
# Mississippi Data Cleaning

This is a ReadMe for Mississippi's data cleaning process, from 2014 to 2023.




## Setup

There are five folders you need: 
Original Data Files, Data Request, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it). 

Download the folder titled "Data Request" and the original raw data .xlsx files ending in _all within the Original Data Files folder on Google Drive. The former is the "Data Request" folder, while the latter should be placed within an "Original Data Files" folder.
The cleaning code currently only uses the 2014 original raw data file due to inconsistencies with the data request files but original raw data files for all years are available. 

There are 11 .do files. 

Run them in the following order:

Mississippi DTA Conversion.do; 

Mississippi Cleaning Merge Files.do; 

Mississippi `year'.do. 



    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/maggie/Desktop/Mississippi/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Mississippi/NCES/District"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

global raw "/Users/maggie/Desktop/Mississippi/Original Data Files"
global output "/Users/maggie/Desktop/Mississippi/Output"
global Request "/Users/maggie/Desktop/Mississippi/Data Request"
```

## Updates

03/23/2024: Updated output files to incorporate new data request files instead of original raw data files.