clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

** Cleaning 2014-2015 **

use "${output}/MS_AssmtData_2015_all.dta", clear

** Rename existing variables

rename District DistName
rename StateAssignedDistrictID StateAssignedDistID
rename SchoolName SchName
rename StateAssignedSchoolID StateAssignedSchID 

replace Subject = lower(Subject)

** Generating missing variables

gen GradeLevel = ""

replace GradeLevel = "G03" if Grade == 3
replace GradeLevel = "G04" if Grade == 4
replace GradeLevel = "G05" if Grade == 5
replace GradeLevel = "G06" if Grade == 6
replace GradeLevel = "G07" if Grade == 7
replace GradeLevel = "G08" if Grade == 8

drop Grade

gen AssmtName = "PARCC"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""
gen AssmtType = "Regular"
gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

** Merging Rows

replace DataType = "Z Aggregated by Levels 1-3 and 4-5" if DataType == "State Aggregated by Levels 1-3 and 4-5" | DataType == "Aggregated by Levels 1-3 and 4-5"

sort DataLevel DistName SchName GradeLevel Subject DataType
replace Levels13PCT = Levels13PCT[_n+1] if missing(Levels13PCT)
replace Levels45PCT = Levels45PCT[_n+1] if missing(Levels45PCT)

drop if DataType == "Z Aggregated by Levels 1-3 and 4-5"
drop DataType

** Rename existing variables

rename Level1PCT Lev1_percent
rename Level2PCT Lev2_percent
rename Level3PCT Lev3_percent
rename Level4PCT Lev4_percent
rename Level5PCT Lev5_percent
rename Levels45PCT ProficientOrAbove_percent
rename TestTakers StudentGroup_TotalTested

gen Lev1_count = ""
gen Lev2_count = ""
gen Lev3_count = ""
gen Lev4_count = ""
gen Lev5_count = ""
gen AvgScaleScore = ""
gen ProficiencyCriteria = "Levels 4-5"
gen ProficientOrAbove_count = ""
gen ParticipationRate = ""
gen SchYear = "2014-2015"

** Merging with NCES

merge m:1 NCESDistrictID using "${NCES}/NCES_2014_District.dta"
drop if _merge == 2
drop _merge

drop NCESSchoolID
replace StateAssignedSchID = "1700092" if SchName == "Desoto Co Alternative Center"
replace StateAssignedSchID = "0618008" if SchName == "Dubard School For Language Disorders"
replace StateAssignedSchID = "0130045" if SchName == "Natchez Freshman Academy"
gen seasch = StateAssignedSchID
merge m:1 seasch using "${NCES}/NCES_2014_School.dta"
drop if _merge == 2
drop _merge year lea_name county_name
replace State = 28
replace StateAbbrev = "MS"
replace StateFips = 28

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "${output}/MS_AssmtData_2015.dta", replace

export delimited using "/Users/maggie/Desktop/Mississippi/Output/csv/MS_AssmtData_2015.csv", replace
