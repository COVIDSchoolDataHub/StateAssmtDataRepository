## North Carolina Cleaning ReadMe
This is a ReadMe for North Carolina's data cleaning process, from 2014 to 2024.

## Setup
Create three folders: NC State Testing Data, NCES District and School Demographics, and EDFacts.
- Download files from the Original Data Files folder on Drive and put them in the NC State Testing Data folders.
- Create district and school subfolders in the NCES folders; download NCES files and file them appropriately. 
- Create a subfolder for every year prior to 2021 in the EDFacts folder and store the wide versions of the EDFacts datasets there.

## Files to Download

1. From the drive, download the Original Data files from 2014-2024 -  Version 2.0 folder. There are ten original csv files/text files. Save these files to the "Original" folder
2. From the drive, download NCES District and School files from the "NCES District and School Demographics" folder, within the "Data Cleaning Materials" folder. There should be ten NCES_District files and ten NCES_School files. Save these files to the "NCES" folder
3. From Github, download the following do-files:
   a. "NC_nces.do"
   b. "nc_do.do" 
   c. "NC_2024.do"
   d. "NC_EDFactsParticipation_2014_2021.do"
   e. "NC_EDFactsParticipation_2022.do"

## Directories
```
Set directories at the top of the do file:
global data "/Users/miramehta/Documents/NC State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global EDFacts "/Users/miramehta/Documents/EDFacts"
```
- "data" refers to the folder with original data files downloaded from Drive and is where the transformed output files will be saved
- "NCES" should link to a folder containing downloaded NCES District and School files (till 2022) 
- "EDFacts" should link to a folder containing downloaded EDFacts datasets (with subfolders for each year before 2022) 

## Recreate Cleaning
1. Run the "nc_nces" do file this will create NCES files for the current year and the "NC_district_id" files to merge in for missing DistNames
2. Run "nc_do" file. This will create the relevant output files from 2014-2023
3. Run the "NC_EDFactsParticipation_2014_2021" do file, which should add in participation data for those years
4. Run the "NC_EDFactsParticipation_2022" do file, which should add in participation data for those years
5. Run the "NC_2024" file to generate the cleaned 2024 dataset

## Updates
12/06/2024: Updated to derive additional values.