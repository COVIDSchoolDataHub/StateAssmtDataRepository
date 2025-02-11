* TENNESSEE
*File name: TN_Main_File 
*Last update: 2/10/2025

clear 
set excelxlsxlargefile on
set more off
set trace off

global DoFiles "C:/Zelma/Tennessee/" 
global NCES_District "C:/Zelma/NCES_Files/NCES District Files, Fall 1997-Fall 2022"
global NCES_School "C:/Zelma/NCES_Files/NCES School Files, Fall 1997-Fall 2022"
global NCES_TN "C:/Zelma/Tennessee/NCES"

*Input folders*
global Original "C:/Zelma/Tennessee/Original Data Files" //Original Data Files downloaded from Google Drive.
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive. Code to convert .csv to .dta commented out. 

*Output folders*
global Output "C:/Zelma/Tennessee/Output_Files" // Version 2.1 Output directory here.
global Stable_Output "C:/Zelma/Tennessee/Output_Files/Stable_Names_Output" // Version 2.1 Output with Stable Names.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Tennessee/Output_Files_ND" //Non Derivation Output. 
global Stable_Output_ND "C:/Zelma/Tennessee/Output_Files_ND/Stable_Names_Output_ND" // Non Derivation Output with Stable Names.

*Run in this order.*
do "${DoFiles}/01_TN_NCES.do" 
do "${DoFiles}/02_TN_DTA_Conversion.do" 
do "${DoFiles}/03_TN_Cleaning_2010_2015.do"
do "${DoFiles}/04_TN_Cleaning_2017_2024.do"
do "${DoFiles}/05_TN_EDFactsParticipationRate_2014_2015_2017_2018.do" 
do "${DoFiles}/06_TN_StableNames.do"
****************************************************
