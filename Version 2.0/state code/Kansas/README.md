
# Kansas Data Cleaning

This is a ReadMe for Kansas's data cleaning process, from 2015 to 2024.


## Setup

There are 6 main folders (with subfolders) you need to create: 

1. Raw
   
       a. Download the original excel files and place them into this folder.

2. temp [will start empty]
   
3. NCES District Files, Fall 1997-Fall 2022

      a. [Download files from Google drive district folder for NCES_2014 through NCES_2022]

4. NCES School Files, Fall 1997-Fall 2022

      a. [Download files from Google drive school folder for NCES_2014 through NCES_2022]
   
5. EdFacts [There are no subfolders]
   
      a. Download this folder from the Google drive. It will already have the 2022 files in it.
   
      b. Download all of the .csvs from the _EDFacts --> Datasets folder on the drive for 2015 to 2021 only. They should all be in the EdFacts folder with no subfolders. 

7. Output [will start empty]
    
## File Path

The file path setup should be as follows: 

```bash
   global raw "\Users\Clare\Desktop\Zelma V2.0\Kansas\Raw"
   global temp "\Users\Clare\Desktop\Zelma V2.0\Kansas\temp"
   global NCESDistrict "\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES District Files, Fall 1997-Fall 2022"
   global NCESSchool "\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES School Files, Fall 1997-Fall 2022"
   global EDFacts "\Users\Clare\Desktop\Zelma V2.0\Kansas\EdFacts"
   global output "\Users\Clare\Desktop\Zelma V2.0\Kansas\Output"
```

## Do File Order
There are 4 .do files, to be run in the following order:

Order
1. 01_Kansas_NCES.do [this preps the NCES files for merging]
2. 02_Kansas_Preparing ED Facts.do [this preps EDFacts files for merging in counts and participation]
3. 03_Kansas_YearlyCleaning.do [this cleans each raw Kansas data file + merges in NCES]
4. 04_Kansas_Merging with EDFacts.do [this merges in EDFacts data and calculates tested counts and level counts]
5. 05_Kansas_FinalEdits.do [produces final output]

## Updates

04/16/2024: Updated to remove school and district IDs from their names and to adjust StudentGroup counts to match the "All Students" value if the StudentGroup only contains one StudentSubGroup.

05/01/24: Updated to pull in updated NCES Fall 2022 data.

6/17/24: Uploaded Kansas_Updates_Jun24.do to apply new StudentGroup_TotalTested convention and derive Student counts for English Proficient where possible. This is a stopgap measure to get kansas ready for V1.1 and should probably be incorporated into the individual cleaning files at a future date.

12/4/24: Restructured code and incorporated 2024 data.
