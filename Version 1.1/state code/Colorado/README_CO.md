
# Colorado Data Cleaning

This is a ReadMe for Colorado's data cleaning process, from 2015 to 2023.

## Setup

There are two main folders you will need to create: CO State Testing Data and NCES District and School Demographics.
Within the folder CO State Testing Data, you will need to create a separate subfolder for each year from 2015-2023.
Within the NCES District and School Demographics folder, there should be three folders:
(1) NCES District Files, Fall 1997-Fall 2022
(2) NCES School Files, Fall 1997-Fall 2022
(3) Cleaned NCES Data

Download the original .xlsx files and place them into the appropriate subfolder in the "CO State Testing Data" folder. 

There are 10 .do files.

First run Colorado NCES Cleaning.do, and then you can run any of the individual year files.  The only exception is 2023, which has two files -- first run Colorado DTA Conversion.do, and then run Colorado 2023 Cleaning.do.


    
## File Path

The file path setup should be as follows: 

global path: Folder containing original data files for the given year.
global NCES Folder containing cleaned NCES data.
global NCESSchool Folder containing school level NCES data files.
global NCESDistrict: Folder containing district level NCES data files.
global Output: Folder in which output files will be saved (CO State Testing Data).

Note that "path" will need to change for every year

```bash
global path "/Users/miramehta/Documents/CO State Testing Data/[year]"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global output "/Users/miramehta/Documents/CO State Testing Data"
```
## Updates

04/10/2024: Updated to pull from 2022 NCES files, derive level counts for 2015 and proficiency counts for 2022, and match updated StudentGroup_TotalTested convention.  Also updated to appropriately address range values.

05/01/2024: Updated to pull in updated NCES fall 2022 data and correct some StudentGroup and StudentSubGroup labels.