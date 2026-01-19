import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    property var selectedModel // { id, name, author, year, genre }
    onSelectedModelChanged: {
        inputName.clear()
        inputLength.clear()
    }

    property var selectedSong // { id, name, length }

    // signals without deeper meaning
    signal songAdded(int songId)
    signal songDeleted(int songId)
    // -----
    signal albumDeleted(int albumId)
    signal editAlbum(var selectedModel)

    ColumnLayout {
        anchors.fill: parent
        anchors.bottomMargin: 60

        id: layout
        spacing: 20

        // About album - image + info
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: 320

            spacing: 24

            // Image
            Item {
                Layout.minimumWidth: 200
                Layout.preferredWidth: 300
                Layout.maximumWidth: 350
                Layout.minimumHeight: 300
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                Image {
                    anchors.centerIn: parent

                    id: albumWrapperImage

                    fillMode: Image.PreserveAspectFit
                    source: selectedModel && selectedModel.id ? imageFile.getImage(selectedModel.id) : ""
                    asynchronous: true
                    cache: false

                    width: parent.width
                    height: 300
                    opacity: status === Image.Ready ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }

                // Default if image is not set.
                Label {
                    anchors.centerIn: parent

                    text: "🎵"
                    color: Material.accent
                    font.pixelSize: 120

                    visible: albumWrapperImage.status !== Image.Ready
                    opacity: visible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }

            // Info
            ColumnLayout {
                Layout.fillWidth: true

                spacing: 12

                Repeater {
                    model: [
                        { label: qsTr("Album name"), value: selectedModel ? selectedModel.name : qsTr("None") },
                        { label: qsTr("Author"), value: selectedModel ? selectedModel.author : qsTr("None") },
                        { label: qsTr("Year"), value: selectedModel ? selectedModel.year : qsTr("None") },
                        { label: qsTr("Genre"), value: selectedModel ? selectedModel.genre : qsTr("None") }
                    ]

                    delegate: ColumnLayout {
                        spacing: 4

                        // Model item label
                        Label {
                            Layout.fillWidth: true

                            text: modelData.label
                            color: Material.accent
                            font.bold: true
                        }

                        // Model item value
                        Label {
                            Layout.fillWidth: true

                            text: modelData.value
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // Action panel for managing album
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 12
                    Layout.preferredHeight: 60

                    // Edit
                    Button {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                        text: qsTr("Edit album")
                        onClicked: editAlbum(root.selectedModel)
                    }

                    // Delete
                    DestructiveButton {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                        text: qsTr("Delete album")
                        onClicked: {
                            if(selectedModel && selectedModel.id) {
                                deleteDialog.type = "album"
                                deleteDialog.name = selectedModel.name
                                deleteDialog.open()
                            }
                        }
                    }
                }
            }
        }

        // Panel for adding new song
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.preferredHeight: 60

            ValidationTextField {
                Layout.fillWidth: true

                id: inputName
                label: qsTr("Song name")
            }

            ValidationTextField {
                Layout.fillWidth: true

                id: inputLength
                label: qsTr("Length")
                validationFn: function(text) {
                    let valid = true
                    let error = ""

                    if(!/^\d{2}:[0-5]\d$/.test(text)) {
                        valid = false
                        error = qsTr("Please use format 00:00")
                    }

                    return { valid, error }
                }
            }

            Button {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                text: qsTr("Add song")
                onClicked: {
                    inputName.validate()
                    inputLength.validate()

                    if(
                        selectedModel
                        && selectedModel.id
                        && inputName.valid
                        && inputLength.valid
                    ) {
                        let songId = db.insertSong(selectedModel.id, inputName.text, inputLength.text)
                        inputName.clear()
                        inputLength.clear()

                        songAdded(songId);
                    }
                }
            }
        }

        // List of stored songs
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: db.songs.length ? 300 : 0
            Layout.margins: 12

            id: songList
            model: db.songs // { id, name, length }

            delegate: Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                border.color: "lightgrey"
                border.width: 1
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    spacing: 12

                    // Song name
                    Label {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.leftMargin: 12

                        text: modelData ? modelData.name : qsTr("Unknown")
                    }

                    // Song duration
                    Label {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.rightMargin: 12

                        text: modelData ? modelData.length : qsTr("00:00")
                    }

                    // Delete button for song on this row
                    DestructiveButton {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.rightMargin: 12

                        text: qsTr("Delete")
                        onClicked: {
                            if(modelData && modelData.id) {
                                deleteDialog.type = "song"
                                deleteDialog.name = modelData.name
                                selectedSong = modelData
                                deleteDialog.open()
                            }
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                interactive: true
            }
        }

        // Displays when songs count = 0
        Label {
            Layout.fillWidth: true

            text: qsTr("No songs found")
            font.pixelSize: 24
            font.bold: true
            color: Material.color(Material.Grey)
            horizontalAlignment: Text.AlignHCenter
            visible: songList.count === 0
        }
    }

    // Confirm dialog for deletion
    Dialog {
        anchors.centerIn: Overlay.overlay

        id: deleteDialog
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        title: qsTr("Confirm")

        property string type: "album"
        property string name: "N/A"

        onAccepted: {
           if(type === "album") {
               let del = db.deleteAlbum(selectedModel.id)
               if(del) {
                   imageFile.deleteImage(selectedModel.id)
               }

               albumDeleted(selectedModel.id)
           } else if(type === "song") {
               db.deleteSong(selectedSong.id)
               songDeleted(selectedSong.id)
           }
       }

        ColumnLayout {
            spacing: 12

            // Header
            Label {
                text: qsTr("Are you sure you want to delete %1?").arg(deleteDialog.type)
                font.bold: true
            }

            // Body
            Label {
                text: deleteDialog.name
                color: Material.accent
                wrapMode: Text.WordWrap
            }
        }
    }
}
