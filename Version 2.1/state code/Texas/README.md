# Texas Data Cleaning

This is a ReadMe for Texas's data cleaning process, from 2012 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/11/2025, the most recent files are from NCES 2022. 

## Texas Setup
Create a folder for TX. Inside that folder, create the following subfolders:

    1. Original_Files: Download the files within the 2022, 2023, and 2024 subfolders and place them all in the Original_Files folder. These files are located in the Original Data Folder on Google Drive. 
    
      a. Reduced_Files [subfolder]: Download all reduced files from "2012 to 2021, non-scraped, REDUCED files" located in the Original Data Folder on Google Drive. 
    
    2. NCES_TX [will start empty]
     
    3. Output_Files: This folder includes the usual and HMH output.
       
    4. Output_Files_ND: This is a folder for the non-derivation output.
      
    5. Temp_Files 

## Process
    Place all do files in the TX folder.
    
    Set the appropriate file paths in TX_Main_File.do
    
    Running TX_Main_File.do will execute all the do files in order.

## Recreate Cleaning/ Creating the reduced files
A change from the previous version is the creation of "reduced files". These files are created from the "full files". 

In the full files, several variables are dropped and data are reshaped from wide to long to create the reduced files.

The variable list for the full files can be found in fy22_varlist.xlsx.

This file is located on the Google Drive --> Texas --> Original Data Files --> TX varlist. 

    1. Download the full files from the "2012 to 2021, non-scraped, full files" folder. 
    
    2. Store them in the Original_Files folder created in the Setup section.
    
    3. Download the TX Original File Importing & Reduction.do file. Update the file path and run the code. 

## Updates
10/17/24: Updated to include 2024 data, clean prior years using the csv version of the file instead of the .sas version (for easier Stata processing) and standardize district names to match 2024.

10/24/24: Updated to use new 2022 and 2023 files which include data for Spanish version of the test.

11/17/24: Updated to pull in district names from NCES (for standardization).

2/6/2025: Code modified to run on reduced files. Comments and header added. Non-derivation output code added and commented out. 

2/11/2015: Code modified to reflect changes in NCES folder structure. 
