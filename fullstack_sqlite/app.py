#!/usr/bin/env python3
import sqlite3
from flask import Flask, jsonify, request, g

app = Flask(__name__, static_folder='static', static_url_path='')
DATABASE = 'fullstack_sqlite.db'

def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

def init_db():
    with app.app_context():
        db = get_db()
        with app.open_resource('schema.sql', mode='r') as f:
            db.cursor().executescript(f.read())
        db.commit()

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    db = get_db()
    cursor = db.execute('SELECT * FROM tasks ORDER BY id')
    tasks = [dict(row) for row in cursor.fetchall()]
    return jsonify(tasks)

@app.route('/api/tasks', methods=['POST'])
def add_task():
    new_task = request.json or {}
    text = new_task.get('text', 'unnamed task')
    db = get_db()
    db.execute('INSERT INTO tasks (text, completed) VALUES (?, ?)', [text, False])
    db.commit()
    cursor = db.execute('SELECT * FROM tasks WHERE id = last_insert_rowid()')
    created = cursor.fetchone()
    return jsonify(dict(created)), 201

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    update_data = request.json or {}
    db = get_db()
    db.execute('UPDATE tasks SET completed = ? WHERE id = ?', [update_data.get('completed', False), task_id])
    db.commit()
    return jsonify({'message': 'Task updated successfully'})

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    db = get_db()
    db.execute('DELETE FROM tasks WHERE id = ?', [task_id])
    db.commit()
    return jsonify({'message': 'Task deleted successfully'})

@app.route('/')
def index():
    return app.send_static_file('index.html')

if __name__ == '__main__':
    try:
        init_db()
        print('Database initialized.')
    except sqlite3.OperationalError:
        print('Database already exists.')
    app.run(host='0.0.0.0', port=5004)
