
# Hawaii Data Cleaning

This is a ReadMe for Hawaii's data cleaning process, from 2015 to 2023.


## Setup
Create a folder for HI. Inside that folder, create two more folders: 
"Original", and "Output"

### Files to Download
- From the drive, download the Original Data - Version 1.1 Folder
- From github, download only the file named "Hawaii_DataRequestCleaning_AllYears.do"

### Directories
Set directories at the top of the do file:
```
global Original "/Volumes/T7/State Test Project/Hawaii/Original Data"
global Output "/Volumes/T7/State Test Project/Hawaii/Output"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
```
- "Original" refers to the original data downloaded from the drive
- "Output" is the output folder
- "NCES" should link to a folder containing updated (as of Feb 2024) NCES District and School files.

## Recreate Cleaning
1. Unhide the Importing Code
2. Run the do-file
3. On future runs you'll want to hide the importing code
