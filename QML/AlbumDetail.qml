import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property var selectedModel // { id, name, author, year, genre }
    property var selectedSong // { id, name, length }

    // signals currently have no deeper meaning
    signal songAdded(int songId)
    signal songDeleted(int songId)
    // -----
    signal albumDeleted(int albumId)
    signal editAlbum(var selectedModel)

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        spacing: 20
        anchors.fill: parent
        anchors.bottomMargin: 60

        // About album - image + basic info
        RowLayout {
            spacing: 24
            Layout.fillWidth: true
            Layout.minimumHeight: 320

            // Image
            Item {
                Layout.preferredWidth: 300
                Layout.minimumWidth: 200
                Layout.maximumWidth: 350
                Layout.minimumHeight: 300
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                Image {
                    id: albumWrapperImage
                    fillMode: Image.PreserveAspectFit
                    source: selectedModel && selectedModel.id ? imageFile.get_image(selectedModel.id) : ""
                    asynchronous: true
                    cache: false

                    anchors.centerIn: parent
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
                    text: "🎵"
                    color: Material.accent
                    font.pixelSize: 120

                    visible: albumWrapperImage.status !== Image.Ready
                    anchors.centerIn: parent
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

                        Label {
                            text: modelData.label
                            color: Material.accent
                            font.bold: true
                        }

                        Label {
                            text: modelData.value
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
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

        // Action panel for adding new song
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.preferredHeight: 60

            ValidationTextField {
                label: qsTr("Song name")
                id: inputName
                Layout.fillWidth: true
            }

            ValidationTextField {
                label: qsTr("Length")
                id: inputLength
                Layout.fillWidth: true
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
                        let songId = db.insert_song(selectedModel.id, inputName.text, inputLength.text)
                        inputName.clear()
                        inputLength.clear()

                        songAdded(songId);
                    }
                }
            }
        }

        // List of stored songs
        ListView {
            id: songList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: db.songs.length ? 300 : 0
            Layout.margins: 12
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
                        text: modelData ? modelData.name : qsTr("Unknown")
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.leftMargin: 12
                    }

                    // Song duration
                    Label {
                        text: modelData ? modelData.length : qsTr("00:00")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.rightMargin: 12
                    }

                    // Delete button for song on this row
                    DestructiveButton {
                        text: qsTr("Delete")
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        Layout.rightMargin: 12
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

        Label {
            text: qsTr("No songs found")
            font.pixelSize: 24
            font.bold: true
            color: Material.color(Material.Grey)
            Layout.fillWidth: true
            visible: songList.count === 0
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Dialog {
        id: deleteDialog

        property string type: "album"
        property string name: "N/A"

        title: qsTr("Confirm")
        modal: true
        anchors.centerIn: Overlay.overlay

        standardButtons: Dialog.Yes | Dialog.No

        onAccepted: {
           if(type === "album") {
               db.delete_album(selectedModel.id)
               albumDeleted(selectedModel.id)
           } else if(type === "song") {
               db.delete_song(selectedSong.id)
               songDeleted(selectedSong.id)
           }
       }

        ColumnLayout {
            spacing: 12

            Label {
                text: qsTr("Are you sure you want to delete %1?").arg(deleteDialog.type)
                font.bold: true
            }

            Label {
                text: deleteDialog.name
                color: Material.accent
                wrapMode: Text.WordWrap
            }
        }
    }
}
