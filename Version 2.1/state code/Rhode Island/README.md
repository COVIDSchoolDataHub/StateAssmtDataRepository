 # Rhode Island
This is a ReadMe for Rhode Island's cleaning process, from 2018-2024, excluding 2020. 

## NCES Setup

NCES_Full: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
    
       a. NCES District Files [subfolder] 

       b. NCES School Files [subfolder]

As of 2/27/2025, the most recent files are from NCES 2022. 

## Setup

Create a folder for RI. Inside that folder, create the following subfolders:
      
      1. Original Data Files: Download the following files and place them in the Original Data Files.

      From Google Drive --> Rhode Island:
     
      i) RI_2018_2024_NCES ID crosswalk.xlsx

      ii) RI_District_School_CW.xlsx

      
      From Google Drive --> Rhode Island --> RI Original Data Files

      iii) RI_OriginalData_ela_2018_2024.xlsx

      iv) RI_OriginalData_math_2018_2024.xlsx

      v) RI_OriginalData_sci_2018_2024.xlsx
      
         a. DTA [subfolder] 
         
      2. Temp
         
      3. NCES_RI [will start empty]
           
      4. Output_Files
      
      5. Output_Files_ND: This is a folder for the non-derivation output.

## Process
    Place all do files in the RI folder.
    
    Set the appropriate file paths in RI_Main_File.do
    
    Running RI_Main_File.do will execute all the do files in order.

## Notes
Level percentages had varying formats (e.g, they were both decimals and percentages, and there was no pattern). They were determined to be a percent or a decimal based on the following process:

1. Automatically assigned as a percentage value if the raw data contained "%" after the value
2. Automatically assigned as a percentage value if the number was over 1.
3. Remaining were decimals, but could not distinguish between a decimal (0.9) and a decimal percentage (0.9%). This problem only applied to Lev4_percent. Determined to be a percentage if and only if the sum of all percents was too high.

Two crosswalks used to merge NCES data. Both include most schools, but only by using them together can we get all IDs for now. Something to streamline later.

## Updates
- 12/13/24: Recleaned all RI data using new scraped data from 2018-2024
- 12/15/24: Responded to R1
- 02/27/25: Modified code to create non-derivation output. Standardized code to include headers and footers. 
