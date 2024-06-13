
# California Data Cleaning

This is a ReadMe for California's data cleaning process, from 2010 to 2023 (with the exception of 2014 and 2020).





## Setup

There are five folders you need to create: 
Original Data Files, NCES, Output, Unmerged Districts, Cleaned DTA.

Download the original .xlsx files and place them into the "Original Data Files" folder. 

Download the "ca_unmerged_may2024" file from the drive (California -> Unmerged -> Unmerged as of May 2024) and place it in the main California folder.

Download the NCES files for unmerged districts (.dta files) and place them into the "Unmerged Districts" folder.

There are 16 .do files. 

Run them in the following order:

california_dta_conversion.do; 

california_NCES_do_file.do; 

california_missing_NCES_updated.do;

california_`year'_clean.do. 

california_unmerged_PostClean.do



    
## File Path

The file path setup should be as follows: 

FOR the california_missing_NCES_updated.do file ONLY: 

global original "/Users/minnamgung/Desktop/SADR/California/Unmerged Districts"

FOR the california_NCES_do_file.do file ONLY: 

global NCESOld "/Users/minnamgung/Desktop/SADR/NCESOld"

global California1 "/Users/minnamgung/Desktop/SADR/California/NCES"

FOR the california_dta_conversion.do file ONLY: 

global original "/Users/minnamgung/Desktop/SADR/California/Original Data Files"

FOR the rest of the do files:

```bash
global nces "/Users/minnamgung/Desktop/SADR/California/NCES"
global output "/Users/minnamgung/Desktop/SADR/California/Output"
global unmerged "/Users/minnamgung/Desktop/SADR/California/Unmerged Districts"
```
## Updates

- 03/10/2024: Responded to first round of 2024 data update review comments.
- 06/11/2023: Moved to new NCES files for all years and updated unmerged observations. Added new code to deal with additional unmerged observations.
