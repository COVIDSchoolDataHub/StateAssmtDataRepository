
# Oklahoma Data Cleaning
This is a ReadMe for Oklahoma's data cleaning process, from 2017 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 3/12/2025, the most recent files are from NCES 2022. 

## Oklahoma Setup
Create a folder for OK. Inside that folder, create the following subfolders:

 1. Original Data Files: Download the **entire** folder called OK Original Data Files. This is located in Google Drive --> Oklahoma.
   
        The folder and files are structured exactly the way you need it on your local drive.

        You should have the following folders in the Original Data Files folder your local drive.
    
        a. DTA [subfolder]

        b. OK ELA, Math Sci Assmt Data (2017-2023) Received via Data Request - 4-25-24 [subfolder]

        c. OK ELA, Math, Sci Assmt Data (2024) Received via Data Request - 11-10-24 [subfolder]

        d. Publicly Available Data Files [subfolder]
      
3. Temp 
         
4. NCES_OK [will start empty]
           
6. Output_Files
      
7. Output_Files_ND: This is a folder for the non-derivation output.


## Process
    Place all do files in the OK folder.
        
    Set the appropriate file paths in OK_Main_File.do
        
    Running OK_Main_File.do will execute all the do files in order.
    
## Updates

04/11/2024: Updated output files to incorporate new NCES variables.
  
05/25/2024: Updated output files to use new data request files in place of old original data files.
  
12/02/2024: Updated to include 2024 data, derive additional information, and match StudentGroup_TotalTested
convention for V2.0

03/12/2025: Standardized code and added code for non-derivation output. 
