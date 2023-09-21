clear
set more off

cd "/Users/maggie/Desktop/Indiana"

global raw "/Users/maggie/Desktop/Indiana/Original Data Files"
global output "/Users/maggie/Desktop/Indiana/Output"
global NCES "/Users/maggie/Desktop/Indiana/NCES/Cleaned"

//////	ORGANIZING AND APPENDING DATA


//// State

//ela
import excel "/${raw}/2022/IN_OriginalData_2022_all_state.xlsx", sheet("ELA") cellrange(A3:H9) clear

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "ela"

save "/${output}/StateELA2022", replace

//math
import excel "/${raw}/2022/IN_OriginalData_2022_all_state.xlsx", sheet("Math") cellrange(A3:H9) clear

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "math"

save "/${output}/StateMath2022", replace

//sci
import excel "/${raw}/2022/IN_OriginalData_2022_all_state.xlsx", sheet("Science") cellrange(A3:H5) clear

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "sci"

save "/${output}/StateSci2022", replace

//soc
import excel "/${raw}/2022/IN_OriginalData_2022_all_state.xlsx", sheet("Social Studies") cellrange(A3:H4) clear

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "soc"

save "/${output}/StateSoc2022", replace

// state disaggregate data (ela)
import excel "/${raw}/2022/IN_OriginalData_2022_all_state_disagg.xlsx", sheet("ELA") cellrange(A2:H16) clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent

drop if inlist(StudentSubGroup, "General Education", "Special Education")

gen Subject = "ela"

gen StudentGroup = "RaceEth"
replace StudentGroup = "EL Status" if StudentSubGroup == "Non-English Language Learner" | StudentSubGroup == "English Language Learner"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Free/Reduced price meals" | StudentSubGroup == "Paid meals"

bysort StudentGroup: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

gen GradeLevel = "G38"

save  "/${output}/StateDisagg2022ELA", replace

// state disaggregate data (math)
import excel "/${raw}/2022/IN_OriginalData_2022_all_state_disagg.xlsx", sheet("Math") cellrange(A2:H16) clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent

drop if inlist(StudentSubGroup, "General Education", "Special Education")

gen Subject = "math"

gen StudentGroup = "RaceEth"
replace StudentGroup = "EL Status" if StudentSubGroup == "Non-English Language Learner" | StudentSubGroup == "English Language Learner"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Free/Reduced price meals" | StudentSubGroup == "Paid meals"

bysort StudentGroup: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

gen GradeLevel = "G38"

save "/${output}/StateDisagg2022Math", replace

// state disaggregate data (sci)
import excel "/${raw}/2022/IN_OriginalData_2022_all_state_disagg.xlsx", sheet("Science") cellrange(A2:H16) clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent

drop if inlist(StudentSubGroup, "General Education", "Special Education")

gen Subject = "sci"

gen StudentGroup = "RaceEth"
replace StudentGroup = "EL Status" if StudentSubGroup == "Non-English Language Learner" | StudentSubGroup == "English Language Learner"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Free/Reduced price meals" | StudentSubGroup == "Paid meals"

bysort StudentGroup: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

gen GradeLevel = "G38"

save "/${output}/StateDisagg2022Sci", replace

// state disaggregate data (soc)
import excel "/${raw}/2022/IN_OriginalData_2022_all_state_disagg.xlsx", sheet("Social Studies") cellrange(A2:H16) clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent

drop if inlist(StudentSubGroup, "General Education", "Special Education")

gen Subject = "soc"

gen StudentGroup = "RaceEth"
replace StudentGroup = "EL Status" if StudentSubGroup == "Non-English Language Learner" | StudentSubGroup == "English Language Learner"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Free/Reduced price meals" | StudentSubGroup == "Paid meals"

bysort StudentGroup: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

gen GradeLevel = "G38"

save "/${output}/StateDisagg2022Soc", replace

