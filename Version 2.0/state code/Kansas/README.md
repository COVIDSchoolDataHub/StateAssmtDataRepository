
# Kansas Data Cleaning

This is a ReadMe for Kansas's data cleaning process, from 2015 to 2023.


## Setup

There are three main folders (with subfolders) you need to create: 

1. KS State Testing Data
   
       a. Original Data Files [Download the original excel files and place them into this folder.]
       b. Output [will start empty]
 
   
3. NCES District and School Demographics
   
       a. NCES District Files, Fall 1997-Fall 2022 [Download files from Google drive district folder]
       b. NCES School Files, Fall 1997-Fall 2022 [Download files from Google drive school folder]
       c. Cleaned NCES Data [will start empty]
   
5. EdFacts
   
       a. There should be a folder for each applicable year in the EdFacts folder (2015 to 2022)
    
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

## Do File Order
There are 10 .do files, one for converting excel and csv files into dta files, one for cleaning EdFacts and NCES data to appropriately merge with testing data, and one file for each year.

Order
1. Kansas DTA Conversion.do
2. Kansas Cleaning Merge Files.do
3. Kansas 2015 Cleaning.do
4. Kansas 2016 Cleaning.do
5. Kansas 2017 Cleaning.do
6. Kansas 2018 Cleaning.do
7. Kansas 2019 Cleaning.do
8. Kansas 2021 Cleaning.do
9. Kansas 2022 Cleaning.do
10. Kansas 2023 Cleaning.do 

## Updates

04/16/2024: Updated to remove school and district IDs from their names and to adjust StudentGroup counts to match the "All Students" value if the StudentGroup only contains one StudentSubGroup.

05/01/24: Updated to pull in updated NCES Fall 2022 data.

6/17/24: Uploaded Kansas_Updates_Jun24.do to apply new StudentGroup_TotalTested convention and derive Student counts for English Proficient where possible. This is a stopgap measure to get kansas ready for V1.1 and should probably be incorporated into the individual cleaning files at a future date.
