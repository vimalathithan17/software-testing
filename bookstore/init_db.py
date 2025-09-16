import sqlite3
import os

BASE_DIR = os.path.dirname(__file__)
DB_PATH = os.path.join(BASE_DIR, "bookstore.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute(
        """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL
        )
        """
    )
    c.execute(
        """
        CREATE TABLE IF NOT EXISTS books (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            author TEXT,
            price REAL
        )
        """
    )
    c.execute("SELECT COUNT(*) FROM books")
    if c.fetchone()[0] == 0:
        c.executemany(
            "INSERT INTO books(id, title, author, price) VALUES (?, ?, ?, ?)",
            [
                (1, "The Pragmatic Programmer", "Andrew Hunt", 30),
                (2, "Clean Code", "Robert C. Martin", 28),
                (3, "Introduction to Algorithms", "CLRS", 80),
            ],
        )
    conn.commit()
    conn.close()

if __name__ == '__main__':
    init_db()
    print('bookstore.db initialized at', DB_PATH)
