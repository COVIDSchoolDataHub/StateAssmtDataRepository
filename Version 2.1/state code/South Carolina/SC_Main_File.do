* SOUTH CAROLINA
* File name: SC_Main_File 
* Last update: 03/11/2025

*******************************************************
* Notes 

* Place all do files in the SC folder.
    
* Set the appropriate file paths in SC_Main_File.do
    
* Running SC_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2016-2024 (excluding 2020).
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/South Carolina" 
global Temp "C:/Zelma/South Carolina/Temp" //This will start empty. 

*EDFacts Folders* 
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
global ED_Express  "C:/Zelma/South Carolina/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Express
global EDFacts_SC "C:/Zelma/South Carolina/EDFacts_SC" //This will start empty and will hold the SC-specific EDFacts files. 

*SCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_SC "C:/Zelma/South Carolina/NCES_SC" //This will start empty and will hold the SC-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/South Carolina/Original Data Files"
global Original_DTA "C:/Zelma/South Carolina/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/South Carolina/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/South Carolina/Output_Files_ND" //Non Derivation Output. 

// Run in this order.
do "${DoFiles}/SC_Do_File.do"
do "${DoFiles}/SC_EDFactsParticipationRate_2016_2021.do"
do "${DoFiles}/SC_EDFactsParticipationRate_2022.do"
* END of SC_Main_File.do
****************************************************
