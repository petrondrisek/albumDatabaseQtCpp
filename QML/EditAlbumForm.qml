import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    property string imageBefore: ""

    property var selectedModel
    onSelectedModelChanged: {
        if(selectedModel && selectedModel.id) {
            imageInput.imageUrl = imageFile.getImage(selectedModel.id)
        } else {
            imageInput.imageUrl = ""
        }

        root.imageBefore = imageInput.imageUrl //save to check on submit if imageUrl has changed.
    }

    signal submit(var name, var author, var year, var genre, var image, var imageChanged)

    ColumnLayout {
        anchors.fill: parent

        id: layout

        spacing: 20

        // Header
        Label {
            Layout.bottomMargin: 12

            text: qsTr("Edit album")
            font.pixelSize: 18
            font.bold: true
        }

        // Inputs
        ValidationTextField {
            Layout.fillWidth: true

            id: inputName
            label: qsTr("Album name")
            defaultValue: selectedModel && selectedModel.name ? selectedModel.name : ""
        }

        ValidationTextField {
            Layout.fillWidth: true

            id: inputAuthor
            label: qsTr("Author")
            defaultValue: selectedModel && selectedModel.author ? selectedModel.author : ""
        }

        ValidationTextField {
            Layout.fillWidth: true

            id: inputYear
            label: qsTr("Year")
            defaultValue: selectedModel && selectedModel.year ? selectedModel.year : ""
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
            defaultIndex: selectedModel && selectedModel.genre ? selectGenre.model.indexOf(selectedModel.genre) : 0
        }

        ImageSelectInput {
            Layout.fillWidth: true

            id: imageInput
        }

        Button {
            text: qsTr("Edit album")
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
                        imageInput.imageUrl,
                        imageInput.imageUrl !== root.imageBefore
                    );
                }
            }
        }
    }
}
