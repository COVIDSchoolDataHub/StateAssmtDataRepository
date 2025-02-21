# Tennessee Data Cleaning

This is a ReadMe for TN's cleaning process from 2012-2024 (excluding 2016).

## NCES Setup

NCES_Full: Download the folder from NCES District and School Demographics in the _Data Cleaning Materials folder in Google Drive and set up the following subfolders.
    
   a. NCES District Files [subfolder] 

   b. NCES School Files [subfolder]
   
## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. This is in the _EDFacts folder in _Data Cleaning Materials in Google Drive. There will be individual folders for each year.

## Tennessee Setup
Create a folder for TN. Inside that folder, create the following subfolders:

1. Original Data Files
   
   a. Download the Original Data Files from the Tennessee folder in Google Drive. There are no subfolders.
   
   b. Also save TN_Unmerged_2024.xlsx in this folder [This file is located in the TN ID notes folder in the Tennessee folder in Google Drive.]
   
2. NCES_TN [will start empty]
   
3. Output_Files

   a. Temp [subfolder]
   b. Final [subfolder]
  
4. Output_Files_ND. This is a folder for the non-derivation output.

   a. Temp [subfolder]
   b. Final_ND [subfolder]. This is a folder for the final non-derivation output.

## Process
    Place all do files in the TN folder.
        
    Set the appropriate file paths in TN_Main_File.do

    The cd path should be updated in the other TN do files prior to running the TN_Main_File.
        
    Running TN_Main_File.do will execute all the do files in order.
