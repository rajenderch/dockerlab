from flask import Flask, render_template, request, redirect, url_for
import mysql.connector
import os

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(
        host=os.getenv('DB_HOST', 'db'),
        user=os.getenv('DB_USER', 'root'),
        password=os.getenv('DB_PASSWORD', 'rootpassword'),
        database=os.getenv('DB_NAME', 'studentdb')
    )

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute('SELECT * FROM students')
        students = cursor.fetchall()
        cursor.close()
        conn.close()
        return render_template('index.html', students=students)
    except Exception as e:
        return f"Database error: {str(e)}", 500

@app.route('/add', methods=['POST'])
def add_student():
    try:
        name = request.form['name']
        email = request.form['email']
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('INSERT INTO students (name, email) VALUES (%s, %s)', (name, email))
        conn.commit()
        cursor.close()
        conn.close()
        return redirect(url_for('index'))
    except Exception as e:
        return f"Error adding student: {str(e)}", 500

@app.route('/delete/<int:id>')
def delete_student(id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('DELETE FROM students WHERE id = %s', (id,))
        conn.commit()
        cursor.close()
        conn.close()
        return redirect(url_for('index'))
    except Exception as e:
        return f"Error deleting student: {str(e)}", 500

@app.route('/health')
def health():
    try:
        conn = get_db_connection()
        conn.close()
        return {"status": "ok", "database": "connected"}, 200
    except Exception as e:
        return {"status": "error", "database": str(e)}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
