# SCRAPING OUTLINE FROM: https://www.lambdatest.com/blog/playwright-for-web-scraping/
# https://github.com/oxylabs/playwright-web-scraping
# DOCS: https://playwright.dev/docs/intro

# to use Playwright test development GUI: 
# python -m playwright codegen https://gems.opi.mt.gov/ 

# RARE CANNOT CONNECT TO POWERBI THING
import json
import logging
import os
import subprocess
import sys
import time
import urllib
from logging import getLogger
import playwright
from playwright.async_api import async_playwright
from playwright.sync_api import sync_playwright
from playwright.sync_api import Playwright, sync_playwright, expect
import asyncio
import time


# workbook = xlsxwriter.Workbook('ricas_math.xlsx')
# worksheet = workbook.add_worksheet()
# worksheet.write('R1', 'Subject')



# async def main():
#  async with async_playwright() as p:
#     browser = await p.chromium.launch(headless=False)
#     page = await browser.new_page()
#     await page.goto('https://gems.opi.mt.gov/student-data')
#     await page.wait_for_timeout(1000)
#     await browser.close()


    # all_products = await page.query_selector_all('.a-spacing-base')
    # data = []
    # for product in all_products:
    #     result = dict()
#         title_el = await product.query_selector('span.a-size-base-plus')
#         result['title'] = await title_el.inner_text()
#         price_el = await product.query_selector('span.a-price')
#         result['price'] = await price_el.inner_text()
#         rating_el = await product.query_selector('span.a-icon-alt')
#         result['rating'] = await rating_el.inner_text()
#         data.append(result)
#         print(data)
#     await browser.close()

#         page.screenshot(path="example.png")

# configMathAndELA38 = {"gradeList" : ["3rd Grade", "4th Grade", "5th Grade", "6th Grade", "7th Grade", "8th Grade"]}

def setup(p, sleepTime:int=20, headless:bool=False):
    browser = p.chromium.launch(headless=headless)
    context = browser.new_context()
    page = context.new_page()
    page.goto("https://gems.opi.mt.gov/")
    page.get_by_role("link", name="Student", exact=True).click()
    time.sleep(sleepTime)
    return page, browser, context

def main():
    with sync_playwright() as p:
        page, browser, context = setup(p, 20, False)


        # FIRST DASHBOARD:
        page.get_by_text("Math and ELA Assessments Dashboard (Grades 3-8)").click(force=True)
        gradeList = ["3rd Grade", "4th Grade", "5th Grade", "6th Grade", "7th Grade", "8th Grade"]
        geographyLoop(page)
        # gradeLoop(page, gradeList)

        # # FIRST SUBJECT
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_text("Percentage Of Students At Each Proficiency LevelPercentage Of Students At Each P").click(timeout=60*3*1000)
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("visual-title").get_by_text("English Language Arts (ELA) Proficiency Levels").click()
        # downloadLoop(page, "Montana", "ProficiencyLevels")

        # # SECOND SUBJECT
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Bookmark . Display Students That Test At Or Above Proficient And Total Students Tested, And Schools Or Districts Can Be Compared To The State For These Measures").locator("path").first.click(timeout=60*3*1000)
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Percent At Or Above Proficient, Statewide Compared To Selected Schools").click()
        # downloadLoop(page, "Montana", "PercentAtOrAboveProficiency")
        
        # # THIRD SUBJECT
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Bookmark . Display Percentile Score Trends For The SBAC Assessment").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Average Scale Score By Percentiles").click()
        # downloadLoop(page, "Montana", "ScaleScores")

        # # FOURTH SUBJECT
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Bookmark . Display Participation").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("English Language Arts (ELA) Percent Assessed").click()
        # downloadLoop(page, "Montana", "Participation")

            
        context.close()
        browser.close()



        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Bookmark . Display Students That Test At Or Above Proficient And Total Students Tested, And Schools Or Districts Can Be Compared To The State For These Measures").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("legend").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("visual-more-options-btn").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").locator(".cdk-overlay-backdrop").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Bookmark . Display Percentile Score Trends For The SBAC Assessment").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("Bookmark . Display Participation").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("State Label, County Name, District Name, School Name").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Montana").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Montana").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Beaverhead").locator("i").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Beaverhead").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Beaverhead").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Dillon Elem").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Dillon Elem").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Montana").click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Dillon Elem").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Dillon Elem").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Grant Elem").locator("span").first.click()
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name="Grant Elem").locator("span").first.click()


def downloadLoop(page, geography:str, varName:str, grades:str, subject:str):
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("visual-more-options-btn").click(force=True)
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("pbimenu-item.Export data").dispatch_event('click')
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label(".xlsx (Excel 150,000-row max)").click()
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("option", name=".csv (30,000-row max)").click()
    with page.expect_download() as download_info:
           # Perform the action that initiates download
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("export-btn").dispatch_event('click')
    download = download_info.value
    download.save_as("temp/" + varName + "_" + geography + "_" + grades + ".csv")
    time.sleep(5)

def geographyLoop(page):
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_label("State Label, County Name, District Name, School Name").click(timeout=60*3*1000)
    ## RUNNING INTO SCROLLING ISSUE ON GEOGRAPHY LOOP
    ### Scroll failure happens on number 9. STILL HAPPENING DESPITE SCROLL.
    # De-select all Montana
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(0).dispatch_event('click')
    # 56 elements
    for i in range(1,57,1):
        if i < 56:
            page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i+1).scroll_into_view_if_needed()
            time.sleep(0.2)
        else: 
            page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).scroll_into_view_if_needed()
            time.sleep(0.2)
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).dispatch_event('click')
        time.sleep(0.5)
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).dispatch_event('click')


def gradeLoop(page, gradeList:list):
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("visual-container-repeat").get_by_label("Grade Level", exact=True).locator("i").click(timeout=60*3*1000)
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("option", name="Select all").locator("div span").dispatch_event('click')
    for g in gradeList:
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("option", name=g).locator("div span").dispatch_event('click')
        time.sleep(0.5)
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("option", name=g).locator("div span").dispatch_event('click')


    time.sleep(10)

if __name__ == "__main__":
    main()




# TO PACKAGE INTO EXECUTABLE:

# Bash:
# $env:PLAYWRIGHT_BROWSERS_PATH="0"
# playwright install chromium
# pyinstaller -F main.py

# PowerShell:
# PLAYWRIGHT_BROWSERS_PATH=0 playwright install chromium
# pyinstaller -F main.py