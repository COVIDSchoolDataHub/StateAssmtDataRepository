
# Arizona Data Cleaning

This is a ReadMe for Arizona's data cleaning process, from 2010 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/20/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## Arizona Setup
Create a folder for AZ. Inside that folder, create the following subfolders:

 1. Original Data Files: Download the **entire** folder called AZ Original Data Files. This is located in Google Drive --> Arizona.
   
        The folder and files are structured exactly the way you need it on your local drive.
     
         a. AzSci [subfolder]
         b. AzM2-AzMERIT + AIMS Science [subfolder]
         c. AIMS [subfolder]
         d. AASA   [subfolder]  
      
2. Temp 
         
3. NCES_AZ [will start empty]
      
4. EDFacts_AZ [will start empty]
      
5. Output_Files
      
6. Output_Files_ND: This is a folder for the non-derivation output.


## Process
The do files need to be executed in the following order.

    01_NCES_clean copy.do
    02_AZ EDFacts.do
    03_AIMS_all_clean_2010.do
    04_AIMS_all_clean_2011.do
    05_AIMS_all_clean_2012.do
    06_AIMS_all_clean_2013.do
    07_AIMS_all_clean_2014.do
    08_AzMerit_clean_2015.do
    09_AzMerit_clean_2016.do
    10_AzMerit_clean_2017.do
    11_AzMerit_clean_2018.do
    12_AzMerit_clean_2019.do
    13_AzM2_clean_2021.do
    14_AASA_clean_2022.do
    15_AASA_clean_2023.do
    16_AASA_clean_2024.do
    17_AZ_EDFactsParticipation_2014_2021.do
    18_AZ_EDFactsParticipation_2022.do

You can run AZ_Main_File.do after setting the appropriate file paths. 

## Updates

03/06/2024: Updated new StudentGroup/StudentSubGroup labels; New variable order/sort; New flag variables.

11/01/2024: Updated to include 2024 data, derive additional StudentSubGroup_TotalTested and performance information,
and match v2.0 StudentGroup_TotalTested convention.

12/01/2024: Updated to include 2024 science data.

02/20/2025: Updated to restructure code, adddc code for non-derivation output, and modified code for exporting intermediate output to a Temp folder. 
