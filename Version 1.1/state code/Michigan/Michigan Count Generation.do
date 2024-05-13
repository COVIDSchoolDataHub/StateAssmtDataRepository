clear
set more off
set trace off

global output "/Volumes/T7/State Test Project/Michigan/Original Data"
global NCES "/Volumes/T7/State Test Project/Michigan/NCES"

cd "/Volumes/T7/State Test Project/Michigan"

*foreach year in 2015 2016 2017 2018 2019 2021 2022 2023

foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 {
	
	use "${output}/MI_AssmtData_`year'.dta", clear
	
// 	browse State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested

destring StudentGroup_TotalTested, gen(total_count) ignore("*")
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen All = max(total_count)

* drop if StudentGroup=="All Students" & All ==.
destring StudentSubGroup_TotalTested, gen(Count_n) ignore("<10")
replace Count_n=0 if StudentSubGroup_TotalTested == "<10"
* drop All total_count

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = sum(Count_n) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = sum(Count_n) if StudentGroup == "Disability Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Eng = sum(Count_n) if StudentGroup == "EL Status"

gen not_count=.

replace not_count = All - Econ if StudentSubGroup == "Economically Disadvantaged"
replace not_count = All - Disability if StudentSubGroup == "SWD"
replace not_count = All - Eng if StudentSubGroup == "English Learner"

tostring not_count, replace

replace StudentSubGroup_TotalTested=not_count if StudentSubGroup_TotalTested=="<10" & StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup_TotalTested=not_count if StudentSubGroup_TotalTested=="<10" & StudentSubGroup == "SWD"
replace StudentSubGroup_TotalTested=not_count if StudentSubGroup_TotalTested=="<10" & StudentSubGroup == "English Learner"

tostring All, replace
replace StudentGroup_TotalTested=All if StudentGroup_TotalTested=="*"

replace StudentSubGroup_TotalTested = "1-9" if StudentSubGroup_TotalTested == "<10"
* replace Lev*_count = "1-2" if Lev*_count == "<3"
foreach v of varlist Lev*_percent ProficientOrAbove_percent {
	replace `v'="0"+`v' if substr(`v', 1, 1)=="."
	gen `v'1 = subinstr(`v', "<=", "0-0", .)
	replace `v'=`v'1 if strpos(`v', "<=")
	drop `v'1
	
	replace `v'=`v'+"-1" if substr(`v', 1, 1)==">"
	gen `v'1 = substr(`v', 3, .)
	replace `v' = `v'1 if strpos(`v', ">=")
	drop `v'1
	replace `v'="0"+`v' if substr(`v', 1, 1)=="."
	
}
foreach v of varlist Lev*_count ProficientOrAbove_count{
	replace `v' = "1-2" if `v' == "<3"
}

replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="1-9" if StudentSubGroup_TotalTested=="." 
	
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MI_AssmtData_`year'.dta", replace

export delimited using "${output}/csv/MI_AssmtData_`year'.csv", replace
}


