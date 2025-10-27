import Quickshell
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: wallpaper
    
    visible: true
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    // Wallpaper settings (background layer)
    exclusionMode: ExclusionMode.Ignore
    
    // Important: Set Z-order to bottom
    z: -1
    
    // Don't steal focus or input
    mask: Region {}
    
    // Make it non-interactive
    Item {
        anchors.fill: parent
        enabled: false
    }
    // Parallax cursor position (auto-animated)
    property real mouseX: width / 2
    property real mouseY: height / 2
    property real time: 0
    
    // Path to wallpaper assets
    // Path to wallpaper assets
    property string wallpaperPath: Qt.resolvedUrl("assets/wallpapers/1/")
    
    // Smooth automatic parallax animation
    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            time += 0.016
            wallpaper.mouseX = wallpaper.width / 2 + Math.sin(time * 0.3) * 200
            wallpaper.mouseY = wallpaper.height / 2 + Math.cos(time * 0.2) * 150
        }
    }
    
    // Background base color (fallback)
    Rectangle {
        anchors.fill: parent
        color: '#ffffff'
    }
    
    // PARALLAX LAYERS WITH IMAGES
    
    // Layer 3 (far) - slowest movement
    Item {
        id: layer3
        anchors.fill: parent
        
        property real offsetX: (wallpaper.mouseX - parent.width / 2) * 0.01
        property real offsetY: (wallpaper.mouseY - parent.height / 2) * 0.01
        
        x: offsetX
        y: offsetY
        
        Behavior on offsetX { SmoothedAnimation { velocity: 30 } }
        Behavior on offsetY { SmoothedAnimation { velocity: 30 } }
        
        Image {
            anchors.centerIn: parent
            width: parent.width * 1.1
            height: parent.height * 1.1
            source: wallpaperPath + "layer3.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            
            // Fallback if image doesn't exist
            onStatusChanged: {
                if (status === Image.Error) {
                    console.log("Warning: layer3.png not found")
                }
            }
        }
    }
    
    // Layer 2 (middle) - medium movement
    Item {
        id: layer2
        anchors.fill: parent
        
        property real offsetX: (wallpaper.mouseX - parent.width / 2) * 0.03
        property real offsetY: (wallpaper.mouseY - parent.height / 2) * 0.03
        
        x: offsetX
        y: offsetY
        
        Behavior on offsetX { SmoothedAnimation { velocity: 60 } }
        Behavior on offsetY { SmoothedAnimation { velocity: 60 } }
        
        Image {
            anchors.centerIn: parent
            width: parent.width * 1.1
            height: parent.height * 1.1
            source: wallpaperPath + "layer1.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            
            onStatusChanged: {
                if (status === Image.Error) {
                    console.log("Warning: layer1.png not found")
                }
            }
        }
    }
    
    // Layer 1 (near) - fastest movement
    Item {
        id: layer1
        anchors.fill: parent
        
        property real offsetX: (wallpaper.mouseX - parent.width / 2) * 0.05
        property real offsetY: (wallpaper.mouseY - parent.height / 2) * 0.05
        
        x: offsetX
        y: offsetY
        
        Behavior on offsetX { SmoothedAnimation { velocity: 100 } }
        Behavior on offsetY { SmoothedAnimation { velocity: 100 } }
        
        Image {
            anchors.centerIn: parent
            width: parent.width * 1.1
            height: parent.height * 1.1
            source: wallpaperPath + "layer2.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            
            onStatusChanged: {
                if (status === Image.Error) {
                    console.log("Warning: layer1.png not found")
                }
            }
        }
    }
    
    // CLOCK (center screen)
    Item {
        anchors.centerIn: parent
        width: 400
        height: 200
        
        Column {
            anchors.centerIn: parent
            spacing: 10
            
            // Time
            Text {
                id: timeText
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 96
                font.bold: true
                font.family: "Departure Mono"
                color: "#cdd6f4"
                style: Text.Outline
                styleColor: "#1e1e2e"
                
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        var date = new Date()
                        timeText.text = Qt.formatTime(date, "hh:mm")
                    }
                    Component.onCompleted: triggered()
                }
            }
            
            // Date
            Text {
                id: dateText
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 24
                font.family: "Departure Mono"
                color: "#89b4fa"
                
                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: {
                        var date = new Date()
                        var days = ["Sunday", "Monday", "Tuesday", 
                                   "Wednesday", "Thursday", "Friday", "Saturday"]
                        var months = ["January", "February", "March", "April", "May", "June",
                                     "July", "August", "September", "October", "November", "December"]
                        dateText.text = days[date.getDay()] + ", " + 
                                       months[date.getMonth()] + " " + 
                                       date.getDate() + ", " + 
                                       date.getFullYear()
                    }
                    Component.onCompleted: triggered()
                }
            }
        }
    }
}