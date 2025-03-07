* MICHIGAN
* File name: MI_Main_File 
* Last update: 03/07/2025

*******************************************************
* Notes 

* Place all do files in the MI folder.
    
* Set the appropriate file paths in MI_Main_File.do
    
* Running MI_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2015-2024.
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Michigan/" 
global Temp "C:/Zelma/Michigan/Temp" //This will start empty. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
global ED_Express  "C:/Zelma/Michigan/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Exprss
global EDFacts_MI "C:/Zelma/Michigan/EDFacts_MI" //This will start empty and will hold the MI-specific EDFacts files. 

*MIES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_MI "C:/Zelma/Michigan/NCES_MI" //This will start empty and will hold the MI-specific MIES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Michigan/Original Data Files"
global Original_DTA "C:/Zelma/Michigan/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/Michigan/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Michigan/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
do "${DoFiles}/Michigan DTA Conversion.do"
do "${DoFiles}/Michigan NCES Cleaning.do"
forval year = 2015/2024 {
if `year' == 2020 continue
do "${DoFiles}/Michigan `year' Cleaning.do"
} 
do "${DoFiles}/MI_EDFactsParticipation_2015_2021.do"
do "${DoFiles}/MI_EDFactsParticipation_2022.do"
* END of MI_Main_File.do
****************************************************
