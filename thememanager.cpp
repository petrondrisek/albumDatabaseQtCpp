#include "thememanager.h"
#include "enums.h"

ThemeManager::ThemeManager(QObject *parent)
    : QObject(parent)
{
    QSettings settings("CDDatabaseOndrisekQML", "App");
    m_currentTheme = settings.value("theme", 0).toInt();
}

void ThemeManager::setCurrentTheme(const int &theme)
{
    if(m_currentTheme == theme)
    {
        return;
    }

    QSettings settings("CDDatabaseOndrisekQML", "App");
    settings.setValue("theme", theme);

    m_currentTheme = theme;
    emit themeChanged();
}
