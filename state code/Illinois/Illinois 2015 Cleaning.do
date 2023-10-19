clear
set more off

global output "/Users/maggie/Desktop/Illinois/Output"
global NCES "/Users/maggie/Desktop/Illinois/NCES/Cleaned"

cd "/Users/maggie/Desktop/Illinois"

**** State

use "${output}/IL_AssmtData_2015-2017_all_state.dta", clear

** Dropping extra variables

drop Migrant IEP NotIEP

** Rename existing variables

rename ELA SchYear
rename B GradeLevel
rename TotalTested StudentGroup_TotalTested
rename All ProficientOrAbove_percentAll
rename Male ProficientOrAbove_percentMale
rename Female ProficientOrAbove_percentFemale
rename White ProficientOrAbove_percentWhite
rename Black ProficientOrAbove_percentBlack
rename Hispanic ProficientOrAbove_percentHisp
rename Asian ProficientOrAbove_percentAsian
rename HawaiianPacificIslander ProficientOrAbove_percentHawaii
rename NativeAmerican ProficientOrAbove_percentNative
rename TwoorMoreRaces ProficientOrAbove_percentTwo
rename LEP ProficientOrAbove_percentLearner
rename NotLEP ProficientOrAbove_percentProf
rename LowIncome ProficientOrAbove_percentDis
rename NotLowIncome ProficientOrAbove_percentNotDis

** Dropping entries

keep if SchYear == "2015"

** Replacing variables

replace SchYear = "2014-15"

** Generating new variables

gen AssmtName = "PARCC"
gen AssmtType = "Regular"

local level 1 2 3 4 5

foreach a of local level {
	gen Lev`a'_count = "--"
	gen Lev`a'_percent = "--"
}

gen ProficientOrAbove_count = "--"

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

gen SchName = "All Schools"
gen DistName = "All Districts"

replace GradeLevel = "G0" + subinstr(GradeLevel,"Grade ","",.)
replace GradeLevel = "G38" if GradeLevel == "G0Grade3-8"

gen Subject = ""
replace Subject = "ela" if _n < 8
replace Subject = "math" if _n > 7

gen DataLevel = "State"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping

reshape long ProficientOrAbove_percent, i(GradeLevel Subject) j(StudentSubGroup) string

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaii"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hisp"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Prof"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NotDis"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"

gen StudentSubGroup_TotalTested = "--"
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested if StudentGroup == "All Students"

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

save "${output}/IL_AssmtData_2015_all_state.dta", replace

**** District & Schools

use "${output}/IL_AssmtData_2015_all.dta", clear

** Dropping extra variables

drop County City

** Rename existing variables

rename RCDTS StateAssignedSchID
rename DistrictSchool DataLevel
drop Dist
rename DistrictNameSchoolName SchName
rename Grade3 Lev1_percentela3
rename H Lev2_percentela3
rename I Lev3_percentela3
rename J Lev4_percentela3
rename K Lev5_percentela3
rename L Lev1_percentmath3
rename M Lev2_percentmath3
rename N Lev3_percentmath3
rename O Lev4_percentmath3
rename P Lev5_percentmath3
rename Grade4 Lev1_percentela4
rename R Lev2_percentela4
rename S Lev3_percentela4
rename T Lev4_percentela4
rename U Lev5_percentela4
rename V Lev1_percentmath4
rename W Lev2_percentmath4
rename X Lev3_percentmath4
rename Y Lev4_percentmath4
rename Z Lev5_percentmath4
rename Grade5 Lev1_percentela5
rename AB Lev2_percentela5
rename AC Lev3_percentela5
rename AD Lev4_percentela5
rename AE Lev5_percentela5
rename AF Lev1_percentmath5
rename AG Lev2_percentmath5
rename AH Lev3_percentmath5
rename AI Lev4_percentmath5
rename AJ Lev5_percentmath5
rename Grade6 Lev1_percentela6
rename AL Lev2_percentela6
rename AM Lev3_percentela6
rename AN Lev4_percentela6
rename AO Lev5_percentela6
rename AP Lev1_percentmath6
rename AQ Lev2_percentmath6
rename AR Lev3_percentmath6
rename AS Lev4_percentmath6
rename AT Lev5_percentmath6
rename Grade7 Lev1_percentela7
rename AV Lev2_percentela7
rename AW Lev3_percentela7
rename AX Lev4_percentela7
rename AY Lev5_percentela7
rename AZ Lev1_percentmath7
rename BA Lev2_percentmath7
rename BB Lev3_percentmath7
rename BC Lev4_percentmath7
rename BD Lev5_percentmath7
rename Grade8 Lev1_percentela8
rename BF Lev2_percentela8
rename BG Lev3_percentela8
rename BH Lev4_percentela8
rename BI Lev5_percentela8
rename BJ Lev1_percentmath8
rename BK Lev2_percentmath8
rename BL Lev3_percentmath8
rename BM Lev4_percentmath8
rename BN Lev5_percentmath8

** Dropping entries

drop if StateAssignedSchID == ""

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping

reshape long Lev1_percentela Lev2_percentela Lev3_percentela Lev4_percentela Lev5_percentela Lev1_percentmath Lev2_percentmath Lev3_percentmath Lev4_percentmath Lev5_percentmath, i(StateAssignedSchID) j(GradeLevel) string

reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, i(StateAssignedSchID GradeLevel) j(Subject) string

drop if Lev1_percent == " "

** Replacing variables

replace SchName = "All Schools" if DataLevel != 3

replace GradeLevel = "G0" + GradeLevel

** Generating new variables

gen SchYear = "2014-15"

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)

gen seasch = StateAssignedSchID
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

gen AssmtName = "PARCC"
gen AssmtType = "Regular"

gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4 5

foreach a of local level {
	gen Lev`a'_count = "--"
	destring Lev`a'_percent, replace
	replace Lev`a'_percent = Lev`a'_percent/100
}

gen ProficientOrAbove_count = "--"

gen ProficientOrAbove_percent = Lev4_percent + Lev5_percent
tostring ProficientOrAbove_percent, replace force

foreach a of local level {
	tostring Lev`a'_percent, replace force
}

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

** Merging with NCES

gen StateAssignedDistID = substr(StateAssignedSchID,1,11)

merge m:1 State_leaid using "${NCES}/NCES_2015_District.dta"

drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2015_School.dta"

drop if _merge == 2
drop _merge

**** Appending

append using "${output}/IL_AssmtData_2015_all_state.dta"

replace StateAbbrev = "IL" if DataLevel == 1
replace State = 17 if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

** Generating new variables

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2015.dta", replace

export delimited using "${output}/csv/IL_AssmtData_2015.csv", replace
