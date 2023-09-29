clear
set more off

cd "/Users/maggie/Desktop/Indiana"

global raw "/Users/maggie/Desktop/Indiana/Original Data Files"
global output "/Users/maggie/Desktop/Indiana/Output"
global NCES "/Users/maggie/Desktop/Indiana/NCES/Cleaned"

//////	ORGANIZING AND APPENDING DATA


//// Create state level data

//ela
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_state.xlsx", sheet("ELA") cellrange(A3:C9) clear

rename A GradeLevel

rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"
gen Subject = "ela"

save "/${raw}/2015/StateELA2015", replace

//math
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_state.xlsx", sheet("Math") cellrange(A3:C9) clear

rename A GradeLevel

rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"
gen Subject = "math"

save "/${raw}/2015/StateMath2015", replace

//sci
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_state.xlsx", sheet("Science") cellrange(A3:C5) clear

rename A GradeLevel

rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"
gen Subject = "sci"

save "/${raw}/2015/StateSci2015", replace

//soc
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_state.xlsx", sheet("Social Studies") cellrange(A3:C5) clear

rename A GradeLevel

rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"
gen Subject = "soc"

save "/${raw}/2015/StateSoc2015", replace

// state disaggregate data (math and ela)
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_state_disagg.xlsx", sheet("Sheet1") cellrange(A2:G16) clear

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

bysort StudentGroup: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

gen GradeLevel = "G38"

tostring *_TotalTested, replace

save "/${raw}/2015/StateDisagg2015", replace

//append all state-level files
use "/${raw}/2015/StateELA2015", replace
append using "/${raw}/2015/StateMath2015"
append using "/${raw}/2015/StateSci2015"
append using "/${raw}/2015/StateSoc2015"
append using "/${raw}/2015/StateDisagg2015"

gen DataLevel = "State"

tostring Proficient*, replace force

save "/${raw}/2015/State2015", replace

//// Create district level data

//math and ela
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_dist.xlsx", sheet("Spring 2015") cellrange(A3:AK301) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela3
rename D ProficientOrAbove_percentela3

rename E ProficientOrAbove_countmath3
rename F ProficientOrAbove_percentmath3

drop G

rename H ProficientOrAbove_countela4
rename I ProficientOrAbove_percentela4

rename J ProficientOrAbove_countmath4
rename K ProficientOrAbove_percentmath4

drop L

rename M ProficientOrAbove_countela5
rename N ProficientOrAbove_percentela5

rename O ProficientOrAbove_countmath5
rename P ProficientOrAbove_percentmath5

drop Q

rename R ProficientOrAbove_countela6
rename S ProficientOrAbove_percentela6

rename T ProficientOrAbove_countmath6
rename U ProficientOrAbove_percentmath6

drop V

rename W ProficientOrAbove_countela7
rename X ProficientOrAbove_percentela7

rename Y ProficientOrAbove_countmath7
rename Z ProficientOrAbove_percentmath7

drop AA

rename AB ProficientOrAbove_countela8
rename AC ProficientOrAbove_percentela8

rename AD ProficientOrAbove_countmath8
rename AE ProficientOrAbove_percentmath8

drop AF

rename AG ProficientOrAbove_countela38
rename AH ProficientOrAbove_percentela38

rename AI ProficientOrAbove_countmath38
rename AJ ProficientOrAbove_percentmath38

drop AK

tostring Proficient*, replace force

reshape long ProficientOrAbove_countela ProficientOrAbove_percentela ProficientOrAbove_countmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(GradeLevel) string

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID GradeLevel) j(Subject) string

gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

drop if ProficientOrAbove_count == "."

save "/${raw}/2015/DistMathELA2015", replace


//science
import excel "/${raw}/2015/IN_OriginalData_2015_sci_soc.xlsx", sheet("2015_SCIENCE_CORP") cellrange(A3:H358) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_count4
rename D ProficientOrAbove_percent4

rename E ProficientOrAbove_count6
rename F ProficientOrAbove_percent6

rename G ProficientOrAbove_count38
rename H ProficientOrAbove_percent38

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "sci"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

save "/${raw}/2015/DistSci2015", replace


// district social studies
import excel "/${raw}/2015/IN_OriginalData_2015_sci_soc.xlsx", sheet("2015_SS_CORP") cellrange(A3:H158) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_count5
rename D ProficientOrAbove_percent5

rename E ProficientOrAbove_count7
rename F ProficientOrAbove_percent7

rename G ProficientOrAbove_count38
rename H ProficientOrAbove_percent38

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID) j(GradeLevel) string

