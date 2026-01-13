import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Enums 1.0

Rectangle {
    id: modal
    anchors.fill: parent
    color: themeManager.currentTheme === Theme.LIGHT ? "#DDFFFFFF" : "#DD000000"
    visible: opacity > 0.01
    opacity: 0
    z: 1000

    function show() {
        modal.opacity = 1
    }

    function hide() {
        modal.opacity = 0
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }
    }

    default property alias content: contentItem.data

    // Blocks clicking on elements behind z-index
    MouseArea {
        anchors.fill: parent
        onClicked: modal.hide()
    }

    Button {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        background: Rectangle {
            id: closeButtonArea
            color: "transparent"
        }
        contentItem: Text {
            id: closeButtonText
            property bool hovered: false
            property real scaleFactor: hovered ? 1.2 : 1

            text: "\u2715"   // ×
            font.pixelSize: 28
            color: themeManager.currentTheme === Theme.LIGHT
                    ? hovered ? "#FF404040" : "#FF000000"
                    : hovered ? "#FFDDDDDD" : "#FFFFFFFF"

            transform: Scale {
                xScale: closeButtonText.scaleFactor
                yScale: closeButtonText.scaleFactor
                origin.x: closeButtonText.width/2
                origin.y: closeButtonText.height/2
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Behavior on scaleFactor {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutCubic
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: closeButtonText.hovered = true
            onExited: closeButtonText.hovered = false

            onClicked: modal.hide()
        }
    }

    Frame {
        id: frame
        anchors.centerIn: parent

        width: parent.width - 200
        height: parent.height - 200

        // Animation
        property bool displayed: modal.visible
        property real offsetY: displayed ? 0 : -24

        transform: Translate {
            id: translate
            y: frame.offsetY
        }

        Behavior on offsetY {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutCubic
            }
        }

        // background
        background: Rectangle {
            id: frameRect
            color: Material.background
            radius: 6
            border.width: 1
            border.color: Material.color(Material.Grey)
        }

        ScrollView {
            id: scrollView
            anchors.fill: parent
            clip: true
            contentHeight: contentItem.implicitHeight + 56 // base fix for top/bottom margin

            ColumnLayout {
                id: contentItem
                width: scrollView.width - 56  // width - padding
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.top: parent.top
                anchors.topMargin: 28
                anchors.bottomMargin: 28
                spacing: 12
            }
        }
    }
}
