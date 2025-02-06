# Texas Data Cleaning

This is a ReadMe for Texas's data cleaning process, from 2012 to 2024.

## Setup

Create a folder for TX. Create five folder and subfolders. 

1. Original_Files: Download the files from the 2022, 2023, and 2024 subfolders in the Original Data Folder on Google Drive.
  
   a. Reduced_Files [subfolder]: Download all reduced files from "2012 to 2021, non-scraped, REDUCED files" located in the Original Data Folder on Google Drive. 

2.  Output_Files
   
3.  Output_Files_ND [This is a folder for the non-derivation output.]
  
4. Temp_Files
 
5.  "NCES_files" with these additional subfolders:
  
         a. NCES District Files, Fall 1997-Fall 2022
    
         b. NCES School Files, Fall 1997-Fall 2022
    
         c. Cleaned NCES Data

## Download the following .do files.
1. TX_Main_File.do
2. TX_2012.do
3. TX_2013.do
4. TX_2014.do
5. TX_2015.do
6. TX_2016.do
7. TX_2017.do
8. TX_2018.do
9. TX_2019.do
10. TX_2021.do
11. TX_2022.do
12. TX_2023.do
13. TX_2024.do

Update the file path in the TX_Main_File.do. Run the TX_Main_File which execute the do files in order.

## Recreate Cleaning/ Creating the reduced files

1. Download the full files from the "2012 to 2021, non-scraped, full files" folder. 
2. Store them in the Original_Files folder created in the Setup section.
3. Download the TX Original File Importing & Reduction.do file. Update the file path and run the code. 

## Updates
10/17/24: Updated to include 2024 data, clean prior years using the csv version of the file instead of the .sas version (for easier Stata processing) and standardize district names to match 2024.

10/24/24: Updated to use new 2022 and 2023 files which include data for Spanish version of the test.

11/17/24: Updated to pull in district names from NCES (for standardization).

2/6/2025: Code modified to run on reduced files. Comments and header added. Non-derivation output code added and commented out. 
