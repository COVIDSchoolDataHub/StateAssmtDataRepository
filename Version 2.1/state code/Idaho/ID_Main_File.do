* IDAHO
*File name: ID_Main_File 
*Last update: 2/26/2025

*******************************************************
* Notes

* Place all do files in the ID folder.
    
* Set the appropriate file paths in ID_Main_File.do
    
* Running ID_Main_File.do will execute all the do files in order.

* The non-derivation output is created for 2016 - 2023
*******************************************************
clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Idaho/" 
global Temp "C:/Zelma/Idaho/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_ID "C:/Zelma/Idaho/NCES_ID" //This will start empty and will hold the ID-specific NCES files. As of 2/26/25, folder not in use. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Idaho/Original Data Files" 
global Original_Cleaned "C:/Zelma/Idaho/Original Data Files/Cleaned DTA" 

*Output folders*
global Output "C:/Zelma/Idaho/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Idaho/Output_Files_ND" //Non Derivation Output. Created for 2016 - 2023.

// Run in this order. 
*Add newer years in order.*
do "${DoFiles}/01_ID_DataRequest_2016.do" 
do "${DoFiles}/02_ID_DataRequest_2017.do" 
do "${DoFiles}/03_ID_DataRequest_2018.do" 
do "${DoFiles}/04_ID_DataRequest_2019.do" 
do "${DoFiles}/05_ID_DataRequest_2021.do" 
do "${DoFiles}/06_ID_DataRequest_2022.do" 
do "${DoFiles}/07_ID_DataRequest_2023.do" 
do "${DoFiles}/08_ID_DataCleanPublic_2024.do" 
****************************************************
