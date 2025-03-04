clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global MS "/Users/maggie/Desktop/Mississippi"
global raw "/Users/maggie/Desktop/Mississippi/Original Data Files"
global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"
global Request "/Users/maggie/Desktop/Mississippi/Data Request"

local subject math ela sci
local datatype performance participation
local datalevel district school state

/*
** Fixing weird data formatting issue with science school performance file

use "${Request}/2019/sciperformance/schoolcleaned.dta", clear
tostring Lev*_count, replace force
foreach v of numlist 1/5{
	replace Lev`v'_count = "*" if Lev`v'_count == "."
}
save "${Request}/2019/sciperformance/schoolcleaned.dta", replace
*/

foreach sub of local subject {
	use "${Request}/2019/`sub'performance/statecleaned.dta", clear
	append using "${Request}/2019/`sub'performance/districtcleaned.dta"
	append using "${Request}/2019/`sub'performance/schoolcleaned.dta"
	save "${Request}/2019/`sub'performance.dta", replace
}

foreach sub of local subject {
	use "${Request}/2019/`sub'participation/statecleaned.dta", clear
	append using "${Request}/2019/`sub'participation/districtcleaned.dta"
	append using "${Request}/2019/`sub'participation/schoolcleaned.dta"
	save "${Request}/2019/`sub'participation.dta", replace
}

foreach sub of local subject {
	use "${Request}/2019/`sub'participation.dta", clear
	merge 1:1 StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup using "${Request}/2019/`sub'performance.dta"
	drop if _merge == 1
	drop _merge
	save "${Request}/2019/`sub'.dta", replace
}

use "${Request}/2019/ela.dta", clear
append using "${Request}/2019/math.dta"
append using "${Request}/2019/sci.dta"

drop if StudentSubGroup_TotalTested == "0" | (Lev1_count == "0" & Lev2_count == "0" & Lev3_count == "0" & Lev4_count == "0" & Lev5_count == "0")
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == ""

foreach v of numlist 1/5 {
	replace Lev`v'_count = "0" if Lev`v'_count == ""
}

gen State_leaid = StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2018_District.dta"
drop if _merge == 2
drop _merge

gen seasch = StateAssignedSchID
merge m:1 seasch using "${NCES}/NCES_2018_School.dta"
drop if _merge == 2
drop _merge

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Creating variables

replace SchYear = "2018-19"

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3

replace StateAssignedDistID = subinstr(StateAssignedDistID, "MS-", "", .)
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = substr(StateAssignedSchID, 6, 7)
replace StateAssignedSchID = "" if DataLevel != 3

gen AssmtName = "MAAP"

gen ProficiencyCriteria = "Levels 4-5"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

replace State = "Mississippi"
replace StateAbbrev = "MS"
replace StateFips = 28

** Replacing student counts to sum of level counts

foreach v of numlist 1/5 {
	destring Lev`v'_count, gen(Lev`v'_count2) force
}
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
gen sum = Lev1_count2 + Lev2_count2 + Lev3_count2 + Lev4_count2 + Lev5_count2
gen diff = StudentSubGroup_TotalTested2 - sum
tostring sum, replace force
replace StudentSubGroup_TotalTested = sum if diff != 0 & sum != "."
drop StudentSubGroup_TotalTested2 sum diff

** Generating student group total counts

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

** Generating level percents

foreach v of numlist 1/5 {
	gen Lev`v'_percent = Lev`v'_count2/StudentSubGroup_TotalTested2
	tostring Lev`v'_percent, replace format("%9.4g") force
	replace Lev`v'_percent = "*" if Lev`v'_percent == "."
	replace Lev`v'_percent = "0" if Lev`v'_count == "0"
}

drop StudentSubGroup_TotalTested2

** Generating proficiencies

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force

gen ProficientOrAbove_count = Lev4_count2 + Lev5_count2 
replace ProficientOrAbove_count = StudentSubGroup_TotalTested2 - (Lev1_count2 + Lev2_count2 + Lev3_count2) if ProficientOrAbove_count == .
gen ProficientOrAbove_percent = ProficientOrAbove_count/StudentSubGroup_TotalTested2
tostring ProficientOrAbove_count, replace force
tostring ProficientOrAbove_percent, replace format("%9.4g") force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"

drop StudentSubGroup_TotalTested2 test *_count2

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

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2019.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2019.csv", replace