gen Subject = "soc"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

save "/${raw}/2015/DistSoc2015", replace


// dist disaggregate math and ela (race/ethnicity)
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_dist_disagg.xlsx", sheet("Ethnicity") cellrange (A3:AK295) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela1
rename D ProficientOrAbove_percentela1

rename E ProficientOrAbove_countmath1
rename F ProficientOrAbove_percentmath1

drop G

rename H ProficientOrAbove_countela2
rename I ProficientOrAbove_percentela2

rename J ProficientOrAbove_countmath2
rename K ProficientOrAbove_percentmath2

drop L

rename M ProficientOrAbove_countela3
rename N ProficientOrAbove_percentela3

rename O ProficientOrAbove_countmath3
rename P ProficientOrAbove_percentmath3

drop Q

rename R ProficientOrAbove_countela4
rename S ProficientOrAbove_percentela4

rename T ProficientOrAbove_countmath4
rename U ProficientOrAbove_percentmath4

drop V

rename W ProficientOrAbove_countela5
rename X ProficientOrAbove_percentela5

rename Y ProficientOrAbove_countmath5
rename Z ProficientOrAbove_percentmath5

drop AA

rename AB ProficientOrAbove_countela6
rename AC ProficientOrAbove_percentela6

rename AD ProficientOrAbove_countmath6
rename AE ProficientOrAbove_percentmath6

drop AF

rename AG ProficientOrAbove_countela7
rename AH ProficientOrAbove_percentela7

rename AI ProficientOrAbove_countmath7
rename AJ ProficientOrAbove_percentmath7

drop AK

reshape long ProficientOrAbove_countela ProficientOrAbove_percentela ProficientOrAbove_countmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "1"
replace StudentSubGroup = "Asian" if StudentSubGroup == "2"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "3"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "4"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "5"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "6"
replace StudentSubGroup = "White" if StudentSubGroup == "7"

gen StudentGroup = "RaceEth"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

gen GradeLevel = "G38"

save "/${raw}/2015/DistDisaggRaceEth2015", replace



// dist disaggregate math and ela (EL status)

import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_dist_disagg.xlsx", sheet("ELL") cellrange(A3:L295) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela1
rename D ProficientOrAbove_percentela1

rename E ProficientOrAbove_countmath1
rename F ProficientOrAbove_percentmath1

drop G

rename H ProficientOrAbove_countela2
rename I ProficientOrAbove_percentela2

rename J ProficientOrAbove_countmath2
rename K ProficientOrAbove_percentmath2

drop L

tostring Proficient*, replace force

reshape long ProficientOrAbove_countela ProficientOrAbove_percentela ProficientOrAbove_countmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "English Proficient" if StudentSubGroup == "1"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "2"

gen StudentGroup = "EL Status"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

gen GradeLevel = "G38"

save "/${raw}/2015/DistDisaggELStatus2015", replace



// economic status (math ela)

import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_dist_disagg.xlsx", sheet("Free_Reduced") cellrange(A3:L295) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela1
rename D ProficientOrAbove_percentela1

rename E ProficientOrAbove_countmath1
rename F ProficientOrAbove_percentmath1

drop G

rename H ProficientOrAbove_countela2
rename I ProficientOrAbove_percentela2

rename J ProficientOrAbove_countmath2
rename K ProficientOrAbove_percentmath2

drop L

tostring Proficient*, replace force

reshape long ProficientOrAbove_countela ProficientOrAbove_percentela ProficientOrAbove_countmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(StudentSubGroup) string

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID StudentSubGroup) j(Subject) string

replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "1"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "2"

gen StudentGroup = "Economic Status"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

gen GradeLevel = "G38"

save "/${raw}/2015/DistDisaggEconStatus2015", replace


// append at district level data

use "/${raw}/2015/DistMathELA2015.dta"
append using "/${raw}/2015/DistSci2015.dta"
append using "/${raw}/2015/DistSoc2015.dta"
append using "/${raw}/2015/DistDisaggEconStatus2015"
append using "/${raw}/2015/DistDisaggELStatus2015"
append using "/${raw}/2015/DistDisaggRaceEth2015"

gen DataLevel = "District"

save "/${raw}/2015/Dist2015", replace


//// School level data files
import excel "/${raw}/2015/IN_OriginalData_2015_mat_ela_sch.xlsx", sheet("Spring 2015") cellrange(A3:AM1518) clear

rename A StateAssignedDistID
rename B DistName
rename C StateAssignedSchID
rename D SchName

