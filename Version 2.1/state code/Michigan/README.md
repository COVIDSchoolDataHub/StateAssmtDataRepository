
# Michigan Data Cleaning

This is a ReadMe for Michigan's data cleaning process, from 2015 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/07/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## Michigan Setup
  Create a folder for MI. Inside that folder, create the following subfolders:
  
    1. Original Data Files: Download from Google Drive --> Michigan --> MI Original Data Files.
    
       i) All files [Place these files in the Original Data Files folder]
       
       ii) Download the ED Data Express folder [Place this folder in Original Data Files]

       From Google Drive --> Michigan, download and place within the Original Data Files folder on your drive. 

       i) MI_Unmerged_2024.xlsx

       ii) MI_NCESUpdates_2018_2024.xlsx

      You should have two subfolders in the Original Data Files folder on your drive.
       
         a) DTA [subfolder]
      
         b) ED Data Express [subfolder]: This is downloaded from the Original Data Files folder.
                 
    2. Temp:  
             
    3. NCES_MI 
          
    4. EDFacts_MI 
          
    5. Output_Files
          
    6. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the MI folder.
        
    Set the appropriate file paths in MI_Main_File.do
        
    Running MI_Main_File.do will execute all the do files in order.

## Updates

02/28/2024: Updated new StudentGroup/StudentSubGroup labels; merged in 2022 NCES data for 2023 (with the exception of DistType, DistLocale, CountyCode, CountyName which were retrieved from 2021 files); New variable order/sort; New flag variables; Variable type conversion.

05/13/2024: Updated NCES data with new data files, including for 2023.

07/12/2024: Updated files for V2.0 to include ParticipationRate. Reorganized Count Generation.

09/09/2024: Added 2024 data, included additional derivations, applied StudentGroup_TotalTested convention across years.

03/07/2025: Updated code to standardize it and create non-derivation output. 
