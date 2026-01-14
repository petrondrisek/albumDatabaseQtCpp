import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root

    spacing: 12

    // Debounce
    property int searchDebounceMs: 800

    Timer {
        id: searchDebounceTimer
        interval: root.searchDebounceMs
        repeat: false
        onTriggered: root.search()
    }

    // Form
    TextField {
        Layout.fillWidth: true

        id: authorInput
        placeholderText: qsTr("Search author")

        // Debounce while writing
        onTextChanged: {
            searchDebounceTimer.restart()
        }

        // Immediately searches when pressing enter
        onAccepted: {
            searchDebounceTimer.stop()
            root.search()
        }
    }

    ValidationTextField {
        Layout.fillWidth: true

        id: yearInput

        label: qsTr("Search year")
        validationFn: function(text) {
            let valid = true;
            let error = "";

            if(!/^\d+$/.test(text) && text.length) {
                valid = false;
                error = qsTr("Year has to be numeric.")
            }

            return { valid, error }
        }

        // Debounce while writing
        onTextChanged: () => {
            searchDebounceTimer.restart()
        }

        // Immediately searches when pressing enter
        onAccepted: () => {
            searchDebounceTimer.stop()
            root.search()
        }
    }

    GenreSelectInput {
        Layout.fillWidth: true

        id: genreSelect

        validationFn: function(text) {
            return { valid: true, error: "" }
        }

        onTextChanged: () => {
            root.search()
        }
    }

    Button {
        text: qsTr("Search")
        onClicked: {
            yearInput.validate()
            genreSelect.validate()

            root.search();
        }
    }

    function search() {
        if(yearInput.valid && genreSelect.valid) {
            db.fetch_albums(authorInput.text, yearInput.text, genreSelect.text);
        }
    }
}
