clear all
set more off

log using nj_cleaning.log, replace text

cd "/Users/miramehta/Documents/"
global data "/Users/miramehta/Documents/NJ State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//2014-2015
//English
import excel "${data}/NJ_OriginalData_2015_ela_G03", clear
gen Subject = "ela"
gen GradeLevel = "G03"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_ela", replace

import excel "${data}/NJ_OriginalData_2015_ela_G04", clear
gen Subject = "ela"
gen GradeLevel = "G04"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_ela_G04", replace

import excel "${data}/NJ_OriginalData_2015_ela_G05", clear
gen Subject = "ela"
gen GradeLevel = "G05"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_ela_G05", replace

import excel "${data}/NJ_OriginalData_2015_ela_G06", clear
gen Subject = "ela"
gen GradeLevel = "G06"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_ela_G06", replace

import excel "${data}/NJ_OriginalData_2015_ela_G07", clear
gen Subject = "ela"
gen GradeLevel = "G07"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_ela_G07", replace

import excel "${data}/NJ_OriginalData_2015_ela_G08", clear
gen Subject = "ela"
gen GradeLevel = "G08"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_ela_G08", replace

use "${data}/NJ_OriginalData_2015_ela", clear
append using "${data}/NJ_OriginalData_2015_ela_G04" "${data}/NJ_OriginalData_2015_ela_G05" "${data}/NJ_OriginalData_2015_ela_G06" "${data}/NJ_OriginalData_2015_ela_G07" "${data}/NJ_OriginalData_2015_ela_G08"
save "${data}/NJ_AssmtData_2015", replace

//Math
import excel "${data}/NJ_OriginalData_2015_mat_G03", clear
gen Subject = "math"
gen GradeLevel = "G03"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_mat", replace

import excel "${data}/NJ_OriginalData_2015_mat_G04", clear
gen Subject = "math"
gen GradeLevel = "G04"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_mat_G04", replace

import excel "${data}/NJ_OriginalData_2015_mat_G05", clear
gen Subject = "math"
gen GradeLevel = "G05"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_mat_G05", replace

import excel "${data}/NJ_OriginalData_2015_mat_G06", clear
gen Subject = "math"
gen GradeLevel = "G06"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_mat_G06", replace

import excel "${data}/NJ_OriginalData_2015_mat_G07", clear
gen Subject = "math"
gen GradeLevel = "G07"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_mat_G07", replace

import excel "${data}/NJ_OriginalData_2015_mat_G08", clear
gen Subject = "math"
gen GradeLevel = "G08"

drop A B G J K S T U V W
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABLITIES"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2015_mat_G08", replace

use "${data}/NJ_OriginalData_2015_mat", clear
append using "${data}/NJ_OriginalData_2015_mat_G04" "${data}/NJ_OriginalData_2015_mat_G05" "${data}/NJ_OriginalData_2015_mat_G06" "${data}/NJ_OriginalData_2015_mat_G07" "${data}/NJ_OriginalData_2015_mat_G08"
save "${data}/NJ_OriginalData_2015_mat", replace

//Combine Subjects and Clean
use "${data}/NJ_AssmtData_2015", clear
append using "${data}/NJ_OriginalData_2015_mat"

replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL STUDENTS"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AMERICAN INDIAN"
replace StudentSubGroup = "Asian" if StudentSubGroup == "ASIAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "AFRICAN AMERICAN"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER"
replace StudentSubGroup = "White" if StudentSubGroup == "WHITE"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HISPANIC"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "OTHER" & StudentGroup == "RaceEth"
replace StudentSubGroup = "Male" if StudentSubGroup == "MALE"
replace StudentSubGroup = "Female" if StudentSubGroup == "FEMALE"
replace StudentSubGroup = "Students with Disabilities" if StudentSubGroup == "STUDENTS WITH DISABLITIES"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NON ECON. DISADVANTAGED"

gen SchYear = "2014-15"
gen AssmtName = "PARCC"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == ""
replace DataLevel = "State" if StateAssignedDistID == ""
gen Lev1_count =.
gen Lev2_count =.
gen Lev3_count =.
gen Lev4_count =.
gen Lev5_count =.
gen ProficiencyCriteria = "Students in Levels 4 and 5 are proficient."
gen ProficientOrAbove_count =.

gen Meets_percent = Lev4_percent
gen Exceeds_percent = Lev5_percent
destring Meets_percent, replace force
destring Exceeds_percent, replace force
gen ProficientOrAbove_percent = Meets_percent + Exceeds_percent
drop Meets_percent Exceeds_percent

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force
destring Lev5_percent, replace force
destring ProficientOrAbove_percent, replace force
replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace Lev5_percent = Lev5_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring Lev5_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "*" if Lev1_percent == "."
replace Lev2_percent = "*" if Lev2_percent == "."
replace Lev3_percent = "*" if Lev3_percent == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev5_percent = "*" if Lev5_percent == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

