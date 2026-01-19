import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Enums 1.0


ApplicationWindow {
    id: main

    minimumWidth: 900
    width: 1220
    minimumHeight: 600
    height: 720

    visible: true

    title: qsTr("CD database")

    Material.theme: themeManager.currentTheme === Theme.LIGHT ? Material.Light : Material.Dark
    Material.primary: Material.Indigo
    Material.accent: Material.Blue

    property string modalType: "add"
    property var selectedAlbum

    menuBar: AppMenuBar { }

    Modal {
        id: modal

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.fillWidth: true

            spacing: 12

            // Add new album (visible if modalType == add)
            AddAlbumForm {
                Layout.fillWidth: true

                visible: main.modalType == "add"

                // Signal
                onSubmit: (name, author, year, genre, image) => {
                    let id = db.insertAlbum(name, author, year, genre)

                    if(image) {
                        imageFile.uploadImage(image, id)
                    }

                    modal.hide()
                }
            }

            // Detail of selected album (visible if modelType == detail)
            AlbumDetail {
                Layout.fillWidth: true

                visible: main.modalType == "detail"
                selectedModel: main.selectedAlbum

                // Signal
                onEditAlbum: (album) => {             
                    main.selectedAlbum = album
                    main.modalType = "edit"
                }

                // Signal
                onAlbumDeleted: () => {
                    main.selectedAlbum = null
                    main.modalType = "add"

                    modal.hide()
                }
            }

            // Edit album (visible if modalType == edit)
            EditAlbumForm {
                Layout.fillWidth: true

                visible: main.modalType == "edit"
                selectedModel: main.selectedAlbum

                // Signal
                onSubmit: (name, author, year, genre, image, imageChanged) => {
                    if(main.selectedAlbum && main.selectedAlbum.id){
                        let id = main.selectedAlbum.id
                        let del = db.updateAlbum(id, name, author, year, genre)

                        if(del && imageChanged) {
                            if(image) {
                                imageFile.uploadImage(image, id)
                            } else {
                                imageFile.deleteImage(id)
                            }
                        }

                        modal.hide()

                        // Update selected album
                        main.selectedAlbum.name = name
                        main.selectedAlbum.author = author
                        main.selectedAlbum.year = year
                        main.selectedAlbum.genre = genre
                        main.selectedAlbum = null
                    }
                }
            }
        }
    }

    // Header (title + add new album)
    ColumnLayout{
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 24

            spacing: 12

            // App name
            Label {
                Layout.leftMargin: 24

                text: qsTr("CD DATABASE")
                font.pixelSize: 28
                font.bold: true
                color: Material.accent
            }

            // Spacing between items
            Item {
                Layout.fillWidth: true
            }

            // Add new album button
            Button {
                Layout.rightMargin: 24

                text: qsTr("Add new album")

                onClicked: {
                    main.modalType = "add"
                    main.selectedAlbum = null
                    modal.show()
                }
            }
        }

        SearchPanel {
            Layout.margins: 24
            Layout.fillWidth: true
        }

        AlbumList {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Signal
            onAlbumShowDetail: (album) => {
                main.selectedAlbum = album
                main.modalType = "detail"
                modal.show()
            }
        }
    }
}
