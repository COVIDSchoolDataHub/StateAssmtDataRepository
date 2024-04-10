
# Arkansas Data Cleaning

This is a ReadMe for Arkansas's data cleaning process, from 2009 to 2023.


## Setup
Create a folder for Arkansas. Inside that folder, create five more folders: 
Original, NCES, Output, Temp, and EDFacts. 

Download do-files and place them in the Arkansas folder.

Download the original .xlsx files and place them into the "Original" folder. Download the EDFacts data in Long .dta format and place them in the EDfacts folder. Download updated NCES files and place them in the NCES folder. Download ar_full-dist-sch-stable-list_through2023.xlsx and place it in the maine folder.

## Explanation of cleaning process
Each do-file cleans data that has a very similar structure. The data each do-file cleans is outlined below.


## Description of do-files
There are 8 do-files:

AR_Cleaning_2009_2014 - this do-file cleans all original data from 2009-2014.

AR_Cleaning_2015 - this do-file cleans all original data from 2015

AR_Cleaning_2016_2023 - this do-file cleans all data for the "All Students" SubGroup, for years 2016-2023 and all DataLevels.

AR_NoCountsSubGroupData_2016_2023 - this do-file cleans all data at the SubGroup level, for 2016-2018, and all District and School level SubGroup data 
for 2019-2023. Does not clean overlapping data with AR_StateSG_2019_2023 or ANY data from the "All Students" Subgroup.

AR_StateSG_2019_2023 - this do-file cleans all SubGroup data at the State level from 2019-2023.

AR_EDfacts_2016_2023 - this do-file cleans EDfacts data, merges StudentSubGroup_TotalTested and ParticipationRate where possible for District and School level subgroup data, and aggregates district level StudentSubGroup_TotalTested to the state level.

AR_StableNames - this do-file runs after all other do-files and replaces DistNames and SchNames across years with consistent names.

AR_Master - Runs all do files, sets file paths for all do-files, combines and sorts cleaned files for 2016-2023.

## Re-creating cleaning process
To recreate cleaning for all years, use only the AR_Master do-file. 

- Under "Set Directory for all folders", paste the directory for your Arkansas folder after the cd command. 
- Under "SET FILE DIRECTORIES BELOW," Set file directories to match each of the five folders created earlier next to the corresponding global command.

Run this do-file. 

To recreate cleaning for 2009-2014 only, run the AR_Cleaning_2009_2014 do-file and the AR_StableNames do-file.
To recreate cleaning for 2015 only, run the AR_Cleaning_2015 do-file and the AR_StableNames do-file.
To recreate cleaning for 2016-2023, just run the master file. 2009-2015 doesn't take much time and 2016-2023 relies on many data sources which need to be appended and then merged with EDFacts. If you really want to only clean 2016-2023, delete AR_Cleaning_2009_2014 and AR_Cleaning_2015 froom the local "dofiles" macro.

