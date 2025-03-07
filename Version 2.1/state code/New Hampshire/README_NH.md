
# New Hampshire Data Cleaning

This is a ReadMe for New Hampshire's data cleaning process, from 2009 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/07/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## New Hampshire Setup
  Create a folder for NH. Inside that folder, create the following subfolders:
  
    1. Original Data Files: Download from **all** files Google Drive --> New Hampshire --> NH Original Data Files.
    
       i)  NH_OriginalData_G38_Dist.xlsx [Download this file from NH Original Data Files --> Received Gr3-8 aggregated district data via data request subfolder.]
       
      You should have one subfolder in the Original Data Files folder on your drive.
       
         a) DTA [subfolder]
                      
    2. Temp:  
             
    3. NCES_NH [Not in use] 
          
    4. EDFacts_NH 
          
    5. Output_Files
          
    6. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the NH folder.
        
    Set the appropriate file paths in NH_Main_File.do
        
    Running NH_Main_File.do will execute all the do files in order.

## Updates

11/05/2024: Updated to include 2024 data, derive additional values, and match v2.0 StudentGroup_TotalTested convention.

12/06/2024: Updated to derive more specific values for ranges (per Stanford feedback).

03/07/2025: Updated code to standardize it and create non-derivation output.
