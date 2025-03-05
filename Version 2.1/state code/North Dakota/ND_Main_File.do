* NORTH DAKOTA
* File name: ND_Main_File 
* Last update: 03/05/2025

*******************************************************
* Notes

* Place all do files in the ND folder.
    
* Set the appropriate file paths in ND_Main_File.do
    
* Running ND_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2014-2024.
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/North Dakota/" 
global Temp "C:/Zelma/North Dakota/Temp" //This will start empty. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
global ED_Express  "C:/Zelma/North Dakota/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Exprss
global EDFacts_ND "C:/Zelma/North Dakota/EDFacts_ND" //This will start empty and will hold the ND-specific EDFacts files. 

*NDES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_ND "C:/Zelma/North Dakota/NCES_ND" //This will start empty and will hold the ND-specific NDES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/North Dakota/Original Data Files"
global Original_DTA "C:/Zelma/North Dakota/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/North Dakota/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/North Dakota/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
do "${DoFiles}/ND Student Counts 15-21.do"
do "${DoFiles}/ND Student Counts 22-24.do"
forval year = 2015/2024 {
if `year' == 2020 continue
do "${DoFiles}/ND Cleaning `year'.do"
} 
* END of ND_Main_File.do
****************************************************
