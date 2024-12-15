# Rhode Island
This is a ReadMe for Rhode Island's cleaning process, from 2018-2024

## Setup

Create the following folders:
- Main Rhode Island Folder
  - Original Data Files
  - Output
  - NCES

- Download all excel files in the Original Data folder on the drive. Place them in the Original Data Folder.
- Download **both** crosswalks from the main folder in the drive. Place them in the Main RI folder.
- Download the following files from github
  - RI_Cleaning_2018_2024.do
  - RI_Data_Conversion.do
  - RI_NCES.do  

Set directories in the do files as follows:

RI_NCES:

```
global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Original NCES data from drive
global NCES "/Volumes/T7/State Test Project/Rhode Island/NCES" //NCES folder created above
```
RI_Cleaning_2018_2024 and RI_Data_Conversion

```
cd "/Volumes/T7/State Test Project/Rhode Island" //Directory to main RI folder
global Original "/Volumes/T7/State Test Project/Rhode Island/Original" //Original Data folder created above
global Output "/Volumes/T7/State Test Project/Rhode Island/Output" //Output folder created above
global NCES "/Volumes/T7/State Test Project/Rhode Island/NCES" //NCES folder created above
```

## Re-create Cleaning Process
1. Run the RI_NCES.do file and the RI_Data_Converstion.do files in any order. 
2. Run the RI_Cleaning_2018_2024 file.

## Notes
Level percentages had varying formats (e.g, they were both decimals and percentages, and there was no pattern). They were determined to be a percent or a decimal based on the following process:

1. Automatically assigned as a percentage value if the raw data contained "%" after the value
2. Automatically assigned as a percentage value if the number was over 1.
3. Remaining were decimals, but could not distinguish between a decimal (0.9) and a decimal percentage (0.9%). This problem only applied to Lev4_percent. Determined to be a percentage if and only if the sum of all percents was too high.

Two crosswalks used to merge NCES data. Both include most schools, but only by using them together can we get all IDs for now. Something to streamline later.

## Updates
12/13/24: Recleaned all RI data using new scraped data from 2018-2024
12/15/24: Responded to R1
