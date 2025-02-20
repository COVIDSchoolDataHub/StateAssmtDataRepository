* ARIZONA
*File name: AZ_Main_File 
*Last update: 2/20/2025

clear 
set excelxlsxlargefile on 
set more off
set trace off
cap log close

global DoFiles "C:/Zelma/Arizona/" 
global Temp "C:/Zelma/Arizona/Temp" //This will start empty. 

*NCES Folders*
global NCES_District "C:/Zelma/NCES_Full/NCES District Files"
global NCES_School "C:/Zelma/NCES_Full/NCES School Files"
global NCES_AZ "C:/Zelma/Arizona/NCES_AZ" //This will start empty and will hold the AZ-specific NCES files. 

*EDFacts Folders*
global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive. 
global EDFacts_AZ "C:/Zelma/Arizona/EDFacts_AZ" //This will start empty and will hold the AZ-specific EDFacts files. 

*Input folders* //Original Data Files downloaded from Google Drive.
global Original "C:/Zelma/Arizona/Original Data Files" 
global AIMS "C:/Zelma/Arizona/Original Data Files/AIMS" 
global AzMERIT "C:/Zelma/Arizona/Original Data Files/AzM2-AzMERIT + AIMS Science"
global AzSci "C:/Zelma/Arizona/Original Data Files/AzSci"
global AASA "C:/Zelma/Arizona/Original Data Files/AASA"

*Output folders*
global Output "C:/Zelma/Arizona/Output_Files" // Version 2.1 Output directory here.

*Non Derivation Output Folders*
global Output_ND "C:/Zelma/Arizona/Output_Files_ND" //Non Derivation Output. 

// Run in this order.*
// do "${DoFiles}/01_NCES_clean copy.do"
// do "${DoFiles}/02_AZ EDFacts.do"
do "${DoFiles}/03_AIMS_all_clean_2010.do"
do "${DoFiles}/04_AIMS_all_clean_2011.do"
do "${DoFiles}/05_AIMS_all_clean_2012.do"
do "${DoFiles}/06_AIMS_all_clean_2013.do"
do "${DoFiles}/07_AIMS_all_clean_2014.do"
do "${DoFiles}/08_AzMerit_clean_2015.do"
do "${DoFiles}/09_AzMerit_clean_2016.do"
do "${DoFiles}/10_AzMerit_clean_2017.do"
do "${DoFiles}/11_AzMerit_clean_2018.do"
do "${DoFiles}/12_AzMerit_clean_2019.do"
do "${DoFiles}/13_AzM2_clean_2021.do"
do "${DoFiles}/14_AASA_clean_2022.do"
do "${DoFiles}/15_AASA_clean_2023.do"
do "${DoFiles}/16_AASA_clean_2024.do"
do "${DoFiles}/17_AZ_EDFactsParticipation_2014_2021.do"
do "${DoFiles}/18_AZ_EDFactsParticipation_2022.do"
* END of AZ_Main_File.do 
****************************************************
