#include "database.h"

const QString DB_FILE_NAME = "database.db";

Database::Database(QObject *parent)
    : QObject(parent)
    , m_lastError(DbError::None)
{
    init_database();
    fetch_albums("", "", "");
}

Database::~Database()
{
    if(db.isOpen())
        db.close();

    QSqlDatabase::removeDatabase(m_connectionName);
}

void Database::init_database()
{
    m_connectionName = QString("db_connection_%1").arg(reinterpret_cast<quintptr>(this)); // unique db connection name
    db = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
    db.setDatabaseName(DB_FILE_NAME);

    if (!db.open()) {
        qDebug() << "Database file was not found" << db.lastError().text();
        m_lastError = DbError::ConnectionError;
        return;
    }

    qDebug() << "Database initialized";

    QSqlQuery query(db);
    if(
        !query.exec("CREATE TABLE IF NOT EXISTS album ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT,"
               "name TEXT NOT NULL,"
               "author TEXT NOT NULL,"
               "year INTEGER NOT NULL,"
               "genre TEXT NOT NULL"
                    ");")
    ) {
        qWarning() << "Unable to create 'album' table" << query.lastError().text();
        m_lastError = DbError::QueryError;
        return;
    }

    if(
        !query.exec("CREATE TABLE IF NOT EXISTS songs ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT,"
               "album INTEGER,"
               "name TEXT NOT NULL,"
               "length TEXT NOT NULL,"
               "FOREIGN KEY(album) REFERENCES album(id)"
               ");")
    ){
        qWarning() << "Unable to create 'songs' table" << query.lastError().text();
        m_lastError = DbError::QueryError;
        return;
    }
}

void Database::fetch_album_songs(const int &album_id)
{
    if (!db.isOpen())
    {
        qDebug() << "Database is not open to fetch album songs";
        m_lastError = DbError::ConnectionError;
        return;
    }

    QVariantList rows;
    QSqlQuery query(db);

    query.prepare("SELECT * FROM songs WHERE album = :album_id");
    query.bindValue(":album_id", album_id);

    if(!query.exec()){
        qWarning() << "Unable to select rows from 'songs'" << query.lastError().text();
        m_lastError = DbError::QueryError;
        return;
    }

    QSqlRecord record = query.record();

    while (query.next()) {
        QVariantMap row;
        for (int i = 0; i < record.count(); ++i) {
            QString columnName = record.fieldName(i);
            row[columnName] = query.value(i);
        }
        rows.append(row);
    }

    // Set to private songs variable and emit change signal.
    songs = rows;
    emit songsChanged();

    qDebug() << songs.size() << "songs will be displayed.";
    m_lastError = DbError::None;
}

void Database::fetch_albums(const QString &author, const QString &year, const QString &genre)
{
    if (!db.isOpen())
    {
        qDebug() << "Database is not open to fetch albums.";
        m_lastError = DbError::ConnectionError;
        return;
    }


    QVariantList results;
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

    if (!query.exec()) {
        qWarning() << "Unable to find rows in 'album' table" << query.lastError().text();
        m_lastError = DbError::QueryError;
        return;
    }

    while (query.next()) {
        QVariantMap album;
        album["id"] = query.value("id");
        album["name"] = query.value("name");
        album["author"] = query.value("author");
        album["year"] = query.value("year");
        album["genre"] = query.value("genre");
        results.append(album);
    }

    // Set to private albums variable and emit change signal.
    albums = results;
    emit albumsChanged();

    qDebug() << albums.size() << " albums will be displayed.";
    m_lastError = DbError::None;
}

bool Database::album_exists(const int &album_id)
{
    if (!db.isOpen()) {
        return false;
    }

    QSqlQuery query(db);
    query.prepare("SELECT COUNT(*) FROM album WHERE id = :id");
    query.bindValue(":id", album_id);

    if (query.exec() && query.next()) {
        return query.value(0).toInt() > 0;
    }

    return false;
}

