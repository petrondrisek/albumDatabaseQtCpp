import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: button
    text: qsTr("Delete")

    Material.background: hovered ? Material.Red : Material.color(Material.Red, Material.Shade900)
    Material.foreground: "white"
    highlighted: true

    contentItem: Label {
        text: button.text
        color: "white"
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
