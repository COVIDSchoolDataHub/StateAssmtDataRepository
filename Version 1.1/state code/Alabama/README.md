
# Alabama Data Cleaning

This is a ReadMe for Alabama's data cleaning process, from 2015 to 2023.





## Setup

There are four folders you need to create: 
AL State Testing Data (and an output folder within it), AlabamaMain, NCES School, and NCES District. 

Download the original .csv and .xlsx files and place them into the "AL State Testing Data" folder. 

There are 2 .do files. 

You only have to use the file AL_Cleaning.do, and the other, Fixing Unmerged.do  will run through that.



    
## File Path

The file path setup should be as follows: 

local Original: Folder containing original data files.
local NCES_District: Folder containing NCES District files.
local NCES_School: Folder containing NCES School files.
local Output: Folder in which output files will be saved (within the original folder)
local AlabamaMain: Folder containing do files.


```bash
local Original "/Users/miramehta/Documents/AL State Testing Data"
local NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
local NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
local Output "/Users/miramehta/Documents/AL State Testing Data/Output"
local AlabamaMain "/Users/miramehta/Documents/Github/StateAssmtDataRepository/Version 1.1/State Code/Alabama"
```
## Updates

03/02/2024: Updated new StudentGroup/StudentSubGroup labels; Derived values for StudentSubGroup_TotalTested where possible; Derived more vlaues for ProficientOrAbove count and percent where possbile; New variable order/sort; New flag variables; Variable type conversion.
