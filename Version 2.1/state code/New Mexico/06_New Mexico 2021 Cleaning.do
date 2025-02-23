*******************************************************
* NEW MEXICO

* File name: 06_New Mexico 2021 Cleaning
* Last update: 2/20/2025

*******************************************************
* Description: This file cleans all New Mexico Original Data for 2021.

*******************************************************

clear
set more off

use "${raw}/NM_AssmtData_2021_MSSA.dta", clear

drop SortCode
*drop if inlist(Group, "ED", "Foster", "Homeless", "Migrant", "Military", "SwD")
drop if Group == "ED"

** Renaming variables

rename Code StateAssignedSchID
rename StateorDistrict DistName
rename School SchName
rename Group StudentSubGroup
rename Count StudentSubGroup_TotalTestedela
rename ProficientAbove ProficientOrAbove_percentela
rename H StudentSubGroup_TotalTestedmath
rename I ProficientOrAbove_percentmath

** Reshape

reshape long StudentSubGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject) string

** Replacing/generating variables

gen SchYear = "2020-21"

gen AssmtName = "NM-MSSA"

gen AssmtType = "Regular"

gen GradeLevel = "G38"

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "Districtwide"
replace DataLevel = "State" if DistName == "Statewide"

gen StateAssignedDistID = StateAssignedSchID if DataLevel != "State"
replace StateAssignedDistID = substr(StateAssignedDistID, 1, 3) if strlen(StateAssignedDistID) == 6
replace StateAssignedDistID = "0" + substr(StateAssignedDistID, 1, 2) if strlen(StateAssignedDistID) == 5
replace StateAssignedDistID = "00" + substr(StateAssignedDistID, 1, 1) if strlen(StateAssignedDistID) == 4
gen State_leaid = StateAssignedDistID
replace State_leaid = "NM-" + State_leaid
replace State_leaid = "" if DataLevel == "State"

replace StateAssignedSchID = substr(StateAssignedSchID, 2, 3) if strlen(StateAssignedSchID) == 4
replace StateAssignedSchID = substr(StateAssignedSchID, 3, 3) if strlen(StateAssignedSchID) == 5
replace StateAssignedSchID = substr(StateAssignedSchID, 4, 3) if strlen(StateAssignedSchID) == 6
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID
replace seasch = "" if DataLevel != "School"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "FRL"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "SWD" if StudentSubGroup == "SwD"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == ""
replace ProficientOrAbove_percent = "0-0.20" if ProficientOrAbove_percent == "≤ 20"
replace ProficientOrAbove_percent = "0.80-1" if ProficientOrAbove_percent == "≥ 80"

local level 1 2 3 4
foreach a of local level {
	gen Lev`a'_percent = "--"
	gen Lev`a'_count = "--"
}

gen Lev5_percent = ""
gen Lev5_count = ""


gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"

gen ProficientOrAbove_count = "--"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

merge m:1 State_leaid using "${NCES}/NCES_2020_District_NM.dta", update replace
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2020_School_NM.dta", update replace
drop if _merge == 2
drop _merge

replace StateAbbrev = "NM" if DataLevel == 1
replace State = "New Mexico" if DataLevel == 1
replace StateFips = 35 if DataLevel == 1
replace CountyName = "Dona Ana County" if CountyName == "DoÃ±a Ana County"
drop if sch_lowest_grade_offered >=9 & !missing(sch_lowest_grade_offered)
drop if SchLevel == 0
drop sch_lowest_grade_offered

** Generating new variables

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

** Saving ela & math data
save "${output}/NM_AssmtData_2021.dta", replace

** Adding Science Data from Data request **

use "$raw/NM_AssmtData_2021_ASR.dta", clear
keep *science* SchNumb
foreach var of varlist _all {
if "`var'" == "SchNumb" continue	
local label: variable label `var'
local newlabel = subinstr("`label'","stud_","",.)
local newlabel = subinstr("`newlabel'","_science_","",.)
rename `var' `newlabel'
}
reshape long proficiency participation, i(SchNumb) j(StudentSubGroup, string)
gen Subject = "sci"

//Renaming
rename SchNumb StateAssignedSchID
rename proficiency ProficientOrAbove_percent
rename participation ParticipationRate

//DataLevel 
gen DataLevel = "State" if StateAssignedSchID == 999999
replace DataLevel = "District" if StateAssignedSchID <1000
replace DataLevel = "School" if StateAssignedSchID >=1000 & StateAssignedSchID != 999999
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

//Fixing ID's
tostring StateAssignedSchID, replace
gen StateAssignedDistID = StateAssignedSchID if DataLevel == 2
replace StateAssignedDistID = StateAssignedSchID if DataLevel !=1
replace StateAssignedDistID = substr(StateAssignedDistID, 1, strlen(StateAssignedDistID)-3) if DataLevel == 3
replace StateAssignedSchID = substr(StateAssignedSchID,-3,3)
replace StateAssignedSchID = "" if DataLevel !=3

//StudentSubGroup
replace StudentSubGroup = proper(StudentSubGroup)
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African_Amer"
replace StudentSubGroup = "All Students" if StudentSubGroup == "Allstudents"
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Ell"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multirace"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native_Amer"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Frl"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Cleaning Percents
foreach var of varlist ProficientOrAbove_percent ParticipationRate {
replace `var' = string(real(`var')/100, "%9.3g") if regexm(`var', "[A-Z]") ==0 & !missing(`var')
replace `var' = "0-.05" if `var' == "LE 5%"
replace `var' = ".95-1" if `var' == "GE 95%"
replace `var' = "--" if missing(`var')
}

