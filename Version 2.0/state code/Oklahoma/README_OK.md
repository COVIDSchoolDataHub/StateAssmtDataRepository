
# Oklahoma Data Cleaning
This is a ReadMe for Oklahoma's data cleaning process, from 2017 to 2024.

## Setup

There are two main folders you need: 
- Oklahoma (with subfolders for Original Data Files and Output (and a csv folder within this))
- NCES (with subfolders for school, district, and cleaned data)

Download the original raw data .xlsx and .csv files on Google Drive, and keep them within the subfolders they are in on Drive.

- Data from Version 1.0 (in the Publicly Available Data Files folder on Drive) will be used for AvgScaleScore.
- Data from the Data Requests will be used for everything else.

There are 4 .do files. 

Run them in the following order:

Oklahoma DTA Conversion.do; 

Oklahoma NCES Cleaning.do; 

Oklahoma Cleaning 2017-2023.do;

Oklahoma Cleaning 2024.do.
    
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

- 04/11/2024: Updated output files to incorporate new NCES variables.
- 05/25/2024: Updated output files to use new data request files in place of old original data files.
- 12/02/2024: Updated to include 2024 data, derive additional information, and match StudentGroup_TotalTested
  convention for V2.0
