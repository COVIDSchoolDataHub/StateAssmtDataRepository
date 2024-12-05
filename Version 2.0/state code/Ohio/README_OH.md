# Ohio Data Cleaning

This is a ReadMe for Ohio's data cleaning process, from 2016 to 2024.

## Setup

Create a folder for OH. Inside that folder, create two more folders: "Original Data" and "Output"
You should also create a folder for NCES Data with three subfolders: NCES District Files, Fall 1997-Fall 2022,
NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.

1.  Download original data files and place them in the folder.
2.  Set file directories at the top of each do file:

```         
global raw "/Users/miramehta/Documents/OH State Testing Data/Original Data"
global output "/Users/miramehta/Documents/OH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/"
global NCES_clean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
```

-   `raw` Corresponds to the "Original" data. The folder names don't really matter.
-   `output` Corresponds to the cleaned data.
-   `NCES` Corresponds to umbrella NCES folder.
-   `NCES_clean` Should be empty for now.

## Recreate Cleaning

1. Run the file "OH Importing Raw Data_10.23.24" first.  This will import the raw data and convert to .dta files for each year.

2. Run the do-files for each year.  These can be run in any order.

# Updates
10/23/24: Original cleaning (with files from DR received 9/25/24 for V2.0).
12/04/24: Updated to aggregate information for schools listed in multiple districts in raw data to one observationo with NCES listed district.