//Merging NCES
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
gen State_leaid = "NM-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3
merge m:1 State_leaid using "$NCES/NCES_2020_District_NM", keep(match master)
**Missing Districts have no match in data request file
drop if _merge == 1 & DataLevel !=1
drop _merge
merge m:1 seasch using "$NCES/NCES_2020_School_NM", keep(match master)
**Missing Schools have no match in data request file
drop if _merge == 1 & DataLevel == 3
drop _merge

//Dropping pre-k & high schools
drop if sch_lowest_grade_offered >= 9 & !missing(sch_lowest_grade_offered)
drop sch_lowest_grade_offered
drop if SchLevel == 0

//Indicator and Missing Variables
gen GradeLevel = "GZ"
gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
forvalues n = 1/4 {
	gen Lev`n'_percent = "--"
	gen Lev`n'_count = "--"
}
gen Lev5_count = ""
gen Lev5_percent = ""
replace State = "New Mexico"
replace StateFips = 35
replace StateAbbrev = "NM"
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
gen AvgScaleScore = "--"
gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"
gen AssmtName = "NM-ASR & Dynamic Learning Maps"
gen AssmtType = "Regular and alt"
gen SchYear = "2020-21"
**Flags
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

//Fixing Some Variables
replace CountyName = "Dona Ana County" if CountyName == "DoÃ±a Ana County"

//Appending
append using "${output}/NM_AssmtData_2021.dta"

//Deriving ProficientOrAbove_percent Where Possible
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(real(Lev1_percent)) & !missing(real(Lev2_percent))
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") !=0

//Standardizing Names
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)

** Deriving Count Ranges where possible
foreach count of varlist *_count {
	local percent = subinstr("`count'","count","percent",.)
	replace `count' = string(round(real(substr(`percent',1,strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if regexm(`percent', "[0-9]") !=0 & strpos(`percent', "-") !=0 & !missing(real(StudentSubGroup_TotalTested))
}

//Deriving Counts Where Possible
foreach count of varlist *_count {
local percent = subinstr("`count'", "count","percent",.)
replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if regexm(`count', "[0-9]") == 0 & regexm(`percent', "-") == 0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

forvalues n = 3/4{
	split Lev`n'_percent, parse("-")
	destring Lev`n'_percent1, replace force
	destring Lev`n'_percent2, replace force
	replace Lev`n'_percent2 = 0 if Lev`n'_percent2 == . & Lev`n'_percent1 != .
	split Lev`n'_count, parse("-")
	destring Lev`n'_count1, replace force
	destring Lev`n'_count2, replace force
	replace Lev`n'_count2 = 0 if Lev`n'_count2 == . & Lev`n'_count1 != .
}

replace ProficientOrAbove_count = string(Lev3_count1 + Lev4_count1) + "-" + string(Lev3_count2 + Lev4_count2) if inlist(ProficientOrAbove_count, "*", "--") & !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--")
replace ProficientOrAbove_percent = string(Lev3_percent1 + Lev4_percent1) + "-" + string(Lev3_percent2 + Lev4_percent2) if inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--")

//Deriving Additional Values of StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
gen missing_ssgtt = 1 if nStudentSubGroup_TotalTested == .
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen missing_multiple = total(missing_ssgtt)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID AssmtType GradeLevel Subject: egen RaceEth = total(nStudentSubGroup_TotalTested) if StudentGroup == "RaceEth" & StudentSubGroup != "Hispanic or Latino"
bysort StateAssignedDistID StateAssignedSchID AssmtType GradeLevel Subject: egen Gender = total(nStudentSubGroup_TotalTested) if StudentGroup == "Gender"

replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & StudentSubGroup != "Hispanic or Latino" & max != 0 & nStudentSubGroup_TotalTested == . & RaceEth != 0 & missing_multiple == 1
replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & nStudentSubGroup_TotalTested == . & Gender != 0
drop RaceEth Gender missing_ssgtt missing_multiple max nStudentSubGroup_TotalTested

drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

//Deriving ProficientOrAbove_count from SSGTT
split ProficientOrAbove_percent, parse("-")
destring ProficientOrAbove_percent1, replace force
destring ProficientOrAbove_percent2, replace
replace ProficientOrAbove_count = string(round(real(StudentSubGroup_TotalTested) * ProficientOrAbove_percent1)) if inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 == .
replace ProficientOrAbove_count = string(round(real(StudentSubGroup_TotalTested) * ProficientOrAbove_percent1)) + "-" + string(round(real(StudentSubGroup_TotalTested) * ProficientOrAbove_percent2)) if inlist(ProficientOrAbove_count, "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--") & ProficientOrAbove_percent1 != . & ProficientOrAbove_percent2 != .
replace ProficientOrAbove_count = "0" if ProficientOrAbove_count == "0-0"
replace ProficientOrAbove_percent = "0-.2" if ProficientOrAbove_percent == "0-0.20"

//Final cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NM_AssmtData_2021.dta", replace
export delimited "${output}/NM_AssmtData_2021.csv", replace


* End of 06_New Mexico 2021 Cleaning

