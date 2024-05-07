# West Virginia Data Cleaning

This is a ReadMe for West Virginia's data cleaning process, from 2015 to 2023.

## Setup

Create a folder for WV. Within that folder, create four more folders corresponding to the following directories at the top of the do-files. `counts` should contain EDFacts data. `data` should contain all original data downloaded from the drive, including enrollment data. `NCES` should contain updated NCES files.

```
cd "/Volumes/T7/State Test Project/West Virginia"
global data "/Volumes/T7/State Test Project/West Virginia/Original Data Files"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_clean "/Volumes/T7/State Test Project/West Virginia/NCES_Clean"
global counts "/Volumes/T7/State Test Project/EDFACTS"
```

## Recreating Cleaning
There are 3 do-files you must run, and 11 total do files to download. The 3 do files to run manually and change directories for are WV Cleaning_7.22.23, WV Student Counts 15-21_12.2.23, and WV Student Counts 22-23_12.2.23. Run the Student Counts do-files first. Then run the the Cleaning do-file. This cleaning do-file will run the remaining do-files which clean each year. You do not need to set directories in these files. You can run the yearly do-files individually after setting directories in the 3 manual do-files.