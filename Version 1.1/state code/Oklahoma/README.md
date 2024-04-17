
# Oklahoma Data Cleaning

This is a ReadMe for Oklahoma's data cleaning process, from 2017 to 2023.




## Setup

There are seven folders you need: 
Original Data Files, Data Request, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it). 

Download the original raw data .xlsx files within the Original Data Files folder on Google Drive.

There are 8 .do files. 

Run them in the following order:

Oklahoma DTA Conversion.do; 

Oklahoma NCES Cleaning.do; 

Oklahoma `year' Cleaning.do. 



    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/maggie/Desktop/Oklahoma/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Oklahoma/NCES/District"
global NCES "/Users/maggie/Desktop/Oklahoma/NCES/Cleaned"

global raw "/Users/maggie/Desktop/Oklahoma/Original Data Files"
global output "/Users/maggie/Desktop/Oklahoma/Output"
```

## Updates

04/11/2024: Updated output files to incorporate new NCES variables.