*******************************************************
* WISCONSIN

* File name: WI_2018
* Last update: 2/28/2025

*******************************************************
* Notes

	* This do file import WI 2018 (csv) and saves it as dta. 
	* The file is reshaped, cleaned and merged with NCES 2017.
	* Only the usual output is created. 
*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear

import delimited "${Original}/WI_OriginalData_2018_all.csv", varnames(1) delimit(",") case(preserve)
save "${Original_DTA}/WI_OriginalData_2018_all", replace

use "${Original_DTA}/WI_OriginalData_2018_all", replace
// dropping unused variables
drop TEST_RESULT GRADE_GROUP CESA CHARTER_IND COUNTY AGENCY_TYPE

*drop if TEST_RESULT_CODE == "No Test"
replace TEST_RESULT_CODE = "5000" if TEST_RESULT_CODE == "No Test"

replace TEST_RESULT_CODE = "0" if TEST_RESULT_CODE == "*"

gen Suppressed = "N"
replace Suppressed = "Y" if TEST_RESULT_CODE == "0"

gen SuppressedSubGroup = "N"
replace SuppressedSubGroup = "Y" if GROUP_BY_VALUE == "[Data Suppressed]"

//convert this variable to numeric
replace STUDENT_COUNT = "5000" if STUDENT_COUNT == "*"
replace PERCENT_OF_GROUP = "5000" if PERCENT_OF_GROUP == "*"
replace GROUP_COUNT = "5000" if GROUP_COUNT == "*"

// force this variable to numeric
destring STUDENT_COUNT, replace
destring PERCENT_OF_GROUP, replace
destring TEST_RESULT_CODE, replace
destring GROUP_COUNT, replace
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
rename GROUP_COUNT SubGroup_enrollment
rename DISTRICT_CODE StateAssignedDistID
rename SCHOOL_CODE StateAssignedSchID
rename TEST_GROUP AssmtName

// renaming groups of variables with *
rename STUDENT_COUNT* Lev*_count
drop PERCENT_OF_GROUP*

// replace zero counts with zero
forvalues x = 1/4 {
		replace Lev`x'_count = 0 if Lev`x'_count == .
}

drop Lev0_count

// generating group counts and participation rate
gen StudentSubGroup_TotalTested = Lev1_count+Lev2_count+Lev3_count+Lev4_count
gen ParticipationRate = StudentSubGroup_TotalTested / SubGroup_enrollment
forvalues x = 1/4 {
	gen Lev`x'_percent = Lev`x'_count / StudentSubGroup_TotalTested
	replace Lev`x'_percent = 0 if Lev`x'_count == 0
}

