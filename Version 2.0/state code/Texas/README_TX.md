# Texas Data Cleaning

This is a ReadMe for Texas's data cleaning process, from 2012 to 2024.

## Setup

Create a folder for TX. Inside that folder, create three more folders: "original_files", "output_files", and "temp_files"
You should also create a folder for NCES Data with three subfolders: NCES District Files, Fall 1997-Fall 2022,
NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.

1.  Download original data files and place them in the folder.
2.  Set file directories at the top of each do file:

```         
global original_files "/Users/miramehta/Documents/TX State Testing Data/Original"
global NCES_files "/Users/miramehta/Documents/NCES District and School Demographics"
global output_files "/Users/miramehta/Documents/TX State Testing Data/Output"
global temp_files "/Users/miramehta/Documents/TX State Testing Data/Temp"
```

-   `original_files` Corresponds to the "Original" data. The folder names don't really matter.
-   `NCES_files` Corresponds to raw NCES .dta files, downloaded from the drive
-   `output_files` Corresponds to the cleaned data
-   `temp_files` should be empty for now.

## Recreate Cleaning

1. Unhide importing code for each year:
```
forvalues i = 3/8
    .
    .
    .
save "$temp_files/TX_Temp_`year'_All_All.dta", replace
```

2. Run the do-files for each year. You will want to hide the importing code again after the first run. 

3. Run the do-file "Texas DistName Updates.do" to standardize all the DistNames in each cleaned file.

## Updates
10/17/24: Updated to include 2024 data, clean prior years using the csv version of the file instead of the .sas version (for easier Stata processing) and standardize district names to match 2024.
10/24/24: Updated to use new 2022 and 2023 files which include data for Spanish version of the test.