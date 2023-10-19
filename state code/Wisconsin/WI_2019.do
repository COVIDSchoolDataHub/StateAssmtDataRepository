clear
set more off

global path "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Wisconsin"
global nces "/Users/sarahridley/Desktop/CSDH/Raw/NCES"
global output "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Wisconsin/Output"

import delimited "${path}/WI_OriginalData_2019_all.csv", varnames(1) delimit(",") case(preserve)

// dropping unused variables
drop TEST_RESULT GRADE_GROUP CESA CHARTER_IND COUNTY AGENCY_TYPE

// force this variable to numeric
destring TEST_RESULT_CODE, replace force

// drop if entry was string ('destring force' turns non-numeric-convertible entries to .)
drop if TEST_RESULT_CODE == .

// main test, not alternate
keep if TEST_GROUP == "Forward"

// only grades 3-8
keep if GRADE_LEVEL < 9

// reshape from long to wide
reshape wide STUDENT_COUNT PERCENT_OF_GROUP, i(DISTRICT_NAME SCHOOL_NAME TEST_SUBJECT GRADE_LEVEL GROUP_BY GROUP_BY_VALUE GROUP_COUNT FORWARD_AVERAGE_SCALE_SCORE) j(TEST_RESULT_CODE)

// generating state vars
gen AssmtType = "Regular"

// renaming variables
rename DISTRICT_NAME DistName
rename SCHOOL_NAME SchName
rename TEST_SUBJECT Subject
rename SCHOOL_YEAR SchYear
rename GRADE_LEVEL GradeLevel
rename GROUP_BY StudentGroup
rename GROUP_BY_VALUE StudentSubGroup
rename FORWARD_AVERAGE_SCALE_SCORE AvgScaleScore
rename GROUP_COUNT StudentSubGroup_TotalTested
rename DISTRICT_CODE StateAssignedDistID
rename SCHOOL_CODE StateAssignedSchID
rename TEST_GROUP AssmtName

// renaming groups of variables with *
rename STUDENT_COUNT* Lev*_count
rename PERCENT_OF_GROUP* Lev*_percent

// replacing subject variables
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

// replacing grade level variable
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

// replacing / dropping student group
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "ELL Status"
drop if StudentGroup == "Disability Status"
drop if StudentGroup == "Migrant Status"

// replacing student subgroup
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer Indian"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Isle"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL/LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Eng Prof"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Disadv"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Econ Disadv"

// force numeric type
destring (StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore), replace force

// make sure that proficiency percents are decimals and replace . counts with 0 before aggregating
local levels 1 2 3 4

foreach lvl of local levels {
	replace Lev`lvl'_percent = 0 if Lev`lvl'_percent == .
	replace Lev`lvl'_percent = Lev`lvl'_percent / 100
	replace Lev`lvl'_count = 0 if Lev`lvl'_count == .
}

gen Lev5_count = 0
gen Lev5_percent = 0

// generate prof count, prof rate, and participation rate
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ProficientOrAbove_count = Lev3_count + Lev4_count
gen ParticipationRate = (Lev1_count + Lev2_count + Lev3_count + Lev4_count) / StudentSubGroup_TotalTested
gen ProficiencyCriteria = "Levels 3 and 4"

// generate and replace DataLevel
gen DataLevel = "School"
replace DataLevel = "District" if SchName == "[Districtwide]"
replace DataLevel = "State" if SchName == "[Statewide]"
replace SchName = "All Schools" if (SchName == "[Districtwide]" | SchName == "[Statewide]")
replace DistName = "All Districts" if (DistName == "[Statewide]")
tostring StateAssignedDistID StateAssignedSchID, replace
replace StateAssignedDistID = "" if DistName == "All Districts"
replace StateAssignedSchID = "" if SchName == "All Schools"

// generate flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "Y"

// NCES district data
gen state_leaid = StateAssignedDistID
destring state_leaid, replace force
save temp, replace
clear
import excel "${nces}/NCES_2018_District.xlsx", firstrow case(preserve)

keep if state_name == "Wisconsin"
keep ncesdistrictid state_leaid DistCharter county_name county_code district_agency_type
split state_leaid, p(-)
drop state_leaid state_leaid1
rename state_leaid2 state_leaid
destring state_leaid, replace force
drop if state_leaid == .
merge 1:m state_leaid using temp
drop _merge
// drop extra data from NCES file
drop if DataLevel == ""
tostring state_leaid, replace force

rename district_agency_type DistType
rename state_leaid State_leaid
rename county_name CountyName
rename county_code CountyCode

// fix Seeds of Health Elementary Program and Rocketship to merge
replace ncesdistrictid = "5500074" if SchName == "Seeds of Health Elementary Program"
replace ncesdistrictid = "5500081" if DistName == "Rocketship Education Wisconsin Inc"

// NCES school data
gen seasch = StateAssignedSchID
// fix Seeds of Health Elementary Program to merge
replace seasch = "8121" if SchName == "Seeds of Health Elementary Program"
//replace seasch = "8140" if SchName == "Rocketship Transformation Prep"
//replace seasch = "8133" if SchName == "Rocketship Transformation Prep"
destring seasch, replace force
save temp, replace
clear
import excel "${nces}/NCES_2018_School.xlsx", firstrow case(preserve)

keep if state_name == "Wisconsin"
keep ncesschoolid ncesdistrictid seasch school_type SchLevel SchVirtual
split seasch, p(-)
drop seasch seasch1
rename seasch2 seasch
destring seasch, replace force
merge 1:m seasch ncesdistrictid using temp
drop _merge
drop if DataLevel == ""
tostring seasch, replace force

rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID 
rename school_type SchType

// fix County data for Rocketship
replace CountyName = "Milwaukee County" if DistName == "Rocketship Education Wisconsin Inc"
replace CountyCode = "55079" if DistName == "Rocketship Education Wisconsin Inc"

// sorting
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n DistName SchName Subject GradeLevel StudentGroup
drop DataLevel 
rename DataLevel_n DataLevel

gen State = "Wisconsin"
gen StateAbbrev = "WI"
gen StateFips = 55

// calculate group total tested (after sorted!)
gen StudentGroup_TotalTested = 0
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if StudentGroup_TotalTested == 0

replace State_leaid = "" if State_leaid == "."
replace seasch = "" if seasch == "."

// reordering
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

export delimited using "${output}/WI_AssmtData_2019.csv", replace
