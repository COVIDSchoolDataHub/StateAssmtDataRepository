clear
set more off

global raw "/Users/maggie/Desktop/Virginia/Original Data"
global NCES "/Users/maggie/Desktop/Virginia/NCES/Cleaned"
global output "/Users/maggie/Desktop/Virginia/Output"

cd "/Users/maggie/Desktop/Virginia"

////	AGGREGATE DATA

//Transform to long

import excel "/${raw}/VA_OriginalData_1998-2002_all.xls", sheet("1998-2002 % Passing By School") cellrange(A2:EP2119) firstrow case(lower) clear

rename english2002 ProficientOrAbove_percentread3
rename mathematics2002 ProficientOrAbove_percentmath3
rename history2002 ProficientOrAbove_percentsoc3
rename science2002 ProficientOrAbove_percentsci3
rename writing2002 ProficientOrAbove_percentwri5
rename englishrlr2002 ProficientOrAbove_percentread5
rename ao ProficientOrAbove_percentmath5
rename at ProficientOrAbove_percentsoc5
rename ay ProficientOrAbove_percentsci5
rename computertechnology2002 ProficientOrAbove_percentstem5
rename bi ProficientOrAbove_percentwri8
rename bn ProficientOrAbove_percentread8
rename bs ProficientOrAbove_percentmath8
rename bx ProficientOrAbove_percentsoc8
rename cc ProficientOrAbove_percentsci8
rename ch ProficientOrAbove_percentstem8

keep div divisionname sch schoolname lowgr highgr ProficientOrAbove_percent*

drop if divisionname == ""

reshape long ProficientOrAbove_percentread ProficientOrAbove_percentmath ProficientOrAbove_percentsoc ProficientOrAbove_percentsci ProficientOrAbove_percentwri ProficientOrAbove_percentstem, i(div sch) j(GradeLevel)

reshape long ProficientOrAbove_percent, i(div sch GradeLevel) j(Subject) string

drop if ProficientOrAbove_percent == ""

replace ProficientOrAbove_percent = "-100" if ProficientOrAbove_percent == "."

// Rewrite percent as decimal

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "-1"

// Remove PK only programs and high schools

drop if highgr == "PK"
drop if highgr == "KG"
destring lowgr, replace force
drop if ProficientOrAbove_percent == "--" & lowgr > 8

drop highgr lowgr

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

save "/${output}/VA_2002_base.dta", replace


//// PREPARE DISAGGREGATE TOTALS FOR APPENDING

// Gender

import excel "/${raw}/disaggregate/VA_1998-2002_gender.xls", sheet("shading (2)") cellrange(B3:L41) firstrow clear

drop if SOLTest == "" | SOLTest == "Grade 3" | SOLTest == "Grade 5" | SOLTest == "Grade 8" 

gen gradebreakup = _n
drop if gradebreakup > 16

gen GradeLevel= .
replace GradeLevel=3 if gradebreakup < 5
replace GradeLevel=5 if gradebreakup > 4
replace GradeLevel=8 if gradebreakup > 10

keep SOLTest K L GradeLevel
rename K ProficientOrAbove_percentFemale
rename L ProficientOrAbove_percentMale

reshape long ProficientOrAbove_percent, i(SOLTest GradeLevel) j(StudentSubGroup) string

gen StudentGroup = "Gender"
rename SOLTest Subject

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

save "/${output}/VA_2002_gender.dta", replace


// Race & Ethnicity, grade 3

import excel "/${raw}/disaggregate/VA_1998-2002_raceeth.xls", sheet("Sheet1 (2)") cellrange(A9:AE14) clear

keep A F K P U
rename A StudentSubGroup
rename F ProficientOrAbove_percentread
rename K ProficientOrAbove_percentmath
rename P ProficientOrAbove_percentsoc
rename U ProficientOrAbove_percentsci

gen GradeLevel = 3

reshape long ProficientOrAbove_percent, i(StudentSubGroup) j(Subject) string

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

gen StudentGroup = "RaceEth"

