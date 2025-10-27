import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens

        Wallpaper{
            property var modelData
            screen: modelData
        }
    }
    Volume{}
}

