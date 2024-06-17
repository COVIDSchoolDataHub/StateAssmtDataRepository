
# Wyoming Data Cleaning

This is a ReadMe for Wyoming's data cleaning process, from 2014 to 2023.





## Setup

There are five folders you need to create: 
Original Data Files, NCES, Output, EDFacts, and Temp. 

Download the three original files (one for each data level). Place them in the "Original Data Files" folder. Download the EDFacts count files from the Long DTA Versions folder and place them in the EDFacts folder. Also download the WY 2022 EDFacts file from the WY original data folder and place it in the EDFacts folder. The NCES cleaning file will generate altered NCES files, so you may also want a folder to store these files. 

There are 4 .do files. 

Run them in the following order:

Cleaning NCES.do; 

WY_Cleaning.do; 

WY_EDFACTS.do;

WY_EDFACTS_2022.do;

On the first run, you need to update file paths and unhide import code in WY_Cleaning.do.

If you are running into errors with the WY_EDFacts files, run WY_Cleaning.do again before trying to run WY_EDFACTS (You shouldn't have to run the NCES file). Running the EDFacts files back to back can cause type errors. 

In its current form WY_Cleaning.do automatically runs the subsequent files. To run them individually, delete/comment out the final two lines. 
