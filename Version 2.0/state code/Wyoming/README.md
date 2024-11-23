
# Wyoming Data Cleaning

This is a ReadMe for Wyoming's data cleaning process, from 2014 to 2024.





## Setup

There are five folders you need to create: 
Original Data Files, NCES, Output, EDFacts, and Temp. 

Download NCES files from the drive (2013-2022) and place them into the NCES folder (can place both School and District files in the same folder).

Download the three original files (one for each data level) from Original Data on the drive. Place them in the "Original Data Files" folder. Download the EDFacts count files from the Long DTA Versions folder (2014-2021) and place them in the EDFacts folder. Also download the WY 2022 EDFacts file from the WY Original Data folder and place it in the EDFacts folder. 

There are 4 .do files. 

Run them in the following order:

Cleaning NCES.do;

WY_Cleaning.do; 

WY_EDFACTS.do;

WY_EDFACTS_2022.do;

On the first run, you need to update file paths and unhide import code in WY_Cleaning.do.

If you are running into errors with the WY_EDFacts files, run WY_Cleaning.do again before trying to run WY_EDFACTS (You shouldn't have to run the NCES file). Running the EDFacts files back to back can cause type errors. 

In its current form WY_Cleaning.do automatically runs the subsequent files. To run them individually, delete/comment out the final two lines. 

## Updates
- 6/27/24: Updated AssmtType to Regular and alt using the WY_StateTask_Jun24 do-file. This should be incorporated into the cleaning do-file at a later date.
- 7/23/24: WY_Cleaning.do has been combined with Cleaning_NCES.do and combines the process of cleaning the NCES files and then merging them with WY_Assmt_Data. WY_EDFacts.do has been updated to use the current cleaning code for wide-form Original Data and accounts for "All Students" count. Also accounts for changing AssmtType from "regular" to "regular and alt".
- 11/17/24: Updated WY_Cleaning.do to include state task from June.
