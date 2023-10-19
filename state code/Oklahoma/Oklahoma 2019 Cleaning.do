clear
set more off

global raw "/Users/maggie/Desktop/Oklahoma/Original Data Files"
global output "/Users/maggie/Desktop/Oklahoma/Output"
global NCES "/Users/maggie/Desktop/Oklahoma/NCES/Cleaned"

cd "/Users/maggie/Desktop/Oklahoma"

use "${raw}/OK_AssmtData_2019.dta", clear

** Renaming variables

rename grade GradeLevel
rename OrganizationId StateAssignedSchID
rename Group SchName
rename Administration SchYear

local subject ELA Mathematics Science
foreach a of local subject{
	rename `a'BelowBasic `a'BelowBasicPer
	rename `a'Basic `a'BasicPer
	rename `a'Proficient `a'ProficientPer
	rename `a'Advanced `a'AdvancedPer
	rename `a'* *`a'
}

** Reshape

tostring ValidN*, replace

reshape long ValidN MeanOPI BelowBasicNo BelowBasicPer BasicNo BasicPer ProficientNo ProficientPer AdvancedNo AdvancedPer, i(StateAssignedSchID GradeLevel) j(Subject) string

** Renaming variables

rename ValidN StudentGroup_TotalTested
rename MeanOPI AvgScaleScore
rename BelowBasicNo Lev1_count
rename BelowBasicPer Lev1_percent
rename BasicNo Lev2_count
rename BasicPer Lev2_percent
rename ProficientNo Lev3_count
rename ProficientPer Lev3_percent
rename AdvancedNo Lev4_count
rename AdvancedPer Lev4_percent

** Dropping entries

drop if Subject == "Science" & GradeLevel != "05" & GradeLevel != "08"

** Replacing variables

tostring SchYear, replace
replace SchYear = "2018-19"

replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

replace GradeLevel = "G" + GradeLevel

gen DataLevel = "School"
replace DataLevel = "District" if substr(StateAssignedSchID, 7, 1) == ""
replace DataLevel = "State" if StateAssignedSchID == "0"

gen StateAssignedDistID = ""
replace StateAssignedSchID = "51I020180" if StateAssignedSchID == "51I020190"
drop if StateAssignedSchID == "05I006105" // Closed school
replace StateAssignedDistID = StateAssignedSchID
sort StateAssignedSchID
replace StateAssignedDistID = StateAssignedDistID[_n-1] if DataLevel == "School"

gen DistName = SchName
replace DistName = DistName[_n-1] if DataLevel == "School"
replace DistName = strtrim(DistName)

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "***"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

replace AvgScaleScore = "*" if AvgScaleScore == "***"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_count = "*" if Lev`a'_count == "***"
}

gen AssmtName = "OSTP"
gen AssmtType = "Regular"

gen Lev5_count = ""
gen Lev5_percent = ""

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"

local level 1 2 3 4

foreach a of local level {
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	}

gen ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

foreach a of local level{
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2
	replace Lev`a'_percent = "*" if Lev`a'_percent2 == "."
	drop Lev`a'_percent2
}

destring Lev3_count, gen(Lev3_count2) force
destring Lev4_count, gen(Lev4_count2) force

gen ProficientOrAbove_count = Lev3_count2 + Lev4_count2
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

drop *count2

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = "OK-" + substr(StateAssignedDistID, 1, 2) + "-" + substr(StateAssignedDistID, 3, 4)
replace State_leaid = "" if DataLevel == 1
drop if DistName == "Jones Academy" | DistName == "Riverside Indian School" // BIE Schools

merge m:1 State_leaid using "${NCES}/NCES_2018_District.dta"

drop if _merge == 2
drop _merge

gen seasch = substr(StateAssignedSchID, 1, 2) + "-" + substr(StateAssignedSchID, 3, 4) + "-" + substr(StateAssignedSchID, 7, 3)
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2018_School.dta"

drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2017_School.dta", update

drop if _merge == 2
drop _merge

replace StateAbbrev = "OK" if DataLevel == 1
replace State = 40 if DataLevel == 1
replace StateFips = 40 if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OK_AssmtData_2019.dta", replace

export delimited using "${output}/csv/OK_AssmtData_2019.csv", replace
