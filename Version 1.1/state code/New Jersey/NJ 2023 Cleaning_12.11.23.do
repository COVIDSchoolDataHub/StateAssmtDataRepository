clear all
set more off

cd "/Users/miramehta/Documents/"
global data "/Users/miramehta/Documents/NJ State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//2022-2023//
//English

//Grade 3
import excel "${data}/NJ_OriginalData_2023_ela_G03", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_ela.dta", replace

//Grade 4
import excel "${data}/NJ_OriginalData_2023_ela_G04", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_ela_G04.dta", replace

//Grade 5
import excel "${data}/NJ_OriginalData_2023_ela_G05", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_ela_G05.dta", replace

//Grade 6
import excel "${data}/NJ_OriginalData_2023_ela_G06", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_ela_G06.dta", replace

//Grade 7
import excel "${data}/NJ_OriginalData_2023_ela_G07", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_ela_G07.dta", replace

//Grade 8
import excel "${data}/NJ_OriginalData_2023_ela_G08", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_ela_G08.dta", replace

use "${data}/NJ_OriginalData_2023_ela", clear
append using "${data}/NJ_OriginalData_2023_ela_G04" "${data}/NJ_OriginalData_2023_ela_G05" "${data}/NJ_OriginalData_2023_ela_G06" "${data}/NJ_OriginalData_2023_ela_G07" "${data}/NJ_OriginalData_2023_ela_G08"
save "${data}/NJ_AssmtData_2023", replace

//Math
import excel "${data}/NJ_OriginalData_2023_mat_G03", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_mat", replace

import excel "${data}/NJ_OriginalData_2023_mat_G04", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_mat_G04", replace

import excel "${data}/NJ_OriginalData_2023_mat_G05", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_mat_G05", replace

import excel "${data}/NJ_OriginalData_2023_mat_G06", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_mat_G06", replace

import excel "${data}/NJ_OriginalData_2023_mat_G07", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_mat_G07", replace

import excel "${data}/NJ_OriginalData_2023_mat_G08", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_mat_G08", replace

use "${data}/NJ_OriginalData_2023_mat", clear
append using "${data}/NJ_OriginalData_2023_mat_G04" "${data}/NJ_OriginalData_2023_mat_G05" "${data}/NJ_OriginalData_2023_mat_G06" "${data}/NJ_OriginalData_2023_mat_G07" "${data}/NJ_OriginalData_2023_mat_G08"
save "${data}/NJ_OriginalData_2023_mat", replace

//Science
import excel "${data}/NJ_OriginalData_2023_sci_G05", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_sci", replace

import excel "${data}/NJ_OriginalData_2023_sci_G08", clear
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
bys SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

save "${data}/NJ_OriginalData_2023_sci_G08", replace

use "${data}/NJ_OriginalData_2023_sci", clear
append using "${data}/NJ_OriginalData_2023_sci_G08"
save "${data}/NJ_OriginalData_2023_sci", replace

//Combine Subjects and Clean
use "${data}/NJ_AssmtData_2023", clear
append using "${data}/NJ_OriginalData_2023_mat" "${data}/NJ_OriginalData_2023_sci"

replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Other" if StudentSubGroup == "Other" & StudentGroup == "RaceEth"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentSubGroup = "Other" if StudentSubGroup == "Non-Binary/Undesignated"

gen SchYear = "2022-23"
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
gen ProficiencyCriteria = "Students in Levels 4 and 5 are proficient."
replace ProficiencyCriteria = "Students in Levels 3 and 4 are proficient." if Subject == "sci"

gen Three_percent = Lev3_percent
gen Four_percent = Lev4_percent
gen Five_percent = Lev5_percent
destring Three_percent, replace force
destring Four_percent, replace force
destring Five_percent, replace force
gen ProficientOrAbove_percent = Four_percent + Five_percent
replace ProficientOrAbove_percent = Three_percent + Four_percent if Subject == "sci"
drop Three_percent Four_percent Five_percent

