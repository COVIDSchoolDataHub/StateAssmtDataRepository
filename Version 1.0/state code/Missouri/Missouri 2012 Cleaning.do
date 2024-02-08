clear
set more off

global output "/Users/maggie/Desktop/Missouri/Output"
global NCES "/Users/maggie/Desktop/Missouri/NCES/Cleaned"

cd "/Users/maggie/Desktop/Missouri"

use "${output}/MO_AssmtData_2010-2014_state.dta", clear
append using "${output}/MO_AssmtData_2010-2014_statedisag.dta"

keep if YEAR == 2012
drop if strpos(CATEGORY, "MSIP5") > 0
destring MEAN_SCALE_SCORE, replace
gen DataLevel = "State"

append using "${output}/MO_AssmtData_2010-2014_district.dta", force
append using "${output}/MO_AssmtData_2010-2014_districtdisag.dta", force

replace DataLevel = "District" if DataLevel == ""

append using "${output}/MO_AssmtData_2010-2014_school.dta", force

rename SCHOOL_CODE* StateAssignedSchID

append using "${output}/MO_AssmtData_2010-2014_schooldisag.dta", force

replace StateAssignedSchID = SCHOOL_CODE if StateAssignedSchID == .
drop SCHOOL_CODE
rename SCHOOL_NAME SchName
replace DataLevel = "School" if DataLevel == ""

rename COUNTY_DISTRICT StateAssignedDistID 
rename DISTRICT_NAME DistName
rename YEAR SchYear
rename CATEGORY StudentGroup
rename TYPE StudentSubGroup
rename CONTENT_AREA Subject
rename GRADE_LEVEL GradeLevel
rename REPORTABLE StudentSubGroup_TotalTested
rename BELOW_BASIC Lev1_count
rename BASIC Lev2_count
rename PROFICIENT Lev3_count
rename ADVANCED Lev4_count
rename TOP_TWO_LEVELS ProficientOrAbove_count
rename BELOW_BASIC_PCT Lev1_percent
rename BASIC_PCT Lev2_percent
rename PROFICIENT_PCT Lev3_percent
rename ADVANCED_PCT Lev4_percent
rename TOP_TWO_LEVELS_PCT ProficientOrAbove_percent
rename MEAN_SCALE_SCORE AvgScaleScore

** Dropping variables and entries

drop COUNTY_DISTRICT_SCHOOL_CODE SUMMARY_LEVEL ACCOUNTABLE PARTICIPANT LEVEL_NOT_DETERMINED LEVEL_NOT_DETERMINED_PCT BOTTOM_TWO_LEVELS BOTTOM_TWO_LEVELS_PCT MAP_INDEX MEDIAN_SCALE_SCORE MEDIAN_TERRANOVA

keep if SchYear == 2012

drop if strpos(StudentGroup, "MSIP5") > 0
drop if inlist(GradeLevel, "A1", "A2", "AH", "B1", "E1", "E2", "GE", "GV")
drop if inlist(StudentSubGroup, "IEP_student")

** Replacing variables

tostring SchYear, replace
replace SchYear = "2011-12"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Replacing variables

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if DataLevel != 3
tostring StateAssignedDistID, replace
replace StateAssignedDistID = "" if DataLevel == 1

replace StudentGroup = "All Students" if StudentGroup == "Total"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentSubGroup == "LEP/ELL Students"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Map Free and Reduced Lunch"

replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer. Indian or Alaska Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black(not Hispanic)"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "White" if StudentSubGroup == "White(not Hispanic)"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP/ELL Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Map Free and Reduced Lunch"

replace GradeLevel = "G0" + subinstr(GradeLevel, "0", "", .)

gen AssmtName = "MAP"
gen AssmtType = "Regular"

replace Subject = "ela" if Subject == "Eng. Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

local level 1 2 3 4
foreach a of local level{
	replace Lev`a'_percent = Lev`a'_percent/100
}

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

gen ParticipationRate = "--"

** Merging with NCES

gen State_leaid = StateAssignedDistID
replace State_leaid = "0" + State_leaid if substr(State_leaid, 5, 1) == ""
replace State_leaid = "0" + State_leaid if substr(State_leaid, 6, 1) == ""
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCES}/NCES_2011_District.dta"

drop if NCESDistrictID == "" & DataLevel != 1

drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID + State_leaid
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2011_School.dta"

drop if NCESSchoolID == "" & DataLevel == 3

drop if _merge == 2
drop _merge

**

replace StateAbbrev = "MO" if DataLevel == 1
replace State = 29 if DataLevel == 1
replace StateFips = 29 if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MO_AssmtData_2012.dta", replace

export delimited using "${output}/csv/MO_AssmtData_2012.csv", replace
