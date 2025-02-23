*******************************************************
* NEW MEXICO

* File name: 04_New Mexico 2018 Cleaning
* Last update: 2/20/2025

*******************************************************
* Description: This file cleans all New Mexico Original Data for 2018.

*******************************************************

clear all
set more off

use "${raw}/NM_AssmtData_2018_PARCC.dta", clear
keep if strpos(Assessment, "Grade") > 0
drop if inlist(Assessment, "ELA Grade 9", "ELA Grade 10", "ELA Grade 11")
tostring Code, replace
append using "${raw}/NM_AssmtData_2018_SBA.dta"
drop if Grade == 11

** Renaming variables

rename Code StateAssignedSchID
rename District DistName
rename School SchName
rename Level* Lev*_percent

** Replacing/generating variables

gen SchYear = "2017-18"

gen Subject = ""
replace Subject = "sci" if Assessment == ""
replace Subject = "ela" if strpos(Assessment, "ELA") > 0
replace Subject = "math" if strpos(Assessment, "Math") > 0

gen AssmtName = ""
replace AssmtName = "NMSBA" if Subject == "sci"
replace AssmtName = "PARCC" if Subject != "sci"

gen AssmtType = "Regular"

gen GradeLevel = ""
tostring Grade, replace
replace GradeLevel = "G0" + Grade if Grade != "."
replace Assessment = subinstr(Assessment, "Math Grade ", "", .)
replace Assessment = subinstr(Assessment, "ELA Grade ", "", .)
replace GradeLevel = "G0" + Assessment if Assessment != ""
drop Grade Assessment

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "Districtwide"
replace DataLevel = "State" if DistName == "Statewide"

