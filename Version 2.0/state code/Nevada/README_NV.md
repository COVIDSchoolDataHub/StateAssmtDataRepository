
# Nevada Data Cleaning

This is a ReadMe for Nevada's data cleaning process, from 2016 to 2024.




## Setup

There are six folders you need: 
Original Data Files, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it). 

Download the original .csv files (should already be grouped by subject within the Original Data Files - Version 1.1 folder on Google Drive). 

There are 10 .do files. 

Run them in the following order:

Nevada Data Conversion.do; 

Nevada NCES Cleaning.do; 

Nevada `year' Cleaning.do. 


    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/maggie/Desktop/Nevada/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Nevada/NCES/District"
global NCES "/Users/maggie/Desktop/Nevada/NCES/Cleaned"

global raw "/Users/maggie/Desktop/Nevada/Original Data Files"
global output "/Users/maggie/Desktop/Nevada/Output"
```
## Updates

05/21/2024: Incorporated StudentSubGroup by GradeLevel data and updated new StudentSubGroup labels, new variable order, and new flag variables.
10/29/2024: Cleaned 2024 data, derived additional values for StudentSubGroup_TotalTested as well as level and ProficientOrAbove counts/percents,
and updated to match V2.0 StudentGroup_TotalTested convention.