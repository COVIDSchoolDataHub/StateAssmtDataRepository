* INDIANA
*File name: IN_Main_File 
*Last update: 2/13/2025

clear 
set excelxlsxlargefile on 
set more off
set trace off

global DoFiles "C:/Zelma/Indiana/" 
global Temp "C:/Zelma/Indiana/Temp"

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_IN "C:/Zelma/Indiana/NCES_IN" //This will start empty and will hold the IN-specific NCES files. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive. Code to convert .csv to .dta commented out. 
global EDFacts_IN "C:/Zelma/Indiana/EDFacts_IN" //This will start empty and will hold the IN-specific EDFacts files. 

*Input folders*
global Original "C:/Zelma/Indiana/Original Data Files" //Original Data Files downloaded from Google Drive.

*Output folders*
global Output "C:/Zelma/Indiana/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Indiana/Output_Files_ND" //Non Derivation Output. 

// Run in this order.*
do "${DoFiles}/01_IN_NCES.do" 
do "${DoFiles}/02_IN_Importing_sci_soc.do" 
do "${DoFiles}/03_IN_Importing.do" 
do "${DoFiles}/04_IN_Cleaning.do"
do "${DoFiles}/05_IN_EDFactsParticipation_2014_2021.do"
do "${DoFiles}/06_IN_EDFactsParticipation_2022.do" 
* END of IN_Main_File.do 
****************************************************
