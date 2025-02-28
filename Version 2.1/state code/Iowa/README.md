# Iowa Data Cleaning

This is a ReadMe for Iowa's data cleaning process, from 2004 to 2024.

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/28/2025, the most recent files are from NCES 2022. 

## Setup

Create a folder for IA. Inside that folder, create the following subfolders:
      
	1. Original Data Files: Download the following folders from Google Drive --> IoWa --> IA Original Data Files. 
 
 	Retain the same folder structure and place the folders in the Original Data Files.  

		a. 2014 and Previous Files [subfolder]
  		b. 2015 and Post Files [subfolder]
    	c. Stable Dist and Sch Names [subfolder]
  
	Also, download the following file and place it in the Original Data Files folder.
 
 		i) ia_county-list_through2023.xlsx [Google Drive --> Iowa --> IA Original Data Files]
         
		d. DTA [subfolder] - This folder needs to be created. 

      2. Temp
         
      3. NCES_IA [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output. [Not in use.]

## Process
    Place all do files in the IA folder.
    
    Set the appropriate file paths in IA_Main_File.do
    
    Running IA_Main_File.do will execute all the do files in order.

# Updates
7/3/24: Added EDFacts Participation Data to 2014 through 2022

8/2/24: Applied new stable district names to all years (referenced by IA_StableNames do-file, which should be run last).

12/15/24: New .do files to streamline cleaning. Integrated 2024 data and applied StudentGroup_TotalTested convention.

02/10/25: Updated file 2 to clean Disability Status observations in newly received 2024 data request.

02/28/25: Modified code to export non-derivation output. Added headers, footers, and notes in each do file.
