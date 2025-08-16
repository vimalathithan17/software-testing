# Selenium Python Tutorial: From Zero to E2E Hero

Welcome! This repository is a complete, hands-on tutorial designed to teach you automated testing with Selenium and Python. We'll start with the absolute basics of testing, progressively build your skills through hands-on examples, and finish by testing a fullstack application.

## Table of Contents

- [**Part 1: The World of Software Testing**](#part-1-the-world-of-software-testing)
  - [What is Software Testing?](#what-is-software-testing)
  - [Types of Software Testing](#types-of-software-testing)
  - [Manual vs. Automated Testing](#manual-vs-automated-testing)
  - [A General Approach to Identify Requirements & Test Cases](#a-general-approach-to-identify-requirements--test-cases)
  - [Positive vs. Negative Testing](#positive-vs-negative-testing)
- [**Part 2: Understanding the Applications & Requirements**](#part-2-understanding-the-applications--requirements)
  - [**App 1: The Static To-Do App (`basic/`)**](#app-1-the-static-to-do-app-basic)
    - [How It Works](#how-it-works)
    - [Test Cases (Static App)](#test-cases-static-app)
    - [Requirements Traceability Matrix (RTM)](#requirements-traceability-matrix-rtm)
  - [**App 2: The Fullstack To-Do App (`fullstack/`)**](#app-2-the-fullstack-to-do-app-fullstack)
    - [How It Works](#how-it-works-1)
    - [End-to-End Test Cases (Fullstack App)](#end-to-end-test-cases-fullstack-app)
    - [Requirements Traceability Matrix (RTM)](#requirements-traceability-matrix-rtm-1)
- [**Part 3: The Automation Toolkit: Selenium & Python**](#part-3-the-automation-toolkit-selenium--python)
  - [What is Selenium?](#what-is-selenium)
  - [Environment Setup](#environment-setup)
  - [Core Selenium Concepts: The WebDriver](#core-selenium-concepts-the-webdriver)
  - [Core Selenium Concepts: Finding Elements](#core-selenium-concepts-finding-elements)
  - [How to Use Locators in Selenium](#how-to-use-locators-in-selenium)
  - [**Ultimate Guide to XPath**](#ultimate-guide-to-xpath)
  - [**Ultimate Guide to Selenium Methods**](#ultimate-guide-to-selenium-methods)
- [**Part 4: The Hands-On Tutorial: From Script to Framework**](#part-4-the-hands-on-tutorial-from-script-to-framework)
  - [How to Run The Tests](#how-to-run-the-tests)
  - [How Pytest Works: A Quick Dive](#how-pytest-works-a-quick-dive)
  - [The AAA (Arrange, Act, Assert) Pattern Explained](#the-aaa-arrange-act-assert-pattern-explained)
  - [**Level 1: A Simple Script (`basic/`)**](#level-1-a-simple-script-basic)
  - [**Level 2: Introducing a Test Runner - `pytest`**](#level-2-introducing-a-test-runner---pytest)
  - [**Level 3: The Page Object Model (POM) (`basic_pom/`)**](#level-3-the-page-object-model-pom-basic_pom)
  - [**Level 4: Fullstack End-to-End Testing (`fullstack/`)**](#level-4-fullstack-end-to-end-testing-fullstack)
- [**Part 5: Appendix**](#part-5-appendix)
  - [**Deep Dive: Interacting with a Database (SQLite)**](#deep-dive-interacting-with-a-database-sqlite)
  - [CI/CD Integration with GitHub Actions](#cicd-integration-with-github-actions)
- [**Part 6: Long Story Short - A Selenium Test Template**](#part-6-long-story-short---a-selenium-test-template)

---

## Part 1: The World of Software Testing

### What is Software Testing?
Software testing is the process of evaluating a software application to find and fix defects. It's a crucial quality assurance step that verifies the software does what it's supposed to do (meets requirements), ensuring it's reliable, secure, and provides a good user experience.

### Types of Software Testing
Testing isn't a single activity. It's a collection of different types, each with a specific purpose.

| Type | Description | Example |
|---|---|---|
| **Unit Testing** | Testing the smallest possible piece of code in isolation (e.g., a single function or method). | Checking if a `calculate_sum(a, b)` function returns the correct value. |
| **Integration Testing** | Testing how multiple units or components work together. | Verifying that when you click the "Save" button (UI component), the data is correctly sent to the API (backend component). |
| **End-to-End (E2E) Testing** | Testing the entire application flow from start to finish, simulating a real user journey. **This is what we do with Selenium.** | Simulating a user logging in, adding an item to a shopping cart, and checking out. |
| **Performance Testing** | Evaluating how the system performs under a specific workload (e.g., speed, responsiveness, stability). | Checking how long it takes for the search results page to load when 1000 users are searching at the same time. |
| **Security Testing** | Uncovering vulnerabilities in the system to protect it from attacks. | Trying to access a user's profile page without being logged in. |

### Manual vs. Automated Testing

| Aspect | Manual Testing | Automated Testing |
|---|---|---|
| **Process** | A human tester manually interacts with the application, following test steps to find bugs. | A software script (like our Python/Selenium tests) executes pre-written commands to interact with the application and verify outcomes. |
| **Pros** | - Great for exploratory testing and checking user experience. <br>- Can find bugs a script might miss. | - **Fast & Efficient:** Runs tests much faster than a human. <br>- **Repeatable:** Executes the same steps precisely every time, perfect for regression testing. <br>- **CI/CD:** Can be integrated into build pipelines to run automatically. |
| **Cons** | - **Slow & Expensive:** Time-consuming for large applications. <br>- **Prone to Human Error:** Testers can make mistakes. | - **Initial Investment:** Requires time to set up frameworks and write test scripts. <br>- **Maintenance:** Scripts must be updated when the application changes. |

### A General Approach to Identify Requirements & Test Cases
A requirement is a specific feature the software must have. A test case is a set of steps to validate that a requirement works correctly.

1.  **Deconstruct the Application:** Look at the application and break it down into its core features. For a To-Do app, this would be:
    *   Adding Tasks
    *   Viewing Tasks
    *   Completing Tasks
    *   Deleting Tasks

2.  **Think Like a User:** For each feature, list all the things a user might want to do.
    *   *Feature: Adding Tasks*
        *   Can I add a task with text?
        *   Can I add a task with numbers and symbols?
        *   What happens if I try to add an empty task?
        *   What happens if I add a very long task?

3.  **Formalize into Requirements (REQs):** Turn these user stories into formal, testable statements.
    *   `REQ-001`: The system must allow a user to add a new task with text content.
    *   `REQ-002`: The system must prevent a user from adding a task with no content.

4.  **Create Test Cases (TCs):** For each requirement, write specific, step-by-step instructions to test it. A good test case includes:
    *   **ID:** A unique identifier (e.g., `TC_ADD_01`).
    *   **Requirement ID:** Which requirement it covers.
    *   **Type:** Positive or Negative.
    *   **Preconditions:** Any state required before the test (e.g., "User is on the main page").
    *   **Steps:** The exact actions to perform.
    *   **Expected Result:** What the outcome should be.

### Positive vs. Negative Testing
-   **Positive Testing (Happy Path):** Checks if the application works as expected with valid inputs.
    -   *Example:* Adding a task with normal text like "Buy milk".
-   **Negative Testing (Edge Cases):** Checks how the application handles invalid inputs or unexpected conditions.
    -   *Example:* Trying to add an empty task, or a task with only spaces. A robust application should handle this gracefully (e.g., show an error message) instead of crashing.

---

## Part 2: Understanding the Applications & Requirements

### App 1: The Static To-Do App (`basic/`)

This is a simple, client-side-only To-Do application. All logic is handled in the browser using HTML and JavaScript.

#### How It Works
-   **`basic/index.html`**: Defines the structure of the page, including the input field (`#taskInput`), the add button (`#addTaskBtn`), and the task list (`#taskList`).
-   **`basic/script.js`**: Contains the JavaScript logic to handle adding, completing, and deleting tasks.
-   **Persistence**: There is **no persistence**. All tasks are lost when you refresh the page.

#### Test Cases (Static App)

| Test Case ID | Req ID | Type | Steps | Expected Result |
|---|---|---|---|---|
| TC_ADD_01 | REQ-001 | Positive | 1. In the `taskInput` field, type "Buy milk". <br> 2. Click the "Add Task" button. | A new item "Buy milk" appears in the list. The input field is cleared. |
| TC_ADD_02 | REQ-001 | Positive | 1. In the `taskInput` field, type "Call Mom @ 5pm! #Urgent". <br> 2. Click the "Add Task" button. | A new item "Call Mom @ 5pm! #Urgent" appears in the list. |
| TC_ADD_03 | REQ-002 | Negative | 1. Ensure the `taskInput` field is empty. <br> 2. Click the "Add Task" button. | An alert box with "Please enter a task." appears. No task is added. |
| TC_ADD_04 | REQ-002 | Negative | 1. In `taskInput`, type several spaces. <br> 2. Click the "Add Task" button. | An alert box with "Please enter a task." appears. No task is added. |
| TC_MARK_01 | REQ-003 | Positive | 1. Add task "Read a book". <br> 2. Click on the text of the task. | The task "Read a book" gets a line-through and its color changes. |
| TC_MARK_02 | REQ-004 | Positive | 1. Mark the "Read a book" task as complete. <br> 2. Click on the text of the completed task again. | The line-through and color change are removed, returning it to an active state. |
| TC_DEL_01 | REQ-005 | Positive | 1. Add task "Water the plants". <br> 2. Click the "Delete" button next to it. | The task "Water the plants" is permanently removed from the list. |
| TC_DEL_02 | REQ-005 | Positive | 1. Add and complete the task "Take out trash". <br> 2. Click the "Delete" button next to it. | The completed task "Take out trash" is permanently removed from the list. |
| TC_DEL_03 | REQ-005 | Positive | 1. Add "Task A", "Task B", "Task C". <br> 2. Click the "Delete" button next to "Task B". | Only "Task B" is removed. "Task A" and "Task C" remain unchanged. |
| TC_DEL_04 | REQ-005 | Positive | 1. Add a task. <br> 2. Click its "Delete" button. <br> 3. In the confirmation pop-up, click "OK". | The confirmation pop-up closes and the task is permanently removed from the list. |
| TC_DEL_05 | REQ-005 | Negative | 1. Add a task. <br> 2. Click its "Delete" button. <br> 3. In the confirmation pop-up, click "Cancel". | The confirmation pop-up closes and the task remains in the list, unchanged. |

#### Requirements Traceability Matrix (RTM)

| Requirement ID | Requirement Description | Corresponding Test Case ID(s) |
|---|---|---|
| REQ-001 | A user must be able to add a new task to their to-do list. | TC_ADD_01, TC_ADD_02 |
| REQ-002 | The system must prevent a user from adding a blank or empty task. | TC_ADD_03, TC_ADD_04 |
| REQ-003 | A user must be able to mark any task on the list as "completed". | TC_MARK_01 |
| REQ-004 | A user must be able to un-mark a "completed" task, returning it to an active state. | TC_MARK_02 |
| REQ-005 | A user must be able to permanently delete a task from the list. | TC_DEL_01, TC_DEL_02, TC_DEL_03, TC_DEL_04, TC_DEL_05 |
| REQ-006 | All added tasks must be clearly visible in a list format. | Implicitly tested in all "add" and "delete" cases |

### App 2: The Fullstack To-Do App (`fullstack/`)

This is a client-server application where the frontend communicates with a Python Flask backend to persist data.

#### How It Works
-   **`fullstack/app.py`**: A Flask server that provides a REST API for task management and serves the frontend.
-   **`fullstack/static/`**: Contains the frontend code (HTML, CSS, JS). The JavaScript here uses `fetch` to make API calls to the backend.
-   **`fullstack/todo.db`**: A SQLite database file where tasks are stored.
-   **Persistence**: **Yes**. Tasks are stored in the database, so they persist across page reloads.

#### End-to-End Test Cases (Fullstack App)

| Test Case ID | Scenario/Description | Test Steps | Verification Steps |
|---|---|---|---|
| E2E_ADD_01 | Positive: Verify a new task is added and persists. | 1. Navigate to the application. <br> 2. In the input field, type "Pay electricity bill". <br> 3. Click "Add Task". | **UI:** A new list item with the text "Pay electricity bill" appears on the page. <br> **Database:** A new row is created in the `tasks` table where `text` is "Pay electricity bill" and `completed` is 0. |
| E2E_ADD_02 | Negative: Verify an empty task is not added. | 1. Navigate to the application. <br> 2. Click "Add Task" with the input field empty. | **UI:** An alert box appears. No new task is added to the list on the page. <br> **Database:** The total number of rows in the `tasks` table does not change. |
| E2E_MARK_01 | Positive: Verify a task can be marked as complete. | 1. Add a task "Go for a run". <br> 2. Click on the text of the "Go for a run" task. | **UI:** The list item "Go for a run" gets a line-through style (the 'completed' class is applied). <br> **Database:** The row for "Go for a run" in the `tasks` table is updated to set the `completed` column to 1. |
| E2E_DEL_01 | Positive: Verify a task can be deleted. | 1. Add a task "Clean the car". <br> 2. Click the "Delete" button next to it. <br> 3. Click "OK" on the confirmation alert. | **UI:** The list item "Clean the car" is removed from the page. <br> **Database:** The row for "Clean the car" is permanently deleted from the `tasks` table. |
| E2E_LOAD_01 | Positive: Verify existing tasks load on page refresh. | 1. Add two tasks: "Task A" and "Task B". <br> 2. Refresh the browser page. | **UI:** The page reloads, and both "Task A" and "Task B" are visible in the list. <br> **Database:** (N/A for this test, as it verifies the GET request functionality). |

#### Requirements Traceability Matrix (RTM)

| Requirement ID | Requirement Description | Corresponding Test Case ID(s) |
|---|---|---|
| REQ-001 | A user must be able to add a new task. | E2E_ADD_01 |
| REQ-002 | The system must prevent adding an empty task. | E2E_ADD_02 |
| REQ-003 | A user must be able to mark a task as completed. | E2E_MARK_01 |
| REQ-005 | A user must be able to delete a task. | E2E_DEL_01 |
| REQ-007 | Tasks must persist after a page refresh. | E2E_LOAD_01 |

---

## Part 3: The Automation Toolkit: Selenium & Python

### What is Selenium?
Selenium is a powerful, open-source framework for automating web browsers. It provides a programming interface that allows your scripts to control a browser, performing actions like clicking buttons, typing in fields, and reading content from the page. It's the core tool we'll use for our E2E tests.

### Environment Setup
1.  **Install Python:** Ensure you have Python 3.8+ installed.
2.  **Install Dependencies:** Open your terminal and run this command from the root of the repository:
    ```bash
    pip install selenium pytest flask
    ```
3.  **Web Browser:** Have modern browsers like Firefox, Chrome, and/or Edge installed. Selenium 4+ includes **Selenium Manager**, which automatically downloads the correct `WebDriver` for your installed browsers, so you don't need to do it manually!

### Core Selenium Concepts: The `WebDriver`
The `WebDriver` is the heart of Selenium. It's an object that represents a single browser session. You create it, give it commands, and then close it when you're done.

You can easily test on different browsers by instantiating the correct driver:

```python
from selenium import webdriver

# To use Firefox
driver = webdriver.Firefox()

# To use Google Chrome
driver = webdriver.Chrome()

# To use Microsoft Edge
driver = webdriver.Edge()

# --- Your test logic goes here ---
# Example:
driver.get("https://www.google.com")
print(driver.title) # Prints the title of the page

# --- Always close the session ---
driver.quit()
```

### Core Selenium Concepts: Finding Elements
To interact with something on a page (like a button or input field), you first have to find it. Selenium provides several strategies, or "locators", to do this.

| Locator | Description | Example |
|---|---|---|
| `By.ID` | **Best:** Finds an element by its unique `id` attribute. Fast and reliable. | `driver.find_element(By.ID, 'taskInput')` |
| `By.CSS_SELECTOR` | **Great:** Uses CSS selector syntax to find elements. Very powerful and often more readable than XPath. | `driver.find_element(By.CSS_SELECTOR, 'button.delete-btn')` |
| `By.XPATH` | **Most Powerful:** Uses XPath expressions to navigate the HTML structure. Can find anything, but can be complex and slower. | `driver.find_element(By.XPATH, "//li[contains(., 'Buy milk')]")` |
| `By.CLASS_NAME` | Finds elements by their `class` attribute. Be careful if multiple elements share the same class. | `driver.find_element(By.CLASS_NAME, 'completed')` |
| `By.TAG_NAME` | Finds elements by their HTML tag (e.g., `li`, `button`). | `driver.find_elements(By.TAG_NAME, 'li')` |

### How to Use Locators in Selenium
The syntax is always `driver.find_element(By.STRATEGY, 'value')`. The `By` class is an essential part of telling Selenium *how* to search for the element.

```python
from selenium.webdriver.common.by import By

# Find the task input field by its unique ID
task_input_by_id = driver.find_element(By.ID, 'taskInput')

# Find the same input field using a CSS selector
task_input_by_css = driver.find_element(By.CSS_SELECTOR, '#taskInput')

# Find the same input field using its XPath
task_input_by_xpath = driver.find_element(By.XPATH, "//input[@id='taskInput']")

# Find the "Add Task" button by its class name
# Note: This is risky if multiple buttons share the class.
add_button_by_class = driver.find_element(By.CLASS_NAME, 'btn')

# Find the first list item on the page by its HTML tag
first_list_item = driver.find_element(By.TAG_NAME, 'li')
```

---

### Ultimate Guide to XPath

Think of XPath as a postal address for elements in the HTML document. It's a powerful language that lets you navigate the complex tree structure of an HTML page to find any element you need.

#### Absolute vs. Relative XPath
-   **Absolute XPath:** Starts from the root (`/html`) and lists every single element down to the target. It's extremely brittle and should **never be used**. If any element in that path changes, your locator breaks.
    -   *Example (Bad):* `/html/body/div/div[2]/ul/li[3]/span`
-   **Relative XPath:** Starts with `//`, which means "search anywhere in the document". It finds a unique "landmark" near your target element and navigates from there. This is the correct way to write XPath.
    -   *Example (Good):* `//ul[@id='taskList']/li[3]/span`

#### XPath Syntax Breakdown

The basic syntax is `//tag[@attribute='value']`.

| Symbol | Meaning | Example |
|---|---|---|
| `//` | Selects nodes from the current node that match the selection no matter where they are. | `//div` (finds all `div` elements) |
| `tag` | The HTML tag of the element you want. | `//button` (finds all buttons) |
| `@` | Selects an attribute. | `//input[@id]` (finds all inputs that have an `id` attribute) |
| `[]` | A predicate, used to filter and find a specific node. | `//input[@id='taskInput']` (finds the input whose `id` is 'taskInput') |

#### Finding Elements by Attributes
This is the most common use case.
-   **Find by a single attribute:**
    -   `//input[@id='taskInput']`
    -   `//button[@class='delete-btn']`
-   **Find using logical operators (`and`, `or`):**
    -   `//input[@type='text' and @name='username']` (Finds an input that is a text field AND has the name 'username').
    -   `//button[@class='btn-primary' or @class='btn-secondary']` (Finds a button whose class is either 'btn-primary' OR 'btn-secondary').

#### Using Powerful XPath Functions

| Function | Description | Example |
|---|---|---|
| `contains()` | Checks if an attribute or text *partially* contains a value. This is great for dynamic content. | `//button[contains(@class, 'delete')]` (finds a button whose class includes 'delete'). <br> `//li[contains(., 'Buy milk')]` (`.` refers to all text within the element, making this very robust). |
| `starts-with()` | Checks if an attribute starts with a certain string. Useful for dynamic IDs. | `//div[starts-with(@id, 'user-')]` (finds divs with IDs like `user-1`, `user-2`, etc.). |
| `text()` | Finds an element by its **exact** text content. **Warning:** This is brittle. It fails if there's extra whitespace or child elements. | `//button[text()='Add Task']` |
| `normalize-space()` | Trims all leading/trailing whitespace and collapses multiple spaces into one before comparing. The best way to find by text. | `//button[normalize-space()='  Add Task  ']` (This will match the button, whereas `text()` would fail). |

#### Navigating Relationships with XPath Axes
Axes let you navigate from a known element to a nearby one. This is the key to creating stable locators when the element you want has no unique attributes.

Imagine you have this HTML structure:
```html
<div class="item">
  <h3>Task Name: Buy Milk</h3>
  <p>Status: Incomplete</p>
  <button class="delete-btn">Delete</button>
</div>
```
**Goal:** Click the "Delete" button specifically for the "Buy Milk" task.

| Axis | Description | Example |
|---|---|---|
| `parent::*` | Selects the direct parent of the current element. | `//button[@class='delete-btn']/parent::div` (Finds the `div` that is the parent of the delete button). |
| `child::*` | Selects the children of the current element. | `//div[@class='item']/child::button` (Finds the button that is a child of the item div). |
| `following-sibling::*` | Selects all siblings that come *after* the current element. | `//h3/following-sibling::button` (Finds the button that is a sibling of the `h3` tag). |
| `preceding-sibling::*` | Selects all siblings that come *before* the current element. | `//button/preceding-sibling::h3` (Finds the `h3` that comes before the button). |
| `ancestor::*` | Selects all ancestors (parent, grandparent, etc.). | `//button/ancestor::div[@class='item']` (Finds the ancestor `div` with class 'item'). |

**The Winning Locator:**
To reliably find the delete button for "Buy Milk", you would combine these techniques:
`//h3[contains(., 'Buy Milk')]/following-sibling::button[@class='delete-btn']`
*   **Translation:** "Find an `h3` element that contains the text 'Buy Milk', then find its sibling that is a `button` with the class 'delete-btn'."

---

### Ultimate Guide to Selenium Methods

Here are the most common Selenium commands you'll use, categorized and with scenario-based examples.

#### Category 1: Browser Navigation & Information
These methods control the browser window itself.

| Method | Scenario | Example |
|---|---|---|
| `driver.get(url)` | **"Go to the login page."** <br> Navigates the browser to a specific URL. | `driver.get("http://127.0.0.1:5000/login")` |
| `driver.refresh()` | **"The page content didn't load correctly, let's try again."** <br> Reloads the current page. | `driver.refresh()` |
| `driver.back()` | **"After clicking a link, I want to go back to the previous page."** | `driver.back()` |
| `driver.forward()` | **"After going back, I want to go forward again."** | `driver.forward()` |
| `driver.title` | **"Verify I am on the correct page by checking its title."** <br> Returns the `<title>` of the current page as a string. | `expected_title = "My App - Login"` <br> `assert driver.title == expected_title` |
| `driver.current_url` | **"Verify that after a successful login, the URL changed to the dashboard page."** | `expected_url = "http://127.0.0.1:5000/dashboard"` <br> `assert driver.current_url == expected_url` |

#### Category 2: Finding Elements
These are your primary tools for locating elements before you can interact with them.

| Method | Scenario | Example |
|---|---|---|
| `driver.find_element(By, value)` | **"I need to find the unique username input field."** <br> Finds the **first** element matching the locator. Throws a `NoSuchElementException` if not found. | `username_field = driver.find_element(By.ID, 'username')` |
| `driver.find_elements(By, value)` | **"I need to get all the items in a list to check how many there are."** <br> Finds **all** elements matching the locator and returns them as a list. Returns an empty list if none are found (does not throw an error). | `all_tasks = driver.find_elements(By.TAG_NAME, 'li')` <br> `assert len(all_tasks) == 5` |

#### Category 3: Element Interaction
Once you have an element, these methods let you perform actions on it.

| Method | Scenario | Example |
|---|---|---|
| `element.click()` | **"Click the 'Login' button."** | `login_button.click()` |
| `element.send_keys(text)` | **"Type my username into the username field."** | `username_field.send_keys("testuser")` |
| `element.clear()` | **"The input field has some default text. I need to clear it before typing."** | `search_field.clear()` |
| `element.submit()` | **"This form doesn't have a submit button, but I can submit it from any of its input fields."** <br> (Works on any element inside a `<form>` tag). | `password_field.submit()` |

#### Category 4: Reading Element State
These methods let you get information from an element to verify the state of the application.

| Method | Scenario | Example |
|---|---|---|
| `element.text` | **"Verify that the welcome message displays the correct username."** <br> Gets the visible text of an element. | `welcome_message = driver.find_element(By.ID, 'welcome').text` <br> `assert "Welcome, testuser!" in welcome_message` |
| `element.get_attribute(name)` | **"Check if an image has the correct source file."** or **"Check if a button becomes disabled after clicking."** <br> Gets the value of any HTML attribute (like `class`, `href`, `value`, `style`, `disabled`). | `image_src = logo.get_attribute("src")` <br> `button_state = submit_btn.get_attribute("disabled")` <br> `assert button_state == "true"` |
| `element.is_displayed()` | **"After adding a task, verify that it is now visible on the page."** | `new_task = driver.find_element(...)` <br> `assert new_task.is_displayed()` |
| `element.is_enabled()` | **"Verify that the 'Submit' button is disabled until all required fields are filled."** | `submit_button = driver.find_element(...)` <br> `assert not submit_button.is_enabled()` |
| `element.is_selected()` | **"Verify that a specific checkbox or radio button is checked by default."** | `remember_me_checkbox = driver.find_element(...)` <br> `assert remember_me_checkbox.is_selected()` |

#### Category 5: Advanced Interactions (Waits, Alerts, Windows)

| Method | Scenario | Example |
|---|---|---|
| `WebDriverWait(driver, timeout)` | **"The page takes a few seconds to load data via an API call. I need to wait for the data to appear before I check it."** <br> This is the **correct** way to handle timing issues. | `wait = WebDriverWait(driver, 10)` <br> `profile_pic = wait.until(EC.presence_of_element_located((By.ID, 'profile')))` |
| `driver.switch_to.alert` | **"When I click delete, a confirmation pop-up appears. I need to interact with it."** | `alert = driver.switch_to.alert` |
| `alert.accept()` | **"Click the 'OK' button on the confirmation alert."** | `alert.accept()` |
| `alert.dismiss()` | **"Click the 'Cancel' button on the confirmation alert."** | `alert.dismiss()` |
| `driver.window_handles` | **"I clicked a link that opened a new browser tab. I need to get a list of all open tabs."** | `all_tabs = driver.window_handles` |
| `driver.switch_to.window(handle)` | **"Switch focus to the newly opened tab to continue my test there."** | `driver.switch_to.window(all_tabs[1])` |

---

## Part 4: The Hands-On Tutorial: From Script to Framework

### How to Run The Tests
To run the automated tests, you'll use the `pytest` command in your terminal. It's crucial to run the command from the correct directory so that `pytest` can discover the tests and import the necessary modules.

-   **For `basic` and `basic_pom` tests:**
    -   To run setupTest.py,interactTest.py,assertTest.py:
    -   Navigate to basic and run the tests
        ```bash
        cd basic
        python setupTest.py
        python interactTest.py
        python assertTest.py
        ```
    -   To run pytest files, based on which test you want to run, navigate to the appropriate directory containing the test file
        ```bash
        #To basic
        cd basic

        #Or to basic_pom
        cd basic_pom
        ```
    -   Now run
        ```bash
        pytest
        ```
    -   pytest automatically finds the test file and functions
    -   Navigate to the root of the project.
    -   To run pytest against a specific file:
        ```bash
        # Run tests in the basic script
        pytest basic/test_todo_app.py

        # Run tests in the POM version
        pytest basic_pom/test_todo_app.py
        ```

-   **For `fullstack` E2E tests:**
    -   First, make sure the Flask server is running. Open a **separate terminal**, navigate to the `fullstack` directory, and run:
        ```bash
        cd fullstack/
        python app.py
        ```
        You should see output indicating the server is running (e.g., `* Running on http://127.0.0.1:5000`).
    -   In your **primary terminal**, navigate to the `fullstack` directory and run pytest. `pytest` will automatically discover the `test_e2e_todo_app.py` file.
        ```bash
        cd fullstack/
        pytest
        ```

#### Pytest Command-Line Options
You can modify `pytest`'s behavior with flags:

| Flag | Description | Example |
|---|---|---|
| `-v` | **Verbose mode.** Shows each test function name and `PASSED` or `FAILED` instead of just dots. Highly recommended. | `pytest -v` |
| `-k <expr>` | **Keyword expression.** Runs only tests whose names match the given string expression. | `pytest -k "add_task"` (runs `test_add_task_positive` and `test_add_task_end_to_end`) |
| `--html=report.html` | **Generate HTML report.** Creates a self-contained HTML file with detailed test results. (Requires `pytest-html` plugin: `pip install pytest-html`). | `pytest --html=report.html` |
| `-n <num>` | **Parallel execution.** Runs tests in parallel across multiple CPUs. (Requires `pytest-xdist` plugin: `pip install pytest-xdist`). | `pytest -n 4` (runs tests across 4 workers) |

### How Pytest Works: A Quick Dive
`pytest` is not magic; it follows a set of conventions to make testing simple yet powerful. Understanding these will help you write better tests.

#### Test Discovery
How does `pytest` know what to run? It scans the directory for files and functions that follow its naming convention:
-   **Files:** Looks for files named `test_*.py` or `*_test.py`.
-   **Functions:** Inside those files, it will execute functions prefixed with `test_`.
-   **Classes:** It can also run methods inside classes prefixed with `Test`, but we are using the simpler functional approach in this tutorial.

#### Fixtures and Dependency Injection
A **fixture** is a function that provides a fixed baseline state or a reusable object for your tests. Our `driver` function is a perfect example.
-   You mark a function as a fixture with the `@pytest.fixture` decorator.
-   **Dependency Injection:** When you include the name of a fixture (`driver`) as an argument to your test function (`def test_add_task(driver):`), `pytest` automatically runs the fixture first and "injects" its result into your test. This is a clean, powerful way to provide resources like a database connection or a WebDriver instance to your tests without boilerplate code.

#### The Power of `yield` in Fixtures (Setup & Teardown)
A fixture can be used for both setup and teardown. The `yield` keyword is the dividing line.
-   **Setup:** All code *before* the `yield` statement is the setup code. It runs before the test starts. In our case, `driver = webdriver.Firefox()` is the setup.
-   **Execution:** The `yield` statement passes control to the test function, which then runs to completion. It passes the value that was yielded (our `driver` object).
-   **Teardown:** All code *after* the `yield` statement is the teardown code. It runs after the test has finished, regardless of whether it passed or failed. `driver.quit()` is our teardown, ensuring the browser always closes.

```python
@pytest.fixture
def driver():
    # --- 1. SETUP CODE (runs before each test) ---
    driver = webdriver.Firefox()
    yield driver # --- 2. PASS THE DRIVER TO THE TEST AND WAIT FOR IT TO FINISH ---
    # --- 3. TEARDOWN CODE (runs after each test) ---
    driver.quit()
```
This structure makes tests extremely clean and ensures resources are managed correctly and automatically.

### The AAA (Arrange, Act, Assert) Pattern Explained
This is a simple and powerful way to structure your tests for maximum clarity. Every test should have these three distinct parts.

-   **Arrange:** Set up all the preconditions for your test. This includes creating the driver, loading the correct page, and preparing the application state (e.g., ensuring the database is clean or a user is logged in).
-   **Act:** Perform the single, specific user action that you want to test. This should be a concise block of code, like clicking one button or filling out one form.
-   **Assert:** Verify the outcome of the action. Check if the application responded correctly. An assertion compares an actual result to an expected result. If they don't match, the test fails.

**Example using the AAA Pattern:**
```python
def test_add_task_positive(driver):
    # 1. ARRANGE
    # Load the application page.
    # The 'driver' itself is part of the arrangement, handled by the fixture.
    todo_page = TodoPage(driver)
    todo_page.load()
    task_name = "Buy groceries"

    # 2. ACT
    # Perform the single action: adding a task.
    todo_page.add_task(task_name)

    # 3. ASSERT
    # Verify the outcome: was the task added to the list?
    task_element = todo_page.get_task_element(task_name)
    assert task_element.is_displayed()
    assert task_element.text == task_name
```

### Level 1: A Simple Script (`basic/`)
We start by writing simple, direct scripts that show the core Selenium commands. This helps understand the fundamentals before we add layers of abstraction.

#### Step 1: Just Opening a Browser (`setupTest.py`)
**Goal:** Confirm that Selenium can open a browser and navigate to our local file.
```python
# From basic/setupTest.py
import time
import os
from selenium import webdriver

# Arrange: Create a new Firefox browser instance.
driver = webdriver.Firefox()

# Arrange: Construct the absolute file path to our HTML file.
# This is important so the script can be run from anywhere.
file_path = os.path.abspath('basic/index.html')

# Act: Tell the browser to open our local file.
driver.get('file://' + file_path)

# Assert (Implicit): We use a sleep here to visually inspect the page.
# In a real test, we would assert the page title or an element's presence.
time.sleep(5)

# Teardown: Close the browser window and end the WebDriver session.
driver.quit()
```

#### Step 2: Interacting with the Page (`interactTest.py`)
**Goal:** Find elements and perform basic actions on them.
```python
# From basic/interactTest.py
# ... (setup code is the same) ...

# Act: Find the task input field by its unique ID.
task_input = driver.find_element(By.ID, 'taskInput')
# Act: Type the string 'Buy milk' into the input field.
task_input.send_keys('Buy milk')

# Act: Find the 'Add Task' button by its ID.
add_task_button = driver.find_element(By.ID, 'addTaskBtn')
# Act: Click the button.
add_task_button.click()

# Assert (Implicit): Wait and see.
time.sleep(2)
# ... (teardown code is the same) ...
```

#### Step 3: Adding Verifications (`assertTest.py`)
**Goal:** Make our script self-verifying. An automated test is useless without assertions.
```python
# From basic/assertTest.py
# ... (act code is the same) ...

# Assert: Find all elements with the 'li' tag. This returns a list.
tasks = driver.find_elements(By.TAG_NAME, 'li')
# Assert: Get the text of the first task in the list.
task_text = tasks[0].text
# Assert: Check if the text we added is present in the new list item.
# If this condition is false, the script will raise an AssertionError and stop.
assert "Buy milk" in task_text

print("TEST PASSED!")
# ... (teardown code is the same) ...
```

### Level 2: Introducing a Test Runner - `pytest`
Writing standalone scripts is not scalable. A test runner like `pytest` gives us superpowers:
-   **Test Discovery:** Automatically finds and runs any function starting with `test_`.
-   **Fixtures:** Reusable setup and teardown code. This is perfect for creating and quitting the `driver` for each test.
-   **Clear Reporting:** Gives a detailed report of which tests passed and failed.

```python
# From basic/test_todo_app.py
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import os

# This is a pytest fixture. It runs before each test that uses it.
# It handles the setup (creating driver) and teardown (quitting driver).
@pytest.fixture
def driver():
    # --- Setup ---
    driver = webdriver.Firefox()
    # 'yield' passes the driver object to the test function.
    yield driver
    # --- Teardown ---
    # This code runs after the test is finished.
    driver.quit()

# This is a test function. pytest will find and run it automatically.
# Notice it takes the 'driver' fixture as an argument.
def test_add_task_positive(driver):
    # Arrange
    file_path = os.path.abspath('basic/index.html')
    driver.get('file://' + file_path)

    # Act
    task_input = driver.find_element(By.ID, 'taskInput')
    task_input.send_keys('Buy milk')
    driver.find_element(By.ID, 'addTaskBtn').click()

    # Assert
    # Use an explicit wait to give the page time to update.
    wait = WebDriverWait(driver, 10)
    # Wait until an element matching this XPath is present.
    new_task = wait.until(EC.presence_of_element_located((By.XPATH, "//li[contains(., 'Buy milk')]")))
    assert new_task.is_displayed()
```

### Level 3: The Page Object Model (POM) (`basic_pom/`)
As we write more tests, we repeat selectors (`By.ID, 'taskInput'`) and actions. The Page Object Model (POM) is a design pattern that solves this by creating a class for each page in our app.

-   **What it is:** A class that centralizes all locators and user actions for a specific page.
-   **Why use it:**
    -   **Maintainability:** If a UI element changes (e.g., its ID is updated), you only need to update it in one place: the page object.
    -   **Readability:** Tests become clean and describe *what* is being done, not *how* it's done.

**The Page Object (`basic_pom/pages/todo_page.py`):**
This class doesn't contain any tests or assertions. It's just a map of the page.
```python
# From basic_pom/pages/todo_page.py
class TodoPage:
    # Locators are stored as class variables (tuples).
    # This makes them easy to find and update.
    TASK_INPUT = (By.ID, 'taskInput')
    ADD_TASK_BUTTON = (By.ID, 'addTaskBtn')
    TASK_LIST = (By.ID, 'taskList')

    def __init__(self, driver):
        self.driver = driver

    # Actions are defined as methods. They describe user behaviors.
    def add_task(self, task_name):
        self.driver.find_element(*self.TASK_INPUT).send_keys(task_name)
        self.driver.find_element(*self.ADD_TASK_BUTTON).click()

    def get_task_element(self, task_name):
        # This is a dynamic locator, built using the task name.
        xpath = f"//li[contains(., '{task_name}')]"
        return self.driver.find_element(By.XPATH, xpath)
```

**The Test (`basic_pom/test_todo_app.py`):**
The test is now much cleaner and more readable. It uses the `TodoPage` to interact with the application.
```python
# From basic_pom/test_todo_app.py
from pages.todo_page import TodoPage

def test_add_task_positive(driver):
    # Arrange
    # Create an instance of our page object.
    todo_page = TodoPage(driver)
    # Load the page.
    todo_page.load() # A helper method in the POM

    # Act
    # Call the high-level action method from the page object.
    todo_page.add_task("Buy milk")

    # Assert
    # Use another page object method to get the result.
    task_element = todo_page.get_task_element("Buy milk")
    assert task_element.is_displayed()
```

### Level 4: Fullstack End-to-End Testing (`fullstack/`)
Now we test the fullstack application. The key difference is that we must verify changes in the **database** as well as the UI to confirm true persistence.

**How the Test Works (`fullstack/test_e2e_todo_app.py`):**
Our E2E test uses the same POM pattern but adds a database verification step.
1.  **Arrange:** Clear the database to ensure a clean state. Load the page from the live server.
2.  **Act:** Use the `TodoPage` object to add a task via the UI.
3.  **Assert (UI):** Check that the new task is visible on the page.
4.  **Assert (DB):** Use a helper module (`utils/db_manager.py`) to connect to the database and verify that a new row was created with the correct data.

```python
# From fullstack/test_e2e_todo_app.py
from pages.todo_page import TodoPage
from utils import db_manager

def test_add_task_end_to_end(driver):
    # Arrange
    todo_page = TodoPage(driver)
    task_name = "Pay electricity bill"
    # Ensure the database is empty before the test.
    db_manager.clear_all_tasks()
    # Load the page from the running Flask server.
    todo_page.load()

    # Act
    todo_page.add_task(task_name)

    # Assert (UI)
    # Check that the frontend updated correctly.
    assert todo_page.get_task_element(task_name).is_displayed()

    # Assert (DB)
    # Check that the backend persisted the data correctly.
    db_task = db_manager.get_task_by_text(task_name)
    assert db_task is not None
    assert db_task['text'] == task_name
    assert db_task['completed'] == 0 # Verify the default state
```

---

## Part 5: Appendix

### Deep Dive: Interacting with a Database (SQLite)
For true E2E testing, you must verify data at its source. Let's walk through the process with a clear scenario.

**Scenario:** In our To-Do app, after we add a new task called "Final Presentation", we need to connect to the database to prove it was saved correctly.

#### Step 1: Import the `sqlite3` library
This is a standard Python library, so no installation is needed.
```python
import sqlite3
```

#### Step 2: Connect to the Database
This opens the database file. If the file doesn't exist, it will be created.
```python
# Scenario: Open a connection to our application's database.
DATABASE_PATH = 'fullstack/todo.db'
conn = sqlite3.connect(DATABASE_PATH)
```

#### Step 3: Create a Cursor
A `cursor` is an object that acts like a mouse pointer in a text file. It lets you execute commands and move through the results.
```python
# Scenario: We need a cursor to send commands to our database.
cur = conn.cursor()
```

#### Step 4: Execute a SQL Query
This is where you send your SQL command. Use `?` as a placeholder for any variables to prevent a security vulnerability called SQL Injection.
```python
# Scenario: We want to find the task we just created.
task_to_find = "Final Presentation"
query = "SELECT * FROM tasks WHERE text = ?"
cur.execute(query, (task_to_find,)) # Note: args must be a tuple
```

#### Step 5: Fetch the Results
After executing a `SELECT` query, you need to retrieve the data.
- `fetchone()`: Gets the first matching row. Returns `None` if no match is found.
- `fetchall()`: Gets all matching rows as a list.
```python
# Scenario: Get the single task we searched for.
result = cur.fetchone() # e.g., (1, 'Final Presentation', 0)
print(result)
```

#### Step 6: Commit Changes (for Write Operations)
If you run an `INSERT`, `UPDATE`, or `DELETE` query, the change is not saved until you `commit` it.
```python
# Scenario: We need to delete all tasks for a clean test environment.
cur.execute("DELETE FROM tasks")
conn.commit() # This saves the deletion.
```

#### Step 7: Close the Connection
Always close the connection to release the database file lock and free up resources.
```python
# Scenario: We are done with the database for now.
conn.close()
```

### CI/CD Integration with GitHub Actions
Continuous Integration (CI) is the practice of automatically running your tests every time you push a code change. This helps catch bugs early. Here is a simple GitHub Actions workflow to run our `fullstack` tests.

**File:** `.github/workflows/e2e-tests.yml`
```yaml
name: E2E Tests

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install dependencies
        run: pip install selenium pytest flask

      - name: Start Flask server in background
        run: |
          cd fullstack
          nohup python app.py &
          sleep 2 # Give the server a moment to start

      - name: Run pytest
        run: |
          cd fullstack
          pytest
```
This workflow will automatically run on every push or pull request, giving you confidence that your changes haven't broken anything.

---

## Part 6: Long Story Short - A Selenium Test Template
If you're starting a new test file, here is a general-purpose template that combines `pytest`, the AAA pattern, and explicit waits.

```python
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# 1. The Pytest Fixture (Setup & Teardown)
@pytest.fixture
def driver():
    """
    Creates and tears down a WebDriver instance for each test.
    """
    # ARRANGE (Setup)
    driver = webdriver.Chrome() # Or Firefox, Edge, etc.
    driver.implicitly_wait(5) # A small implicit wait for stability.
    yield driver
    # ARRANGE (Teardown)
    driver.quit()


# 2. The Test Function
def test_feature_scenario(driver):
    """
    A template for a single test case.
    The function name should describe what it tests.
    """
    # ARRANGE
    # Go to the page you want to test.
    driver.get("http://example.com")
    # Define any test data you need.
    expected_title = "Example Domain"

    # ACT
    # In this simple case, the action is just loading the page.
    # For a login test, this would be:
    # driver.find_element(By.ID, 'username').send_keys('user')
    # driver.find_element(By.ID, 'password').send_keys('pass')
    # driver.find_element(By.ID, 'submit').click()

    # ASSERT
    # Use an explicit wait for the condition you are verifying.
    wait = WebDriverWait(driver, 10)
    wait.until(EC.title_is(expected_title))

    # Perform your assertions.
    actual_title = driver.title
    assert actual_title == expected_title

    # You can have multiple assertions.
    header_element = driver.find_element(By.TAG_NAME, 'h1')
    assert header_element.is_displayed()
    assert "Example" in header_element.text
```

