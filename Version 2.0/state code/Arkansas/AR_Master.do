clear
set more off

//Set Directory for all folders
cd "/Users/miramehta/Documents"

//SET FILE DIRECTORIES BELOW
global Original "/Users/miramehta/Documents/AR State Testing Data/Original Data"
global Output "/Users/miramehta/Documents/AR State Testing Data/Output"
global NCES "//Users/miramehta/Documents/NCES District and School Demographics"
global Temp "/Users/miramehta/Documents/AR State Testing Data/Temp"
global EDFacts "/Users/miramehta/Documents/AR State Testing Data/EDFacts"

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

	** Post Launch Review **
//NCESSchoolID for 2019
if `year' == 2019 replace NCESSchoolID = "050042401683" if StateAssignedSchID == "6061702" 

//Deriving ProficientOrAbove_percent where possible
replace ProficientOrAbove_percent = string(1-(real(Lev1_percent) + real(Lev2_percent)), "%9.3g") if regexm(Lev1_percent, "[0-9]") !=0 & regexm(Lev2_percent, "[0-9]") !=0 & regexm(ProficientOrAbove_percent, "[0-9]") ==0

//Updating Flags
if `year' == 2016 replace Flag_CutScoreChange_sci = "Y"
if `year' == 2018 replace Flag_CutScoreChange_sci = "N"
replace Flag_CutScoreChange_soc = "Not Applicable"

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if StudentSubGroup != "All Students"

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AR_AssmtData_`year'", replace
}


//EDfacts Merging
do AR_EDFacts_2016_2023


//Stable Names Across Years
*do AR_StableNames

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
		


