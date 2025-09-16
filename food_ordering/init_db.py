import sqlite3
import os

BASE_DIR = os.path.dirname(__file__)
DB_PATH = os.path.join(BASE_DIR, "food.db")

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
        CREATE TABLE IF NOT EXISTS menu (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL
        )
        """
    )
    c.execute("SELECT COUNT(*) FROM menu")
    if c.fetchone()[0] == 0:
        c.executemany(
            "INSERT INTO menu(id, name, price) VALUES (?, ?, ?)",
            [
                (1, "Margherita Pizza", 8),
                (2, "Veg Burger", 6),
                (3, "Caesar Salad", 5),
            ],
        )
    conn.commit()
    conn.close()

if __name__ == '__main__':
    init_db()
    print('food.db initialized at', DB_PATH)
