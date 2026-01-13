#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <QSettings>
#include "enums.h"
#include "database.h"
#include "imagefile.h"
#include "languagemanager.h"
#include "thememanager.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    // Enums register to QML
    qmlRegisterUncreatableType<Enums>("Enums", 1, 0, "Language", "Enum only");
    qmlRegisterUncreatableType<Enums>("Enums", 1, 0, "Theme", "Enum only");

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    Database *db = new Database();
    ImageFile *imageFile = new ImageFile();

    // Language
    LanguageManager *langManager = new LanguageManager(&app, &engine, &app);

    // Theme
    ThemeManager *themeManager = new ThemeManager(&app);

    engine.rootContext()->setContextProperty("db", db);
    engine.rootContext()->setContextProperty("imageFile", imageFile);
    engine.rootContext()->setContextProperty("languageManager", langManager);
    engine.rootContext()->setContextProperty("themeManager", themeManager);

    engine.loadFromModule("CDDatabaseOndrisekQML", "Main");

    return app.exec();
}
