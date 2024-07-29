clear
set more off


global OldOutput "/Volumes/T7/State Test Project/New Mexico/Output" 
global NewOutput "/Volumes/T7/State Test Project/New Mexico/Output with Stable Names"

global StateAbbrev "NM"
global years 2017 2018 2019 2021 2022 2023

tempfile temp1
save "`temp1'", emptyok
clear
foreach year in $years {
	use "$OldOutput/${StateAbbrev}_AssmtData_`year'", clear
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
	use "$OldOutput/${StateAbbrev}_AssmtData_`year'", clear
	merge m:1 NCESDistrictID using "${StateAbbrev}_StableNames"
	drop if _merge == 2
	replace DistName = DistName1
	drop DistName1 _merge
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested 		StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$NewOutput/${StateAbbrev}_AssmtData_`year'", replace
export delimited "$NewOutput/${StateAbbrev}_AssmtData_`year'", replace
	
}
