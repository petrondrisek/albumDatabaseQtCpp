#ifndef IMAGEFILE_H
#define IMAGEFILE_H

#include <QObject>
#include <QString>

class ImageFile: public QObject
{
    Q_OBJECT
public:
    ImageFile(QObject *parent = nullptr);
    Q_INVOKABLE void upload_image(const QString &path, const int &album_id);
    Q_INVOKABLE QString get_image(const int &album_id);
    Q_INVOKABLE bool delete_image(const int &album_id);

signals:
    void imageReady(int album_id);
};

#endif // IMAGEFILE_H
