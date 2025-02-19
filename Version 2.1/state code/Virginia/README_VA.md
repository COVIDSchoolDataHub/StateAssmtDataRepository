
# Virginia Data Cleaning

This is a ReadMe for Virginia's data cleaning process, from 1998 to 2024.

## Setup

There are seven folders you need: 
Original Data, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it), and EDFacts.

Download the Original Data folder on Google Drive and keep files within the correct subfolders.

There are 30 .do files. You can run VA_Main_File.do to complete the entire cleaning process.

Alternatively, you can set the macros defined in "VA_Main_File" and then run the other do files individually in the following order:

01_Virginia NCES Cleaning.do; 

VA_`year'.do;

28_VA_EDFactsParticipation_2015.do;

29_VA Participation Rates_12.3.23.do.
    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/maggie/Desktop/Virginia/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Virginia/NCES/District"
global NCES "/Users/maggie/Desktop/Virginia/NCES/Cleaned"

global raw "/Users/maggie/Desktop/Virginia/Original Data"
global participation "/Users/maggie/Desktop/Virginia/Original Data/Participation Rates"

global output "/Users/maggie/Desktop/Virginia/Output"

global EDFacts "/Users/miramehta/Documents/EDFacts"
```
## Updates

04/27/2024: Incorporated new StudentSubGroups and updated to include new variables.

02/19/2025: Updated to include 2024 data and match new file name convention.