import QtQuick 2.15
import QtQuick.Controls 2.15
import Enums 1.0

MenuBar {
    // File
    Menu {
        title: qsTr("File")

        Action {
            text: qsTr("Quit")
            onTriggered: Qt.quit()
        }
    }

    // Lang
    Menu {
        title: qsTr("Language")

        ActionGroup {
            id: languageGroup
            exclusive: true
        }

        Action {
            text: qsTr("Čeština")

            checked: languageManager.currentLanguage === Language.CZECH
            checkable: true
            ActionGroup.group: languageGroup

            onTriggered: languageManager.currentLanguage = Language.CZECH
        }

        Action {
            text: qsTr("English")

            checked: languageManager.currentLanguage === Language.ENGLISH
            checkable: true
            ActionGroup.group: languageGroup

            onTriggered: languageManager.currentLanguage = Language.ENGLISH
        }
    }

    // Theme
    Menu {
        title: qsTr("Theme")

        ActionGroup {
            id: themeGroup
            exclusive: true
        }

        Action {
            text: qsTr("Light")

            checkable: true
            checked: themeManager.currentTheme === Theme.LIGHT
            ActionGroup.group: themeGroup

            onTriggered: themeManager.currentTheme = Theme.LIGHT
        }

        Action {
            text: qsTr("Dark")

            checkable: true
            checked: themeManager.currentTheme === Theme.DARK
            ActionGroup.group: themeGroup

            onTriggered: themeManager.currentTheme = Theme.DARK
        }
    }
}
