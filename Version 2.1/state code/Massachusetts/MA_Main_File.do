* MASSACHUSETTS
*File name: MA_Main_File 
*Last update: 2/27/2025

*******************************************************
* Notes

* Place all do files in the MA folder.
    
* Set the appropriate file paths in MA_Main_File.do
    
* Running MA_Main_File.do will execute all the do files in order.

* Only the usual output is created. 
*******************************************************
clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Massachusetts/" 
global Temp "C:/Zelma/Massachusetts/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_MA "C:/Zelma/Massachusetts/NCES_MA" //This will start empty and will hold the MA-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Massachusetts/Original Data Files" 
global Original_DTA "C:/Zelma/Massachusetts/Original Data Files/DTA" //Change here. 

*Output folders*
global Output "C:/Zelma/Massachusetts/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Massachusetts/Output_Files_ND" //Non Derivation Output. None created. 

// Run in this order. 
do "${DoFiles}/MA Data Conversion.do" 
do "${DoFiles}/MA_NCES_New.do" 
do "${DoFiles}/MA_2010_2014.do"
do "${DoFiles}/MA_2015_2016.do" 
do "${DoFiles}/MA_2017_2024.do" 
do "${DoFiles}/MA ParticipationRate.do" 
* END of MA_Main_File.do
****************************************************
