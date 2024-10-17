## Setup
Create six folders: 
  1. NCES_MN
     - Access NCES files from the Drive and put them into NCES_MN. Add both district and school files into the same folder.
  3. Original Files
     - Download all of the original data files and put them in the Original Files Folder.
     - Download the file called "mn_full-dist-sch-stable-list_through2024" and put it in the Original Files Folder.
  5. Temp [initially empty]
  6. Output [initially empty]
  7. MN_2022
     - Download the files in the MN_2022_EDFactsParticipation folder on the Google drive (https://drive.google.com/drive/u/0/folders/1h2DrMQB0t91SSPdujEDHJvCN-lRXXo5y)
  9. do files
     - Download each of the do files for each year (1998-2024) and place them into the "do files" folder.

## Directory Paths Setup

cd "/Users/kaitlynlucas/Desktop/do files"

global original_files "/Users/kaitlynlucas/Desktop/Minnesota State Task"

global NCES_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/NCES New"

global output_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output"

global temp_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN_Temp"



*Participation Rate 2014-2021:*

global Original "/Users/kaitlynlucas/Desktop/EDFacts Drive Data" //Folder with Output .dta

global EDFacts "/Users/kaitlynlucas/Desktop/EDFacts Drive Data" //Folder with downloaded state-specific 2022 participation data from EDFacts

global State_Output "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder with state-specific data

global New_Output "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder for Output 2.0


*Participation Rate 2022:*


global Original "/Users/kaitlynlucas/Desktop/EDFacts Drive Data" //Folder with Output .dta

global EDFacts "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN_2022" //Folder with downloaded state-specific 2022 participation data from EDFacts

global State_Output "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder with state-specific data

global Output_20 "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder for Output 2.0


## Do File Order
Run the do files in the following order:  

1. MN_Master.do with the directory to the "do files" folder
2. MN_EDFactsParticipationRate_2014_2021.do
3. MN_EDFactsParticipationRate_2022.do



