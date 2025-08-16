document.addEventListener('DOMContentLoaded', () => {
    const taskInput = document.getElementById('taskInput');
    const addTaskBtn = document.getElementById('addTaskBtn');
    const taskList = document.getElementById('taskList');

    // Add a new task when the button is clicked
    addTaskBtn.addEventListener('click', addTask);

    // Handle clicks on the task list (for completing or deleting)
    taskList.addEventListener('click', handleTaskClick);

    function addTask() {
        const taskText = taskInput.value.trim();
        if (taskText === '') {
            alert('Please enter a task.');
            return;
        }

        const li = document.createElement('li');
        li.textContent = taskText;

        const deleteBtn = document.createElement('button');
        deleteBtn.textContent = 'Delete';
        deleteBtn.className = 'delete-btn';

        li.appendChild(deleteBtn);
        taskList.appendChild(li);

        taskInput.value = '';
    }

    function handleTaskClick(e) {
        // Mark task as completed
        if (e.target.tagName === 'LI') {
            e.target.classList.toggle('completed');
        } 
        // Delete a task
        else if (e.target.className === 'delete-btn') {
            // --- THIS IS THE NEW PART ---
            // Show a confirmation dialog before deleting
            if (confirm("Are you sure you want to delete this task?")) {
                const li = e.target.parentElement;
                taskList.removeChild(li);
            }
            // If user clicks 'Cancel', do nothing.
            // --------------------------
        }
    }
});