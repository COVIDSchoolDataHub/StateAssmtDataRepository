*CONNECTICUT
*File name: CT_Main_File
*Last update: 2/11/2025

clear 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Connecticut/"
global Temp "C:/Zelma/Connecticut/Temp" 

*NCES and EDFacts Folders*
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_State "C:/Zelma/Connecticut/NCES_CT" 
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (2021 only) downloaded from Google Drive. Code to convert .csv to .dta commented out. 

*Input Folders*
global Original "C:/Zelma/Connecticut/Original Data Files"

*Output Folder*
global Output "C:/Zelma/Connecticut/Output"

*Non Derivation Output Folder*
global Output_ND "C:/Zelma/Connecticut/Output_ND" //No Derivation Output

*Run in this order*
do "${DoFiles}/01_CT_Cleaning.do" 
do "${DoFiles}/02_CT_Cleaning_2021.do" //Code at the start needs to unhidden on first run
do "${DoFiles}/03_CT_2021_EDFACTS.do" 

* END of CT_Main_File.do 
****************************************************
