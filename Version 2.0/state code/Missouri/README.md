
# Missouri Data Cleaning

This is a ReadMe for Missouri's data cleaning process, from 2010 to 2024.
* Note that 2020 is excluded, as MO did not administer spring tests during that year due to COVID.


## Setup

The main folders and subfolders you need to create include: 

1. MO State Testing Data [Download the original excel and .csv files, and place them in this folder.]
   a. Output
   
2. NCES District and School Demographics
   a. NCES District Files, Fall 1997-Fall 2022
   b. NCES School Files, Fall 1997-Fall 2022
   c. Cleaned NCES Data
   
There .do files should be run in the following order:
1. Run "Missouri DTA Conversion.do" first to convert the original files into .dta files.
2. Run "Missouri NCES Cleaning.do" to clean the NCES files so that they are prepared to merge into the testing data.
3. Run 2010-14 Cleaning
4. Run 2015-17 Cleaning
5. Run 2018-24
    
## File Path

The file path setup should be as follows: 

global NCESSchool: Folder containing NCES school files

global NCESDistrict: Folder containing NCES district files

global NCESClean: Folder containing cleaned NCES data

global data: Folder containing original data files (in both excel/csv and .dta form)

global output: Folder containing cleaned + merged files

```bash
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global data "/Users/miramehta/Documents/MO State Testing Data"
global output "/Users/miramehta/Documents/MO State Testing Data/Output"
```
## Updates

03/18/2024: Updated to incorporate post-launch file format changes (including new subgroups) and clean up code, including by putting into loop form.
