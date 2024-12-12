# Iowa Data Cleaning

This is a ReadMe for Iowa's data cleaning process, from 2004 to 2024.

# Setup

The main folders (with subfolders) you need to creaste include:

1. Intermediate  [download from Iowa folder; already includes subfolders]

	a. intermediate1
	
	b. intermediate2
	

2. NCES_full [Place all of the most recent NCES school and district files from the Google drive in this folder. Do not create any subfolders.]
	
3. NCES_iowa. [will start empty]

4. Original Data Files. From the "Original Data Files" folder on the Google drive, download the following subfolders:

	a. 2014 and Previous Files

	b. 2015 and Post Files
	
	c. Stable Dist and Sch Names
	
	d. You will also need the "ia_county-list_through2023.xlsx" file in this folder
	
7. Output  [empty]

# Process
You should run the 4 do files in the following order, updating all paths as needed.

1. 01_Iowa_NCES_clean.do

2. 02_IA_clean_preNCES.do

3. 03_IA_NCES merging.do

4. 04_IA_Final Cleaning.do


Updates
7/3/24: Added EDFacts Participation Data to 2014 through 2022

8/2/24: Applied new stable district names to all years (referenced by IA_StableNames do-file, which should be run last).

12/12/24: New .do files to streamline cleaning. Integrated 2024 data and applied StudentGroup_TotalTested convention.
