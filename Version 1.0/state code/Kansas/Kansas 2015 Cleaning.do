clear
set more off

global raw "/Users/maggie/Desktop/Kansas/Original Data Files"
global output "/Users/maggie/Desktop/Kansas/Output"
global NCES "/Users/maggie/Desktop/Kansas/NCES/Cleaned"
global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

cd "/Users/maggie/Desktop/Kansas"

use "${raw}/KS_AssmtData_2015.dta", clear

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

drop if inlist(GradeLevel, 10, 13)
drop if inlist(StudentSubGroup, "Free Lunch only", "Reduced Lunch only", "Students with  Disabilities")

** Replacing/generating variables

tostring SchYear, replace
replace SchYear = "2014-15"

replace Subject = strlower(Subject)

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

replace StateAssignedDistID = strtrim(StateAssignedDistID)
replace StateAssignedSchID = strtrim(StateAssignedSchID)
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "0"
replace DataLevel = "State" if StateAssignedDistID == "0"

gen DistName = SchName
sort StateAssignedDistID StateAssignedSchID
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
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Self-Paid Lunch only"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")

gen StudentSubGroup_TotalTested = "--"

replace PctNotValid = PctNotValid/100

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = Lev`a'_percent/100
	replace Lev`a'_percent = Lev`a'_percent/(1-PctNotValid)
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AssmtName = "KAP"
gen AssmtType = "Regular"

gen AvgScaleScore = "--"

gen ParticipationRate = 1 - PctNotValid
drop PctNotValid

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

gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCES}/NCES_2014_District.dta"

drop if _merge == 1 & DataLevel != 1
drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID
merge m:1 seasch using "${NCES}/NCES_2014_School.dta"

drop if _merge == 2
drop _merge

replace StateAbbrev = "KS" if DataLevel == 1
replace State = 20 if DataLevel == 1
replace StateFips = 20 if DataLevel == 1

** Merging with EDFacts Datasets

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactscount2015districtkansas.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactscount2015schoolkansas.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

** State counts

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${raw}/KS_AssmtData_2015_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${raw}/KS_AssmtData_2015_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort State_leaid seasch GradeLevel Subject: egen All = max(StudentSubGroup_TotalTested2)
bysort State_leaid seasch GradeLevel Subject: egen Econ = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Economic Status"
replace StudentSubGroup_TotalTested2 = All - Econ if StudentSubGroup == "Not Economically Disadvantaged"
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0"
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test All Econ

** Generating new variables

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/KS_AssmtData_2015.dta", replace

export delimited using "${output}/csv/KS_AssmtData_2015.csv", replace
