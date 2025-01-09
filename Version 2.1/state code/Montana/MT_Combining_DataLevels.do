clear
set more off

global Output "/Volumes/T7/State Test Project/Montana/Output"

forvalues year = 2016/2023 {
	if `year' == 2020 continue
	use "${Output}/MT_AssmtData_`year'_District", clear
	append using "${Output}/MT_AssmtData_`year'_StateDemo" "${Output}/MT_AssmtData_`year'_State"
	recast str7 SchYear

gsort -StudentSubGroup_TotalTested	
duplicates drop StudentSubGroup GradeLevel Subject DistName SchName, force //one duplicate district. If these files are still being used, investigate this.	

//Derive StudentSubGroup_TotalTested as level count/level percent if not missing both
foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace StudentSubGroup_TotalTested = string(round(real(`count')/real(`percent'))) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(`count')) & !missing(real(`percent')) & real(`percent') !=0
}

**StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested based on complementary subgroup where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*
	
//Deriving Counts
foreach count of varlist *_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
}

//Level percent (and corresponding count) derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

foreach percent of varlist Lev*_percent {
	replace `percent' = "0" if real(`percent') <  0.005 & !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent)) & missing(real(ProficientOrAbove_percent))

foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}



//Deriving ProficientOrAbove_percent if we have Level 1 and Level 2
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent)) if missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & (1-real(Lev1_percent)-real(Lev2_percent))>0.01

//Deriving ProficientOrAbove_count if we have Level 1 and 2
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev2_count)) if missing(real(ProficientOrAbove_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(StudentSubGroup_TotalTested))

//Derive Level percent (and corresponding count) if we have ProficientOrAbove_percent
replace Lev3_percent = string(real(ProficientOrAbove_percent)-real(Lev4_percent)) if !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev4_percent)) & missing(real(Lev3_percent))
replace Lev4_percent = string(real(ProficientOrAbove_percent)- real(Lev3_percent)) if !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent)) & missing(real(Lev4_percent))

foreach count of varlist Lev3_count Lev4_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

//Set very slightly high prof percent values to 1 (these are like 1.00000132)
replace ProficientOrAbove_percent = "1" if real(ProficientOrAbove_percent) > 1 & !missing(real(ProficientOrAbove_percent))

//Set ProficientOrAbove_count to Lev3_count + Lev4_count if not missing either
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))

//Updating Flags and AssmtName for Sci 2022 & 2023
if `year' == 2022 {
	replace Flag_CutScoreChange_sci = "Y"
	replace Flag_AssmtNameChange = "Y" if Subject == "sci"
}
if `year' == 2023 replace Flag_CutScoreChange_sci = "N"
if `year' >= 2022 replace AssmtName = "Montana Science Assessment" if Subject == "sci"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode	
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MT_AssmtData_`year'", replace
export delimited "${Output}/MT_AssmtData_`year'", replace
}
