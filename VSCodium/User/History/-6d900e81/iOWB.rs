use bevy::prelude::*;

fn main() {
    App::new().run()
}

pub fn setup(mut commands: Commands) {
    
}

#[derive(Component)]
pub struct Person {
    pub name: String
}