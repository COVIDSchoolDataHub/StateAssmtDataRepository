
# Georgia Data Cleaning

This is a ReadMe for Georgia's data cleaning process, from 2011 to 2023.


## Setup

There are two main folders you need to create: GA State Testing Data and NCES District and School Demographics.
There should be three folders withing the NCES folder:
NCES District Files, Fall 1997-Fall 2022, NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.

Download the original .csv files and place them into the "GA State Testing Data" folder. 

There are 12 .do files, one for each year.

You can run the files in any order, except for 2023, which MUST be run after 2022 in order to incorporate NCES data correctly.


    
## File Path

The file path setup should be as follows: 

global GAdata: File containing original data files (and where output will be saved).
global NCES: File containing all NCES files (with subfolders for original state and district data, plus an additional subfolder where usable cleaned files will be saved.)


```bash
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
```

## General Note
Broadly, the initial file format (and therefore the cleaning code structure) are the same for 2015 and 2019-2023.  All other years have an initial file format that matches each other, but is different from 2015 and 2019-2023.

## Updates

04/17/2024: Updated to derive more level and proficiency counts where possible, change the case of CountyName prior to 2015, and match new StudentGroup_TotalTested convention for suppressed subgroup counts/categories where only one applicable subgroup is reported.