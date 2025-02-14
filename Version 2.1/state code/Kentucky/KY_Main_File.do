*******************************************************
* KENTUCKY

* File name: KY_Main_File
* Last update: 2/13/2025

*******************************************************

*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

** Set directory to Kentucky folder
cd "/Volumes/T7/State Test Project/Kentucky"

** Set Path to do-files
global DoFiles "/Users/joshuasilverman/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/Kentucky"

** Set Path to NCES Folders
global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_KY "/Volumes/T7/State Test Project/Kentucky/NCES"

** Original Data and Output Data folders
global Original "/Volumes/T7/State Test Project/Kentucky/Original Data Files"
global Output "/Volumes/T7/State Test Project/Kentucky/Output"

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
do "$DoFiles/KY_NCES.do"
do "$DoFiles/KY_Cleaning_2012_2021.do"
do "$DoFiles/KY_Cleaning_DataRequest_2022-2024.do"
do "$DoFiles/KY_EDFactsParticipation_2022"

** Note: All importing code is uncommented for the first run.