gen ParticipationRate =.

replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "${data}/NJ_AssmtData_2015", replace

//Clean NCES Data
use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2014_School.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 3, 6)
rename seasch StateAssignedSchID
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
save "${NCES}/Cleaned NCES Data/NCES_2015_School_NJ.dta", replace

use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2014_District.dta", clear
drop if state_name != 34
gen str StateAssignedDistID = substr(state_leaid, 3, 6)
save "${NCES}/Cleaned NCES Data/NCES_2015_District_NJ.dta", replace

//Merge Data
use "${data}/NJ_AssmtData_2015", clear
merge m:1 StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2015_District_NJ.dta"
drop if _merge == 2

destring StateAssignedSchID, replace force
merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2015_School_NJ.dta", gen (merge2)
drop if merge2 == 2


//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

gen State = "New Jersey"
replace StateAbbrev = "NJ"
replace StateFips = 34

gen seasch = StateAssignedSchID
tostring seasch, replace force
tostring StateAssignedSchID, replace force

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen (DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${data}/NJ_AssmtData_2015", replace
export delimited "${data}/NJ_AssmtData_2015", replace
clear

//2015-2016
//English
import excel "${data}/NJ_OriginalData_2016_ela_G03", clear
gen Subject = "ela"
gen GradeLevel = "G03"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_ela", replace

import excel "${data}/NJ_OriginalData_2016_ela_G04", clear
gen Subject = "ela"
gen GradeLevel = "G04"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_ela_G04", replace

import excel "${data}/NJ_OriginalData_2016_ela_G05", clear
gen Subject = "ela"
gen GradeLevel = "G05"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_ela_G05", replace

import excel "${data}/NJ_OriginalData_2016_ela_G06", clear
gen Subject = "ela"
gen GradeLevel = "G06"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_ela_G06", replace

import excel "${data}/NJ_OriginalData_2016_ela_G07", clear
gen Subject = "ela"
gen GradeLevel = "G07"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_ela_G07", replace

import excel "${data}/NJ_OriginalData_2016_ela_G08", clear
gen Subject = "ela"
gen GradeLevel = "G08"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_ela_G08", replace

use "${data}/NJ_OriginalData_2016_ela", clear
append using "${data}/NJ_OriginalData_2016_ela_G04" "${data}/NJ_OriginalData_2016_ela_G05" "${data}/NJ_OriginalData_2016_ela_G06" "${data}/NJ_OriginalData_2016_ela_G07" "${data}/NJ_OriginalData_2016_ela_G08"
save "${data}/NJ_AssmtData_2016", replace

//Math
import excel "${data}/NJ_OriginalData_2016_mat_G03", clear
gen Subject = "math"
gen GradeLevel = "G03"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_mat", replace

import excel "${data}/NJ_OriginalData_2016_mat_G04", clear
gen Subject = "math"
gen GradeLevel = "G04"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_mat_G04", replace

import excel "${data}/NJ_OriginalData_2016_mat_G05", clear
gen Subject = "math"
gen GradeLevel = "G05"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_mat_G05", replace

import excel "${data}/NJ_OriginalData_2016_mat_G06", clear
gen Subject = "math"
gen GradeLevel = "G06"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_mat_G06", replace

import excel "${data}/NJ_OriginalData_2016_mat_G07", clear
gen Subject = "math"
gen GradeLevel = "G07"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_mat_G07", replace

import excel "${data}/NJ_OriginalData_2016_mat_G08", clear
gen Subject = "math"
gen GradeLevel = "G08"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2016_mat_G08", replace

use "${data}/NJ_OriginalData_2016_mat", clear
append using "${data}/NJ_OriginalData_2016_mat_G04" "${data}/NJ_OriginalData_2016_mat_G05" "${data}/NJ_OriginalData_2016_mat_G06" "${data}/NJ_OriginalData_2016_mat_G07" "${data}/NJ_OriginalData_2016_mat_G08"
save "${data}/NJ_OriginalData_2016_mat", replace

//Combine Subjects and Clean
use "${data}/NJ_AssmtData_2016", clear
append using "${data}/NJ_OriginalData_2016_mat"

replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL STUDENTS"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AMERICAN INDIAN"
replace StudentSubGroup = "Asian" if StudentSubGroup == "ASIAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "AFRICAN AMERICAN"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "NATIVE HAWAIIAN"
replace StudentSubGroup = "White" if StudentSubGroup == "WHITE"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HISPANIC"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "OTHER" & StudentGroup == "RaceEth"
replace StudentSubGroup = "Male" if StudentSubGroup == "MALE"
replace StudentSubGroup = "Female" if StudentSubGroup == "FEMALE"
replace StudentSubGroup = "Students with Disabilities" if StudentSubGroup == "STUDENTS WITH DISABILITIES"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NON-ECON. DISADVANTAGED"

gen SchYear = "2015-16"
gen AssmtName = "PARCC"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == ""
replace DataLevel = "State" if StateAssignedDistID == ""
gen Lev1_count =.
gen Lev2_count =.
gen Lev3_count =.
gen Lev4_count =.
gen Lev5_count =.
gen ProficiencyCriteria = "Students in Levels 4 and 5 are proficient."
gen ProficientOrAbove_count =.

gen Meets_percent = Lev4_percent
gen Exceeds_percent = Lev5_percent
destring Meets_percent, replace force
destring Exceeds_percent, replace force
gen ProficientOrAbove_percent = Meets_percent + Exceeds_percent
drop Meets_percent Exceeds_percent

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force
destring Lev5_percent, replace force
destring ProficientOrAbove_percent, replace force
replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace Lev5_percent = Lev5_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring Lev5_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "*" if Lev1_percent == "."
replace Lev2_percent = "*" if Lev2_percent == "."
replace Lev3_percent = "*" if Lev3_percent == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev5_percent = "*" if Lev5_percent == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

gen ParticipationRate =.

replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "${data}/NJ_AssmtData_2016", replace

//Clean NCES Data
use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2015_School.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 3, 6)
gen StateAssignedSchID = seasch
save "${NCES}/Cleaned NCES Data/NCES_2016_School_NJ.dta", replace

