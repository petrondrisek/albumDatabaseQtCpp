import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: field

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    property string label: "Input"
    property alias text: input.text
    property bool valid: true
    property string error: ""
    property var validationFn   // function(value) -> {valid, error}
    property int minimumLength: 3
    property int maximumLength: 50
    property string defaultValue: ""

    signal accepted()

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 4

        TextField {
            Layout.fillWidth: true

            id: input

            placeholderText: field.label
            text: field.defaultValue
            maximumLength: field.maximumLength

            onEditingFinished: field.validate()
            onTextChanged: {
                if(field.valid) {
                    field.textChanged()
                }
            }
            onAccepted: {
                if(field.valid) {
                    field.accepted()
                }
            }
        }

        // Error label, display only when property error is not empty
        Label {
            text: field.error
            color: Material.color(Material.Red)
            font.pixelSize: 12

            visible: !field.valid
        }
    }

    function validate() {
        if (!validationFn) {
            valid = input.text.length >= field.minimumLength && input.text.length < field.maximumLength
            error = valid ? "" : qsTr("The content has to be %1–%2 characters long.")
                                    .arg(field.minimumLength)
                                    .arg(field.maximumLength)
            return valid
        }

        const result = validationFn(input.text)
        valid = result.valid
        error = result.error ?? ""
        return valid
    }

    function clear() {
        input.clear()
    }
}
