
# Arizona Data Cleaning

This is a ReadMe for Arizona's data cleaning process, from 2010 to 2023.




## Setup

There are six folders you need: 
AASA, AIMS, AzMERIT, AzSci, NCES, Output (and a csv folder within it). 

Download the original .xlsx files (should already be grouped by exam within the Original Data Files folder on Google Drive). 

There are 15 .do files. 

Run them in the following order:

NCES_clean copy.do; 

AZ EDFacts.do; 

`exam'_Clean_`year'.do. 

Remember to un-comment the beginning of each `exam'_Clean_`year'.do file when running for the first time to convert files into .dta format.



    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/maggie/Desktop/Arizona/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Arizona/NCES/District"
global NCES "/Users/maggie/Desktop/Arizona/NCES/Cleaned"

global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

global AIMS "/Users/maggie/Desktop/Arizona/AIMS"
global AzMERIT "/Users/maggie/Desktop/Arizona/AzMERIT"
global AASA "/Users/maggie/Desktop/Arizona/AASA"
global AzSci "/Users/maggie/Desktop/Arizona/AzSci"

global output "/Users/maggie/Desktop/Arizona/Output"
```
## Updates

03/06/2024: Updated new StudentGroup/StudentSubGroup labels; New variable order/sort; New flag variables.