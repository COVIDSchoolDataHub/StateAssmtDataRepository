
# Pennsylvania Data Cleaning

This is a ReadMe for Pennsylvania's data cleaning process, from 2015 to 2024.
* Note that 2020 is excluded, as PA did not administer spring tests during that year due to COVID.


## Setup

There are four main folders you need to create: NCES District and School Demographics (NCES), Original, Output, and Temp.
1. Download the original excel files from the Google Drive:
      - PA_2022_OriginalData_School.xlsx
      - PA_EFParticipation_2022_ela.xlsx
      - PA_EFParticipation_2022_sci.xlsx
      - PA_EFParticipation_2022_math.xlsx
      - PA_OriginalData_2023_Subgroups_District.xlsx
      - PA_OriginalData_2023_Subgroups_State.xlsx
      - PA_OriginalData_2023_Subgroups_School.xlsx
      - PA_OriginalData_2024_District.xlsx
      - PA_OriginalData_2024_State.xlsx
      - PA_OriginalData_2024_School.xlsx
  and place them in the Original folder.
2. Download the NCES District Files, Fall 1997-Fall 2022 and NCES School Files, Fall 1997-Fall 2022, and place them in the NCES folder.
3. Download the PA_2022.do, PA_2023.do, PA_2024.do, PA_All_DataRequest.do, PA_EDFactsParticipation_2015_2021, and PA_EDFactsParticipation_2022 do-files.
   
## File Path

The file path setup should be as follows: 

- global Original: Folder containing original data files
- global NCES: Folders containing NCES school & district files
- global Output: Folder containing cleaned data files
- global Temp: Folder containing .dta format versions of the original data

```bash
global Original "/Users/name/Desktop/Pennsylvania/Original"
global NCES "/Users/name/Desktop/Pennsylvania/NCES"
global Output "/Users/name/Desktop/Pennsylvania/Output"
global Temp "/Users/name/Desktop/Pennsylvania/Temp"
```
## Re-creating cleaning process

There are six do-files to re-create the output files: 
1. Run "PA_All_DataRequest.do" to clean the data for 2015-2022. The specific code for each year is also hidden -- unhide as needed to get the years you want.
2. Run the PA_EDFactsParticipation_2015_2021 do file to add in particpation data for 2015-2021.
3. Run "PA_2022.do" to clean the data for 2022.
4. Run the PA_EDFactsParticipation_2022 do file to add in particaption data for 2022.
5. Run "PA_2023.do" to clean the data for 2023.
6. Run "PA_2024.do" to clean the data for 2024.

## Updates

- 05/07/2024: Updated to incorporate post-launch formatting changes, including including SWD for 2023, use updated NCES files, and generate counts for 2023 data.
- 12/08/2024: Aggregated in some missing data in 2022 with a public data request file.
- 12/08/2024: Updated the StudentGroup_TotalTested derivation for all years.
