## North Carolina Cleaning ReadMe
This is a ReadMe for North Carolina's data cleaning process, from 2014 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/05/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## North Carolina Setup
Create a folder for NC. Inside that folder, create the following subfolders:

1. Original Data Files: Download the following files from Google Drive --> North Carolina --> NC Original Data Files.

   Place these files in the Original Data Files folder. 

         i) Disag_*.txt files (10 files)
   
         ii) missing_nc.csv
   
         iii) NC_district_IDs_2024.dta
   
         iv) NC_EFParticipation_2022_*.xlsx (3 files)
   
         v) nc_full-dist-sch-stable-list_through2023.dta
   
   a) DTA [subfolder]
             
2. Temp:  
         
3. NCES_NC [subfolder]
      
4. EDFacts_NC [subfolder]
      
5. Output_Files
      
6. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the NC folder.
        
    Set the appropriate file paths in NC_Main_File.do
        
    Running NC_Main_File.do will execute all the do files in order.
    
## Updates
12/06/2024: Updated to derive additional values.

03/05/2024: Updated to standardize code and to create non-derivation output. New do file created for 2014-2023 non-derivation output. Errors fixed in nc_do.do.
