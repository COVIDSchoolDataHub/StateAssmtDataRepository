clear
set more off

global MS "/Users/miramehta/Documents/Mississippi"
global raw "/Users/miramehta/Documents/Mississippi/Original Data Files"
global output "/Users/miramehta/Documents/Mississippi/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EDFacts"

local subject math ela
local datatype performance participation
local datalevel district school state


//Only using ela/math from request, science unreliable
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

//assessment name for science changed for 2019
gen AssmtName = "MAAP"

gen ProficiencyCriteria = "Levels 4-5"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

//assessment name for science changed for 2019
gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if Subject == "sci"
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
replace StudentSubGroup_TotalTested = sum if StudentSubGroup_TotalTested2 == . & sum != "."
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

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
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
replace ProficientOrAbove_count = StudentSubGroup_TotalTested2 - (Lev1_count2 + Lev2_count2 + Lev3_count2) if ProficientOrAbove_count == . & (StudentSubGroup_TotalTested2 - (Lev1_count2 + Lev2_count2 + Lev3_count2)) > 0
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
merge 1:1 NCESDistrictID StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019districtmississippi.dta", gen(DistMerge)
drop if DistMerge == 2
save "`tempdist'", replace
clear

//School Merge
use "`tempsch'"
duplicates report NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force

merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019schoolmississippi.dta", gen(SchMerge)
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

** Getting rid of ranges where high and low ranges are the same
foreach var of varlist *_count *_percent {
replace `var' = substr(`var',1, strpos(`var', "-")-1) if real(substr(`var',1, strpos(`var', "-")-1)) == real(substr(`var', strpos(`var', "-")+1,10)) & strpos(`var', "-") !=0 & regexm(`var', "[0-9]") !=0
}

//Derivations

**Deriving Count if we have all other counts

replace Lev1_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev1_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev1_count)) & missing(real(Lev2_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev3_count)-real(Lev1_count)) > 0

replace Lev3_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev4_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & missing(real(Lev3_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev4_count)-real(Lev1_count)-real(Lev2_count)) > 0

replace Lev4_count = string(real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev5_count)) & !missing(real(Lev1_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev4_count)) & (real(StudentSubGroup_TotalTested)-real(Lev5_count)-real(Lev1_count)-real(Lev3_count)-real(Lev2_count)) > 0

replace Lev5_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev4_count)) & !missing(real(Lev3_count)) & !missing(real(Lev2_count)) & missing(real(Lev5_count)) & (real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev4_count)-real(Lev3_count)-real(Lev2_count)) > 0

** Deriving Percents if we have all other percents
replace Lev1_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev2_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent) > 0.005)

replace Lev3_percent = string(1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))  & (1-real(Lev5_percent)-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent) > 0.005)

replace Lev4_percent = string(1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev5_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))  & (1-real(Lev5_percent)-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

replace Lev5_percent = string(1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev5_percent))  & (1-real(Lev1_percent)-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent) > 0.005)

//Clean up AvgScaleScore
replace AvgScaleScore = string(real(AvgScaleScore), "%9.3f") if !missing(real(AvgScaleScore))
save "$raw/MS_AssmtData_2019_ela_math", replace

//////////////////////////////////////////////////////////
//INCORPORATING SCIENCE DATA FROM WEBSITE (unique to 2019)
//////////////////////////////////////////////////////////

//Combining
use "$raw/MS_AssmtData_2019_G5sci", clear
rename Grade5 Entity
gen GradeLevel = "G05"
tempfile g5
save "`g5'", replace
use "$raw/MS_AssmtData_2019_G8sci", clear
rename Grade8 Entity
gen GradeLevel = "G08"
append using "`g5'"
gen olddistname = Entity
gen oldschname = Entity
drop if missing(Entity)
save "$raw/MS_AssmtData_2019_sci", replace

//Merging in IDs
use "$MS/ms_full-dist-sch-stable-list_through2024", clear
keep if SchYear == "2018-19"
duplicates drop olddistname, force
replace DataLevel = "District"
gen Entity = olddistname
drop newschname NCESSchoolID
save "$MS/2019_DistrictIDs", replace
use "$MS/ms_full-dist-sch-stable-list_through2024", clear
gen Entity = oldschname
keep if SchYear == "2018-19"
duplicates drop Entity, force
save "$MS/2019_SchoolIDs", replace

use "$raw/MS_AssmtData_2019_sci", clear
merge m:1 Entity using "$MS/2019_DistrictIDs", gen(DistMerge)
drop if DistMerge == 2
merge m:1 Entity using "$MS/2019_SchoolIDs", gen(SchMerge) update replace
drop if SchMerge == 2
drop if missing(Entity)

merge m:1 Entity using "$MS/MS Unmerged_2019_Sci", gen(NewMerged) update replace
drop if Notes == "DROP"
drop if NewMerged == 2
drop Notes SameName newschname newdistname

//Stablenames
merge m:1 NCESDistrictID using "$MS/2019_DistrictIDs", gen(StableDistMerge)
drop if StableDistMerge == 2
merge m:1 NCESSchoolID using "$MS/2019_SchoolIDs", gen(StableSchMerge)
drop if StableSchMerge == 2
replace newschname = "Central Elementary School" if NCESSchoolID == "280348000668"

//DataLevel
replace DataLevel = "State" if Entity == "Grand Total"
replace newdistname = "All Districts" if DataLevel == "State"
replace newschname = "All Schools" if DataLevel != "School"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

//Renaming and Dropping variables
rename AverageScaleScore AvgScaleScore
rename Level*PCT Lev*_percent
rename TestTakers StudentSubGroup_TotalTested
gen DistName = Entity if DataLevel == 2
gen SchName = Entity if DataLevel == 3
replace DistName = newdistname if !missing(newdistname)
replace SchName = newschname if !missing(newschname)
keep Lev* AvgScaleScore *Name NCES* DataLevel State SchYear StudentSubGroup_TotalTested GradeLevel
order State SchYear DataLevel *Name NCES*
replace DistName = "Ms Sch For the Blind and Deaf" if NCESDistrictID == "2801189"

//Counts and percents
foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	gen `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = string(real(`percent'), "%9.3g") if !missing(real(`percent'))

}
gen ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if !missing(real(Lev4_count)) & !missing(real(Lev5_count))
gen ProficientOrAbove_percent = string(real(Lev4_percent) + real(Lev5_percent)) if !missing(real(Lev4_percent)) & !missing(real(Lev5_percent))
foreach var of varlist *_count *_percent {
	replace `var' = "*" if missing(`var')
}

//AvgScaleScore
replace AvgScaleScore = string(real(AvgScaleScore), "%9.3f") if !missing(real(AvgScaleScore))

//Merging NCES
merge m:1 NCESDistrictID using "$NCES/NCES_2018_District", nogen keep(match master)
merge m:1 NCESSchoolID using "$NCES/NCES_2018_School", nogen keep(match master)

//StateAssignedDistID & StateAssignedSchID
gen StateAssignedDistID = subinstr(State_leaid, "MS-","",.)
gen StateAssignedSchID = substr(seasch,strpos(seasch, "-") +1,10)
drop State_leaid seasch

//Indicator & missing
replace State = "Mississippi"
replace SchYear = "2018-19"
replace StateFips = 28
replace StateAbbrev = "MS"

gen AssmtName = "MAAP"

gen AssmtType = "Regular"

gen ProficiencyCriteria = "Levels 4-5"

gen Subject = "sci"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

gen ParticipationRate = "--"

//Combining with ela/math
append using "$raw/MS_AssmtData_2019_ela_math"



keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2019.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2019.csv", replace
