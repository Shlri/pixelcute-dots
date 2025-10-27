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

			anchors {
				right: true
				bottom: true
                top: true
                left: true
			}

			margins {
				right: 0
				bottom: 0
                top: 0
				left: 0
			}

			implicitWidth: content.width
			implicitHeight: content.height

			color: "transparent"

			// Give the window an empty click mask so all clicks pass through it.
			mask: Region {}

			// Use the wlroots specific layer property to ensure it displays over
			// fullscreen windows.
			WlrLayershell.layer: WlrLayer.Overlay

			ColumnLayout {
				id: content

				Text {
					text: "Activate Linux"
					color: "#50ffffff"
					font.pointSize: 22
				}

				Text {
					text: "Go to Settings to activate Linux"
					color: "#50ffffff"
					font.pointSize: 14
				}
			}
		}
	}
}
