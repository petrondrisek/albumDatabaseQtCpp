#ifndef IMAGEFILE_H
#define IMAGEFILE_H

#include <QObject>
#include <QString>

class ImageFile: public QObject
{
    Q_OBJECT
public:
    ImageFile(QObject *parent = nullptr);
    Q_INVOKABLE void uploadImage(const QString &path, const int &albumId);
    Q_INVOKABLE QString getImage(const int &albumId);
    Q_INVOKABLE bool deleteImage(const int &albumId);

private:
    QString m_imagesDir;
    QString getImagePath(const int &albumId);

signals:
    void imageReady(int albumId);
};

#endif // IMAGEFILE_H
