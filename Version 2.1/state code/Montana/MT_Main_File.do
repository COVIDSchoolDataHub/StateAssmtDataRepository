*******************************************************
* MONTANA

* File name: MT_Main_File
* Last update: 03/06/2025

*******************************************************
* Notes

  * Global macros can be updated in this do file.
  * This will be the only .do file needed to run through all state files in the proper order.
  * You will need to install the filelist package if you do not have it already.  You can do so by unhiding the code below.
  *ssc install filelist

*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear
set more off

global DoFiles "/Users/miramehta/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/Montana" 

*NCES Folders*
global NCES_Dist "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCES_MT "/Users/miramehta/Documents/Montana/NCES" //This will start empty and will hold the MT-specific NCES files.

*Input Folders*
global Original "/Users/miramehta/Documents/Montana/Original"
global ELA_Math "/Users/miramehta/Documents/Montana/Original/District-level ELA and math downloads"
global Sci "/Users/miramehta/Documents/Montana/Original/District-level science downloads"

*Output Folder*
global Output "/Users/miramehta/Documents/Montana/Output" //Usual output exported. 

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
*Add newer years in order.*
do "${DoFiles}/01_MT_NCES.do"
do "${DoFiles}/02_MT_School_Cleaning.do"
do "${DoFiles}/03_MT_District_Cleaning.do" //contains notes for code to be hidden after first run
do "${DoFiles}/04_MT_State_Cleaning.do" //contains notes for code to be hidden after first run.

* END of MT_Main_File.do 
****************************************************