int Database::insert_album(const QString &name, const QString &author, const QString &year, const QString &genre)
{
    if (!db.isOpen())
    {
        qDebug() << "Database is not open to insert albums.";
        m_lastError = DbError::ConnectionError;
        return -1;
    }

    if (name.trimmed().isEmpty() || author.trimmed().isEmpty() || genre.trimmed().isEmpty()) {
        qWarning() << "Name, author and genre cannot be empty.";
        m_lastError = DbError::ValidationError;
        return -1;
    }

    QVariantMap row;
    QSqlQuery query(db);

    query.prepare("INSERT INTO album (name, author, genre, year) VALUES(:name, :author, :genre, :year)");
    query.bindValue(":name", name);
    query.bindValue(":author", author);
    query.bindValue(":genre", genre);
    query.bindValue(":year", year);

    if (!query.exec()) {
        qDebug() << "Unable to insert album" << query.lastError().text();
        m_lastError = DbError::QueryError;
        return -1;
    }

    qint64 lastId = query.lastInsertId().toLongLong();

    QSqlQuery selectQuery(db);
    selectQuery.prepare("SELECT id, name, author, genre, year FROM album WHERE id = :id");
    selectQuery.bindValue(":id", lastId);

    if (selectQuery.exec() && selectQuery.next()) {
        row["id"] = selectQuery.value("id");
        row["name"] = selectQuery.value("name");
        row["author"] = selectQuery.value("author");
        row["genre"] = selectQuery.value("genre");
        row["year"] = selectQuery.value("year");
    } else {
        qDebug() << "Unable to load last inserted album" << selectQuery.lastError().text();
        m_lastError = DbError::QueryError;
        return -1;
    }

    albums.append(row);
    emit albumsChanged();

    m_lastError = DbError::None;
    return row["id"].toInt();
}

int Database::insert_song(const int &album_id, const QString &name, const QString &length)
{
    if (!db.isOpen())
    {
        qDebug() << "Database is not open to insert songs.";
        m_lastError = DbError::ConnectionError;
        return -1;
    }

    if(!album_exists(album_id))
    {
        qWarning() << "Album id does not exist.";
        m_lastError = DbError::ValidationError;
        return -1;
    }

    if(name.trimmed().isEmpty() || length.trimmed().isEmpty())
    {
        qWarning() << "Name and lenth cannot be empty.";
        m_lastError = DbError::ValidationError;
        return -1;
    }

    QVariantMap row;
    QSqlQuery query(db);

    query.prepare("INSERT INTO songs (name, album, length) VALUES(:name, :album, :length)");
    query.bindValue(":name", name);
    query.bindValue(":album", album_id);
    query.bindValue(":length", length);

    if (!query.exec()) {
        qWarning() << "Unable to add song for album ID: " << QString("%1").arg(album_id) << ":" << query.lastError().text();
        m_lastError = DbError::QueryError;
        return -1;
    }

    qint64 lastId = query.lastInsertId().toLongLong();

    QSqlQuery selectQuery(db);
    selectQuery.prepare("SELECT * FROM songs WHERE id = :id");
    selectQuery.bindValue(":id", lastId);

    if (selectQuery.exec() && selectQuery.next()) {
        row["id"] = selectQuery.value("id");
        row["name"] = selectQuery.value("name");
        row["album"] = selectQuery.value("album");
        row["length"] = selectQuery.value("length");
    } else {
        qWarning() << "Unable to load last inserted song." << selectQuery.lastError().text();
        m_lastError = DbError::QueryError;
        return -1;
    }

    songs.append(row);
    emit songsChanged();

    m_lastError = DbError::None;
    return lastId;
}

