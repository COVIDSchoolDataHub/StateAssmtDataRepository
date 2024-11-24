
# Illinois Data Cleaning

This is a ReadMe for Illinois's data cleaning process, from 2015 to 2024.


## Setup
Create a folder for IL. Inside that folder, create two more folders: 
"Original", and "NCES"

1. Download do-files and place them in the IL folder.
2. Download the "Datasets" folder in the EDFacts folder under _Data Cleaning Materials
3. Make sure you're using updated NCES files 
4. Set Directories as follows:
The `cd` command should map to the IL folder
`NCESSchool` should map to the folder containing NCES .dta files at the school level
`NCESDistrict` should map to the folder containing NCES .dta files at the district level
`NCES` should map to the NCES folder inside the IL folder.
`EDFacts` should map to the folder containing the EDFacts datasets exactly as formatted in the drive, where each year is its own folder.
`raw` and `output` should both map to the Original folder
- As an aside, both the final output and the raw files will be found in the "Original" folder. Cleaned files are identified by their name, "IL_AssmtData_`year'" in .csv format. Feel free to change this, just make sure to note changes in this file.

## Recreating Cleaning Process
- Run the Illinois DTA conversion file or the Illinois Cleaning Merge files first. Make sure to check the do-files for hidden importing code on the first run (this is always at the top of the file)
- Run the yearly cleaning files after these files in any order.
- To clean all years at once after running the conversion and merge do-files, run the following code:
```
cd "[YOUR FOLDER PATH FOR IL]"
forvalues year = 2015/2024 {
if `year' == 2020 continue
do Illinois `year' Cleaning
}
```











