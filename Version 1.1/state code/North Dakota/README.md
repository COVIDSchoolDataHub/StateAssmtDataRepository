
# North Dakota Data Cleaning

This is a ReadMe for North Dakota's data cleaning process, from 2015 to 2023.




## Setup

There are seven folders you need: 
Original Data Files, Data Request, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it). 

Download the original raw data .xlsx files ending in the Original Data Files folder on Google Drive.

There are 10 .do files. 

Run them in the following order:

ND Student Counts 15-21.do; 

ND Student Counts 22-23.do;

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