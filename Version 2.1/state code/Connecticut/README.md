
# Connecticut Data Cleaning

This is a ReadMe for Connecticut's data cleaning process, from 2015 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/11/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the files below from Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets --> 2021. 

            edfactspart2021eladistrict.csv
            
            edfactspart2021mathdistrict.csv
            
            edfactspart2021elaschool.csv
            
            edfactspart2021mathschool.csv

## Connecticut Setup
Create a folder for CT. Inside that folder, create the following subfolders:

    1. Original Data Files: Download the Original Data Files from the Connecticut folder in Google Drive.
    
    2. NCES_CT [will start empty]
            
    3. Output 
        
    4. Output_ND: This is a folder for the non-derivation output
        
    5. Temp 

## Process
The do files need to be executed in the following order.

    1. 01_CT_Cleaning.do 
    
    2. 02_CT_Cleaning_2021.do 
    
    3. 03_CT_2021_EDFACTS.do
    
You can run CT_Main_File.do after setting the appropriate file paths. 

### Note: Install the "labutil" package for the code to run (necessary for "labmask" command):

Type the following code into the command module:
```
ssc install labutil
```
