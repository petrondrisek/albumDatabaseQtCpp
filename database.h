#ifndef DATABASE_H
#define DATABASE_H

#include <QCoreApplication>
#include <QObject>
#include <QSqlDatabase>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QVariantList>

class Database : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList albums READ getAlbums NOTIFY albumsChanged)
    Q_PROPERTY(QVariantList songs READ getSongs NOTIFY songsChanged)
public:
    Database(QObject* parent = nullptr);
    ~Database() override;
    // Getters
    QVariantList getAlbums() const { return albums; }
    QVariantList getSongs() const { return songs; }
    // Create
    Q_INVOKABLE int insertAlbum(const QString &name, const QString &author, const QString &year, const QString &genre);
    Q_INVOKABLE int insertSong(const int &albumId, const QString &name, const QString &length);
    // Fetch from DB
    Q_INVOKABLE void fetchSongs(const int &albumId);
    Q_INVOKABLE void fetchAlbums(const QString &author, const QString &year, const QString &genre);
    // Delete
    Q_INVOKABLE bool deleteAlbum(const int &albumId);
    Q_INVOKABLE bool deleteSong(const int &songId);
    // Update
    Q_INVOKABLE bool updateAlbum(const int &albumId, const QString &name, const QString &author, const QString &year, const QString &genre);

signals:
    void albumsChanged();
    void songsChanged();
private:
    QVariantList albums;
    QVariantList songs;

    QString m_connectionName;
    QSqlDatabase db;

    void initDatabase();

    // Helping methods
    bool albumExists(const int &albumId, const QString &debugPrefix = "albumExists");
    bool executeQuery(QSqlQuery &query, const QString &sqlCommand, const QString &error, const QString &debugPrefix = "executeQuery");
    bool isDatabaseOn(const QString &debugPrefix = "isDatabaseOn");
    QVariantList selectMany(QSqlQuery &preparedQuery, const QString &error, const QString &debugPrefix = "selectMany");
    QVariantMap selectOne(QSqlQuery &preparedQuery, const QString &error, const QString &debugPrefix = "selectOne");

};

#endif // DATABASE_H
