clear
set more off

global output "/Volumes/T7/State Test Project/Michigan/Original Data"
global NCES "/Volumes/T7/State Test Project/Michigan/NCES"

cd "/Volumes/T7/State Test Project/Michigan"

use "${output}/MI_AssmtData_2021_all.dta", clear

** Rename existing variables

rename SchoolYear SchYear
rename TestType AssmtName
rename DistrictCode State_leaid
rename DistrictName DistName
rename BuildingCode seasch
rename BuildingName SchName
rename GradeContentTested GradeLevel
rename ReportCategory StudentSubGroup
rename TotalAdvanced Lev4_count
rename TotalProficient Lev3_count
rename TotalPartiallyProficient Lev2_count
rename TotalNotProficient Lev1_count
rename TotalMet ProficientOrAbove_count
rename NumberAssessed StudentSubGroup_TotalTested
rename PercentAdvanced Lev4_percent
rename PercentProficient Lev3_percent
rename PercentPartiallyProficient Lev2_percent
rename PercentNotProficient Lev1_percent
rename PercentMet ProficientOrAbove_percent
rename AvgSS AvgScaleScore

** Dropping entries

keep if AssmtName == "M-STEP" | AssmtName == "PSAT"
drop if ISDName != "Statewide" & DistName == "All Districts"
/// drop if StudentSubGroup == "Students With Disabilities" | StudentSubGroup == "Students Without Disabilities"

** Dropping extra variables

drop TestPopulation ISDCode ISDName CountyCode CountyName EntityType SchoolLevel Locale MISTEM_NAME MISTEM_CODE TotalSurpassed TotalAttained TotalEmergingTowards PercentSurpassed PercentAttained PercentEmergingTowards PercentDidNotMeet StdDevSS MeanPtsEarned MinScaleScore MaxScaleScore ScaleScore25 ScaleScore50 ScaleScore75

** Changing DataLevel

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "All Buildings"
replace DataLevel = "State" if DistName == "All Districts"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Replacing variables

replace SchYear = "2020-21"

replace SchName = "All Schools" if DataLevel != 3

replace Subject = "ela" if Subject == "ELA" 
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

tostring GradeLevel, replace
replace GradeLevel = "G03" if GradeLevel == "3"
replace GradeLevel = "G04" if GradeLevel == "4"
replace GradeLevel = "G05" if GradeLevel == "5"
replace GradeLevel = "G06" if GradeLevel == "6"
replace GradeLevel = "G07" if GradeLevel == "7"
replace GradeLevel = "G08" if GradeLevel == "8"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic of Any Race"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learners"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students With Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students Without Disabilities"

** Generating new variables

gen AssmtType = "Regular"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Female" | StudentSubGroup == "Male"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"

gen StudentSubGroup_TotalTested2 = StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"

gen ParticipationRate = "--"

** Converting Data to String

local level 1 2 3 4

