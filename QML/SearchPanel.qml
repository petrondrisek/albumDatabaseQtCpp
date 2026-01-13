import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 12

    property int searchDebounceMs: 800

    Timer {
        id: searchDebounceTimer
        interval: root.searchDebounceMs
        repeat: false
        onTriggered: root.search()
    }

    TextField {
        id: authorInput
        placeholderText: qsTr("Search author")
        Layout.fillWidth: true

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
        onTextChanged: () => {
            searchDebounceTimer.restart()
        }
        onAccepted: () => {
            searchDebounceTimer.stop()
            root.search()
        }

        Layout.fillWidth: true
    }

    GenreSelectInput {
        id: genreSelect
        Layout.fillWidth: true
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
