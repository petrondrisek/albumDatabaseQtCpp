#include "imagefile.h"

#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QUrl>

ImageFile::ImageFile(QObject *parent) {}

void ImageFile::upload_image(const QString &path, const int &album_id)
{
    if (path.isEmpty() || album_id <= 0) {
        return;
    }

    QUrl url(path);
    QString sourcePath = url.toLocalFile();

    if (sourcePath.isEmpty()) {
        return;
    }

    QString imagesDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/images";
    QDir().mkpath(imagesDir);

    QString targetPath = imagesDir + QString("/album_%1.bmp").arg(album_id);

    QFile::remove(targetPath); // overwrite if exists
    QFile::copy(sourcePath, targetPath);

    emit imageReady(album_id);
}


QString ImageFile::get_image(const int &album_id)
{
    if (album_id <= 0) {
        return QString();
    }

    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QString("/images/album_%1.bmp").arg(album_id);

    if (QFile::exists(path)) {
        return QUrl::fromLocalFile(path).toString();
    }

    return QString();
}


bool ImageFile::delete_image(const int &album_id)
{
    if (album_id <= 0) {
        return false;
    }

    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + QString("/images/album_%1.bmp").arg(album_id);

    bool remove = QFile::remove(path);
    emit imageReady(album_id);
    return remove;
}

