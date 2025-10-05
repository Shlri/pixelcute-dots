import Quickshell
import Quickshell.Hyprland
import QtQuick
import Qt.labs.platform

Item {
    id: wallpaper
    anchors.fill: parent
    z: 0

    MouseArea {
        id: mouseTracker
	anchors.fill: parent
	hoverEnabled: true
	acceptedButtons: Qt.NoButton
    }

    // layer 1
    Image {
        id: bgLayer
	anchors.fill: parent
	source: "~/.config/quickshell/pc/assets/wallpapers/bg.jpg"
	fillMode: Image.PreserveAspectCrop
	smooth: true
	layer.enabled: true
	layer.smooth: true
	z:0

	x:(parent.width / 2) - (mouseTracker.mouseX * 0.02)
	y: (parent.height / 2) - (mouseTracker.mouseY * 0.02)
        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
    }
}
