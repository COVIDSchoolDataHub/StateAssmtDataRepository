*CONNECTICUT
*File name:
*Last update: 2/4/2025

clear 
*Check each do file for the working directory*

global DoFiles "C:/Zelma/2025-01-27/"
global Original "C:/Zelma/2025-01-27/Original Data Files"
global Output "C:/Zelma/2025-01-27/Output"
global Output_ND "C:/Zelma/2025-01-27/Output_ND" //No Derivation Output
global Temp "C:/Zelma/2025-01-27/Temp" 
global NCES_School "C:/Zelma/2025-01-27/NCES/School"
global NCES_District "C:/Zelma/2025-01-27/NCES/District"
global EDFacts "C:/Zelma/2025-01-27/EDFacts" //Folder with downloaded state-specific 2022 participation data from EDFacts

*Run in this order*
do "${DoFiles}/01_CT_Cleaning.do"
do "${DoFiles}/02_CT_Cleaning_2021.do" //Code at the start needs to unhidden on first run
do "${DoFiles}/03_CT_2021_EDFACTS.do"

****************************************************
