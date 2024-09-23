Create seven folders: NCES Old, NCES New, Original Files, Temp, Output, MN_2022, do files

Access old NCES files from the Drive and put them into NCES Old.

Run NCES do file

Download all of the do files for each year (1998-2024) and place them into the "do files" folder. Download all of the original data files and put them in the Original Files Folder. Also make sure to download the file called "mn_full-dist-sch-stable-list_through2024" and put it in the Original Files Folder.

Run MN_Master.do with the directory to the "do files" folder

Run MN_StableNames.do

Run MN_EDFactsParticipationRate_2014_2021.do

Download the MN_EFParticipation_2022_subject files and place them into the MN_2022

Run MN_EDFactsParticipationRate_2022.do

Directory:

cd "/Users/kaitlynlucas/Desktop/do files"

global original_files "/Users/kaitlynlucas/Desktop/Minnesota State Task"

global NCES_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/NCES_MN"

global output_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output"

global temp_files "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN_Temp"


Participation Rate 2014-2021

global Original "/Users/kaitlynlucas/Desktop/EDFacts Drive Data" //Folder with Output .dta

global EDFacts "/Users/kaitlynlucas/Desktop/EDFacts Drive Data" //Folder with downloaded state-specific 2022 participation data from EDFacts

global State_Output "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder with state-specific data

global Output_20 "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder for Output 2.0


Participation Rate 2022

global Original "/Users/kaitlynlucas/Desktop/EDFacts Drive Data" //Folder with Output .dta

global EDFacts "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN_2022" //Folder with downloaded state-specific 2022 participation data from EDFacts

global State_Output "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder with state-specific data

global Output_20 "/Users/kaitlynlucas/Desktop/Minnesota State Task/MN Output" //Folder for Output 2.0



