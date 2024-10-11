
# Alabama Data Cleaning

This is a ReadMe for Alabama's data cleaning process, from 2015 to 2024.

## Setup

There are four folders you need to create: 
AL State Testing Data, NCES School, and NCES District.

Within the AL State Testing Data folder, create two subfolders: Original Data Files and Output.

Download the original .csv and .xlsx files and place them into the "Original Data Files" folder. 

There are 4 .do files, which should be run in the following order:
AL_Cleaning.do, Fixing Unmerged.do, AL_2023.do, and AL_2024.do.
    
## File Path

The file path setup should be as follows: 

local Original: Folder containing original data files.
local NCES_District: Folder containing NCES District files.
local NCES_School: Folder containing NCES School files.
local Output: Folder in which output files will be saved (within the original folder)

```bash
local Original "/Users/miramehta/Documents/AL State Testing Data/Original Data Files"
local NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
local NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
local Output "/Users/miramehta/Documents/AL State Testing Data/Output"
```
## Updates

03/02/2024: Updated new StudentGroup/StudentSubGroup labels; Derived values for StudentSubGroup_TotalTested where possible; Derived more vlaues for ProficientOrAbove count and percent where possbile; New variable order/sort; New flag variables; Variable type conversion.

4/16/24: Response to post launch review: Switched 2023 to use report card database; derived more counts and percents where we had a combination of count and percent (for instance, Lev1_count and Lev1_percent); misc changes/fixes

10/10/24: Added data for 2024, updated StudentGroup_TotalTested to match Version 2.0 convention, and derived additional level and proficiency information where it was suppressed and could be determined from other unsuppressed information (see CW for more on this methodology).  Also updated 2023 to pull from updated report card database, which now includes counts.