
# Nevada Data Cleaning

This is a ReadMe for Nevada's data cleaning process, from 2016 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/28/2025, the most recent files are from NCES 2022. 

## Setup

Create a folder for NV. Inside that folder, create the following subfolders:
      
      1. Original Data Files: Download all subfolders from Google Drive --> Nevada --> NV Original Data --> NV Original Data Files - Version 1.1+

      Retain the same folder structure, so there will be two subfolders:

          a. ELA & Math [subfolder]

          b. Sci [subfolder]
               
      2. Temp
         
      3. NCES_NV [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output.

## Process
    Place all do files in the NV folder.
    
    Set the appropriate file paths in NV_Main_File.do
    
    Running NV_Main_File.do will execute all the do files in order.
    
## Updates

05/21/2024: Incorporated StudentSubGroup by GradeLevel data and updated new StudentSubGroup labels, new variable order, and new flag variables.

10/29/2024: Cleaned 2024 data, derived additional values for StudentSubGroup_TotalTested as well as level and ProficientOrAbove counts/percents,
and updated to match V2.0 StudentGroup_TotalTested convention.

02/28/2025: Modified code to export non-derivation output. Added headers, footers, and notes in each do file. 
