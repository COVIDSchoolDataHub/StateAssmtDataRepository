clear
set more off

global raw "/Volumes/T7/State Test Project/New Mexico/Original Data Files"
global output "/Volumes/T7/State Test Project/New Mexico/Output"
global NCES "/Volumes/T7/State Test Project/New Mexico/NCES"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

cd "/Volumes/T7/State Test Project/New Mexico"

use "${raw}/NM_AssmtData_2019_TAMELA.dta", clear
keep if strpos(Assessment, "Grade") > 0
drop if inlist(Assessment, "ELA Grade 9", "ELA Grade 10", "ELA Grade 11")
tostring Code, replace
rename *Name *
drop DistrictCode SchoolCode
append using "${raw}/NM_AssmtData_2019_SBA.dta"
drop if Grade == "11"

** Renaming variables

rename Code StateAssignedSchID
rename District DistName
rename School SchName
rename Level* Lev*_percent

** Replacing/generating variables

gen SchYear = "2018-19"

gen Subject = ""
replace Subject = "sci" if Assessment == ""
replace Subject = "ela" if strpos(Assessment, "ELA") > 0
replace Subject = "math" if strpos(Assessment, "Math") > 0

gen AssmtName = ""
replace AssmtName = "NMSBA" if Subject == "sci"
replace AssmtName = "TAMELA" if Subject != "sci"

gen AssmtType = "Regular"

gen GradeLevel = ""
replace GradeLevel = "G0" + Grade if Grade != ""
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

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

merge m:1 State_leaid using "${NCES}/NCES_2018_District.dta", update replace
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2018_School.dta", update replace
drop if _merge == 1 & DataLevel == 3
drop if _merge == 2
drop _merge

replace StateAbbrev = "NM" if DataLevel == 1
replace State = "New Mexico" if DataLevel == 1
replace StateFips = 35 if DataLevel == 1
replace CountyName = "Dona Ana County" if CountyName == "DoÃ±a Ana County"

** Merging with EDFacts Datasets

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactscount2019districtnewmexico.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop SCHOOL_YEAR-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019districtnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop SCHOOL_YEAR-_merge 

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactscount2019schoolnewmexico.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop SCHOOL_YEAR-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019schoolnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop SCHOOL_YEAR-_merge


destring StudentSubGroup_TotalTested, gen(UnsuppressedSSG_TotalTested) force

// Aggregating to State Level
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

** StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = string(UnsuppressedSSG_TotalTested) if DataLevel == 1 & UnsuppressedSSG_TotalTested !=0
drop UnsuppressedSSG_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

** Generating new variables

gen Flag_AssmtNameChange = "Y"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

drop if missing(State)
save "${output}/NM_AssmtData_2019.dta", replace

** Adding Regular and Alt Data (Disaggregated by SubGroup & GradeLevel) **
use "${raw}/NM_AssmtData_2019_all_RegularAlt.dta", clear

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
gen StateAssignedDistID = StateAssignedSchID if DataLevel == 2
replace StateAssignedDistID = StateAssignedSchID if DataLevel !=1
replace StateAssignedDistID = substr(StateAssignedDistID, 1, strlen(StateAssignedDistID)-3) if DataLevel == 3
replace StateAssignedSchID = substr(StateAssignedSchID,-3,3)
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
*Female
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
*Male
*Migrant
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"

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
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == " "

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

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

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." | missing(ProficientOrAbove_percent)

//ProficientOrAbove_count
gen ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

//NCES Merging
replace StateAssignedDistID = string(real(StateAssignedDistID), "%03.0f")
replace StateAssignedDistID = "" if StateAssignedDistID == "."
gen State_leaid = "NM-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3

merge m:1 State_leaid using "$NCES/NCES_2018_District", gen(DistMerge)
drop if DistMerge == 2
merge m:1 seasch using "$NCES/NCES_2018_School", gen(SchMerge)
drop if SchMerge == 2
drop if SchMerge == 1 & ProficientOrAbove_percent == "--" & DataLevel == 3

drop *Merge sch_lowest State_leaid seasch

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
order State StateAbbrev StateFips DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested ProficientOrAbove_percent ProficientOrAbove_count DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

replace State = "New Mexico"
replace StateAbbrev = "NM"
replace StateFips = 35

** Merging with EDFacts Datasets

gen ParticipationRate = "--"

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactscount2019districtnewmexico.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019districtnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactscount2019schoolnewmexico.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019schoolnewmexico.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge


//Missing & Empty vars
forvalues n = 1/4 {
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}
gen Lev5_count = ""
gen Lev5_percent = ""

gen AvgScaleScore = "--"'

//Indicator Variables
gen ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"

gen Flag_AssmtNameChange = "Y"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

gen AssmtName = ""
replace AssmtName = "NMSBA" if Subject == "sci"
replace AssmtName = "TAMELA" if Subject != "sci"

gen AssmtType = "Regular and alt"

gen SchYear = "2018-19"

//Appending Regular AssmtType Data
append using "$output/NM_AssmtData_2019"

//Deriving ProficientOrAbove_percent if we have Levels 1-3 for ela/math or Levels 1-2 for sci
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent)-real(Lev3_percent), "%9.3g") if !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev3_percent)) & missing(real(ProficientOrAbove_percent)) & Subject != "sci"
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(ProficientOrAbove_percent)) & Subject == "sci"

//Applying Final Count Derivations
foreach count of varlist *_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
	replace `count' = string(round(real(substr(`percent',1,strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if regexm(`percent', "[0-9]") !=0 & strpos(`percent', "-") !=0 & !missing(real(StudentSubGroup_TotalTested))
}

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
keep DataLevel NCESDistrictID NCESSchoolID DistName SchName
tempfile names
save "`names'", replace
use "`temp1'", clear
merge m:1 DataLevel NCESDistrictID NCESSchoolID using "`names'", update replace gen(Updated_Names)

//Roots & Wings Community Charter
** Weird Observations. Unmerged in Regular and alt. Seems to match with "Roots & Wings Community" in Regular, but classified as part of a different district.
replace DistName = "Roots And Wings Community" if SchName == "Roots & Wings Community Charter"
replace SchName = "Roots & Wings Community" if SchName == "Roots & Wings Community Charter"
replace NCESDistrictID = "3500176" if SchName == "Roots & Wings Community"
replace StateAssignedDistID = "570" if SchName == "Roots & Wings Community"
replace NCESSchoolID = "350017600846" if SchName == "Roots & Wings Community"
replace StateAssignedSchID = "001" if SchName == "Roots & Wings Community"
replace DistType = "Charter agency" if SchName == "Roots & Wings Community"
replace DistCharter = "Yes" if SchName == "Roots & Wings Community"
replace SchType = 1 if SchName == "Roots & Wings Community"
replace SchLevel = 1 if SchName == "Roots & Wings Community"
replace SchVirtual = 0 if SchName == "Roots & Wings Community"


//Final Cleaning
replace CountyName = "Dona Ana County" if CountyName == "DoÃ±a Ana County"

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName AssmtType Subject GradeLevel StudentGroup StudentSubGroup

save "$output/NM_AssmtData_2019", replace
export delimited "$output/NM_AssmtData_2019", replace
