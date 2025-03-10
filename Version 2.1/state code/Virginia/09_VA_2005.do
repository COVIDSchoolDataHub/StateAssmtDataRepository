clear
set more off

////	AGGREGATE DATA

import excel "/${raw}/VA_OriginalData_2003-2005_all.xls", sheet("spring_pass_rate_table_03_to_05") cellrange(A3:GX1973) firstrow

rename K ProficientOrAbove_percentela3
rename L Lev2_percentela3
rename M Lev3_percentela3
rename R ProficientOrAbove_percentela5
rename S Lev2_percentela5
rename T Lev3_percentela5
rename Y ProficientOrAbove_percentwri5
rename Z Lev2_percentwri5
rename AA Lev3_percentwri5
rename AF ProficientOrAbove_percentela8
rename AG Lev2_percentela8
rename AH Lev3_percentela8
rename AM ProficientOrAbove_percentwri8
rename AN Lev2_percentwri8
rename AO Lev3_percentwri8
rename BH ProficientOrAbove_percentmath3
rename BI Lev2_percentmath3
rename BJ Lev3_percentmath3
rename BO ProficientOrAbove_percentmath5
rename BP Lev2_percentmath5
rename BQ Lev3_percentmath5
rename BV ProficientOrAbove_percentmath8
rename BW Lev2_percentmath8
rename BX Lev3_percentmath8
rename CX ProficientOrAbove_percentsoc3
rename CY Lev2_percentsoc3
rename CZ Lev3_percentsoc3
rename DE ProficientOrAbove_percentsoc5
rename DF Lev2_percentsoc5
rename DG Lev3_percentsoc5
rename DL ProficientOrAbove_percentsoc8
rename DM Lev2_percentsoc8
rename DN Lev3_percentsoc8
rename FM ProficientOrAbove_percentsci3
rename FN Lev2_percentsci3
rename FO Lev3_percentsci3
rename FT ProficientOrAbove_percentsci5
rename FU Lev2_percentsci5
rename FV Lev3_percentsci5
rename GA ProficientOrAbove_percentsci8
rename GB Lev2_percentsci8
rename GC Lev3_percentsci8

keep DivNo DivisionName SchNo SchoolName LowGrade HighGrade ProficientOrAbove_percent* Lev2* Lev3*

drop if DivisionName == ""

reshape long ProficientOrAbove_percentela Lev2_percentela Lev3_percentela ProficientOrAbove_percentmath Lev2_percentmath Lev3_percentmath ProficientOrAbove_percentsoc Lev2_percentsoc Lev3_percentsoc ProficientOrAbove_percentsci Lev2_percentsci Lev3_percentsci ProficientOrAbove_percentwri Lev2_percentwri Lev3_percentwri, i(DivNo SchNo) j(GradeLevel)

reshape long ProficientOrAbove_percent Lev2_percent Lev3_percent, i(DivNo SchNo GradeLevel) j(Subject) string

drop if ProficientOrAbove_percent == ""


// Rewrite percent as decimal

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."

destring Lev2_percent, replace
replace Lev2_percent = Lev2_percent/100
tostring Lev2_percent, replace force
replace Lev2_percent = "--" if Lev2_percent == "."

destring Lev3_percent, replace
replace Lev3_percent = Lev3_percent/100
tostring Lev3_percent, replace force
replace Lev3_percent = "--" if Lev3_percent == "."


// Remove PK only programs and high schools

drop if HighGrade == "PK"
drop if HighGrade == "KG"
destring LowGrade, replace force
drop if ProficientOrAbove_percent == "--" & LowGrade > 8

drop HighGrade LowGrade

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

save "/${output}/VA_2005_base.dta", replace


////	PREPARE DISAGGREGATE DATA

// Grade 3

import excel "/${raw}/disaggregate/VA_2003-2005_disaggregate_G03.xls", sheet("spring_only_sol_by_grade") cellrange(A3:AK16) firstrow clear

keep Category *2005

