clear
set more off

global output "/Users/maggie/Desktop/Michigan/Output"
global NCES "/Users/maggie/Desktop/Michigan/NCES/Cleaned"

cd "/Users/maggie/Desktop/Michigan"

use "${output}/MI_AssmtData_2018_all.dta", clear

** Rename existing variables

rename SchoolYear SchYear
rename TestType AssmtName
rename DistrictCode State_leaid
rename DistrictName DistName
rename BuildingCode seasch
rename BuildingName SchName
rename GradeContentTested GradeLevel
rename ReportCategory StudentSubGroup
rename TotalAdvanced Lev4_count
rename TotalProficient Lev3_count
rename TotalPartiallyProficient Lev2_count
rename TotalNotProficient Lev1_count
rename TotalMet ProficientOrAbove_count
rename NumberAssessed StudentSubGroup_TotalTested
rename PercentAdvanced Lev4_percent
rename PercentProficient Lev3_percent
rename PercentPartiallyProficient Lev2_percent
rename PercentNotProficient Lev1_percent
rename PercentMet ProficientOrAbove_percent
rename AvgSS AvgScaleScore

** Dropping entries

keep if AssmtName == "M-STEP"
drop if ISDName != "Statewide" & DistName == "All Districts"
drop if StudentSubGroup == "Students With Disabilities" | StudentSubGroup == "Students Without Disabilities"

** Dropping extra variables

drop TestPopulation ISDCode ISDName CountyCode CountyName EntityType SchoolLevel Locale MISTEM_NAME MISTEM_CODE TotalSurpassed TotalAttained TotalEmergingTowards TotalDidNotMeet PercentSurpassed PercentAttained PercentEmergingTowards PercentDidNotMeet StdDevSS MeanPtsEarned MinScaleScore MaxScaleScore ScaleScore25 ScaleScore50 ScaleScore75

** Changing DataLevel

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "All Buildings"
replace DataLevel = "State" if DistName == "All Districts"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Replacing variables

replace SchYear = "2017-18"

replace SchName = "All Schools" if DataLevel != 3

replace Subject = "ela" if Subject == "ELA" 
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "soc" if Subject == "Social Studies"

tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic of Any Race"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learners"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"

** Generating new variables

gen AssmtType = "Regular"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"

gen StudentSubGroup_TotalTested2 = StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

gen ParticipationRate = "--"

** Converting Data to String

local level 1 2 3 4

foreach a of local level {
	gen Lev`a'_percent2 = Lev`a'_percent
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,"%","",.)
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,"<=","",.)	
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,">=","",.)
	destring Lev`a'_percent2, replace force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2 if strpos(Lev`a'_percent, "%") == 0
	replace Lev`a'_percent = "<=" + Lev`a'_percent2 if strpos(Lev`a'_percent, "<") > 0
	replace Lev`a'_percent = ">=" + Lev`a'_percent2 if strpos(Lev`a'_percent, ">") > 0
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
	drop Lev`a'_percent2
	}

gen test = ""
replace test = "less" if strpos(ProficientOrAbove_percent, "<") > 0
replace test = "greater" if strpos(ProficientOrAbove_percent, ">") > 0
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,"%","",.)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,"<=","",.)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,">=","",.)
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "<=" + ProficientOrAbove_percent if test == "less"
replace ProficientOrAbove_percent = ">=" + ProficientOrAbove_percent if test == "greater"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
drop test

** Merging with NCES

tostring State_leaid, gen(StateAssignedDistID)
replace StateAssignedDistID = "33020" if SchName == "Ingham Academy/Family Center"
replace StateAssignedDistID = "" if DataLevel == 1

gen leadingzero = 1 if State_leaid < 10000
tostring State_leaid, replace
replace State_leaid = "0" + State_leaid if leadingzero == 1
drop leadingzero
replace State_leaid = "MI-" + State_leaid
replace State_leaid = "MI-33020" if SchName == "Ingham Academy/Family Center"
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCES}/NCES_2017_District.dta"

drop if _merge == 2
drop _merge

tostring seasch, gen(StateAssignedSchID)
replace StateAssignedSchID = "" if DataLevel != 3

gen leadingzero = 1 if seasch < 10000
replace leadingzero = 2 if seasch < 1000
replace leadingzero = 3 if seasch < 100
replace leadingzero = 4 if seasch < 10
tostring seasch, replace
replace seasch = "0" + seasch if leadingzero == 1
replace seasch = "00" + seasch if leadingzero == 2
replace seasch = "000" + seasch if leadingzero == 3
replace seasch = "0000" + seasch if leadingzero == 4
drop leadingzero
replace seasch = State_leaid + "-" + seasch
replace seasch = subinstr(seasch,"MI-","",.)
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2017_School.dta"

drop if _merge == 2
drop _merge

replace NCESSchoolID = "268062005335" if seasch == "41000-02806"
replace NCESSchoolID = "268085007799" if seasch == "61000-09766"
replace NCESSchoolID = "260110308093" if seasch == "82015-09994"

merge m:1 NCESSchoolID using "${NCES}/NCES_2021_School.dta", update

drop if _merge == 2
drop _merge

replace StateAbbrev = "MI" if DataLevel == 1
replace State = 26 if DataLevel == 1
replace StateFips = 26 if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MI_AssmtData_2018.dta", replace

export delimited using "${output}/csv/MI_AssmtData_2018.csv", replace
