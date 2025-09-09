# app.py

import mysql.connector
from flask import Flask, jsonify, request, g

app = Flask(__name__, static_folder='static', static_url_path='')

# --- NEW: MySQL Configuration ---
# IMPORTANT: Update these with your own MySQL credentials
DB_CONFIG = {
    'user': 'root',
    'password': 'your_mysql_root_password', # <-- CHANGE THIS
    'host': '127.0.0.1',
    'database': 'todo_db' # We will create this database
}

# --- Database Helper Functions (Updated for MySQL) ---
def get_db():
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = mysql.connector.connect(**DB_CONFIG)
    return db

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

# --- API Routes (Updated with MySQL syntax) ---
@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    db = get_db()
    # Using dictionary=True makes the results behave like Python dicts
    cursor = db.cursor(dictionary=True)
    cursor.execute('SELECT * FROM tasks ORDER BY id')
    tasks = cursor.fetchall()
    cursor.close()
    return jsonify(tasks)

@app.route('/api/tasks', methods=['POST'])
def add_task():
    new_task = request.json
    db = get_db()
    cursor = db.cursor(dictionary=True)
    # MySQL uses '%s' as a placeholder, not '?'
    sql = "INSERT INTO tasks (text, completed) VALUES (%s, %s)"
    val = (new_task['text'], False)
    cursor.execute(sql, val)
    db.commit()
    
    # Get the ID of the task we just created
    created_task_id = cursor.lastrowid
    
    # Fetch the newly created task to return it
    cursor.execute("SELECT * FROM tasks WHERE id = %s", (created_task_id,))
    created_task = cursor.fetchone()
    cursor.close()
    
    return jsonify(created_task), 201

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    update_data = request.json
    db = get_db()
    cursor = db.cursor()
    sql = "UPDATE tasks SET completed = %s WHERE id = %s"
    val = (update_data['completed'], task_id)
    cursor.execute(sql, val)
    db.commit()
    cursor.close()
    return jsonify({'message': 'Task updated successfully'})

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    db = get_db()
    cursor = db.cursor()
    sql = "DELETE FROM tasks WHERE id = %s"
    val = (task_id,)
    cursor.execute(sql, val)
    db.commit()
    cursor.close()
    return jsonify({'message': 'Task deleted successfully'})

# --- Serve Frontend ---
@app.route('/')
def index():
    return app.send_static_file('index.html')

# --- Main execution ---
if __name__ == '__main__':
    app.run(debug=True)