clear
set more off

cd "/Users/maggie/Desktop/Indiana"

global raw "/Users/maggie/Desktop/Indiana/Original Data Files"
global output "/Users/maggie/Desktop/Indiana/Output"
global NCES "/Users/maggie/Desktop/Indiana/NCES/Cleaned"

//////	ORGANIZING AND APPENDING DATA


//// Create state level data

//ela
import excel "/${raw}/2018/IN_OriginalData_2018_all_state.xlsx", sheet("ELA") cellrange(A3:D9) clear

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "ela"

save "/${raw}/2018/StateELA2018", replace

//math
import excel "/${raw}/2018/IN_OriginalData_2018_all_state.xlsx", sheet("Math") cellrange(A3:D9) clear

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "math"

save "/${raw}/2018/StateMath2018", replace

//sci
import excel "/${raw}/2018/IN_OriginalData_2018_all_state.xlsx", sheet("Science") cellrange(A3:D5) clear

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "sci"

save "/${raw}/2018/StateSci2018", replace

//soc
import excel "/${raw}/2018/IN_OriginalData_2018_all_state.xlsx", sheet("Social Studies") cellrange(A3:D5) clear

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen Subject = "soc"

save "/${raw}/2018/StateSoc2018", replace

// state disaggregate data (math and ela)
import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_state_disagg.xlsx", sheet("Grades 03-08") cellrange(A2:G16) clear

rename A StudentSubGroup
rename B ProficientOrAbove_countela
rename C StudentSubGroup_TotalTestedela
rename D ProficientOrAbove_percentela
rename E ProficientOrAbove_countmath
rename F StudentSubGroup_TotalTestedmath
rename G ProficientOrAbove_percentmath

drop if inlist(StudentSubGroup, "General Education", "Special Education")

reshape long ProficientOrAbove_count StudentSubGroup_TotalTested ProficientOrAbove_percent, i(StudentSubGroup) j (Subject) string

gen StudentGroup = "RaceEth"
replace StudentGroup = "EL Status" if StudentSubGroup == "Non-English Language Learner" | StudentSubGroup == "English Language Learner"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Free/Reduced price meals" | StudentSubGroup == "Paid meals"

bysort Subject StudentGroup: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

gen GradeLevel = "G38"

save "/${raw}/2018/StateDisagg2018", replace

//append all state-level files
use "/${raw}/2018/StateELA2018", replace
append using "/${raw}/2018/StateMath2018"
append using "/${raw}/2018/StateSci2018"
append using "/${raw}/2018/StateSoc2018"
append using "/${raw}/2018/StateDisagg2018"

gen DataLevel = "State"

tostring Proficient*, replace force
tostring Student*, replace force

save "/${raw}/2018/State2018", replace

//// Create district level data

//math and ela
import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_dist.xlsx", sheet("Spring 2018") cellrange(A3:BM376) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela3
rename D StudentGroup_TotalTestedela3
rename E ProficientOrAbove_percentela3

rename F ProficientOrAbove_countmath3
rename G StudentGroup_TotalTestedmath3
rename H ProficientOrAbove_percentmath3

drop I J K

rename L ProficientOrAbove_countela4
rename M StudentGroup_TotalTestedela4
rename N ProficientOrAbove_percentela4

rename O ProficientOrAbove_countmath4
rename P StudentGroup_TotalTestedmath4
rename Q ProficientOrAbove_percentmath4

drop R S T

rename U ProficientOrAbove_countela5
rename V StudentGroup_TotalTestedela5
rename W ProficientOrAbove_percentela5

rename X ProficientOrAbove_countmath5
rename Y StudentGroup_TotalTestedmath5
rename Z ProficientOrAbove_percentmath5

drop AA AB AC

rename AD ProficientOrAbove_countela6
rename AE StudentGroup_TotalTestedela6
rename AF ProficientOrAbove_percentela6

rename AG ProficientOrAbove_countmath6
rename AH StudentGroup_TotalTestedmath6
rename AI ProficientOrAbove_percentmath6

drop AJ AK AL

rename AM ProficientOrAbove_countela7
rename AN StudentGroup_TotalTestedela7
rename AO ProficientOrAbove_percentela7

rename AP ProficientOrAbove_countmath7
rename AQ StudentGroup_TotalTestedmath7
rename AR ProficientOrAbove_percentmath7

drop AS AT AU

rename AV ProficientOrAbove_countela8
rename AW StudentGroup_TotalTestedela8
rename AX ProficientOrAbove_percentela8

