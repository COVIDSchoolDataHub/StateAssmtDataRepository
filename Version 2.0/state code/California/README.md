
# California Data Cleaning

This is a ReadMe for California's data cleaning process, from 2010 to 2023 (with the exception of 2014 and 2020).


## Setup

There are four folders you need to create: 
Original Data Files, NCES, Output, Cleaned DTA.

Download the original .xlsx files and place them into the "Original Data Files" folder. 

Download the NCES crosswalk (CA_DistSchInfo_2010_2024) from the CA Dist and School Info folder and place it in the main California folder.

Download the Unmerged_2024.xlsx file and place it in the main California folder.

There are 16 .do files. 

Run them in the following order:

california_dta_conversion.do; 

CA_NCES_New.do; 

california_`year'_clean.do;

CA_Science_2019_2024.do;


    
## File Path

The file path setup should be as follows: 

FOR the CA_NCES.do file ONLY: 

```
global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/California/NCES"
```

FOR the california_dta_conversion.do file ONLY: 
```
global original "/Volumes/T7/State Test Project/California/Original Data Files"
global CA_Folder "/Volumes/T7/State Test Project/California"
global data "/Volumes/T7/State Test Project/California/Cleaned DTA"
```

FOR the rest of the do files:

```
global data "/Volumes/T7/State Test Project/California/Cleaned DTA"
global nces "/Volumes/T7/State Test Project/California/NCES"
global output "/Volumes/T7/State Test Project/California/Output"
```
## Updates

- 03/10/2024: Responded to first round of 2024 data update review comments.
- 06/11/2023: Moved to new NCES files for all years and updated unmerged observations. Added new code to deal with additional unmerged observations.
- 6/15/23: Fixed mismatched ID's for all years.
- 6/27/24 Incorporated science data for 2019-2023.
- 11/10/24: Incorporated 2024, streamlined all do-files, redid nces merging by using crosswalk/dealt with mismatched dist and sch ids, brought state up to V2.0 conventions
