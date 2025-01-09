
# Georgia Data Cleaning

This is a ReadMe for Georgia's data cleaning process, from 2011 to 2024.

## Setup

There are three main folders you need to create: GA State Testing Data, NCES District and School Demographics, and EDFacts.
There should be three folders withing the NCES folder:
NCES District Files, Fall 1997-Fall 2022, NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.
The EDFacts folder should have a subfolder for each year.

Download the original .csv files and place them into the "GA State Testing Data" folder. 

There are 15 .do files, one for each year, and 2 files to merge in participation data.

You can run the year files in any order, but the GA_EDFactsParticipation Files must be run last.
    
## File Path

The file path setup should be as follows: 

global GAdata: Folder containing original data files (and where output will be saved).
global NCES: Folder containing all NCES files (with subfolders for original state and district data, plus an additional subfolder where usable cleaned files will be saved).
global EDFacts: Folder containing all EDFacts data (with subfolders for each year).


```bash
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global EDFacts "/Users/miramehta/Documents/EdFacts"

```

## General Note
Broadly, the initial file format (and therefore the cleaning code structure) are the same for 2015 and 2019-2023.  All other years have an initial file format that matches each other, but is different from 2015 and 2019-2023.

## Updates

04/17/2024: Updated to derive more level and proficiency counts where possible, change the case of CountyName prior to 2015, and match new StudentGroup_TotalTested convention for suppressed subgroup counts/categories where only one applicable subgroup is reported.

05/01/2024: Updated to pull in updated NCES fall 2022 data and correct an unmerged value in 2021.

10/6/2024: Updated to include preliminary 2024 data (only ela & math; no subgroups), match new StudentGroup_TotalTested convention and derive ProficientOrAbove_percent values to avoid getting percentages greater than 1.