//append all state-level files
use "/${output}/StateELA2022", replace
append using "/${output}/StateMath2022"
append using "/${output}/StateSci2022"
append using "/${output}/StateSoc2022"
append using "/${output}/StateDisagg2022ELA"
append using "/${output}/StateDisagg2022Math"
append using "/${output}/StateDisagg2022Sci"
append using "/${output}/StateDisagg2022Soc"

gen DataLevel = "State"

tostring Lev*, replace
tostring ProficientOrAbove_count, replace
tostring ProficientOrAbove_percent, replace force

save "/${output}/State2022", replace


//// District

//ela
import excel "/${raw}/2022/IN_OriginalData_2022_all_dist.xlsx", sheet("ELA") cellrange(A6:AY412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count38
rename AT Lev2_count38
rename AU Lev3_count38
rename AV Lev4_count38
rename AW ProficientOrAbove_count38
rename AX StudentGroup_TotalTested38
rename AY ProficientOrAbove_percent38

tostring Lev*, replace
tostring Proficient*, replace force

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "ela"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/DistELA2022", replace

//math
import excel "/${raw}/2022/IN_OriginalData_2022_all_dist.xlsx", sheet("Math") cellrange(A6:AY412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count38
rename AT Lev2_count38
rename AU Lev3_count38
rename AV Lev4_count38
rename AW ProficientOrAbove_count38
rename AX StudentGroup_TotalTested38
rename AY ProficientOrAbove_percent38

tostring Lev*, replace
tostring Proficient*, replace force

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "math"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/DistMath2022", replace

//sci
import excel "/${raw}/2022/IN_OriginalData_2022_all_dist.xlsx", sheet("Science") cellrange(A6:W386) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count4
rename D Lev2_count4
rename E Lev3_count4
rename F Lev4_count4
rename G ProficientOrAbove_count4
rename H StudentGroup_TotalTested4
rename I ProficientOrAbove_percent4

rename J Lev1_count6
rename K Lev2_count6
rename L Lev3_count6
rename M Lev4_count6
rename N ProficientOrAbove_count6
rename O StudentGroup_TotalTested6
rename P ProficientOrAbove_percent6

rename Q Lev1_count38
rename R Lev2_count38
rename S Lev3_count38
rename T Lev4_count38
rename U ProficientOrAbove_count38
rename V StudentGroup_TotalTested38
rename W ProficientOrAbove_percent38

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "sci"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/DistSci2022.dta", replace

//soc
import excel "/${raw}/2022/IN_OriginalData_2022_all_dist.xlsx", sheet("Social Studies") cellrange(A6:I377) clear


rename A StateAssignedDistID
rename B DistName

rename C Lev1_count5
rename D Lev2_count5
rename E Lev3_count5
rename F Lev4_count5
rename G ProficientOrAbove_count5
rename H StudentGroup_TotalTested5
rename I ProficientOrAbove_percent5

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "soc"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/DistSoc2022.dta", replace

// dist disaggregate data

// ela race

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("ELA Ethnicity") cellrange(A6:AY412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggRaceEth2022_ELA.dta", replace

// math race

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("Math Ethnicity") cellrange(A6:AY412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggRaceEth2022_Math.dta", replace

// sci race

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("Science Ethnicity") cellrange(A6:AY386) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggRaceEth2022_sci.dta", replace

// soc race

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("Social Studies Ethnicity") cellrange(A6:AY377) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggRaceEth2022_soc.dta", replace

// gender


// math gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("Math Gender") cellrange(A6:P412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup =  "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggGender2022_Math.dta", replace

// ela gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("ELA Gender") cellrange(A6:P412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup =  "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggGender2022_ELA.dta", replace

// sci gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("Science Gender") cellrange(A6:P386) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup =  "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggGender2022_sci.dta", replace

// soc gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_race_gender.xlsx", sheet("Social Studies Gender") cellrange(A6:P377) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup =  "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggGender2022_soc.dta", replace

//	english learners

// ela el status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("ELA English Learners") cellrange(A6:P412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggELStatus2022_ELA.dta", replace

// math el status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("Math English Learners") cellrange(A6:P412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggELStatus2022_Math.dta", replace

// science el status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("Science English Learners") cellrange(A6:P386) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggELStatus2022_sci.dta", replace

// soc el status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("Social Studies English Learners") cellrange(A6:P377) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggELStatus2022_soc", replace

// ela econ status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("ELA Socio Economic") cellrange(A6:P412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "Economic Status"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggEconStatus2022_ELA.dta", replace

// math econ status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("Math Socio Economic") cellrange(A6:P412) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "Economic Status"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggEconStatus2022_Math.dta", replace

// science econ status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("Science Socio Economic") cellrange(A6:P386) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "Economic Status"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggEconStatus2022_sci.dta", replace

// soc econ status

import excel "/${raw}/2022/IN_OriginalData_2022_all_dist_disagg.xlsx", sheet("Social Studies Socio Economic") cellrange(A6:P377) clear

rename A StateAssignedDistID
rename B DistName

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedDistID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "Economic Status"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedDistID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/DistDisaggEconStatus2022_soc.dta", replace

// append at district level data

use "/${output}/DistELA2022.dta"
append using "/${output}/DistMath2022.dta"
append using "/${output}/DistSci2022.dta"
append using "/${output}/DistSoc2022.dta"
append using "/${output}/DistDisaggEconStatus2022_ELA"
append using "/${output}/DistDisaggELStatus2022_ELA"
append using "/${output}/DistDisaggRaceEth2022_ELA"
append using "/${output}/DistDisaggGender2022_ELA"
append using "/${output}/DistDisaggEconStatus2022_Math"
append using "/${output}/DistDisaggELStatus2022_Math"
append using "/${output}/DistDisaggRaceEth2022_Math"
append using "/${output}/DistDisaggGender2022_Math"
append using "/${output}/DistDisaggEconStatus2022_sci"
append using "/${output}/DistDisaggELStatus2022_sci"
append using "/${output}/DistDisaggRaceEth2022_sci"
append using "/${output}/DistDisaggGender2022_sci"
append using "/${output}/DistDisaggEconStatus2022_soc"
append using "/${output}/DistDisaggELStatus2022_soc"
append using "/${output}/DistDisaggRaceEth2022_soc"
append using "/${output}/DistDisaggGender2022_soc"

gen DataLevel = "District"

save "/${output}/Dist2022", replace

** continue here **

///////// school level data

//ela
import excel "/${raw}/2022/IN_OriginalData_2022_all_sch.xlsx", sheet("ELA") cellrange(A6:BA1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count38
rename AV Lev2_count38
rename AW Lev3_count38
rename AX Lev4_count38
rename AY ProficientOrAbove_count38
rename AZ StudentGroup_TotalTested38
rename BA ProficientOrAbove_percent38

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedSchID) j(GradeLevel) string

gen Subject="ela"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/SchELA2022", replace

//math
import excel "/${raw}/2022/IN_OriginalData_2022_all_sch.xlsx", sheet("Math") cellrange(A6:BA1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count38
rename AV Lev2_count38
rename AW Lev3_count38
rename AX Lev4_count38
rename AY ProficientOrAbove_count38
rename AZ StudentGroup_TotalTested38
rename BA ProficientOrAbove_percent38

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedSchID) j(GradeLevel) string

gen Subject = "math"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/SchMath2022", replace

//sci
import excel "/${raw}/2022/IN_OriginalData_2022_all_sch.xlsx", sheet("Science") cellrange(A6:Y1515) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count4
rename F Lev2_count4
rename G Lev3_count4
rename H Lev4_count4
rename I ProficientOrAbove_count4
rename J StudentGroup_TotalTested4
rename K ProficientOrAbove_percent4

rename L Lev1_count6
rename M Lev2_count6
rename N Lev3_count6
rename O Lev4_count6
rename P ProficientOrAbove_count6
rename Q StudentGroup_TotalTested6
rename R ProficientOrAbove_percent6

rename S Lev1_count38
rename T Lev2_count38
rename U Lev3_count38
rename V Lev4_count38
rename W ProficientOrAbove_count38
rename X StudentGroup_TotalTested38
rename Y ProficientOrAbove_percent38

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedSchID) j(GradeLevel) string

gen Subject = "sci"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/SchSci2022", replace

//soc
import excel "/${raw}/2022/IN_OriginalData_2022_all_sch.xlsx", sheet("Social Studies") cellrange(A6:K1123) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count5
rename F Lev2_count5
rename G Lev3_count5
rename H Lev4_count5
rename I ProficientOrAbove_count5
rename J StudentGroup_TotalTested5
rename K ProficientOrAbove_percent5

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(StateAssignedSchID) j(GradeLevel) string

gen Subject = "soc"

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${output}/SchSoc2022", replace

/////// disaggregate school files

// ela race

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("ELA Ethnicity") cellrange(A6:BA1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentSubGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentSubGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentSubGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentSubGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentSubGroup_TotalTested9
rename BA ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggRaceEth2022_ELA.dta", replace

// math race

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("Math Ethnicity") cellrange(A6:BA1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentSubGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentSubGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentSubGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentSubGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentSubGroup_TotalTested9
rename BA ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggRaceEth2022_Math.dta", replace

// sci race

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("Science Ethnicity") cellrange(A6:BA1515) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentSubGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentSubGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentSubGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentSubGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentSubGroup_TotalTested9
rename BA ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggRaceEth2022_sci.dta", replace

// soc race

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("Social Studies Ethnicity") cellrange(A6:BA1123) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentSubGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentSubGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentSubGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentSubGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentSubGroup_TotalTested9
rename BA ProficientOrAbove_percent9

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "3"
replace StudentSubGroup = "Asian" if StudentSubGroup == "4"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "5"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "6"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "7"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "8"
replace StudentSubGroup = "White" if StudentSubGroup == "9"

gen StudentGroup = "RaceEth"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggRaceEth2022_soc.dta", replace

// gender

// ela gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("ELA Gender") cellrange(A6:R1708) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup = "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggGender2022_ELA.dta", replace

// math gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("Math Gender") cellrange(A6:R1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup = "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggGender2022_Math.dta", replace

// sci gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("Science Gender") cellrange(A6:R1515) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup = "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggGender2022_sci.dta", replace

// soc gender

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_race_gender.xlsx", sheet("Social Studies Gender") cellrange(A6:R1123) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"
tostring StudentSubGroup, replace

replace StudentSubGroup = "Female" if StudentSubGroup == "3"
replace StudentSubGroup = "Male" if StudentSubGroup == "4"

gen StudentGroup = "Gender"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggGender2022_soc.dta", replace

// ela ELStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("ELA English Learners") cellrange(A6:R1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggELStatus2022_ELA.dta", replace

// math ELStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("Math English Learners") cellrange(A6:R1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggELStatus2022_Math.dta", replace

// sci ELStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("Science English Learners") cellrange(A6:R1515) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggELStatus2022_sci.dta", replace

// soc ELStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("Social Studies English Learners") cellrange(A6:R1123) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "3"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggELStatus2022_soc.dta", replace

// ela EconStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("ELA Socio Economic") cellrange(A6:R1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "ela"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggEconStatus2022_ELA.dta", replace

// math EconStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("Math Socio Economic") cellrange(A6:R1707) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "math"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggEconStatus2022_Math.dta", replace

// sci EconStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("Science Socio Economic") cellrange(A6:R1515) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "sci"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggEconStatus2022_sci.dta", replace

// soc EconStatus

import excel "/${raw}/2022/IN_OriginalData_2022_all_sch_disagg.xlsx", sheet("Social Studies Socio Economic") cellrange(A6:R1123) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentSubGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentSubGroup_TotalTested4
rename R ProficientOrAbove_percent4

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(StateAssignedSchID) j(StudentSubGroup) string

gen GradeLevel = "G38"

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "3"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "4"

gen StudentGroup = "EL Status"
gen Subject = "soc"

drop if Lev1_count == ""

bysort StateAssignedSchID: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

save "/${output}/SchDisaggEconStatus2022_soc.dta", replace

//append state level data
use "/${output}/SchELA2022.dta", clear
append using "/${output}/SchMath2022.dta"
append using "/${output}/SchSci2022.dta"
append using "/${output}/SchSoc2022.dta"
append using "/${output}/SchDisaggEconStatus2022_ELA.dta"
append using "/${output}/SchDisaggELStatus2022_ELA.dta"
append using "/${output}/SchDisaggRaceEth2022_ELA.dta"
append using "/${output}/SchDisaggGender2022_ELA.dta"
append using "/${output}/SchDisaggEconStatus2022_Math.dta"
append using "/${output}/SchDisaggELStatus2022_Math.dta"
append using "/${output}/SchDisaggRaceEth2022_Math.dta"
append using "/${output}/SchDisaggGender2022_Math.dta"
append using "/${output}/SchDisaggEconStatus2022_sci.dta"
append using "/${output}/SchDisaggELStatus2022_sci.dta"
append using "/${output}/SchDisaggRaceEth2022_sci.dta"
append using "/${output}/SchDisaggGender2022_sci.dta"
append using "/${output}/SchDisaggEconStatus2022_soc.dta"
append using "/${output}/SchDisaggELStatus2022_soc.dta"
append using "/${output}/SchDisaggRaceEth2022_soc.dta"
append using "/${output}/SchDisaggGender2022_soc.dta"

gen DataLevel = "School"

save "/${output}/School2022", replace

//append all data
append using "/${output}/Dist2022.dta"
append using "/${output}/State2022.dta"

save "/${output}/IN_2022_appended.dta", replace

////	MERGE NCES

gen State_leaid = "IN-" + StateAssignedDistID

merge m:1 State_leaid using "/${NCES}/NCES_2021_District.dta"

tab DistName StateAssignedDistID if _merge == 1 & DataLevel != "State"

drop if StateAssignedDistID == "9200"
drop if StateAssignedDistID == "9205"
drop if StateAssignedDistID == "9210"
drop if StateAssignedDistID == "9215"
drop if StateAssignedDistID == "9220"
drop if StateAssignedDistID == "9230"
drop if StateAssignedDistID == "9240"

drop if _merge==2
drop _merge

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID

merge m:1 seasch using "/${NCES}/NCES_2021_School.dta"

tab SchName if _merge == 1 & DataLevel == "School"

drop if _merge==2
drop _merge

/////	FINISH CLEANING

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

replace seasch = "" if DataLevel != 3
replace State_leaid = "" if DataLevel == 1

gen SchYear = "2022-23"

gen AssmtName = "ILEARN"
gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

replace GradeLevel = "G38" if inlist(GradeLevel,"38","Grand Total","All Students")
replace GradeLevel = subinstr(GradeLevel,"Grade ","",.)
replace GradeLevel = "G0" + GradeLevel if GradeLevel != "G38"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced price meals"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learner"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Paid meals"

drop if Lev1_count == ""

gen Lev5_count = ""
gen Lev5_percent = ""

local level 1 2 3 4

foreach a of local level{
	gen Lev`a'_percent = "--"
	replace Lev`a'_count = "*" if Lev`a'_count == "***"
}

replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "***"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "***"

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3 and 4"

replace State = 18
replace StateAbbrev = "IN"
replace StateFips = 18

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IN_AssmtData_2022.dta", replace

export delimited using "${output}/csv/IN_AssmtData_2022.csv", replace
