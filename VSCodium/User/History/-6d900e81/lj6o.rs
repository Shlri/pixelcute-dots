use bevy::prelude::*;

fn main() {
    App::new().run()
}

pub fn hello_world() {
    println!("hello world")
}

#[derive(Component)]
pub struct Person {
    pub name: String
}