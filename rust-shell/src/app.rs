mod wallpaper;

use anyhow::{Context, Result};
use smithay_client_toolkit::{
    compositor::{CompositorHandler, CompositorState},
    delegate_compositor, delegate_layer, delegate_output, delegate_registry, delegate_shm,
    output::{OutputHandler, OutputState},
    registry::{ProvidesRegistryState, RegistryState},
    registry_handlers,
    shell::wlr_layer::{LayerShell, LayerShellHandler, LayerSurface, LayerSurfaceConfigure},
    shm::{Shm, ShmHandler},
};
use wayland_client::{
    globals::registry_queue_init,
    protocol::{wl_output, wl_surface},
    Connection, EventQueue, QueueHandle,
};

use wallpaper::Wallpaper;

pub struct App {
    registry_state: RegistryState,
    output_state: OutputState,
    shm: Shm,
    wallpaper: Option<Wallpaper>,
    exit: bool,
}

impl App {
    pub fn new() -> Result<(Self, EventQueue<Self>)> {
        let conn = Connection::connect_to_env().context("Failed to connect to Wayland")?;
        let (globals, event_queue) = registry_queue_init::<Self>(&conn)?;
        let qh = event_queue.handle();

        let registry_state = RegistryState::new(&globals);
        let output_state = OutputState::new(&globals, &qh);
        let shm = Shm::bind(&globals, &qh)?;

        let compositor = CompositorState::bind(&globals, &qh)?;
        let layer_shell = LayerShell::bind(&globals, &qh)?;
        
        let wallpaper = Wallpaper::new(&compositor, &layer_shell, &shm.wl_shm(), &qh)?;

        let app = Self {
            registry_state,
            output_state,
            shm,
            wallpaper: Some(wallpaper),
            exit: false,
        };

        Ok((app, event_queue))
    }

    pub fn run(&mut self, mut event_queue: EventQueue<Self>) -> Result<()> {
        println!("Event loop started");

        while !self.exit {
            event_queue.blocking_dispatch(self)?;
        }

        Ok(())
    }
}

impl CompositorHandler for App {
    fn scale_factor_changed(&mut self, _: &Connection, _: &QueueHandle<Self>, _: &wl_surface::WlSurface, _: i32) {}
    fn transform_changed(&mut self, _: &Connection, _: &QueueHandle<Self>, _: &wl_surface::WlSurface, _: wl_output::Transform) {}
    fn frame(&mut self, _: &Connection, _: &QueueHandle<Self>, surface: &wl_surface::WlSurface, _: u32) {
        if let Some(wp) = &mut self.wallpaper {
            wp.draw(surface);
        }
    }
    fn surface_enter(&mut self, _: &Connection, _: &QueueHandle<Self>, _: &wl_surface::WlSurface, _: &wl_output::WlOutput) {}
    fn surface_leave(&mut self, _: &Connection, _: &QueueHandle<Self>, _: &wl_surface::WlSurface, _: &wl_output::WlOutput) {}
}

impl OutputHandler for App {
    fn output_state(&mut self) -> &mut OutputState { &mut self.output_state }
    fn new_output(&mut self, _: &Connection, _: &QueueHandle<Self>, _: wl_output::WlOutput) {}
    fn update_output(&mut self, _: &Connection, _: &QueueHandle<Self>, _: wl_output::WlOutput) {}
    fn output_destroyed(&mut self, _: &Connection, _: &QueueHandle<Self>, _: wl_output::WlOutput) {}
}

impl LayerShellHandler for App {
    fn closed(&mut self, _: &Connection, _: &QueueHandle<Self>, _: &LayerSurface) {
        self.exit = true;
    }

    fn configure(&mut self, _: &Connection, qh: &QueueHandle<Self>, _: &LayerSurface, cfg: LayerSurfaceConfigure, _: u32) {
        if let Some(wp) = &mut self.wallpaper {
            wp.configure(cfg, qh);
        }
    }
}

impl ShmHandler for App {
    fn shm_state(&mut self) -> &mut Shm { &mut self.shm }
}

impl ProvidesRegistryState for App {
    fn registry(&mut self) -> &mut RegistryState { &mut self.registry_state }
    registry_handlers![OutputState];
}

delegate_compositor!(App);
delegate_output!(App);
delegate_layer!(App);
delegate_shm!(App);
delegate_registry!(App);