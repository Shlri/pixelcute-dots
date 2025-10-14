use bevy::prelude::*;

fn main() {
    App::new().add_system(hello_world).run()
}

pub fn hello_world() {
    println!("hello world")
}

#[derive(Component)]
pub struct Person {
    pub name: String
}