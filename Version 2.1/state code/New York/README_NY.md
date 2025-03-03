
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

1. Original Data Files: Download the following subfolders from Google Drive --> New York --> NY Original Data Files.

      i) 2006-2018
   
      ii) 2019-2024

   Place these files in the Original Data Files folder on your local drive.

   a. DTA [subfolder]: Will start empty.
             
3. Temp: Currently not in use. 
         
4. NCES_NY [will start empty] : Currently not in use. 
      
5. EDFacts_NY [will start empty]
      
6. Output_Files
      
7. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the NY folder.
        
    Set the appropriate file paths in NY_Main_File.do
        
    Running NY_Main_File.do will execute all the do files in order.

## Updates
11/23/24: Updated to include 2024 data and match V2.0 StudentGroup_TotalTested convention.

03/03/25: Updated to add headers, footers, and notes. Code modified to export non-derivation output. Error resolved in 2006-2017.do.
