
# New York Data Cleaning

This is a ReadMe for New York's data cleaning process, from 2006 to 2024.


## Setup
Create two main folders:
1. NCES District and School Demographics; this will have two subfolders:
   
    a. NCES District Files, Fall 1997-Fall 2022
   
    b. NCES School Files, Fall 1997-Fall 2022
   
2. New York; this will have two subfolders:
   
    a. Original (download the original data files from Drive and keep them in their appropriate subfolders).
   
    b. Output

## Directories
Set file directories at the top of each do file:

```         
global original "/Users/miramehta/Documents/New York/Original"
global output "/Users/miramehta/Documents/New York/Output"
global nces_school "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global nces_district "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"	
```

-   `original_files` Corresponds to the "Original" data. The folder names don't really matter.
-   `output` Corresponds to the output folder, where cleaned files will be saved.
-   `nces_school` Corresponds to the NCES school level data.
-   `nces_district` Corresponds to the NCES school level data.

## Recreating cleaning
There are 9 .do files for New York.  Run them as follows:
1. "Combining 2006-2017.do"
2. "2006-2017.do"
3. Individual year files (2018-2024, in any order you want)
4. "NY_EDFactsParticipation_2014_2019.do"

## Updates
11/23/24: Updated to include 2024 data and match V2.0 StudentGroup_TotalTested convention.
