
# Arkansas Data Cleaning
This is a ReadMe for Arkansas's data cleaning process, from 2009 to 2024.

## Setup
Create three main folders for Arkansas:
1. AR State Testing Data, with the following subfolders:
   
    a. Original Data - Keep all files in the subfolders they are in on Drive.
   
    b. Output
   
    c. Temp
   
    d. EDFacts (contains the long .dta formatted data)
   
2. NCES District and School Demographics, with the following subfolders:
   
    a. NCES District Files, Fall 1997-Fall 2022
   
    b. NCES School Files, Fall 1997-Fall 2022
   
3. EDFacts, with subfolders for each year (contains the wide versions of the data)

## Recreating Cleaning Process
There are 10 do-files, which should be run in the following order:

1. AR_Cleaning_2009_2014 - this do-file cleans all original data from 2009-2014.
2. AR_Cleaning_2015 - this do-file cleans all original data from 2015
3. AR_AllStudents_2016_2023 - this do-file cleans all data for the "All Students" SubGroup, for years 2016-2023 and all DataLevels
4. AR_NoCountsSubGroupData_2016_2023 - this do-file cleans all data at the SubGroup level, for 2016-2018, and all District and School level SubGroup data for 2019-2023. Does not clean overlapping data with AR_StateSG_2019_2023 or ANY data from the "All Students" Subgroup
5. AR_StateSG_2019_2023 - this do-file cleans all SubGroup data at the State level from 2019-2023.
6. AR_Cleaning_2024 - this do-file cleans all data for 2024 (pulling from all three raw data files)
7. AR_EDfacts_2016_2024 - this do-file combines all cleaned data for 2016-2023, cleans EDfacts data, merges StudentSubGroup_TotalTested and ParticipationRate where possible for District and School level subgroup data, and aggregates district level StudentSubGroup_TotalTested to the state level.
8. AR_EDFacts_2014_2021 - this do-file merges in ParticipationRate data from EDFacts for 2014-2021
9. AR_EDFacts_2022 - this do-file merges in ParticipationRate data from EDFacts for 2022
10. AR_StableNames - this do-file replaces DistNames and SchNames across years with consistent names.

## File Path

The file path setup should be as follows:

```bash
global Original "/Users/miramehta/Documents/AR State Testing Data/Original Data"
global Output "/Users/miramehta/Documents/AR State Testing Data/Output"
global NCES "//Users/miramehta/Documents/NCES District and School Demographics"
global Temp "/Users/miramehta/Documents/AR State Testing Data/Temp"
global EDFacts "/Users/miramehta/Documents/AR State Testing Data/EDFacts"
global EDFactsWide "/Users/miramehta/Documents/EDFacts"
```

## Updates
12/10/2024: Updated to include 2024 data, derive additional values where possible,
and match V2.0 StudentGroup_TotalTested convention.