foreach a of local level {
	gen Lev`a'_percent2 = Lev`a'_percent
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,"%","",.)
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,"<=","",.)	
	replace Lev`a'_percent2 = subinstr(Lev`a'_percent2,">=","",.)
	destring Lev`a'_percent2, replace force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2 if strpos(Lev`a'_percent, "%") == 0
	replace Lev`a'_percent = "<=" + Lev`a'_percent2 if strpos(Lev`a'_percent, "<") > 0
	replace Lev`a'_percent = ">=" + Lev`a'_percent2 if strpos(Lev`a'_percent, ">") > 0
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
	drop Lev`a'_percent2
	}

gen test = ""
replace test = "less" if strpos(ProficientOrAbove_percent, "<") > 0
replace test = "greater" if strpos(ProficientOrAbove_percent, ">") > 0
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,"%","",.)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,"<=","",.)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,">=","",.)
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "<=" + ProficientOrAbove_percent if test == "less"
replace ProficientOrAbove_percent = ">=" + ProficientOrAbove_percent if test == "greater"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
drop test

** Merging with NCES

tostring State_leaid, gen(StateAssignedDistID)
replace StateAssignedDistID = "" if DataLevel == 1

gen leadingzero = 1 if State_leaid < 10000
tostring State_leaid, replace
replace State_leaid = "0" + State_leaid if leadingzero == 1
drop leadingzero
replace State_leaid = "MI-" + State_leaid
replace State_leaid = "" if DataLevel == 1

merge m:1 State_leaid using "${NCES}/NCES_2020_District.dta"

drop if _merge == 2
drop _merge

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta", update

drop if _merge == 2
drop _merge

tostring seasch, gen(StateAssignedSchID)
replace StateAssignedSchID = "" if DataLevel != 3

gen leadingzero = 1 if seasch < 10000
replace leadingzero = 2 if seasch < 1000
replace leadingzero = 3 if seasch < 100
replace leadingzero = 4 if seasch < 10
tostring seasch, replace
replace seasch = "0" + seasch if leadingzero == 1
replace seasch = "00" + seasch if leadingzero == 2
replace seasch = "000" + seasch if leadingzero == 3
replace seasch = "0000" + seasch if leadingzero == 4
drop leadingzero
replace seasch = State_leaid + "-" + seasch
replace seasch = subinstr(seasch,"MI-","",.)
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2020_School.dta"

drop if _merge == 2
drop _merge

replace NCESSchoolID = "260113908944" if seasch == "82773-03724"

merge m:1 NCESSchoolID using "${NCES}/NCES_2021_School.dta", update

drop if _merge == 2
drop _merge

drop State
replace StateAbbrev = "MI"
gen State = "Michigan"
destring StateFips, replace
replace StateFips = 26

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
/// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "Y" //Changed 9/30/24

foreach v of varlist SchType SchLevel SchVirtual {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	
//////////////////
*COUNT GENERATION*
//////////////////

destring StudentGroup_TotalTested, gen(total_count) ignore("*")
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen All = max(total_count)

* drop if StudentGroup=="All Students" & All ==.
destring StudentSubGroup_TotalTested, gen(Count_n) ignore("<10")
replace Count_n=0 if StudentSubGroup_TotalTested == "<10"
* drop All total_count

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = sum(Count_n) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = sum(Count_n) if StudentGroup == "Disability Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Eng = sum(Count_n) if StudentGroup == "EL Status"

gen not_count=.

replace not_count = All - Econ if StudentSubGroup == "Economically Disadvantaged"
replace not_count = All - Disability if StudentSubGroup == "SWD"
replace not_count = All - Eng if StudentSubGroup == "English Learner"

tostring not_count, replace

replace StudentSubGroup_TotalTested=not_count if StudentSubGroup_TotalTested=="<10" & StudentSubGroup == "Economically Disadvantaged"
replace StudentSubGroup_TotalTested=not_count if StudentSubGroup_TotalTested=="<10" & StudentSubGroup == "SWD"
replace StudentSubGroup_TotalTested=not_count if StudentSubGroup_TotalTested=="<10" & StudentSubGroup == "English Learner"

tostring All, replace
replace StudentGroup_TotalTested=All if StudentGroup_TotalTested=="*"

replace StudentSubGroup_TotalTested = "0-9" if StudentSubGroup_TotalTested == "<10"
* replace Lev*_count = "1-2" if Lev*_count == "<3"
foreach v of varlist Lev*_percent ProficientOrAbove_percent {
	gen `v'1 = subinstr(`v', "<=", "0-", .)
	replace `v'=`v'1 if strpos(`v', "<=")
	drop `v'1
	
	replace `v'=`v'+"-1" if substr(`v', 1, 1)==">"
	gen `v'1 = substr(`v', 3, .)
	replace `v' = `v'1 if strpos(`v', ">=")
	drop `v'1
	
}
foreach v of varlist Lev*_count ProficientOrAbove_count{
	replace `v' = "0-2" if `v' == "<3"
}

replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="0-9" if StudentSubGroup_TotalTested=="." 

//StudentGroup_TotalTested new convention
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Setting ID digits to 5 to make consistent across years
foreach var of varlist StateAssigned* {
	replace `var' = string(real(`var'), "%05.0f") if !missing(real(`var'))
}

//Derive Exact count/percent where we have range and corresponding exact count/percent and StudentSubGroup_TotalTested
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`percent'))
	replace `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

//Derivations

**Deriving Counts (and corresponding percents) if we have ProficientOrAbove_count & other count OR TotalDidNotMeet & other count

