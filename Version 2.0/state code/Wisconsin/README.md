
# Wisconsin Data Cleaning

This is a ReadMe for Wisconsin's data cleaning process, from 2016 to 2024.


## Setup
Create a folder for WI. Inside that folder, create four more folders: 
"Original", "NCES", "Temp", and "Output"

### Files to Download
- From the drive, download the Original Data - Version 1.1 Folder. Put these in the "Original" folder.
- Also from the drive, download the NCES school and district files for 2016-2022 from the Data Cleaning Materials - NCES District and School Demographics folder. Put these in the "NCES" folder.
  
### Directories
Set directories at the top of the do file:
```
global path "/Users/kaitlynlucas/Desktop/Wisconsin/Original Files"
global nces "/Users/kaitlynlucas/Desktop/Wisconsin/nces"
global output "/Users/kaitlynlucas/Desktop/Wisconsin/output"
global temporary "/Users/kaitlynlucas/Desktop/Wisconsin/temp"
```
- "Original" refers to the original data downloaded from the drive
- "Output" is the output folder
- "NCES" is the NCES District and School files folder (2016-2022)
- "Temp" is where the code will temporarily store files to deal with suppressed data

## Recreate Cleaning
1. Unhide the Importing Code at the top of each do file
2. Run the do-files
3. On future runs you'll want to hide the importing code
