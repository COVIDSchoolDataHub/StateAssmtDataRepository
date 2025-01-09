clear
set more off

global MS "/Volumes/T7/State Test Project/Mississippi"
global raw "/Volumes/T7/State Test Project/Mississippi/Original Data Files"
global output "/Volumes/T7/State Test Project/Mississippi/Output"
global NCES "/Volumes/T7/State Test Project/Mississippi/NCES"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"


local grade 3 4 5 6 7 8
local gradesci 5 8
local level 1 2 3 4
local subject L M
local levelname NM NB NP NA PM PB PP PA


use "${raw}/MS_AssmtData_2014_ela_mat.dta", clear
append using "${raw}/MS_AssmtData_2014_sci.dta"

** Dropping extra variables

drop SCH

** Rename existing variables

rename DISTSCH StateAssignedSchID 
rename DIST StateAssignedDistID
rename DISTRICT_NAME DistName
rename SCHOOL_NAME SchName

** Changing to long

foreach grd of local grade {
	foreach sub of local subject {
		rename G`grd'`sub'N StudentSubGroup_TotalTestedG0`grd'Z`sub'
	}
}

foreach grd of local grade {
	foreach sub of local subject {
		rename G`grd'`sub'SS AvgScaleScoreG0`grd'Z`sub'
	}
}

foreach grdsci of local gradesci {
	rename G`grdsci'SN StudentSubGroup_TotalTestedG0`grdsci'
}

foreach grdsci of local gradesci {
	rename G`grdsci'SSS AvgScaleScoreG0`grdsci'
}

foreach grd of local grade {
	foreach sub of local subject {
			foreach lvl of local levelname {
				rename G`grd'`sub'`lvl' `lvl'G0`grd'Z`sub'
		}
	}
}

foreach grdsci of local gradesci {
		foreach lvl of local levelname {
			rename G`grdsci'S`lvl' `lvl'G0`grdsci'
	}
}

reshape long NM NB NP NA PM PB PP PA StudentSubGroup_TotalTested AvgScaleScore, i(StateAssignedDistID StateAssignedSchID DistName SchName Subject) j(GradeLevel) string

drop if missing(StudentSubGroup_TotalTested)

rename NM Lev1_count
rename NB Lev2_count
rename NP Lev3_count
rename NA Lev4_count

rename PM Lev1_percent
rename PB Lev2_percent
rename PP Lev3_percent
rename PA Lev4_percent

split GradeLevel, parse("Z") generate(GradeLevel)

replace Subject = "ela" if GradeLevel2 == "L" 
replace Subject = "math" if GradeLevel2 == "M"

drop GradeLevel GradeLevel2

rename GradeLevel1 GradeLevel


** Generating missing variables

gen StudentGroup = "All Students"
gen StudentSubGroup = StudentGroup

gen ParticipationRate = "--"

foreach a of local level {
	destring Lev`a'_count, gen(Lev`a'_count2) force
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
}

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force

gen ProficientOrAbove_count = Lev3_count2 + Lev4_count2 
replace ProficientOrAbove_count = StudentSubGroup_TotalTested2 - (Lev1_count2 + Lev2_count2) if ProficientOrAbove_count == .
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
gen ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2
replace ProficientOrAbove_percent = 1 - (Lev1_percent2 + Lev2_percent2) if ProficientOrAbove_percent == .
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
drop StudentSubGroup_TotalTested2

foreach a of local level {
	tostring Lev`a'_percent2, replace format("%9.4g") force
	replace Lev`a'_percent = Lev`a'_percent2 if Lev`a'_percent != "*"
	drop Lev`a'_count2
	drop Lev`a'_percent2
}

gen DataLevel = "School"
replace DataLevel = "District" if strpos(SchName, "Districtwide Data") > 0
replace DataLevel = "State" if SchName == "Statewide Data"

replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel != "School"
replace SchName = subinstr(SchName, " (E)", "", .)

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

replace StateAssignedDistID = "" if DataLevel == 1
gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCES}/NCES_2013_District.dta"

drop if _merge == 2
drop _merge

replace StateAssignedSchID = "" if DataLevel != 3
gen seasch = StateAssignedSchID

merge m:1 seasch using "${NCES}/NCES_2013_School.dta"

drop if _merge == 2
drop _merge




** Merging with EDFacts Count Datasets

gen test = 1
append using "${EDFacts}/2014/edfactscount2014districtmississippi.dta",
merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2014/edfactspart2014districtmississippi.dta", update
drop if _merge == 2
drop _merge

replace SchName = "All Schools" if SchName == ""

append using "${EDFacts}/2014/edfactscount2014schoolmississippi.dta", force
merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2014/edfactspart2014schoolmississippi.dta", update
drop if _merge == 2
drop _merge

replace test = 2 if test == .
sort DataLevel NCESDistrictID NCESSchoolID test

replace AvgScaleScore = "--" if AvgScaleScore == ""
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""
replace ProficientOrAbove_percent = Proficient if missing(real(ProficientOrAbove_percent)) & !missing(Proficient)
replace StudentSubGroup_TotalTested = string(Count) if missing(real(StudentSubGroup_TotalTested)) & !missing(Count)

** Merging with EDFacts Participation Datasets
tempfile tempall
tostring NCESDistrictID, replace
save "`tempall'", replace
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "`tempall'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear

//District Merge
use "`tempdist'"
duplicates drop NCESDistrictID StudentSubGroup GradeLevel Subject, force
tostring NCESDistrictID, replace
merge 1:1 NCESDistrictID StudentSubGroup GradeLevel Subject using "${EDFacts}/2014/edfactspart2014districtmississippi.dta", gen(DistMerge)
drop if DistMerge == 2
save "`tempdist'", replace
clear

//School Merge
use "`tempsch'"
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force
tostring NCESDistrictID, replace
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts}/2014/edfactspart2014schoolmississippi.dta", gen(SchMerge)
drop if SchMerge == 2
save "`tempsch'", replace
clear

