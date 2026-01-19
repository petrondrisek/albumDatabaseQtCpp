#include "imagefile.h"

#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QUrl>

ImageFile::ImageFile(QObject *parent)
    : QObject(parent)
{
    // Gets and creates directory, if not exists in appdata
    m_imagesDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/images";
    QDir().mkpath(m_imagesDir);
}

QString ImageFile::getImagePath(const int &albumId)
{
    return m_imagesDir + QString("/album_%1.bmp").arg(albumId);
}

void ImageFile::uploadImage(const QString &path, const int &albumId)
{
    if (path.isEmpty() || albumId <= 0) {
        return;
    }

    QUrl url(path);
    QString sourcePath = url.toLocalFile();
    if (sourcePath.isEmpty()) {
        return;
    }

    QString targetPath = getImagePath(albumId);
    QFile::remove(targetPath); // overwrite if exists

    bool success = QFile::copy(sourcePath, targetPath);
    if(success){
        emit imageReady(albumId);
    }

    qDebug() << "Image uploaded:" << success << ", path:" << targetPath;
}


QString ImageFile::getImage(const int &albumId)
{
    if (albumId <= 0) {
        return QString();
    }

    QString path = getImagePath(albumId);

    if (QFile::exists(path)) {
        return QUrl::fromLocalFile(path).toString();
    }

    return QString();
}

bool ImageFile::deleteImage(const int &albumId)
{
    if (albumId <= 0) {
        return false;
    }

    QString path = getImagePath(albumId);

    bool success = QFile::remove(path);
    if (success) {
        emit imageReady(albumId);
    }

    qDebug() << "Image deleted:" << success << ", path:" << path;
    return success;
}

