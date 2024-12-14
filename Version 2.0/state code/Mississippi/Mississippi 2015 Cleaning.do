clear
set more off

global MS "/Users/miramehta/Documents/Mississippi"
global raw "/Users/miramehta/Documents/Mississippi/Original Data Files"
global output "/Users/miramehta/Documents/Mississippi/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EDFacts"

local subject math ela sci
local datatype performance participation
local datalevel district school state

foreach sub of local subject {
	use "${Request}/2015/`sub'performance/statecleaned.dta", clear
	append using "${Request}/2015/`sub'performance/districtcleaned.dta"
	append using "${Request}/2015/`sub'performance/schoolcleaned.dta"
	save "${Request}/2015/`sub'performance.dta", replace
}

foreach sub of local subject {
	use "${Request}/2015/`sub'participation/statecleaned.dta", clear
	append using "${Request}/2015/`sub'participation/districtcleaned.dta"
	append using "${Request}/2015/`sub'participation/schoolcleaned.dta"
	save "${Request}/2015/`sub'participation.dta", replace
}

foreach sub of local subject {
	use "${Request}/2015/`sub'participation.dta", clear
	merge 1:1 StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup using "${Request}/2015/`sub'performance.dta"
	drop if _merge == 1
	drop _merge
	save "${Request}/2015/`sub'.dta", replace
}

use "${Request}/2015/ela.dta", clear
append using "${Request}/2015/math.dta"
append using "${Request}/2015/sci.dta"

foreach v of numlist 1/5 {
	replace Lev`v'_count = "0" if Lev`v'_count == ""
	replace Lev5_count = "" if Subject == "sci"
}

gen State_leaid = StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2014_District.dta"
drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID
merge m:1 seasch using "${NCES}/NCES_2014_School.dta"
drop if _merge == 2
drop _merge

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Creating variables

replace SchYear = "2014-15"

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

gen AssmtName = "PARCC" if Subject != "sci"
replace AssmtName = "MST2" if Subject == "sci"

gen ProficiencyCriteria = "Levels 4-5" if Subject != "sci"
replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen Flag_AssmtNameChange = "Y" if Subject != "sci"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

replace State = "Mississippi"
replace StateAbbrev = "MS"
replace StateFips = 28

** Replacing student counts to sum of level counts

foreach v of numlist 1/5 {
	destring Lev`v'_count, gen(Lev`v'_count2) force
}
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
gen sum = Lev1_count2 + Lev2_count2 + Lev3_count2 + Lev4_count2 + Lev5_count2 if Subject != "sci"
replace sum = Lev1_count2 + Lev2_count2 + Lev3_count2 + Lev4_count2 if Subject == "sci"
gen diff = StudentSubGroup_TotalTested2 - sum if Subject != "sci"
replace diff = StudentSubGroup_TotalTested2 - sum if Subject == "sci"
tostring sum, replace force
replace StudentSubGroup_TotalTested = sum if diff != 0 & sum != "."
drop StudentSubGroup_TotalTested2 sum diff

** Generating student group total counts

gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

** Generating level percents
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force

foreach v of numlist 1/5 {
	gen Lev`v'_percent = Lev`v'_count2/StudentSubGroup_TotalTested2
	tostring Lev`v'_percent, replace format("%9.4g") force
	replace Lev`v'_percent = "*" if Lev`v'_percent == "."
	replace Lev`v'_percent = "0" if Lev`v'_count == "0"
}
replace Lev5_percent = "" if Subject == "sci"

** Generating proficiencies

gen ProficientOrAbove_count = Lev4_count2 + Lev5_count2 if Subject != "sci"
replace ProficientOrAbove_count = StudentSubGroup_TotalTested2 - (Lev1_count2 + Lev2_count2 + Lev3_count2) if ProficientOrAbove_count == . & Subject != "sci"
replace ProficientOrAbove_count = Lev3_count2 + Lev4_count2 if Subject == "sci"
replace ProficientOrAbove_count = StudentSubGroup_TotalTested2 - (Lev1_count2 + Lev2_count2) if ProficientOrAbove_count == . & Subject == "sci"
gen ProficientOrAbove_percent = ProficientOrAbove_count/StudentSubGroup_TotalTested2
tostring ProficientOrAbove_count, replace force
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"

drop StudentSubGroup_TotalTested2 *_count2


** Merging with standardized name file
merge m:1 NCESDistrictID using "${MS}/standarddistnames.dta"
replace DistName = newdistname if _merge != 1
drop if _merge == 2 
drop newdistname _merge

merge m:1 NCESSchoolID using "${MS}/standardschnames.dta"
replace SchName = newschname if _merge != 1
drop if DataLevel == 3 & _merge == 1
drop if _merge == 2
drop newdistname newschname _merge


