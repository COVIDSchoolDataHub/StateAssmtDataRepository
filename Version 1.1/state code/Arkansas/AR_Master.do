clear
set more off

//Set Directory for all folders
cd "/Volumes/T7/State Test Project/Arkansas"

//SET FILE DIRECTORIES BELOW
global Original "/Volumes/T7/State Test Project/Arkansas/Original Data"
global Output "/Volumes/T7/State Test Project/Arkansas/Output"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Temp "/Volumes/T7/State Test Project/Arkansas/Temp"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

local dofiles AR_Cleaning_2009_2014 AR_Cleaning_2015 AR_AllStudents_2016_2023 AR_NoCountsSubGroupData_2016_2023 AR_StateSG_2019_2023

foreach file of local dofiles {
	do `file'
}

//Combining separate data files for 2016-2023
forvalues year = 2016/2023 {
if `year' == 2020 continue
use "${Temp}/AR_AssmtData_`year'_AllStudents"
append using "${Temp}/AR_AssmtData_`year'_nocountsSG"
if `year' >= 2019 append using "${Temp}/AR_AssmtData_`year'_StateSG"
replace SchName = proper(SchName)
replace DistName = proper(DistName)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Dropping Blank Rows
drop if Lev1_percent == "--" & Lev3_percent == "--" & Lev4_percent== "--" & ProficientOrAbove_percent == "--"
drop if missing(State)

save "${Output}/AR_AssmtData_`year'", replace
}


//EDfacts Merging
do AR_EDFacts_2016_2023
/*



		**	Notes on data structures and do-files	**

•Years 2016-2018 rely on three data sources, each with a corresponding do-file. 
	•AR_AllStudents_2016_2023: This do-file cleans original data from files called: "AR_OriginalData_[year]"
		•Data is not disaggregated by StudentSubGroup, but contains StudentSubGroup_TotalTested and level percents
	
	•AR_NoCountsSubGroupData_2016_2023: This do-file cleans original data from files called: "AR_[DataLevel]_Subgroups_[year]_no counts"
		•Data is disaggregated by StudentSubGroup, but does not contain StudentSubGroup_TotalTested or level percents.
	
	•AR_EDFacts_2016_2023: This data file merges in StudentSubGroup_TotalTested and ParticipationRate where missing for years 2016-2023, and aggregates StudentSubGroup_TotalTested to the state level.
		•Data used to supplement missing StudentSubGroup_TotalTested where possible. Does not include science, often missing certain Subgroups for schools. Also does not include Foster care or Native Hawaiian Students.
	
•Years 2019-2023 rely on the three above data sources, plus data cleaned in one more do file;
	•AR_StateSG_2019_2023: This do-file cleans original data from files called: AR_OriginalData_[year]_State_sg
			•This data is disaggregated by StudentSubGroup and contains level percents, but no StudentSubGroup_TotalTested. EDfacts used to supplement StudentSubGroup_TotalTested where possible.
		

		**	Misc Notes **
•2015 had Proficiency Level 5, thus all years will have Lev5_count and Lev5_percent as "--" rather than empty
		


