clear

// Define file paths

global original_files "/Users/meghancornacchia/Desktop/DataRepository/Louisiana/Original Data Files"
global NCES_files "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
global output_files "/Users/meghancornacchia/Desktop/DataRepository/Louisiana/Output"
global temp_files "/Users/meghancornacchia/Desktop/DataRepository/Louisiana/Temporary Data Files"

** 2022-23 Proficiency Data
/*
import excel "$original_files/LA_OriginalData_2023_nostate.xlsx", sheet("2023 LEAP SUPPRESSED") cellrange(A3:BE93445) firstrow allstring clear

rename ELA AvgScaleScoreela
rename Math AvgScaleScoremath
rename Science AvgScaleScoresci
rename SocialStudies AvgScaleScoresoc

rename TotalStudentTested StudentSubGroup_TotalTestedela
rename Advanced Lev5_countela
rename P Lev5_percentela
rename Mastery Lev4_countela
rename R Lev4_percentela
rename Basic Lev3_countela
rename T Lev3_percentela
rename ApproachingBasic Lev2_countela
rename V Lev2_percentela
rename Unsatisfactory Lev1_countela
rename X Lev1_percentela

rename Y StudentSubGroup_TotalTestedmath
rename Z Lev5_countmath
rename AA Lev5_percentmath
rename AB Lev4_countmath
rename AC Lev4_percentmath
rename AD Lev3_countmath
rename AE Lev3_percentmath
rename AF Lev2_countmath
rename AG Lev2_percentmath
rename AH Lev1_countmath
rename AI Lev1_percentmath

rename AJ StudentSubGroup_TotalTestedsci
rename AK Lev5_countsci
rename AL Lev5_percentsci
rename AM Lev4_countsci
rename AN Lev4_percentsci
rename AO Lev3_countsci
rename AP Lev3_percentsci
rename AQ Lev2_countsci
rename AR Lev2_percentsci
rename AS Lev1_countsci
rename AT Lev1_percentsci

rename AU StudentSubGroup_TotalTestedsoc
rename AV Lev5_countsoc
rename AW Lev5_percentsoc
rename AX Lev4_countsoc
rename AY Lev4_percentsoc
rename AZ Lev3_countsoc
rename BA Lev3_percentsoc
rename BB Lev2_countsoc
rename BC Lev2_percentsoc
rename BD Lev1_countsoc
rename BE Lev1_percentsoc

gen DataLevel = "School"
replace DataLevel = "District" if SchoolName == ""
replace DataLevel = "State" if SchoolSystemName == "Louisiana Statewide"

** Reshape Wide to Long

generate id = _n
reshape long Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count StudentSubGroup_TotalTested AvgScaleScore, i(id) j(Subject, string)
drop id
drop if StudentSubGroup_TotalTested == ""
drop if SchoolSystemCode == "" & DataLevel != "State"

save "${temp_files}/2023_all_subjects_nostate.dta", replace
*/
/*
import excel "$original_files/LA_OriginalData_2023_state.xlsx", sheet("Sheet1") cellrange(A3:Be93607) firstrow clear

rename ELA AvgScaleScoreela
rename Math AvgScaleScoremath
rename Science AvgScaleScoresci
rename SocialStudies AvgScaleScoresoc

rename TotalStudentTested StudentSubGroup_TotalTestedela
rename Advanced Lev5_countela
rename P Lev5_percentela
rename Mastery Lev4_countela
rename R Lev4_percentela
rename Basic Lev3_countela
rename T Lev3_percentela
rename ApproachingBasic Lev2_countela
rename V Lev2_percentela
rename Unsatisfactory Lev1_countela
rename X Lev1_percentela

rename Y StudentSubGroup_TotalTestedmath
rename Z Lev5_countmath
rename AA Lev5_percentmath
rename AB Lev4_countmath
rename AC Lev4_percentmath
rename AD Lev3_countmath
rename AE Lev3_percentmath
rename AF Lev2_countmath
rename AG Lev2_percentmath
rename AH Lev1_countmath
rename AI Lev1_percentmath

rename AJ StudentSubGroup_TotalTestedsci
rename AK Lev5_countsci
rename AL Lev5_percentsci
rename AM Lev4_countsci
rename AN Lev4_percentsci
rename AO Lev3_countsci
rename AP Lev3_percentsci
rename AQ Lev2_countsci
rename AR Lev2_percentsci
rename AS Lev1_countsci
rename AT Lev1_percentsci

rename AU StudentSubGroup_TotalTestedsoc
rename AV Lev5_countsoc
rename AW Lev5_percentsoc
rename AX Lev4_countsoc
rename AY Lev4_percentsoc
rename AZ Lev3_countsoc
rename BA Lev3_percentsoc
rename BB Lev2_countsoc
rename BC Lev2_percentsoc
rename BD Lev1_countsoc
rename BE Lev1_percentsoc

keep if SchoolSystemName == "Louisiana Statewide"
gen DataLevel = "State"

** Reshape Wide to Long

generate id = _n
reshape long Lev1_percent Lev1_count Lev2_percent Lev2_count Lev3_percent Lev3_count Lev4_percent Lev4_count Lev5_percent Lev5_count StudentSubGroup_TotalTested AvgScaleScore, i(id) j(Subject, string)
drop id
drop if StudentSubGroup_TotalTested == ""

tostring AvgScaleScore, replace

append using "${temp_files}/2023_all_subjects_nostate.dta"

save "${temp_files}/2023_all_subjects.dta", replace

*/