use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2015_District.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 3, 6)
save "${NCES}/Cleaned NCES Data/NCES_2016_District_NJ.dta", replace

//Merge Data
use "${data}/NJ_AssmtData_2016", clear
merge m:1 StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2016_District_NJ.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2016_School_NJ.dta", gen (merge2)
drop if merge2 == 2
save "${data}/NJ_AssmtData_2016", replace

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

gen State = "New Jersey"
replace StateAbbrev = "NJ"
replace StateFips = 34

replace NCESSchoolID = "Missing" if SchName == "SINGLE GENDER ACADEMY" & NCESSchoolID == ""

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen (DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${data}/NJ_AssmtData_2016", replace
export delimited "${data}/NJ_AssmtData_2016", replace
clear

//2016-2017
//English
import excel "${data}/NJ_OriginalData_2017_ela_G03", clear
gen Subject = "ela"
gen GradeLevel = "G03"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_ela", replace

import excel "${data}/NJ_OriginalData_2017_ela_G04", clear
gen Subject = "ela"
gen GradeLevel = "G04"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_ela_G04", replace

import excel "${data}/NJ_OriginalData_2017_ela_G05", clear
gen Subject = "ela"
gen GradeLevel = "G05"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_ela_G05", replace

import excel "${data}/NJ_OriginalData_2017_ela_G06", clear
gen Subject = "ela"
gen GradeLevel = "G06"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_ela_G06", replace

import excel "${data}/NJ_OriginalData_2017_ela_G07", clear
gen Subject = "ela"
gen GradeLevel = "G07"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_ela_G07", replace

import excel "${data}/NJ_OriginalData_2017_ela_G08", clear
gen Subject = "ela"
gen GradeLevel = "G08"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_ela_G08", replace

use "${data}/NJ_OriginalData_2017_ela", clear
append using "${data}/NJ_OriginalData_2017_ela_G04" "${data}/NJ_OriginalData_2017_ela_G05" "${data}/NJ_OriginalData_2017_ela_G06" "${data}/NJ_OriginalData_2017_ela_G07" "${data}/NJ_OriginalData_2017_ela_G08"
save "${data}/NJ_AssmtData_2017", replace

//Math
import excel "${data}/NJ_OriginalData_2017_mat_G03", clear
gen Subject = "math"
gen GradeLevel = "G03"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_mat", replace

import excel "${data}/NJ_OriginalData_2017_mat_G04", clear
gen Subject = "math"
gen GradeLevel = "G04"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_mat_G04", replace

import excel "${data}/NJ_OriginalData_2017_mat_G05", clear
gen Subject = "math"
gen GradeLevel = "G05"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_mat_G05", replace

import excel "${data}/NJ_OriginalData_2017_mat_G06", clear
gen Subject = "math"
gen GradeLevel = "G06"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_mat_G06", replace

import excel "${data}/NJ_OriginalData_2017_mat_G07", clear
gen Subject = "math"
gen GradeLevel = "G07"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_mat_G07", replace

import excel "${data}/NJ_OriginalData_2017_mat_G08", clear
gen Subject = "math"
gen GradeLevel = "G08"
drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "DISTRICT NAME"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "CURRENT - ELL"
drop if StudentSubGroup == "FORMER - ELL"
drop if StudentSubGroup == "STUDENTS WITH DISABILITIES"
drop if StudentSubGroup == "SE ACCOMMODATION"

replace SchName = DistName + " DISTRICT TOTAL" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentGroup = "Economic Status" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentGroup = "Economic Status" if StudentSubGroup == "NON-ECON. DISADVANTAGED"
replace StudentGroup = "RaceEth" if StudentGroup == "RACE/ETHNICITY"
replace StudentGroup = "Gender" if StudentGroup == "GENDER"
replace StudentGroup = "All Students" if StudentGroup == "TOTAL"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2017_mat_G08", replace

use "${data}/NJ_OriginalData_2017_mat", clear
append using "${data}/NJ_OriginalData_2017_mat_G04" "${data}/NJ_OriginalData_2017_mat_G05" "${data}/NJ_OriginalData_2017_mat_G06" "${data}/NJ_OriginalData_2017_mat_G07" "${data}/NJ_OriginalData_2017_mat_G08"
save "${data}/NJ_OriginalData_2017_mat", replace

//Combine Subjects and Clean
use "${data}/NJ_AssmtData_2017", clear
append using "${data}/NJ_OriginalData_2017_mat"

replace StudentGroup = "Subgroup" if StudentGroup == "SUBGROUP"
replace StudentSubGroup = "SE Accommodation" if StudentSubGroup == "SE ACCOMMODATION"
replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL STUDENTS"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "AMERICAN INDIAN"
replace StudentSubGroup = "Asian" if StudentSubGroup == "ASIAN"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "AFRICAN AMERICAN"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "NATIVE HAWAIIAN"
replace StudentSubGroup = "White" if StudentSubGroup == "WHITE"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "HISPANIC"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "OTHER" & StudentGroup == "RaceEth"
replace StudentSubGroup = "Male" if StudentSubGroup == "MALE"
replace StudentSubGroup = "Female" if StudentSubGroup == "FEMALE"
replace StudentSubGroup = "Students with Disabilities" if StudentSubGroup == "STUDENTS WITH DISABILITIES"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ENGLISH LANGUAGE LEARNERS"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECONOMICALLY DISADVANTAGED"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NON-ECON. DISADVANTAGED"

gen SchYear = "2016-17"
gen AssmtName = "PARCC"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == ""
replace DataLevel = "State" if StateAssignedDistID == ""
gen Lev1_count =.
gen Lev2_count =.
gen Lev3_count =.
gen Lev4_count =.
gen Lev5_count =.
gen ProficiencyCriteria = "Students in Levels 4 and 5 are proficient."
gen ProficientOrAbove_count =.

gen Meets_percent = Lev4_percent
gen Exceeds_percent = Lev5_percent
destring Meets_percent, replace force
destring Exceeds_percent, replace force
gen ProficientOrAbove_percent = Meets_percent + Exceeds_percent
drop Meets_percent Exceeds_percent

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force
destring Lev5_percent, replace force
destring ProficientOrAbove_percent, replace force
replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace Lev5_percent = Lev5_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring Lev5_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "*" if Lev1_percent == "."
replace Lev2_percent = "*" if Lev2_percent == "."
replace Lev3_percent = "*" if Lev3_percent == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev5_percent = "*" if Lev5_percent == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
gen ParticipationRate =.

replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "${data}/NJ_AssmtData_2017", replace

//Clean NCES Data
use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2016_School.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 8)
gen str StateAssignedSchID = substr(seasch, 8, 10)
save "${NCES}/Cleaned NCES Data/NCES_2017_School_NJ.dta", replace