save "/${output}/VA_2002_race3.dta", replace


// Race & Ethnicity, grade 5 & 8

import excel "/${raw}/disaggregate/VA_1998-2002_raceeth.xls", sheet("Sheet1 (2)") cellrange(A18:AE40) clear

keep A F K P U Z AE
rename A StudentSubGroup
rename F ProficientOrAbove_percentread
rename K ProficientOrAbove_percentwri
rename P ProficientOrAbove_percentmath
rename U ProficientOrAbove_percentsoc
rename Z ProficientOrAbove_percentsci
rename AE ProficientOrAbove_percentstem

gen id = _n
gen GradeLevel = .
replace GradeLevel = 5 if id<12
replace GradeLevel = 8 if id>12
drop if id <= 4
drop if id > 10 & id < 18
drop id

reshape long ProficientOrAbove_percent, i(StudentSubGroup GradeLevel) j(Subject) string

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

gen StudentGroup = "RaceEth"

save "/${output}/VA_2002_race58.dta", replace


////	APPEND AGGREGATE AND DISAGGREGATE DATA

use "/${output}/VA_2002_base.dta", clear

append using "/${output}/VA_2002_gender.dta"
append using "/${output}/VA_2002_race3.dta"
append using "/${output}/VA_2002_race58.dta"


////	PREPARE FOR NCES MERGE

destring div, gen(StateAssignedDistID)
replace div = "00" + div if StateAssignedDistID < 10
replace div = "0" + div if StateAssignedDistID >= 10 & StateAssignedDistID < 100
tostring StateAssignedDistID, replace
rename div State_leaid

tostring sch, replace
destring sch, gen(StateAssignedSchID)
replace sch = State_leaid + "000" + sch if StateAssignedSchID < 10
replace sch = State_leaid + "00" + sch if StateAssignedSchID >= 10 & StateAssignedSchID < 100
replace sch = State_leaid + "0" + sch if StateAssignedSchID >= 100 & StateAssignedSchID < 1000
replace sch = State_leaid + sch if StateAssignedSchID >= 1000
tostring StateAssignedSchID, replace
rename sch seasch
drop if seasch == "9010901" | seasch == "2190219"

replace StateAssignedDistID = "" if schoolname == "STATE SUMMARY" | StudentGroup != "All Students"
replace seasch = "" if schoolname == "DIVISION SUMMARY" | schoolname == "STATE SUMMARY" | StudentGroup != "All Students"
replace StateAssignedSchID = "" if schoolname == "DIVISION SUMMARY" | schoolname == "STATE SUMMARY" | StudentGroup != "All Students"

merge m:1 State_leaid using "/${NCES}/NCES_2001_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "/${NCES}/NCES_2001_School.dta"
drop if _merge == 2
drop _merge


////	FINISH CLEANING DATA

replace Subject = "stem" if Subject == "Computer/Technology"
replace Subject = "wri" if strpos(Subject, "Writing") > 0
replace Subject = "ela" if strpos(Subject, "English") > 0
replace Subject = "soc" if Subject == "History"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

local level 1 2 3
foreach a of local level {
	gen Lev`a'_count = "--"
	gen Lev`a'_percent = "--"
}

gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""

gen DataLevel = "School"
replace DataLevel = "State" if StudentGroup != "All Students"
replace DataLevel = "State" if schoolname == "STATE SUMMARY"
replace DataLevel = "District" if schoolname == "DIVISION SUMMARY"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G08" if GradeLevel == "8"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtName = "Standards of Learning"
gen AssmtType = "Regular"
gen SchYear = "2001-02"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 2-3"
gen ProficientOrAbove_count = "--"
gen ParticipationRate = "--"

replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Am Indian/Alaskan Native"
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Ethnicity Unknown"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"

replace State = 51 if DataLevel == 1
replace StateAbbrev = "VA" if DataLevel == 1
replace StateFips = 51 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

drop divisionname schoolname

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/VA_AssmtData_2002.dta", replace

export delimited using "${output}/csv/VA_AssmtData_2002.csv", replace
