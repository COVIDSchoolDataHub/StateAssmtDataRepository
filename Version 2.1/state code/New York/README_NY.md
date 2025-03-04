
# New York Data Cleaning

This is a ReadMe for New York's data cleaning process, from 2006 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/03/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## New York Setup
Create a folder for NY. Inside that folder, create the following subfolders:

1. Original Data Files: Download the **entire**  Combined .dta files folder from Google Drive --> New York --> NY Original Data Files.

   Place this folder in the Original Data Files.

       a) 2006-2018 [subfolder]: Use **only** if creating combined files.

       b) 2019-2024 [subfolder]: Use **only** if creating combined files.

       c) Combined .dta files [subfolder]: 
             
4. Temp: Currently not in use. 
         
5. NCES_NY [will start empty] : Currently not in use. 
      
6. EDFacts_NY [will start empty]
      
7. Output_Files
      
8. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the NY folder.
        
    Set the appropriate file paths in NY_Main_File.do
        
    Running NY_Main_File.do will execute all the do files in order.

## Recreate Cleaning/ Creating the combined files
A change from the previous version is usage of only "combined files". 

These files are created from the following zipped folders in Google Drive --> New York --> NY Original Data Files.

    i) 2006-2018

    ii) 2019-2024 (update folder name as newer files are added)

Instead of using numerous txt files, the combined files are used since they are faster to process.

    1. Download the txt files as noted above.
    
    2. Store them in the Original Data Files folder. Retain the same folder structure. 

    3. In the Setup section of the NY_Main_File.do, 

        i) Original_1 refers to the 2006-2018 folder

        ii) Original_2 refers to the 2019-2024 folder (update folder name as newer files are added)
    
    4. The do files that create the combined files are:

        i) Combining 2006-2017.do

        ii) Combining 2018-onwards.do

        These do files have been commented out in the NY_Main_File.do

## Updates
11/23/24: Updated to include 2024 data and match V2.0 StudentGroup_TotalTested convention.

03/03/25: Updated to add headers, footers, and notes. Code modified to export non-derivation output. Error resolved in 2006-2017.do.

03/04/25: Updated code to use combined files. Created new do file to combine 2018-2024 txt files. Added code to create combined files for 2019-2024. 
