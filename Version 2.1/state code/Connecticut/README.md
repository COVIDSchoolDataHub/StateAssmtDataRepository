
# Connecticut Data Cleaning

This is a ReadMe for Connecticut's data cleaning process, from 2015 to 2024.


### NOTE: Install the "labutil" package for the code to run (necessary for "labmask" command):

Type the following code into the command module:
```
ssc install labutil
```


## Setup

A. Create six folders and subfolders: 
    1. Original Data Files 
        a. Download the original files from the drive in all individual year folders and the "Additional Subgroup" folder. Place them in the "Original Data Files" folder. 
      
    2. NCES
        a. District [subfolder]
        b. School [subfolder]
        
    3. Output 
    
    4. Output_ND [this is a folder for the non-derivation output]
    
    5. EDFacts. 
    
        a. Put the 4 2021 EDFacts files below into the EdFacts folder on your computer drive.
        b. You can find these EdFacts files here: https://drive.google.com/drive/folders/1oZMYBDpy9SgKOx9X0IiB6QgaCNGFbu1r?usp=sharing
            edfactspart2021eladistrict.dta
            edfactspart2021mathdistrict.dta
            edfactspart2021elaschool.dta
            edfactspart2021mathschool.dta
    6. Temp 

B. Download the following .do files:

    1. 01_CT_Cleaning.do; 
    
    2. 02_CT_Cleaning_2021.do; 
    
    3. 03_CT_2021_EDFACTS.do.
    
    4. CT_Main_File.do;

After any updates needed to the .do files, run CT_Main_File.do, which will execute the do files in order.
