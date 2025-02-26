* COLORADO
*File name: CO_Main_File 
*Last update: 2/25/2025

*******************************************************
* Notes

* Place all do files in the CO folder.
    
* Set the appropriate file paths in CO_Main_File.do
    
* Running CO_Main_File.do will execute all the do files in order.

* The non-derivation output is only created for 2015 and 2022.
*******************************************************

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Colorado/" 
global Temp "C:/Zelma/Colorado/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_CO "C:/Zelma/Colorado/NCES_CO" //This will start empty and will hold the CO-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Colorado/Original Data Files" 
global Original_Cleaned "C:/Zelma/Colorado/Original Data Files/Cleaned DTA" 

*Output folders*
global Output "C:/Zelma/Colorado/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Colorado/Output_Files_ND" //Non Derivation Output. Only for 2015 and 2022.

// Run in this order. 
do "${DoFiles}/Colorado NCES Cleaning.do"
forval year = 2015/2024 {
	if `year' == 2020 continue
	if `year' == 2023 {
	do "${DoFiles}/Colorado DTA Conversion.do"
	do "${DoFiles}/CO_2023.do"
	}
	do "${DoFiles}/CO_`year'.do"
	}
* END of CO_Main_File.do 
****************************************************
