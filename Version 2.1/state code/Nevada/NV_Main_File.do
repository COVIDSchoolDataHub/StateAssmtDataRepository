* NEVADA
*File name: NV_Main_File 
*Last update: 2/28/2025

*******************************************************
* Notes

* Place all do files in the NV folder.
    
* Set the appropriate file paths in NV_Main_File.do
    
* Running NV_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2016 to 2024, excluding 2020.
*******************************************************
clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Nevada/" 
global Temp "C:/Zelma/Nevada/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_NV "C:/Zelma/Nevada/NCES_NV" //This will start empty and will hold the NV-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Nevada/Original Data Files" 

*Output folders*
global Output "C:/Zelma/Nevada/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Nevada/Output_Files_ND" //Non Derivation Output.

// Run in this order. 
do "${DoFiles}/Nevada Data Conversion.do"
do "${DoFiles}/Nevada NCES Cleaning.do" 
forval year = 2016/2024 {
	if `year' == 2020 continue
	do "${DoFiles}/Nevada `year' Cleaning.do"
}
* END of NV_Main_File.do
****************************************************