drop SubGroup_enrollment
//making unique groups
egen uniquegrp = group(DistName SchName Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
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

// replacing student subgroup
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer Indian"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Isle"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL/LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Eng Prof"
replace StudentSubGroup = "Other" if StudentSubGroup == "Unknown" & StudentGroup == "EL Status"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Disadv"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Econ Disadv"
replace StudentSubGroup = "Other" if StudentSubGroup == "Unknown" & StudentGroup == "Economic Status"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "SwoD"
replace StudentSubGroup = "SWD" if StudentSubGroup == "SwD"

// generate prof count, prof rate, and participation rate
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
gen ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficiencyCriteria = "Levels 3-4"

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
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "N"

// fix Seeds of Health Elementary Program and Rocketship to merge
replace DistName = "Rocketship Southside Community Prep" if StateAssignedDistID == "8002"
replace StateAssignedDistID = "8133" if DistName == "Rocketship Southside Community Prep"

// NCES district data
gen state_leaid = StateAssignedDistID
destring state_leaid, replace force
save temp, replace
clear
use "${NCES_District}/NCES_2017_District"

keep if state_name == "Wisconsin"
keep ncesdistrictid state_leaid DistCharter county_name county_code district_agency_type DistLocale
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

// NCES school data
gen seasch = StateAssignedSchID
// fix Seeds of Health Elementary Program to merge
replace seasch = "8121" if SchName == "Seeds of Health Elementary Program"
destring seasch, replace force
save temp, replace
clear
use "${NCES_School}/NCES_2017_School"

keep if state_name == "Wisconsin"
keep ncesschoolid ncesdistrictid seasch SchType SchLevel SchVirtual DistLocale
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

// fix County data for Rocketship
replace CountyName = "Milwaukee County" if DistName == "Rocketship Southside Community Prep"
replace CountyCode = "55079" if DistName == "Rocketship Southside Community Prep"

// sorting
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop DataLevel 
rename DataLevel_n DataLevel

gen State = "Wisconsin"
gen StateAbbrev = "WI"
gen StateFips = 55

//New StudentGroup_TotalTested v2.0
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1
replace State_leaid = "" if State_leaid == "."
replace seasch = "" if seasch == "."

// Restring Counts
forvalues x = 1/4 {
		tostring Lev`x'_count, replace force format("%9.3g")
		tostring Lev`x'_percent, replace force format("%9.4g")
}
tostring Lev5000_count, replace
foreach var of varlist StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate {
	tostring `var', replace force
}

// Dealing with suppressed cases
foreach var of varlist Lev*_count Lev*_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested ParticipationRate {
	replace `var' = "*" if Suppressed == "Y" & SuppressedSubGroup == "N"
}

gen Lev5_count = ""
gen Lev5_percent = ""

// reordering
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
order `vars'

preserve 

drop if SuppressedSubGroup == "Y"
save "$Temp/WI_2018_wo_suppressed.dta", replace

restore

// Now deal with Subgroup Suppressed Cases

drop if SuppressedSubGroup == "N"

gen n1 = _n

// All Students

replace StudentSubGroup = "All Students" if StudentGroup == "All Students"

// Economic Status

expand 3 if StudentGroup == "Economic Status"

sort n1 DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

by n1: gen copy_id = _n
replace copy_id=. if StudentGroup != "Economic Status"


replace StudentSubGroup="Economically Disadvantaged" if copy_id==1
replace StudentSubGroup="Not Economically Disadvantaged" if copy_id==2
replace StudentSubGroup="Other" if copy_id==3

drop copy_id

// EL Status
expand 3 if StudentGroup == "EL Status"
sort n1 DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
by n1: gen copy_id = _n
replace copy_id=. if StudentGroup != "EL Status"


replace StudentSubGroup="English Learner" if copy_id==1
replace StudentSubGroup="English Proficient" if copy_id==2
replace StudentSubGroup="Other" if copy_id==3

drop copy_id

// Gender

expand 3 if StudentGroup == "Gender"

sort n1 DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

by n1: gen copy_id = _n
replace copy_id=. if StudentGroup != "Gender"


replace StudentSubGroup="Male" if copy_id==1
replace StudentSubGroup="Female" if copy_id==2
replace StudentSubGroup="Unknown" if copy_id==3
drop copy_id
//Migrant Status

expand 2 if StudentGroup == "Migrant Status"
sort n1 DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

by n1: gen copy_id = _n
replace copy_id=. if StudentGroup != "Migrant Status"

replace StudentSubGroup = "Migrant" if copy_id ==1
replace StudentSubGroup = "Non-Migrant" if copy_id == 2
drop copy_id

//Disability Status

expand 2 if StudentGroup == "Disability Status"
sort n1 DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

by n1: gen copy_id = _n
replace copy_id=. if StudentGroup != "Disability Status"

replace StudentSubGroup = "SWD" if copy_id ==1
replace StudentSubGroup = "Non-SWD" if copy_id == 2
drop copy_id



// RaceEth

expand 8 if StudentGroup == "RaceEth"

sort n1 DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

by n1: gen copy_id = _n
replace copy_id=. if StudentGroup != "RaceEth"


replace StudentSubGroup="American Indian or Alaska Native" if copy_id==1
replace StudentSubGroup="Asian" if copy_id==2
replace StudentSubGroup="Black or African American" if copy_id==3
replace StudentSubGroup="Hispanic or Latino" if copy_id==4
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if copy_id==5
replace StudentSubGroup="Two or More" if copy_id==6
replace StudentSubGroup="Unknown" if copy_id==7
replace StudentSubGroup="White" if copy_id==8

drop copy_id

drop n1

// Replace Suppressed with *

foreach var of varlist Lev*_count Lev*_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested ParticipationRate {
	replace `var' = "*" if Suppressed == "Y" & SuppressedSubGroup == "Y"
}

replace Lev5_count = ""
replace Lev5_percent = ""

// Save Suppressed file

save "$Temp/WI_2018_only_suppressed.dta", replace

// Appending

clear

append using "$Temp/WI_2018_only_suppressed.dta" "$Temp/WI_2018_wo_suppressed.dta"

// Dealing with Multi-District Schools
drop if SchName == "Rural Virtual Academy" & NCESDistrictID != "5508940"
drop if SchName == "JEDI Virtual K-12" & NCESSchoolID == ""
replace NCESSchoolID = "Missing" if SchName == "JEDI Virtual K-12 - Jefferson and Eastern Dane County Interactive" & NCESSchoolID == ""

//Post Launch Misc Updates
drop if StudentGroup == "Economic Status" & StudentSubGroup == "Other"
drop if StudentGroup == "EL Status" & StudentSubGroup == "Other"
drop if StudentGroup == "Migrant Status" & StudentSubGroup == "Unknown"
drop if StudentGroup == "Disability Status" & StudentSubGroup == "Unknown"
*drop if StudentGroup == "RaceEth" & StudentSubGroup == "Unknown"
*drop if StudentGroup == "Gender" & StudentSubGroup == "Unknown"

//Dropping Unmerged Virtual School with all data suppressed
drop if SchName == "JEDI Virtual K-12 - Jefferson and Eastern Dane County Interactive" & NCESSchoolID == "Missing"

//Post launch review responsereplace CountyName = "Milwaukee County" if CountyName == "San Mateo County"
replace CountyCode = "55079" if CountyCode== "6081"
replace StudentSubGroup_TotalTested = string(StudentGroup_TotalTested) if StudentSubGroup == "All Students" & StudentSubGroup_TotalTested == "*"

// Sorting and Exporting final
//V2.0 Suppressed Data Issues
replace AvgScaleScore = "*" if AvgScaleScore == ""
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested =="."
drop Suppressed
drop SuppressedSubGroup

// Reordering variables and sorting data
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output*
save "${Output}/WI_AssmtData_2018.dta", replace
export delimited using "${Output}/WI_AssmtData_2018.csv", replace
* END of WI_2018.do
****************************************************
