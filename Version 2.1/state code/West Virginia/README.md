# West Virginia Data Cleaning

This is a ReadMe for West Virginia's data cleaning process, from 2015 to 2024.

## Setup
You will need three main folders:
1. EDFacts, with subfolders for each year from 2015-2021. They should contain the wide .csv versions of the files.
2. NCES District and School Demographics, with subfolders for school and district data.
3. West Virginia, with the following subfolders:
    - Original Data Files: This will contain all original files downloaded form Drive.
    - Counts: This will begin empty, but will contain the versions of files with student counts that can be merged with performance data.
    - NCES_Clean: This will begin empty, but will contian the WV-specific NCES files.
    - Output: This will begin empty, and cleaned files will be saved here.

Macros can be set as follows:
```
global DoFiles "/Users/miramehta/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/West Virginia" 
cd "/Users/miramehta/Documents/West Virginia"
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCES_Dist "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_clean "/Users/miramehta/Documents/West Virginia/NCES_Clean"
global edfacts "/Users/miramehta/Documents/EDFacts"
global counts "/Users/miramehta/Documents/West Virginia/Counts"
global data "/Users/miramehta/Documents/West Virginia/Original Data Files"
global output "/Users/miramehta/Documents/West Virginia/Output" //Usual output exported. 
```

## Recreating Cleaning
You can complete the entire cleaning process by running "WV_Main_File.do."
Alternatively, you can set the macros defined in "WV_Main_File.do." and run each of the other 12 .do files individually in the following order:
1. Run 01_WV_Student_Counts.do
2. Run 02_WV_EDFacts_22_24.do
3. Run 03_WV_ParticipationRate_18_24.do
4. Run the do files for each year in any order you'd like.

## Updates
02/22/2024: Updated to include particiaption rates & state level counts received via data request & match new file naming convention.