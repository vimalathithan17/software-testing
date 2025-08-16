# test_e2e_todo_app.py

import pytest
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from pages.todo_page import TodoPage
from utils import db_manager

@pytest.fixture(scope="function")
def driver():
    # Pre-condition: Clear the database before each test
    db_manager.clear_all_tasks()
    
    driver = webdriver.Firefox()
    driver.maximize_window()
    yield driver
    
    # Teardown: Close the browser
    driver.quit()

# Test Case: E2E_ADD_01
def test_add_task_end_to_end(driver):
    """Tests adding a valid task and verifies it on the UI and in the database."""
    todo_page = TodoPage(driver)
    task_name = "Pay electricity bill"
    
    todo_page.load()
    todo_page.add_task(task_name)
    
    # UI Verification
    assert todo_page.get_task_element(task_name).is_displayed()
    
    # DB Verification
    db_task = db_manager.get_task_by_text(task_name)
    assert db_task is not None
    assert db_task['text'] == task_name
    assert db_task['completed'] == 0

# Test Case: E2E_ADD_02
def test_add_empty_task_is_rejected(driver):
    """Tests that an empty task is not added to the UI or DB."""
    todo_page = TodoPage(driver)
    todo_page.load()

    # Action: Click add without typing
    driver.find_element(*todo_page.ADD_TASK_BUTTON).click()

    # UI Verification
    wait = WebDriverWait(driver, 5)
    alert = wait.until(EC.alert_is_present())
    assert "Please enter a task." in alert.text
    alert.accept()
    assert todo_page.get_task_count() == 0

    # DB Verification
    tasks_in_db = db_manager.query_db("SELECT * FROM tasks")
    assert len(tasks_in_db) == 0

# Test Case: E2E_MARK_01
def test_mark_task_complete_end_to_end(driver):
    """Tests marking a task as complete and verifies on UI and in DB."""
    todo_page = TodoPage(driver)
    task_name = "Go for a run"
    
    todo_page.load()
    todo_page.add_task(task_name)
    
    # Action
    task_element = todo_page.mark_task_complete(task_name)
    
    # UI Verification
    assert "completed" in task_element.get_attribute("class")
    
    # DB Verification
    db_task = db_manager.get_task_by_text(task_name)
    assert db_task['completed'] == 1

# Test Case: E2E_DEL_01
def test_delete_task_end_to_end(driver):
    """Tests deleting a task and verifies it's gone from UI and DB."""
    todo_page = TodoPage(driver)
    task_name = "Clean the car"
    
    todo_page.load()
    todo_page.add_task(task_name)
    
    # Action
    task_element = todo_page.delete_task(task_name, confirm_delete=True)
    
    # UI Verification
    wait = WebDriverWait(driver, 5)
    assert wait.until(EC.staleness_of(task_element))
    assert todo_page.get_task_count() == 0
    
    # DB Verification
    db_task = db_manager.get_task_by_text(task_name)
    assert db_task is None

# Test Case: E2E_LOAD_01
def test_tasks_persist_on_page_refresh(driver):
    """Tests that tasks are loaded correctly from the DB on page refresh."""
    todo_page = TodoPage(driver)
    todo_page.load()

    # Arrange: Add two tasks
    todo_page.add_task("Task A")
    todo_page.add_task("Task B")
    assert todo_page.get_task_count() == 2

    # Action: Refresh the page
    driver.refresh()

    # UI Verification: Wait for an element to ensure the page has reloaded
    wait = WebDriverWait(driver, 10)
    wait.until(EC.presence_of_element_located(todo_page.TASK_INPUT))
    
    # Assert both tasks are present and the count is correct
    assert todo_page.get_task_element("Task A").is_displayed()
    assert todo_page.get_task_element("Task B").is_displayed()
    assert todo_page.get_task_count() == 2