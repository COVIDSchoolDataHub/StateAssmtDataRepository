
# New Jersey Data Cleaning

This is a ReadMe for New Jersey's data cleaning process, from 2015 to 2024.
* Note that 2020 and 2021 are excluded, as NJ did not administer spring tests during those years due to COVID.


## Setup

There are four main folders you need to create: NCES, Original, Output, and Temp.
1. Download the original excel files from the Google Drive by downloading the folders (2015-2024), as well as:
      - NJ_EFParticipation_2022_ela.xlsx
      - NJ_EFParticipation_2022_sci.xlsx
      - NJ_EFParticipation_2022_math.xlsx
  and place them in the Original folder.
2. Download the NCES District Files, Fall 1997-Fall 2022 and NCES School Files, Fall 1997-Fall 2022, and place them in the NCES folder.
3. Download the NJ Cleaning 2015_2018 (when PARCC was administered), NJ Cleaning 2019_2023 (when NJSLA is administered), NJ_2024, NJ_EDFactsParticipation_2015_2021, and NJ_EDFactsParticipation_2022 do-files.

## File Path

The file path setup should be as follows: 

- global Original: Folder containing original data files
- global NCES: Folders containing NCES school & district files
- global Output: Folder containing cleaned data files
- global Temp: Folder containing .dta format versions of the original data

```bash
global Original "/Users/name/Desktop/New Jersey/Original"
global NCES "/Users/name/Desktop/New Jersey/NCES"
global Output "/Users/name/Desktop/New Jersey/Output"
global Temp "/Users/name/Desktop/New Jersey/Temp"
```
## Re-creating cleaning process

There are five do-files to re-create the output files: 
1. Run "NJ Cleaning 2015_2018.do" to clean the data for 2015-2018.
2. Run "NJ Cleaning 2019_2023.do" to clean the data for 2019-2023.
3. Run the NJ_EDFactsParticipation_2015_2021 do file to add in particpation data for 2015-2021.
4. Run the NJ_EDFactsParticipation_2022 do file to add in particaption data for 2022.
7. Run "NJ_2024.do" to clean the data for 2024.
## Updates

04/23/2024: Updated to add in unmerged NCES information and match new StudentGroup_TotalTested convention.
12/14/2024: Updated to add in new StudentGroup_TotalTested derivation
