
# Kentucky Data Cleaning

This is a ReadMe for Kentucky's data cleaning process, from 2012 to 2024.

## Setup

There are two main folders you need:
- KY State Testing Data: Create one subfolder called Original Data Files and one called Output.
- NCES District and School Demographics: Create one subfolder called NCES District Files, Fall 1997-Fall 2022 and
  one called NCES Schools Files, Fall 1997-Fall 2022.

Download the original .xlsx and .csv files and place them in the Original Data Files folder. 

There are 4 .do files. 

Run them in the following order:

1. KY_Cleaning_2012_2023.do
2. KY_StudentCounts_2022.do
3. KY_EDFactsParticipation_2022.do
4. KY_Cleaning_2024.do

Remember to un-comment the beginning of the cleaning .do files to convert original files into .dta format.
    
## File Path

The file path setup should be as follows: 

```bash
global Original "/Users/miramehta/Documents/KY State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/KY State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
```
## Updates

12/02/2024: Added 2024 data and updated StudentGroup_TotalTested to match V2.0 convention.