import Quickshell
import Quickshell.Hyprland
import Quickshell.Pipewire 
import Quickshell.SystemTray 
import QtQuick

PanelWindow {
    id: bar
    anchors.bottom: true
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width
    height: 32
    color: "#e0e0e0"
    radius: 12

    // Пастельная палитра
    property color textColor: "#333333"
    property color blueColor: "#89CFF0"
    property color pinkColor: "#FFB6C1"

    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // Воркспейсы (слева)
        HyprlandWorkspaces {
            color: textColor
            activeColor: blueColor
            hoverColor: pinkColor
            font.pixelSize: 14
        }

        // Разделитель
        Item {
            width: parent.width * 0.2
            height: 1
        }

        // Фокусированное окно
        HyprlandActiveWindow {
            format: "{title}"
            color: textColor
            font.pixelSize: 12
            maxLength: 20
        }

        // Разделитель
        Item {
            width: 10
            height: 1
        }

        // Звук
        PipewireVolume {
            format = "{icon} {volume}%"
            color: textColor
            iconColors = {
                muted: pinkColor,
                low: textColor,
                medium: blueColor,
                high: blueColor
            }
            font.pixelSize: 14
        }

        // Разделитель
        Item {
            width: parent.width * 0.3
            height: 1
        }

        // Время (справа)
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 80  // Отступ для трея
            text: Qt.formatDateTime(new Date(), "hh:mm:ss")
            color: textColor
            font.pixelSize: 14
            font.family: "Fira Sans"

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: parent.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
            }
        }

        // Трей (справа, после времени)
        SystemTray {
            anchors.right: parent.right
            anchors.rightMargin: 10
            spacing: 5  // Расстояние между иконками
            iconSize: 20  // Размер иконок
            iconColor: textColor  // Серый для иконок
            hoverColor: blueColor  // Голубой на hover
        }
    }
}