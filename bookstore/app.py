import os
import sqlite3
from flask import Flask, render_template, request, redirect, url_for, session, flash, g
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = "dev-secret-bookstore"

BASE_DIR = os.path.dirname(__file__)
DB_PATH = os.path.join(BASE_DIR, "bookstore.db")


def get_db():
	db = getattr(g, "_database", None)
	if db is None:
		db = g._database = sqlite3.connect(DB_PATH)
		db.row_factory = sqlite3.Row
	return db


def init_db():
	conn = sqlite3.connect(DB_PATH)
	c = conn.cursor()
	# Users table
	c.execute(
		"""
		CREATE TABLE IF NOT EXISTS users (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			username TEXT UNIQUE NOT NULL,
			password_hash TEXT NOT NULL
		)
		"""
	)
	# Books table
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
	# Seed books if empty
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
			flash("Please provide username and password", "error")
			return redirect(url_for("register"))
		db = get_db()
		try:
			db.execute(
				"INSERT INTO users(username, password_hash) VALUES (?, ?)",
				(username, generate_password_hash(password)),
			)
			db.commit()
		except sqlite3.IntegrityError:
			flash("User already exists", "error")
			return redirect(url_for("register"))
		flash("Registration successful. Please login.", "info")
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
			flash("Logged in", "info")
			return redirect(url_for("catalogue"))
		flash("Invalid credentials", "error")
		return redirect(url_for("login"))
	return render_template("login.html")


@app.route("/catalogue")
def catalogue():
	db = get_db()
	books = db.execute("SELECT id, title, author, price FROM books").fetchall()
	# convert to dict-like objects for templates
	books = [dict(b) for b in books]
	return render_template("catalogue.html", books=books, user=session.get("user"))


@app.route("/logout")
def logout():
	session.pop("user", None)
	flash("Logged out", "info")
	return redirect(url_for("home"))


if __name__ == "__main__":
	init_db()
	# By default don't use the Flask reloader (debug mode) when running tests.
	# Set FLASK_DEBUG=1 in the environment to enable debug mode during development.
	debug_mode = os.environ.get("FLASK_DEBUG", "0") == "1"
	app.run(debug=debug_mode, host="0.0.0.0", port=5001)
