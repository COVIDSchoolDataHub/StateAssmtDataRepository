# SCRAPING OUTLINE FROM: https://www.lambdatest.com/blog/playwright-for-web-scraping/
# https://github.com/oxylabs/playwright-web-scraping
# DOCS: https://playwright.dev/docs/intro

# to use Playwright test development GUI: 
# python -m playwright codegen https://gems.opi.mt.gov/ 

# RARE CANNOT CONNECT TO POWERBI THING

# Results in tags:

#  page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").get_by_text("Error drawing dashboard: unable to connect to https://api.powerbi.com/").click()
#     page.goto("https://gems.opi.mt.gov/")
#     page.frame_locator("iframe").get_by_text("Error drawing dashboard: unable to connect to https://api.powerbi.com/").click()
#     page.frame_locator("iframe").get_by_text("Error drawing dashboard:").click()


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

configMathAndELA38 = {"gradeList" : ["3rd Grade", "4th Grade", "5th Grade", "6th Grade", "7th Grade", "8th Grade"]}
countyList = ["Beaverhead", "Big Horn", "Blaine", "Broadwater", "Carbon", "Carter", "Cascade", "Chouteau", "Custer", "Daniels", "Dawson", "Deer Lodge", "Fallon", "Fergus", "Flathead", "Gallatin", "Garfield", "Glacier", "Golden Valley", "Granite", "Hill", "Jefferson", "Judith Basin", "Lake", "Lewis & Clark", "Liberty", "Lincoln", "Madison", "McCone", "Meagher", "Mineral", "Missoula", "Musselshell", "Park", "Petroleum", "Phillips", "Pondera", "Powder River", "Powell", "Prairie", "Ravalli", "Richland", "Roosevelt", "Rosebud", "Sanders", "Sheridan", "Silver Bow", "Stillwater", "Sweet Grass", "Teton", "Toole", "Treasure", "Valley", "Wheatland", "Wibaux", "Yellowstone"]