bool Database::delete_album(const int &album_id)
{
    if (!db.isOpen())
    {
        qDebug() << "Database is not open to insert songs.";
        m_lastError = DbError::ConnectionError;
        return -1;
    }

    if(!album_exists(album_id))
    {
        qWarning() << "Album does not exists";
        m_lastError = DbError::ValidationError;
        return false;
    }

    // Create transaction
    if (!db.transaction())
    {
        qWarning() << "Unable to create transaction" << db.lastError().text();
        m_lastError = DbError::QueryError;
        return false;
    }

    QSqlQuery query(db);

    query.prepare("DELETE FROM songs WHERE album = :album_id");
    query.bindValue(":album_id", album_id);
    if (!query.exec())
    {
        qWarning() << "Unable to delete songs for album ID:" << album_id << query.lastError().text();
        db.rollback();
        m_lastError = DbError::QueryError;
        return false;
    }

    query.prepare("DELETE FROM album WHERE id = :album_id");
    query.bindValue(":album_id", album_id);
    if (!query.exec())
    {
        qWarning() << "Unable to delete album ID:" << album_id << query.lastError().text();
        db.rollback();
        m_lastError = DbError::QueryError;
        return false;
    }

    // Transaction commit
    if (!db.commit()) {
        qWarning() << "Unable to commit transaction." << db.lastError().text();
        db.rollback();
        m_lastError = DbError::QueryError;
        return false;
    }

    // Find and remove from private albums, then emit change signal.
    for(int i = 0; i < albums.size(); ++i) {
        QVariantMap album = albums[i].toMap();
        if(album["id"].toInt() == album_id){
            albums.removeAt(i);
            emit albumsChanged();
            break;
        }
    }

    m_lastError = DbError::None;
    return true;
}

bool Database::delete_song(const int &song_id)
{
    if (!db.isOpen())
    {
        qDebug() << "Database is not open to insert songs.";
        m_lastError = DbError::ConnectionError;
        return -1;
    }

    QSqlQuery query(db);

    query.prepare("DELETE FROM songs WHERE id = :song_id");
    query.bindValue(":song_id", song_id);
    if (!query.exec()) {
        qWarning() << "Unable to delete song ID:" << song_id << query.lastError().text();
        m_lastError = DbError::QueryError;
        return false;
    }

    // Find and remove from private songs, then emit change signal.
    for(int i = 0; i < songs.size(); ++i) {
        QVariantMap song = songs[i].toMap();
        if(song["id"].toInt() == song_id){
            songs.removeAt(i);
            emit songsChanged();
            break;
        }
    }

    m_lastError = DbError::None;
    return true;
}

bool Database::update_album(
    const int &album_id,
    const QString &name,
    const QString &author,
    const QString &year,
    const QString &genre
) {
    if (!db.isOpen())
    {
        qDebug() << "Database is not open to update album.";
        m_lastError = DbError::ConnectionError;
        return false;
    }

    if(!album_exists(album_id))
    {
        qWarning() << "Album id does not exist.";
        m_lastError = DbError::ValidationError;
        return false;
    }

    if(
        name.trimmed().isEmpty()
        || author.trimmed().isEmpty()
        || year.trimmed().isEmpty()
        || genre.trimmed().isEmpty()
    ) {
        qWarning() << "Name, author, year or genre cannot be empty.";
        m_lastError = DbError::ValidationError;
        return false;
    }

    QSqlQuery query(db);

    query.prepare("UPDATE album SET name=:name, author=:author, year=:year, genre=:genre WHERE id=:album_id");
    query.bindValue(":name", name);
    query.bindValue(":author", author);
    query.bindValue(":year", year);
    query.bindValue(":genre", genre);
    query.bindValue(":album_id", album_id);

    if (!query.exec()) {
        qWarning() << "Unable to update album ID: " << QString("%1").arg(album_id) << ":" << query.lastError().text();
        m_lastError = DbError::QueryError;
        return false;
    }

    // Find and update index from private albums, then emit change signal.
    for(int i = 0; i < albums.size(); ++i) {
        QVariantMap album = albums[i].toMap();
        if(album["id"].toInt() == album_id){
            album["name"] = name;
            album["author"] = author;
            album["year"] = year;
            album["genre"] = genre;
            albums[i] = album;
            break;
        }
    }
    emit albumsChanged();

    m_lastError = DbError::None;
    return true;
}

Database::DbError Database::lastError() const
{
    return m_lastError;
}

QString Database::lastErrorString() const
{
    switch (m_lastError) {
        case DbError::None:
            return "Success";
        case DbError::ConnectionError:
            return "Unable to connect to the database.";
        case DbError::QueryError:
            return "SQL command error.";
        case DbError::ValidationError:
            return "Validation error.";
        default:
            return "Unknown error.";
    }
}


