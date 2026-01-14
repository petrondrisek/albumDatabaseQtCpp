import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1

Item {
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    property string imageUrl: ""

    RowLayout {
        anchors.fill: parent

        id: layout

        spacing: 12

        // File dialog and open button
        Button {
            text: qsTr("Select image")
            onClicked: fileDialog.open()
        }

        FileDialog {
            id: fileDialog
            title: qsTr("Choose image file")
            nameFilters: ["BMP files (*.bmp)"]
            onAccepted: {
                if(fileDialog.currentFile) {
                    imageUrl = fileDialog.currentFile
                }
            }
        }

        // Clear button, displays only when image is selected
        DestructiveButton {
            visible: imageUrl.length > 0

            text: qsTr("Clear")

            onClicked: {
                imageUrl = ""
            }
        }

        // Preview image box, displays only when image is selected
        Rectangle {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100

            visible: imageUrl.length > 0

            border.width: 1
            border.color: Material.color(Material.Grey, Material.Shade400)
            radius: 4

            Image {
                anchors.fill: parent
                anchors.margins: 4

                id: previewImage

                source: imageUrl
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false

                opacity: status === Image.Ready ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }
    }

}
