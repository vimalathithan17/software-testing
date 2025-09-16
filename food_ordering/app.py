import os
import sqlite3
from flask import Flask, render_template, request, redirect, url_for, session, flash, g
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = "dev-secret-food"

BASE_DIR = os.path.dirname(__file__)
DB_PATH = os.path.join(BASE_DIR, "food.db")


def get_db():
    db = getattr(g, "_database", None)
    if db is None:
        db = g._database = sqlite3.connect(DB_PATH)
        db.row_factory = sqlite3.Row
    return db


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


@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, "_database", None)
    if db is not None:
        db.close()


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        if not username or not password:
            flash("Missing fields", "error")
            return redirect(url_for("register"))
        db = get_db()
        try:
            db.execute(
                "INSERT INTO users(username, password_hash) VALUES (?, ?)",
                (username, generate_password_hash(password)),
            )
            db.commit()
        except sqlite3.IntegrityError:
            flash("User exists", "error")
            return redirect(url_for("register"))
        flash("Registered", "info")
        return redirect(url_for("login"))
    return render_template("register.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")
        db = get_db()
        row = db.execute("SELECT password_hash FROM users WHERE username = ?", (username,)).fetchone()
        if row and check_password_hash(row["password_hash"], password):
            session["user"] = username
            return redirect(url_for("menu"))
        flash("Invalid", "error")
        return redirect(url_for("login"))
    return render_template("login.html")


@app.route("/menu")
def menu():
    db = get_db()
    rows = db.execute("SELECT id, name, price FROM menu").fetchall()
    menu = [dict(r) for r in rows]
    return render_template("menu.html", menu=menu, user=session.get("user"))


@app.route("/order", methods=["POST"])
def order():
    if not session.get("user"):
        return redirect(url_for("login"))
    item_id = int(request.form.get("item_id"))
    coupon = request.form.get("coupon")
    db = get_db()
    item = db.execute("SELECT id, name, price FROM menu WHERE id = ?", (item_id,)).fetchone()
    if not item:
        flash("Invalid item", "error")
        return redirect(url_for("menu"))
    price = item["price"]
    if coupon == "FOOD10":
        price = round(price * 0.9, 2)
    return render_template("payment.html", item=item, price=price)


@app.route("/pay", methods=["POST"])
def pay():
    return render_template("success.html")


if __name__ == "__main__":
    init_db()
    # Default: don't run with the reloader during automated tests. Enable debug with FLASK_DEBUG=1
    debug_mode = os.environ.get("FLASK_DEBUG", "0") == "1"
    app.run(debug=debug_mode, host="0.0.0.0", port=5002)
