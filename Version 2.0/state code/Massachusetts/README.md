# Massachusetts ReadMe
This ReadMe describes Massachusetts' cleaning process, from 2017-2023. Note that 2010-2023 is available on Zelma, and the do-files to clean it are located here, however this document focuses exclusively on 2017-2023.

## Recreating Cleaning Process

#### You should create three folders:
- Original Data
- Output
- NCES

These folders correspond to the directories in the do-files.

#### Download the following files from the Original Data folder in the drive and place them in your Original Data folder:
- MA_OriginalData_2017_2023.csv
- ma_district_science.xlsx
- ma_school_science.xlsx

#### For 2017-2023, run the following files in the order listed below:

1. MA_NCES_New
2. MA_Cleaning_2017_2023

## Notes & Updates
- When 2024 data is released, the code only needs to be modified slightly so that the loops include 2024, since the data will be in the same format as the data we currently have.