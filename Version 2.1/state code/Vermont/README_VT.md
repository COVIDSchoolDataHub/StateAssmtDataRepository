
# Vermont Data Cleaning

This is a ReadMe for Vermont's data cleaning process, from 2016 to 2024.


## Setup
Create three folders:
1. Create a folder for Vermont. Inside that folder, create two subfolders: "Original Data" and "Output".
    a. Original Data - includes all original data files, including the 2022 edfacts files, from Drive
    b. Output - where cleaned files will be saved
2. NCES District and School Demographics, with subfolders for school and district level data.
3. EDFacts, with subfolders for each year from 2016 to 2021.


1. Download do-files and place them in the VT folder.
2. Download the "Datasets" folder in the EDFacts folder under _Data Cleaning Materials
3. Make sure you're using updated NCES files 
4. Set Directories as follows:
The `cd` command should map to the Vermont folder
`NCES_Schoool` should map to the folder containing NCES .dta files at the school level
`NCES_District ` should map to the folder containing NCES .dta files at the district level
`EDFacts` should map to the folder containing the EDFacts datasets exactly as formatted in the drive, where each year is its own folder.

## Recreating Cleaning Process
- Run the one yearly cleaning do file
- Run the 2016-2017 and 2022 Edfacts files next

## Updates
02/12/2025: Updated to include 20224 data.