use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2016_District.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 8)
save "${NCES}/Cleaned NCES Data/NCES_2017_District_NJ.dta", replace

//Merge Data
use "${data}/NJ_AssmtData_2017", clear
merge m:1 StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2017_District_NJ.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2017_School_NJ.dta", gen (merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

gen State = "New Jersey"
replace StateAbbrev = "NJ" if StateAbbrev == ""
replace StateFips = 34 if StateFips ==.

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen (DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${data}/NJ_AssmtData_2017", replace
export delimited "${data}/NJ_AssmtData_2017", replace
clear

//2017-2018
//English
import excel "${data}/NJ_OriginalData_2018_ela_G03", clear
gen Subject = "ela"
gen GradeLevel = "G03"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Disability Status" if StudentSubGroup == "Students With Disabilities"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_ela", replace

import excel "${data}/NJ_OriginalData_2018_ela_G04", clear
gen Subject = "ela"
gen GradeLevel = "G04"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_ela_G04", replace

import excel "${data}/NJ_OriginalData_2018_ela_G05", clear
gen Subject = "ela"
gen GradeLevel = "G05"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_ela_G05", replace

import excel "${data}/NJ_OriginalData_2018_ela_G06", clear
gen Subject = "ela"
gen GradeLevel = "G06"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_ela_G06", replace

import excel "${data}/NJ_OriginalData_2018_ela_G07", clear
gen Subject = "ela"
gen GradeLevel = "G07"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_ela_G07", replace

import excel "${data}/NJ_OriginalData_2018_ela_G08", clear
gen Subject = "ela"
gen GradeLevel = "G08"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_ela_G08", replace

use "${data}/NJ_OriginalData_2018_ela", clear
append using "${data}/NJ_OriginalData_2018_ela_G04" "${data}/NJ_OriginalData_2018_ela_G05" "${data}/NJ_OriginalData_2018_ela_G06" "${data}/NJ_OriginalData_2018_ela_G07" "${data}/NJ_OriginalData_2018_ela_G08"
save "${data}/NJ_AssmtData_2018", replace

//Math
import excel "${data}/NJ_OriginalData_2018_mat_G03", clear
gen Subject = "math"
gen GradeLevel = "G03"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_mat", replace

import excel "${data}/NJ_OriginalData_2018_mat_G04", clear
gen Subject = "math"
gen GradeLevel = "G04"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_mat_G04", replace

import excel "${data}/NJ_OriginalData_2018_mat_G05", clear
gen Subject = "math"
gen GradeLevel = "G05"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_mat_G05", replace

import excel "${data}/NJ_OriginalData_2018_mat_G06", clear
gen Subject = "math"
gen GradeLevel = "G06"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_mat_G06", replace

import excel "${data}/NJ_OriginalData_2018_mat_G07", clear
gen Subject = "math"
gen GradeLevel = "G07"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_mat_G07", replace

import excel "${data}/NJ_OriginalData_2018_mat_G08", clear
gen Subject = "math"
gen GradeLevel = "G08"

drop A B G J K
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename H StudentGroup
rename I StudentSubGroup
rename M AvgScaleScore
rename N Lev1_percent
rename O Lev2_percent
rename P Lev3_percent
rename Q Lev4_percent
rename R Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - Ell"
drop if StudentSubGroup == "Former - Ell"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "Se Accommodation"

replace SchName = DistName + " District Total" if SchName == "" & DistName != ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = L
destring L, replace force
replace L = -1000000 if L == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(L)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop L

save "${data}/NJ_OriginalData_2018_mat_G08", replace

use "${data}/NJ_OriginalData_2018_mat", clear
append using "${data}/NJ_OriginalData_2018_mat_G04" "${data}/NJ_OriginalData_2018_mat_G05" "${data}/NJ_OriginalData_2018_mat_G06" "${data}/NJ_OriginalData_2018_mat_G07" "${data}/NJ_OriginalData_2018_mat_G08"
save "${data}/NJ_OriginalData_2018_mat", replace

//Combine Subjects and Clean
use "${data}/NJ_AssmtData_2018", clear
append using "${data}/NJ_OriginalData_2018_mat"

replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Other" & StudentGroup == "RaceEth"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"

gen SchYear = "2017-18"
gen AssmtName = "PARCC"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == ""
replace DataLevel = "State" if StateAssignedDistID == ""
gen Lev1_count =.
gen Lev2_count =.
gen Lev3_count =.
gen Lev4_count =.
gen Lev5_count =.
gen ProficiencyCriteria = "Students in Levels 4 and 5 are proficient."
gen ProficientOrAbove_count =.

gen Meets_percent = Lev4_percent
gen Exceeds_percent = Lev5_percent
destring Meets_percent, replace force
destring Exceeds_percent, replace force
gen ProficientOrAbove_percent = Meets_percent + Exceeds_percent
drop Meets_percent Exceeds_percent

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force
destring Lev5_percent, replace force
destring ProficientOrAbove_percent, replace force
replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace Lev5_percent = Lev5_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring Lev5_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "*" if Lev1_percent == "."
replace Lev2_percent = "*" if Lev2_percent == "."
replace Lev3_percent = "*" if Lev3_percent == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev5_percent = "*" if Lev5_percent == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

gen ParticipationRate =.

drop S

replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "${data}/NJ_AssmtData_2018", replace

//Clean NCES Data
use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2017_School.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 8)
gen str StateAssignedSchID = substr(seasch, 8, 10)
save "${NCES}/Cleaned NCES Data/NCES_2018_School_NJ.dta", replace

