# Massachusetts ReadMe
This ReadMe describes Massachusetts' cleaning process, from 2010-2024.

## Recreating Cleaning Process

#### You should create four folders:
- Original Data
- Output
- NCES
- Temp

These folders correspond to the directories in the do-files.

#### Setup
- Download all files in the Original Data - Version 2.0 folder on the drive
- Make sure you have NCES data
- Download the spreadsheet ma_full-dist-sch-stable-list_through2024 from the MA DistNames folder and place it in the main Massachusetts folder
- Download the spreadsheet MA_Unmerged_2024 from the main folder and place it in the main Massachusetts folder

#### Recreate Cleaning Process (do-file order)
1. MA Data Conversion
2. MA_NCES_New
3. MA_2010_2014, MA_2015_2016, MA_2017_2024 (order doesn't matter)
4. MA_ParticipationRate

## Notes & Updates
- When 2024 data is released, the code only needs to be modified slightly so that the loops include 2024, since the data will be in the same format as the data we currently have.
- 9/26/24: 2024 added
- 10/9/2024: Stabilized DistNames & SchNames
- 10/13/2024: Completely recleaned 2010-2016 for V2.0. Modified entire cleaning structure (including 2017-2024) for simplicity.
