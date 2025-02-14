
# Kentucky Data Cleaning

This is a ReadMe for Kentucky's data cleaning process, from 2012 to 2024.

## NCES Setup
NCES_Original: Download the folder from Google Drive-->_Data Cleaning Materials --> NCES District and School Demographics.
Move all district and school files from the subfolders into the NCES_Original folder. 

## Kentucky Setup
Create a folder for KY. Inside that folder, create the following subfolders:
  a. Original: Download Original Data Files from the Kentucky folder on the drive
  b. Output: Will be where the .csv and .dta output is saved, starts empty
  c. NCES: Will start empty, will contain cleaned NCES files to be used for KY_Cleaning_DataRequest_2022-2024.do.

## File Path
Set file paths in the main do-file:
```
** Set directory to Kentucky folder
cd "/Volumes/T7/State Test Project/Kentucky"

** Set Path to do-files
global DoFiles "/Users/joshuasilverman/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/Kentucky"

** Set Path to NCES Folders
global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_KY "/Volumes/T7/State Test Project/Kentucky/NCES"

** Original Data and Output Data folders
global Original "/Volumes/T7/State Test Project/Kentucky/Original Data Files"
global Output "/Volumes/T7/State Test Project/Kentucky/Output"
```


## Recreate cleaning
There are four do-files. Run them in the following order:

1. KY_NCES
2. KY_Cleaning_2012_2023.do
3. KY_Cleaning_DataRequest_2022-2024.do
4. KY_EDFactsParticipation_2022.do

After setting directories you may run the KY_Main_file.do to recreate the cleaning process as described above.

## Updates

12/02/2024: Added 2024 data and updated StudentGroup_TotalTested to match V2.0 convention.
02/14/2024: Recleaned 2022-2024 data from data request. Standardized code to align with V2.1 conventions. Added main do-file.