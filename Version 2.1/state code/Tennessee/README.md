# Tennessee Data Cleaning

This is a ReadMe for TN's cleaning process from 2012-2024 (excluding 2016).

## Setup
Create a folder for TN. Inside that folder, create the following subfolders:
1. NCES [Download the folder from NCES District and School Demographics in the _Data Cleaning Materials folder in Google Drive.]
    
   a. NCES District Files, Fall 1997-Fall 2022 [subfolder] 

   b. NCES School Files, Fall 1997-Fall 2022 [subfolder]
   
3. Original Data Files: Download the Original Data Files from the Tennessee folder in Google Drive.
   
4. Output_Files

   a. Stable_Names_Output [subfolder] [This is a folder for stable names output.]

   b. Output - Version 1.1 [subfolder] [Download all files from the Output - Version 1.1 from the Tennessee folder in Google Drive.]
   
6. Output_Files_ND [This is a folder for the non-derivation output.]

   a. Stable_Names_Output_ND [subfolder] [This is a folder for stable names non-derivation output.]

## Other files to download in the main TN folder:
1. TN_Unmerged_2024.xlsx [This file is located in the TN ID notes folder in the Tennessee folder in Google Drive.]

## Process
The do files need to be executed in the following order.

01_TN_NCES.do

02_TN_DTA_Conversion.do

03_TN_Cleaning_2010_2014.do

04_TN_Cleaning_2017_2024.do

05_TN_EDFactsParticipationRate.do

06_TN_StableNames.do

You can run TN_Main_File.do after setting the appropriate file paths. 
