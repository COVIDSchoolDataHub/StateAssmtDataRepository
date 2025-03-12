* OKLAHOMA
* File name: OK_Main_File 
* Last update: 03/12/2025

*******************************************************
* Notes 

* Place all do files in the OK folder.
    
* Set the appropriate file paths in OK_Main_File.do
    
* Running OK_Main_File.do will execute all the do files in order.

* Non-derivation output is created for 2016-2023 (excluding 2020).
*******************************************************

*To use labmask, uncomment the below code to install.*
*ssc install labutil

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Oklahoma" 
global Temp "C:/Zelma/Oklahoma/Temp" //This will start empty. 

*EDFacts Folders [Unused]
// global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
// global ED_Express  "C:/Zelma/Oklahoma/Original Data Files/ED Data Express" //2022 onwards files downloaded from ED Data Express
// global EDFacts_OK "C:/Zelma/Oklahoma/EDFacts_OK" //This will start empty and will hold the OK-specific EDFacts files. 

*OKES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_OK "C:/Zelma/Oklahoma/NCES_OK" //This will start empty and will hold the OK-specific NCES files. 

*Input folders* //Original Data Files downloaded from Google Drive.
// global Original "C:/Zelma/Oklahoma/Original Data Files" //Unused.
global Org_PubAvail "C:/Zelma/Oklahoma/Original Data Files/Publicly Available Data Files"
global Org_17_23 "C:/Zelma/Oklahoma/Original Data Files/OK ELA, Math Sci Assmt Data (2017-2023) Received via Data Request - 4-25-24"
global Org_24 "C:/Zelma/Oklahoma/Original Data Files/OK ELA, Math, Sci Assmt Data (2024) Received via Data Request - 11-10-24"
global Original_DTA "C:/Zelma/Oklahoma/Original Data Files/DTA"

*Output folders*
global Output "C:/Zelma/Oklahoma/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Oklahoma/Output_Files_ND" //Non Derivation Output. 

// Run in this order.
do "${DoFiles}/Oklahoma DTA Conversion.do"
do "${DoFiles}/Oklahoma NCES Cleaning.do"
do "${DoFiles}/Oklahoma Cleaning 2017-2023.do"
do "${DoFiles}/Oklahoma Cleaning 2024.do"
* END of OK_Main_File.do
****************************************************
