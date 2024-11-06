
# New Hampshire Data Cleaning

This is a ReadMe for New Hampshire's data cleaning process, from 2015 to 2024.

## Setup

There are three main folders you need to create: NH State Testing Data, NCES District and School Demographics, and EDFacts.
There should be two folders within the NCES folder:
NCES District Files, Fall 1997-Fall 2022 and NCES School Files, Fall 1997-Fall 2022.
There should be a subfolder for each year in the EDFacts folder.  Use the wide version of the datasets, not the long version.
There should be two subfolders within the NH State Testing Data Folder: Original Data Files and Output.
Download the original csv files and place them into the Original Data Files folder (move the file in the data request subfolder to this general folder if you are downloading from Drive).

There are 2 .do files.  First run NH_Cleaning.do, and then run NH_EDFactsParticipationRate_2014_2018.do to merge participation rates in.
    
## File Path

The file path setup should be as follows: 

global Original: Folder with all original data files.
global Output: Folder transformed files.
global NCES: Folder containing NCES files (in district and school subfolders).
global EDFacts: Folder containing EDFacts files (in separate folders for each year).

```bash
global Original "/Users/miramehta/Documents/NH State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/NH State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

global EDFacts "/Users/miramehta/Documents/EDFacts"

```
## Updates

11/05/2024: UPdated to include 2024 data, derive additional values, and match V2.0 StudentGroup_TotalTested convention.