
# New Mexico Data Cleaning

This is a ReadMe for New Mexico's data cleaning process, from 2015 to 2023.

## Setup

There are three main folders you need to create:
1. New Mexico, with the following subfolders:
    - Original Data (download original files form V1.1+ subfolder on Drive)
    - Output
2. NCES District and School Demographics, with the following subfolders:
    - NCES District Files, Fall 1997-Fall 2022
    - NCES School Files, Fall 1997-Fall 2022
    - Cleaned NCES Data
3. EDFacts, with a subfolder for each year (containing wide .csv versions of the files).

There are 9 .do files, which should be run in the following order:
1. New Mexico Cleaning Merge Files.do
2. New Mexico DTA Conversion.do
3. New Mexico `year' Cleaning.do [these can be run in any order you want]
4. NM Stable Names.do
    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EDFacts"
global raw "/Users/miramehta/Documents/New Mexico/Original Data Files"
global output "/Users/miramehta/Documents/New Mexico/Output"
```
## Updates

12/12/2024: Updated to derive additional information for StudentSubGroup_TotalTested + ProficientOrAbove.