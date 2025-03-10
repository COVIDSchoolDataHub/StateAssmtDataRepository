* NEW JERSEY
* File name: NJ_Main_File 
* Last update: 03/10/2025

*******************************************************
* Notes 

* Place all do files in the NJ folder.
    
* Set the appropriate file paths in NJ_Main_File.do
    
* Running NJ_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2015-2024 (excluding 2020, 2021).
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/New Jersey/" 
global Temp "C:/Zelma/New Jersey/Temp" //This will start empty. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
global ED_Express  "C:/Zelma/New Jersey/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Exprss
global EDFacts_NJ "C:/Zelma/New Jersey/EDFacts_NJ" //This will start empty and will hold the NJ-specific EDFacts files. 

*NJES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_NJ "C:/Zelma/New Jersey/NCES_NJ" //This will start empty and will hold the NJ-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/New Jersey/Original Data Files"
global Original_DTA "C:/Zelma/New Jersey/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/New Jersey/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/New Jersey/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
do "${DoFiles}/NJ Cleaning 2015_2018.do"
do "${DoFiles}/NJ Cleaning 2019_2023.do"
do "${DoFiles}/NJ_2024.do"
do "${DoFiles}/NJ_EDFactsParticipation_2015_2021.do"
do "${DoFiles}/NJ_EDFactsParticipation_2022.do"
* END of NJ_Main_File.do
****************************************************
