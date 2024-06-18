
# Virginia Data Cleaning

This is a ReadMe for Virginia's data cleaning process, from 1998 to 2023.




## Setup

There are six folders you need: 
Original Data, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it). 

Download the Original Data folder on Google Drive and rename the "VA Participation Rates Received via Data Request - 12/1/23" folder within it "Participation Rates."

There are 27 .do files. 

Run them in the following order:

Virginia NCES Cleaning.do; 

VA_`year'.do;

VA Participation Rates_12.3.23.do.


    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/maggie/Desktop/Virginia/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Virginia/NCES/District"
global NCES "/Users/maggie/Desktop/Virginia/NCES/Cleaned"

global raw "/Users/maggie/Desktop/Virginia/Original Data"
global participation "/Users/maggie/Desktop/Virginia/Original Data/Participation Rates"

global output "/Users/maggie/Desktop/Virginia/Output"
```
## Updates

04/27/2024: Incorporated new StudentSubGroups and updated to include new variables.