countyDistrictMap = {"Beaverhead":["Dillon Elem", "Grant Elem", "Jackson Elem", "Lima K-12 Schools", "Polaris Elem", "Reichle Elem", "Wisdom Elem", "Wise River Elem"],
 "Big Horn":["Hardin Elem", "Lodge Grass Elem", "Pryor Elem", "Spring Creek Elem", "Wyola Elem"],
 "Blaine":["Bear Paw Elem", "Chinook Elem", "Cleveland Elem", "Harlem Elem", "Hays-Lodge Pole K-12 Schls", "North Harlem Colony Elem", "Turner Elem", "Zurich Elem"],
 "Broadwater":["Townsend K-12 Schools"],
 "Carbon":["Belfry K-12 Schools", "Bridger K-12 Schools", "Fromberg K-12", "Joliet Elem", "Luther Elem", "Red Lodge Elem", "Roberts K-12 Schools"],
 "Carter":["Alzada Elem", "Ekalaka Elem", "Hawks Home Elem"],
 "Cascade":["Belt Elem", "Cascade Elem", "Centerville Elem", "Great Falls Elem", "Sun River Valley Elem", "Ulm Elem", "Vaughn Elem"],
 "Chouteau":["Benton Lake Elem", "Big Sandy Elem", "Big Sandy K-12", "Carter Elem", "Fort Benton Elem", "Geraldine K-12", "Highwood K-12", "Knees Elem"],
 "Custer":["Kinsey Elem", "Kircher Elem", "Miles City Elem", "S H Elem", "S Y Elem", "Spring Creek Elem", "Trail Creek Elem"],
 "Daniels":["Scobey K-12 Schools"],
 "Dawson":["Bloomfield Elem", "Deer Creek Elem", "Glendive Elem", "Lindsay Elem", "Richey Elem"],
 "Deer Lodge":["Anaconda Elem"],
 "Fallon":["Baker K-12 Schools", "Plevna K-12 Schools"],
 "Fergus":["Ayers Elem", "Deerfield Elem", "Denton Elem", "Grass Range Elem", "King Colony Elem", "Lewistown Elem", "Moore Elem", "Roy K-12 Schools", "Spring Creek Colony Elem", "Winifred K-12 Schools"],
 "Flathead":["Bigfork Elem", "Cayuse Prairie Elem", "Columbia Falls Elem", "Creston Elem", "Deer Park Elem", "Evergreen Elem", "Fair-Mont-Egan Elem", "Helena Flats Elem", "Kalispell Elem", "Kila Elem", "Marion Elem", "Olney-Bissell Elem", "Pleasant Valley Elem", "Smith Valley Elem", "Somers Elem", "Swan River Elem", "West Glacier Elem", "West Valley Elem", "Whitefish Elem"],
 "Gallatin":["Amsterdam Elem", "Anderson Elem", "Belgrade Elem", "Big Sky School K-12", "Bozeman Elem", "Cottonwood Elem", "Gallatin Gateway Elem", "LaMotte Elem", "Malmborg Elem", "Manhattan School", "Monforton Elem", "Pass Creek Elem", "Springhill Elem", "Three Forks Elem", "West Yellowstone K-12", "Willow Creek Elem"],
 "Garfield":["Cohagen Elem", "Jordan Elem", "Kester Elem", "Pine Grove Elem", "Ross Elem", "Sand Springs Elem"],
 "Glacier":["Browning Elem", "Cut Bank Elem", "East Glacier Park Elem", "Mountain View Elem"],
 "Golden Valley":["Lavina K-12 Schools", "Ryegate K-12 Schools"],
 "Granite":["Drummond Elem", "Hall Elem", "Philipsburg K-12 Schools"],
 "Hill":["Box Elder Elem", "Cottonwood Elem", "Davey Elem", "Gildford Colony Elem", "Havre Elem", "North Star Elem", "Rocky Boy Elem"],
 "Jefferson":["Basin Elem", "Boulder Elem", "Cardwell Elem", "Clancy Elem", "Montana City Elem", "Whitehall Elem"],
 "Judith Basin":["Geyser Elem", "Geyser K-12 Schools", "Hobson K-12 Schools", "Stanford K-12 Schools"],
 "Lake":["Arlee Elem", "Charlo Elem", "Polson Elem", "Ronan Elem", "St Ignatius K-12 Schools", "Swan Lake-Salmon Elem", "Upper West Shore Elem", "Valley View Elem"],
 "Lewis & Clark":["Auchard Creek Elem", "Augusta Elem", "East Helena Elem", "East Helena K-12", "Helena Elem", "Lincoln K-12 Schools", "Trinity Elem", "Wolf Creek Elem"],
 "Liberty":["Chester-Joplin-Inverness El", "Liberty Elem"],
 "Lincoln":["Eureka Elem", "Fortine Elem", "Libby K-12 Schools", "McCormick Elem", "Trego Elem", "Troy Elem", "Yaak Elem"],
 "Madison":["Alder Elem", "Ennis K-12 Schools", "Harrison K-12 Schools", "Sheridan Elem", "Twin Bridges K-12 Schools"],
 "McCone":["Circle Elem", "Vida Elem"],
 "Meagher":["White Sulphur Spgs K-12"],
 "Mineral":["Alberton K-12 Schools", "St Regis K-12 Schools", "Superior K-12 Schools"],
 "Missoula":["Bonner Elem", "Clinton Elem", "DeSmet Elem", "Frenchtown K-12 Schools", "Hellgate Elem", "Lolo Elem", "Missoula Elem", "Potomac Elem", "Seeley Lake Elem", "Sunset Elem", "Swan Valley Elem", "Target Range Elem", "Woodman Elem"],
 "Musselshell":["Melstone Elem", "Roundup Elem"],
 "Park":["Arrowhead Elem", "Cooke City Elem", "Gardiner Elem", "Livingston Elem", "Pine Creek Elem", "Shields Valley Elem"],
 "Petroleum":["Winnett K-12 Schools"],
 "Phillips":["Dodson K-12", "Malta K-12 Schools", "Saco Elem", "Whitewater K-12 Schools"],
 "Pondera":["Conrad Elem", "Dupuyer Elem", "Heart Butte K-12 Schools", "Miami Elem", "Valier Elem"],
 "Powder River":["Biddle Elem", "Broadus Elem", "South Stacey Elem"],
 "Powell":["Avon Elem", "Deer Lodge Elem", "Elliston Elem", "Garrison Elem", "Gold Creek Elem", "Helmville Elem", "Ovando Elem"],
 "Prairie":["Terry K-12 Schools"],
 "Ravalli":["Corvallis K-12 Schools", "Darby K-12 Schools", "Florence-Carlton K-12 Schls", "Hamilton K-12 Schools", "Lone Rock Elem", "Stevensville Elem", "Victor K-12 Schools"],
 "Richland":["Brorson Elem", "Fairview Elem", "Lambert Elem", "Rau Elem", "Savage Elem", "Sidney Elem"],
 "Roosevelt":["Bainville K-12 Schools", "Brockton Elem", "Culbertson Elem", "Froid Elem", "Frontier Elem", "Poplar Elem", "Wolf Point Elem"],
 "Rosebud":["Ashland Elem", "Birney Elem", "Colstrip Elem", "Forsyth Elem", "Lame Deer Elem", "Rosebud K-12"],
 "Sanders":["Dixon Elem", "Hot Springs K-12", "Noxon Elem", "Plains Elem", "Plains K-12", "Thompson Falls Elem", "Trout Creek Elem"],
 "Sheridan":["Medicine Lake K-12 Schools", "Plentywood K-12 Schools", "Westby K-12 Schools"],
 "Silver Bow":["Butte Elem", "Divide Elem", "Melrose Elem", "Ramsay Elem"],
 "Stillwater":["Absarokee Elem", "Columbus Elem", "Fishtail Elem", "Molt Elem", "Nye Elem", "Park City Elem", "Rapelje Elem", "Reed Point Elem"],
 "Sweet Grass":["Big Timber Elem", "Greycliff Elem", "McLeod Elem", "Melville Elem"],
 "Teton":["Bynum Elem", "Choteau Elem", "Dutton/Brady K-12 Schools", "Fairfield Elem", "Golden Ridge Elem", "Greenfield Elem", "Pendroy Elem", "Power Elem"],
 "Toole":["Galata Elem", "Shelby Elem", "Sunburst K-12 Schools"],
 "Treasure":["Hysham K-12 Schools"],
 "Valley":["Frazer Elem", "Glasgow K-12 Schools", "Hinsdale Elem", "Lustre Elem", "Nashua K-12 Schools", "Opheim K-12 Schools"],
 "Wheatland":["Harlowton Elem", "Harlowton K-12", "Judith Gap Elem"],
 "Wibaux":["Wibaux K-12 Schools"],
 "Yellowstone":["Billings Elem", "Blue Creek Elem", "Broadview Elem", "Canyon Creek Elem", "Custer K-12 Schools", "Elder Grove Elem", "Elysian Elem", "Huntley Projet K-12 Schools", "Independent Elem", "Laurel Elem", "Lockwood Elem", "Lockwood K-12", "Morin Elem", "Pioneer Elem", "Shepherd Elem", "Yellowstone Academy Elem"]}

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
        gradeList = configMathAndELA38.get("gradeList")
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
    page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(0).dispatch_event('click', timeout=60*3*1000)
    # 56 elements
    # for i in range(1,57,1):
    #     if i < 56:
    #         page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i+1).scroll_into_view_if_needed()
    #         time.sleep(0.5)
    #     else: 
    #         page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).scroll_into_view_if_needed()
    #         time.sleep(0.5)
    #     page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).dispatch_event('click')
    #     time.sleep(0.5)
    #     page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).dispatch_event('click')
    # for i in range(1,57,1):
    #     if i < 5:
    #         page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).scroll_into_view_if_needed()
    #         time.sleep(0.2)
    #         page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).dispatch_event('click')
    #     if i >= 5:
    #         page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").locator("div:nth-child(3) > .scroll-element_outer > .scroll-bar").first.dispatch_event('click')
            # page.mouse.wheel(0,-200)
    #         time.sleep(0.2)
    #         page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem").nth(i).dispatch_event('click')
    for county in countyDistrictMap.keys():
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name=county).locator("span").first.dispatch_event('click')
        page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name=county).locator("span").first.dispatch_event('wheel', { "deltaY":-200.0 })

        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").locator("div:nth-child(3) > .scroll-element_outer > .scroll-bar").first.dispatch_event('wheel', { "deltaY":-200.0 })
        # page.mouse.wheel(0,-200)
        time.sleep(0.2)
        # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_role("treeitem", name=county).locator("i").dispatch_event('click')
        # for district in countyDistrictMap.get(county):
        #     page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").get_by_text(district, exact=True).dispatch_event('click')
        #     time.sleep(0.2)

    # page.frame_locator("#OPI_main_content section >> internal:has-text=\"Math and ELA Assessments Dashboard (Grades 3-8) How do Montana students score on\"i >> iframe").frame_locator("iframe").locator("div:nth-child(3) > .scroll-element_outer > .scroll-element_track").first.click()



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