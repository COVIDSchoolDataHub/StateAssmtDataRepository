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

1. Original Data Files.
   a. Download the Original Data Files from the Tennessee folder in Google Drive. There are no subfolders.
   b. Also save TN_Unmerged_2024.xlsx in this folder [This file is located in the TN ID notes folder in the Tennessee folder in Google Drive.]
   
3. NCES_TN [will start empty]
   
4. Output_Files

   a. Temp [subfolder]
   b. Final [subfolder]
  
5. Output_Files_ND. This is a folder for the non-derivation output.

   a. Temp [subfolder]
   b. Final_ND [subfolder]. This is a folder for the final non-derivation output.

## Process
The TN_Main_File will execute the following TN .do files. Before running TN_Main_File, you will need to update the cd file path in each .do file, and all of the paths in TN_Main_File.

01_TN_NCES.do

02_TN_DTA_Conversion.do

03_TN_Cleaning_2010_2014.do

04_TN_Cleaning_2017_2024.do

05_TN_EDFactsParticipationRate.do

06_TN_StableNames.do
