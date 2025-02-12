*******************************************************
* TEXAS

* File name: TX_Main_File
* Last update: 2/11/2025

*******************************************************
* Notes

  * The TX data has two versions of files for 2012 through 2021 - full files and REDUCED files. This code executes on the REDUCED 2012 through 2021 files.
  * The code to reduce the full files is on GitHub - TX Original File Importing & Reduction.do.  
  * Global macros can be updated in this do file.
  * This will be the only .do file needed to run through all state files in the proper order.
*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear 

global DoFiles "C:/Zelma/Texas/" 
global temp_files "C:/Zelma/Texas/Temp_Files" 

*NCES Folders*
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_State "C:/Zelma/Texas/NCES_TX" //This will start empty and will hold the TX-specific NCES files. 

*Input Folders*
global original_files "C:/Zelma/Texas/Original_Files" // Save files from 2022, 2023 and 2024 subfolders into this folder.
global original_reduced "C:/Zelma/Texas/Original_Files/Reduced Files" //Store files from "2012 to 2021, non-scraped, REDUCED files".

*Output Folder*
global output_files "C:/Zelma/Texas/Output_Files" //Usual output exported. 

*Non Derivation Output Folder*
global output_ND "C:/Zelma/Texas/Output_Files_ND" //Non derivation output. As of last update, no non-derivation output needs to be created for TX.

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
*Add newer years in order.*
do "${DoFiles}/TX_2012.do"
do "${DoFiles}/TX_2013.do" 
do "${DoFiles}/TX_2014.do"
do "${DoFiles}/TX_2015.do"
do "${DoFiles}/TX_2016.do" 
do "${DoFiles}/TX_2017.do"
do "${DoFiles}/TX_2018.do"
do "${DoFiles}/TX_2019.do" 
do "${DoFiles}/TX_2021.do"
do "${DoFiles}/TX_2022.do" //Uncommented code to import csv files for the first time. 
do "${DoFiles}/TX_2023.do" //Uncommented code to import csv files for the first time. 
do "${DoFiles}/TX_2024.do" //Uncommented code to import csv files for the first time. 

* END of TX_Main_File.do 
****************************************************
