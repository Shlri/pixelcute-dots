import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
	Variants {
		// Create the panel once on each monitor.
		model: Quickshell.screens

		PanelWindow {
			id: w

			property var modelData
			screen: modelData

			implicitWidth: content.width
			implicitHeight: content.height

			color: "transparent"

            anchors {
                bottom: true
            }
			// Give the window an empty click mask so all clicks pass through it.
			mask: Region {}

			// Use the wlroots specific layer property to ensure it displays over
			// fullscreen windows.
            WlrLayershell.layer: WlrLayer.Overlay

			ColumnLayout {
				id: content

				Text {
					text: "Activate Linux"
					color: '#50000000'
					font.pointSize: 22
				}
			}
		}
	}
}
