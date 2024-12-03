
# Missouri Data Cleaning

This is a ReadMe for Missouri's data cleaning process, from 2010 to 2023.
* Note that 2020 is excluded, as MO did not administer spring tests during that year due to COVID.


## Setup

There are two main folders you need to create: MO State Testing Data and NCES District and School Demographics.
There should be three folders within the NCES folder:
NCES District Files, Fall 1997-Fall 2022, NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.
Download the original excel and .csv files, and place them in the MO State Testing Data folder.
Also create an Output subfolder of the MO State Testing Data folder to which to save the cleaned files.

There are 5 .do files.
You should run "Missouri DTA Conversion.do" first to convert the original files into .dta files.
Then run "Missouri NCES Cleaning.do" to clean the NCES files so taht they are prepared to merge into the testing data.
The other three files are for the years 2010-14, 2015-17, and 2018-24.  You can run these three in any order.
    
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
