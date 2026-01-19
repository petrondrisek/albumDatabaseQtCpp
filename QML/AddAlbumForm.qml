import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    signal submit(var name, var author, var year, var genre, var image)

    ColumnLayout {
        anchors.fill: parent

        id: layout

        spacing: 20

        // Header
        Label {
            Layout.bottomMargin: 12

            text: qsTr("Add new album")
            font.pixelSize: 18
            font.bold: true
        }

        // Inputs
        ValidationTextField {
            Layout.fillWidth: true

            id: inputName
            label: qsTr("Album name")
        }

        ValidationTextField {
            Layout.fillWidth: true

            id: inputAuthor
            label: qsTr("Author")
        }

        ValidationTextField {
            Layout.fillWidth: true

            id: inputYear
            label: qsTr("Year")
            validationFn: function(text) {
                let valid = true;
                let error = "";

                if(!/^\d+$/.test(text)) {
                    valid = false;
                    error = qsTr("This field can only contains numbers.");
                }

                return { valid, error };
            }
        }

        GenreSelectInput {
            Layout.fillWidth: true

            id: selectGenre
        }

        ImageSelectInput {
            Layout.fillWidth: true

            id: imageInput
        }

        Button {
            text: qsTr("Add album")
            onClicked: {
                inputName.validate();
                inputAuthor.validate();
                inputYear.validate();
                selectGenre.validate();

                if(
                        inputName.valid
                        && inputAuthor.valid
                        && inputYear.valid
                        && selectGenre.valid
                ) {
                    submit(
                        inputName.text,
                        inputAuthor.text,
                        inputYear.text,
                        selectGenre.text,
                        imageInput.imageUrl
                    );

                    inputName.clear();
                    inputAuthor.clear();
                    inputYear.clear();
                    selectGenre.clear();
                    imageInput.clear();
                }
            }
        }
    }
}
