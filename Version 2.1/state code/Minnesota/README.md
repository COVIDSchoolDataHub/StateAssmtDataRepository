# Minnesota Data Cleaning

This is a ReadMe for Minnesota's data cleaning process, from 1998 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/24/2025, the most recent files are from NCES 2022. 

## EDFacts Setup
EDFacts: Download the Datasets subfolder containing *.csv files. There will be individual folders for each year. 

This is located in Google Drive-->_Data Cleaning Materials --> _EDFacts--> Datasets.

## Minnesota Setup
Create a folder for MN. Inside that folder, create the following subfolders:

 1. Original Data Files: Download the **entire** folder (and subfolders) from Google Drive --> Minnesota:
    
        i. MN Original Data Files
    
        ii. MN_2022_EDFactsParticipation
   
        Place these files in the Original Data Files folder on your local drive.
  
         a. Cleaned DTA [subfolder]: Will start empty.
         b. MN Stable Dist and Sch Names [subfolder]: Will contain files from MN Stable Dist and Sch Names subfolder of MN Original Data Files. 
     
3. Temp 
         
4. NCES_MN [will start empty] : Currently not in use. 
      
5. EDFacts_MN [will start empty]
      
6. Output_Files
      
7. Output_Files_ND: This is a folder for the non-derivation output.


## Process
    Place all do files in the MN folder.
        
    Set the appropriate file paths in MN_Main_File.do
        
    Running MN_Main_File.do will execute all the do files in order.
