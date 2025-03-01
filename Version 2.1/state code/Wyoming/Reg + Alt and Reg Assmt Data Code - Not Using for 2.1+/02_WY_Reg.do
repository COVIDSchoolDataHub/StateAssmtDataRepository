clear
set more off
set trace off

//Import Data - Hide After First Run

import excel "${Original}/WY Grade 3 to 10 Public Assessment Results WYTOPP Only 2018-19 and 2020-21 - 2025-02-20 WDE VM.xlsx", firstrow case(preserve) clear
save "${Original}/WY_Reg_Combined.dta", replace
import excel "${Original}/WY Grade 3 to 10 Public Assessment Results WYTOPP Only 2021-22 and 2022-23 - 2025-02-20 WDE VM.xlsx", firstrow case(preserve) clear
append using "${Original}/WY_Reg_Combined.dta"
save "${Original}/WY_Reg_Combined.dta", replace
import excel "${Original}/WY Grade 3 to 10 Public Assessment Results WYTOPP Only 2023-24 - 2025-02-20 WDE VM.xlsx", firstrow case(preserve) clear
append using "${Original}/WY_Reg_Combined.dta"
save "${Original}/WY_Reg_Combined.dta", replace

use "${Original}/WY_Reg_Combined.dta", clear

//Rename Variables
rename SCHOOL_YEAR SchYear
rename TEST_TYPE AssmtName
rename DATA_SCOPE DataLevel
rename DISTRICT_ID StateAssignedDistID
rename DISTRICT_NAME DistName
rename SCHOOL_ID StateAssignedSchID
rename SCHOOL_NAME SchName
rename GRADE GradeLevel
rename SUBGROUP StudentSubGroup
rename SUBJECT Subject
rename COUNT_TESTED StudentSubGroup_TotalTested
rename PARTICIPATION_RATE ParticipationRate
rename PERCENT_BELOW Lev1_percent
rename PERCENT_BASIC Lev2_percent
rename PERCENT_PROFICIENT Lev3_percent
rename PERCENT_ADVANCED Lev4_percent
rename PERCENT_PROFICIENT_ADVANCED ProficientOrAbove_percent
rename AVG_WYTOPP_SCALE_SCORE AvgScaleScore

drop PERCENT_BASIC_BELOW ALT_ORDER

//DataLevel
replace DataLevel = strproper(DataLevel)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//GradeLevel & Subject
drop if inlist(GradeLevel, "09", "10", "ALL")
replace GradeLevel = "G" + GradeLevel
replace Subject = "ela" if Subject == "English Language Arts (ELA)"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//StudentSubGroup & StudentGroup
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learner"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Individual Education Plan (IEP)"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-Individual Education Plan (non-IEP)"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Free/Reduced Lunch"
replace StudentSubGroup = subinstr(StudentSubGroup, " Connected", "", 1)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ", 1)

drop if strpos(StudentSubGroup, "Academic Year") != 0
drop if strpos(StudentSubGroup, "Accommodations") != 0
drop if strpos(StudentSubGroup, "Gifted") != 0
drop if strpos(StudentSubGroup, "Virtual") != 0

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") != 0
replace StudentGroup = "Economic Status" if strpos(StudentSubGroup, "Economically") != 0
replace StudentGroup = "EL Status" if strpos(StudentSubGroup, "English") != 0
replace StudentGroup = "Foster Care Status" if strpos(StudentSubGroup, "Foster Care") != 0
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup = "Homeless Enrolled Status" if strpos(StudentSubGroup, "Homeless") != 0
replace StudentGroup = "Migrant Status" if strpos(StudentSubGroup, "Migrant") != 0
replace StudentGroup = "Military Connected Status" if strpos(StudentSubGroup, "Military") != 0

replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)
drop if StudentSubGroup_TotalTested == "0"
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, " ", "", 2)

//Performance Information
foreach var in ParticipationRate Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	replace `var' = subinstr(`var', "%", "", 1)
	gen `var'fl = 1 if strpos(`var', "<=") != 0
	gen `var'fh = 1 if strpos(`var', ">=") != 0
	replace `var' = subinstr(`var', "<= ", "", 1)
	replace `var' = subinstr(`var', ">= ", "", 1)
	replace `var' = string(real(`var')/100, "%9.4g") if `var' != ""
	replace `var' = "0" if `var' == "0.0000"
	replace `var' = "1" if `var' == "1.0000"
	replace `var' = "--" if `var' == ""
}

gen x = strpos(StudentSubGroup_TotalTested, "-")
gen ssgttlow = substr(StudentSubGroup_TotalTested, 1, x-1)
gen ssgtthigh = substr(StudentSubGroup_TotalTested, x+1, strlen(StudentSubGroup_TotalTested)-x)
destring ssgttlow ssgtthigh, replace

