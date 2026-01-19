#include "database.h"

const QString DB_FILE_NAME = "database.db";

Database::Database(QObject *parent)
    : QObject(parent)
{
    initDatabase();
    fetchAlbums("", "", "");
}

Database::~Database()
{
    if(db.isOpen())
        db.close();

    QSqlDatabase::removeDatabase(m_connectionName);
}

void Database::initDatabase()
{
    m_connectionName = QString("db_connection_%1").arg(reinterpret_cast<quintptr>(this)); // unique db connection name
    db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
    db.setDatabaseName(DB_FILE_NAME);

    if (!db.open()) {
        qDebug() << "Database file was not found" << db.lastError().text();
        return;
    }

    // Create album table
    QSqlQuery query(db);
    if(!executeQuery(
            query,
            "CREATE TABLE IF NOT EXISTS album ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "name TEXT NOT NULL,"
            "author TEXT NOT NULL,"
            "year INTEGER NOT NULL,"
            "genre TEXT NOT NULL"
            ");",
            "Unable to create 'album' table",
            "initDatabase - album"
    )) {
        return;
    }

    // Create songs table
    if(!executeQuery(
            query,
            "CREATE TABLE IF NOT EXISTS songs ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "album INTEGER,"
            "name TEXT NOT NULL,"
            "length TEXT NOT NULL,"
            "FOREIGN KEY(album) REFERENCES album(id)"
            ");",
            "Unable to create 'songs' table",
            "initDatabase - songs"
    )){
        return;
    }

    qDebug() << "Database initialized";
}

void Database::fetchSongs(const int &albumId)
{
    if(!isDatabaseOn("fetchSongs")) return;

    QSqlQuery query(db);
    query.prepare("SELECT * FROM songs WHERE album = :albumId");
    query.bindValue(":albumId", albumId);

    songs = selectMany(query, "Unable to select rows from 'songs'", "fetchSongs");
    emit songsChanged();
}

void Database::fetchAlbums(const QString &author, const QString &year, const QString &genre)
{
    if(!isDatabaseOn("fetchAlbums")) return;

    QSqlQuery query(db);
    QString sql = "SELECT * FROM album WHERE 1=1";
    if (!author.isEmpty())
        sql += " AND author LIKE :author";
    if (!year.isEmpty())
        sql += " AND year = :year";
    if (!genre.isEmpty())
        sql += " AND genre = :genre";

    query.prepare(sql);

    if (!author.isEmpty())
        query.bindValue(":author", author + "%");
    if (!year.isEmpty())
        query.bindValue(":year", year);
    if (!genre.isEmpty())
        query.bindValue(":genre", genre);

    albums = selectMany(query, "Unable to select from 'albums'", "fetchAlbums");
    emit albumsChanged();
}

int Database::insertAlbum(const QString &name, const QString &author, const QString &year, const QString &genre)
{
    if(!isDatabaseOn("insertAlbum")) return -1;

    if (name.trimmed().isEmpty() || author.trimmed().isEmpty() || genre.trimmed().isEmpty()) {
        qWarning() << "Name, author and genre cannot be empty.";
        return -1;
    }

    QSqlQuery query(db);
    query.prepare("INSERT INTO album (name, author, genre, year) VALUES(:name, :author, :genre, :year)");
    query.bindValue(":name", name);
    query.bindValue(":author", author);
    query.bindValue(":genre", genre);
    query.bindValue(":year", year);

    if (!query.exec()) {
        qWarning() << "Unable to insert album" << query.lastError().text();
        return -1;
    }

    qint64 lastId = query.lastInsertId().toLongLong();
    QSqlQuery selectQuery(db);
    selectQuery.prepare("SELECT id, name, author, genre, year FROM album WHERE id = :id");
    selectQuery.bindValue(":id", lastId);

    QVariantMap row = selectOne(selectQuery, "Unable to select album last inserted id", "insertAlbum");
    if(!row.isEmpty()){
        albums.append(row);
        emit albumsChanged();

        return row["id"].toInt();
    }

    return -1;
}

int Database::insertSong(const int &albumId, const QString &name, const QString &length)
{
    if(!isDatabaseOn("insertAlbum")) return -1;

    if(!albumExists(albumId)) return -1;

    if(name.trimmed().isEmpty() || length.trimmed().isEmpty())
    {
        qWarning() << "Name and lenth cannot be empty.";
        return -1;
    }

    QSqlQuery query(db);
    query.prepare("INSERT INTO songs (name, album, length) VALUES(:name, :album, :length)");
    query.bindValue(":name", name);
    query.bindValue(":album", albumId);
    query.bindValue(":length", length);

    if (!query.exec()) {
        qWarning() << "Unable to add song for album ID: " << QString("%1").arg(albumId) << ":" << query.lastError().text();
        return -1;
    }

    qint64 lastId = query.lastInsertId().toLongLong();
    QSqlQuery selectQuery(db);
    selectQuery.prepare("SELECT * FROM songs WHERE id = :id");
    selectQuery.bindValue(":id", lastId);

    QVariantMap row = selectOne(selectQuery, "Unable to load last inserted song id", "insertSong");
    if(!row.isEmpty()){
        songs.append(row);
        emit songsChanged();

        return lastId;
    }

    return -1;
}

