
# Alabama Data Cleaning

This is a ReadMe for Colorado's data cleaning process, from 2014 to 2023.





## Setup

There are two main folders you will need to create: CO State Testing Data and NCES District and School Demographics.
Within the folder CO State Testing Data, you will need to create a separate subfolder for each year from 2014-2023.
Within the NCES District and School Demographics folder, there should be three folders:
(1) NCES District Files, Fall 1997-Fall 2022
(2) NCES School Files, Fall 1997-Fall 2022
(3) Cleaned NCES Data

Download the original .xlsx files and place them into the appropriate subfolder in the "CO State Testing Data" folder. 

There are 11 .do files. 

First run Colorado NCES Cleaning.do, and then you can run any of the individual year files.  The only exception is 2023, which has two files -- first run Colorado DTA Conversion.do, and then run Colorado 2023 Cleaning.do.


    
## File Path

The file path setup should be as follows: 

local path: Folder containing original data files for the given year.
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global Output: Folder in which output files will be saved (CO State Testing Data).

```bash
local path "/Users/miramehta/Documents/CO State Testing Data/[year]"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global output "/Users/miramehta/Documents/CO State Testing Data"
```
## Updates

03/04/2024: Updated to include DistLocale and pull from updated NCES data files.