rename AY ProficientOrAbove_countmath8
rename AZ StudentGroup_TotalTestedmath8
rename BA ProficientOrAbove_percentmath8

drop BB BC BD

rename BE ProficientOrAbove_countela38
rename BF StudentGroup_TotalTestedela38
rename BG ProficientOrAbove_percentela38

rename BH ProficientOrAbove_countmath38
rename BI StudentGroup_TotalTestedmath38
rename BJ ProficientOrAbove_percentmath38

drop BK BL BM

tostring Proficient* StudentGroup_TotalTested*, replace force

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(GradeLevel) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedDistID GradeLevel) j(Subject) string

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${raw}/2018/DistMathELA2018", replace


//science
import excel "/${raw}/2018/IN_OriginalData_2018_sci_soc.xlsx", sheet("2018_Science_Corp") cellrange(A3:K365) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_count4
rename D StudentGroup_TotalTested4
rename E ProficientOrAbove_percent4

rename F ProficientOrAbove_count6
rename G StudentGroup_TotalTested6
rename H ProficientOrAbove_percent6

rename I ProficientOrAbove_count38
rename J StudentGroup_TotalTested38
rename K ProficientOrAbove_percent38

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "sci"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

save "/${raw}/2018/DistSci2018", replace


// district social studies
import excel "/${raw}/2018/IN_OriginalData_2018_sci_soc.xlsx", sheet("2018 Social_Studies_Corp") cellrange(A3:K373) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_count5
rename D StudentGroup_TotalTested5
rename E ProficientOrAbove_percent5

rename F ProficientOrAbove_count7
rename G StudentGroup_TotalTested7
rename H ProficientOrAbove_percent7

rename I ProficientOrAbove_count38
rename J StudentGroup_TotalTested38
rename K ProficientOrAbove_percent38

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "soc"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

save "/${raw}/2018/DistSoc2018", replace


// dist disaggregate math and ela (race/ethnicity)
import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_dist_disagg.xlsx", sheet("Ethnicity") cellrange (A3:BM376) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela1
rename D StudentGroup_TotalTestedela1
rename E ProficientOrAbove_percentela1

rename F ProficientOrAbove_countmath1
rename G StudentGroup_TotalTestedmath1
rename H ProficientOrAbove_percentmath1

drop I J K

rename L ProficientOrAbove_countela2
rename M StudentGroup_TotalTestedela2
rename N ProficientOrAbove_percentela2

rename O ProficientOrAbove_countmath2
rename P StudentGroup_TotalTestedmath2
rename Q ProficientOrAbove_percentmath2

drop R S T

rename U ProficientOrAbove_countela3
rename V StudentGroup_TotalTestedela3
rename W ProficientOrAbove_percentela3

rename X ProficientOrAbove_countmath3
rename Y StudentGroup_TotalTestedmath3
rename Z ProficientOrAbove_percentmath3

drop AA AB AC

rename AD ProficientOrAbove_countela4
rename AE StudentGroup_TotalTestedela4
rename AF ProficientOrAbove_percentela4

rename AG ProficientOrAbove_countmath4
rename AH StudentGroup_TotalTestedmath4
rename AI ProficientOrAbove_percentmath4

drop AJ AK AL

rename AM ProficientOrAbove_countela5
rename AN StudentGroup_TotalTestedela5
rename AO ProficientOrAbove_percentela5

rename AP ProficientOrAbove_countmath5
rename AQ StudentGroup_TotalTestedmath5
rename AR ProficientOrAbove_percentmath5

drop AS AT AU

rename AV ProficientOrAbove_countela6
rename AW StudentGroup_TotalTestedela6
rename AX ProficientOrAbove_percentela6

rename AY ProficientOrAbove_countmath6
rename AZ StudentGroup_TotalTestedmath6
rename BA ProficientOrAbove_percentmath6

drop BB BC BD

rename BE ProficientOrAbove_countela7
rename BF StudentGroup_TotalTestedela7
rename BG ProficientOrAbove_percentela7

rename BH ProficientOrAbove_countmath7
rename BI StudentGroup_TotalTestedmath7
rename BJ ProficientOrAbove_percentmath7

drop BK BL BM

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedDistID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "1"
replace StudentSubGroup = "Asian" if StudentSubGroup == "2"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "3"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "4"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "5"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "6"
replace StudentSubGroup = "White" if StudentSubGroup == "7"

gen StudentGroup = "RaceEth"

rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop if ProficientOrAbove_count == ""

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort StateAssignedDistID Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort StateAssignedDistID Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