** Merging with EDFacts data
tempfile tempall
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
duplicates report NCESDistrictID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID StudentSubGroup GradeLevel Subject, force
merge 1:1 NCESDistrictID StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactspart2015districtmississippi.dta", gen(DistMerge)
drop if DistMerge == 2
save "`tempdist'", replace
clear

//School Merge
use "`tempsch'"
duplicates report NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force
*destring NCESSchoolID, replace
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactspart2015schoolmississippi.dta", gen(SchMerge)
drop if SchMerge == 2
save "`tempsch'", replace
clear

//Combining DataLevels
use "`tempall'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"

//New Participation Data
replace ParticipationRate = Participation if !missing(Participation)

replace CountyName = proper(CountyName)
replace CountyName = "DeSoto County" if CountyName == "Desoto County"

/*
** Merging with EDFacts Datasets
gen test = 1
append using "${EDFacts}/2015/edfactscount2015districtmississippi.dta", force
merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactspart2015districtmississippi.dta", update
drop if _merge == 2
drop _merge

destring NCESSchoolID, replace
append using "${EDFacts}/2015/edfactscount2015schoolmississippi.dta"
merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactspart2015schoolmississippi.dta", update
drop if _merge == 2
drop _merge

replace test = 2 if test == .
sort DataLevel NCESDistrictID NCESSchoolID test

replace AvgScaleScore = "--" if AvgScaleScore == ""
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""
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

replace ParticipationRate = Participation if !missing(Participation)


destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test2 = min(StudentSubGroup_TotalTested2)
drop StudentSubGroup_TotalTested2 test test2
*/

//Derivations

**Deriving Count if we have all other counts

** Getting rid of ranges where high and low ranges are the same
foreach var of varlist *_count *_percent {
replace `var' = substr(`var',1, strpos(`var', "-")-1) if real(substr(`var',1, strpos(`var', "-")-1)) == real(substr(`var', strpos(`var', "-")+1,10)) & strpos(`var', "-") !=0 & regexm(`var', "[0-9]") !=0
}

*ela/math
replace Lev1_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev1_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0 & Subject != "sci"

replace Lev2_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev1_count)) & missing(real(Lev2_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) > 0 & Subject != "sci"

replace Lev3_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & missing(real(Lev3_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) > 0 & Subject != "sci"

replace Lev4_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev1_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev4_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) > 0 & Subject != "sci"

replace Lev5_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev5_count)) & (real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0 & Subject != "sci"

*sci
replace Lev1_count = string(real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev1_count)) & (real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0 & Subject == "sci"

replace Lev2_count = string(real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev1_count)) & missing(real(Lev2_count)) & (real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) > 0 & Subject == "sci"

replace Lev3_count = string(real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev2_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev4_count)) & !missing(real(Lev2_count)) & !missing(real(Lev1_count)) & missing(real(Lev3_count)) & (real(StudentSubGroup_TotalTested)-real(Lev4_count)-real(Lev2_count)-real(Lev1_count)) > 0 & Subject == "sci"

replace Lev4_count = string(real(StudentSubGroup_TotalTested)-real(Lev3_count)-real(Lev2_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & !missing(real(Lev1_count)) & missing(real(Lev4_count)) & (real(StudentSubGroup_TotalTested)-real(Lev3_count)-real(Lev2_count)-real(Lev1_count)) > 0 & Subject == "sci"





** Deriving Percents if we have all other percents
*ela/math
replace Lev1_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005) & Subject != "sci"

replace Lev2_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent) > 0.005) & Subject != "sci"

replace Lev3_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent) > 0.005) & Subject != "sci"

replace Lev4_percent = string(1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))  & (1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005) & Subject != "sci"

replace Lev5_percent = string(1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev5_percent))  & (1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005) & Subject != "sci"
*sci
*sci
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent)) if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent)) & (1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent)) > 0 & Subject == "sci"

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent)) if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent)) & (1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent)) > 0 & Subject == "sci"

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev2_percent)-real(Lev1_percent)) if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev3_percent)) & (1-real(Lev4_percent)-real(Lev2_percent)-real(Lev1_percent)) > 0 & Subject == "sci"

replace Lev4_percent = string(1-real(Lev3_percent)-real(Lev2_percent)-real(Lev1_percent)) if !missing(1) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev4_percent)) & (1-real(Lev3_percent)-real(Lev2_percent)-real(Lev1_percent)) > 0 & Subject == "sci"

foreach v of numlist 1/5 {
	replace Lev`v'_percent = "*" if strpos(Lev`v'_percent, "e") != 0 & Lev`v'_count == "*"
}

//Clean up AvgScaleScore
replace AvgScaleScore = string(real(AvgScaleScore), "%9.3f") if !missing(real(AvgScaleScore))


keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2015.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2015.csv", replace
