
# Connecticut Data Cleaning

This is a ReadMe for Connecticut's data cleaning process, from 2015 to 2024.


### NOTE: Install the "labutil" package for the code to run (necessary for "labmask" command):

Type the following code into the command module:
```
ssc install labutil
```


## Setup

There are six folders you need to create: 
Original Data Files, NCES, Output, Output_ND, EDFacts, and Temp. 

Output_ND is a new folder for the non-derivation output.

Create two subfolders in the NCES folder: 
District, School.

Download the original files from the drive in all individual year folders and the "Additional Subgroup" folder. Place them in the "Original Data Files" folder. 

Put the 4 2021 EDFacts files into the EdFacts folder on your computer drive. 

The files are the following: 
edfactspart2021eladistrict.dta
edfactspart2021mathdistrict.dta
edfactspart2021elaschool.dta
edfactspart2021mathschool.dta

You can find these EdFacts files here: https://drive.google.com/drive/folders/1oZMYBDpy9SgKOx9X0IiB6QgaCNGFbu1r?usp=sharing

There are 4 .do files to be downloaded.
CT_Main_File.do;

01_CT_Cleaning.do; 

02_CT_Cleaning_2021.do; 

03_CT_2021_EDFACTS.do.

Run CT_Main_File.do, which will execute the do files in order.
