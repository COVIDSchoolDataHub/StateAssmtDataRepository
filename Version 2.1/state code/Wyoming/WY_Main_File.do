*******************************************************
* WYOMING

* File name: WY_Main_File
* Last update: 2/26/2025

*******************************************************
* Notes

  * Global macros can be updated in this do file.
  * This will be the only .do file needed to run through all state files in the proper order.
*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear
set more off

global DoFiles "/Users/miramehta/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/Wyoming" 

*NCES Folders*
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data" //This will start empty and will hold the WV-specific NCES files.

*EDFacts Folders*
global EDFacts "/Users/miramehta/Documents/EDFacts"

*Input Folder*
global Original "/Users/miramehta/Documents/Wyoming/Original"

*Output Folder*
global Output "/Users/miramehta/Documents/Wyoming/Output" //Usual output exported. 

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
*Add newer years in order.*
do "${DoFiles}/01_WY_Reg_Alt.do" //contains notes for code to be hidden after first run
do "${DoFiles}/02_WY_Reg.do" //contains notes for code to be hidden after first run
do "${DoFiles}/03_WY_EDFacts_14_21.do" //contains notes for code to be hidden after first run
do "${DoFiles}/04_WY_EDFacts_2022.do" //contains notes for code to be hidden after first run

* END of WY_Main_File.do 
****************************************************
