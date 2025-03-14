* SOUTH DAKOTA
* File name: SD_Main_File 
* Last update: 03/12/2025

*******************************************************
* Notes 

* Place all do files in the SD folder.
    
* Set the appropriate file paths in SD_Main_File.do
    
* Running SD_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2003-2023 (excluding 2020).
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/South Dakota" 
global Temp "C:/Zelma/South Dakota/Temp" //This will start empty. 

*EDFacts Folders [Unused]
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
// global ED_Express  "C:/Zelma/South Dakota/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Express. [Unused]
global EDFacts_SD "C:/Zelma/South Dakota/EDFacts_SD" //This will start empty and will hold the SD-specific EDFacts files. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
// global NCES_SD "C:/Zelma/South Dakota/NCES_SD" //This will start empty and will hold the SD-specific NCES files. [Unused]

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/South Dakota/Original Data Files" 
global Original_DTA "C:/Zelma/South Dakota/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/South Dakota/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/South Dakota/Output_Files_ND" //Non Derivation Output. 

// Run in this order.
do "${DoFiles}/SD_2003_2013.do"
do "${DoFiles}/SD_2014.do"
do "${DoFiles}/SD_2015_2017.do"
do "${DoFiles}/SD_2018_2023.do"
do "${DoFiles}/SD_2024.do"
do "${DoFiles}/SD_EDFacts_2015_2018.do"
* END of SD_Main_File.do
****************************************************
