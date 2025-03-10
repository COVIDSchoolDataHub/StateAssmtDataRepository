clear
set more off

global raw "/Users/maggie/Desktop/Virginia/Original Data"
global NCES "/Users/maggie/Desktop/Virginia/NCES/Cleaned"
global output "/Users/maggie/Desktop/Virginia/Output"

cd "/Users/maggie/Desktop/Virginia"

////	AGGREGATE DATA

//Transform to long

import excel "/${raw}/VA_OriginalData_1998-2002_all.xls", sheet("1998-2002 % Passing By School") cellrange(A2:EP2119) firstrow case(lower) clear

rename english1999 ProficientOrAbove_percentela3
rename mathematics1999 ProficientOrAbove_percentmath3
rename history1999 ProficientOrAbove_percentsoc3
rename science1999 ProficientOrAbove_percentsci3
rename writing1999 ProficientOrAbove_percentwri5
rename englishrlr1999 ProficientOrAbove_percentela5
rename al ProficientOrAbove_percentmath5
rename aq ProficientOrAbove_percentsoc5
rename av ProficientOrAbove_percentsci5
rename computertechnology1999 ProficientOrAbove_percentstem5
rename bf ProficientOrAbove_percentwri8
rename bk ProficientOrAbove_percentela8
rename bp ProficientOrAbove_percentmath8
rename bu ProficientOrAbove_percentsoc8
rename bz ProficientOrAbove_percentsci8
rename ce ProficientOrAbove_percentstem8

keep div divisionname sch schoolname lowgr highgr ProficientOrAbove_percent*

drop if divisionname == ""

reshape long ProficientOrAbove_percentela ProficientOrAbove_percentmath ProficientOrAbove_percentsoc ProficientOrAbove_percentsci ProficientOrAbove_percentwri ProficientOrAbove_percentstem, i(div sch) j(GradeLevel)

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

save "/${output}/VA_1999_base.dta", replace


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

keep SOLTest E F GradeLevel
rename E ProficientOrAbove_percentFemale
rename F ProficientOrAbove_percentMale

reshape long ProficientOrAbove_percent, i(SOLTest GradeLevel) j(StudentSubGroup) string

gen StudentGroup = "Gender"
rename SOLTest Subject

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

save "/${output}/VA_1999_gender.dta", replace


// Race & Ethnicity, grade 3

import excel "/${raw}/disaggregate/VA_1998-2002_raceeth.xls", sheet("Sheet1 (2)") cellrange(A9:AE14) clear

keep A C H M R
rename A StudentSubGroup
rename C ProficientOrAbove_percentela
rename H ProficientOrAbove_percentmath
rename M ProficientOrAbove_percentsoc
rename R ProficientOrAbove_percentsci

gen GradeLevel = 3

reshape long ProficientOrAbove_percent, i(StudentSubGroup) j(Subject) string

replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

gen StudentGroup = "RaceEth"

save "/${output}/VA_1999_race3.dta", replace


// Race & Ethnicity, grade 5 & 8

import excel "/${raw}/disaggregate/VA_1998-2002_raceeth.xls", sheet("Sheet1 (2)") cellrange(A18:AE40) clear

keep A C H M R W AB
rename A StudentSubGroup
rename C ProficientOrAbove_percentela
rename H ProficientOrAbove_percentwri
rename M ProficientOrAbove_percentmath
rename R ProficientOrAbove_percentsoc
rename W ProficientOrAbove_percentsci
rename AB ProficientOrAbove_percentstem

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

save "/${output}/VA_1999_race58.dta", replace


////	APPEND AGGREGATE AND DISAGGREGATE DATA

use "/${output}/VA_1999_base.dta", clear

append using "/${output}/VA_1999_gender.dta"
append using "/${output}/VA_1999_race3.dta"
append using "/${output}/VA_1999_race58.dta"


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

drop if Subject == "Computer/Technology" | Subject == "stem"
replace Subject = "wri" if strpos(Subject, "Writing") > 0
replace Subject = "ela" if strpos(Subject, "Reading") > 0 | Subject == "English"
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
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

gen AssmtName = "Standards of Learning"
gen AssmtType = "Regular"

gen SchYear = "1998-99"

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

replace State = "Virginia" if DataLevel == 1
replace StateAbbrev = "VA" if DataLevel == 1
replace StateFips = 51 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
replace CountyName = proper(CountyName)
replace DistName = proper(DistName)

merge m:1 SchYear CountyCode using "/${raw}/va_county-list_through2023.dta"
replace CountyName = newcountyname
drop if _merge == 2
drop _merge

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/VA_AssmtData_1999.dta", replace

export delimited using "${output}/csv/VA_AssmtData_1999.csv", replace
