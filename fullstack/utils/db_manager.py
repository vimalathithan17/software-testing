# utils/db_manager.py
import sqlite3

DATABASE_PATH = 'todo.db'

def query_db(query, args=(), one=False):
    """A generic function to query the database."""
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.close()
    return (rv[0] if rv else None) if one else rv

def get_task_by_text(task_text):
    """Fetches a single task from the DB by its text content."""
    task = query_db("SELECT * FROM tasks WHERE text = ?", [task_text], one=True)
    return task

def clear_all_tasks():
    """Deletes all tasks from the database."""
    # We need a separate connection for writing/deleting
    conn = sqlite3.connect(DATABASE_PATH)
    cur = conn.cursor()
    cur.execute("DELETE FROM tasks")
    conn.commit()
    conn.close()