rename E ProficientOrAbove_countela3
rename F ProficientOrAbove_percentela3

rename G ProficientOrAbove_countmath3
rename H ProficientOrAbove_percentmath3

drop I

rename J ProficientOrAbove_countela4
rename K ProficientOrAbove_percentela4

rename L ProficientOrAbove_countmath4
rename M ProficientOrAbove_percentmath4

drop N

rename O ProficientOrAbove_countela5
rename P ProficientOrAbove_percentela5

rename Q ProficientOrAbove_countmath5
rename R ProficientOrAbove_percentmath5

drop S

rename T ProficientOrAbove_countela6
rename U ProficientOrAbove_percentela6

rename V ProficientOrAbove_countmath6
rename W ProficientOrAbove_percentmath6

drop X

rename Y ProficientOrAbove_countela7
rename Z ProficientOrAbove_percentela7

rename AA ProficientOrAbove_countmath7
rename AB ProficientOrAbove_percentmath7

drop AC

rename AD ProficientOrAbove_countela8
rename AE ProficientOrAbove_percentela8

rename AF ProficientOrAbove_countmath8
rename AG ProficientOrAbove_percentmath8

drop AH

rename AI ProficientOrAbove_countela38
rename AJ ProficientOrAbove_percentela38

rename AK ProficientOrAbove_countmath38
rename AL ProficientOrAbove_percentmath38

drop AM

reshape long ProficientOrAbove_countela ProficientOrAbove_percentela ProficientOrAbove_countmath ProficientOrAbove_percentmath, i(StateAssignedSchID) j(GradeLevel) string

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedSchID GradeLevel) j(Subject) string

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

save "/${raw}/2015/SchMathELA2015", replace


// science

import excel "/${raw}/2015/IN_OriginalData_2015_sci_soc.xlsx", sheet("2015_SCIENCE_SCH") cellrange(A3:J1614) clear

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName

rename E ProficientOrAbove_count4
rename F ProficientOrAbove_percent4

rename G ProficientOrAbove_count6
rename H ProficientOrAbove_percent6

rename I ProficientOrAbove_count38
rename J ProficientOrAbove_percent38

tostring Proficient*, replace force

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID StateAssignedSchID) j(GradeLevel) string

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

gen Subject = "sci"

save "/${raw}/2015/SchSci2015", replace


// social studies

import excel "/${raw}/2015/IN_OriginalData_2015_sci_soc.xlsx", sheet("2015_SS_SCH") cellrange(A3:J383) clear

rename A StateAssignedSchID
rename B SchName
rename C StateAssignedDistID
rename D DistName

rename E ProficientOrAbove_count5
rename F ProficientOrAbove_percent5

rename G ProficientOrAbove_count7
rename H ProficientOrAbove_percent7

rename I ProficientOrAbove_count38
rename J ProficientOrAbove_percent38

tostring Proficient*, replace force

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID StateAssignedSchID) j(GradeLevel) string

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

drop if ProficientOrAbove_count == ""

gen Subject = "soc"

save "/${raw}/2015/SchSoc2015", replace


//append school level data
use "/${raw}/2015/SchMathELA2015.dta", clear
append using "/${raw}/2015/SchSci2015.dta"
append using "/${raw}/2015/SchSoc2015.dta"

gen DataLevel = "School"

save "/${raw}/2015/School2015", replace

//append all data
append using "/${raw}/2015/Dist2015.dta"
append using "/${raw}/2015/State2015.dta"

save "/${raw}/2015/IN_2015_appended.dta", replace


////	MERGE NCES

gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "/${NCES}/NCES_2015_District.dta"

tab StateAssignedDistID if _merge == 1 & DataLevel != "State"

drop if _merge==2
drop _merge

drop if StateAssignedDistID=="N/A"
drop if StateAssignedDistID=="9200"
drop if StateAssignedDistID=="9205"
drop if StateAssignedDistID=="9210"
drop if StateAssignedDistID=="9215"
drop if StateAssignedDistID=="9220"
drop if StateAssignedDistID=="9230"
drop if StateAssignedDistID=="9240"

gen seasch = StateAssignedSchID

merge m:1 State_leaid seasch using "/${NCES}/NCES_2015_School.dta"

tab SchName if _merge == 1 & DataLevel == "School"

drop if SchName == "Sanders School"

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

gen SchYear = "2014-15"

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

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 2 and 3"

replace State = 18
replace StateAbbrev = "IN"
replace StateFips = 18

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IN_AssmtData_2015.dta", replace

export delimited using "${output}/csv/IN_AssmtData_2015.csv", replace
