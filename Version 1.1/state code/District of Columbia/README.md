
# DC Data Cleaning

This is a ReadMe for DC's data cleaning process, from 2015 to 2023.


## Setup
Create a folder for DC. Inside that folder, create three more folders: 
Original, NCES, Output

Download do-files and place them in the DC folder.

Download the original files and place them into the "Original" folder. Download updated NCES files and place them in the NCES folder.

## Explanation of cleaning process
Each do file corresponds to its own year, except the DC_ParticipationRate_2015_2022. You may run the yearly do-files in any order, but make sure to run the participation rate do-file last. 

## Description of do-files
Beyond the yearly do-files, which just cleans the respective year, the DC_Master file recreates the cleaning process after all directories have been updated, and the DC_ParticipationRate_2015_2022 file merges in separate participation data for the applicable years. This file can only run after each year has been cleaned.

## Re-creating cleaning process
For each do file, set file directories at the top corresponding to the folders created earlier. The code looks like this:
```
global Output "/Volumes/T7/State Test Project/District of Columbia/Output"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
cd "/Volumes/T7/State Test Project/District of Columbia"
```
Where `cd` corresponds to the parent "DC" folder, and the other directories are self-evident.

Where applicable, un-hide the importing code at the beginning on the first run of the do-file. This is hidden to speed up the cleaning process on future runs. 