gen StateAssignedDistID = StateAssignedSchID if DataLevel != "State"
replace StateAssignedDistID = substr(StateAssignedDistID, 1, 3) if strlen(StateAssignedDistID) == 6
replace StateAssignedDistID = "0" + substr(StateAssignedDistID, 1, 2) if strlen(StateAssignedDistID) == 5
replace StateAssignedDistID = "00" + substr(StateAssignedDistID, 1, 1) if strlen(StateAssignedDistID) == 4
replace StateAssignedDistID = "0" + substr(StateAssignedDistID, 1, 2) if strlen(StateAssignedDistID) == 2
replace StateAssignedDistID = "00" + substr(StateAssignedDistID, 1, 1) if strlen(StateAssignedDistID) == 1
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

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4 5
foreach a of local level {
	split Lev`a'_percent, parse("-")
	destring Lev`a'_percent1, replace force
	replace Lev`a'_percent1 = Lev`a'_percent1/100
	tostring Lev`a'_percent1, replace format("%9.2g") force
	destring Lev`a'_percent2, replace force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	tostring Lev`a'_percent2, replace format("%9.2g") force
	replace Lev`a'_percent = Lev`a'_percent1 if Lev`a'_percent1 != "." & Lev`a'_percent2 == "."
	replace Lev`a'_percent = Lev`a'_percent1 + "-" + Lev`a'_percent2 if Lev`a'_percent1 != "." & Lev`a'_percent2 != "."
	gen Lev`a'_percent3 = subinstr(Lev`a'_percent, "≤ ", "", .) if strpos(Lev`a'_percent, "≤ ") > 0
	replace Lev`a'_percent3 = subinstr(Lev`a'_percent, "≥ ", "", .) if strpos(Lev`a'_percent, "≥ ") > 0
	destring Lev`a'_percent3, replace force
	replace Lev`a'_percent3 = Lev`a'_percent3/100
	tostring Lev`a'_percent3, replace format("%9.2g") force
	replace Lev`a'_percent = "0-" + Lev`a'_percent3 if strpos(Lev`a'_percent, "≤ ") > 0
	replace Lev`a'_percent = Lev`a'_percent3 + "-1" if strpos(Lev`a'_percent, "≥ ") > 0
	drop Lev`a'_percent1 Lev`a'_percent2 Lev`a'_percent3
	replace Lev`a'_percent = "*" if Lev`a'_percent == "^"
	gen Lev`a'_count = "--"
}

replace Lev5_count = "" if Subject == "sci"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"

gen ProficientOrAbove_count = "--"

foreach a of local level {
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
}

gen ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2 if Subject == "sci"
replace ProficientOrAbove_percent = Lev4_percent2 + Lev5_percent2 if Subject != "sci"
tostring ProficientOrAbove_percent, replace format("%9.2g") force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." & Subject == "sci" & Lev3_percent != "*" & Lev4_percent != "*"
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." & Subject != "sci" & Lev4_percent != "*" & Lev5_percent != "*"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

foreach a of local level {
	drop Lev`a'_percent2
}

forvalues n = 3/5{
	split Lev`n'_percent, parse("-")
	destring Lev`n'_percent1, replace force
	destring Lev`n'_percent2, replace force
	replace Lev`n'_percent2 = 0 if Lev`n'_percent2 == . & Lev`n'_percent1 != .
}

replace ProficientOrAbove_percent = string(Lev4_percent1 + Lev5_percent1, "%9.3g") + "-" + string(Lev4_percent2 + Lev5_percent2, "%9.3g") if inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(Lev5_percent, "*", "--") & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_percent = string(Lev3_percent1 + Lev4_percent1, "%9.3g") + "-" + string(Lev3_percent2 + Lev4_percent2, "%9.3g") if inlist(ProficientOrAbove_percent, "*", "--") & !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & ProficiencyCriteria == "Levels 3-4"
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "-0", "", 1)

//Deriving ProficientOrAbove_percent if we have Levels 1-3 for ela/math or Levels 1-2 for sci
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent)-real(Lev3_percent), "%9.3g") if !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev3_percent)) & missing(real(ProficientOrAbove_percent)) & Subject != "sci"
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(ProficientOrAbove_percent)) & Subject == "sci"

//Deriving Specific Values for Lev5 Ranges
replace Lev5_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent), "%9.3g") if missing(real(Lev5_percent)) & strpos(ProficientOrAbove_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & !missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if missing(real(Lev5_percent)) & strpos(ProficientOrAbove_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & !missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0 & ProficiencyCriteria == "Levels 4-5"

//Correcting A Few Specific Obs with Odd Values due to Ranges
replace ProficientOrAbove_percent = ".9-1" if ProficientOrAbove_percent == ".9-1.08"
replace ProficientOrAbove_percent = ".91-1" if ProficientOrAbove_percent == ".91-1.08"
replace ProficientOrAbove_percent = ".95-1" if ProficientOrAbove_percent == ".95-1.03"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

merge m:1 State_leaid using "${NCES}/NCES_2017_District_NM.dta", update replace
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2017_School_NM.dta", update replace
drop if _merge == 2
drop _merge

replace StateAbbrev = "NM" if DataLevel == 1
replace State = "New Mexico" if DataLevel == 1
replace StateFips = 35 if DataLevel == 1
replace CountyName = "Dona Ana County" if CountyName == "DoÃ±a Ana County"

** Merging with EDFacts Datasets

*NO DISTRICT LEVEL COUNTS FOR NM in 2018 (and no counts for ela in addition to sci)

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2018/edfactspart2018districtnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2018/edfactscount2018schoolnewmexico.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2018/edfactspart2018schoolnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG_TotalTested) force

// Aggregating counts to District Level
tempfile temp1
save "`temp1'", replace
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear

use "`temp1'"
collapse (sum) UnsuppressedSSG_TotalTested if DataLevel == 3, by(NCESDistrictID GradeLevel Subject StudentSubGroup)
merge 1:1 NCESDistrictID GradeLevel Subject StudentSubGroup using "`tempdist'", update nogen
save "`tempdist'", replace
clear
use "`temp1'"
keep if DataLevel !=2
append using "`tempdist'"
sort DataLevel


// Aggregating counts to State Level
tempfile temp1
save "`temp1'", replace
keep if DataLevel == 1
tempfile tempstate
save "`tempstate'", replace
clear

use "`temp1'"
collapse (sum) UnsuppressedSSG_TotalTested if DataLevel == 3, by(GradeLevel Subject StudentSubGroup)
merge 1:1 GradeLevel Subject StudentSubGroup using "`tempstate'", update
save "`tempstate'", replace
use "`temp1'"
keep if DataLevel !=1
append using "`tempstate'"
sort DataLevel
** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

** StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = string(UnsuppressedSSG_TotalTested) if DataLevel == 1 & UnsuppressedSSG_TotalTested !=0
drop UnsuppressedSSG_TotalTested

//Applying Count Derivations
forvalues n = 1/5 {
	replace Lev`n'_count = string(round(real(Lev`n'_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(Lev`n'_percent)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(Lev`n'_count))
	replace Lev`n'_count = string(round(real(substr(Lev`n'_percent,1,strpos(Lev`n'_percent, "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(Lev`n'_percent,strpos(Lev`n'_percent, "-")+1,5))*real(StudentSubGroup_TotalTested))) if regexm(Lev`n'_percent, "[0-9]") !=0 & strpos(Lev`n'_percent, "-") !=0 & !missing(real(StudentSubGroup_TotalTested))
	replace Lev`n'_count = "0" if Lev`n'_count == "0-0"
}

