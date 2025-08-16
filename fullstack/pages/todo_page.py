# pages/todo_page.py

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

class TodoPage:
    # --- Locators ---
    TASK_INPUT = (By.ID, 'taskInput')
    ADD_TASK_BUTTON = (By.ID, 'addTaskBtn')
    TASK_LIST = (By.ID, 'taskList')
    TASK_LIST_ITEMS = (By.XPATH, "//ul[@id='taskList']/li")

    def __init__(self, driver):
        self.driver = driver
        self.wait = WebDriverWait(self.driver, 10)
    
    # ... (other methods like load, add_task, etc. remain the same) ...
    def load(self):
        self.driver.get('http://127.0.0.1:5000/')
    
    def add_task(self, task_name):
        self.driver.find_element(*self.TASK_INPUT).send_keys(task_name)
        self.driver.find_element(*self.ADD_TASK_BUTTON).click()
        return self.get_task_element(task_name)

    def mark_task_complete(self, task_name):
        task_element = self.get_task_element(task_name)
        task_element.click()
        return task_element

    def delete_task(self, task_name, confirm_delete=True):
        task_element = self.get_task_element(task_name)
        delete_button = task_element.find_element(By.TAG_NAME, 'button')
        delete_button.click()
        alert = self.wait.until(EC.alert_is_present())
        if confirm_delete:
            alert.accept()
        else:
            alert.dismiss()
        return task_element

    def get_task_element(self, task_name):
        task_locator = (By.XPATH, f"//li[contains(text(), '{task_name}')]")
        return self.wait.until(EC.presence_of_element_located(task_locator))

    # --- New Helper Method ---
    def get_task_count(self):
        """Returns the number of task items visible on the page."""
        return len(self.driver.find_elements(*self.TASK_LIST_ITEMS))