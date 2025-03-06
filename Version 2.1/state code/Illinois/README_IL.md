
# Illinois Data Cleaning

This is a ReadMe for Illinois's data cleaning process, from 2015 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/06/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## Illinois Setup
  Create a folder for IL. Inside that folder, create the following subfolders:
  
    1. Original Data Files: Download from Google Drive --> Illinois --> IL Original Data Files.
    
       i) All files [Place these files in Original Data Files folder]
       
       ii) Download the ED Data Express folder [Place this folder in Original Data Files]
    
      You should have two subfolders in the Original Data Files folder on your drive.
       
         a) DTA [subfolder]
      
         b) ED Data Express [subfolder]: This is downloaded from the Original Data Files folder.
                 
    2. Temp:  
             
    3. NCES_IL 
          
    4. EDFacts_IL 
          
    5. Output_Files
          
    6. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the IL folder.
        
    Set the appropriate file paths in IL_Main_File.do
        
    Running IL_Main_File.do will execute all the do files in order.

## Updates

02/12/2025: Updated to include 2024 sci data from data request.

03/06/2025: Updated code to standardize it and create non-derivation output. 
