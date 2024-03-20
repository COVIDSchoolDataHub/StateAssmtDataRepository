
# New Jersey Data Cleaning

This is a ReadMe for New Jersey's data cleaning process, from 2015 to 2023.
* Note that 2020 and 2021 are excluded, as NJ did not administer spring tests during those years due to COVID.


## Setup

There are two main folders you need to create: NJ State Testing Data and NCES District and School Demographics.
There should be three folders within the NCES folder:
NCES District Files, Fall 1997-Fall 2022, NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.
There should be a subfolder for each year within the NJ State Testing Data folder.
Download the original excel files and place them into the appropriate subfolder here.

There are 2 .do files, one for 2015-2018 (when PARCC was administered) and on for 2019-2023 (when NJSLA is administered).
You can run the files in either order.
    
## File Path

The file path setup should be as follows: 

global data: Large folder within which original data files for each year are stored
global NCESSchool: Folder containing NCES school files
global NCESDistrict: Folder containing NCES district files
global NCESClean: Folder containing cleaned NCES data

```bash
global data "/Users/miramehta/Documents/NJ State Testing Data"
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCESClean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
```
## Updates

03/15/2024: Updated to incorporate post-launch file format changes (including new subgroups) and derive level and proficiency counts based on percents and student counts.