gen GradeLevel = "G38"

save "/${raw}/2018/DistDisaggRaceEth2018", replace



// dist disaggregate math and ela (EL status)

import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_dist_disagg.xlsx", sheet("ELL") cellrange(A3:T376) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela1
rename D StudentGroup_TotalTestedela1
rename E ProficientOrAbove_percentela1

rename F ProficientOrAbove_countmath1
rename G StudentGroup_TotalTestedmath1
rename H ProficientOrAbove_percentmath1

drop I J K

rename L ProficientOrAbove_countela2
rename M StudentGroup_TotalTestedela2
rename N ProficientOrAbove_percentela2

rename O ProficientOrAbove_countmath2
rename P StudentGroup_TotalTestedmath2
rename Q ProficientOrAbove_percentmath2

drop R S T

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedDistID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "1"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "2"

gen StudentGroup = "EL Status"

rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop if ProficientOrAbove_count == ""

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort StateAssignedDistID Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort StateAssignedDistID Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

gen GradeLevel = "G38"

save "/${raw}/2018/DistDisaggELStatus2018", replace



// economic status (math ela)

import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_dist_disagg.xlsx", sheet("SES") cellrange(A3:T376) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela1
rename D StudentGroup_TotalTestedela1
rename E ProficientOrAbove_percentela1

rename F ProficientOrAbove_countmath1
rename G StudentGroup_TotalTestedmath1
rename H ProficientOrAbove_percentmath1

drop I J K

rename L ProficientOrAbove_countela2
rename M StudentGroup_TotalTestedela2
rename N ProficientOrAbove_percentela2

rename O ProficientOrAbove_countmath2
rename P StudentGroup_TotalTestedmath2
rename Q ProficientOrAbove_percentmath2

drop R S T

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedDistID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "1"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "2"

gen StudentGroup = "Economic Status"

rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop if ProficientOrAbove_count == ""

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort StateAssignedDistID Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort StateAssignedDistID Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

gen GradeLevel = "G38"

save "/${raw}/2018/DistDisaggEconStatus2018", replace


// append at district level data

use "/${raw}/2018/DistMathELA2018.dta"
append using "/${raw}/2018/DistSci2018.dta"
append using "/${raw}/2018/DistSoc2018.dta"
append using "/${raw}/2018/DistDisaggEconStatus2018"
append using "/${raw}/2018/DistDisaggELStatus2018"
append using "/${raw}/2018/DistDisaggRaceEth2018"

gen DataLevel = "District"

save "/${raw}/2018/Dist2018", replace


//// School level data files
import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_sch.xlsx", sheet("Spring 2018") cellrange(A3:BO1698) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E ProficientOrAbove_countela3
rename F StudentGroup_TotalTestedela3
rename G ProficientOrAbove_percentela3

rename H ProficientOrAbove_countmath3
rename I StudentGroup_TotalTestedmath3
rename J ProficientOrAbove_percentmath3

drop K L M

rename N ProficientOrAbove_countela4
rename O StudentGroup_TotalTestedela4
rename P ProficientOrAbove_percentela4

rename Q ProficientOrAbove_countmath4
rename R StudentGroup_TotalTestedmath4
rename S ProficientOrAbove_percentmath4

drop T U V

rename W ProficientOrAbove_countela5
rename X StudentGroup_TotalTestedela5
rename Y ProficientOrAbove_percentela5

rename Z ProficientOrAbove_countmath5
rename AA StudentGroup_TotalTestedmath5
rename AB ProficientOrAbove_percentmath5

drop AC AD AE

rename AF ProficientOrAbove_countela6
rename AG StudentGroup_TotalTestedela6
rename AH ProficientOrAbove_percentela6

rename AI ProficientOrAbove_countmath6
rename AJ StudentGroup_TotalTestedmath6
rename AK ProficientOrAbove_percentmath6

drop AL AM AN

rename AO ProficientOrAbove_countela7
rename AP StudentGroup_TotalTestedela7
rename AQ ProficientOrAbove_percentela7

rename AR ProficientOrAbove_countmath7
rename AS StudentGroup_TotalTestedmath7
rename AT ProficientOrAbove_percentmath7

drop AU AV AW

rename AX ProficientOrAbove_countela8
rename AY StudentGroup_TotalTestedela8
rename AZ ProficientOrAbove_percentela8

rename BA ProficientOrAbove_countmath8
rename BB StudentGroup_TotalTestedmath8
rename BC ProficientOrAbove_percentmath8

drop BD BE BF

