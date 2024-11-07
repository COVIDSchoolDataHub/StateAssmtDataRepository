
# Wisconsin Data Cleaning

This is a ReadMe for Wisconsin's data cleaning process, from 2016 to 2024.


## Setup
Create a folder for WI. Inside that folder, create four more folders: 
1. "Original"
  - From the drive, download the files in the "Original Data Files" folder. Save these in the "Original" folder.
2. "NCES"
  - From the drive, download the NCES school and district files for 2016-2022 from the Data Cleaning Materials - NCES District and School Demographics folder. Put these in the "NCES" folder. All district and school files should be together in this folder (no subfolders).
3. "Temp"
  - This will start empty.
4. "Output"
  - This will start empty. 

### Directories
Set directories at the top of the do file:
```
global path "/Users/kaitlynlucas/Desktop/Wisconsin/Original Files"
global nces "/Users/kaitlynlucas/Desktop/Wisconsin/nces"
global temporary "/Users/kaitlynlucas/Desktop/Wisconsin/temp"
global output "/Users/kaitlynlucas/Desktop/Wisconsin/output"

```
- "Original" refers to the original data downloaded from the drive
- "NCES" is the NCES District and School files folder (2016-2022)
- "Temp" is where the code will temporarily store files to deal with suppressed data
- "Output" is the output folder

## Recreate Cleaning
1. Unhide the Importing Code at the top of each do file. (On future runs you'll want to hide the importing code)
2. Run the do-files in order from 2016 onward. 
