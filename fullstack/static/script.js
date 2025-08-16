// static/script.js

document.addEventListener('DOMContentLoaded', () => {
    const taskInput = document.getElementById('taskInput');
    const addTaskBtn = document.getElementById('addTaskBtn');
    const taskList = document.getElementById('taskList');

    // --- Load existing tasks from the backend when the page loads ---
    async function loadTasks() {
        const response = await fetch('/api/tasks');
        const tasks = await response.json();
        taskList.innerHTML = ''; // Clear the list before rendering
        tasks.forEach(task => {
            renderTask(task);
        });
    }

    // --- Render a single task to the page ---
    function renderTask(task) {
        const li = document.createElement('li');
        li.textContent = task.text;
        li.dataset.id = task.id; // Store the database ID on the element

        if (task.completed) {
            li.classList.add('completed');
        }

        const deleteBtn = document.createElement('button');
        deleteBtn.textContent = 'Delete';
        deleteBtn.className = 'delete-btn';

        li.appendChild(deleteBtn);
        taskList.appendChild(li);
    }

    // --- Add a new task ---
    async function addTask() {
        const taskText = taskInput.value.trim();
        if (taskText === '') {
            alert('Please enter a task.');
            return;
        }

        const response = await fetch('/api/tasks', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: taskText }),
        });

        if (response.ok) {
            const newTask = await response.json();
            renderTask(newTask);
            taskInput.value = '';
        } else {
            alert('Failed to add task.');
        }
    }

    // --- Handle clicks for completing or deleting tasks ---
    async function handleTaskClick(e) {
        const li = e.target.closest('li');
        if (!li) return;

        const taskId = li.dataset.id;

        // Mark task as completed/incomplete
        if (e.target.tagName === 'LI') {
            const isCompleted = !li.classList.contains('completed');
            const response = await fetch(`/api/tasks/${taskId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ completed: isCompleted }),
            });
            if (response.ok) {
                li.classList.toggle('completed');
            }
        }
        // Delete a task
        else if (e.target.className === 'delete-btn') {
            if (confirm("Are you sure you want to delete this task?")) {
                const response = await fetch(`/api/tasks/${taskId}`, {
                    method: 'DELETE',
                });
                if (response.ok) {
                    taskList.removeChild(li);
                }
            }
        }
    }

    addTaskBtn.addEventListener('click', addTask);
    taskList.addEventListener('click', handleTaskClick);

    // Initial load of tasks
    loadTasks();
});