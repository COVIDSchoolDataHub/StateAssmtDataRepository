
# Indiana Data Cleaning

This is a ReadMe for Indiana's data cleaning process from 2014 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/13/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## Indiana Setup
Create a folder for IN. Inside that folder, create the following subfolders:
      
      1. Original Data Files: Download the **entire** folder called Original Data Files - Version 2.0+ (incl v1.1 + sci and soc data). 
      
      This is located in Google Drive --> Indiana. 
      
      The folder and files are structured exactly the way you need it on your local drive.
         a. ELA + Math [subfolder]: This should contain all  ELA + Math files downloaded.
         b. Science + Social Studies [subfolder]: This should contain all Science + Social Studies downloaded.   
      
      2. Temp
         
      3. NCES_IN [will start empty]
      
      4. EDFacts_IN [will start empty]
      
      5. Output_Files
      
      6. Output_Files_ND: This is a folder for the non-derivation output.
   
## Process
The do files need to be executed in the following order.

      1. 01_Indiana NCES Cleaning.do
      
      2. 02_IN_Importing_sci_soc.do
      
      3. 03_IN_Importing.do
      
      4. 04_IN_Cleaning.do
      
      5. 05_IN_EDFactsParticipation_2014_2021.do
      
      6. 06_IN_EDFactsParticipation_2022.do

You can run IN_Main_File.do after setting the appropriate file paths. 

## Updates
11/12/24: Updated to include 2024 data, as well as new sci/soc data received in data request, and incorporate "all students" data from public files.

02/13/24: Modified code to export non-derivation output. Fixed case-sensitive issues in 03_IN_Importing. Added headers, footers, and notes in each do file. 
