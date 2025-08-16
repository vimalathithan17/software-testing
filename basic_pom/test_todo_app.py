# test_todo_app.py (Refactored with POM)

import os
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import pytest
from pages.todo_page import TodoPage # Import our new Page Object

@pytest.fixture
def driver():
    driver = webdriver.Firefox()
    driver.maximize_window()
    yield driver
    driver.quit()

def test_add_task_positive(driver):
    """Tests adding a valid task using POM."""
    todo_page = TodoPage(driver)
    file_path = os.path.abspath('index.html')
    todo_page.load(file_path)
    
    todo_page.add_task("Buy milk")
    
    task_element = todo_page.get_task_element("Buy milk")
    assert task_element.is_displayed()

def test_add_task_negative_empty(driver):
    """Tests that an empty task cannot be added using POM."""
    todo_page = TodoPage(driver)
    file_path = os.path.abspath('index.html')
    todo_page.load(file_path)

    # Directly click add button without typing
    driver.find_element(*todo_page.ADD_TASK_BUTTON).click()

    wait = WebDriverWait(driver, 10)
    alert = wait.until(EC.alert_is_present())
    assert alert.text == "Please enter a task."
    alert.accept()

def test_mark_task_complete(driver):
    """Tests marking a task as complete using POM."""
    todo_page = TodoPage(driver)
    file_path = os.path.abspath('index.html')
    todo_page.load(file_path)
    
    todo_page.add_task("Read a book")
    task_element = todo_page.mark_task_complete("Read a book")
    
    assert "completed" in task_element.get_attribute("class")

def test_delete_task_confirm(driver):
    """Tests deleting a task with confirmation using POM."""
    todo_page = TodoPage(driver)
    file_path = os.path.abspath('index.html')
    todo_page.load(file_path)
    
    todo_page.add_task("Task to delete")
    task_element = todo_page.delete_task("Task to delete", confirm_delete=True)
    
    wait = WebDriverWait(driver, 10)
    assert wait.until(EC.staleness_of(task_element))