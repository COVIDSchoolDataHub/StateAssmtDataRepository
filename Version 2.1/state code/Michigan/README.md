
# Michigan Data Cleaning

This is a ReadMe for Michigan's data cleaning process, from 2015 to 2024.





## Setup

There are four folders you need to create: 
Original Data Files, NCES, Output (and a csv folder within it). 

Download the original .xlsx files and place them into the "Original Data Files" folder. 

Make sure to have downloaded edfacts data from the drive and downloaded 2022 edfacts participation data for Michigan.

There are 12 .do files. 

Run them in the following order:

Michigan DTA Conversion.do; 

Michigan NCES Cleaning.do; 

Michigan `year' Cleaning.do. 

MI_EDFactsParticipation_2015_2021.do

MI_EDFactsParticipation_2022.do

    
## File Path

The file path setup should be as follows: 

global NCESOld: Folder containing original NCES files.

global NCESNew (or global NCES): Folder containing cleaned (Michigan specific) NCES files used for merging. 


```bash
global NCESNew "/Users/minnamgung/Desktop/SADR/Michigan/NCES"
global NCESOld "/Users/minnamgung/Desktop/SADR/NCESOld"

global raw "/Users/minnamgung/Desktop/SADR/Michigan/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Michigan/Output"
global NCES "/Users/minnamgung/Desktop/SADR/Michigan/NCES"
```
## Updates

02/28/2024: Updated new StudentGroup/StudentSubGroup labels; merged in 2022 NCES data for 2023 (with the exception of DistType, DistLocale, CountyCode, CountyName which were retrieved from 2021 files); New variable order/sort; New flag variables; Variable type conversion.

05/13/2024: Updated NCES data with new data files, including for 2023.

07/12/2024: Updated files for V2.0 to include ParticipationRate. Reorganized Count Generation.

09/09/2024: Added 2024 data, included additional derivations, applied StudentGroup_TotalTested convention across years.
