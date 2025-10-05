import Quickshell
import Quickshell.Hyprland
import QtQuick
import Qt.labs.platform

Item {
    id: wallpaper
    anchors.fill: parent
    z: 0

    // Пастельная тема (встроенная)
    property color textColor: "#333333"
    property color pinkColor: "#FFB6C1"
    property color baseColor: "#f5f5f5"  // Fallback белый, если JPG не грузится

    property string wallpapersPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/quickshell/pc/assets/wallpapers/"

    MouseArea {
        id: mouseTracker
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    // Fallback фон (белый, если ничего не грузится)
    Rectangle {
        anchors.fill: parent
        color: baseColor
        z: 0
    }

    // Единственный слой: Твоя JPG с параллаксом (медленный сдвиг)
    Image {
        id: singleLayer
        anchors.fill: parent
        source: "file://" + wallpaper.wallpapersPath + "single-wallpaper.jpg"  // Твоя JPG
        fillMode: Image.PreserveAspectCrop
        smooth: true
        layer.enabled: true
        layer.smooth: true
        z: 1  // Поверх fallback

        x: (parent.width / 2) - (mouseTracker.mouseX * 0.03)  // Лёгкий параллакс (3%)
        y: (parent.height / 2) - (mouseTracker.mouseY * 0.03)
        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
    }

    // Часы (поверх всего)
    Text {
        id: clockText
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        text: Qt.formatDateTime(new Date(), "hh:mm:ss")
        color: textColor
        font.pixelSize: 24
        font.family: "Fira Sans"
        style: Text.Outline
        styleColor: pinkColor
        layer.enabled: true
        z: 2
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
    }
}
