clear
set more off

global Output "/Volumes/T7/State Test Project/Montana/Output"

forvalues year = 2016/2023 {
	if `year' == 2020 continue
	use "${Output}/MT_AssmtData_`year'_District", clear
	append using "${Output}/MT_AssmtData_`year'_StateDemo" "${Output}/MT_AssmtData_`year'_State"
	recast str7 SchYear
	
//Applying StudentGroup Convetion and Deriving English Learner Count Where Possible
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop StudentGroup_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"	
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
** Deriving
destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG) force
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup Subject GradeLevel DistName SchName)

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & StudentSubGroup == "English Learner"
drop UnsuppressedSG UnsuppressedSSG

//Deriving Counts
foreach count of varlist *_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
}

//Deriving ProficientOrAbove_percent if we have Level 1 and Level 2
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent)) if missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & (1-real(Lev1_percent)-real(Lev2_percent))>0.01

//Deriving ProficientOrAbove_count if we have Level 1 and 2
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev2_count)) if missing(real(ProficientOrAbove_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(StudentSubGroup_TotalTested))

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode	
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MT_AssmtData_`year'", replace
export delimited "${Output}/MT_AssmtData_`year'", replace
}
