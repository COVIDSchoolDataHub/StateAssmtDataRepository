
# Delaware Data Cleaning

This is a ReadMe for Delaware's data cleaning process, from Spring 2015 to Spring 2024 

*Has been adapted for the 2024 Zelma 2.0 review.




## Setup
There are eight folders you need to create: 
NCESOld, NCESNew, Original Data Files, Output, 2015-2017 DCAS files, Delaware Assessment, Delaware V2.0, DE_2022

Download the original .xlsx files and place them into the "Original Data Files" folder. 

(With the exception of the 2015-2017 DCAS files, which should be place separately in a "2015-2017 DCAS files" folder.

There are 2 .do files. Run them in the following order.

NCES_Cleaning_DE_final.do

DE_2015_2024.do 

(You should not have to run DE_2015_2024_PART2.do separately)

(The NCESOld file should be the most recent available NCES files.)

In order to add ParticipationRate data to the files:

Download DE_AssmtData_year files from Output - Version 1.1 folder on Google Drive, and place them into the "Delaware Assessment" folder.
Download DE_EFParticipation_2022_subject files from the Original Data Files folder on Google Drive, and place them into the "DE_2022" folder.

Run the following .do files.

DE_EDFactsParticipation_2015_2021.do

DE_EDFactsParticipation_2022.do

The files in the "Delaware V2.0" folder are your final files.

    
## File Path

The file path setup should be as follows: 

```bash
global Abbrev "DE" //Set State Abbreviation Here
global NCES_Original "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESOld"
global NCES_$Abbrev "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESNew" //Create a folder for state specific NCES files

global original "/Users/kaitlynlucas/Desktop/Delaware State Task/Original Data Files"
global output "/Users/kaitlynlucas/Desktop/Delaware State Task/Output"
global nces "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESNew"
global PART2 "/Users/kaitlynlucas/Desktop/Delaware State Task/DE_2015_2024_PART2.do"

//ParticipationRate file path setup
global EDFacts "/Users/kaitlynlucas/Desktop/EDFacts Drive Data"
global State_Output "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/Delaware Assessment" // Version 1.1 Output directory here
global New_Output "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/Delaware V2.0"

global Original "/Users/kaitlynlucas/Desktop/EDFacts Drive Data" //Folder with Output .dta
global EDFacts "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/DE_2022" //Folder with downloaded state-specific 2022 participation data from EDFacts
global State_Output "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/Delaware Assessment" //Folder with state-specific data
global Output_20 "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/Delaware V2.0" //Folder for Output 2.0
```
## Updates

03/29/2024: Made 2024 updates.
04/12/2024: Responded to 2024 review comments.
08/1/2024: Made filename updates.
08/30/2024: Added code for 2024 data.
