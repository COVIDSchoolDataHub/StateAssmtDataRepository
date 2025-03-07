* ILLINOIS
* File name: IL_Main_File 
* Last update: 03/06/2025

*******************************************************
* Notes 

* Place all do files in the IL folder.
    
* Set the appropriate file paths in IL_Main_File.do
    
* Running IL_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2015-2024. 
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Illinois/" 
global Temp "C:/Zelma/Illinois/Temp" //This will start empty. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
global ED_Express  "C:/Zelma/Illinois/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Exprss
global EDFacts_IL "C:/Zelma/Illinois/EDFacts_IL" //This will start empty and will hold the IL-specific EDFacts files. 

*ILES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_IL "C:/Zelma/Illinois/NCES_IL" //This will start empty and will hold the IL-specific ILES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Illinois/Original Data Files"
global Original_DTA "C:/Zelma/Illinois/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/Illinois/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Illinois/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
do "${DoFiles}/Illinois DTA Conversion.do"
do "${DoFiles}/Illinois Cleaning Merge Files.do"
forval year = 2015/2024 {
if `year' == 2020 continue
do "${DoFiles}/Illinois `year' Cleaning.do"
} 
* END of IL_Main_File.do
****************************************************
