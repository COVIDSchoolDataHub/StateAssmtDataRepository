# Rhode Island
This is a ReadMe for Rhode Island's cleaning process, from 2018-2024

## Setup
- Download all excel files in the Original Data folder on the drive
- Download the **two** crosswalks from the main folder in the drive
- Download the following files from github
  - RI_Cleaning_2018_2024.do
  - RI_Data_Conversion.do
  - RI_NCES.do

Create the following folders:
- Main Rhode Island File
  - Original Data Files
  - Output
  - NCES
  


Set directories in the do files as follows:
RI_NCES:

```
global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Original NCES data from drive
global NCES "/Volumes/T7/State Test Project/Rhode Island/NCES" //
