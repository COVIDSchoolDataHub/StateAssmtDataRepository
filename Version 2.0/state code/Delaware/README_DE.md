
## Delaware Data Cleaning

This is a ReadMe for Delaware's data cleaning process, from Spring 2015 to Spring 2024 

## Setup
1. Create a folder called DE State Testing Data.
    -  Create two subfolders: Original Data Files and Output.
    -  Download the original excel files (anything that is not in a subfolder on Drive) and place them in the Original Data Files folder.
    -  Place the files in the data request subfolder on Drive into the general Original Data Files folder.
2. Create a folder called NCES District and School Demographics.
    - Create three subfolders: NCES District Files, Fall 1997-Fall 2022; NCES School Files, Fall 1997-Fall 2022; Cleaned NCES Data.
    - Place the original NCES files into the appropriate folder (district or school).

There are 11 .do files. First run NCES_Clean_11.8.24.do.  Then you can run the files for each year in any order you want, as long as you run DE_sci_soc_2015-17_11.17.24 last.

## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global Original "/Users/miramehta/Documents/DE State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/DE State Testing Data/Output"
```
## Updates

03/29/2024: Made 2024 updates.
04/12/2024: Responded to 2024 review comments.
08/1/2024: Made filename updates.
08/30/2024: Added code for 2024 data.
11/08/2024: Recleaned data based on files received from data request.
11/17/2024: Incorporated 2015 sci/soc data that was not available by data request.
