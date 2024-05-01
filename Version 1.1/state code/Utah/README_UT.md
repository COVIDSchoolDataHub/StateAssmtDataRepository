
# Utah Data Cleaning

This is a ReadMe for Utah's data cleaning process, from 2014 to 2023.
* Note that 2020 is excluded, as MO did not administer spring tests during that year due to COVID.


## Setup

There are three main folders you need to create: UT State Testing Data, NCES District and School Demographics, and EdFacts.
There should be three folders within the NCES folder:
NCES District Files, Fall 1997-Fall 2022, NCES School Files, Fall 1997-Fall 2022, and Cleaned NCES Data.
Download the original excel files (including the enrollment data and unmerged schools files), and place them in the UT State Testing Data folder.
Also create an Intermediate subfolder and an Output subfolder of the UT State Testing Data folder to which to save intermediate and cleaned files.
The EdFacts folder should have subfolders for each year from 2014 to 2021.  Save original EdFacts files into the appropriate folder here.

There are 12 .do files.
You should run "UT_NCES_clean.do" first to clean NCES files and convert the unmerged school file to .dta format.
Then run "UT_edfacts_clean.do" to clean the EdFacts data, and then run "UT_Enrollment_22_23_clean.do" to obtain student counts.
The other nine files are for each year of data and can be run in any order you choose.

## File Path

The file path setup should be as follows: 

global raw: Folder containing original data files (both testing, enrollment, and unmerged schools file)
global int: Folder containing .dta files generated in the process of cleaning data
global output: Folder containing cleaned + merged files
global nces: Folder containing all NCES files (original + cleaned)
global utah: Folder containing cleaned NCES data
global edfacts: Folder containing all EdFacts files.

```bash
global raw "/Users/miramehta/Documents/UT State Testing Data/Original Data"
global output "/Users/miramehta/Documents/UT State Testing Data/Output"
global int "/Users/miramehta/Documents/UT State Testing Data/Intermediate"

global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global utah "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global edfacts "/Users/miramehta/Documents/EdFacts"
```
## Updates

04/19/2024: Updated to match new StudentGroup_TotalTested convention, address issues in merging, and correct issue with derived performance counts at the state level.

05/01/2024: Updated to fix inconsistent school names across years.