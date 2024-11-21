# South Dakota Cleaning

This ReadMe outlines South Dakota's cleaning process, from 2003 to 2024

## Setup

Create three subfolders within your main South Dakota folder:

1. Original Data
   - This folder should include all data downloaded from the "Files currently used" folder in the drive. No other downloads are necessary.
     
2. Output
   
3. Stata .dta versions

## Recreate Cleaning

There are 4 files to run (and five to download):
- SD_2003_2013 (run)
- SD_2014_2017 (run)
- SD_EDFactsParticipation_2014_2017 (do ***not*** run)
- SD_2018_2023 (run)
- SD_2024 (run)

Run the do-files in any order you like. As a note, SD_EDFactsParticipation_2014_2017 will run on its own when you run the SD_2014_2017 do-file. Set directories as follows:

```
global Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
global Output "/Volumes/T7/State Test Project/South Dakota/Output"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Stata_versions "/Volumes/T7/State Test Project/South Dakota/Stata .dta versions"
```
Where each global command corresponds to a subfolder created above (or NCES data for NCES_District and NCES_School).

- As a note, in order to recreate cleaning on the first run, you need to unhide some importing code. Namely, each do file includes code that looks like the following that must be unhidden:
  
```
// import excel "$Original/SD_OriginalData_`year'.xlsx", firstrow case(preserve) clear allstring
// save "$Original/SD_OriginalData_`year'", replace
```
You should re-hide the code after the first run.

## Updates
- 11/20/24: Cleaned SD 2024, brought prior years up to Version 2.0 standards and completed self review. Created ReadMe.

