import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: field
    implicitHeight: genreSelect.implicitHeight
    implicitWidth: layout.implicitWidth

    property bool valid: true
    property string error: ""
    property var validationFn // function(text) -> { valid, error }

    property alias text: genreSelect.currentText
    property int defaultIndex: 0
    property var model: [
        "",
        "Pop",
        "Rock",
        "Hip Hop",
        "Electronic / EDM",
        "R&B",
        "Jazz",
        "Classical",
        "Metal",
        "Reggae",
        "Country"
    ]

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 4

        ComboBox {
            id: genreSelect
            Layout.fillWidth: true

            model: field.model
            currentIndex: field.defaultIndex

            onCurrentTextChanged: {
                field.validate()
                field.textChanged()
            }
        }

        Label {
            text: field.error
            color: Material.color(Material.Red)
            visible: !field.valid
            font.pixelSize: 12
        }
    }

    function validate() {
        if (!validationFn) {
            valid = genreSelect.currentText.length
            error = valid ? "" : qsTr("The content cannot be null.")
            return valid
        }

        const result = validationFn(genreSelect.currentText)
        valid = result.valid
        error = result.error ?? ""
        return valid
    }

    function clear() {
        genreSelect.currentIndex = 0
    }
}