rename BG ProficientOrAbove_countela38
rename BH StudentGroup_TotalTestedela38
rename BI ProficientOrAbove_percentela38

rename BJ ProficientOrAbove_countmath38
rename BK StudentGroup_TotalTestedmath38
rename BL ProficientOrAbove_percentmath38

drop BM BN BO

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedSchID) j(GradeLevel) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID GradeLevel) j(Subject) string

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "/${raw}/2018/SchMathELA2018", replace


// science

import excel "/${raw}/2018/IN_OriginalData_2018_sci_soc.xlsx", sheet("2018_Science_School") cellrange(A3:M1512) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E ProficientOrAbove_count4
rename F StudentGroup_TotalTested4
rename G ProficientOrAbove_percent4

rename H ProficientOrAbove_count6
rename I StudentGroup_TotalTested6
rename J ProficientOrAbove_percent6

rename K ProficientOrAbove_count38
rename L StudentGroup_TotalTested38
rename M ProficientOrAbove_percent38

tostring Proficient*, replace force
tostring StudentGroup_TotalTested*, replace force

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID) j(GradeLevel) string

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen Subject = "sci"

save "/${raw}/2018/SchSci2018", replace


// social studies

import excel "/${raw}/2018/IN_OriginalData_2018_sci_soc.xlsx", sheet("2018_Social_Studies_School") cellrange(A3:M1516) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E ProficientOrAbove_count5
rename F StudentGroup_TotalTested5
rename G ProficientOrAbove_percent5

rename H ProficientOrAbove_count7
rename I StudentGroup_TotalTested7
rename J ProficientOrAbove_percent7

rename K ProficientOrAbove_count38
rename L StudentGroup_TotalTested38
rename M ProficientOrAbove_percent38

tostring Proficient*, replace force
tostring StudentGroup_TotalTested*, replace force

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID) j(GradeLevel) string

gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen Subject="soc"

save "/${raw}/2018/SchSoc2018", replace


// disaggregate school math and ela (race/ethnicity)

import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_sch_disagg.xlsx", sheet("Ethnicity") cellrange(A3:BO1698) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E ProficientOrAbove_countela1
rename F StudentGroup_TotalTestedela1
rename G ProficientOrAbove_percentela1

rename H ProficientOrAbove_countmath1
rename I StudentGroup_TotalTestedmath1
rename J ProficientOrAbove_percentmath1

drop K L M

rename N ProficientOrAbove_countela2
rename O StudentGroup_TotalTestedela2
rename P ProficientOrAbove_percentela2

rename Q ProficientOrAbove_countmath2
rename R StudentGroup_TotalTestedmath2
rename S ProficientOrAbove_percentmath2

drop T U V

rename W ProficientOrAbove_countela3
rename X StudentGroup_TotalTestedela3
rename Y ProficientOrAbove_percentela3

rename Z ProficientOrAbove_countmath3
rename AA StudentGroup_TotalTestedmath3
rename AB ProficientOrAbove_percentmath3

drop AC AD AE

rename AF ProficientOrAbove_countela4
rename AG StudentGroup_TotalTestedela4
rename AH ProficientOrAbove_percentela4

rename AI ProficientOrAbove_countmath4
rename AJ StudentGroup_TotalTestedmath4
rename AK ProficientOrAbove_percentmath4

drop AL AM AN

rename AO ProficientOrAbove_countela5
rename AP StudentGroup_TotalTestedela5
rename AQ ProficientOrAbove_percentela5

rename AR ProficientOrAbove_countmath5
rename AS StudentGroup_TotalTestedmath5
rename AT ProficientOrAbove_percentmath5

drop AU AV AW

rename AX ProficientOrAbove_countela6
rename AY StudentGroup_TotalTestedela6
rename AZ ProficientOrAbove_percentela6

rename BA ProficientOrAbove_countmath6
rename BB StudentGroup_TotalTestedmath6
rename BC ProficientOrAbove_percentmath6

drop BD BE BF

rename BG ProficientOrAbove_countela7
rename BH StudentGroup_TotalTestedela7
rename BI ProficientOrAbove_percentela7

rename BJ ProficientOrAbove_countmath7
rename BK StudentGroup_TotalTestedmath7
rename BL ProficientOrAbove_percentmath7

drop BM BN BO

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedSchID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "1"
replace StudentSubGroup = "Asian" if StudentSubGroup == "2"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "3"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "4"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "5"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "6"
replace StudentSubGroup = "White" if StudentSubGroup == "7"

gen StudentGroup = "RaceEth"

