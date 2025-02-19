* LOUISIANA
*File name: LA_Main_File 
*Last update: 2/19/2025

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Louisiana/" 
global Temp "C:/Zelma/Louisiana/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_LA "C:/Zelma/Louisiana/NCES_LA" //This will start empty and will hold the LA-specific NCES files. 

*Input folders*
global Original "C:/Zelma/Louisiana/Original Data Files" //Original Data Files downloaded from Google Drive.

*Output folders*
global Output "C:/Zelma/Louisiana/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Louisiana/Output_Files_ND" //Non Derivation Output. 

// Run in this order.*
do "${DoFiles}/LA_2015_SepData.do"
do "${DoFiles}/LA_2016_SepData.do"
do "${DoFiles}/LA_2017_SepData.do"
do "${DoFiles}/LA_2018_SepData.do"
do "${DoFiles}/LA_2019_SepData.do"
do "${DoFiles}/LA_2021_SepData.do"
do "${DoFiles}/LA_2022_SepData.do"
do "${DoFiles}/LA_2023_SepData.do"
do "${DoFiles}/LA_2024_SepData.do"
* END of LA_Main_File.do 
****************************************************
