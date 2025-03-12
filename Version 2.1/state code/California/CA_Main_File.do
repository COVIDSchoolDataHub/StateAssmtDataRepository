* CALIFORNIA
*File name: CA_Main_File 
*Last update: 2/21/2025

*Place all do files in the CA folder.
    
*Set the appropriate file paths in CA_Main_File.do
    
*Running CA_Main_File.do will execute all the do files in order.

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "/Users/joshuasilverman/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/California" 
global Temp "/Volumes/T7/State Test Project/California/Temp" //This will start empty and store 2019-2024 (excluding 2020) ELA + Math and Science output until appended. 

*NCES Folders*
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_CA "/Volumes/T7/State Test Project/California/NCES" //This will start empty and will hold the CA-specific NCES files. 

*Input folders*
global Original "/Volumes/T7/State Test Project/California/Original Data Files" //Original Data Files downloaded from Google Drive.
global Original_Cleaned "/Volumes/T7/State Test Project/California/Cleaned DTA" //This will start empty. 

*Output folders*
global Output "/Volumes/T7/State Test Project/California/Output" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "/Volumes/T7/State Test Project/California/Output ND" //Non Derivation Output. 

// Run in this order.*
do "${DoFiles}/01_california_dta_conversion.do" 
do "${DoFiles}/02_CA_NCES_New.do" 
do "${DoFiles}/california_2010_clean.do"
do "${DoFiles}/california_2011_clean.do"
do "${DoFiles}/california_2012_clean.do"
do "${DoFiles}/california_2013_clean.do"
do "${DoFiles}/california_2015_clean.do"
do "${DoFiles}/california_2016_clean.do"
do "${DoFiles}/california_2017_clean.do"
do "${DoFiles}/california_2017_clean.do"
do "${DoFiles}/california_2018_clean.do"
do "${DoFiles}/california_2019_clean.do"
do "${DoFiles}/california_2021_clean.do"
do "${DoFiles}/california_2022_clean.do"
do "${DoFiles}/california_2023_clean.do"
do "${DoFiles}/california_2024_clean.do"
do "${DoFiles}/california_Science_2019_2024.do"
* END of CA_Main_File.do 
****************************************************
