clear
set more off

global raw "/Users/maggie/Desktop/New Mexico/Original Data Files"
global output "/Users/maggie/Desktop/New Mexico/Output"
global NCES "/Users/maggie/Desktop/New Mexico/NCES/Cleaned"

cd "/Users/maggie/Desktop/New Mexico"

use "${raw}/NM_AssmtData_2022_all.dta", clear

drop SortCode
drop if inlist(Group, "ED", "Foster", "Homeless", "Migrant", "Military", "SwD")

** Renaming variables

rename Code StateAssignedSchID
rename StateorDistrict DistName
rename School SchName
rename Group StudentSubGroup
rename Count StudentSubGroup_TotalTestedela
rename ProficientAbove ProficientOrAbove_percentela
rename J StudentSubGroup_TotalTestedmath
rename K ProficientOrAbove_percentmath
rename L StudentSubGroup_TotalTestedsci
rename M ProficientOrAbove_percentsci

** Reshape

reshape long StudentSubGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject) string

** Replacing/generating variables

gen SchYear = "2021-22"

gen AssmtName = "All Valid Assessments"

gen AssmtType = "Regular and Alternate"

gen GradeLevel = "--"

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "Districtwide"
replace DataLevel = "State" if DistName == "Statewide"

gen StateAssignedDistID = StateAssignedSchID if DataLevel != "State"
replace StateAssignedDistID = substr(StateAssignedDistID, 1, 3) if strlen(StateAssignedDistID) == 6
replace StateAssignedDistID = "0" + substr(StateAssignedDistID, 1, 2) if strlen(StateAssignedDistID) == 5
replace StateAssignedDistID = "00" + substr(StateAssignedDistID, 1, 1) if strlen(StateAssignedDistID) == 4
gen State_leaid = StateAssignedDistID
replace State_leaid = "NM-" + State_leaid
replace State_leaid = "" if DataLevel == "State"

replace StateAssignedSchID = substr(StateAssignedSchID, -3, .)
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != "School"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "FRL"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == ""
replace ProficientOrAbove_percent = "0-0.20" if ProficientOrAbove_percent == "≤ 20"
replace ProficientOrAbove_percent = "0.80-1" if ProficientOrAbove_percent == "≥ 80"

local level 1 2 3 4
foreach a of local level {
	gen Lev`a'_percent = "--"
	gen Lev`a'_count = "--"
}

gen Lev5_percent = ""
gen Lev5_count = ""

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"

gen ProficientOrAbove_count = "--"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"
drop if _merge == 2
drop _merge

replace StateAbbrev = "NM" if DataLevel == 1
replace State = 35 if DataLevel == 1
replace StateFips = 35 if DataLevel == 1
replace CountyName = "Dona Ana County" if CountyName == "DoÃ±a Ana County"

** Generating new variables

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "Y"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NM_AssmtData_2022.dta", replace

export delimited using "${output}/csv/NM_AssmtData_2022.csv", replace
