import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import Enums 1.0


ApplicationWindow {
    id: main
    width: 1220
    minimumWidth: 800
    height: 720
    minimumHeight: 600
    visible: true
    title: qsTr("CD database")

    Material.theme: themeManager.currentTheme === Theme.LIGHT ? Material.Light : Material.Dark
    Material.primary: Material.Indigo
    Material.accent: Material.Blue

    menuBar: AppMenuBar { }

    property string modalType: "add"
    property var selectedAlbum

    Modal {
        id: modal

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 12

            // Add new album (visible if modal_type = add)
            AddAlbumForm {
                Layout.fillWidth: true
                visible: main.modalType == "add"

                // Signal
                onSubmit: (name, author, year, genre, image) => {
                    let id = db.insert_album(name, author, year, genre)

                    if(image) {
                        imageFile.upload_image(image, id)
                    }

                    modal.hide()
                }
            }

            // Detail of selected album (visible if model_type = detail)
            AlbumDetail {
                id: albumDetail
                Layout.fillWidth: true
                visible: main.modalType == "detail"
                selectedModel: main.selectedAlbum

                onEditAlbum: (album) => {
                    main.modalType = "edit"
                    main.selectedAlbum = album
                }

                onAlbumDeleted: () => {
                    main.selectedAlbum = null
                    main.modalType = "add"
                    modal.hide()
                }
            }

            // Edit album
            EditAlbumForm {
                Layout.fillWidth: true
                visible: main.modalType == "edit"
                selectedModel: main.selectedAlbum

                // Signal
                onSubmit: (name, author, year, genre, image) => {
                    if(main.selectedAlbum && main.selectedAlbum.id){
                        let id = main.selectedAlbum.id
                        let del = db.update_album(id, name, author, year, genre)

                        if(del) {
                            if(image) {
                                imageFile.upload_image(image, id)
                            } else {
                                imageFile.delete_image(id)
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
                text: qsTr("CD DATABASE")
                font.pixelSize: 28
                font.bold: true
                Layout.leftMargin: 24
                color: Material.accent
            }

            // Spacing between items
            Item {
                Layout.fillWidth: true
            }

            // Add new album
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
