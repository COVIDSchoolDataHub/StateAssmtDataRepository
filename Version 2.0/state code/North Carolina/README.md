## North Carolina Cleaning ReadMe
This is a ReadMe for North Carolina's data cleaning process, from 2014 to 2024

## Setup
Create a folder for NC. Inside that folder, create three more folders: 

1. "Original"
2. "NCES" 
3. "Output"

## Files to Download

1. From the drive, download the Original Data files from 2014-2024 -  Version 2.0 folder. There are ten original csv files/text files. Save these files to the "Original" folder
2. From the drive, download NCES District and School files from the "NCES District and School Demographics" folder, within the "Data Cleaning Materials" folder. There should be ten NCES_District files and ten NCES_School files. Save these files to the "NCES" folder
3. From Github, download the do-file named "nc_nces"
4. Save these files to the "NCES" folder
5. From Github, download the "nc_do" file
6. From Github, download the "NC_EDFactsParticipation_2014_2021" do-file and the "NC_EDFactsParticipation_2022" do-file
7. These can be saved to the "Original" folder

## Directories
```
Set directories at the top of the do file:
Users/name/Desktop/North Carolina
global Original Users/name/Desktop/North Carolina/Original
global Output Users/name/Desktop/North Carolina/Output
global NCES Users/name/Desktop/North Carolina/NCES
```
- "Original" refers to the original data downloaded from the drive and github
- "Output" is the output folder
- "NCES" should link to a folder containing downloaded NCES District and School files (till 2022) 

## Recreate Cleaning
1. First run the "nc_nces" do file this will create NCES files for the current year and the "NC_district_id" files to merge in for missing DistNames
2. Save these to the "NCES" folder
3. Then run the "nc_do" file. This will create the relevant output files from 2014-2023
4. Save these to "Output"
5. Then run the 2014-2021 output files through the "NC_EDFactsParticipation_2014_2021" do file, which should add in participation data for those years
6. Then run the 2022-2023 output files through the "NC_EDFactsParticipation_2022" do file, which should add in participation data for those years
7. Finally, from Github, run the "NC_2024" file to generate the cleaned 2024 dataset
8. Save this to "Output"
