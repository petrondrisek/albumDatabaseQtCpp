#ifndef ENUMS_H
#define ENUMS_H
#include <QObject>

class Enums : public QObject
{
    Q_OBJECT
public:
    explicit Enums(QObject* parent = nullptr);

    enum Language {
        CZECH,
        ENGLISH
    };
    Q_ENUM(Language);

    enum Themes {
        LIGHT,
        DARK
    };
    Q_ENUM(Themes);
};

#endif // ENUMS_H
