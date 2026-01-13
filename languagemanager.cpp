#include "languagemanager.h"

LanguageManager::LanguageManager(QGuiApplication *app, QQmlApplicationEngine *engine, QObject *parent)
    : QObject(parent)
    , m_app(app)
    , m_engine(engine)
    , m_translator(new QTranslator(this))
{
    QSettings settings("CDDatabaseOndrisekQML", "App");
    m_currentLanguage = settings.value("language", 0).toInt();

    loadTranslation(static_cast<Enums::Language>(m_currentLanguage));
}

void LanguageManager::setCurrentLanguage(const int &lang)
{
    if (m_currentLanguage == lang)
    {
        return;
    }

    m_currentLanguage = lang;

    QSettings settings("CDDatabaseOndrisekQML", "App");
    settings.setValue("language", lang);

    loadTranslation(static_cast<Enums::Language>(lang));
    emit languageChanged();
}

void LanguageManager::loadTranslation(const Enums::Language &lang)
{
    m_app->removeTranslator(m_translator);
    delete m_translator;

    m_translator = new QTranslator(this);

    QString qmFile;
    switch (lang) {
    case Enums::Language::CZECH:
        qmFile = ":/i18n/app_cs.qm";
        break;
    case Enums::Language::ENGLISH:
        qmFile = ":/i18n/app_en.qm";
        break;
    }

    if (m_translator->load(qmFile)) {
        m_app->installTranslator(m_translator);
        qDebug() << "Loaded lang:" << qmFile;
        m_engine->retranslate();
    } else {
        qWarning() << "Unable to load lang:" << qmFile;
    }
}
