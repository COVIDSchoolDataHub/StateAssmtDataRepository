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

global DoFiles "C:/Zelma/California/" 
global Temp "C:/Zelma/California/Temp" //This will start empty and store 2019-2024 (excluding 2020) ELA + Math and Science output until appended. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_CA "C:/Zelma/California/NCES_CA" //This will start empty and will hold the CA-specific NCES files. 

*Input folders*
global Original "C:/Zelma/California/Original Data Files" //Original Data Files downloaded from Google Drive.
global Original_Cleaned "C:/Zelma/California/Original Data Files/Cleaned DTA" //This will start empty. 

*Output folders*
global Output "C:/Zelma/California/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/California/Output_Files_ND" //Non Derivation Output. 

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
