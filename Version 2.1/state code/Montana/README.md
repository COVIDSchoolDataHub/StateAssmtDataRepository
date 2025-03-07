
# Montana Data Cleaning

This describes Montana's data cleaning process, from 2016-2024.

## Do-file order:
You can set macros in MT_Main_File.do and run this file to compelte the entire cleaning process.

Alternatively, after setting macros, you can run the do files individually in the following order:

1. MT_NCES.do
2. MT_School_Cleaning.do
3. MT_District_Cleaning.do
4. MT_State_Cleaning.do

## Data to download

Download the entire folder "Original Data Files Version 2.1". Do not remove files from their subfolders.

## Directories

`global NCES_Dist` should link to original NCES district files

`global NCES_School` should link to original NCES school files

`global NCES_MT` should link to a new folder inside your Montana folder

`global Original` should link to the folder containing Original data (Version 2.1 overall folder)

`global ELA_Math` should link to the folder containing district-level ELA & math downloads

`global Sci` should link to the folder containing district-level science downloads

`local Original` (in the MT_State_DemograohicData.do file) should link to the Montana state-level data downloads folder

`global Output` should link to a new folder containing output data.

## Notes for MT_District_Cleaning

1. Unhide the code at the top of the main file if you don't have the "filelist" package:
```
*ssc install filelist
```
Rehide this code after installing.

2. Importing code in the district level file should be hidden after first run.

## Updates
12/16/24: Applied numerous derivations as noted in CW and brought MT up to V2.0.
03/05/25: Cleaned newly downloaded data (newly includes 2024 data, state-level subgroup sci data, + district level sci data) and school level G38 data received via DR 01/06/24.