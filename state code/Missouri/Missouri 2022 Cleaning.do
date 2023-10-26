clear
set more off

global output "/Users/maggie/Desktop/Missouri/Output"
global NCES "/Users/maggie/Desktop/Missouri/NCES/Cleaned"

cd "/Users/maggie/Desktop/Missouri"

use "${output}/MO_AssmtData_2022_state.dta", clear
append using "${output}/MO_AssmtData_2022_district.dta"
append using "${output}/MO_AssmtData_2022_school.dta"

rename YEAR SchYear
rename SUMMARY_LEVEL DataLevel
rename CATEGORY StudentGroup
rename TYPE StudentSubGroup
rename COUNTY_DISTRICT StateAssignedDistID 
rename DISTRICT_NAME DistName
rename SCHOOL_CODE StateAssignedSchID
rename SCHOOL_NAME SchName
rename CONTENT_AREA Subject
rename GRADE_LEVEL GradeLevel
rename REPORTABLE StudentSubGroup_TotalTested
rename BELOW_BASIC Lev1_count
rename BASIC Lev2_count
rename PROFICIENT Lev3_count
rename ADVANCED Lev4_count
rename BELOW_BASIC_PCT Lev1_percent
rename BASIC_PCT Lev2_percent
rename PROFICIENT_PCT Lev3_percent
rename ADVANCED_PCT Lev4_percent

** Dropping variables and entries

drop ACCOUNTABLE NONPARTICIPANTLND NONPARTICIPANTLNDPCT

keep if inlist(GradeLevel, "3", "4", "5", "6", "7", "8")

tab StudentSubGroup

drop if strpos(StudentSubGroup, "IEP") | strpos(StudentSubGroup, "<") | strpos(StudentSubGroup, "EL") | strpos(StudentSubGroup, "Direct Certification") > 0 & StudentSubGroup != "EL Students"
drop if inlist(StudentSubGroup, "Gifted", "High School Vocational", "Migrant", "TitleI")

** Replacing variables

tostring SchYear, replace
replace SchYear = "2021-22"

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
replace StudentGroup = "Economic Status" if strpos(StudentSubGroup, "Free and Reduced Lunch") > 0

replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer. Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic)"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "No Response"
replace StudentSubGroup = "White" if StudentSubGroup == "White (not Hispanic)"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP/ELL Students"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Map Free and Reduced Lunch"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non Free and Reduced Lunch"

replace GradeLevel = "G0" + GradeLevel

gen AssmtName = "MAP"
gen AssmtType = "Regular"

replace Subject = "ela" if Subject == "Eng. Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

local level 1 2 3 4
foreach a of local level{
	destring Lev`a'_percent, replace force
	replace Lev`a'_percent = Lev`a'_percent/100
	tostring Lev`a'_percent, replace force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
}

destring Lev3_percent, gen(Lev3_percent2) force
destring Lev4_percent, gen(Lev4_percent2) force
gen ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
drop Lev3_percent2 Lev4_percent2

destring Lev3_count, gen(Lev3_count2) force
destring Lev4_count, gen(Lev4_count2) force
gen ProficientOrAbove_count = Lev3_count2 + Lev4_count2
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
drop Lev3_count2 Lev4_count2

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

** Merging with NCES

gen State_leaid = StateAssignedDistID
replace State_leaid = "0" + State_leaid if substr(State_leaid, 5, 1) == ""
replace State_leaid = "0" + State_leaid if substr(State_leaid, 6, 1) == ""
replace State_leaid = "MO-" + State_leaid
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

drop if _merge == 2
drop _merge

gen seasch = subinstr(State_leaid, "MO-", "", .) + "-" + StateAssignedSchID + subinstr(State_leaid, "MO-", "", .)
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"

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

save "${output}/MO_AssmtData_2022.dta", replace

export delimited using "${output}/csv/MO_AssmtData_2022.csv", replace