use "${temp_files}/2023_all_subjects.dta", clear

** Keep only regular assessment
drop if InnovativeAssessmentProgram == "Y"

** Rename Variables

rename SchoolSystemCode StateAssignedDistID
rename SchoolSystemName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
//rename Group StudentGroup

// Fix GradeLevel values

replace GradeLevel = "G" + GradeLevel


//// Use this code if decide to use ranges for StudentGroup_TotalTested
/*
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested_num) force
gen StudentSubGroup_TotalTested_min = StudentSubGroup_TotalTested_num
replace StudentSubGroup_TotalTested_min = 0 if StudentSubGroup_TotalTested == "<10"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen StudentGroup_TotalTested_min = sum(StudentSubGroup_TotalTested_min)
tostring StudentGroup_TotalTested_min, replace

gen StudentSubGroup_TotalTested_max = StudentSubGroup_TotalTested_num
replace StudentSubGroup_TotalTested_max = 10 if StudentSubGroup_TotalTested == "<10"
bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen StudentGroup_TotalTested_max = sum(StudentSubGroup_TotalTested_max)
tostring StudentGroup_TotalTested_max, replace

gen StudentGroup_TotalTested = StudentGroup_TotalTested_min + "-" + StudentGroup_TotalTested_max
replace StudentGroup_TotalTested = StudentGroup_TotalTested_max if StudentGroup_TotalTested_max == StudentGroup_TotalTested_min

drop *max *min
*/

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"
gen SchYear = "2022-23"
gen AssmtName = "LEAP 2025"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 4-5"
gen State = "Louisiana"

** Generate Empty Variables

gen ParticipationRate = "--"
replace AvgScaleScore = "*" if AvgScaleScore == ""

** Fix Variable Types

replace Lev1_percent = subinstr(Lev1_percent, " ", "", .)
replace Lev2_percent = subinstr(Lev2_percent, " ", "", .)
replace Lev3_percent = subinstr(Lev3_percent, " ", "", .)
replace Lev4_percent = subinstr(Lev4_percent, " ", "", .)
replace Lev5_percent = subinstr(Lev5_percent, " ", "", .)
replace Lev1_percent = subinstr(Lev1_percent, "%", "", .)
replace Lev2_percent = subinstr(Lev2_percent, "%", "", .)
replace Lev3_percent = subinstr(Lev3_percent, "%", "", .)
replace Lev4_percent = subinstr(Lev4_percent, "%", "", .)
replace Lev5_percent = subinstr(Lev5_percent, "%", "", .)

// Renaming student groups and subgroups
rename Subgroup StudentSubGroup


gen StudentGroup = ""

replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged"

replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Economically Disadvantaged"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

replace StudentGroup = "Disability Status" if StudentSubGroup == "Regular Education"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Regular Education"

replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"

replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

replace StudentGroup = "RaceEth" if StudentSubGroup == "White"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"

replace StudentGroup = "EL Status" if StudentSubGroup == "Not English Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learner"

replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"

replace StudentGroup = "Migrant Status" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"

replace StudentGroup = "All Students" if StudentSubGroup == "Total Population"
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total Population"

replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military Affiliated"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Affiliated"

replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Not Military Affiliated"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not Military Affiliated"

replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Not Foster Care"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not Foster Care"

replace StudentGroup = "Homeless Status" if StudentSubGroup == "Homeless"

replace StudentGroup = "Homeless Status" if StudentSubGroup == "Not Homeless"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"

replace StudentGroup = "Gender" if StudentSubGroup == "Female"
replace StudentGroup = "Gender" if StudentSubGroup == "Male"

keep if StudentGroup == "Economic Status" | StudentGroup == "Disability Status" | StudentGroup == "RaceEth" | StudentGroup == "Migrant Status" | StudentGroup == "All Students" | StudentGroup == "EL Status" | StudentGroup == "Gender" | StudentGroup == "Military Connected Status" | StudentGroup == "Foster Care Status" | StudentGroup == "Homeless Status"


** Handling state level counts
foreach v of varlist Lev*_count {
	destring `v', g(n`v') force
}

