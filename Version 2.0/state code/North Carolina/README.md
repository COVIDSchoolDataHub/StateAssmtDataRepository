This is a ReadMe for North Carolina's data cleaning process, from 2014 to 2024.

Setup
Create a folder for NC. Inside that folder, create three more folders: "Original", "NCES" and "Output"
Set the working directory to Users/name/Desktop/North Carolina

Files to Download
From the drive, download the Original Data files from 2014-2024 -  Version 2.0 Folder
There are ten original csv files/text files
Save these files to the "Original" folder.

From the drive, download NCES District/School files from the "NCES District and School Demographics" Folder, within the "Data Cleaning Materials" Folder
There should be ten NCES_District files and ten NCES_School files
From Github, download the do-file named "nc_nces", running this will create NCES files for the current year and the "NC_district_id" files to merge in for missing DistNames.
Save these files to the "NCES" folder.

From Github, download the "nc_do" file and run it
This will create the relevant output files from 2014-2023
Then download the "NC_EDFactsParticipation_2014_2021" do-file and run the 2014-2021 output files through the code, which should add in participation data for those years.
Then download the "NC_EDFactsParticipation_2022" do-file and run the 2022-2023 output files through the code, which should add in participation data for those years.

Finally, from Github, run the "NC_2024" file to generate the cleaned 2024 dataset.
