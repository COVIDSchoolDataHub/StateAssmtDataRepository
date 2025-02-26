
## Delaware Data Cleaning

This is a ReadMe for Delaware's data cleaning process, from Spring 2015 to Spring 2024 

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/26/2025, the most recent files are from NCES 2022. 

## Setup
Create a folder for DE. Inside that folder, create the following subfolders:
      
      1. Original Data Files: 
      From Google Drive --> Delaware --> DE Original Data Files, download and place **all files** in the Original Data Files folder:
          i) DE Data Request - Received 11/6/24 (File names start with FOIA)
          ii) DE Original Data Files (File names start with DE_Original_Data_*)
      
               a. Cleaned DTA [subfolder]
         
      2. Temp
         
      3. NCES_DE [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output. As of 2/26/25, there is no non-derivation output. 

## Process
    Place all do files in the DE folder.
    
    Set the appropriate file paths in DE_Main_File.do
    
    Running DE_Main_File.do will execute all the do files in order.

## Updates

    - 03/29/2024: Made 2024 updates.
    - 04/12/2024: Responded to 2024 review comments.
    - 08/1/2024: Made filename updates.
    - 08/30/2024: Added code for 2024 data.
    - 11/08/2024: Recleaned data based on files received from data request.
    - 11/17/2024: Incorporated 2015 sci/soc data that was not available by data request.
    - 02/26/2025: Standardized code to add headers, footers, and other code. Fixed code that imports files. 
