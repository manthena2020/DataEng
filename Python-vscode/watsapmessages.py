from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import NoSuchElementException
import pandas
import time
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

# Load the chrome driver
# Specify the path to the ChromeDriver executable
driver = webdriver.Chrome()
                          
count = 0

# Open WhatsApp URL in chrome browser
driver.get("https://web.whatsapp.com/")
wait = WebDriverWait(driver, 1000)

try:
    qr_code_element = wait.until(EC.presence_of_element_located((By.ID, "side")))

    # Read data from excel
    excel_data = pandas.read_excel('Customer bulk email data.xlsx', sheet_name='Customers', engine='openpyxl')

    # Iterate excel rows till to finish
    for column in excel_data['Name'].tolist():
        # Assign customized message
        message = excel_data['Message'][0]

        # Locate search box through XPath
        search_box = '//*[@id="side"]/div[1]/div/label/div/div[2]'
        person_title = wait.until(lambda driver: driver.find_element_by_xpath(search_box))

        # Clear search box if any contact number is written in it
        person_title.clear()

        # Send contact number in search box
        person_title.send_keys(str(excel_data['Contact'][count]))
        count = count + 1

        # Wait for 2 seconds to search contact number
        time.sleep(2)

        try:
            # Load error message in case unavailability of contact number
            element = driver.find_element_by_xpath('//*[@id="pane-side"]/div[1]/div/span')
        except NoSuchElementException:
            # Format the message from the excel sheet
            message = message.replace('{customer_name}', column)
            person_title.send_keys(Keys.ENTER)
            actions = ActionChains(driver)
            actions.send_keys(message)
            actions.send_keys(Keys.ENTER)
            actions.perform()

    # Close chrome browser
    driver.quit()

except Exception as e:
    print("Error:", str(e))