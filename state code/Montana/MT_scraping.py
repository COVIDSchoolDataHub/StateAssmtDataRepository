# SCRAPING OUTLINE FROM: https://www.lambdatest.com/blog/playwright-for-web-scraping/
# https://github.com/oxylabs/playwright-web-scraping
# DOCS: https://playwright.dev/docs/intro

# to use Playwright test development GUI: 
# python -m playwright codegen https://gems.opi.mt.gov/ 


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


#     all_products = await page.query_selector_all('.a-spacing-base')
#     data = []
#     for product in all_products:
#         result = dict()
#         title_el = await product.query_selector('span.a-size-base-plus')
#         result['title'] = await title_el.inner_text()
#         price_el = await product.query_selector('span.a-price')
#         result['price'] = await price_el.inner_text()
#         rating_el = await product.query_selector('span.a-icon-alt')
#         result['rating'] = await rating_el.inner_text()
#         data.append(result)
#         print(data)
#     await browser.close()

def main():
    with sync_playwright() as p:
        # browser = p.webkit.launch()
        # page = browser.new_page()
        # # page.goto("https://gems.opi.mt.gov/student-data")
        # # page.goto("https://gems.opi.mt.gov/")
        # page.get_by_role("button-medium").click()
        # page.screenshot(path="example.png")
        # browser.close()

        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()
        page.goto("https://gems.opi.mt.gov/")
        page.get_by_role("link", name="Student", exact=True).click()
        page.get_by_text("Math and ELA Assessments Dashboard (Grades 3-8)").click()
        # Wait until we see the data populate (can have a significant delay: timeout set to 2 mins):
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_text("Percentage Of Students At Each Proficiency LevelPercentage Of Students At Each P").click(timeout=60*3*1000)
         # sometimes, even after click, dashboard won't load. MUST FIX!
        print("Dashboard is loaded!")
        page.screenshot(path="example.png")

        # Okay, a couple of notes:
        # Bad news, the graphs are formatted as SVGs, so not easy to scrape from first page.
        # Good news, there's a 3 dot button that you can click: this presents an "export data" option and a "format as table" option. 
        # Bad news about the good news -- it's really annoying to click this button. Trying to figure out.

        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("visual-more-options-btn").click()
        print("3 dot menu is loaded!")

        # trying to click format as table
        # something about pointer interception
        # read more here! https://community.fabric.microsoft.com/t5/Developer/Report-testing-Automation-using-Playwright-unable-to-click/m-p/1372438

        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_test_id("pbimenu-item.Show as a table").click()
        page.screenshot(path="example2.png")

        context.close()
        browser.close()

 
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