* NEW YORK
*File name: NY_Main_File 
*Last update: 03/03/2025

*******************************************************
* Notes

* Place all do files in the NY folder.
    
* Set the appropriate file paths in NY_Main_File.do
    
* Running NY_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2018 to 2024, excluding 2020.
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/New York/" 
global Temp "C:/Zelma/New York/Temp" //This will start empty. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive. 
global EDFacts_NY "C:/Zelma/New York/EDFacts_NY" //This will start empty and will hold the NY-specific EDFacts files. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_NY "C:/Zelma/New York/NCES_NY" //This will start empty and will hold the NY-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/New York/Original Data Files"
global Original_1 "C:/Zelma/New York/Original Data Files/2006-2018" 
global Original_2 "$Original/2019-2024" //Update this folder name as newer data becomes available. 
global Original_DTA "C:/Zelma/New York/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/New York/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/New York/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
do "${DoFiles}/Combining 2006-2017.do"
do "${DoFiles}/2006-2017.do"
// Update end year when newer do files are created. 
forvalues year = 2018/2024 {
if `year' == 2020 continue
do "${DoFiles}/`year'.do"
}
do "${DoFiles}/NY_EDFactsParticipation_2014_2019.do"
* END of NY_Main_File.do
****************************************************
