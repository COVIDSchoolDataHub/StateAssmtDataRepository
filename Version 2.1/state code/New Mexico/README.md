
# New Mexico Data Cleaning

This is a ReadMe for New Mexico's data cleaning process, from 2015 to 2024.

## Setup

There are three main folders you need to create:
1. New Mexico, with the following subfolders:
    - Original Data (download original files form V1.1+ subfolder on Drive)
    - Output
2. NCES District and School Demographics, with the following subfolders:
    - NCES District Files, Fall 1997-Fall 2022
    - NCES School Files, Fall 1997-Fall 2022
    - Cleaned NCES Data
3. EDFacts, with a subfolder for each year (containing wide .csv versions of the files). This is the EDFacts folder downloadable from the drive.

There are 10 .do files, which should be run in the following order:
1. 01_New Mexico DTA Conversion
2. 02_New Mexico Cleaning Merge Files.do
3. 03 - 09_New Mexico `year' Cleaning.do [these can be run in any order you want]
4. 10_NM Stable Names.do
    
## File Path

File paths should be specified in the Main do-file as follows: 

```bash
 ** Set Path to do-files
global DoFiles "/Users/joshuasilverman/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/New Mexico"


 ** Set path to NCES Original and Cleaned Directories
global NCESSchool "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Original NCES school data
global NCESDistrict "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" // Original NCES district data
global NCES "/Volumes/T7/State Test Project/New Mexico/NCES" //Cleaned NCES school and district data

 **Set path to EDFacts wide files
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

 **State cleaning directories
global NM "/Volumes/T7/State Test Project/New Mexico" //Main NM folder (should contain 2024 unmerged schools)
global raw "/Volumes/T7/State Test Project/New Mexico/Original Data Files" //Original Data
global output "/Volumes/T7/State Test Project/New Mexico/Output" //Output
```
## Updates

12/12/2024: Updated to derive additional information for StudentSubGroup_TotalTested + ProficientOrAbove.

02/21/2025: Updated 2017-2023 to align  with do-file standardization. Added 2024 data request data.