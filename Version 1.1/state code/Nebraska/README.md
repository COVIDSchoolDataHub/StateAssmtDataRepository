# Nebraska Data Cleaning
Updated as of 4/7/24 pre-review
This is a ReadMe for Nebraska's data cleaning process, from 2016 to 2023.

## Setup

Create a folder for Nebraska. Inside that folder, create a folder for the original data and the cleaned data.

1.  Download do-files and place them in the folder.
2.  Download original data from drive and place it in the original data folder.
3.  Make sure to have updated NCES data downloaded and EDFacts data downloaded
4.  Set file directories at the top of each file.

```
cd "/Volumes/T7/State Test Project/Nebraska"     
global data "/Volumes/T7/State Test Project/Nebraska/Original Data Files"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global counts "/Volumes/T7/State Test Project/EDFACTS"
global output "/Volumes/T7/State Test Project/Nebraska/Output"
```

-   `data` Corresponds to the "Original" data. The folder names don't really matter.
-   `NCES` Corresponds to raw NCES .dta files, downloaded from the drive
-   `counts` Corresponds to the folder with raw EDFACTS .dta files, downloaded from the drive
-   `output` Corresponds to the cleaned data

## Recreate Cleaning

1.  Run NE Student Counts 2016+17_12.1.23.do first
2.  Run NE Student Counts 2018_12.1.23.do second
3.  Run other files in any order you like

### Optional: Use NE_MASTER do-file to clean all files at once after setting directories in each do-file.

-   Inside the NE_MASTER do-file, change the directory `global dir "/Volumes/T7/State Test Project/Nebraska"`
-   Run the do-file. This is a simple file to run all do files in the correct order.