//Additional Derivations
forvalues n = 3/5{
	split Lev`n'_count, parse("-")
	destring Lev`n'_count1, replace force
	destring Lev`n'_count2, replace force
	replace Lev`n'_count2 = 0 if Lev`n'_count2 == . & Lev`n'_count1 != .
}

replace ProficientOrAbove_count = string(Lev4_count1 + Lev5_count1) + "-" + string(Lev4_count2 + Lev5_count2) if inlist(ProficientOrAbove_count, "*", "--") & !inlist(Lev4_count, "*", "--") & !inlist(Lev5_count, "*", "--") & ProficiencyCriteria == "Levels 4-5"

replace ProficientOrAbove_count = string(Lev3_count1 + Lev4_count1) + "-" + string(Lev3_count2 + Lev4_count2) if inlist(ProficientOrAbove_count, "*", "--") & !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--") & ProficiencyCriteria == "Levels 3-4"

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if inlist(ProficientOrAbove_count, "*", "--") & !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested))
replace ProficientOrAbove_count = string(round(real(substr(ProficientOrAbove_percent,1,strpos(ProficientOrAbove_percent, "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(ProficientOrAbove_percent,strpos(ProficientOrAbove_percent, "-")+1,5))*real(StudentSubGroup_TotalTested))) if regexm(ProficientOrAbove_percent, "[0-9]") !=0 & strpos(ProficientOrAbove_percent, "-") !=0 & !missing(real(StudentSubGroup_TotalTested)) & inlist(ProficientOrAbove_count, "*", "--")

replace ProficientOrAbove_count = subinstr(ProficientOrAbove_count, "-0", "", 1)
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") != 0

replace Lev4_count = "0" if ProficientOrAbove_count == "0" & strpos(Lev4_count, "0-") ==1
replace Lev5_count = "0" if ProficientOrAbove_count == "0" & ProficiencyCriteria == "Levels 4-5" & strpos(Lev5_count, "0-") ==1
replace Lev3_count = "0" if ProficientOrAbove_count == "0" & ProficiencyCriteria == "Levels 3-4" & strpos(Lev3_count, "0-") ==1

replace Lev4_percent = "0" if ProficientOrAbove_percent == "0" & strpos(Lev4_percent, "0-") ==1
replace Lev5_percent = "0" if ProficientOrAbove_percent == "0" & ProficiencyCriteria == "Levels 4-5" & strpos(Lev5_percent, "0-") ==1
replace Lev3_percent = "0" if ProficientOrAbove_percent == "0" & ProficiencyCriteria == "Levels 3-4" & strpos(Lev3_percent, "0-") ==1

//Correcting A Few Specific Obs with Odd Values due to Ranges
replace ProficientOrAbove_percent = ".9-1" if ProficientOrAbove_percent == ".9-1.08"
replace ProficientOrAbove_percent = ".91-1" if ProficientOrAbove_percent == ".91-1.08"
replace ProficientOrAbove_percent = ".95-1" if ProficientOrAbove_percent == ".95-1.03"

drop if missing(State)
save "${output}/NM_AssmtData_2018.dta", replace

** Adding Regular and Alt Data (Disaggregated by SubGroup & GradeLevel) **
use "${raw}/NM_AssmtData_2018_all_RegularAlt.dta", clear

//Renaming
rename Code StateAssignedSchID
rename StateorDistrict DistName
rename School SchName
rename Grade GradeLevel
rename Group StudentSubGroup
rename Count StudentSubGroup_TotalTestedela
rename ProficientAbove ProficientOrAbove_percentela
rename I StudentSubGroup_TotalTestedmath
rename J ProficientOrAbove_percentmath
rename K StudentSubGroup_TotalTestedsci
rename L ProficientOrAbove_percentsci

//Reshaping
reshape long StudentSubGroup_TotalTested ProficientOrAbove_percent, i(StateAssignedSchID GradeLevel StudentSubGroup) j(Subject, string)

//DataLevel
gen DataLevel =.
replace DataLevel = 1 if DistName == "Statewide"
replace DataLevel = 2 if SchName == "Districtwide"
replace DataLevel = 3 if missing(DataLevel)
label def DataLevel 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel
sort DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Fixing ID's
tostring StateAssignedSchID, replace
drop if DistName == "State Charters" //these are effectivley duplicate observations
gen StateAssignedDistID = StateAssignedSchID if DataLevel == 2
replace StateAssignedDistID = StateAssignedSchID if DataLevel !=1
replace StateAssignedDistID = substr(StateAssignedDistID, 1, strlen(StateAssignedDistID)-3) if DataLevel == 3
replace StateAssignedSchID = substr(StateAssignedSchID,-3,3)
replace StateAssignedSchID = "022" if StateAssignedSchID == "001" & SchName == "Horizon Academy West" //correcting for an incorrect merge
replace StateAssignedSchID = "" if DataLevel !=3

//GradeLevel
drop if real(GradeLevel) < 3 | real(GradeLevel) > 8
replace GradeLevel = "G0" + GradeLevel

//StudentSubGroup

*All Students
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
*Asian
replace StudentSubGroup = "White" if StudentSubGroup == "Caucasian"
*Economically Disadvantaged
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners, Current"
*Female
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
*Male
*Migrant
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students w Disabilities"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "." | strpos(StudentSubGroup_TotalTested, "-") !=0

//ProficientOrAbove_percent
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≤", "<",.)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≥", ">",.)

foreach var of varlist ProficientOrAbove_percent {
replace `var' = subinstr(`var'," ", "",.)
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i("*%<>=-")
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
drop range`var' n`var'
}

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." | ProficientOrAbove_percent == "-"

