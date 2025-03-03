*******************************************************
* NEW MEXICO

* File name: NM_Main_File
* Last update: 2/20/2025

*******************************************************



clear
set more off

//Setup

 ** Set Path to do-files
global DoFiles "/Users/joshuasilverman/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/New Mexico"


 ** Set path to NCES Original and Cleaned Directories
global NCESSchool "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Original NCES school data
global NCESDistrict "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" // Original NCES district data
global NCES "/Volumes/T7/State Test Project/New Mexico/NCES" //Cleaned NCES school and district data

 **Set path to EDFacts wide files
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

 **State cleaning directories
global NM "/Volumes/T7/State Test Project/New Mexico" //Main NM folder (should contain 2024 unmerged schools)
global raw "/Volumes/T7/State Test Project/New Mexico/Original Data Files" //Original Data
global output "/Volumes/T7/State Test Project/New Mexico/Output" //Output

//Recreate Cleaning
// do "$DoFiles/01_New Mexico DTA Conversion.do" //Line may be hidden after first run for speed.
// do "$DoFiles/02_New Mexico Cleaning Merge Files.do" //Line may be hidden after first run for speed.
do "$DoFiles/03_New Mexico 2017 Cleaning.do"
do "$DoFiles/04_New Mexico 2018 Cleaning.do"
do "$DoFiles/05_New Mexico 2019 Cleaning.do"
do "$DoFiles/06_New Mexico 2021 Cleaning.do"
do "$DoFiles/07_New Mexico 2022 Cleaning.do"
do "$DoFiles/08_New Mexico 2023 Cleaning.do"
do "$DoFiles/09_New Mexico 2024 Cleaning.do"
do "$DoFiles/10_NM Stable Names.do"

* End of NM Cleaning
