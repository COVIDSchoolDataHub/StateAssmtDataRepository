* IOWA
*File name: IA_Main_File 
*Last update: 2/28/2025

*******************************************************
* Notes

* Place all do files in the IA folder.
    
* Set the appropriate file paths in IA_Main_File.do
    
* Running IA_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2016 to 2024, excluding 2020.
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Iowa/" 
global Temp "C:/Zelma/Iowa/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_IA "C:/Zelma/Iowa/NCES_IA" //This will start empty and will hold the IA-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Iowa/Original Data Files" 
global Original_Pre "C:/Zelma/Iowa/Original Data Files/2014 and Previous Files" 
global Original_Post "C:/Zelma/Iowa/Original Data Files/2015 and Post Files" 
global Stable "C:/Zelma/Iowa/Original Data Files/Stable Dist and Sch Names" 
global Original_DTA "C:/Zelma/Iowa/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/Iowa/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Iowa/Output_Files_ND" //Non Derivation Output. [Not in use.]

// Run in this order. 
do "${DoFiles}/01_Iowa_NCES_clean.do"
do "${DoFiles}/02_IA_clean_preNCES.do"
do "${DoFiles}/03_IA_NCES merging.do"
do "${DoFiles}/04_IA_Final Cleaning.do"
* END of IA_Main_File.do
****************************************************
