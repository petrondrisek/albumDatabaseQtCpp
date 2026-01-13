#ifndef LANGUAGEMANAGER_H
#define LANGUAGEMANAGER_H

#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QTranslator>
#include "enums.h"

class LanguageManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY languageChanged)

public:
    LanguageManager(QGuiApplication *app, QQmlApplicationEngine *engine, QObject *parent = nullptr);

    int currentLanguage() const { return m_currentLanguage; }
    void setCurrentLanguage(const int &lang);

signals:
    void languageChanged();

private:
    void loadTranslation(const Enums::Language &lang);

    QGuiApplication *m_app;
    QQmlApplicationEngine *m_engine;
    QTranslator *m_translator;

    int m_currentLanguage;
};

#endif // LANGUAGEMANAGER_H