use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2017_District.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 8)
save "${NCES}/Cleaned NCES Data/NCES_2018_District_NJ.dta", replace

//Merge Data
use "${data}/NJ_AssmtData_2018", clear
merge m:1 StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2018_District_NJ.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2018_School_NJ.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

gen State = "New Jersey"
replace StateAbbrev = "NJ" if StateAbbrev == ""
replace StateFips = 34 if StateFips ==.

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen (DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${data}/NJ_AssmtData_2018", replace
export delimited "${data}/NJ_AssmtData_2018", replace
clear

//2018-2019
//English
import excel "${data}/NJ_OriginalData_2019_ela_G03", clear
gen Subject = "ela"
gen GradeLevel = "G03"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_ela", replace

import excel "${data}/NJ_OriginalData_2019_ela_G04", clear
gen Subject = "ela"
gen GradeLevel = "G04"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_ela_G04", replace

import excel "${data}/NJ_OriginalData_2019_ela_G05", clear
gen Subject = "ela"
gen GradeLevel = "G05"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_ela_G05", replace

import excel "${data}/NJ_OriginalData_2019_ela_G06", clear
gen Subject = "ela"
gen GradeLevel = "G06"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_ela_G06", replace

import excel "${data}/NJ_OriginalData_2019_ela_G07", clear
gen Subject = "ela"
gen GradeLevel = "G07"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_ela_G07", replace

import excel "${data}/NJ_OriginalData_2019_ela_G08", clear
gen Subject = "ela"
gen GradeLevel = "G08"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_ela_G08", replace

use "${data}/NJ_OriginalData_2019_ela", clear
append using "${data}/NJ_OriginalData_2019_ela_G04" "${data}/NJ_OriginalData_2019_ela_G05" "${data}/NJ_OriginalData_2019_ela_G06" "${data}/NJ_OriginalData_2019_ela_G07" "${data}/NJ_OriginalData_2019_ela_G08"
save "${data}/NJ_AssmtData_2019", replace

//Math
import excel "${data}/NJ_OriginalData_2019_mat_G03", clear
gen Subject = "math"
gen GradeLevel = "G03"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_mat", replace

import excel "${data}/NJ_OriginalData_2019_mat_G04", clear
gen Subject = "math"
gen GradeLevel = "G04"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_mat_G04", replace

import excel "${data}/NJ_OriginalData_2019_mat_G05", clear
gen Subject = "math"
gen GradeLevel = "G05"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_mat_G05", replace

import excel "${data}/NJ_OriginalData_2019_mat_G06", clear
gen Subject = "math"
gen GradeLevel = "G06"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_mat_G06", replace

import excel "${data}/NJ_OriginalData_2019_mat_G07", clear
gen Subject = "math"
gen GradeLevel = "G07"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_mat_G07", replace

import excel "${data}/NJ_OriginalData_2019_mat_G08", clear
gen Subject = "math"
gen GradeLevel = "G08"

drop A B I J
rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_mat_G08", replace

use "${data}/NJ_OriginalData_2019_mat", clear
append using "${data}/NJ_OriginalData_2019_mat_G04" "${data}/NJ_OriginalData_2019_mat_G05" "${data}/NJ_OriginalData_2019_mat_G06" "${data}/NJ_OriginalData_2019_mat_G07" "${data}/NJ_OriginalData_2019_mat_G08"
save "${data}/NJ_OriginalData_2019_mat", replace

//Science
import excel "${data}/NJ_OriginalData_2019_sci_G05", clear
keep C D E F G H K L M N O P

gen Subject = "sci"
gen GradeLevel = "G05"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
gen Lev5_percent = ""

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if DistName != "" & SchName == ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_sci", replace

import excel "${data}/NJ_OriginalData_2019_sci_G08", clear
keep C D E F G H K L M N O P

gen Subject = "sci"
gen GradeLevel = "G08"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
gen Lev5_percent = ""

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if DistName != "" & SchName == ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2019_sci_G08", replace

use "${data}/NJ_OriginalData_2019_sci", clear
append using "${data}/NJ_OriginalData_2019_sci_G08"
save "${data}/NJ_OriginalData_2019_sci", replace

//Combine Subjects and Clean
use "${data}/NJ_AssmtData_2019", clear
append using "${data}/NJ_OriginalData_2019_mat" "${data}/NJ_OriginalData_2019_sci"

replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Other" & StudentGroup == "RaceEth"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"

gen SchYear = "2018-19"
gen AssmtName = "NJSLA"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == ""
replace DataLevel = "State" if StateAssignedDistID == ""
gen Lev1_count =.
gen Lev2_count =.
gen Lev3_count =.
gen Lev4_count =.
gen Lev5_count =.
gen ProficiencyCriteria = "Students in Levels 4 and 5 are proficient."
replace ProficiencyCriteria = "Students in Levels 3 and 4 are proficient." if Subject == "sci"
gen ProficientOrAbove_count =.

gen Three_percent = Lev3_percent
gen Four_percent = Lev4_percent
gen Five_percent = Lev5_percent
destring Three_percent, replace force
destring Four_percent, replace force
destring Five_percent, replace force
gen ProficientOrAbove_percent = Four_percent + Five_percent
replace ProficientOrAbove_percent = Three_percent + Four_percent if Subject == "sci"
drop Three_percent Four_percent Five_percent

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force
destring Lev5_percent, replace force
destring ProficientOrAbove_percent, replace force
replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace Lev5_percent = Lev5_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring Lev5_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "*" if Lev1_percent == "."
replace Lev2_percent = "*" if Lev2_percent == "."
replace Lev3_percent = "*" if Lev3_percent == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev5_percent = "*" if Lev5_percent == "."
replace Lev5_percent = "" if Subject == "sci"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
gen ParticipationRate =.

replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "${data}/NJ_AssmtData_2019", replace

//Clean NCES Data
use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2018_School.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 8)
gen str StateAssignedSchID = substr(seasch, 8, 10)
save "${NCES}/Cleaned NCES Data/NCES_2019_School_NJ.dta", replace