gen GradeLevel = "G38"

rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop if ProficientOrAbove_count == ""

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort StateAssignedSchID Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort StateAssignedSchID Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

save "/${raw}/2018/SchDisaggRaceEth2018", replace



// school disaggregate math and ela (EL status)

import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_sch_disagg.xlsx", sheet("ELL") cellrange(A3:V1698) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E ProficientOrAbove_countela1
rename F StudentGroup_TotalTestedela1
rename G ProficientOrAbove_percentela1

rename H ProficientOrAbove_countmath1
rename I StudentGroup_TotalTestedmath1
rename J ProficientOrAbove_percentmath1

drop K L M

rename N ProficientOrAbove_countela2
rename O StudentGroup_TotalTestedela2
rename P ProficientOrAbove_percentela2

rename Q ProficientOrAbove_countmath2
rename R StudentGroup_TotalTestedmath2
rename S ProficientOrAbove_percentmath2

drop T U V

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedSchID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "1"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "2"

gen StudentGroup = "EL Status"

gen GradeLevel = "G38"

rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop if ProficientOrAbove_count == ""

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort StateAssignedSchID Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort StateAssignedSchID Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

save "/${raw}/2018/SchDisaggELStatus2018", replace



// school disaggregate math and ela (Econ status)

import excel "/${raw}/2018/IN_OriginalData_2018_mat_ela_sch_disagg.xlsx", sheet("SES") cellrange(A3:V1698) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E ProficientOrAbove_countela1
rename F StudentGroup_TotalTestedela1
rename G ProficientOrAbove_percentela1

rename H ProficientOrAbove_countmath1
rename I StudentGroup_TotalTestedmath1
rename J ProficientOrAbove_percentmath1

drop K L M

rename N ProficientOrAbove_countela2
rename O StudentGroup_TotalTestedela2
rename P ProficientOrAbove_percentela2

rename Q ProficientOrAbove_countmath2
rename R StudentGroup_TotalTestedmath2
rename S ProficientOrAbove_percentmath2

drop T U V

reshape long ProficientOrAbove_countela StudentGroup_TotalTestedela ProficientOrAbove_percentela ProficientOrAbove_countmath StudentGroup_TotalTestedmath ProficientOrAbove_percentmath, i(StateAssignedSchID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "1"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "2"

gen StudentGroup = "Economic Status"

gen GradeLevel = "G38"

rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop if ProficientOrAbove_count == ""

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort StateAssignedSchID Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort StateAssignedSchID Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

save "/${raw}/2018/SchDisaggEconStatus2018", replace


//append school level data
use "/${raw}/2018/SchMathELA2018.dta", clear
append using "/${raw}/2018/SchSci2018.dta"
append using "/${raw}/2018/SchSoc2018.dta"
append using "/${raw}/2018/SchDisaggEconStatus2018"
append using "/${raw}/2018/SchDisaggELStatus2018"
append using "/${raw}/2018/SchDisaggRaceEth2018"

gen DataLevel = "School"

save "/${raw}/2018/School2018", replace

//append all data
append using "/${raw}/2018/Dist2018.dta"
append using "/${raw}/2018/State2018.dta"

save "/${raw}/2018/IN_2018_appended.dta", replace


////	MERGE NCES

gen State_leaid = "IN-" + StateAssignedDistID

merge m:1 State_leaid using "/${NCES}/NCES_2017_District.dta"

tab DistName StateAssignedDistID if _merge == 1 & DataLevel != "State"

drop if _merge==2
drop _merge

drop if StateAssignedDistID=="9200"
drop if StateAssignedDistID=="9205"
drop if StateAssignedDistID=="9210"
drop if StateAssignedDistID=="9215"
drop if StateAssignedDistID=="9220"
drop if StateAssignedDistID=="9230"
drop if StateAssignedDistID=="9240"

gen seasch = StateAssignedDistID + "-" + StateAssignedSchID

merge m:1 seasch using "/${NCES}/NCES_2017_School.dta"

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

gen SchYear = "2017-18"

gen AssmtName = "ISTEP+"
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

drop if ProficientOrAbove_count == ""

gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""

local level 1 2 3

foreach a of local level{
	gen Lev`a'_percent = "--"
	gen Lev`a'_count = "--"
}

replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "***"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "***"
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "***"
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "***"

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 2 and 3"

replace State = 18
replace StateAbbrev = "IN"
replace StateFips = 18

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IN_AssmtData_2018.dta", replace

export delimited using "${output}/csv/IN_AssmtData_2018.csv", replace
