*TEXAS
*File name: TX_Main_File 
*Last update: 2/6/2025

*Note: The TX data has two versions of files for 2012 through 2021 - full files and REDUCED files. 
*This code executes on the REDUCED files.
*The code to reduce the full files is on GitHub. 

clear 

global DoFiles "C:/Zelma/Texas/" 
global original_files "C:/Zelma/Texas/Original_Files" // Save files from 2022, 2023 and 2024 subfolders into this folder.
global original_reduced "C:/Zelma/Texas/Original_Files/Reduced Files" //Store files from "2012 to 2021, non-scraped, REDUCED files".
global NCES_files "C:/Zelma/NCES_Files" 
global output_files "C:/Zelma/Texas/Output_Files" //Usual output exported. 
global output_ND "C:/Zelma/Texas/Output_Files_ND" //Non derivation output. As of last update, no non-derivation output needs to be created for TX.
global temp_files "C:/Zelma/Texas/Temp_Files" 

*Run in this order. Add newer years in order.*
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
****************************************************
