
# Hawaii Data Cleaning

This is a ReadMe for Hawaii's data cleaning process, from 2015 to 2024.

## Setup
Create a folder for HI. Inside that folder, create three more folders: 
"Original" and "Output" and "NCES"

### Files to Download
- From the drive, download the Original Data - Version 1.1+ Folder
- From the drive, download NCES district and school files (2014-2022, or newest NCES year) and place them into the "NCES" folder. The do file cleans the NCES files so no need to clean them with another do file. 
- From github, download the files named "HI_OriginalData_DataRequest_2015to2023.do" and "HI_2024_1.30.25.do"

### Directories
Set directories at the top of the do file:
```
global Original "/Users/kaitlynlucas/Desktop/Hawaii/Original"
global Cleaned "/Users/kaitlynlucas/Desktop/Hawaii/Output"
global NCES "/Users/kaitlynlucas/Desktop/Hawaii/NCES"
```
- "Original" refers to the original data downloaded from the drive
- "Output" is the output folder
- "NCES" is the folder containing updated (as of Feb 2024) NCES District and School files.

## Recreate Cleaning
1. Unhide the Importing Code
2. Run HI_OriginalData_DataRequest_2015to2023.do
3. Run HI_2024_1.30.25.do
4. On future runs you'll want to hide the importing code

## Notes
The 2015-2023 file in the Original Data - Version 1.1+ folder is the same as "HalloranDataRequest20240409". Removed 2013 and 2014 files from the Original Data V1.1+ folder.