//ProficientOrAbove_count
gen ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

//NCES Merging
replace StateAssignedDistID = string(real(StateAssignedDistID), "%03.0f")
replace StateAssignedDistID = "" if StateAssignedDistID == "."
gen State_leaid = "NM-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3

merge m:1 State_leaid using "$NCES/NCES_2017_District_NM", gen(DistMerge)
drop if DistMerge == 2
merge m:1 seasch using "$NCES/NCES_2017_School_NM", gen(SchMerge)
drop if SchMerge == 2
drop if SchMerge == 1 & ProficientOrAbove_percent == "--" & DataLevel == 3

drop *Merge sch_lowest State_leaid seasch

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
order State StateAbbrev StateFips DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested ProficientOrAbove_percent ProficientOrAbove_count DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

replace State = "New Mexico"
replace StateAbbrev = "NM"
replace StateFips = 35

** Merging with EDFacts Datasets

gen ParticipationRate = "--"

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2018/edfactscount2018districtnewmexico.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "." & inlist(StudentSubGroup_TotalTested, "*", "--")
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2018/edfactspart2018districtnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2018/edfactscount2018schoolnewmexico.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."  & inlist(StudentSubGroup_TotalTested, "*", "--")
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2018/edfactspart2018schoolnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

replace ParticipationRate = ".98" if ParticipationRate == "98"
replace ParticipationRate = ".8-.89" if ParticipationRate == "80-89"
replace ParticipationRate = ".85-.89" if ParticipationRate == "85-89"
replace ParticipationRate = ".9-.94" if ParticipationRate == "90-94"

