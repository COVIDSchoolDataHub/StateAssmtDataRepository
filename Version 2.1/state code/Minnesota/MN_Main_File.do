* MINNESOTA
*File name: MN_Main_File 
*Last update: 2/24/2025

*******************************************************
* Notes

* Place all do files in the MN folder.
    
*Set the appropriate file paths in MN_Main_File.do
    
* Running MN_Main_File.do will execute all the do files in order.

* The non-derivation output is only created for 2014-2022. 
*******************************************************

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Minnesota/" 
global Temp "C:/Zelma/Minnesota/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_MN "C:/Zelma/Minnesota/NCES_MN" //Currently not in use. This will start empty and will hold the MN-specific NCES files. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive. 
global EDFacts_MN "C:/Zelma/Minnesota/EDFacts_MN" //This will start empty and will hold the MN-specific EDFacts files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Minnesota/Original Data Files" 
global Original_Cleaned "C:/Zelma/Minnesota/Original Data Files/Cleaned DTA" 
global Stable "C:/Zelma/Minnesota/Original Data Files/MN Stable Dist and Sch Names" //Stable Dist and Sch Names folder downloaded from Google Drive. 

*Output folders*
global Output "C:/Zelma/Minnesota/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Minnesota/Output_Files_ND" //Non Derivation Output. 

// Run in this order. 
forval year = 1998/2024 {
	if `year' == 2020 continue
	do "${DoFiles}/MN_`year'.do"
}
do "${DoFiles}/MN_StableNames.do"
do "${DoFiles}/MN_EDFactsParticipationRate_2014_2021.do"
do "${DoFiles}/MN_EDFactsParticipationRate_2022.do"
* END of MN_Main_File.do 
****************************************************
