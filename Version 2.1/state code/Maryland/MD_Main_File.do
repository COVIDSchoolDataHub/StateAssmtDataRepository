* MARYLAND
* File name: MD_Main_File 
* Last update: 03/14/2025

*******************************************************
* Notes 

* Place all do files in the MD folder.
    
* Set the appropriate file paths in MD_Main_File.do
    
* Running MD_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2015-2024.
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Maryland" 
global Temp "C:/Zelma/Maryland/Temp" //This will start empty. 

*EDFacts Folders [Unused]
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
global ED_Express  "C:/Zelma/Maryland/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Express.
global EDFacts_MD "C:/Zelma/Maryland/EDFacts_MD" //This will start empty and will hold the MD-specific EDFacts files. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_MD "C:/Zelma/Maryland/NCES_MD" //This will start empty and will hold the MD-specific NCES files.

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Maryland/Original Data Files" 
global Original_DTA "C:/Zelma/Maryland/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/Maryland/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Maryland/Output_Files_ND" //Non Derivation Output. 

// Run in this order.
do "${DoFiles}/MD_NCES.do"
forvalues year = 2015/2024{
	if `year' == 2020 continue
	do "${DoFiles}/MD_`year'.do"
	}
do "${DoFiles}/MD_EDFactsParticipation_2015_2021.do"
do "${DoFiles}/MD_EDFactsParticipationRate_2022.do"
* END of MD_Main_File.do
****************************************************
