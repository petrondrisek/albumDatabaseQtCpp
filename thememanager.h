#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QSettings>

class ThemeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentTheme READ currentTheme WRITE setCurrentTheme NOTIFY themeChanged)
public:
    ThemeManager(QObject *parent = nullptr);

    int currentTheme() const { return m_currentTheme; }
    void setCurrentTheme(const int &theme);
signals:
    void themeChanged();
private:
    int m_currentTheme;
};

#endif // THEMEMANAGER_H
