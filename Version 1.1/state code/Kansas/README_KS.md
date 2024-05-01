
# Kansas Data Cleaning

This is a ReadMe for Kansas's data cleaning process, from 2015 to 2023.


## Setup

There are three main folders you need to create: KS State Testing Data, NCES District and School Demographics, and EdFacts.
There should be a folder for each applicable year in the EdFacts folder (2015 to 2022).
There should be three folders within the NCES folder:
NCES District Files, Fall 1997-Fall 2022, NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.
There should be two folders within the KS State Testing Data Folder: Original Data Files and Output.
Download the original excel files and place them into the "Original Data Files" folder. 

There are 10 .do files, one for converting excel and csv files into dta files, one for cleaning EdFacts and NCES data to appropriately merge with testing data, and one file for each year.

You should run "Kansas DTA Conversion.do" first. Then run "Kansas Cleaning Merge Files.do."  After that, you can run the individual year files in any order you want.
    
## File Path

The file path setup should be as follows: 

global NCESSchool: Folder containing NCES school files
global NCESDistrict: Folder containing NCES district files
global NCES: Folder containing cleaned NCES data
global EDFacts: Folder containing EDFacts data (wtih separate subfolders by year)
global raw: Folder containing original KS testing data
global output: Folder where cleaned .dta and .csv files will be saved

```bash
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EdFacts"
global raw "/Users/miramehta/Documents/KS State Testing Data/Original Data Files"
global output "/Users/miramehta/Documents/KS State Testing Data/Output"
```
## Updates

04/16/2024: Updated to remove school and district IDs from their names and to adjust StudentGroup counts to match the "All Students" value if the StudentGroup only contains one StudentSubGroup.

05/01/24: Updated to pull in updated NCES Fall 2022 data.