forvalues n = 1/5 {
	destring Lev`n'_percent, replace force
	replace Lev`n'_percent = Lev`n'_percent/100
	gen Lev`n'_count = Lev`n'_percent * K
	replace Lev`n'_count = round(Lev`n'_count)
	tostring Lev`n'_count, replace
	tostring Lev`n'_percent, replace format("%10.0g") force
	replace Lev`n'_percent = "*" if Lev`n'_percent == "."
	replace Lev`n'_count = "*" if Lev`n'_percent == "*"
	replace Lev`n'_count = "*" if StudentSubGroup_TotalTested == "*"
}

replace Lev5_percent = "" if Subject == "sci"
replace Lev5_count = "" if Subject == "sci"

destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
gen ProficientOrAbove_count = ProficientOrAbove_percent * K
replace ProficientOrAbove_count = round(ProficientOrAbove_count)
tostring ProficientOrAbove_count, replace
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*"
replace ProficientOrAbove_count = "*" if StudentSubGroup_TotalTested == "*"

gen ParticipationRate =.

replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedSchID = "" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"

save "${data}/NJ_AssmtData_2023", replace

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
use "${data}/NJ_AssmtData_2023", clear
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

drop state_name year _merge merge2 district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type district_agency_type_num school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch lea_name K

gen State = "New Jersey"
replace StateAbbrev = "NJ" if StateAbbrev == ""
replace StateFips = 34 if StateFips ==.

//Unmerged Schools
replace NCESSchoolID = "341629003214" if SchName == "Cadwalader Elementary School"
replace seasch = "215210-160" if SchName == "Cadwalader Elementary School"
replace SchLevel = 1 if SchName == "Cadwalader Elementary School"
replace SchType = 1 if SchName == "Cadwalader Elementary School"
replace SchVirtual = -1 if SchName == "Cadwalader Elementary School"

replace NCESSchoolID = "340282006146" if SchName == "Carteret Junior High School"
replace seasch = "230750-300" if SchName == "Carteret Junior High School"
replace SchLevel = 2 if SchName == "Carteret Junior High School"
replace SchType = 1 if SchName == "Carteret Junior High School"
replace SchVirtual = -1 if SchName == "Carteret Junior High School"

replace NCESSchoolID = "341629006142" if SchName == "Dr. Martin Luther King Middle School"
replace seasch = "215210-305" if SchName == "Dr. Martin Luther King Middle School"
replace SchLevel = 2 if SchName == "Dr. Martin Luther King Middle School"
replace SchType = 1 if SchName == "Dr. Martin Luther King Middle School"
replace SchVirtual = -1 if SchName == "Dr. Martin Luther King Middle School"

replace NCESSchoolID = "341254006148" if SchName == "Ellen Ochoa School Number 22"
replace seasch = "313970-305" if SchName == "Ellen Ochoa School Number 22"
replace SchLevel = 1 if SchName == "Ellen Ochoa School Number 22"
replace SchType = 1 if SchName == "Ellen Ochoa School Number 22"
replace SchVirtual = -1 if SchName == "Ellen Ochoa School Number 22"

replace NCESSchoolID = "340729006152" if SchName == "Hillside Innovation Academy"
replace seasch = "392190-300" if SchName == "Hillside Innovation Academy"
replace SchLevel = 2 if SchName == "Hillside Innovation Academy"
replace SchType = 1 if SchName == "Hillside Innovation Academy"
replace SchVirtual = -1 if SchName == "Hillside Innovation Academy"

replace NCESSchoolID = "341629006144" if SchName == "Holland Middle School"
replace seasch = "215210-307" if SchName == "Holland Middle School"
replace SchLevel = 2 if SchName == "Holland Middle School"
replace SchType = 1 if SchName == "Holland Middle School"
replace SchVirtual = -1 if SchName == "Holland Middle School"

replace NCESSchoolID = "341134006138" if SchName == "Ironbound Academy Elementary School"
replace seasch = "133570-322" if SchName == "Ironbound Academy Elementary School"
replace SchLevel = 1 if SchName == "Ironbound Academy Elementary School"
replace SchType = 1 if SchName == "Ironbound Academy Elementary School"
replace SchVirtual = -1 if SchName == "Ironbound Academy Elementary School"

replace NCESSchoolID = "341629006145" if SchName == "Jefferson Elementary" & DistName == "Trenton Public School District"
replace seasch = "215210-308" if SchName == "Jefferson Elementary" & DistName == "Trenton Public School District"
replace SchLevel = 1 if SchName == "Jefferson Elementary" & DistName == "Trenton Public School District"
replace SchType = 1 if SchName == "Jefferson Elementary" & DistName == "Trenton Public School District"
replace SchVirtual = -1 if SchName == "Jefferson Elementary" & DistName == "Trenton Public School District"

replace NCESSchoolID = "341629006141" if SchName == "Joyce Kilmer Elementary School"
replace seasch = "215210-304" if SchName == "Joyce Kilmer Elementary School"
replace SchLevel = 1 if SchName == "Joyce Kilmer Elementary School"
replace SchType = 1 if SchName == "Joyce Kilmer Elementary School"
replace SchVirtual = -1 if SchName == "Joyce Kilmer Elementary School"

replace NCESSchoolID = "340429006136" if SchName == "Lincoln School" & DistName == "East Rutherford School District"
replace seasch = "031230-300" if SchName == "Lincoln School" & DistName == "East Rutherford School District"
replace SchLevel = 1 if SchName == "Lincoln School" & DistName == "East Rutherford School District"
replace SchType = 1 if SchName == "Lincoln School" & DistName == "East Rutherford School District"
replace SchVirtual = -1 if SchName == "Lincoln School" & DistName == "East Rutherford School District"	

replace NCESSchoolID = "341629006140" if SchName == "Luis Munoz-Rivera Elementary School"
replace seasch = "215210-303" if SchName == "Luis Munoz-Rivera Elementary School"
replace SchLevel = 1 if SchName == "Luis Munoz-Rivera Elementary School"
replace SchType = 1 if SchName == "Luis Munoz-Rivera Elementary School"
replace SchVirtual = -1 if SchName == "Luis Munoz-Rivera Elementary School"

replace NCESSchoolID = "341254006150" if SchName == "Mahatma Gandhi School Number 25"
replace seasch = "313970-307" if SchName == "Mahatma Gandhi School Number 25"
replace SchLevel = 1 if SchName == "Mahatma Gandhi School Number 25"
replace SchType = 1 if SchName == "Mahatma Gandhi School Number 25"
replace SchVirtual = -1 if SchName == "Mahatma Gandhi School Number 25"

replace NCESSchoolID = "341254006149" if SchName == "Muhammad Ali School Number 23"
replace seasch = "313970-306" if SchName == "Muhammad Ali School Number 23"
replace SchLevel = 2 if SchName == "Muhammad Ali School Number 23"
replace SchType = 1 if SchName == "Muhammad Ali School Number 23"
replace SchVirtual = -1 if SchName == "Muhammad Ali School Number 23"

replace NCESSchoolID = "341629003206" if SchName == "Paul S. Robeson Elementary School"
replace seasch = "215210-080" if SchName == "Paul S. Robeson Elementary School"
replace SchLevel = 1 if SchName == "Paul S. Robeson Elementary School"
replace SchType = 1 if SchName == "Paul S. Robeson Elementary School"
replace SchVirtual = -1 if SchName == "Paul S. Robeson Elementary School"

replace NCESSchoolID = "341287001638" if SchName == "Roosevelt Science Technology Engineering And Mathematics (St"
replace seasch = "074060-180" if SchName == "Roosevelt Science Technology Engineering And Mathematics (St"
replace SchLevel = 1 if SchName == "Roosevelt Science Technology Engineering And Mathematics (St"
replace SchType = 1 if SchName == "Roosevelt Science Technology Engineering And Mathematics (St"
replace SchVirtual = -1 if SchName == "Roosevelt Science Technology Engineering And Mathematics (St"

replace NCESSchoolID = "341629006143" if SchName == "Stokes Elementary School"
replace seasch = "215210-306" if SchName == "Stokes Elementary School"
replace SchLevel = 1 if SchName == "Stokes Elementary School"
replace SchType = 1 if SchName == "Stokes Elementary School"
replace SchVirtual = -1 if SchName == "Stokes Elementary School"

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

save "${data}/NJ_AssmtData_2023", replace
export delimited "${data}/NJ_AssmtData_2023", replace
clear
