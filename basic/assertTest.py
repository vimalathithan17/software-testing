

import time
import os # We need this to get the file path
from selenium import webdriver
from selenium.webdriver.common.by import By

# --- Test Setup ---
# Initialize the Chrome driver // Chrome(),Firefox(),Edge()
driver = webdriver.Firefox()

# Get the absolute path of the index.html file
# This makes sure the script can find your file no matter where you run it from
file_path = os.path.abspath('index.html')

# Open the local HTML file in the browser
driver.get('file://' + file_path)
driver.maximize_window() # Makes the browser fullscreen

# --- Test Execution ---
# 1. Find the task input field by its ID
task_input = driver.find_element(By.ID, 'taskInput')

# 2. Type "Buy milk" into the input field
task_input.send_keys('Buy milk')
time.sleep(1) # Small pause to see the typing

# 3. Find the "Add Task" button by its ID
add_task_button = driver.find_element(By.ID, 'addTaskBtn')

# 4. Click the button
add_task_button.click()
time.sleep(2) # Pause to see the result

# --- Verification (Assertion) ---
# Find the task list by its ID
task_list = driver.find_element(By.ID, 'taskList')

# Find all the list items (li) within the task list
tasks = task_list.find_elements(By.TAG_NAME, 'li')

# Check if the text of the first task contains "Buy milk"
task_text = tasks[0].text
print(f"Found task: {task_text}") # For debugging

# The actual test: assert that the expected text is in the found text
# The task text also includes the "Delete" button text, so we check if our input is a substring.
assert "Buy milk" in task_text
print("TEST PASSED!")

time.sleep(2)

# --- Test Teardown ---
# Close the browser window
driver.quit()