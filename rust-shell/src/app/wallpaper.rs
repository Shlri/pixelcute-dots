use anyhow::{Context, Result};
use memmap2::MmapMut;
use smithay_client_toolkit::{
    compositor::CompositorState,
    shell::{
        wlr_layer::{Anchor, KeyboardInteractivity, Layer, LayerShell, LayerSurface, LayerSurfaceConfigure},
        WaylandSurface,
    },
};
use std::os::fd::AsFd;
use wayland_client::{
    protocol::{wl_buffer, wl_shm, wl_shm_pool, wl_surface},
    QueueHandle, Dispatch,
};

pub struct Wallpaper {
    layer: LayerSurface,
    width: u32,
    height: u32,
    buffer: Option<Buffer>,
    shm: wl_shm::WlShm,
    configured: bool,
}

impl Wallpaper {
    pub fn new<D>(
        compositor: &CompositorState,
        layer_shell: &LayerShell,
        shm: &wl_shm::WlShm,
        qh: &QueueHandle<D>,
    ) -> Result<Self>
    where
        D: Dispatch<wl_surface::WlSurface, smithay_client_toolkit::compositor::SurfaceData> + 'static,
        D: Dispatch<LayerSurface, smithay_client_toolkit::shell::wlr_layer::LayerSurfaceData> + 'static,
    {
        let surface = compositor.create_surface(qh);
        let layer = layer_shell.create_layer_surface(qh, surface, Layer::Background, Some("wallpaper"), None);

        layer.set_anchor(Anchor::all());
        layer.set_keyboard_interactivity(KeyboardInteractivity::None);
        layer.set_exclusive_zone(-1);
        layer.commit();

        Ok(Self {
            layer,
            width: 1920,
            height: 1080,
            buffer: None,
            shm: shm.clone(),
            configured: false,
        })
    }

    pub fn configure<D>(&mut self, cfg: LayerSurfaceConfigure, qh: &QueueHandle<D>)
    where
        D: Dispatch<wl_shm_pool::WlShmPool, ()> + 'static,
        D: Dispatch<wl_buffer::WlBuffer, ()> + 'static,
    {
        if cfg.new_size.0 != 0 { self.width = cfg.new_size.0; }
        if cfg.new_size.1 != 0 { self.height = cfg.new_size.1; }

        self.configured = true;
        println!("Configured: {}x{}", self.width, self.height);

        if let Ok(buf) = Buffer::new(&self.shm, qh, self.width, self.height) {
            self.buffer = Some(buf);
        }
    }

    pub fn draw(&mut self, surface: &wl_surface::WlSurface) {
        if !self.configured { return; }
        let Some(buf) = &mut self.buffer else { return; };

        buf.draw(|data, w, h| {
            for y in 0..h {
                for x in 0..w {
                    let i = ((y * w + x) * 4) as usize;
                    data[i] = 20;       // B
                    data[i + 1] = 20;   // G
                    data[i + 2] = 30;   // R
                    data[i + 3] = 255;  // A
                }
            }
        });

        surface.attach(Some(buf.buffer()), 0, 0);
        surface.damage_buffer(0, 0, self.width as i32, self.height as i32);
        surface.commit();
    }
}

struct Buffer {
    _mmap: MmapMut,
    pool: wl_shm_pool::WlShmPool,
    buffer: wl_buffer::WlBuffer,
    data: *mut u8,
    len: usize,
}

impl Buffer {
    fn new<D>(shm: &wl_shm::WlShm, qh: &QueueHandle<D>, w: u32, h: u32) -> Result<Self>
    where
        D: Dispatch<wl_shm_pool::WlShmPool, ()> + 'static,
        D: Dispatch<wl_buffer::WlBuffer, ()> + 'static,
    {
        let stride = w * 4;
        let len = (stride * h) as usize;

        let fd = rustix::fs::memfd_create("pixelcute-shm", rustix::fs::MemfdFlags::CLOEXEC)?;
        rustix::io::write(&fd, &vec![0u8; len])?;

        let mmap = unsafe { MmapMut::map_mut(&fd)? };
        let data = mmap.as_ptr() as *mut u8;

        let pool = shm.create_pool(fd.as_fd(), len as i32, qh, ());
        let buffer = pool.create_buffer(0, w as i32, h as i32, stride as i32, wl_shm::Format::Argb8888, qh, ());

        Ok(Self { _mmap: mmap, pool, buffer, data, len })
    }

    fn draw<F>(&mut self, f: F) where F: FnOnce(&mut [u8], u32, u32) {
        let slice = unsafe { std::slice::from_raw_parts_mut(self.data, self.len) };
        let w = self.len as u32 / 4;
        let h = if w > 0 { self.len as u32 / w } else { 0 };
        f(slice, w, h);
    }

    fn buffer(&self) -> &wl_buffer::WlBuffer { &self.buffer }
}

impl Drop for Buffer {
    fn drop(&mut self) {
        self.buffer.destroy();
        self.pool.destroy();
    }
}