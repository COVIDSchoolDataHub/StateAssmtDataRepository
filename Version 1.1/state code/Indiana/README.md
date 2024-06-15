
# Indiana Data Cleaning

This is a ReadMe for Indiana's data cleaning process, from 2014 to 2023.

## Recreate Cleaning
Download the files from Original Data - Version 1.1

Download the files from Original Data - Version 1.0

Download the following do-files:

1. IN_NCES.do (not Indiana NCES Cleaning)
2. IN_Importing.do
3. IN_Cleaning.do
4. IN_2014.do through IN_2023.do
5. IN_Combining_Subjects

Steps to recreate cleaning:
1. Create the following folders in the Indiana Drive: NCES, temp, Output_ela_math, Output_sci_soc, Output.
2. Set file directories in all files as follows:

IN_NCES.do:
```
global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024" //Original NCES Data from Drive
global NCES_New "/Volumes/T7/State Test Project/Indiana/NCES" //New Folder to create in IN folder
```
IN_Importing_ela_math.do:
```
global Original "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1" // Original Data Version 1.1
global temp "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1/temp"
global Output "/Volumes/T7/State Test Project/Indiana/Output" // ** Set this to the Output_ela_math folder **
global NCES_New "/Volumes/T7/State Test Project/Indiana/NCES"
```
IN_Cleaning_ela_math.do:
```
global Original "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1"
global temp "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.1/temp"
global Output "/Volumes/T7/State Test Project/Indiana/Output_ela_math"
global NCES_New "/Volumes/T7/State Test Project/Indiana/NCES"
```
IN_`year'.do:
```
global raw "/Volumes/T7/State Test Project/Indiana/Original Data Files - Version 1.0" //Original Data Version 1.0
global output "/Volumes/T7/State Test Project/Indiana/Output_sci_soc" // ** Set this to the Output_sci_soc folder
global NCES "/Volumes/T7/State Test Project/Indiana/NCES"
```
IN_Combining_Subjects.do
```
cd "/Volumes/T7/State Test Project/Indiana" // Set directory to wherever do-files are stored
global ela_math_output "/Volumes/T7/State Test Project/Indiana/Output_ela_math"
global sci_soc_output "/Volumes/T7/State Test Project/Indiana/Output_sci_soc"
global Output_all "/Volumes/T7/State Test Project/Indiana/Output" //Output folder with final files to be uploaded
```

3. Run the files as follows:
- IN_NCES.do
- IN_Importing_ela_math.do
- IN_Cleaning_ela_math.do
- IN_Combining_Subjects.do

Note: You do not need to run the IN_`year' files manually, although you can if you want
