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

# --- Test Execution will go here ---
time.sleep(5) # Pause for 5 seconds to see what's happening

# --- Test Teardown ---
# Close the browser window
driver.quit()