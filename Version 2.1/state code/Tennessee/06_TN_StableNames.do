*******************************************************
* TENNESSEE

* File name: 06_TN_StableNames
* Last update: 2/7/2025

*******************************************************
* Notes

	* This do file uses standardized district names from TN_StableNames.dta and REPLACES the district names in the output created from
	* a) 05_TN_EDFactsParticipationRate_2014_2015_2017_2018.do (usual output only)
	* b) 03_TN_Cleaning_2010_2015 and 04_TN_Cleaning_2017_2024 (non-derived output only)
	
	* The output generated from this code is stored into SEPARATE subfolders called 
	* a) Stable_Names_Output (in Output_Files) and 
	* b) Stable_Names_Output_ND (in Output_Files_ND). 
	
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear
set more off
cd "C:/Zelma/Tennessee"

/////////////////////////////////////////
*** Cleaning ***
/////////////////////////////////////////

global StateAbbrev "TN"
global years 2010 2011 2012 2013 2014 2015 2017 2018 2019 2021 2022 2023 2024

tempfile temp1
save "`temp1'", emptyok
clear
foreach year in $years {
	use "$Output/${StateAbbrev}_AssmtData_`year'", clear
	keep SchYear NCESDistrictID DistName
	destring NCESDistrictID, replace force
	format NCESDistrictID %07.0f
	duplicates drop SchYear NCESDistrictID DistName, force
	append using "`temp1'"
	save "`temp1'", replace
}

use "`temp1'"
duplicates drop NCESDistrictID, force
rename DistName DistName1
save "${StateAbbrev}_StableNames", replace

*Replacing the District Names in the usual output files. 
foreach year in $years {
	if `year' == 2020 continue
	use "$Output/${StateAbbrev}_AssmtData_`year'", clear
	destring NCESDistrictID, replace force
	destring NCESSchoolID, replace force
	format NCESDistrictID %07.0f
	format NCESSchoolID %012.0f
	merge m:1 NCESDistrictID using "${StateAbbrev}_StableNames"
	drop if _merge == 2
	replace DistName = DistName1
	drop DistName1 _merge
	tostring NCESDistrictID, replace
	tostring NCESSchoolID, replace
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Stable_Output/${StateAbbrev}_AssmtData_`year'", replace
export delimited "$Stable_Output/${StateAbbrev}_AssmtData_`year'", replace
	
}

*Replacing the District Names in the non-derived output files. 
foreach year in $years {
	if `year' == 2020 continue
	use "$Output_ND/${StateAbbrev}_AssmtData_`year'_NoDev", clear
	destring NCESDistrictID, replace force
	destring NCESSchoolID, replace force
	format NCESDistrictID %07.0f
	format NCESSchoolID %012.0f
	merge m:1 NCESDistrictID using "${StateAbbrev}_StableNames"
	drop if _merge == 2
	replace DistName = DistName1
	drop DistName1 _merge
	tostring NCESDistrictID, replace
	tostring NCESSchoolID, replace
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Stable_Output_ND/${StateAbbrev}_AssmtData_`year'_NoDev", replace
export delimited "$Stable_Output_ND/${StateAbbrev}_AssmtData_`year'_NoDev", replace
}

