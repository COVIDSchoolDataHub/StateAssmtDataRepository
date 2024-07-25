
# Mississippi Data Cleaning

This is a ReadMe for Mississippi's data cleaning process, from 2014 to 2023.




## Setup

There are six folders you need: 
Original Data Files, Data Request, NCES (a School, District, and Cleaned folder within it), Output (and a csv folder within it), MS_2022. 

Download the folder titled "Data Request" and the original raw data .xlsx files ending in "all" within the Original Data Files folder on Google Drive. The former is the "Data Request" folder, while the latter should be placed within an "Original Data Files" folder.
The cleaning code currently only uses the 2014 original raw data file due to inconsistencies with the data request files but original raw data files for all years are available. Download the MS_EFParticipation_2022_`subject'.csv files from Original Data Files folder on Google Drive and put them in the "MS_2022" folder.

There are 11 .do files. 

Run them in the following order:

Mississippi DTA Conversion.do; 

Mississippi Cleaning Merge Files.do; 

Mississippi `year'.do. 



    
## File Path

The file path setup should be as follows: 
For first .do file:

```bash
global raw "/Users/kaitlynlucas/Desktop/Mississippi State Task/Original Data Files"
global output "/Users/kaitlynlucas/Desktop/Mississippi State Task/Output"
global NCES "/Users/kaitlynlucas/Desktop/Mississippi State Task/NCES"
global Request "/Users/kaitlynlucas/Desktop/Mississippi State Task/Data Request"
```
For second .do file:
```bash
global MS "/Users/kaitlynlucas/Desktop/Mississippi State Task/Original Data Files"
global NCESSchool "/Users/kaitlynlucas/Desktop/Mississippi State Task/NCES/School"
global NCESDistrict "/Users/kaitlynlucas/Desktop/Mississippi State Task/NCES/District"
global NCES "/Users/kaitlynlucas/Desktop/Mississippi State Task/NCES/Cleaned"
global EDFacts "/Users/kaitlynlucas/Desktop/EDFacts Drive Data"
```
For the 11 year .do files:
```bash
global MS "/Users/kaitlynlucas/Desktop/Mississippi State Task/Original Data Files"
global raw "/Users/kaitlynlucas/Desktop/Mississippi State Task/Original Data Files"
global output "/Users/kaitlynlucas/Desktop/Mississippi State Task/Output"
global NCES "/Users/kaitlynlucas/Desktop/Mississippi State Task/NCES/Cleaned"
global EDFacts "/Users/kaitlynlucas/Desktop/EDFacts Drive Data"
global Request "/Users/kaitlynlucas/Desktop/Mississippi State Task/Data Request"
```
for 2022 specifically, replace global EDFacts with: "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/MS_2022"
## Updates

03/23/2024: Updated output files to incorporate new data request files instead of original raw data files.

07/25/2024: Updated output files to include updated ParticipationRate code and changed science AssmtType after 2018 (and flag change).
