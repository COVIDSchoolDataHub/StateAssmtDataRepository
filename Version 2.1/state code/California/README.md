
# California Data Cleaning

This is a ReadMe for California's data cleaning process, from 2010 to 2024 (with the exception of 2014 and 2020).

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/18/2025, the most recent files are from NCES 2022. 

## Setup

Create a folder for CA. Inside that folder, create the following subfolders:
      
      1. Original Data Files: Download all files from Google Drive --> California --> Original Data Files. 
      Place within the Original Data Files folder.
      
      Additionally, download the following files and place them in the Original Data Files.
      They are located in Google Drive --> California.
      
              i) CA_DistSchInfo_2010_2024.xlsx   
              ii) CA_Unmerged_2024.xlsx 
              iii) CA_2024_Updates.xlsx
        
         a. Cleaned DTA [subfolder]
         
      2. Temp
         
      3. NCES_CA [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output.

## Process
The do files need to be executed in the following order.

1. 01_california_dta_conversion.do;

2. 02_CA_NCES_New.do;

3. california_year_clean.do; [year = 2010/2024, excluding 2014 and 2020]

4. california_Science_2019_2024.do;

## Updates

- 03/10/2024: Responded to first round of 2024 data update review comments.
- 06/11/2024: Moved to new NCES files for all years and updated unmerged observations. Added new code to deal with additional unmerged observations.
- 6/15/24: Fixed mismatched ID's for all years.
- 6/27/24 Incorporated science data for 2019-2023.
- 11/10/24: Incorporated 2024, streamlined all do-files, redid nces merging by using crosswalk/dealt with mismatched dist and sch ids, brought state up to V2.0 conventions
- 02/18/25: Modified code to export non-derivation output. Added headers, footers, and notes in each do file. 
