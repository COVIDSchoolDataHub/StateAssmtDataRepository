
# Idaho Data Cleaning

This is a ReadMe for Idahos's data cleaning process, from 2016 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/26/2025, the most recent files are from NCES 2022. 

## Setup

Create a folder for ID. Inside that folder, create the following subfolders:
      
      1. Original Data Files: Download the *entire* folder from Google Drive --> Idaho --> ID Original Data 
      
      Place all the files (out of their subfolders) in the Original Data Files. 
      
         a. Cleaned DTA [subfolder]
         
      2. Temp
         
      3. NCES_ID [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output.

## Process
    Place all do files in the ID folder.
    
    Set the appropriate file paths in ID_Main_File.do
    
    Running ID_Main_File.do will execute all the do files in order.

## Updates
- 02/08/2025: Updated to add formatting across files. Header was added to 2024 but was not otherwise updated.
- 09/07/2024: Updated to include 2024 data as well as to address new conventions and review standards in version 2.0 (including deriving additional counts based on percentages and StudentSubGroup_TotalTested).
- 02/26/2025: Modified to create non-derivation output. 
