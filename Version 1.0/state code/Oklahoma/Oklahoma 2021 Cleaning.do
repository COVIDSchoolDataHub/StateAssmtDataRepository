clear
set more off

global raw "/Users/maggie/Desktop/Oklahoma/Original Data Files"
global output "/Users/maggie/Desktop/Oklahoma/Output"
global NCES "/Users/maggie/Desktop/Oklahoma/NCES/Cleaned"

cd "/Users/maggie/Desktop/Oklahoma"

use "${raw}/OK_AssmtData_2021.dta", clear

** Renaming variables

rename district_name DistName
rename district StateAssignedDistID
rename subject Subject
rename grade GradeLevel
rename year SchYear
rename p_participation p_participation_all
rename p_perf_adv p_perf_adv_all
rename p_perf_prof p_perf_prof_all
rename p_perf_basic p_perf_basic_all
rename p_perf_below_basic p_perf_below_basic_all
rename p_race_aa prop_race_aa
rename p_race_ai prop_race_ai
rename p_race_as prop_race_as
rename p_race_wh prop_race_wh
rename p_race_other prop_race_other
rename p_hisp prop_hisp
rename p_ell prop_ell
rename p_econ_disad prop_econ_disad

** Dropping entries

drop if SchYear != 2021
drop if Subject == "all"
drop if inlist(GradeLevel, "g11", "all")

** Reshape

reshape long p_participation_ prop_ p_perf_adv_ p_perf_prof_ p_perf_basic_ p_perf_below_basic_, i(StateAssignedDistID Subject GradeLevel) j(StudentSubGroup) string

** Dropping entries

drop if prop_ == . & p_participation_ == . & p_perf_adv_ == . & p_perf_prof_ == . & p_perf_basic_ == . & p_perf_below_basic_ == .
drop if prop_ == 0

** Renaming variables

rename p_perf_adv_ Lev4_percent
rename p_perf_prof_ Lev3_percent
rename p_perf_basic_ Lev2_percent
rename p_perf_below_basic_ Lev1_percent
rename p_participation_ ParticipationRate

** Replacing variables

tostring SchYear, replace
replace SchYear = "2020-21"

gen AssmtName = "OSTP"
gen AssmtType = "Regular"

replace GradeLevel = "G0" + substr(GradeLevel, 2, 1)

gen DataLevel = "District"

gen StateAssignedSchID = ""
gen seasch = ""

gen SchName = "All Schools"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "all"
replace StudentGroup = "Economic Status" if StudentSubGroup == "econ_disad"
replace StudentGroup = "EL Status" if StudentSubGroup == "ell"
replace StudentGroup = "Ethnicity" if StudentSubGroup == "hisp"

replace StudentSubGroup = "All Students" if StudentSubGroup == "all"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "econ_disad"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ell"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "hisp"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "race_aa"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "race_ai"
replace StudentSubGroup = "Asian" if StudentSubGroup == "race_as"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "race_other"
replace StudentSubGroup = "White" if StudentSubGroup == "race_wh"

local level 1 2 3 4

foreach a of local level {
	gen Lev`a'_count = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 3-4"

gen ProficientOrAbove_count = "--"
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

** Generating student counts

replace prop_ = 1 if StudentSubGroup == "All Students"
gen StudentSubGroup_TotalTested = round(n_student * prop_ * ParticipationRate)

drop n_student prop_

replace StudentSubGroup_TotalTested = -100000000 if StudentSubGroup_TotalTested == .
bysort StateAssignedDistID StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)
replace StudentGroup_TotalTested = . if StudentGroup_TotalTested < 0

** Converting to string

local var ParticipationRate Lev4_percent Lev3_percent Lev2_percent Lev1_percent StudentSubGroup_TotalTested StudentGroup_TotalTested ProficientOrAbove_percent

foreach a of local var{
	tostring `a', replace force
	replace `a' = "*" if `a' == "." | `a' == "-100000000"
}

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

replace StateAssignedDistID = "61E020" if DistName == "Carlton Landing Academy"
replace StateAssignedDistID = "55E028" if DistName == "John W Rex Charter"
replace StateAssignedDistID = "55E003" if DistName == "OKC Charter: Hupfeld Academy at Western Village"
replace StateAssignedDistID = "55E001" if DistName == "OKC Charter: Independence Middle School"
replace StateAssignedDistID = "55E012" if DistName == "OKC Charter: KIPP Reach College"
replace StateAssignedDistID = "55E021" if DistName == "OKC Charter: Santa Fe South"
replace StateAssignedDistID = "72E017" if DistName == "Tulsa Charter: College Bound"
replace StateAssignedDistID = "72E019" if DistName == "Tulsa Charter: Collegiate Hall"
replace StateAssignedDistID = "72E018" if DistName == "Tulsa Charter: Honor Academy"
replace StateAssignedDistID = "72E005" if DistName == "Tulsa Charter: KIPP Tulsa"
replace StateAssignedDistID = "72E004" if DistName == "Tulsa Charter: School of Arts and Sciences"
replace StateAssignedDistID = "72E006" if DistName == "Tulsa Legacy Charter School Inc"

gen State_leaid = "OK-" + substr(StateAssignedDistID, 1, 2) + "-" + substr(StateAssignedDistID, 3, 4)

merge m:1 State_leaid using "${NCES}/NCES_2020_District.dta"

drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2020_School.dta"

drop if _merge == 2
drop _merge

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OK_AssmtData_2021.dta", replace

export delimited using "${output}/csv/OK_AssmtData_2021.csv", replace
