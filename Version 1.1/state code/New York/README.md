
# New York Data Cleaning

This is a ReadMe for New York's data cleaning process, from 2006 to 2023.


## Setup
Create a folder for New York. Inside that folder, create three more folders: 
"Original", "NCES", and "Output"

1. Download do-files and place them in the Arkansas folder.
2. Download "2006-2018" folder as one and place it in the "Original" folder
3. Download the files inside the "2019-2023" folder and place them in the "Original" folder
4. Download NCES Data if you haven't already. **NOTE: The new 2022 NCES file is incompatible with the 2022 file used to clean this data. The 2022 NCES file used has been uploaded to the drive. (Preliminary NCES data was used rather than the updated data).It can be found inside the Data Documentation Folder


- Inside the NY_Master do-file, change the directory next to the cd command to the New York folder
- Inside the NY_Master do-file, change your global macros to match the folders above. You need to set four directories:
`global original`
`global output` 
`global nces_school` 
`global nces_district`

- Note that nces_school and nces_district can map to the same folder, as long as it contains both district and school files.

- Inside the NY_Master file, select the four global commands and run them to set universal file directories.

## Preliminary Cleaning
Before starting with the main cleaning, there are do-files to import and combine files from 2006-2018. These are "Combining 2006-2017" and "Combining 2018." These must run before any other cleaning.

Inside "Combining 2006-2017", change the directory to folder inside the Original data titled "2006-2018". Run the do-file.
Inside "Combining 2018", change the directory to the same directory as above. Run the do-file.

In the Original folder, you should now have 12 .dta files titled "Combined_[year]". You should have an additional 12 .txt files titled "NY_OriginalData_[subject]_[year]".

## Recreating cleaning
In the NY_Master do-file, simply run the code. If directories have been set correctly, you shouldn't have to do anything more. The code takes about 12 minutes to run, since it cleans every year. If you want to clean specific years, run the corresponding do-file. 

For the 2006-2017 do-file, you can edit the years included in the command:
`forvalues year = 2006/2017 {`

The above code will loop from 2006-2017. If you only wanted to clean a specific year, say 2010, you could replace the command with:
`forvalues year = 2010/2010 {`


To make any changes, go to the do-file that covers the year in question. Sections where different aspects of the cleaning process take place are labeled.








