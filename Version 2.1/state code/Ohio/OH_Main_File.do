* OHIO
* File name: OH_Main_File 
* Last update: 03/11/2025

*******************************************************
* Notes 

* Place all do files in the OH folder.
    
* Set the appropriate file paths in OH_Main_File.do
    
* Running OH_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2016-2024 (excluding 2020).
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Ohio" 
global Temp "C:/Zelma/Ohio/Temp" //This will start empty. 

*EDFacts Folders* [UNUSED]
//global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
//global ED_Express  "C:/Zelma/Ohio/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Express
//global EDFacts_OH "C:/Zelma/Ohio/EDFacts_OH" //This will start empty and will hold the OH-specific EDFacts files. 

*OHES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_OH "C:/Zelma/Ohio/NCES_OH" //This will start empty and will hold the OH-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Ohio/Original Data Files"
global Original_DTA "C:/Zelma/Ohio/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/Ohio/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Ohio/Output_Files_ND" //Non Derivation Output. 

// Run in this order.
do "${DoFiles}/OH Importing Raw Data.do"
forval year = 2016/2024{
if `year' == 2020 continue
do "${DoFiles}/OH `year' Cleaning.do"
}
* END of OH_Main_File.do
****************************************************
