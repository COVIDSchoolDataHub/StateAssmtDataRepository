clear
set more off
cd "/Volumes/T7/State Test Project/Hawaii"
local cleaned "/Volumes/T7/State Test Project/Hawaii/Cleaned Data"
local NCES "/Volumes/T7/State Test Project/NCES/District"
local dofiles Hawaii2013_2014.do hawaii2015-2019_2021-2022.do 
foreach file of local dofiles {
	do `file'
}
foreach year in 2015 2016 2017 2018 2019 2021 2022 {
local prevyear =`=`year'-1'
	use "`cleaned'/HI_AssmtData_`year'.dta"
	drop if DataLevel ==2
	tempfile temp1
	save "`temp1'", replace
	keep if DataLevel ==1
	replace DataLevel = 2
	replace NCESDistrictID = "1500030"
	replace DistName = "Hawaii Department of Education"
	replace StateAssignedDistID = "HI-001"
tempfile temp2
save "`temp2'", replace
clear
use "`NCES'/NCES_`prevyear'_District.dta"
keep if state_fips == 15
decode state_name, gen(State)
rename state_fips StateFips
rename state_leaid State_leaid
decode district_agency_type, gen(DistType)
rename county_code CountyCode
rename county_name CountyName
rename state_location StateAbbrev
rename ncesdistrictid NCESDistrictID
merge 1:m NCESDistrictID using "`temp2'"
append using "`temp1'"
replace State_leaid = "HI-001"
replace Flag_CutScoreChange_read = ""
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`cleaned'/HI_AssmtData_`year'.dta", replace
export delimited "`cleaned'/HI_AssmtData_`year'.csv", replace
clear
}

