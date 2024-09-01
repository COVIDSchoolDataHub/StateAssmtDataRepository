
# Pennsylvania Data Cleaning

This is a ReadMe for Pennsylvania's data cleaning process, from 2015 to 2023.
* Note that 2020 is excluded, as PA did not administer spring tests during that year due to COVID.


## Setup

There are two main folders you need to create: PA State Testing Data and NCES District and School Demographics.
There should be three folders within the PA State Testing Data folder: Original_Data_Files, Output_Data_Files, and Temporary_Data_Files.
Download the original excel files, and place them in the Original_Data_Files folder.
There should be two folders within the NCES folder:
NCES District Files, Fall 1997-Fall 2022 and NCES School Files, Fall 1997-Fall 2022.

There are 2 .do files which can be run in any order.  Both files have code hidden at the beginning to convert the oirginal excel files into .dta format.  Unhide this the first time you run the code.
Run "PA_All_DataRequest.do" to clean the data for 2015-2022. The specific code for each year is also hidden -- unhide as needed to get the years you want.
Run "PA_2023.do" to clean the data for 2023.
    
## File Path

The file path setup should be as follows: 

global original_files: Folder containing original data files
global NCES_school: Folder containing NCES school files
global NCES_district: Folder containing NCES district files
global output_files: Folder containing cleaned data files
global temp_files: Folder containing .dta format versions of the original data

```bash
global original_files "/Users/miramehta/Documents/PA State Testing Data/Original_Data_Files"
global NCES_school "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCES_district "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global output_files "/Users/miramehta/Documents/PA State Testing Data/Output_Data_Files"
global temp_files "/Users/miramehta/Documents/PA State Testing Data/Temporary_Data_Files"
```
## Updates

05/07/2024: Updated to incorporate post-launch formatting changes, including including SWD for 2023, use updated NCES files, and generate counts for 2023 data.