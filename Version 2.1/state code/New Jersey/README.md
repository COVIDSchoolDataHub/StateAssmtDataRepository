
# New Jersey Data Cleaning

This is a ReadMe for New Jersey's data cleaning process, from 2015 to 2024.
* Note that 2020 and 2021 are excluded, as NJ did not administer spring tests during those years due to COVID.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/10/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## New Jersey Setup
  Create a folder for NJ. Inside that folder, create the following subfolders:
  
    1. Original Data Files: Download the **entire** folder from Google Drive --> New Jersey --> NJ Original Data Files.

      Retain the folder structure and do **NOT** extract the files from their folders.

      You should have on your local drive, the following folders:
          
         a) DTA [subfolder]

         b) ED Data Express [subfolder]

         c) Individual year subfolders (2015-2024, excluding 2020 and 2022).
                      
    2. Temp  
             
    3. NCES_NJ 
          
    4. EDFacts_NJ 
          
    5. Output_Files: This should have a subfolder called HMH, where output with alternate IDs for HMH will be saved.
          
    6. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the NJ folder.
        
    Set the appropriate file paths in NJ_Main_File.do
        
    Running NJ_Main_File.do will execute all the do files in order.

## Updates
04/23/2024: Updated to add in unmerged NCES information and match new StudentGroup_TotalTested convention.

12/14/2024: Updated to add in new StudentGroup_TotalTested derivation and 2024 data.

03/10/2025: Updated code to standardize it and create non-derivation output.

03/11/2025: Updated to create an alternate output for HMH (retaining State_leaid & seasch), create unique school IDs, and update derivation for ProficientOrAbove_count.
