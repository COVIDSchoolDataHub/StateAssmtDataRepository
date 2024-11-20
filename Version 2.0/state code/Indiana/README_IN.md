
# Indiana Data Cleaning

This is a ReadMe for Indiana's data cleaning process, from 2014 to 2024.

## Set Up
There are three main folders you will need:
1. IN State Testing Data, with the following subfolders:
    a. Original Data Files - Download the files from Original Data - Version 2.0 and place them here.
    b. Temp
    c. Output
2. NCES District and School Demographics, with subfolders for district and school files, as well as a subfolder for clean NCES files.
3. EDFacts, with a subfolder for each year form 2014-2021.  Download the wide version of the datasets (from the "Long DTA Datasets" folder) and place them in the appropriate subfolders.

There are 6. do files which must be run in the following order:
1. Indiana NCES Cleaning.do
2. IN_Importing_sci_soc.do
3. IN_Importing.do
4. IN_Cleaning.do
5. IN_EDFactsParticipation_2014_2021.do
6. IN_EDFactsParticipation_2022.do

## File Path

The file path setup should be as follows: 

```bash
global NCES_Original "/Users/miramehta/Documents/NCES District and School Demographics/"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global Original "/Users/miramehta/Documents/IN State Testing Data/Original Data Files"
global temp "/Users/miramehta/Documents/IN State Testing Data/Temp"
global Output "/Users/miramehta/Documents/IN State Testing Data/Output"

global EDFacts "/Users/miramehta/Documents/EDFacts"
```

## Updates
11/12/24: Updated to include 2024 data, as well as new sci/soc data received in data request, and incorporate "all students" data from public files.
