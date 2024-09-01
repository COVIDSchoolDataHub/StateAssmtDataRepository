clear
set more off

global raw "/Users/maggie/Desktop/Oklahoma/Original Data Files"
global NCES "/Users/maggie/Desktop/Oklahoma BIE/Cleaned NCES"
global output "/Users/maggie/Desktop/Oklahoma BIE/Output"

cd "/Users/maggie/Desktop/Oklahoma"

use "${raw}/OK_AssmtData_2022.dta", clear

** Renaming variables

rename Grade GradeLevel
rename OrganizationId StateAssignedSchID
rename Group SchName
rename Administration SchYear

local subject ELA Mathematics Science
foreach a of local subject{
	rename `a'BelowBasic `a'BelowBasicPer
	rename `a'Basic `a'BasicPer
	rename `a'Proficient `a'ProficientPer
	rename `a'Advanced `a'AdvancedPer
	rename `a'* *`a'
}

** Reshape

drop if GradeLevel == .
reshape long ValidN MeanOPI BelowBasicNo BelowBasicPer BasicNo BasicPer ProficientNo ProficientPer AdvancedNo AdvancedPer, i(StateAssignedSchID GradeLevel) j(Subject) string

** Renaming variables

rename ValidN StudentGroup_TotalTested
rename MeanOPI AvgScaleScore
rename BelowBasicNo Lev1_count
rename BelowBasicPer Lev1_percent
rename BasicNo Lev2_count
rename BasicPer Lev2_percent
rename ProficientNo Lev3_count
rename ProficientPer Lev3_percent
rename AdvancedNo Lev4_count
rename AdvancedPer Lev4_percent

** Dropping entries

drop if StudentGroup_TotalTested == "N/A"
drop if GradeLevel == 11
keep if strpos(StateAssignedSchID, "B") > 0

** Replacing variables

tostring SchYear, replace
replace SchYear = "2021-22"

replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

gen DataLevel = "School"
replace DataLevel = "District" if substr(StateAssignedSchID, 7, 1) == ""

gen StateAssignedDistID = StateAssignedSchID
sort StateAssignedSchID
replace StateAssignedDistID = StateAssignedDistID[_n-1] if DataLevel == "School"

gen DistName = SchName
replace DistName = DistName[_n-1] if DataLevel == "School"

replace SchName = "All Schools" if DataLevel != "School"

replace StateAssignedSchID = "" if DataLevel != "School"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "***"
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

replace AvgScaleScore = "*" if AvgScaleScore == "***"

local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_count = "*" if Lev`a'_count == "***"
}

gen AssmtName = "OSTP"
gen AssmtType = "Regular"

gen Lev5_count = ""
gen Lev5_percent = ""

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 3-4"

local level 1 2 3 4

foreach a of local level {
	destring Lev`a'_count, gen(Lev`a'_count2) force
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	}

gen ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2
replace ProficientOrAbove_percent = 1 - (Lev1_percent2 + Lev2_percent2) if ProficientOrAbove_percent == .
tostring ProficientOrAbove_percent, replace format("%9.2g") force
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "-") > 0
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

foreach a of local level{
	tostring Lev`a'_percent2, replace format("%9.2g") force
	replace Lev`a'_percent = Lev`a'_percent2
	replace Lev`a'_percent = "*" if Lev`a'_percent2 == "."
	drop Lev`a'_percent2
}

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force

gen ProficientOrAbove_count = Lev3_count2 + Lev4_count2
replace ProficientOrAbove_count = StudentSubGroup_TotalTested2 - (Lev1_count2 + Lev2_count2) if ProficientOrAbove_count == .
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

drop *2

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = ""
replace State_leaid = "BI-D01B02" if DistName == "Riverside Indian School"
replace State_leaid = "BI-D09B02" if DistName == "Jones Academy"

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

drop if _merge == 2
drop _merge

gen seasch = subinstr(State_leaid, "BI-", "", .) + "-" + subinstr(State_leaid, "BI-", "", .)
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"

drop if _merge == 2
drop _merge

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OK_BIE_AssmtData_2022.dta", replace

export delimited using "${output}/csv/OK_BIE_AssmtData_2022.csv", replace
