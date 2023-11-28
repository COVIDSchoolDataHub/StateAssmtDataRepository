clear
set more off

global raw "/Users/maggie/Desktop/New Mexico/Original Data Files"
global output "/Users/maggie/Desktop/New Mexico/Output"
global NCES "/Users/maggie/Desktop/New Mexico/NCES/Cleaned"

cd "/Users/maggie/Desktop/New Mexico"

use "${raw}/NM_AssmtData_2023_ela.dta", clear
gen Subject = "ela"
append using "${raw}/NM_AssmtData_2023_math.dta"
replace Subject = "math" if Subject == ""
append using "${raw}/NM_AssmtData_2023_sci.dta"
replace Subject = "sci" if Subject == ""

drop if HS == 1
drop if Kto2only == 1
drop HS Title1 Kto2only Met* Unattenuated* Attenuation* *SwD

** Renaming variables

rename DistCode StateAssignedDistID
rename District DistName
rename SchNumb StateAssignedSchID
rename School SchName
rename *ELA* *ela*
rename *MATH* *math*
rename *SCIENCE* *sci*

** Reshape

reshape long Participationela Participationmath Participationsci Proficiencyela Proficiencymath Proficiencysci NProficientela NProficientmath NProficientsci dela dmath dsci, i(StateAssignedDistID StateAssignedSchID Subject) j(StudentSubGroup) string

gen ParticipationRate = ""
gen ProficientOrAbove_percent = ""
gen ProficientOrAbove_count = ""
gen StudentSubGroup_TotalTested = ""

local subject ela math sci
foreach sub of local subject {
	replace ParticipationRate = Participation`sub' if Subject == "`sub'"
	replace ProficientOrAbove_percent = Proficiency`sub' if Subject == "`sub'"
	replace ProficientOrAbove_count = NProficient`sub' if Subject == "`sub'"
	replace StudentSubGroup_TotalTested = d`sub' if Subject == "`sub'"
}

drop *ela *math *sci
drop if StudentSubGroup_TotalTested == ""

** Replacing/generating variables

gen SchYear = "2022-23"

gen AssmtName = "All Valid Assessments"

gen AssmtType = "Regular and Alternate"

gen GradeLevel = "G38"

gen DataLevel = "School"

tostring StateAssignedDistID, replace force
tostring StateAssignedSchID, replace force
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
gen State_leaid = StateAssignedDistID
replace State_leaid = "NM-" + State_leaid

replace StateAssignedSchID = substr(StateAssignedSchID, -3, .)
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID

replace StudentSubGroup = "All Students" if StudentSubGroup == "1All"
replace StudentSubGroup = "Female" if StudentSubGroup == "2Female"
replace StudentSubGroup = "Male" if StudentSubGroup == "3Male"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "4Hispanic"
replace StudentSubGroup = "White" if StudentSubGroup == "5White"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "6Black"
replace StudentSubGroup = "Asian" if StudentSubGroup == "7Asian"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "8Native"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "9Multirace"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "10FRL"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "16EL"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

replace ProficientOrAbove_percent = "0-0.02" if ProficientOrAbove_percent == "≤ 2"
replace ProficientOrAbove_percent = "0-0.05" if ProficientOrAbove_percent == "≤ 5"
replace ProficientOrAbove_percent = "0-0.10" if ProficientOrAbove_percent == "≤ 10"
replace ProficientOrAbove_percent = "0-0.20" if ProficientOrAbove_percent == "≤ 20"
replace ProficientOrAbove_percent = "0.80-1" if ProficientOrAbove_percent == "≥ 80"
replace ProficientOrAbove_percent = "0.90-1" if ProficientOrAbove_percent == "≥ 90"

replace ParticipationRate = "0.80-1" if ParticipationRate == "≥ 80"
replace ParticipationRate = "0.90-1" if ParticipationRate == "≥ 90"
replace ParticipationRate = "0.95-1" if ParticipationRate == "≥ 95"
replace ParticipationRate = "0.98-1" if ParticipationRate == "≥ 98"
replace ParticipationRate = "0.99-1" if ParticipationRate == "≥ 99"

local var StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
foreach v of local var {
	replace `v' = "*" if `v' == "*****"
	replace `v' = "--" if `v' == ""
}

local level 1 2 3 4
foreach a of local level {
	gen Lev`a'_percent = "--"
	gen Lev`a'_count = "--"
}

gen Lev5_percent = ""
gen Lev5_count = ""

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 3-4"

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

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NM_AssmtData_2023.dta", replace

export delimited using "${output}/csv/NM_AssmtData_2023.csv", replace