foreach lev in Lev1 Lev2 Lev3 Lev4 ProficientOrAbove {
	gen `lev'_countlow = string(round(real(`lev'_percent) * ssgttlow)) if `lev'_percent != "--"
	gen `lev'_counthigh = string(round(real(`lev'_percent) * ssgtthigh)) if `lev'_percent != "--"
	gen `lev'_count = `lev'_countlow + "-" + `lev'_counthigh if `lev'_countlow != `lev'_counthigh
	replace `lev'_count = `lev'_countlow if `lev'_countlow == `lev'_counthigh
	replace `lev'_count = "--" if `lev'_percent == "--"
	replace `lev'_count = "*" if `lev'_percent == "*"
	drop `lev'_countlow `lev'_counthigh
	replace `lev'_percent = "0-" + `lev'_percent if `lev'_percentfl == 1
	replace `lev'_count = "0-" + `lev'_count if `lev'_percentfl == 1 & strpos(`lev'_count, "-") == 0
	replace `lev'_count = "0-" + substr(`lev'_count, strpos(`lev'_count, "-") + 1, strlen(`lev'_count) - strpos(`lev'_count, "-")) if `lev'_percentfl == 1 & strpos(`lev'_count, "-") != 0
	replace `lev'_percent = `lev'_percent + "-1" if `lev'_percentfh == 1
	replace `lev'_count = `lev'_count + "-" + string(ssgtthigh) if `lev'_percentfh == 1 & strpos(`lev'_count, "-") == 0
	replace `lev'_count = substr(`lev'_count, 1, strpos(`lev'_count, "-") - 1) + "-" + string(ssgtthigh) if `lev'_percentfh == 1 & strpos(`lev'_count, "-") != 0
	drop `lev'_percentfl `lev'_percentfh
}

replace ParticipationRate = "0-" + ParticipationRate if ParticipationRatefl == 1
replace ParticipationRate = ParticipationRate + "-1" if ParticipationRatefh == 1
drop ParticipationRatefl ParticipationRatefh

gen Lev5_count = ""
gen Lev5_percent = ""
tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if AvgScaleScore == "."

//StudentGroup_TotalTested
replace StateAssignedDistID = "000000" if DataLevel== 1
replace StateAssignedSchID = "000000" if DataLevel != 3
egen uniquegrp = group(SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel != 3

//Assessment Information
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2021-22"

//Prepare for NCES Merge
gen State_leaid = "WY-" + StateAssignedDistID
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID

//Separate by Year & Merge with NCES
forvalues fall = 18/23{
	if `fall' == 19 continue
	local spring = `fall' + 1
	preserve
	keep if SchYear == "20`fall'-`spring'"
	
	if `fall' != 23 merge m:1 State_leaid using "${NCES}/NCES_20`fall'_District_WY"
	if `fall' == 23 merge m:1 State_leaid using "${NCES}/NCES_2022_District_WY"
	drop if _merge == 2
	drop _merge
	if `fall' != 23 merge m:1 seasch using "${NCES}/NCES_20`fall'_School_WY"
	if `fall' == 23 merge m:1 seasch using "${NCES}/NCES_2022_School_WY"
	drop if _merge == 2
	drop _merge
	
	gen State = "Wyoming"
	replace StateAbbrev = "WY"
	replace StateFips = 56
	
	*Fixing a School Name
	replace SchName = "Indian Paintbrush Elementary" if SchName == "Indian Paintbrush  Elementary"
	
	*Unmerged Schools & Districts 2024
	if `spring' == 24{
		replace StateAssignedDistID = "5003000" if DistName == "Prairie View Community School"
		replace DistType = "Charter agency" if DistName == "Prairie View Community School"
		replace DistCharter = "Yes" if DistName == "Prairie View Community School"
		replace DistLocale = "Missing/not reported" if DistName == "Prairie View Community School"
		replace NCESSchoolID = "568025900599" if SchName == "Prairie View Community School"
		replace SchType = "Regular school" if SchName == "Prairie View Community School"
		replace SchLevel = "Other" if SchName == "Prairie View Community School"
		replace SchVirtual = "No" if SchName == "Prairie View Community School"
		replace StateAssignedSchID = "5003001" if SchName == "Prairie View Community School"
		replace NCESDistrictID = "5680259" if DistName == "Prairie View Community School"
		replace CountyName = "Platte County" if DistName == "Prairie View Community School"
		replace CountyCode = "56031" if DistName == "Prairie View Community School"
		replace DistType = "Charter agency" if DistName == "Wyoming Classical Academy"
		replace DistCharter = "Yes" if DistName == "Wyoming Classical Academy"
		replace DistLocale = "Missing/not reported" if DistName == "Wyoming Classical Academy"
		replace StateAssignedDistID = "5002000" if DistName == "Wyoming Classical Academy"
		replace CountyName = "Natrona County" if DistName == "Wyoming Classical Academy"
		replace CountyCode = "56025" if DistName == "Wyoming Classical Academy"
		replace SchType = "Regular school" if SchName == "Wyoming Classical Academy"
		replace SchLevel = "Primary" if SchName == "Wyoming Classical Academy"
		replace SchVirtual = "No" if SchName == "Wyoming Classical Academy"
		replace StateAssignedSchID = "5002001" if SchName == "Wyoming Classical Academy"
		replace NCESDistrictID = "5680258" if DistName == "Wyoming Classical Academy"
		replace NCESSchoolID = "568025800598" if SchName == "Wyoming Classical Academy"
	}
	
	*Final Cleaning & Saving
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	append using  "${Output}/WY_AssmtData_20`spring'.dta"
	sort DataLevel DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup
	save "${Output}/WY_AssmtData_20`spring'.dta", replace
	export delimited "${Output}/WY_AssmtData_20`spring'.csv", replace
	restore
}
