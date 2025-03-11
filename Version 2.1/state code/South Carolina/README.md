
# South Carolina Data Cleaning

This is a ReadMe for South Carolina's data cleaning process, from Spring 2016 to Spring 2024. 

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/11/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## South Carolina Setup
  Create a folder for SC. Inside that folder, create the following subfolders:
  
    1. Original Data Files: Download the **entire** folder from Google Drive --> South Carolina --> SC Original Data Files.

      Retain the folder structure and do **NOT** extract the files from their folders.
     
      You should have on your local drive, the following folders:
          
         a) DTA [subfolder]

         b) ED Data Express [subfolder]

     All the files should be placed in the Original Data Files folder. 
                        
    2. Temp  
             
    3. NCES_SC
          
    4. EDFacts_SC 
          
    5. Output_Files
          
    6. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the SC folder.
        
    Set the appropriate file paths in SC_Main_File.do
        
    Running SC_Main_File.do will execute all the do files in order.

## Updates

03/29/2024: Made 2024 updates.

06/17/24: Made changes based on state tasks. Changes should be implemented to the main cleaning file in the future, but currently separate for timing reasons.

07/16/24: Incorporated EDFacts Participation Data.

07/26/24: Updated Flags.

08/09/24: Incorporated State Task form 6/17/24 into main do-file

03/11/25: Updated code to standardize it and create non-derivation output.