rename Category StudentSubGroup
rename *2005 *
rename *Proficient Proficient*
rename *Advanced Advanced*
rename *Passed Passed*

reshape long Passed Proficient Advanced, i(StudentSubGroup) j(Subject) string

drop if StudentSubGroup == "All Students"

gen StudentGroup = ""

replace StudentGroup = "Gender" if StudentSubGroup == "Gender Unknown"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Ethnicity Unknown"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Am Indian/Alaskan Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Ethnicity Unknown"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Gender Unknown"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"

replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

gen GradeLevel = 3

replace Proficient = Proficient/100
tostring Proficient, replace force
replace Advanced = Advanced/100
tostring Advanced, replace force
replace Passed = Passed/100
tostring Passed, replace force

rename Passed ProficientOrAbove_percent 

save "/${output}/VA_2005_G03.dta", replace


//	Grade 5

import excel "/${raw}/disaggregate/VA_2003-2005_disaggregate_G05.xls", sheet("spring_only_sol_by_grade") cellrange(A3:AK16) firstrow clear

keep Category *2005

rename Category StudentSubGroup
rename *2005 *
rename *Proficient Proficient*
rename *Advanced Advanced*
rename *Passed Passed*

reshape long Passed Proficient Advanced, i(StudentSubGroup) j(Subject) string

drop if StudentSubGroup == "All Students"

gen StudentGroup = ""

replace StudentGroup = "Gender" if StudentSubGroup == "Gender Unknown"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Ethnicity Unknown"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Am Indian/Alaskan Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Ethnicity Unknown"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Gender Unknown"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"

replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

gen GradeLevel = 5

replace Proficient = Proficient/100
tostring Proficient, replace force
replace Advanced = Advanced/100
tostring Advanced, replace force
replace Passed = Passed/100
tostring Passed, replace force

rename Passed ProficientOrAbove_percent 

save "/${output}/VA_2005_G05.dta", replace


//	Grade 8

import excel "/${raw}/disaggregate/VA_2003-2005_disaggregate_G08.xls", sheet("spring_only_sol_by_grade") cellrange(A3:AK16) firstrow clear

keep Category *2005

destring *2005, replace

rename Category StudentSubGroup
rename *2005 *
rename *Proficient Proficient*
rename *Advanced Advanced*
rename *Passed Passed*

reshape long Passed Proficient Advanced, i(StudentSubGroup) j(Subject) string

drop if StudentSubGroup == "All Students"

gen StudentGroup = ""

replace StudentGroup = "Gender" if StudentSubGroup == "Gender Unknown"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Ethnicity Unknown"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Am Indian/Alaskan Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Ethnicity Unknown"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Gender Unknown"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"

replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

gen GradeLevel = 8

replace Proficient = Proficient/100
tostring Proficient, replace force
replace Advanced = -100 if Advanced == .
replace Advanced = Advanced/100
tostring Advanced, replace force
replace Advanced = "--" if Advanced == "-1"
replace Passed = Passed/100
tostring Passed, replace force

rename Passed ProficientOrAbove_percent 

save "/${output}/VA_2005_G08.dta", replace


//	Append aggregate and subgroup data together

use "/${output}/VA_2005_base.dta", clear

append using "/${output}/VA_2005_G03.dta"
append using "/${output}/VA_2005_G05.dta"
append using "/${output}/VA_2005_G08.dta"


//	Prepare for NCES merge

replace DivNo = "00" + DivNo if real(DivNo) < 10
replace DivNo = "0" + DivNo if real(DivNo) >= 10 & real(DivNo) < 100
gen StateAssignedDistID = DivNo
rename DivNo State_leaid

replace StateAssignedDistID = "" if DivisionName == "STATE SUMMARY" | DivisionName == ""
replace State_leaid = "" if DivisionName == "STATE SUMMARY" | DivisionName == ""

