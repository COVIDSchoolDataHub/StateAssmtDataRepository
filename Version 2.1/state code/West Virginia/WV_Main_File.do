*******************************************************
* WEST VIRGINIA

* File name: WV_Main_File
* Last update: 2/22/2025

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

global DoFiles "/Users/miramehta/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/West Virginia" 
cd "/Users/miramehta/Documents/West Virginia"

*NCES Folders*
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCES_Dist "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_clean "/Users/miramehta/Documents/West Virginia/NCES_Clean" //This will start empty and will hold the WV-specific NCES files.

*Student Count Folders*
global edfacts "/Users/miramehta/Documents/EDFacts" //This should contain the wide .csv versions of the files, with subfolders for each year from 2015-2021.
global counts "/Users/miramehta/Documents/West Virginia/Counts" //This will start empty and will hold the files with students counts ready to be merged in.

*Input Folder*
global data "/Users/miramehta/Documents/West Virginia/Original Data Files"

*Output Folder*
global output "/Users/miramehta/Documents/West Virginia/Output" //Usual output exported. 

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
*Add newer years in order.*
do "${DoFiles}/01_WV_Student_Counts.do"
do "${DoFiles}/02_WV_EDFacts_22_24.do" 
do "${DoFiles}/03_WV_ParticipationRate_18_24.do"
do "${DoFiles}/04_WV_2015.do"
do "${DoFiles}/05_WV_2016.do" 
do "${DoFiles}/06_WV_2017.do"
do "${DoFiles}/07_WV_2018.do"
do "${DoFiles}/08_WV_2019.do" 
do "${DoFiles}/09_WV_2021.do"
do "${DoFiles}/10_WV_2022.do"
do "${DoFiles}/11_WV_2023.do"
do "${DoFiles}/12_WV_2024.do"

* END of WV_Main_File.do 
****************************************************
