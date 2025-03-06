
# North Dakota Data Cleaning

This is a ReadMe for North Dakota's data cleaning process, from 2015 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 03/05/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## North Dakota Setup
Create a folder for ND. Inside that folder, create the following subfolders:

1. Original Data Files: Download the **entire** folder and subfolders from Google Drive --> North Dakota --> ND Original Data Files.

   Place these files and subfolders in the ND Original Data Files folder.

   Retain the same subfolder structure. 
 
   a) DTA [subfolder]

   b) ED Data Express [subfolder]: This is downloaded from the Original Data Files folder.
             
2. Temp:  
         
3. NCES_ND 
      
4. EDFacts_ND 
      
5. Output_Files
      
6. Output_Files_ND: This is a folder for the non-derivation output.

# Process
    Place all do files in the ND folder.
        
    Set the appropriate file paths in ND_Main_File.do
        
    Running ND_Main_File.do will execute all the do files in order.

## Updates

04/11/2024: Updated output files to incorporate new EDFacts files for 2022 and 2023, derived new student subgroups, and incorporated new NCES variables.

06/17/2024: Updated 2015 Flag_AssmtNameChange for math and ela to "Y". Updated StudentGroup_TotalTested to reflect the all students count for 2022 & 2023, and derived StudentSubGroup_TotalTested based on this value. This was done through an additional do-file, "North Dakota_StateTasks_Jun24". In the future, these changes should be made directly to the yearly do-files, but it is being uploaded separately for now as a stop-gap measure to get V1.1 out. 

09/24/2024: Incorporated 06/17/2024 updates in yearly do-files and added file to clean 2024 data.  Updated ND Student Counts 22-24 file to match new format of downloaded edfacts data.

03/05/2025: Updated code to standardize it and create non-derivation output. Also modified ND Cleaning 2022.do, ND Cleaning 2023.do, and ND Cleaning 2024.do to use the ED Data Express file downloaded on 3/5/25. 
