import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Enums 1.0

Item {
    id: root

    signal albumShowDetail(var album)

    GridView {
        anchors.fill: parent
        anchors.margins: 12

        id: albumGrid
        model: db.albums // { id, name, author, year, genre }

        cellWidth: 292
        cellHeight: 320
        clip: true

        // Center items
        readonly property int columns: Math.floor(width / cellWidth)
        contentItem.x: albumGrid.width % (columns * albumGrid.cellWidth) / 2

        delegate: Item {
            id: albumDelegate

            width: albumGrid.cellWidth
            height: albumGrid.cellHeight

            property int albumId: modelData && modelData.id ? modelData.id : -1
            property string imageUrl: modelData && modelData.id ? imageFile.getImage(modelData.id) : ""
            property int imageVer: 0

            // Item area
            Rectangle {
                anchors.centerIn: parent

                width: albumGrid.cellWidth - 12
                height: albumGrid.cellHeight - 12
                clip: true

                color: "transparent"
                border.color: mouseArea.containsMouse
                              ? Material.accent
                              : Material.color(Material.Grey)
                border.width: 1
                radius: 4

                // Animation border
                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                // Hover effect
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData && modelData.id) {
                            root.albumShowDetail(db.albums[index])
                            db.fetchSongs(modelData.id) // fetch selected album songs list
                        }
                    }
                }

                // Item image
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter

                    id: albumWrapper

                    x: 0
                    y: 4
                    height: albumGrid.cellHeight * 0.75
                    width: albumGrid.cellWidth - 16
                    clip: true

                    Image {
                        id: albumCover

                        width: albumWrapper.width
                        height: albumWrapper.height
                        fillMode: Image.PreserveAspectFit

                        source: albumDelegate.imageUrl
                                ? albumDelegate.imageUrl + "?v=" + albumDelegate.imageVer
                                : ""
                        asynchronous: true
                        cache: false

                        opacity: status === Image.Ready ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }

                    // Default when image is not set
                    Label {
                        anchors.centerIn: parent

                        text: "N/A"
                        color: Material.color(Material.Grey)
                        font.pixelSize: 72

                        visible: albumCover.status !== Image.Ready
                        opacity: visible ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }

                // Album name
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    id: albumName

                    x: 0
                    y: albumGrid.cellHeight * 0.8
                    height: albumGrid.height * 0.2
                    width: albumGrid.cellWidth - 32
                    maximumLineCount: 1
                    elide: Text.ElideRight

                    text: modelData.name
                    color: mouseArea.containsMouse ? Material.accent : Material.color(Material.Grey)
                    font.bold: true
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                // Album author
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    property int topMargin: 4

                    x: 0
                    y: albumGrid.cellHeight * 0.8 + (topMargin + albumName.font.pixelSize)
                    height: albumGrid.height * 0.2
                    width: albumGrid.cellWidth - 32

                    text: modelData.author
                    color: Material.color(Material.Grey)
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                // Genre badge
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 16
                    anchors.leftMargin: -40

                    width: 140
                    height: 28

                    rotation: -45

                    color: Material.accent

                    Label {
                        anchors.centerIn: parent

                        text: modelData
                              ? modelData.genre
                              : ""
                        color: themeManager.currentTheme === Theme.LIGHT ? "white" : "black"
                        font.pixelSize: 8
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            interactive: true
        }
    }

    // Display when album count == 0
    ColumnLayout {
        anchors.centerIn: parent

        visible: albumGrid.count === 0
        spacing: 16

        Label {
            Layout.alignment: Qt.AlignHCenter

            text: qsTr("No albums found")
            font.pixelSize: 24
            font.bold: true
            color: Material.color(Material.Grey)
        }
    }

    // Loads image asynchronously after uploading
    Connections {
        target: imageFile

        function onImageReady(albumId) {
            for (let i = 0; i < albumGrid.count; ++i) {
                let item = albumGrid.itemAtIndex(i)

                if (item && item.albumId === albumId) {
                    item.imageUrl = imageFile.getImage(albumId)
                    item.imageVer += 1
                    break;
                }
            }
        }
    }
}
