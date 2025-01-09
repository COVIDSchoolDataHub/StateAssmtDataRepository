
# Montana Data Cleaning

This describes Montana's data cleaning process, from 2016-2023.

## Do-file order:
1. MT_NCES.do
2. MT_State_All_Students_Cleaning.do
3. MT_State_DemographicData.do
4. MT_District_Cleaning.do
5. MT_Combining_DataLevels.do

## Data to download

Download the entire folder "Original Data Files Version 1.1". **DELETE THE DATA REQUEST DATA ON YOUR COMPUTER.**

## Directories
`global NCES_Original` should link to original NCES files

`global NCES_MT` should link to a new folder inside your Montana folder

`global Original` should link to the folder containing Original data  *for the do-file you're currently running*

`local Original` (in the MT_State_DemograohicData.do file) should link to the Montana state-level data downloads folder

`global Output` should link to a new folder containing output data.

`local Output` (in the MT_State_Demographic data) should link to the same output folder as above

`global Excel_Files` should link to the folder containing the district level excel files

`global Combined_Stata` should link to any folder that makes organizing easier. Currently set to the original data folder.

## Notes for MT_District_Cleaning

1. Unhide the code at the top if you don't have the "filelist" package:
```
*ssc install filelist
```
Rehide this code after installing

2. Unhide the importing Code on your first run. This combines the district level files.

## Updates
12/16/24: Applied numerous derivations as noted in CW and brought MT up to V2.0
