
# Wyoming Data Cleaning

This is a ReadMe for Wyoming's data cleaning process, from 2014 to 2024.

## Setup

There are three main folders you will need to create:
1. NCES District and School Demographics, with subfolders for school, district, and cleaned data.
2. EDFacts, with subfolders for each year from 2014-2024 (contains the wide .csv files).
3. Wyoming, with subfolders for original data and for output.

Download the original data from the V2.0+ subfolder on Drive.

There are 5 .do files. 

You can either run WY_Main_File.do to comlete the cleaning process or set macros in this file and run the others individually as follow:

01_WY_Reg_Alt.do;

02_WY_Reg.do

03_WY_EDFacts_14_21.do;

04_WY_EDFacts_2022.do.

There are notes in the first three files where code can be hidden after the first run because it is meant to import files.

## Updates
- 06/27/2024: Updated AssmtType to Regular and alt using the WY_StateTask_Jun24 do-file. This should be incorporated into the cleaning do-file at a later date.
- 07/23/2024: WY_Cleaning.do has been combined with Cleaning_NCES.do and combines the process of cleaning the NCES files and then merging them with WY_Assmt_Data. WY_EDFacts.do has been updated to use the current cleaning code for wide-form Original Data and accounts for "All Students" count. Also accounts for changing AssmtType from "regular" to "regular and alt".
- 11/17/2024: Updated WY_Cleaning.do to include state task from June.
- 02/26/2024: Updated to incorporate "regular" data received via data request for 2019-24 and match file setup to new conventions.
