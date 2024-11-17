
# Pennsylvania Data Cleaning

This is a ReadMe for Pennsylvania's data cleaning process, from 2015 to 2024.
* Note that 2020 is excluded, as PA did not administer spring tests during that year due to COVID.


## Setup

There are four main folders you need to create: NCES District and School Demographics (NCES), Original, Output, and Temp.
Download the original excel files, and place them in the Original folder.
Download the NCES District Files, Fall 1997-Fall 2022 and NCES School Files, Fall 1997-Fall 2022, and place them in the NCES folder.

There are 2 .do files which can be run in any order.  Both files have code hidden at the beginning to convert the oirginal excel files into .dta format.  Unhide this the first time you run the code.
Run "PA_All_DataRequest.do" to clean the data for 2015-2022. The specific code for each year is also hidden -- unhide as needed to get the years you want.
Run "PA_2023.do" to clean the data for 2023.
Run "PA_2024.do" to clean the data for 2024.
    
## File Path

The file path setup should be as follows: 

global Original: Folder containing original data files
global NCES: Folder containing NCES school & district files
global Output: Folder containing cleaned data files
global Temp: Folder containing .dta format versions of the original data

```bash
global Original "/Users/name/Desktop/Pennsylvania/Original"
global NCES "/Users/name/Desktop/Pennsylvania/NCES"
global Output "/Users/name/Desktop/Pennsylvania/Output"
global Temp "/Users/name/Desktop/Pennsylvania/Temp"4
```
## Updates

05/07/2024: Updated to incorporate post-launch formatting changes, including including SWD for 2023, use updated NCES files, and generate counts for 2023 data.