//Combining DataLevels
use "`tempall'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"


//New Participation Data
replace ParticipationRate = Participation if !missing(Participation)

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = "--" if Lev`a'_percent == ""
	replace Lev`a'_count = "--" if Lev`a'_count == ""
}
replace DistName = DistName[_n-1] if test == 2 & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace SchName = SchName[_n-1] if test == 2 & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace StateAssignedDistID = StateAssignedDistID[_n-1] if StateAssignedDistID == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace StateAssignedSchID = StateAssignedSchID[_n-1] if StateAssignedSchID == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace State_leaid = State_leaid[_n-1] if State_leaid == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace seasch = seasch[_n-1] if seasch == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace DistType = DistType[_n-1] if DistType == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace SchType = SchType[_n-1] if SchType == . & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace SchVirtual = SchVirtual[_n-1] if SchVirtual == . & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace SchLevel = SchLevel[_n-1] if SchLevel == . & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace DistCharter = DistCharter[_n-1] if DistCharter == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace DistLocale = DistLocale[_n-1] if DistLocale == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace CountyCode = CountyCode[_n-1] if CountyCode == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
replace CountyName = CountyName[_n-1] if CountyName == "" & NCESDistrictID == NCESDistrictID[_n-1] & NCESSchoolID == NCESSchoolID[_n-1]
drop if CountyName == "" & DataLevel != 1


//StudentGroup_TotalTested with new convention
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1
drop if missing(StudentGroup_TotalTested) //All data missing/suppressed

replace CountyName = proper(CountyName)
replace CountyName = "DeSoto County" if CountyName == "Desoto County"


** Merging with standardized name file
*destring NCESDistrictID, replace
merge m:1 NCESDistrictID using "${MS}/standarddistnames.dta"
replace DistName = newdistname if _merge != 1
drop if _merge == 2

drop newdistname _merge

*destring NCESSchoolID, replace
merge m:1 NCESSchoolID using "${MS}/standardschnames.dta"
replace SchName = newschname if _merge != 1
drop if DataLevel == 3 & _merge == 1
drop if _merge == 2
drop newdistname newschname _merge

** Generating new variables

gen SchYear = "2013-14"

gen AssmtName = "MCT2" if Subject != "sci"
replace AssmtName = "MST2" if Subject == "sci"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"

gen Lev5_count = "--"
gen Lev5_percent = "--"

replace State = "Mississippi"
replace StateAbbrev = "MS"
replace StateFips = 28

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"


replace CountyName = proper(CountyName)
replace CountyName = "DeSoto County" if CountyName == "Desoto County"

//Derive ProficientOrAbove_count based on StudentSubGroup_TotalTested & ProficientOrAbove_percent ranges & exact values if possible
foreach var of varlist ProficientOrAbove_percent {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var', strpos(`var', "-") + 1,10)
	replace low`var' = high`var' if missing(low`var')
}
replace ProficientOrAbove_count = string(round(real(lowProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) + "-" + string(round(real(highProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if !missing(real(lowProficientOrAbove_percent)) & !missing(real(highProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(ProficientOrAbove_count))

//Clean up AvgScaleScore
replace AvgScaleScore = string(real(AvgScaleScore), "%9.3f") if !missing(real(AvgScaleScore))

//Clean up ParticipationRate
replace ParticipationRate = "--" if ParticipationRate == "."

** Getting rid of ranges where high and low ranges are the same
foreach var of varlist *_count *_percent {
replace `var' = substr(`var',1, strpos(`var', "-")-1) if real(substr(`var',1, strpos(`var', "-")-1)) == real(substr(`var', strpos(`var', "-")+1,10)) & strpos(`var', "-") !=0 & regexm(`var', "[0-9]") !=0
}


//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2014.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2014.csv", replace
