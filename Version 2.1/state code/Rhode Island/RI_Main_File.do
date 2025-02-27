* RHODE ISLAND
*File name: RI_Main_File 
*Last update: 2/27/2025

*******************************************************
* Notes

* Place all do files in the RI folder.
    
* Set the appropriate file paths in RI_Main_File.do
    
* Running RI_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2018 to 2024, excluding 2020.
*******************************************************
clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Rhode Island/" 
global Temp "C:/Zelma/Rhode Island/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_RI "C:/Zelma/Rhode Island/NCES_RI" //This will start empty and will hold the RI-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Rhode Island/Original Data Files" 
global Original_DTA "C:/Zelma/Rhode Island/Original Data Files/DTA" //Change here. 

*Output folders*
global Output "C:/Zelma/Rhode Island/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Rhode Island/Output_Files_ND" //Non Derivation Output.

// Run in this order. 
do "${DoFiles}/RI_NCES.do"
do "${DoFiles}/RI_Data_Conversion.do" 
do "${DoFiles}/RI_Cleaning_2018_2024.do" 
* END of RI_Main_File.do
****************************************************
