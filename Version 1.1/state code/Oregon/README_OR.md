
# Oregon Data Cleaning

This is a ReadMe for Oregon's data cleaning process, from 2015 to 2023.
Note that there is not any data for 2020 due to COVID, and the data for 2021 are very different because of adjusted testing post-COVID.

## Setup

Create the following folders:
- OR State Testing Data (with two subfolders: Original Data and Output.)
- NCES District and School Demographics (with two subfolders: NCES School Files, Fall 1997-Fall 2022 and NCES District Files, Fall 1997-Fall 2022)
Download the original .xlsx files and place them into the "Original Data" subfolder. Download the NCES files and place them into the appropriate folders.

There are 2 .do files, one for 2021 and one for all other years.  You can run them in any order.
    
## File Path

The file path setup should be as follows: 

local Original: Folder containing original data files.
local Output: Folder in which output files will be saved.
local NCESSchool: Folder containing NCES School files.
local NCESDistrict: Folder containing NCES District files.

```bash
local Original "/Users/miramehta/Documents/OR State Testing Data/Original Data"
local Output "/Users/miramehta/Documents/OR State Testing Data/Output"
local NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
local NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"

## Updates

04/28/2024: Included additional subgroups, updated variable types and names, and changed StudentGroup_TotalTested calculation to match post-launch file format.