# Massachusetts ReadMe
This ReadMe describes Massachusetts' cleaning process, from 2010-2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/27/2025, the most recent files are from NCES 2022. 

## Setup

Create a folder for MA. Inside that folder, create the following subfolders:
      
      1. Original Data Files: Download the *entire* folder from Google Drive --> Massachusetts --> MA Original Data Files - Version 2.0
      
      Also, download the following files and place them in the Original Data Files.
      
      i) ma_full-dist-sch-stable-list_through2024.xlsx [Google Drive --> Massachusetts --> MA Dist Names]

      ii) MA_Unmerged_2024.xlsx [Google Drive --> Massachusetts --> MA Unmerged]

      Place all the files (out of their subfolders) in the Original Data Files. 
      
         a. DTA [subfolder]
         
      2. Temp
         
      3. NCES_MA [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output.

## Process
    Place all do files in the MA folder.
    
    Set the appropriate file paths in MA_Main_File.do
    
    Running MA_Main_File.do will execute all the do files in order.

## Notes & Updates
- When 2024 data is released, the code only needs to be modified slightly so that the loops include 2024, since the data will be in the same format as the data we currently have.
- 9/26/24: 2024 added
- 10/9/2024: Stabilized DistNames & SchNames
- 10/13/2024: Completely recleaned 2010-2016 for V2.0. Modified entire cleaning structure (including 2017-2024) for simplicity.
- 02/27/2025: Standardized code. Fixed error in MA_2010_2014.do.
