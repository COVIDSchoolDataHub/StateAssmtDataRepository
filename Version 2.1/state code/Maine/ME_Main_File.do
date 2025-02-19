*******************************************************
* MAINE

* File name: ME_Main_File
* Last update: 2/18/2025

*******************************************************
* Notes

  * For 2015-2023, there are two versions of the original files, the "true" original data, and the files in the "Separated by year" folder on Drive. This file assumes that the files separated by year have been downloaded into the origianl data. However, "Splitting by year.do" can be used to conver the "true" original data to this same format.
  * Global macros can be updated in this do file.
  * This will be the only .do file needed to run through all state files in the proper order.
*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear 

global DoFiles "/Users/miramehta/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/Maine"" 

*NCES Folders*
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"

*Input Folder*
global Original "/Users/miramehta/Documents/Maine/Original" //Save files all original data files into this folder.

*Output Folder*
global Output "/Users/miramehta/Documents/Maine/Output" //Usual output exported. 

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
*Add newer years in order.*
do "${DoFiles}/01_ME_Cleaning_2015.do" //Uncommented code to import csv files for the first time. 
do "${DoFiles}/02_ME_Cleaning_2016-2019.do" //Uncommented code to import csv files for the first time. 
do "${DoFiles}/03_ME_Cleaning_2021-2022.do" //Uncommented code to import csv files for the first time. 
do "${DoFiles}/04_ME_Cleaning_2023.do" //Uncommented code to import csv files for the first time.
do "${DoFiles}/05_ME_DataRequest_2015_2023.do"
do "${DoFiles}/06_ME_Final Cleaning_2015_2023.do"
do "${DoFiles}/07_ME_2024_DataRequest_01.16.25"

//Uncommented code to import csv files for the first time. 

* END of ME_Main_File.do 
****************************************************
