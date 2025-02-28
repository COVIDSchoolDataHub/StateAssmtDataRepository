
# Wisconsin Data Cleaning

This is a ReadMe for Wisconsin's data cleaning process, from 2016 to 2024, excluding 2020.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/28/2025, the most recent files are from NCES 2022. 

## Setup

Create a folder for WI. Inside that folder, create the following subfolders:
      
      1. Original Data Files: Download all *.csv files from Google Drive --> Wisconsin --> WI Original Data Files
      
      Place them in the Original Data Files folder. 

         a. DTA [subfolder] 
         
      2. Temp
         
      3. NCES_WI [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output.

## Process
    Place all do files in the WI folder.
    
    Set the appropriate file paths in WI_Main_File.do
    
    Running WI_Main_File.do will execute all the do files in order.
