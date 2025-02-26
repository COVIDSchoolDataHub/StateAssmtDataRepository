* Delaware
*File name: DE_Main_File 
*Last update: 2/26/2025

*******************************************************
* Notes

* Place all do files in the DE folder.
    
* Set the appropriate file paths in DE_Main_File.do
    
* Running DE_Main_File.do will execute all the do files in order.

* Only the usual output is created. 
*******************************************************

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Delaware/" 
global Temp "C:/Zelma/Delaware/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_DE "C:/Zelma/Delaware/NCES_DE" //This will start empty and will hold the DE-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Delaware/Original Data Files" 
global Original_Cleaned "C:/Zelma/Delaware/Original Data Files/Cleaned DTA" 

*Output folders*
global Output "C:/Zelma/Delaware/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Delaware/Output_Files_ND" //Non Derivation Output. None created for DE as of 2/26/25.

// Run in this order. e
do "${DoFiles}/NCES_Clean_DE.do"
forval year = 2015/2024 {
	if `year' == 2020 continue
	do "${DoFiles}/DE Cleaning `year'.do"
	}
do "${DoFiles}/DE_sci_soc_2015-17.do"
* END of DE_Main_File.do 
****************************************************
