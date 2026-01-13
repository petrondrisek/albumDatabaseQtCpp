#ifndef DATABASE_H
#define DATABASE_H

#include <QCoreApplication>
#include <QObject>
#include <QSqlDatabase>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

class Database : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList albums READ get_albums NOTIFY albumsChanged)
    Q_PROPERTY(QVariantList songs READ get_songs NOTIFY songsChanged)
public:
    enum class DbError {
        None,
        ConnectionError,
        QueryError,
        ValidationError
    };
    Q_ENUM(DbError)

    Database(QObject* parent = nullptr);
    ~Database() override;
    // Getters
    QVariantList get_albums() const { return albums; }
    QVariantList get_songs() const { return songs; }
    // Create
    Q_INVOKABLE int insert_album(const QString &name, const QString &author, const QString &year, const QString &genre);
    Q_INVOKABLE int insert_song(const int &album_id, const QString &name, const QString &length);
    // Fetch from DB
    Q_INVOKABLE void fetch_album_songs(const int &album_id);
    Q_INVOKABLE void fetch_albums(const QString &author, const QString &year, const QString &genre);
    // Delete
    Q_INVOKABLE bool delete_album(const int &album_id);
    Q_INVOKABLE bool delete_song(const int &song_id);
    // Update
    Q_INVOKABLE bool update_album(const int &album_id, const QString &name, const QString &author, const QString &year, const QString &genre);

    // Error handling
    DbError lastError() const;
    QString lastErrorString() const;

signals:
    void albumsChanged();
    void songsChanged();
private:
    QVariantList albums;
    QVariantList songs;

    QString m_connectionName;
    QSqlDatabase db;

    void init_database();
    bool album_exists(const int &album_id);

    DbError m_lastError;
};

#endif // DATABASE_H
