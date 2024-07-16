from selenium import webdriver

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import xlsxwriter
import requests
from bs4 import BeautifulSoup
import time


browser = webdriver.Chrome(r'/Volumes/T7/State Test Project/Rhode Island 2023/chromedriver_mac_arm64/chromedriver')
browser.get('https://www3.ride.ri.gov/ADP')
workbook = xlsxwriter.Workbook('ricas.xlsx')
worksheet = workbook.add_worksheet()

WebDriverWait(browser, 1000).until(EC.element_to_be_clickable((By.ID, 'ddlTest')))

time.sleep(1)
browser.find_element(By.ID, 'ddlTest').find_elements(By.TAG_NAME, 'option')[8].click()
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[0].send_keys('2020-21\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[0].send_keys('2018-19\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[0].send_keys('2017-18\n')
time.sleep(1)

browser.find_elements(By.CLASS_NAME, 'form-check-label')[1].click()
browser.find_elements(By.CLASS_NAME, 'form-check-label')[2].click()
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[2].send_keys('All Students\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[2].send_keys('All Students\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[2].send_keys('Economically Disadvantaged\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[2].send_keys('English Learner\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[2].send_keys('Gender\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[2].send_keys('Race/Ethnicity\n')
time.sleep(1)


browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[3].send_keys('03\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[3].send_keys('03\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[3].send_keys('04\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[3].send_keys('05\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[3].send_keys('06\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[3].send_keys('07\n')
time.sleep(1)
browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[3].send_keys('08\n')
time.sleep(1)
# browser.find_element(By.ID, 'chkADA').click()

# time.sleep(1000)

texts_to_remove = ["Warning: low percent tested:", 'Warning: year-over-year participant increase:', 'Warning: year-over-year participant decrease:']


current_spreadsheet_col = 0
# time.sleep(1000)
chosen_single_selected = 0
for district_type in range(len(browser.find_element(By.ID, 'ddlLEA').find_elements(By.TAG_NAME, 'option'))):
    browser.find_element(By.ID, 'ddlLEA').find_elements(By.TAG_NAME, 'option')[district_type].click()
    browser.find_elements(By.CLASS_NAME, 'chosen-single')[0].click()
    time.sleep(1)
    all_schools = [i.text for i in browser.find_elements(By.CLASS_NAME, 'chosen-results')[1].find_elements(By.TAG_NAME, 'li')]
    browser.find_elements(By.CLASS_NAME, 'chosen-single')[0].click()
    # print(browser.find_elements(By.CLASS_NAME, 'chosen-results')[1])
    # for school_type in range(len(browser.find_elements(By.CLASS_NAME, 'chosen-results')[1].find_elements(By.TAG_NAME, 'li'))):
    for school_type in all_schools:
        browser.find_elements(By.CLASS_NAME, 'chosen-single')[0].click()
        browser.find_elements(By.CLASS_NAME, 'chosen-search-input')[1].send_keys(f'{school_type}\n')
        time.sleep(2)
        page_source = browser.page_source
        soup = BeautifulSoup(page_source, 'html.parser')
        tds = soup.find_all('td')
        tds_new = [td.text.replace('\n', '') for td in tds]
        array_new = []
        temp_arr = []
        for item in range(len(tds_new)):
            if ' : ' in tds_new[item] and item !=0:
                array_new.append(temp_arr)
                temp_arr = []
            for i in texts_to_remove:
                if i in tds_new[item]:
                    tds_new[item].replace('i', '')
            temp_arr.append(tds_new[item])

        for item in array_new:
            current_spreadsheet_col += 1
            split_items = item[0].split(' : ')
            if split_items[1] == 'Statewide':
                # if True:
                year = split_items[0]
                district = 'Statewide'
                # district = browser.find_element(By.ID, 'ddlLEA').find_elements(By.TAG_NAME, 'option')[district_type].text
                school = 'N/A'
                # if split_items[1] == 'Statewide':
                #     school = 'N/A'
                # else:
                # school = split_items[1]
                grade = split_items[2].split(": ")[1]
                student_group = split_items[-1]
                if ':' in item[1]:
                    student_tested_number = item[1].split(': ')[-1]
                else:
                    student_tested_number = item[1]
                if ':' in item[2]:
                    student_tested_percentage = item[2].split(': ')[-1]
                else:
                    student_tested_percentage = item[2]
                # print(item[2])
                # print(item[3])
                if item[3].replace(' ', '') == 'N/A' or '*' in item[3].replace(' ', ''):
                    growth_low = 'N/A'
                    growth_typical = 'N/A'
                    growth_high = 'N/A'
                else:
                    # print(item[3])
                    split_growth = item[3].replace(' ', '').split('%')
                    growth_low = split_growth[0] + '%'
                    growth_typical = split_growth[2] + '%'
                    growth_high = split_growth[4] + '%'
                # print(item[4])
                if 'N/A' in item[4] or '*' in item[4]:

                    avg_growth_percentile = 'N/A'
                else:
                    avg_growth_percentile = item[4]

                if '*' in item[5] or item[5] == 'N/A':
                    not_meeting_expectations = 'N/A'
                    partially_meeting_expectations = 'N/A'
                    meeting_expectations = 'N/A'
                    exceeding_expectations = 'N/A'
                else:
                    split_expectations = item[5].split('%')

                    not_meeting_expectations = split_expectations[0] + '%'
                    # try:
                    partially_meeting_expectations = split_expectations[2] + '%'
                    # except:
                    #     time.sleep(1000)
                    meeting_expectations = split_expectations[4] + '%'
                    exceeding_expectations = split_expectations[6] + '%'
                    # if '4-Exceeding Expectations: ' in exceeding_expectations:
                    #     exceeding_expectations = exceeding_expectations.split('4-Exceeding Expectations: ')[1]

                if '*' in item[6] or item[6] == 'N/A':
                    meeting_or_exceeding_expectations = 'N/A'
                else:
                    meeting_or_exceeding_expectations = item[6]

                if '*' in item[7] or item[7] == 'N/A':
                    avg_scale_score = 'N/A'
                else:
                    avg_scale_score = item[7].replace(' ', '')

                print(f'''
            
                ----------------------------
                year: {year}
                district: {district}
                school: {school}
                grade: {grade}
                student group: {student_group}
                student tested number: {student_tested_number}
                student tested percentage: {student_tested_percentage}
                growth low: {growth_low}
                growth typical: {growth_typical}
                growth high: {growth_high}
                avg growth percentile: {avg_growth_percentile}
                not meeting expectations: {not_meeting_expectations}
                partially meeting expectations: {partially_meeting_expectations}
                meeting expectations: {meeting_expectations}
                exceeding expectations: {exceeding_expectations}
                meeting or exceeding expectations: {meeting_or_exceeding_expectations}
                avg scale score: {avg_scale_score}
                
                ----------------------------
                ''')
                worksheet.write(f'A{current_spreadsheet_col}', year)
                worksheet.write(f'B{current_spreadsheet_col}', district)
                worksheet.write(f'C{current_spreadsheet_col}', school)
                worksheet.write(f'D{current_spreadsheet_col}', grade)
                worksheet.write(f'E{current_spreadsheet_col}', student_group)
                worksheet.write(f'F{current_spreadsheet_col}', student_tested_number)
                worksheet.write(f'G{current_spreadsheet_col}', student_tested_percentage)
                worksheet.write(f'H{current_spreadsheet_col}', growth_low)
                worksheet.write(f'I{current_spreadsheet_col}', growth_typical)
                worksheet.write(f'J{current_spreadsheet_col}', growth_high)
                worksheet.write(f'K{current_spreadsheet_col}', avg_growth_percentile)
                worksheet.write(f'L{current_spreadsheet_col}', not_meeting_expectations)
                worksheet.write(f'M{current_spreadsheet_col}', partially_meeting_expectations)
                worksheet.write(f'N{current_spreadsheet_col}', meeting_expectations)
                worksheet.write(f'O{current_spreadsheet_col}', exceeding_expectations)
                worksheet.write(f'P{current_spreadsheet_col}', meeting_or_exceeding_expectations)
                worksheet.write(f'Q{current_spreadsheet_col}', avg_scale_score)
            else:
                # if True:
                year = split_items[0]
                # district = 'Statewide'
                # district = browser.find_element(By.ID, 'ddlLEA').find_elements(By.TAG_NAME, 'option')[district_type].text
                district = split_items[1]
                # school = 'N/A'
                # if split_items[1] == 'Statewide':
                #     school = 'N/A'
                # else:
                school = split_items[2]
                grade = split_items[3].split(": ")[1]
                student_group = split_items[-1]
                if ':' in item[1]:
                    student_tested_number = item[1].split(': ')[-1]
                else:
                    student_tested_number = item[1]
                if ':' in item[2]:
                    student_tested_percentage = item[2].split(': ')[-1]
                else:
                    student_tested_percentage = item[2]
                # print(item[2])
                # print(item[3])
                if item[3].replace(' ', '') == 'N/A' or '*' in item[3].replace(' ', ''):
                    growth_low = 'N/A'
                    growth_typical = 'N/A'
                    growth_high = 'N/A'
                else:
                    # print(item[3])
                    split_growth = item[3].replace(' ', '').split('%')
                    growth_low = split_growth[0] + '%'
                    growth_typical = split_growth[2] + '%'
                    growth_high = split_growth[4] + '%'
                # print(item[4])
                if 'N/A' in item[4] or '*' in item[4]:

                    avg_growth_percentile = 'N/A'
                else:
                    avg_growth_percentile = item[4]

                if '*' in item[5] or item[5] == 'N/A':
                    not_meeting_expectations = 'N/A'
                    partially_meeting_expectations = 'N/A'
                    meeting_expectations = 'N/A'
                    exceeding_expectations = 'N/A'
                else:
                    split_expectations = item[5].split('%')
                    # print(item[5])
                    # print(item[6])

                    not_meeting_expectations = split_expectations[0] + '%'
                    # try:
                    partially_meeting_expectations = split_expectations[2] + '%'
                    # except:
                    #     time.sleep(1000)
                    meeting_expectations = split_expectations[4] + '%'
                    exceeding_expectations = split_expectations[6] + '%'
                    # if '4-Exceeding Expectations: ' in exceeding_expectations:
                    #     exceeding_expectations = exceeding_expectations.split('4-Exceeding Expectations: ')[1]

                if '*' in item[6] or item[6] == 'N/A':
                    meeting_or_exceeding_expectations = 'N/A'
                else:
                    meeting_or_exceeding_expectations = item[6]

                if '*' in item[7] or item[7] == 'N/A':
                    avg_scale_score = 'N/A'
                else:
                    avg_scale_score = item[7].replace(' ', '')

                print(f'''

                  ----------------------------
                  year: {year}
                  district: {district}
                  school: {school}
                  grade: {grade}
                  student group: {student_group}
                  student tested number: {student_tested_number}
                  student tested percentage: {student_tested_percentage}
                  growth low: {growth_low}
                  growth typical: {growth_typical}
                  growth high: {growth_high}
                  avg growth percentile: {avg_growth_percentile}
                  not meeting expectations: {not_meeting_expectations}
                  partially meeting expectations: {partially_meeting_expectations}
                  meeting expectations: {meeting_expectations}
                  exceeding expectations: {exceeding_expectations}
                  meeting or exceeding expectations: {meeting_or_exceeding_expectations}
                  avg scale score: {avg_scale_score}
                  ----------------------------
                  ''')
                worksheet.write(f'A{current_spreadsheet_col}', year)
                worksheet.write(f'B{current_spreadsheet_col}', district)
                worksheet.write(f'C{current_spreadsheet_col}', school)
                worksheet.write(f'D{current_spreadsheet_col}', grade)
                worksheet.write(f'E{current_spreadsheet_col}', student_group)
                worksheet.write(f'F{current_spreadsheet_col}', student_tested_number)
                worksheet.write(f'G{current_spreadsheet_col}', student_tested_percentage)
                worksheet.write(f'H{current_spreadsheet_col}', growth_low)
                worksheet.write(f'I{current_spreadsheet_col}', growth_typical)
                worksheet.write(f'J{current_spreadsheet_col}', growth_high)
                worksheet.write(f'K{current_spreadsheet_col}', avg_growth_percentile)
                worksheet.write(f'L{current_spreadsheet_col}', not_meeting_expectations)
                worksheet.write(f'M{current_spreadsheet_col}', partially_meeting_expectations)
                worksheet.write(f'N{current_spreadsheet_col}', meeting_expectations)
                worksheet.write(f'O{current_spreadsheet_col}', exceeding_expectations)
                worksheet.write(f'P{current_spreadsheet_col}', meeting_or_exceeding_expectations)
                worksheet.write(f'Q{current_spreadsheet_col}', avg_scale_score)
            # print(array_new)
    chosen_single_selected = 0
workbook.close()