use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2018_District.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 8)
save "${NCES}/Cleaned NCES Data/NCES_2019_District_NJ.dta", replace

//Merge Data
use "${data}/NJ_AssmtData_2019", clear
merge m:1 StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2019_District_NJ.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2019_School_NJ.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name agency_charter_indicator dist_agency_charter_indicator

gen State = "New Jersey"
replace StateAbbrev = "NJ" if StateAbbrev == ""
replace StateFips = 34 if StateFips ==.

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen (DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${data}/NJ_AssmtData_2019", replace
export delimited "${data}/NJ_AssmtData_2019", replace
clear

//2021-2022
//English
import excel "${data}/NJ_OriginalData_2022_ela_G03", clear
keep C D E F G H K L M N O P Q

gen Subject = "ela"
gen GradeLevel = "G03"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_ela", replace

import excel "${data}/NJ_OriginalData_2022_ela_G04", clear

keep C D E F G H K L M N O P Q

gen Subject = "ela"
gen GradeLevel = "G04"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_ela_G04", replace

import excel "${data}/NJ_OriginalData_2022_ela_G05", clear
keep C D E F G H K L M N O P Q

gen Subject = "ela"
gen GradeLevel = "G05"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_ela_G05", replace

import excel "${data}/NJ_OriginalData_2022_ela_G06", clear
keep C D E F G H K L M N O P Q

gen Subject = "ela"
gen GradeLevel = "G06"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_ela_G06", replace

import excel "${data}/NJ_OriginalData_2022_ela_G07", clear
gen Subject = "ela"
gen GradeLevel = "G07"

keep C D E F G H K L M N O P Q

gen Subject = "ela"
gen GradeLevel = "G07"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_ela_G07", replace

import excel "${data}/NJ_OriginalData_2022_ela_G08", clear
keep C D E F G H K L M N O P Q

gen Subject = "ela"
gen GradeLevel = "G08"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_ela_G08", replace

use "${data}/NJ_OriginalData_2022_ela", clear
append using "${data}/NJ_OriginalData_2022_ela_G04" "${data}/NJ_OriginalData_2022_ela_G05" "${data}/NJ_OriginalData_2022_ela_G06" "${data}/NJ_OriginalData_2022_ela_G07" "${data}/NJ_OriginalData_2022_ela_G08"
save "${data}/NJ_AssmtData_2022", replace

//Math
import excel "${data}/NJ_OriginalData_2022_mat_G03", clear
keep C D E F G H K L M N O P Q

gen Subject = "math"
gen GradeLevel = "G03"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_mat", replace

import excel "${data}/NJ_OriginalData_2022_mat_G04", clear
keep C D E F G H K L M N O P Q

gen Subject = "math"
gen GradeLevel = "G04"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_mat_G04", replace

import excel "${data}/NJ_OriginalData_2022_mat_G05", clear
keep C D E F G H K L M N O P Q

gen Subject = "math"
gen GradeLevel = "G05"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_mat_G05", replace

import excel "${data}/NJ_OriginalData_2022_mat_G06", clear
keep C D E F G H K L M N O P Q

gen Subject = "math"
gen GradeLevel = "G06"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_mat_G06", replace

import excel "${data}/NJ_OriginalData_2022_mat_G07", clear
keep C D E F G H K L M N O P Q

gen Subject = "math"
gen GradeLevel = "G07"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_mat_G07", replace

import excel "${data}/NJ_OriginalData_2022_mat_G08", clear
keep C D E F G H K L M N O P Q

gen Subject = "math"
gen GradeLevel = "G08"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
rename Q Lev5_percent

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = DistName + " District Total" if SchName == "District Total"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_mat_G08", replace

use "${data}/NJ_OriginalData_2022_mat", clear
append using "${data}/NJ_OriginalData_2022_mat_G04" "${data}/NJ_OriginalData_2022_mat_G05" "${data}/NJ_OriginalData_2022_mat_G06" "${data}/NJ_OriginalData_2022_mat_G07" "${data}/NJ_OriginalData_2022_mat_G08"
save "${data}/NJ_OriginalData_2022_mat", replace

//Science
import excel "${data}/NJ_OriginalData_2022_sci_G05", clear
keep C D E F G H K L M N O P

gen Subject = "sci"
gen GradeLevel = "G05"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
gen Lev5_percent = ""

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = "District Total" if DistName != "" & SchName == ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_sci", replace

import excel "${data}/NJ_OriginalData_2022_sci_G08", clear
keep C D E F G H K L M N O P

gen Subject = "sci"
gen GradeLevel = "G08"

rename C StateAssignedDistID
rename D DistName
rename E StateAssignedSchID
rename F SchName
rename G StudentGroup
rename H StudentSubGroup
rename L AvgScaleScore
rename M Lev1_percent
rename N Lev2_percent
rename O Lev3_percent
rename P Lev4_percent
gen Lev5_percent = ""

drop if StateAssignedDistID == "DFG Not Designated"
drop if DistName == "District Name"
drop if AvgScaleScore == ""
drop if StudentSubGroup == "Current - ELL"
drop if StudentSubGroup == "Former - ELL"
drop if StudentSubGroup == "Students With Disabilities"
drop if StudentSubGroup == "SE Accommodation"

replace SchName = "District Total" if DistName != "" & SchName == ""

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learners"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentGroup = "All Students" if StudentGroup == "Total"

gen StudentSubGroup_TotalTested = K
destring K, replace force
replace K = -1000000 if K == .
bys SchName StudentGroup: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop K

save "${data}/NJ_OriginalData_2022_sci_G08", replace

use "${data}/NJ_OriginalData_2022_sci", clear
append using "${data}/NJ_OriginalData_2022_sci_G08"
save "${data}/NJ_OriginalData_2022_sci", replace

//Combine Subjects and Clean
use "${data}/NJ_AssmtData_2022", clear
append using "${data}/NJ_OriginalData_2022_mat" "${data}/NJ_OriginalData_2022_sci"

replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Other" & StudentGroup == "RaceEth"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"

gen SchYear = "2021-22"
gen AssmtName = "NJSLA"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == ""
replace DataLevel = "State" if StateAssignedDistID == ""
gen Lev1_count =.
gen Lev2_count =.
gen Lev3_count =.
gen Lev4_count =.
gen Lev5_count =.
gen ProficiencyCriteria = "Students in Levels 4 and 5 are proficient."
replace ProficiencyCriteria = "Students in Levels 3 and 4 are proficient." if Subject == "sci"
gen ProficientOrAbove_count =.

gen Three_percent = Lev3_percent
gen Four_percent = Lev4_percent
gen Five_percent = Lev5_percent
destring Three_percent, replace force
destring Four_percent, replace force
destring Five_percent, replace force
gen ProficientOrAbove_percent = Four_percent + Five_percent
replace ProficientOrAbove_percent = Three_percent + Four_percent if Subject == "sci"
drop Three_percent Four_percent Five_percent

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force
destring Lev5_percent, replace force
destring ProficientOrAbove_percent, replace force
replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100
replace Lev5_percent = Lev5_percent/100
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring Lev5_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "*" if Lev1_percent == "."
replace Lev2_percent = "*" if Lev2_percent == "."
replace Lev3_percent = "*" if Lev3_percent == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev5_percent = "*" if Lev5_percent == "."
replace Lev5_percent = "" if Subject == "sci"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

gen ParticipationRate =.

replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "${data}/NJ_AssmtData_2022", replace

//Clean NCES Data
use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_2021_School.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 10)
gen str StateAssignedSchID = substr(seasch, 8, 11)
save "${NCES}/Cleaned NCES Data/NCES_2022_School_NJ.dta", replace

use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_2021_District.dta", clear
drop if state_location != "NJ"
gen str StateAssignedDistID = substr(state_leaid, 6, 8)
save "${NCES}/Cleaned NCES Data/NCES_2022_District_NJ.dta", replace

//Merge Data
use "${data}/NJ_AssmtData_2022", clear
merge m:1 StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2022_District_NJ.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_2022_School_NJ.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchType
rename state_leaid State_leaid

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name

gen State = "New Jersey"
replace StateAbbrev = "NJ" if StateAbbrev == ""
replace StateFips = 34 if StateFips ==.

//Variable Types
decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen (SchType_s)
drop SchType
rename SchType_s SchType

decode DistType, gen (DistType_s)
drop DistType
rename DistType_s DistType

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType  Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${data}/NJ_AssmtData_2022", replace
export delimited "${data}/NJ_AssmtData_2022", replace
clear

log close