bool Database::deleteAlbum(const int &albumId)
{
    if(!isDatabaseOn("deleteAlbum")) return false;

    if(!albumExists(albumId)) return false;

    // Create transaction
    if (!db.transaction())
    {
        qWarning() << "Unable to create transaction" << db.lastError().text();
        return false;
    }

    QSqlQuery query(db);

    query.prepare("DELETE FROM songs WHERE album = :albumId");
    query.bindValue(":albumId", albumId);
    if (!query.exec())
    {
        qWarning() << "Unable to delete songs for album ID:" << albumId << query.lastError().text();
        db.rollback();
        return false;
    }

    query.prepare("DELETE FROM album WHERE id = :albumId");
    query.bindValue(":albumId", albumId);
    if (!query.exec())
    {
        qWarning() << "Unable to delete album ID:" << albumId << query.lastError().text();
        db.rollback();
        return false;
    }

    // Transaction commit
    if (!db.commit()) {
        qWarning() << "Unable to commit transaction." << db.lastError().text();
        db.rollback();
        return false;
    }

    // Find and remove from private albums, then emit change signal.
    for(int i = 0; i < albums.size(); ++i) {
        QVariantMap album = albums[i].toMap();
        if(album["id"].toInt() == albumId){
            albums.removeAt(i);
            emit albumsChanged();
            break;
        }
    }

    return true;
}

bool Database::deleteSong(const int &songId)
{
    if(!isDatabaseOn("deleteAlbum")) return false;

    QSqlQuery query(db);
    query.prepare("DELETE FROM songs WHERE id = :songId");
    query.bindValue(":songId", songId);
    if (!query.exec()) {
        qWarning() << "Unable to delete song ID:" << songId << query.lastError().text();
        return false;
    }

    // Find and remove from private songs, then emit change signal.
    for(int i = 0; i < songs.size(); ++i) {
        QVariantMap song = songs[i].toMap();
        if(song["id"].toInt() == songId){
            songs.removeAt(i);
            emit songsChanged();
            break;
        }
    }

    return true;
}

bool Database::updateAlbum(
    const int &albumId,
    const QString &name,
    const QString &author,
    const QString &year,
    const QString &genre
) {
    if(!isDatabaseOn("updateAlbum")) return false;

    if(!albumExists(albumId)) return false;

    if(
        name.trimmed().isEmpty()
        || author.trimmed().isEmpty()
        || year.trimmed().isEmpty()
        || genre.trimmed().isEmpty()
    ) {
        qWarning() << "Name, author, year or genre cannot be empty.";
        return false;
    }

    QSqlQuery query(db);
    query.prepare("UPDATE album SET name=:name, author=:author, year=:year, genre=:genre WHERE id=:albumId");
    query.bindValue(":name", name);
    query.bindValue(":author", author);
    query.bindValue(":year", year);
    query.bindValue(":genre", genre);
    query.bindValue(":albumId", albumId);

    if (!query.exec()) {
        qWarning() << "Unable to update album ID: " << QString("%1").arg(albumId) << ":" << query.lastError().text();
        return false;
    }

    // Find and update index from private albums, then emit change signal.
    for(int i = 0; i < albums.size(); ++i) {
        QVariantMap album = albums[i].toMap();
        if(album["id"].toInt() == albumId){
            album["name"] = name;
            album["author"] = author;
            album["year"] = year;
            album["genre"] = genre;
            albums[i] = album;
            break;
        }
    }
    emit albumsChanged();

    return true;
}

// Helping methods
bool Database::executeQuery(QSqlQuery &query, const QString &sqlCommand, const QString &error, const QString &debugPrefix)
{
    query.prepare(sqlCommand);
    if (!query.exec()) {
        qWarning() << "[" << debugPrefix << "]" << error << query.lastError().text();
        return false;
    }
    return true;
}

bool Database::isDatabaseOn(const QString &debugPrefix)
{
    if (!db.isOpen())
    {
        qWarning() << "[" << debugPrefix << "]" << "Database is not open";
        return false;
    }

    return true;
}

bool Database::albumExists(const int &albumId, const QString &debugPrefix)
{
    if(!isDatabaseOn("albumExists")) return false;

    QSqlQuery query(db);
    query.prepare("SELECT COUNT(*) FROM album WHERE id = :id");
    query.bindValue(":id", albumId);

    if (query.exec() && query.next()) {
        return query.value(0).toInt() > 0;
    }

    qWarning() << "[" << debugPrefix << "] Album ID: " << albumId << " does not exist";
    return false;
}

QVariantList Database::selectMany(QSqlQuery &preparedQuery, const QString &error, const QString &debugPrefix)
{
    QVariantList rows;

    if (!preparedQuery.exec()) {
        qWarning() << "[" << debugPrefix << "]" << error << preparedQuery.lastError().text();
        return rows;
    }

    // Map
    QSqlRecord record = preparedQuery.record();

    while (preparedQuery.next()) {
        QVariantMap row;
        for (int i = 0; i < record.count(); ++i) {
            QString columnName = record.fieldName(i);
            row[columnName] = preparedQuery.value(i);
        }
        rows.append(row);
    }

    return rows;
}

QVariantMap Database::selectOne(QSqlQuery &preparedQuery, const QString &error, const QString &debugPrefix)
{
    QVariantMap row;

    if (!preparedQuery.exec()) {
        qWarning() << "[" << debugPrefix << "]" << error << preparedQuery.lastError().text();
        return row;
    }

    if (preparedQuery.next()) {
        QSqlRecord record = preparedQuery.record();
        for (int i = 0; i < record.count(); ++i) {
            QString columnName = record.fieldName(i);
            row[columnName] = preparedQuery.value(i);
        }
    }

    return row;
}
