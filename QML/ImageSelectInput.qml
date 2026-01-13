import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.1

Item {
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    property string imageUrl: ""

    RowLayout {
        id: layout
        spacing: 12
        anchors.fill: parent

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

        Button {
            visible: imageUrl.length > 0
            text: qsTr("Clear")

            onClicked: {
                imageUrl = ""
            }
        }

        Rectangle {
            visible: imageUrl.length > 0

            Layout.preferredWidth: 100
            Layout.preferredHeight: 100

            radius: 4
            border.width: 1
            border.color: Material.color(Material.Grey, Material.Shade400)

            Image {
                id: previewImage

                anchors.fill: parent
                anchors.margins: 4

                fillMode: Image.PreserveAspectFit
                source: imageUrl
                asynchronous: true
                opacity: status === Image.Ready ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }

            BusyIndicator {
                anchors.centerIn: parent

                running: previewImage.status === Image.Loading
                visible: running

                width: 40
                height: 40

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: parent.height + 8
                    radius: width / 2
                    color: Material.background
                    opacity: 0.8
                    z: -1
                }
            }
        }
    }

}
