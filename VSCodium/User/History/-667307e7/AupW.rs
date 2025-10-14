use bevy::prelude::*;
use bevy::ui::prelude::*;

#[derive(States, Default, Debug, Clone, Eq, PartialEq, Hash)]
enum AppState {
    #[default]
    Menu,
    Game,
}

#[derive(Component)]
struct MenuUiRoot;

#[derive(Component)]
struct SettingsButton;

#[derive(Component)]
struct StartButton;

#[derive(Component)]
struct QuitButton;

#[derive(Component)]
struct VolumeSlider;

#[derive(Resource, Default)]
struct GameSettings {
    volume: f32,
}

pub fn setup_menu(mut commands: Commands, asset_server: Res<AssetServer>) {
    commands.spawn((
        NodeBundle {
            style: Style {
                width: Val::Percent(100.0),
                height: Val::Percent(100.0),
                flex_direction: FlexDirection::Column,
                justify_content: JustifyContent::Center,
                align_items: AlignItems::Center,
                ..default()
            },
            background_color: Color::srgb(0.1, 0.1, 0.2).into(),  // Тёмный фон для horror
            ..default()
        },
        MenuUiRoot,
    ))
    .with_children(|parent| {
        // Заголовок
        parent.spawn((
            TextBundle::from_section(
                "Pathologic Clone",
                TextStyle {
                    font_size: 50.0,
                    color: Color::WHITE,
                    ..default()
                },
            ),
            Text::default(),
        ));

        // Кнопка Start
        parent.spawn((
            ButtonBundle {
                style: Style {
                    width: Val::Px(150.0),
                    height: Val::Px(65.0),
                    margin: UiRect::all(Val::Px(10.0)),
                    justify_content: JustifyContent::Center,
                    align_items: AlignItems::Center,
                    ..default()
                },
                background_color: Color::srgb(0.15, 0.15, 0.15).into(),
                ..default()
            },
            StartButton,
        ))
        .with_children(|parent| {
            parent.spawn(TextBundle::from_section(
                "Новая игра",
                TextStyle {
                    font_size: 20.0,
                    color: Color::WHITE,
                    ..default()
                },
            ));
        });

        // Кнопка Settings
        parent.spawn((
            ButtonBundle {
                style: Style {
                    width: Val::Px(150.0),
                    height: Val::Px(65.0),
                    margin: UiRect::all(Val::Px(10.0)),
                    justify_content: JustifyContent::Center,
                    align_items: AlignItems::Center,
                    ..default()
                },
                background_color: Color::srgb(0.15, 0.15, 0.15).into(),
                ..default()
            },
            SettingsButton,
        ))
        .with_children(|parent| {
            parent.spawn(TextBundle::from_section(
                "Настройки",
                TextStyle {
                    font_size: 20.0,
                    color: Color::WHITE,
                    ..default()
                },
            ));
        });

        // Слайдер Volume (показываем в настройках, но для примера здесь)
        parent.spawn((
            Slider::default(),
            VolumeSlider,
            Style {
                width: Val::Px(200.0),
                ..default()
            },
        ));

        // Кнопка Quit
        parent.spawn((
            ButtonBundle {
                style: Style {
                    width: Val::Px(150.0),
                    height: Val::Px(65.0),
                    margin: UiRect::all(Val::Px(10.0)),
                    justify_content: JustifyContent::Center,
                    align_items: AlignItems::Center,
                    ..default()
                },
                background_color: Color::srgb(0.15, 0.15, 0.15).into(),
                ..default()
            },
            QuitButton,
        ))
        .with_children(|parent| {
            parent.spawn(TextBundle::from_section(
                "Выход",
                TextStyle {
                    font_size: 20.0,
                    color: Color::WHITE,
                    ..default()
                },
            ));
        });
    });
}

fn menu_interaction(
    mut interaction_query: Query<(&Interaction, &mut BackgroundColor), (Changed<Interaction>, With<Button>)>,
    mut app_state: ResMut<NextState<AppState>>,
    mut settings: ResMut<GameSettings>,
    mut slider_query: Query<&mut Slider, With<VolumeSlider>>,
    mut commands: Commands,
) {
    for (interaction, mut color) in &mut interaction_query {
        match *interaction {
            Interaction::Pressed => {
                *color = Color::srgb(0.35, 0.75, 0.35).into();  // Hover эффект
            }
            Interaction::Hovered => {
                *color = Color::srgb(0.25, 0.25, 0.25).into();
            }
            Interaction::None => {
                *color = Color::srgb(0.15, 0.15, 0.15).into();
            }
        }
    }

    // Логика кнопок (добавь query для каждой)
    if /* query для StartButton pressed */ true {  // Замени на реальный query
        app_state.set(AppState::Game);
        commands.spawn(/* Game setup */);
    }
    if /* Settings pressed */ true {
        // Toggle settings panel
    }
    if /* Quit pressed */ true {
        std::process::exit(0);
    }

    // Слайдер: Обнови settings.volume = slider.value().0;
    if let Ok(mut slider) = slider_query.get_single_mut() {
        settings.volume = slider.value().0;
    }
}

// В main.rs: .add_plugins(DefaultPlugins).add_state::<AppState>().add_systems(Startup, setup_menu).add_systems(Update, menu_interaction);