
# Oklahoma BIE Data Cleaning
This is a ReadMe for Oklahoma's data cleaning process for BIE schools, from 2017 to 2024. (No BIE data is available for 2021).
This is a subset of the Oklahoma cleaning process and uses a similar set up.

## Setup

There are two main folders you need: 
- Oklahoma (with subfolders for Original Data Files, Output, and Oklahoma BIE (and a csv folder within each of the latter two))
- NCES (with subfolders for school, district, and cleaned data)

Download the original raw data .xlsx and .csv files on Google Drive, and keep them within the subfolders they are in on Drive.

- Only data from Version 1.0 (in the Publicly Available Data Files folder on Drive) will be used, as this is where BIE data are.

There are 7 .do files. Run Oklahoma BIE NCES Cleaning.do first, and then you can run the files for each year in any order.
    
## File Path

The file path setup should be as follows: 

```bash
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global raw "/Users/miramehta/Documents/Oklahoma/Original Data Files"
global output "/Users/miramehta/Documents/Oklahoma/Oklahoma BIE"
```

## Updates

- 12/02/2024: Updated to include 2024 data.