//Missing & Empty vars
forvalues n = 1/5 {
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}
replace Lev5_count = "" if Subject == "sci"
replace Lev5_percent = "" if Subject == "sci"

gen AvgScaleScore = "--"

//Indicator Variables
gen ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

gen AssmtName = ""
replace AssmtName = "NMSBA & NMAPA" if Subject == "sci"
replace AssmtName = "PARCC & NMAPA" if Subject != "sci"

gen AssmtType = "Regular and alt"

gen SchYear = "2017-18"

//ProficientOrAbove_count
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if inlist(ProficientOrAbove_count, "*", "--") & !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested))
replace ProficientOrAbove_count = string(round(real(substr(ProficientOrAbove_percent,1,strpos(ProficientOrAbove_percent, "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(ProficientOrAbove_percent,strpos(ProficientOrAbove_percent, "-")+1,5))*real(StudentSubGroup_TotalTested))) if regexm(ProficientOrAbove_percent, "[0-9]") !=0 & strpos(ProficientOrAbove_percent, "-") !=0 & !missing(real(StudentSubGroup_TotalTested)) & inlist(ProficientOrAbove_count, "*", "--")

//Appending Regular AssmtType Data
append using "$output/NM_AssmtData_2018"

//Standardizing Entity Names
tempfile temp1
save "`temp1'", replace
gsort -AssmtType
duplicates drop DistName StateAssignedDistID SchName StateAssignedSchID, force
duplicates drop NCESDistrictID if DataLevel == 2, force
duplicates drop NCESSchoolID if DataLevel == 3, force
foreach var of varlist DistName SchName {
	replace `var' = proper(`var')
}
keep NCESDistrictID NCESSchoolID DistName SchName
tempfile names
save "`names'", replace
use "`temp1'", clear
merge m:1 NCESDistrictID NCESSchoolID using "`names'", update replace gen(Updated_Names)

//StudentGroup_TotalTested
sort DataLevel DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving Additional Values of StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
gen missing_ssgtt = 1 if nStudentSubGroup_TotalTested == .
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen missing_multiple = total(missing_ssgtt)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID AssmtType GradeLevel Subject: egen RaceEth = total(nStudentSubGroup_TotalTested) if StudentGroup == "RaceEth" & StudentSubGroup != "Hispanic or Latino"
bysort StateAssignedDistID StateAssignedSchID AssmtType GradeLevel Subject: egen Gender = total(nStudentSubGroup_TotalTested) if StudentGroup == "Gender"

replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & max != 0 & nStudentSubGroup_TotalTested == . & RaceEth != 0 & StudentSubGroup != "Hispanic or Latino" & missing_multiple == 1
replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & nStudentSubGroup_TotalTested == . & Gender != 0 & missing_multiple == 1
drop RaceEth Gender max nStudentSubGroup_TotalTested

drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

//Final Cleaning
replace CountyName = "Dona Ana County" if CountyName == "DoÃ±a Ana County"

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup

save "$output/NM_AssmtData_2018", replace
export delimited "$output/NM_AssmtData_2018", replace

* End of 04_New Mexico 2018 Cleaning
