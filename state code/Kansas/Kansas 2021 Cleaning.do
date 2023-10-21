clear
set more off

global raw "/Users/maggie/Desktop/Kansas/Original Data Files"
global output "/Users/maggie/Desktop/Kansas/Output"
global NCES "/Users/maggie/Desktop/Kansas/NCES/Cleaned"

cd "/Users/maggie/Desktop/Kansas"

use "${raw}/KS_AssmtData_2021.dta", clear

** Renaming variables

rename OrganizationLevel SchName
rename PctLevelOne Lev1_percent
rename PctLevelTwo Lev2_percent
rename PctLevelThree Lev3_percent
rename PctLevelFour Lev4_percent
rename GroupName StudentSubGroup
rename Grade GradeLevel
rename BldgNo StateAssignedSchID
rename OrgNo StateAssignedDistID
rename SchoolYear SchYear

** Dropping entries

drop PctNotValid

drop if inlist(GradeLevel, 10, 11, 13)

tab StudentSubGroup
drop if strpos(StudentSubGroup, "Disab") | strpos(StudentSubGroup, "only") > 0 & StudentSubGroup != "Self-Paid Lunch only"
drop if inlist(StudentSubGroup, "Foster Care", "Homeless", "Military Connected Students")

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2020-21"

replace Subject = strlower(Subject)
replace Subject = "sci" if Subject == "science"

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace StateAssignedSchID = strtrim(StateAssignedSchID)
replace DataLevel = "District" if StateAssignedSchID == "0"
replace DataLevel = "State" if StateAssignedDistID == "0"

gen DistName = SchName
sort StateAssignedDistID DataLevel
replace DistName = DistName[_n-1] if DataLevel == "School"

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StudentSubGroup = strtrim(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African-American Students"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free and Reduced Lunch"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Racial"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner Students"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = "KS-" + StateAssignedDistID
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCES}/NCES_2020_District.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID

merge m:1 seasch using "${NCES}/NCES_2020_School.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = 20 if DataLevel == 1
replace StateFips = 20 if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/KS_AssmtData_2021.dta", replace

export delimited using "${output}/csv/KS_AssmtData_2021.csv", replace
