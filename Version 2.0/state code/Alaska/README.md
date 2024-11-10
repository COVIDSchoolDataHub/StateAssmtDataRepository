# Alaska Data Cleaning

This is a ReadMe for Alaska's data cleaning process, from 2017 to 2024.

## Setup

Create a folder for AK. Inside that folder, create five more folders: Original, Output, Temp, NCESnew, NCESold

Download do-files and place them in the AK folder.

Download the AK_OriginalData_2015_2022, AK_OriginalData_2023, and AK_OriginalData_2024 from the drive and place them into the "Original" folder. Download updated NCES .dta files and place them in the NCES folder.

## Explanation of cleaning process

There are four do-files: 
- alaska_NCES_do_file_updates.do cleans the NCES files.
- alaska_updated_do_file cleans 2017-2022, based on the delimited file AK_OriginalData_2015_2022.
- AK_2023 cleans 2023 based on the delimited file AK_OriginalData_2023.
- AK_2024 cleans 2024 based on the delimited file AK_OriginalData_2024.

Run the NCES file first. Run the other files in any order you choose.

## Re-creating cleaning process

For the NCES do-file, set directories as follows:

```         
cd "/Volumes/T7/State Test Project/Alaska"
log using alaska_nces_cleaning.log, replace

global NCESOriginal "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_AK "/Volumes/T7/State Test Project/Alaska/NCES_AK"
```

Where `cd` is the AK folder, `NCESOriginal` is the folder containing original NCES data, and `NCES_AK` is the folder that outputs cleaned NCES files for Alaska.

For the alaska_updated_do_file, set directories as follows:

```         
cap log close
set trace off

cd "/Volumes/T7/State Test Project/Alaska"
log using alaska_cleaning.log, replace

global Original "/Volumes/T7/State Test Project/Alaska/Original"
global Output "/Volumes/T7/State Test Project/Alaska/Output"
global Temp "/Volumes/T7/State Test Project/Alaska/Temp"
```

Where `Original` contains the original delimited file AK_OriginalData_2015_2022. `Temp` contains temporary files during the cleaning process, and `Output` will contain the cleaned files.

When running for the first time, unhide the below code by removing the /\* and \*/:

```         
/*
//New Importing Code
import delimited "$Original/AK_OriginalData_2015_2022", varnames(nonames) clear 
save "$Original/alaska_updated_original", replace
clear
*/
```

For the AK_2023 do file, set directories as follows:

```         
cd "/Volumes/T7/State Test Project/Alaska"

global Original "/Volumes/T7/State Test Project/Alaska/Original"
global Output "/Volumes/T7/State Test Project/Alaska/Output"
global NCES "/Volumes/T7/State Test Project/NCES/"
```

Where `Original` contains the original delimited file AK_OriginalData_2023, `Output` is the folder with the cleaned files, and, importantly, **`NCES` is the original (uncleaned) NCES data downloaded directly from the drive.**

Unhide the below code on the first run:
```
/*
//Importing
import delimited "$Original/AK_OriginalData_2023", case(preserve) stringcols(_all)
save "$Original/AK_OriginalData_2023", replace
*/
```
For the AK_2024 do file, set directories as follows and run the code:

```         
cd "/Volumes/T7/State Test Project/Alaska"

global Original "/Volumes/T7/State Test Project/Alaska/Original"
global Output "/Volumes/T7/State Test Project/Alaska/Output"
global NCES "/Volumes/T7/State Test Project/NCES/"
```

Where `Original` contains the original delimited file AK_OriginalData_2024, `Output` is the folder with the cleaned files, and, importantly, **`NCES` is the original (uncleaned) NCES data downloaded directly from the drive.**

Run the do-file
Unhide the below code on the first run:
```
/*
//New Importing Code
import excel AK_OriginalData_2024.xlsx, clear 
save "$Original/AK_OriginalData_2024", replace
export delimited AK_OriginalData_2024.csv, replace 
clear all
*/
```


