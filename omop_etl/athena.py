from selenium import webdriver
from datetime import datetime as dt

# %%
def athena_driver(username, password, chrome_path, headless=True, download_dir=None):
    options = webdriver.ChromeOptions()
    options.add_argument("--incognito")
    options.add_argument('window-size=1680x900')
    options.headless = headless
    if download_dir:
        options.add_experimental_option('prefs', {'download.default_directory': download_dir})
    driver = webdriver.Chrome(executable_path=chrome_path, options=options)
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


def request_new_vocabulary(driver, vocabularies):
    driver.get('https://athena.ohdsi.org/search-terms/start')
    driver.find_element_by_xpath('/html/body/div/div/header/nav/div[3]/div/a/div[2]').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[3]/div/div/div/a[1]').click()

    attempts = 0
    success = False
    while success is False:
        
        try:
            driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[2]/a').click()
            success = True

        except Exception:
            attempts += 1

            if attempts > 3: 
                raise
        
    # double click on select all to make sure no vocab is selected 
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/table/thead/tr/th[1]/label').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/table/thead/tr/th[1]/label').click()

    # Select vocabularies
    checkboxes = driver.find_elements_by_css_selector("#app > div > div.at-vocabs > div.at-vocabularies > table > tbody > tr")
    
    for checkbox in checkboxes:
        cls = checkbox.find_element_by_class_name('at-vocabularies__code-td')
        if cls.text in vocabularies:
            checkbox.click()
            print(f'Vocabulary {cls.text} was selected')
    
    datestamp = dt.today().strftime('%m_%d_%Y')
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[1]/button').click()
    # Datestamp vocabulary file
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[3]/div[2]/div/div[2]/form/div/div[1]/input').send_keys(f'vocabulary_5x_{datestamp}')
    # Request vocab file
    driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[3]/div[2]/div/div[2]/form/div/div[2]/button[1]').click()

    # Wait for Athena to create vocabulary.
    driver.implicitly_wait(10)

    driver.find_element_by_xpath('/html/body/div/div/div[1]/div[4]/div[2]/img').click()
    driver.find_element_by_xpath('/html/body/div/div/div[1]/div[1]/a').click()
    buttons = driver.find_elements_by_class_name("react-sanfona-item")
    button = buttons[0]
    vocab_status = button.text.split('\n')[-1]

    while vocab_status == 'PENDING':
        print('Preparing vocabulary. It may take several minutes, please wait.', end='\r')
        driver.implicitly_wait(60)
        tool = button.find_element_by_class_name('ac-toolbar')
        vocab_status = tool.text.split()[-1]

        if vocab_status == 'DOWNLOADSHAREARCHIVE':
            print("Vocabulary file is ready ...                                        ")
            break

    #return to main page
    driver.get('https://athena.ohdsi.org/search-terms/start')


def download_vocabulary(driver, version='last', archive=False):
    """Download Athena vocabulary file."""

    driver.get('https://athena.ohdsi.org/search-terms/start')
    driver.find_element_by_xpath('/html/body/div/div/header/nav/div[3]/div/a/div[2]').click()
    driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[3]/div/div/div/a[1]').click()
    driver.implicitly_wait(5)
    # driver.find_element_by_xpath('//*[@id="app"]/div/header/nav/div[3]/div').click()
    buttons = driver.find_elements_by_class_name("react-sanfona-item")

    if version == 'last':
        try:
            button = buttons[0]
        except IndexError:
            print(f'No vocabulary versions found. Request new vocabulary file first.')
    
    else:
        try: 
            button = [x for x in buttons if version in x.text.split()][0]
        except IndexError:
            print(f"Vocabulary version {version} was not found.")
            quit()

    status = button.text.split()[-1]

    if status == 'DOWNLOADSHAREARCHIVE': 
        driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[1]').click()
        if archive:
            driver.implicitly_wait(30)
            driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[3]').click()

    elif status == 'ARCHIVEDRESTORE':
        driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button').click()
        driver.implicitly_wait(10)
        tool = button.find_element_by_class_name('ac-toolbar')
        status = tool.text.split()[-1]

    while status == 'PENDING':
        print('Preparing vocabulary. It may take several minutes, please wait.', end='\r')
        driver.implicitly_wait(60)
        tool = button.find_element_by_class_name('ac-toolbar')
        status = tool.text.split()[-1]

        if status == 'DOWNLOADSHAREARCHIVE':
            driver.implicitly_wait(30)
            driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[1]').click()
            print("Download started ...                                               ")
            if archive:
                driver.implicitly_wait(30)
                driver.find_element_by_xpath('//*[@id="app"]/div/div[1]/div[2]/div[1]/div[1]/ul/li/div/button[3]').click() 

    print('Download complete')

# %%
def get_downloaded_filename(download_dir):
    
    import glob, os
    
    zip_list = glob.glob(download_dir + '/*.zip')
    last_zip = max(zip_list, key=os.path.getctime)

    return last_zip
    
# %%