replace Lev4_count = string(real(ProficientOrAbove_count)-real(Lev3_count)) if !missing(real(ProficientOrAbove_count)) & !missing(real(Lev3_count)) & missing(real(Lev4_count))
replace Lev3_count = string(real(ProficientOrAbove_count)-real(Lev4_count)) if !missing(real(ProficientOrAbove_count)) & !missing(real(Lev4_count)) & missing(real(Lev3_count))
replace Lev2_count = string(real(TotalDidNotMeet)-real(Lev1_count)) if !missing(real(TotalDidNotMeet)) & !missing(real(Lev1_count)) & missing(real(Lev2_count))
replace Lev1_count = string(real(TotalDidNotMeet)-real(Lev2_count)) if !missing(real(TotalDidNotMeet)) & !missing(real(Lev2_count)) & missing(real(Lev1_count))

foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`percent'))
}
drop TotalDidNotMeet

**Deriving Count if we have all other counts

replace Lev1_count = string(real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev1_count)) & (real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev1_count)) & missing(real(Lev2_count)) & (real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) > 0

replace Lev3_count = string(real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev4_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & missing(real(Lev3_count)) & (real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) > 0

replace Lev4_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev1_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev4_count)) & (real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) > 0


** Deriving Percents if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent)) & (1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent)) & (1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent) > 0.005)

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))  & (1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent) > 0.005)

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))  & (1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

** Setting ProficientOrAbove_count ranges to reflect ProficientOrAbove_percent ranges
replace ProficientOrAbove_count = string(round(real(substr(ProficientOrAbove_percent,1, strpos(ProficientOrAbove_percent, "-")-1)) * real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(ProficientOrAbove_percent,strpos(ProficientOrAbove_percent, "-")+1,10)) * real(StudentSubGroup_TotalTested))) if missing(real(ProficientOrAbove_count)) & regexm(ProficientOrAbove_percent, "[0-9]") !=0 & missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested))

//Edits to IDs in response to V2.0 R2
replace NCESDistrictID = "2680850" if SchName == "LAKESHORE LEARNING CENTER"
replace StateAssignedDistID = "61000" if SchName == "LAKESHORE LEARNING CENTER"
replace NCESSchoolID = "268085007799" if SchName == "LAKESHORE LEARNING CENTER"

replace NCESSchoolID = "261560001772" if SchName == "Consolidated Community School Services" & StateAssignedSchID == "9417"
replace NCESDistrictID = "2615600" if SchName == "Consolidated Community School Services" & StateAssignedSchID == "9417"
replace DistType = "Regular local school district" if SchName == "Consolidated Community School Services" & StateAssignedSchID == "9417"
replace CountyName = "Mackinac County" if SchName == "Consolidated Community School Services" & StateAssignedSchID == "9417"
replace DistCharter = "No" if SchName == "Consolidated Community School Services" & StateAssignedSchID == "9417"
replace DistLocale = "Rural, remote" if SchName == "Consolidated Community School Services" & StateAssignedSchID == "9417"
replace CountyCode = "26097" if SchName == "Consolidated Community School Services" & StateAssignedSchID == "9417"

replace NCESDistrictID = "2680620" if DistName == "Kent ISD - District created from ISD" & SchName == "Kent Education Center--Oakleigh"
replace NCESSchoolID = "268062005335" if DistName == "Kent ISD - District created from ISD" & SchName == "Kent Education Center--Oakleigh"
replace DistType = "Specialized public school district" if DistName == "Kent ISD - District created from ISD" & SchName == "Kent Education Center--Oakleigh"
replace DistCharter = "No" if DistName == "Kent ISD - District created from ISD" & SchName == "Kent Education Center--Oakleigh"
replace CountyName = "Kent County" if DistName == "Kent ISD - District created from ISD" & SchName == "Kent Education Center--Oakleigh"
replace CountyCode = "26081" if DistName == "Kent ISD - District created from ISD" & SchName == "Kent Education Center--Oakleigh"


replace DistName = "Hamilton Academy" if NCESDistrictID == "2600987" & DataLevel == 3

//StateAssignedSchID format updates: response to R2 V2.0
replace StateAssignedSchID = string(real(StateAssignedSchID), "%4.0f") if DataLevel == 3

//Final Cleaning

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MI_AssmtData_2021.dta", replace

export delimited using "${output}/csv/MI_AssmtData_2021.csv", replace
