*******************************************************
* VIRGINIA

* File name: VA_Main_File
* Last update: 2/19/2025

*******************************************************
* Notes

	* Global macros can be updated in this do file.
	* This will be the only .do file needed to run through all state files in the proper order.
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear 
set more off
set trace off

global DoFiles "/Users/miramehta/Documents/GitHub/StateAssmtDataRepository/Version 2.1/state code/Virginia" 

*Input folders*
global raw "/Users/miramehta/Documents/Virginia/Original Data" //Original Data Files downloaded from Google Drive.
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global EDFacts "/Users/miramehta/Documents/EDFacts" //EDFacts Datasets (wide version) downloaded from Google Drive.
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data" //NCES files cleaned for VA

*Output folders*
global output "/Users/miramehta/Documents/Virginia/Output" // Output directory here; has a subfolder for .csv formatted files

/////////////////////////////////////////
*** Full State Data Cleaning ***
/////////////////////////////////////////
do "${DoFiles}/01_Virginia NCES Cleaning.do"
do "${DoFiles}/02_VA_1998.do" 
do "${DoFiles}/03_VA_1999.do"
do "${DoFiles}/04_VA_2000.do"
do "${DoFiles}/05_VA_2001.do"
do "${DoFiles}/06_VA_2002.do"
do "${DoFiles}/07_VA_2003.do"
do "${DoFiles}/08_VA_2004.do"
do "${DoFiles}/09_VA_2005.do"
do "${DoFiles}/10_VA_2006.do"
do "${DoFiles}/11_VA_2007.do"
do "${DoFiles}/12_VA_2008.do"
do "${DoFiles}/13_VA_2009.do"
do "${DoFiles}/14_VA_2010.do"
do "${DoFiles}/15_VA_2011.do"
do "${DoFiles}/16_VA_2012.do"
do "${DoFiles}/17_VA_2013.do"
do "${DoFiles}/18_VA_2014.do"
do "${DoFiles}/19_VA_2015.do"
do "${DoFiles}/20_VA_2016.do"
do "${DoFiles}/21_VA_2017.do"
do "${DoFiles}/22_VA_2018.do"
do "${DoFiles}/23_VA_2019.do"
do "${DoFiles}/24_VA_2021.do"
do "${DoFiles}/25_VA_2022.do"
do "${DoFiles}/26_VA_2023.do"
do "${DoFiles}/27_VA_2024.do" //code to import data unhidden; rehide after first run
do "${DoFiles}/28_VA_EDFactsParticipation_2015.do"
do "${DoFiles}/29_VA Participation Rates_12.3.23.do"

****************************************************

*End of VA_Main_File
