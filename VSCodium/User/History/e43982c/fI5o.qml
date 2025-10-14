import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire 
import Quickshell.Services.SystemTray 
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

        Row {
            spacing: 5

            Repeater {
                model: Hyprland.workspaces  // Модель из HyprlandIpc

                Rectangle {
                    id: wsRect
                    required property var modelData  // Доступ к HyprlandWorkspace
                    width: 30; height: 20
                    radius: 5
                    color: modelData.lastActive ? blueColor : textColor  // Голубой, если active
                    border.color: pinkColor  // Розовый бордер на hover (MouseArea ниже)

                    Text {
                        anchors.centerIn: parent
                        text: modelData.id.toString()  // ID воркспейса (1, 2, ...)
                        color: "white"
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: wsRect.color = pinkColor  // Розовый hover
                        onExited: wsRect.color = modelData.lastActive ? blueColor : textColor
                        onClicked: Hyprland.dispatch("workspace", modelData.id)  // Переключение
                    }
                }
            }
        }

        Item {
            width: parent.width * 0.2
            height: 1
        }

        PwNode {
            format: "{icon} {volume}%"
            color: textColor
            font.pixelSize: 14
        }

        Item {
            width: parent.width * 0.3
            height: 1
        }

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

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            spacing: 5

            Repeater {
                model: SystemTray.items  // Модель иконок трея

                Image {
                    id: trayIcon
                    required property var modelData  // Доступ к TrayItem
                    source: modelData.icon  // Иконка из трея
                    width: 20; height: 20
                    fillMode: Image.PreserveAspectFit
                    color: textColor  // Серый для иконок

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: trayIcon.color = blueColor  // Голубой hover
                        onExited: trayIcon.color = textColor
                        onClicked: modelData.activate()  // Открывает меню/приложение
                    }
                }
            }
        }
    }
}