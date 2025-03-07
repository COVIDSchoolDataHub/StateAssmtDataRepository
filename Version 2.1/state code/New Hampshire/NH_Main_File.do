* NEW HAMPSHIRE
* File name: NH_Main_File 
* Last update: 03/07/2025

*******************************************************
* Notes 

* Place all do files in the NH folder.
    
* Set the appropriate file paths in NH_Main_File.do
    
* Running NH_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2009-2024.
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/New Hampshire/" 
global Temp "C:/Zelma/New Hampshire/Temp" //This will start empty. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
//global ED_Express  "C:/Zelma/New Hampshire/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Express
global EDFacts_NH "C:/Zelma/New Hampshire/EDFacts_NH" //This will start empty and will hold the NH-specific EDFacts files. 

*NHES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_NH "C:/Zelma/New Hampshire/NCES_NH" //This will start empty and will hold the NH-specific NHES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/New Hampshire/Original Data Files"
global Original_DTA "C:/Zelma/New Hampshire/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/New Hampshire/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/New Hampshire/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
do "${DoFiles}/NH_Cleaning.do"
do "${DoFiles}/NH_Cleaning_ND.do"
do "${DoFiles}/NH_EDFactsParticipationRate_2014_2018.do"
* END of NH_Main_File.do
****************************************************
