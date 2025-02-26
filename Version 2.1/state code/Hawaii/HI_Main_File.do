*******************************************************
* HAWAII

* File name: NM_Main_File
* Last update: 2/25/2025

*******************************************************


clear
set more off

//Setup

 ** Set Path to do-files
global DoFiles "/Users/joshuasilverman/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/Hawaii"


 ** Set path to NCES Original data (District and School files in one place)
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"


 **State cleaning directories
global Original "/Volumes/T7/State Test Project/Hawaii/Original Data" //Original Data downloaded from the drive. Should include HI_OriginalData_DataRequest_2015to2023.xlsx and HI_DataRequest02.24.25_ela_math_sci.xlsx
global Cleaned "/Volumes/T7/State Test Project/Hawaii/Output" //Output (will be empty at first)

//Recreate Cleaning
** NOTE: On the first run, you must unhide the importing code. For speed, this should be re-hidden after the first runthrough.

do "$DoFiles/01_HI_OriginalData_DataRequest_2015to2023"
do "$DoFiles/02_HI_OriginalData_DataRequest_2024"

* End of HI Cleaning
