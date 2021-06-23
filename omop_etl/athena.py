import time
from selenium import webdriver
from selenium.webdriver.remote.errorhandler import NoSuchElementException
from datetime import datetime as dt
from omop_etl.utils import timeitc



def athena_driver(username, password, headless=True, download_dir=None):
    options = webdriver.ChromeOptions()
    options.add_argument("--incognito")
    options.add_argument('window-size=1680x900')
    options.headless = headless
    if download_dir:
        options.add_experimental_option('prefs', {'download.default_directory': download_dir})
    driver = webdriver.Chrome(executable_path='chromedriver.exe', options=options)
    driver.set_window_position(0,0)
    driver.set_window_size(1200, 1375)
    driver.set_page_load_timeout(15)
    
    driver.get("https://athena.ohdsi.org/")
    driver.find_element_by_xpath('/html/body/div/div/div[4]/div[2]/div/div[2]/div[2]/button').click()
    driver.find_element_by_xpath('/html/body/div/div/header/nav/div[3]/a').click()
    driver.find_element_by_xpath('/html/body/div/div/div[1]/div/div[2]/div/button').click()

    main_window = driver.current_window_handle
    for handle in driver.window_handles:
        if handle != main_window:
            popup = handle
            driver.switch_to.window(popup)

    driver.find_element_by_xpath('//*[@id="username"]').send_keys(username)
    driver.find_element_by_xpath('//*[@id="password"]').send_keys(password)
    driver.find_element_by_xpath('/html/body/div[1]/div/div/div[2]/div/form/section[3]/input[4]').click()
    driver.switch_to.window(driver.window_handles[0])

    return driver 

def request_new_vocabulary_file(driver):
    driver.get('https://athena.ohdsi.org/search-terms/start')
    driver.find_element_by_xpath('/html/body/div/div/header/nav/div[3]/div/a/div[2]').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[3]/div/div/div/a[1]').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[2]/a').click()
    
    # double click on select all to make sure no vocab is selected 
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/table/thead/tr/th[1]/label').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/table/thead/tr/th[1]/label').click()

    # Select vocabularies
    checkboxes = driver.find_elements_by_css_selector("#app > div > div.at-vocabs > div.at-vocabularies > table > tbody > tr")
    with open('omop_vocabularies.yml') as f:
        vocabs = yaml.safe_load(f)
    
    for checkbox in checkboxes:
        cls = checkbox.find_element_by_class_name('at-vocabularies__code-td')
        if cls.text in vocabs:
            checkbox.click()
            print(f'Vocabulary {cls.text} was selected')
    
    datestamp = dt.today().strftime('%m_%d_%Y')
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[1]/button').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[3]/div[2]/div/div[2]/form/div/div[1]/input').send_keys(f'vocabulary_5x_{datestamp}')
    
    # Request vocab file
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[3]/div[2]/div/div[2]/form/div/div[2]/button[1]').click()

    #return to main page
    driver.get('https://athena.ohdsi.org/search-terms/start')

def download_vocabulary_file(driver, get_last=True, vocabulary_name=None, archive=True, restore=True):
    """Download most recent vocabulary file."""
    driver.get('https://athena.ohdsi.org/search-terms/start')
    driver.find_element_by_xpath('/html/body/div/div/header/nav/div[3]/div/a/div[2]').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[3]/div/div/div/a[1]').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[3]/div').click()
    buttons = driver.find_elements_by_class_name("react-sanfona-item")
    last = True
    archive = False
    if get_last:
        button = buttons[0]
        tool = button.find_element_by_class_name('ac-toolbar')
        status = tool.text.split()[-1]
        if status == 'DOWNLOADSHAREARCHIVE': 
            driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[1]').click()
            if archive:
                time.sleep(30)
                driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[3]').click()
        elif status == 'ARCHIVEDRESTORE':
            driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button').click()
            time.sleep(2)
            tool = button.find_element_by_class_name('ac-toolbar')
            status = tool.text.split()[-1]
            while status == 'PENDING':
                print('Restoring vocabulary, please wait.', end='\r')
                time.sleep(60)
                tool = button.find_element_by_class_name('ac-toolbar')
                status = tool.text.split()[-1]
                if status == 'DOWNLOADSHAREARCHIVE':
                    time.sleep(30)
                    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[1]').click()
                    print("Download started")
                    if archive:
                        time.sleep(30)
                        driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[3]').click()                
        elif status == 'PENDING':
            print('Restoring vocabulary, try again later.')
