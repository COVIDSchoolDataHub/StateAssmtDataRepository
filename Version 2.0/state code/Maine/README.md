
# Maine Data Cleaning

This is a ReadMe for Maine's data cleaning process, from 2015 to 2023.

## Folders
Create 3 folders: Output, Original, and NCES

## Directories
- Set directories at the top of each do-file next to the global macros. The directories are as follows:

cd "/Volumes/T7/State Test Project/Maine" //This should link to the Main Maine folder

global Original "/Volumes/T7/State Test Project/Maine/Original Data Files" //This should link to the folder containing all original data

global Output "/Volumes/T7/State Test Project/Maine/Output" //This should link to an empty folder where the output will be generated.

global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //NCES school files available from the drive

global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //NCES District files available from the drive


## Recreating Cleaning Process
- Two options for first step: 
1. (recommended) Download original data in .csv format directly from the drive under the "Separated by year" folder. This will save you the 20 minutes it takes stata to import and convert the .xlsx files to .csv format
2. Download the "true" original data in .xlsx format. Run the "Splitting by year" do-file. This will create the .csv files in the drive folder.

- Download NCES District and School data from the folder on Drive (can combine both types and the do files clean the files for you).
  
- After downloading and setting directories in all do-files in github, run the ME_Master.do file. It is necessary to run this file to fully recreate the cleaning process as there are additions to each year inside that do-file.

- To make changes, add them to the yearly do-files as opposed to the master do-file.

## Updates

8/16/24: Added data request data.

12/16/24: Updated to V2.0 conventions.









