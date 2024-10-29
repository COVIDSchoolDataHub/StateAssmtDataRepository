
# Connecticut Data Cleaning

This is a ReadMe for Connecticut's data cleaning process, from 2015 to 2024.


### NOTE: Install the "labutil" package for the code to run (necessary for "labmask" command):

Type the following code into the command module:
```
ssc install labutil
```


## Setup

There are five folders you need to create: 
Original Data Files, NCES, Output, EDFacts, and Temp. 

Download the original files from the drive in all inidividual year folders and the "Additional Subgroup" folder. Place them in the "Original Data Files" folder. 

Put the 4 2021 EDFacts files in this EDFacts folder: https://drive.google.com/drive/folders/1oZMYBDpy9SgKOx9X0IiB6QgaCNGFbu1r?usp=sharing

The files are: 
edfactspart2021eladistrict.dta
edfactspart2021mathdistrict.dta
edfactspart2021elaschool.dta
edfactspart2021mathschool.dta

There are 3 .do files. 

Run them in the following order:

CT_Cleaning.do; 

CT_Cleaning_2021.do; 

CT_2021_EDFACTS.do.

