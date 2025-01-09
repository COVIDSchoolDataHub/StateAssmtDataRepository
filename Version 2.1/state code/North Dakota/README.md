
# North Dakota Data Cleaning

This is a ReadMe for North Dakota's data cleaning process, from 2015 to 2024.




## Setup

There are six folders you need: 
Original Data Files, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it). 

Download the original raw data .xlsx files ending in the Original Data Files folder on Google Drive.

There are 11 .do files. 

Run them in the following order:

ND Student Counts 15-21.do; 

ND Student Counts 22-24.do;

ND Cleaning `year'.do. 



    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/maggie/Desktop/North Dakota/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/North Dakota/NCES/District"
global NCES "/Users/maggie/Desktop/North Dakota/NCES/Cleaned"

global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

global data "/Users/maggie/Desktop/North Dakota/Original Data Files"
global output "/Users/maggie/Desktop/Mississippi/Output"
global Request "/Users/maggie/Desktop/Mississippi/Data Request"
```

## Updates

04/11/2024: Updated output files to incorporate new EDFacts files for 2022 and 2023, derived new student subgroups, and incorporated new NCES variables.

06/17/2024: Updated 2015 Flag_AssmtNameChange for math and ela to "Y". Updated StudentGroup_TotalTested to reflect the all students count for 2022 & 2023, and derived StudentSubGroup_TotalTested based on this value. This was done through an additional do-file, "North Dakota_StateTasks_Jun24". In the future, these changes should be made directly to the yearly do-files, but it is being uploaded separately for now as a stop-gap measure to get V1.1 out. 

09/24/2024: Incorporated 06/17/2024 updates in yearly do-files and added file to clean 2024 data.  Updated ND Student Counts 22-24 file to match new format of downloaded edfacts data.