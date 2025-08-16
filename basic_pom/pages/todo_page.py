# pages/todo_page.py
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

class TodoPage:
    # This class will contain all the locators and actions for the To-Do page.
    
    # 1. Locators: We define all element locators here, in one place.
    TASK_INPUT = (By.ID, 'taskInput')
    ADD_TASK_BUTTON = (By.ID, 'addTaskBtn')
    TASK_LIST = (By.ID, 'taskList')

    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(self.driver, 10)

    # 2. Actions: We create methods for each user action on the page.
    def load(self, file_path):
        """Navigates to the application's local HTML file."""
        self.driver.get('file://' + file_path)
    
    def add_task(self, task_name):
        """Finds the input field, types the task name, and clicks the add button."""
        self.driver.find_element(*self.TASK_INPUT).send_keys(task_name)
        self.driver.find_element(*self.ADD_TASK_BUTTON).click()
    
    def get_task_element(self, task_name):
        """Waits for and returns the web element for a specific task."""
        # This is a dynamic locator that finds a list item containing specific text.
        task_locator = (By.XPATH, f"//li[contains(text(), '{task_name}')]")
        return self.wait.until(EC.presence_of_element_located(task_locator))

    def mark_task_complete(self, task_name):
        """Finds a task and clicks it to mark as complete."""
        task = self.get_task_element(task_name)
        task.click()
        return task # Return the element for further assertions

    def delete_task(self, task_name, confirm_delete=True):
        """
        Finds a task, clicks its delete button, and handles the confirmation alert.
        """
        task = self.get_task_element(task_name)
        delete_button = task.find_element(By.TAG_NAME, 'button')
        delete_button.click()
        
        alert = self.wait.until(EC.alert_is_present())
        if confirm_delete:
            alert.accept()
        else:
            alert.dismiss()
        return task # Return the original element reference for staleness checks