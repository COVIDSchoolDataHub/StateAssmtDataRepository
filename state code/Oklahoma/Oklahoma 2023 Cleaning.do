clear
set more off

global raw "/Users/maggie/Desktop/Oklahoma/Original Data Files"
global output "/Users/maggie/Desktop/Oklahoma/Output"
global NCES "/Users/maggie/Desktop/Oklahoma/NCES/Cleaned"

cd "/Users/maggie/Desktop/Oklahoma"

use "${raw}/OK_AssmtData_2023.dta", clear

** Renaming variables

rename Grade GradeLevel
rename OrganizationId StateAssignedSchID
rename Group SchName

local subject ELA Mathematics Science
foreach a of local subject{
	rename `a'BelowBasic `a'BelowBasicPer
	rename `a'Basic `a'BasicPer
	rename `a'Proficient `a'ProficientPer
	rename `a'Advanced `a'AdvancedPer
	rename `a'* *`a'
}

** Reshape

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

** Replacing variables

gen SchYear = "2022-23"

replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

replace StateAssignedSchID = "55E003" if StateAssignedSchID == "55000"
replace StateAssignedSchID = "55E012" if StateAssignedSchID == "55000000000000"
replace StateAssignedSchID = "72E004" if StateAssignedSchID == "720000"
replace StateAssignedSchID = "72E005" if StateAssignedSchID == "7200000"
replace StateAssignedSchID = "72E006" if StateAssignedSchID == "72000000"
replace StateAssignedSchID = "61E020" if StateAssignedSchID == "6.10000000000e+21"
replace StateAssignedSchID = "55E028" if StateAssignedSchID == "5.50000000000e+29"
replace StateAssignedSchID = "55E030" if StateAssignedSchID == "5.50000000000e+31"
replace StateAssignedSchID = "72E017" if StateAssignedSchID == "7.20000000000e+18"
replace StateAssignedSchID = "72E018" if StateAssignedSchID == "7.20000000000e+19"
replace StateAssignedSchID = "72E019" if StateAssignedSchID == "7.20000000000e+20"

gen DataLevel = "School"
replace DataLevel = "District" if substr(StateAssignedSchID, 7, 1) == ""
replace DataLevel = "State" if StateAssignedSchID == "0"

gen StateAssignedDistID = StateAssignedSchID
sort StateAssignedSchID
replace StateAssignedDistID = StateAssignedDistID[_n-1] if DataLevel == "School"

gen DistName = SchName
replace DistName = DistName[_n-1] if DataLevel == "School"

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

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
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	}

gen ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2
tostring ProficientOrAbove_percent, replace format("%9.2g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

foreach a of local level{
	tostring Lev`a'_percent2, replace format("%9.2g") force
	replace Lev`a'_percent = Lev`a'_percent2
	replace Lev`a'_percent = "*" if Lev`a'_percent2 == "."
	drop Lev`a'_percent2
}

destring Lev3_count, gen(Lev3_count2) force
destring Lev4_count, gen(Lev4_count2) force

gen ProficientOrAbove_count = Lev3_count2 + Lev4_count2
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

drop *count2

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen State_leaid = "OK-" + substr(StateAssignedDistID, 1, 2) + "-" + substr(StateAssignedDistID, 3, 4)
replace State_leaid = "" if DataLevel == 1
drop if DistName == "Jones Academy" | DistName == "Riverside Indian School" // BIE Schools

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

drop if _merge == 2
drop _merge

**** Updating 2023 districts

replace DistType = 7 if DistName == "Epic Charter School"
replace NCESDistrictID = "4000777" if DistName == "Epic Charter School"
replace DistCharter = "Yes" if DistName == "Epic Charter School"
replace CountyName = "Oklahoma County" if DistName == "Epic Charter School"
replace CountyCode = 40109 if DistName == "Epic Charter School"

replace DistType = 1 if DistName == "Graham-Dustin"
replace NCESDistrictID = "4000782" if DistName == "Graham-Dustin"
replace DistCharter = "No" if DistName == "Graham-Dustin"
replace CountyName = "Okfuskee County" if DistName == "Graham-Dustin"
replace CountyCode = 40107 if DistName == "Graham-Dustin"

**

gen seasch = substr(StateAssignedSchID, 1, 2) + "-" + substr(StateAssignedSchID, 3, 4) + "-" + substr(StateAssignedSchID, 7, 3)
replace seasch = "" if DataLevel != 3

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"

drop if _merge == 2
drop _merge

**** Updating 2023 schools

replace SchType = 1 if seasch == "57-I029-515"
replace NCESSchoolID = "400357029861" if seasch == "57-I029-515"

replace SchType = 1 if seasch == "72-I001-532"
replace NCESSchoolID = "403024029863" if seasch == "72-I001-532"

replace SchType = 1 if seasch == "20-I026-515"
replace NCESSchoolID = "403207029857" if seasch == "20-I026-515"

replace SchType = 1 if seasch == "55-Z014-970"
replace NCESSchoolID = "400077702741" if seasch == "55-Z014-970"

replace SchType = 1 if seasch == "72-E018-980"
replace NCESSchoolID = "400079229862" if seasch == "72-E018-980"

replace SchType = 1 if seasch == "07-I072-130"
replace NCESSchoolID = "401035029856" if seasch == "07-I072-130"

replace SchType = 1 if seasch == "32-I056-105"
replace NCESSchoolID = "400078200608" if seasch == "32-I056-105"

replace SchType = 1 if seasch == "37-I007-125"
replace NCESSchoolID = "401656029858" if seasch == "37-I007-125"

replace SchType = 1 if seasch == "72-I014-510"
replace NCESSchoolID = "401776029866" if seasch == "72-I014-510"

replace SchType = 1 if seasch == "72-I001-542"
replace NCESSchoolID = "403024029864" if seasch == "72-I001-542"

replace SchType = 1 if seasch == "55-I089-526"
replace NCESSchoolID = "402277029860" if seasch == "55-I089-526"

replace SchType = 1 if seasch == "55-I012-195"
replace NCESSchoolID = "401059029859" if seasch == "55-I012-195"

replace SchType = 1 if seasch == "72-I001-577"
replace NCESSchoolID = "403024029865" if seasch == "72-I001-577"

replace SchLevel = -1 if seasch == "20-I026-515" | seasch == "72-I001-532" | seasch == "57-I029-515" | seasch == "55-Z014-970" | seasch == "72-E018-980" | seasch == "07-I072-130" | seasch == "32-I056-105" | seasch == "37-I007-125" | seasch == "72-I014-510" | seasch == "72-I001-542" | seasch == "55-I089-526" | seasch == "55-I012-195" | seasch == "72-I001-577"
replace SchVirtual = -1 if seasch == "20-I026-515" | seasch == "72-I001-532" | seasch == "57-I029-515" | seasch == "55-Z014-970" | seasch == "72-E018-980" | seasch == "07-I072-130" | seasch == "32-I056-105" | seasch == "37-I007-125" | seasch == "72-I014-510" | seasch == "72-I001-542" | seasch == "55-I089-526" | seasch == "55-I012-195" | seasch == "72-I001-577"
label def SchLevel -1 "Missing/not reported"
label def SchVirtual -1 "Missing/not reported"

**

replace StateAbbrev = "OK"
replace State = 40
replace StateFips = 40

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/OK_AssmtData_2023.dta", replace

export delimited using "${output}/csv/OK_AssmtData_2023.csv", replace
