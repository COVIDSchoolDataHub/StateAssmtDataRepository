# Ohio Data Cleaning

This is a ReadMe for Ohio's data cleaning process, from 2016 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/11/2025, the most recent files are from NCES 2022. 

## Ohio Setup
  Create a folder for OH. Inside that folder, create the following subfolders:
  
    1. Original Data Files: Download all files from Google Drive --> Ohio --> OH Original Data Files --> OH - V2.0+ (2016-2024 Received via DR 9-25-24).

         Place all files in the Original Data Files folder.
         
         a) DTA [subfolder]
                      
    2. Temp  
             
    3. NCES_OH
                   
    4. Output_Files
          
    5. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the OH folder.
        
    Set the appropriate file paths in OH_Main_File.do
        
    Running OH_Main_File.do will execute all the do files in order.

# Updates

10/23/24: Original cleaning (with files from DR received 9/25/24 for V2.0).

12/04/24: Updated to aggregate information for schools listed in multiple districts in raw data to one observation with NCES listed district.

03/11/25: Updated code to standardize it and create non-derivation output. OH Importing Raw Data.do was updated with the new file names. 