gen nStudentSubGroup_TotalTested = nLev1_count + nLev2_count + nLev3_count + nLev4_count + nLev5_count
tostring nStudentSubGroup_TotalTested, gen(sStudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = sStudentSubGroup_TotalTested if DataLevel == "State"

drop sStudentSubGroup_TotalTested

// Generating Student Group Counts
save "$temp_files/LA_2023_nogroup.dta", replace
keep if StudentSubGroup=="All Students"
keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "$temp_files/LA_2023_group.dta", replace
clear
use "$temp_files/LA_2023_nogroup.dta"
merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "$temp_files/LA_2023_group.dta"
drop _merge

// Finding subgroup counts for suppressed level counts at state level
bysort DistName SchName Subject GradeLevel StudentGroup: egen non_missing_count = total(nStudentSubGroup_TotalTested)

destring StudentGroup_TotalTested, gen(nStudentGroup_TotalTested) force
replace nStudentSubGroup_TotalTested = nStudentGroup_TotalTested - non_missing_count
tostring nStudentSubGroup_TotalTested, gen(sStudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = sStudentSubGroup_TotalTested if StudentSubGroup_TotalTested == "."

drop sStudentSubGroup_TotalTested
drop nStudentGroup_TotalTested
drop nLev*_count
drop nStudentSubGroup_TotalTested


** Convert Proficiency Data into Percentages

foreach v of varlist Lev*_percent {
	destring `v', g(n`v') i(* -) force
	replace n`v' = n`v' / 100 if n`v' != .
	generate lessthan`v' = 1 if `v'=="<5"
	generate greaterthan`v' = 1 if `v'==">95"
	tostring n`v', replace force
	replace `v' = n`v' if `v' != "*"
	replace `v' = "0-0.05" if lessthan`v' == 1
	replace `v' = "0.95-1" if greaterthan`v' == 1
}


** Generate Proficient or Above Percent

gen Lev4max = Lev4_percent
replace Lev4max = ".05" if Lev4_percent== "0-0.05"
replace Lev4max = "1" if Lev4_percent== "0.95-1"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_percent
replace Lev4min = "0" if Lev4_percent== "0-0.05"
replace Lev4min = "0.95" if Lev4_percent== "0.95-1"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_percent
replace Lev5max = ".05" if Lev5_percent== "0-0.05"
replace Lev5max = "1" if Lev5_percent== "0.95-1"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_percent
replace Lev5min = "0" if Lev5_percent== "0-0.05"
replace Lev5min = "0.95" if Lev5_percent== "0.95-1"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace force
tostring ProficientOrAbovemax, replace force
gen ProficientOrAbove_percent = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_percent = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="."
drop Lev4max Lev4maxnumber Lev4min Lev4minnumber Lev5max Lev5maxnumber Lev5min Lev5minnumber ProficientOrAbovemin ProficientOrAbovemax


** Generate Proficient or Above Count

gen Lev4max = Lev4_count
replace Lev4max = "9" if Lev4_count== "<10"
destring Lev4max, generate(Lev4maxnumber) force
gen Lev4min = Lev4_count
replace Lev4min = "0" if Lev4_count== "<10"
destring Lev4min, generate(Lev4minnumber) force
gen Lev5max = Lev5_count
replace Lev5max = "9" if Lev5_count== "<10"
destring Lev5max, generate(Lev5maxnumber) force
gen Lev5min = Lev5_count
replace Lev5min = "0" if Lev5_count== "<10"
destring Lev5min, generate(Lev5minnumber) force
gen ProficientOrAbovemin = Lev4minnumber + Lev5minnumber
gen ProficientOrAbovemax = Lev4maxnumber + Lev5maxnumber
tostring ProficientOrAbovemin, replace force
tostring ProficientOrAbovemax, replace force
gen ProficientOrAbove_count = ProficientOrAbovemin + "-" + ProficientOrAbovemax
replace ProficientOrAbove_count = ProficientOrAbovemax if ProficientOrAbovemax == ProficientOrAbovemin
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count=="."
replace Lev1_percent = "*" if Lev1_percent=="."
replace Lev2_percent = "*" if Lev2_percent=="."
replace Lev3_percent = "*" if Lev3_percent=="."
replace Lev4_percent = "*" if Lev4_percent=="."
replace Lev5_percent = "*" if Lev5_percent=="."
replace Lev1_count = "*" if Lev1_count==" "
replace Lev2_count = "*" if Lev2_count==" "
replace Lev3_count = "*" if Lev3_count==" "
replace Lev4_count = "*" if Lev4_count==" "
replace Lev5_count = "*" if Lev5_count==" "

// Make counts ranges
foreach v of varlist Lev*_count {
	replace `v' = "0-9" if `v' == "<10"
}

** Generating NCES Variables

gen State_leaid = "LA-" + StateAssignedDistID if DataLevel != "State"
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"

save "$temp_files/2023_preNCES.dta", replace


// Merging with list of ids for unmerged schools

import excel "$original_files/LA_unmerged.xlsx", sheet("Sheet1") firstrow clear

keep if strpos(KeepDrop, "Keep") != 0
keep if SchYear == "2022-23"
tostring NCESDistrictIDOLD, replace format(%12.0f) force
replace NCESDistrictIDNEW = NCESDistrictIDOLD if NCESDistrictIDNEW == ""
keep State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear NCESDistrictIDNEW NCESSchoolID

tostring NCESSchoolID, replace format(%12.0f)
replace NCESSchoolID = "" if NCESSchoolID == "."
rename NCESDistrictIDNEW NCESDistrictID
tostring NCESDistrictID, replace format(%12.0f)
replace NCESDistrictID = "" if NCESDistrictID == "."
rename DistNameCurrent DistName

merge 1:m State_leaid DataLevel seasch StateAssignedDistID DistName StateAssignedSchID SchName SchYear using "${temp_files}/2023_preNCES.dta", nogenerate

drop DistName

replace SchName = "Audubon Charter School - Gentilly" if SchName == "Audubon Charter Gentilly"

save "$temp_files/2023_preNCES.dta", replace

// NCES school merging for originally unmerged obs

use "$NCES_files/NCES_2022_School.dta", clear

keep state_location state_fips_id district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual DistLocale county_name county_code lea_name

keep if state_fips_id == 22
	
rename lea_name DistName
rename state_leaid State_leaid
rename school_type SchType
decode district_agency_type, gen(district_agency_type_new)
drop district_agency_type
rename district_agency_type_new district_agency_type
rename ncesschoolid NCESSchoolID

merge 1:m NCESSchoolID using "${temp_files}/2023_preNCES.dta", keep(match using) nogenerate
save "$temp_files/2023_preNCES.dta", replace

// NCES school merging for other obs

use "$NCES_files/NCES_2022_School.dta", clear 

keep state_location state_fips_id district_agency_type school_type ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual DistLocale county_name county_code

keep if state_fips_id == 22

rename state_leaid State_leaid
rename school_type SchType
decode district_agency_type, gen(district_agency_type_new)
drop district_agency_type
rename district_agency_type_new district_agency_type
rename ncesschoolid NCESSchoolID

merge 1:m seasch using "${temp_files}/2023_preNCES.dta"

keep if _merge == 3 | DataLevel == "District" | DataLevel == "State" | NCESSchoolID == "220117002430"

drop _merge

// Fix one unmerged district
replace DistName = "Orleans Parish" if NCESSchoolID == "220117002430"
replace DistCharter = "No" if NCESSchoolID == "220117002430"
replace SchLevel = 2 if NCESSchoolID == "220117002430"
replace state_fips_id = 22 if NCESSchoolID == "220117002430"
replace ncesdistrictid = "2201170" if NCESSchoolID == "220117002430"
replace DistLocale = "City, large" if NCESSchoolID == "220117002430"
replace county_code = "22071" if NCESSchoolID == "220117002430"
replace county_name = "Orleans Parish" if NCESSchoolID == "220117002430"
replace state_location = "LA" if NCESSchoolID == "220117002430"
replace SchVirtual = 0 if NCESSchoolID == "220117002430"
replace SchType = 1 if NCESSchoolID == "220117002430"
replace district_agency_type = "Regular local school district" if NCESSchoolID == "220117002430"

save "$temp_files/2023_preNCES.dta", replace

// NCES district merging for originally unmerged obs
use "$NCES_files/NCES_2022_District.dta", clear

keep if state_fips_id == 22

keep state_location state_fips_id district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code

rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
drop if State_leaid == ""

merge 1:m NCESDistrictID using "$temp_files/2023_preNCES.dta", keep(match using) nogenerate
save "$temp_files/2023_preNCES.dta", replace

// NCES district merging for other obs
use "$NCES_files/NCES_2022_District.dta", clear

keep if state_fips_id == 22

keep state_location state_fips_id district_agency_type ncesdistrictid state_leaid DistCharter DistLocale county_name county_code

rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
drop if State_leaid == ""

merge 1:m State_leaid using "$temp_files/2023_preNCES.dta"

keep if _merge == 3 | DataLevel == "State"

// Rename NCES variables
rename district_agency_type DistType
rename state_location StateAbbrev
rename state_fips_id StateFips
rename county_name CountyName
rename county_code CountyCode

// Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// Fixing missing state data
replace StateAbbrev = "LA" if DataLevel == 1
replace StateFips = 22 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel == 1


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

** Export 2022-23 Assessment Data

save "$output_files/LA_AssmtData_2023.dta", replace
export delimited using "$output_files/LA_AssmtData_2023.csv", replace