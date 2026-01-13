import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    property var selectedModel
    signal submit(var name, var author, var year, var genre, var image)

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 20

        // Header
        Label {
            text: qsTr("Edit album")
            font.pixelSize: 18
            font.bold: true
            anchors.bottomMargin: 12
        }

        // Inputs
        ValidationTextField {
            id: inputName
            Layout.fillWidth: true
            label: qsTr("Album name")
            defaultValue: selectedModel && selectedModel.name ? selectedModel.name : ""
        }

        ValidationTextField {
            id: inputAuthor
            Layout.fillWidth: true
            label: qsTr("Author")
            defaultValue: selectedModel && selectedModel.author ? selectedModel.author : ""
        }

        ValidationTextField {
            id: inputYear
            Layout.fillWidth: true
            label: qsTr("Year")
            validationFn: function(text) {
                let valid = true;
                let error = "";

                if(!/^\d+$/.test(text)) {
                    valid = false;
                    error = "This field can only contains numbers.";
                }

                return { valid, error };
            }
            defaultValue: selectedModel && selectedModel.year ? selectedModel.year : ""
        }

        GenreSelectInput {
            id: selectGenre
            Layout.fillWidth: true
            defaultIndex: selectedModel && selectedModel.genre ? selectGenre.model.indexOf(selectedModel.genre) : 0
        }

        ImageSelectInput {
            id: imageInput
            Layout.fillWidth: true
            imageUrl: selectedModel && selectedModel.id ? imageFile.get_image(selectedModel.id) : ""
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
                        imageInput.imageUrl
                    );
                }
            }
        }
    }
}
