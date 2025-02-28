* WISCONSIN

*File name: WI_Main_File 
*Last update: 2/28/2025

*******************************************************
* Notes

* Place all do files in the WI folder.
    
* Set the appropriate file paths in WI_Main_File.do
    
* Running WI_Main_File.do will execute all the do files in order.

* Only the usual output is created. 
*******************************************************
clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Wisconsin/" 
global Temp "C:/Zelma/Wisconsin/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_WI "C:/Zelma/Wisconsin/NCES_WI" //This will start empty and will hold the WI-specific NCES files. [Unused]

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Wisconsin/Original Data Files" 
global Original_DTA "C:/Zelma/Wisconsin/Original Data Files/DTA" //Change here. 

*Output folders*
global Output "C:/Zelma/Wisconsin/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Wisconsin/Output_Files_ND" //Non Derivation Output. No non-derivation output for 2016-2024.

// Run in this order. 
forval year = 2016/2024 {
	if `year' == 2020 continue
	do "${DoFiles}/WI_`year'.do"
}
* END of WI_Main_File.do
****************************************************
