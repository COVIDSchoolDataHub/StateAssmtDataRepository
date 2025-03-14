# South Dakota Cleaning

This ReadMe outlines South Dakota's cleaning process, from 2003 to 2024

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/14/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## South Dakota Setup
Create a folder for SD. Inside that folder, create the following subfolders:

1. Original Data Files: Download all files from Google Drive --> South Dakota --> SD Original Data Files --> Files currently used.

   Place these files in the SD Original Data Files folder.

   a) DTA [subfolder]
            
2. Temp:  
             
3. EDFacts_SD 
      
4. Output_Files
      
5. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the SD folder.
        
    Set the appropriate file paths in SD_Main_File.do
        
    Running SD_Main_File.do will execute all the do files in order.

## Updates
- 11/20/24: Cleaned SD 2024, brought prior years up to Version 2.0 standards and completed self review. Created ReadMe.

- 12/3/24: recleaned 2015-2017 based on data request data, incorporated edfacts counts for 2015-2018, responded to V2.0 R1

- 03/14/25: Updated code to standardize it and create non-derivation output.
