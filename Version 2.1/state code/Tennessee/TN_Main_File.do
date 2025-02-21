*******************************************************
* TENNESSEE

* File name: TN_Main_File
* Last update: 2/21/2025

*******************************************************
* Notes
    	* Place all do files in the TN folder.
        * Set the appropriate file paths in TN_Main_File.do
	* The cd path should be updated in the other TN do files prior to running this TN_Main_File.
	* Global macros can be updated in this do file.
	* This will be the only .do file needed to run through all state files in the proper order.
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear 
set excelxlsxlargefile on
set more off
set trace off

global DoFiles "C:\Users\Clare\Desktop\Zelma V2.1\Tennessee" 
global NCES_District "C:\Users\Clare\Desktop\NCES_full\NCES District Files"
global NCES_School "C:\Users\Clare\Desktop\NCES_full\NCES School Files"
global NCES_TN "C:\Users\Clare\Desktop\Zelma V2.1\Tennessee\NCES_TN"

*Input folders*
global Original "C:\Users\Clare\Desktop\Zelma V2.1\Tennessee\Original Data" //Original Data Files downloaded from Google Drive.
global EDFacts "C:\Users\Clare\Desktop\EDFacts" //EDFacts Datasets (wide version) downloaded from Google Drive. Code to convert .csv to .dta commented out. 

*Output folders*
global Output "C:\Users\Clare\Desktop\Zelma V2.1\Tennessee\Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:\Users\Clare\Desktop\Zelma V2.1\Tennessee\Output_Files_ND" //Non Derivation Output. 

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
do "${DoFiles}/01_TN_NCES.do" 
do "${DoFiles}/02_TN_DTA_Conversion.do" 
do "${DoFiles}/03_TN_Cleaning_2010_2015.do"
do "${DoFiles}/04_TN_Cleaning_2017_2024.do"
do "${DoFiles}/05_TN_EDFactsParticipationRate_2014_2015_2017_2018.do" 
do "${DoFiles}/06_TN_StableNames.do"
****************************************************

*End of TN_Main_File
