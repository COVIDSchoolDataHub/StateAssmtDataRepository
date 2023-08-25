clear
set more off

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

local grade 3 4 5 6 7 8
local level 1 2 3 4 5

cd "/Users/maggie/Desktop/Mississippi"

use "${output}/MS_AssmtData_2015_all.dta", clear

** Dropping extra variables

drop NCESDistrictID NCESSchoolID Levels13PCT

** Rename existing variables

rename Grade GradeLevel
rename District DistName
rename StateAssignedDistrictID StateAssignedDistID
rename SchoolName SchName
rename StateAssignedSchoolID StateAssignedSchID
rename TestTakers StudentGroup_TotalTested

foreach a of local level {
	rename Level`a'PCT Lev`a'_percent
}
rename Levels45PCT ProficientOrAbove_percent

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Replace existing variables

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

replace Subject = lower(Subject)

tostring GradeLevel, replace
foreach grd of local grade {
	replace GradeLevel = "G0`grd'" if GradeLevel == "`grd'"
}

** Generating missing variables

gen SchYear = "2014-15"

gen AssmtName = "PARCC"

gen AssmtType = "Regular"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

foreach a of local level {
	gen Lev`a'_count = "--"
}

gen ProficiencyCriteria = "Levels 4-5"
gen ProficientOrAbove_count = "--"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

** Merging Rows

replace DataType = "Proficient" if strpos(DataType, "Aggregated") > 0

sort DataLevel DistName SchName GradeLevel Subject DataType
replace ProficientOrAbove_percent = ProficientOrAbove_percent[_n+1] if missing(ProficientOrAbove_percent)

drop if DataType == "Proficient"
drop DataType

** Dividing Level Percents

foreach a of local level {
	destring Lev`a'_percent, replace force
	replace Lev`a'_percent = Lev`a'_percent/100
	tostring Lev`a'_percent, replace force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
}

destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

** Merging with NCES

replace StateAssignedDistID = "2562" if strpos(DistName, "Human Services") > 0
replace StateAssignedDistID = "Missing/not reported" if DistName == "University Of Southern Mississippi"

gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCES}/NCES_2014_District.dta"

drop if _merge == 2
drop _merge

replace StateAssignedSchID = "1700092" if SchName == "Desoto Co Alternative Center"
replace StateAssignedSchID = "3800094" if SchName == "Lauderdale County Education Skills Center"
replace StateAssignedSchID = "6100092" if SchName == "Learning Center Alternative School"
replace StateAssignedSchID = "0130027" if SchName == "Morgantown College Prep"
replace StateAssignedSchID = "0130026" if SchName == "Morgantown Leadership Academy"
replace StateAssignedSchID = "0130045" if SchName == "Natchez Freshman Academy"
replace StateAssignedSchID = "7620068" if SchName == "Weston Sr H"
replace StateAssignedSchID = "2562008" if SchName == "Williams School"
replace StateAssignedSchID = "Missing/not reported" if SchName == "Dubard School For Language Disorders"

gen seasch = StateAssignedSchID

merge m:1 seasch using "${NCES}/NCES_2014_School.dta"

drop if _merge == 2
drop _merge

replace State = 28
replace StateAbbrev = "MS"
replace StateFips = 28

** Generating new variables

replace NCESDistrictID = "Missing/not reported" if DistName == "University Of Southern Mississippi"
replace NCESSchoolID = "Missing/not reported" if SchName == "Dubard School For Language Disorders"

replace DistName = strproper(DistName)
replace SchName = strproper(SchName)

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2015.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2015.csv", replace
