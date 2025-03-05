*******************************************************
* NEW MEXICO

* File name: 10_NM Stable Names
* Last update: 2/20/2025

*******************************************************
* Description: This file standardizes District Names to the most recent year of data available (currently 2024)

*******************************************************

clear
set more off

global StateAbbrev "NM"
global years 2017 2018 2019 2021 2022 2023 2024

tempfile temp1
save "`temp1'", emptyok
clear
foreach year in $years {
	use "$output/${StateAbbrev}_AssmtData_`year'", clear
	keep SchYear NCESDistrictID DistName
	duplicates drop SchYear NCESDistrictID DistName, force
	append using "`temp1'"
	save "`temp1'", replace
}

use "`temp1'"
duplicates drop NCESDistrictID, force
rename DistName DistName1
drop SchYear
save "${StateAbbrev}_StableNames", replace

foreach year in $years {
	if `year' == 2020 continue
	use "$output/${StateAbbrev}_AssmtData_`year'", clear
	merge m:1 NCESDistrictID using "${StateAbbrev}_StableNames"
	drop if _merge == 2
	replace DistName = DistName1
	drop DistName1 _merge
	replace DistName = upper(DistName) if DataLevel !=1 //NM only for standardization
	replace SchName = upper(SchName) if DataLevel == 3 //Changed 3.3.25 to standardize more across years
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested 		StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup

save "$output/${StateAbbrev}_AssmtData_`year'", replace
export delimited "$output/${StateAbbrev}_AssmtData_`year'", replace
	
}

* End of 10_NM Stable Names
