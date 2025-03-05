* NORTH CAROLINA
* File name: NC_Main_File 
* Last update: 03/05/2025

*******************************************************
* Notes

* Place all do files in the NC folder.
    
* Set the appropriate file paths in NC_Main_File.do
    
* Running NC_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2014-2024.
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/North Carolina/" 
global Temp "C:/Zelma/North Carolina/Temp" //This will start empty. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive. 
global EDFacts_NC "C:/Zelma/North Carolina/EDFacts_NC" //This will start empty and will hold the NC-specific EDFacts files. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_NC "C:/Zelma/North Carolina/NCES_NC" //This will start empty and will hold the NC-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/North Carolina/Original Data Files"
global Original_DTA "C:/Zelma/North Carolina/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/North Carolina/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/North Carolina/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
do "${DoFiles}/NC_NCES.do"
do "${DoFiles}/nc_do.do"
do "${DoFiles}/nc_do_ND.do"
do "${DoFiles}/NC_2024.do"
do "${DoFiles}/NC_EDFactsParticipation_2014_2021.do"
do "${DoFiles}/NC_EDFactsParticipation_2022.do"
* END of NC_Main_File.do
****************************************************