tostring SchNo, replace
replace SchNo = "000" + SchNo if real(SchNo) < 10
replace SchNo = State_leaid + "00" + SchNo if real(SchNo) >= 10 & real(SchNo) < 100
replace SchNo = "0" + SchNo if real(SchNo) >= 100 & real(SchNo) < 1000
gen StateAssignedSchID = StateAssignedDistID + "-" + SchNo
replace SchNo = State_leaid + SchNo
rename SchNo seasch

replace StateAssignedSchID = "" if SchoolName == "DIVISION SUMMARY" | DivisionName == "STATE SUMMARY" | DivisionName == ""
replace seasch = "" if SchoolName == "DIVISION SUMMARY" | DivisionName == "STATE SUMMARY" | DivisionName == ""

merge m:1 State_leaid using "/${NCES}/NCES_2004_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "/${NCES}/NCES_2004_School.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "/${NCES}/NCES_2003_School.dta", update
drop if NCESSchoolID == "" & seasch != ""
drop if _merge == 2
drop _merge


////	FINISH CLEANING DATA

tab Subject
replace Subject = "ela" if Subject == "English"
replace Subject = "soc" if Subject == "History"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

local level 1 2 3
foreach a of local level {
	gen Lev`a'_count = "--"
}

gen Lev1_percent = "--"
replace Lev1_percent = string(1 - real(ProficientOrAbove_percent), "%9.4g") if real(ProficientOrAbove_percent) != .

replace Lev2_percent = "--" if Lev2_percent == ""
replace Lev2_percent = Proficient if Proficient != ""
replace Lev3_percent = Advanced if Advanced != ""

replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent), "%9.4g") if real(ProficientOrAbove_percent) != . & real(Lev3_percent) != . & Lev2_percent == "--"
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev2_percent), "%9.4g") if real(ProficientOrAbove_percent) != . & real(Lev2_percent) != . & Lev3_percent == "--" & real(ProficientOrAbove_percent) - real(Lev2_percent) >= 0

gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""

gen DataLevel = "School"
replace DataLevel = "State" if StudentGroup != "All Students"
replace DataLevel = "State" if DivisionName == "STATE SUMMARY"
replace DataLevel = "District" if SchoolName == "DIVISION SUMMARY"

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

gen SchYear = "2004-05"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 2-3"
gen ProficientOrAbove_count = "--"

gen ParticipationRate = "--"

replace State = "Virginia" if DataLevel == 1
replace StateAbbrev = "VA" if DataLevel == 1
replace StateFips = 51 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
replace CountyName = proper(CountyName)
replace DistName = proper(DistName)
replace DistName = subinstr(DistName, " Of ", " of ", 1) //fixing from proper case for standardization
replace DistName = subinstr(DistName, " And ", " and ", 1) //fixing from proper case for standardization
replace DistName = subinstr(DistName, "Cty Public Schools", "City Public Schools", 1) //for standardization across years
replace DistName = subinstr(DistName, "Co Pblc Schs", "County Public Schools", 1) //for standardization across years
replace DistName = subinstr(DistName, "Pblc Schs", "Public Schools", 1) //for standardization across years
replace DistName = subinstr(DistName, "King Geo ", "King George ", 1) //for standardization across years
replace DistName = subinstr(DistName, "Colnl Heights ", "Colonial Heights ", 1) //for standardization across years
replace DistName = subinstr(DistName, "Prince Wm ", "Prince William ", 1) //for standardization across years
replace DistName = subinstr(DistName, "Fredericksbrg ", "Fredericksburg ", 1) //for standardization across years 
replace DistName = subinstr(DistName, "Va Beach ", "Virginia Beach ", 1) //for standardization across years

replace SchName = strproper(SchName)
replace SchName = stritrim(SchName)

merge m:1 SchYear CountyCode using "/${raw}/va_county-list_through2023.dta"
replace CountyName = newcountyname
drop if _merge == 2
drop _merge

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/VA_AssmtData_2005.dta", replace

export delimited using "${output}/csv/VA_AssmtData_2005.csv", replace
