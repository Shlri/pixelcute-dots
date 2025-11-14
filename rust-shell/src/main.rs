mod app;

fn main() -> anyhow::Result<()> {
    println!("Starting shell...");

    let (mut app, event_queue) = app::App::new();
    app.run(event_queue)?;

    Ok(())
}