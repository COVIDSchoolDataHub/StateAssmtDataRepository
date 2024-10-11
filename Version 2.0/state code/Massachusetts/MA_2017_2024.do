clear
set more off
set trace off

cd "/Volumes/T7/State Test Project/Massachusetts"

global Original "/Volumes/T7/State Test Project/Massachusetts/Original"
global Output "/Volumes/T7/State Test Project/Massachusetts/Output"
global NCES "/Volumes/T7/State Test Project/Massachusetts/NCES"


//Hide below after first run

/*


forvalues year = 2017/2024 {
	import delimited "$Original/MA_OriginalData_2017_2024", case(preserve) clear
	if `year' == 2020 continue
	keep if SY == `year'
	save "$Original/MA_OriginalData_`year'", replace
	
}

import excel "$Original/mass_district_science", clear
save "$Original/mass_district_science", replace
import excel "$Original/mass_school_science", clear
save "$Original/mass_school_science", replace

import excel mass_district_participation_new_2, clear
keep if real(B) < 2021 & real(B) > 2016
save "$Original/mass_district_participation_new_2", replace
import excel mass_school_participation_new, clear
keep if real(B) < 2021 & real(B) > 2016
save "$Original/mass_school_participation_new", replace

import excel MA_Unmerged_2024.xlsx, firstrow case(preserve) allstring clear
save MA_Unmerged_2024, replace

import excel ma_full-dist-sch-stable-list_through2024, firstrow case(preserve) allstring clear
drop DataLevel
gen DataLevel = 3
save MA_SchNames, replace
duplicates drop SchYear NCESDistrictID, force
replace DataLevel = 2
drop *schname NCESSchoolID
save MA_DistNames, replace
append using MA_SchNames
duplicates drop SchYear NCESDistrictID NCESSchoolID, force
save MA_StableNames, replace


*/

//Hide Above after first run



**********************
**// ELA AND MATH **//
**********************




forvalues year = 2017/2024 {
	if `year' == 2020 continue
	local prevyear = `year' -1 
	use "$Original/MA_OriginalData_`year'", clear


//Renaming
rename SY SchYear
rename DIST_CODE StateAssignedDistID
rename DIST_NAME DistName
rename ORG_CODE StateAssignedSchID
rename ORG_NAME SchName
rename ORG_TYPE DataLevel
rename TEST_GRADE GradeLevel
rename SUBJECT_CODE Subject
rename STUGRP StudentSubGroup
rename M_PLUS_E_CNT ProficientOrAbove_count
rename M_PLUS_E_PCT ProficientOrAbove_percent
rename E_CNT Lev4_count
rename E_PCT Lev4_percent
rename M_CNT Lev3_count
rename M_PCT Lev3_percent
rename PM_CNT Lev2_count
rename PM_PCT Lev2_percent
rename NM_CNT Lev1_count
rename NM_PCT Lev1_percent
rename STU_CNT StudentSubGroup_TotalTested
rename STU_PART_PCT ParticipationRate
rename AVG_SCALED_SCORE AvgScaleScore
drop AVG_SGP* ACH_PERCENTILE DISTRICT_AND_SCHOOL

//DataLevel
replace DataLevel = "District" if strpos(DataLevel, "District") !=0
replace DataLevel = "School" if strpos(DataLevel, "School") !=0

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

tostring StateAssigned*, replace
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

//SchYear
tostring SchYear, replace
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear,-2,2)

//GradeLevel
keep if (real(GradeLevel) >= 3 & real(GradeLevel) <= 8) | GradeLevel == "ALL (03-08)"
replace GradeLevel = "G" + GradeLevel if GradeLevel != "ALL (03-08)"
replace GradeLevel = "G38" if GradeLevel == "ALL (03-08)"

//Subject
replace Subject = lower(Subject)

//StudentSubGroup
* All Students
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American" | StudentSubGroup == "African American/Black"
* Asian
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL and Former EL"
* Ever EL
* Female
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Former EL"
* Foster Care
drop if StudentSubGroup == "High Needs" | StudentSubGroup == "High needs"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic" | StudentSubGroup == "Hispanic/Latino"
* Homeless
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low Income" | StudentSubGroup == "Low income"
* Migrant
* Military
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-Race, Non-Hispanic" | StudentSubGroup == "Multi-race, Non-Hispanic/Latino"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian, Pacific Islander"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Low Income" | StudentSubGroup == "Non-Economically Disadvantaged"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-Disabled"
drop if StudentSubGroup == "Non-Title 1" | StudentSubGroup == "Non-Title1"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities" | StudentSubGroup == "Students with disabilities"
drop if StudentSubGroup == "Title 1" | StudentSubGroup == "Title1"
* White

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "Ever EL"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//ParticipationRate
tostring ParticipationRate, replace force usedisplayformat
replace ParticipationRate = "--" if ParticipationRate == "."

//NCES Merging
replace StateAssignedDistID = subinstr(StateAssignedDistID, "0000", "",.)
replace StateAssignedDistID = string(real(StateAssignedDistID), "%04.0f")
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = substr(StateAssignedSchID, -4,4)

gen State_leaid = "MA-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedDistID + StateAssignedSchID if DataLevel == 3

if `year' < 2024 merge m:1 State_leaid using "$NCES/NCES_`prevyear'_District", gen(DistMerge)
if `year' < 2024 merge m:1 seasch using "$NCES/NCES_`prevyear'_School", gen(SchMerge)
if `year' == 2024 {
merge m:1 State_leaid using "$NCES/NCES_2022_District", gen(DistMerge)
merge m:1 seasch using "$NCES/NCES_2022_School", gen(SchMerge)
merge m:1 SchName using MA_Unmerged_2024, update nogen
}

drop if DistMerge == 2
drop if SchMerge == 2

replace State = "Massachusetts"
replace StateFips = 25
replace StateAbbrev = "MA"
if `year' == 2023 | `year' == 2024 {
replace SchVirtual = "No" if NCESSchoolID == "251158002946" | NCESSchoolID == "251332202949" | NCESSchoolID == "251332302950"
replace SchLevel = "Primary" if NCESSchoolID == "251158002946" | NCESSchoolID == "251332202949" | NCESSchoolID == "251332302950"

}
replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID if DataLevel == 3

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Indicator Variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

if `year' == 2017 {
	replace Flag_AssmtNameChange = "Y" if Subject == "ela" | Subject == "math"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_sci = "N"
	
}

if `year' == 2018 replace Flag_CutScoreChange_sci = "N"

if `year' == 2019 {
	replace Flag_AssmtNameChange = "Y" if Subject == "sci"
	replace Flag_CutScoreChange_sci = "Y"
	
}

gen AssmtName = "NextGen MCAS"
gen AssmtType = "Regular"


gen ProficiencyCriteria = "Levels 3-4"

//ID Update for StateAssignedSchID == "03360020"
replace NCESSchoolID = "251284001840" if StateAssignedSchID == "03360020"


//Empty Vars
gen Lev5_count = ""
gen Lev5_percent = ""

//Converting Percents/Counts to String

tostring *_count *_percent StudentGroup_TotalTested StudentSubGroup_TotalTested AvgScaleScore, replace force usedisplayformat

//Converting ParticipationRate and Percents to decimal (added 9/25/24)
foreach var of varlist *_percent ParticipationRate {
	replace `var' = string(real(`var')/100, "%9.3g") if !missing(real(`var'))
}

//Final Cleaning

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/MA_AssmtData_`year'_E2C", replace

}

*************
//** SCI **//
*************
use "$Original/mass_district_science", clear


//Renaming & Appending

rename A DataLevel	
rename B SchYear 	
rename C GradeLevel
rename D StudentSubGroup	
rename E DistName
rename F StateAssignedDistID
rename G Subject	
rename H ProficientOrAbove_count
rename I ProficientOrAbove_percent	
rename J Lev4_count	
rename K Lev4_percent	
rename L Lev3_count	
rename M Lev3_percent	
rename N Lev2_count
rename O Lev2_percent	
rename P Lev1_count		
rename Q Lev1_percent				
rename R StudentSubGroup_TotalTested	
rename S CPI
rename T SGP	
rename U SGP_
gen ParticipationRate = "--"	
gen AvgScaleScore = "--"
drop CPI SGP SGP_

tempfile sci_dist
save "`sci_dist'", replace

use "$Original/mass_school_science", clear

rename A DataLevel
rename B SchYear 	
rename C GradeLevel
rename D StudentSubGroup	
drop if E == "State Total ( ALL )"
rename E SchName
// drop F
rename F StateAssignedSchID
rename G Subject	
rename H ProficientOrAbove_count
rename I ProficientOrAbove_percent	
rename J Lev4_count	
rename K Lev4_percent	
rename L Lev3_count	
rename M Lev3_percent	
rename N Lev2_count
rename O Lev2_percent	
rename P Lev1_count		
rename Q Lev1_percent				
rename R StudentSubGroup_TotalTested	
rename S CPI
rename T SGP	
rename U SGP_2 	
gen ParticipationRate = "--"	
gen AvgScaleScore = "--"

drop CPI SGP SGP_2


append using "`sci_dist'"
keep if SchYear == "2017" | SchYear == "2018"


save "$Original/MA_OriginalData_2017_2018_sci", replace

foreach year in 2017 2018 {
	local prevyear = `year' -1
	use "$Original/MA_OriginalData_2017_2018_sci", clear
	keep if SchYear == "`year'"
	save "$Original/sci_`year'", replace


//DataLevel
replace DataLevel = "State" if DistName == "State Total"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

//SchYear
replace SchYear = string(`year'-1) + "-" + substr("`year'",-2,2)

//GradeLevel
replace GradeLevel = "G" + GradeLevel

//StudentSubGroup
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Afr. Amer./Black"
* All Students
* Asian
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL and Former EL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ. Disadvantaged"
* Ever EL
* Female
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Former EL"
drop if StudentSubGroup == "High needs"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
* Male
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-race, Non-Hisp./Lat."
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"
* White

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "Ever EL"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Subject
replace Subject = "sci"

//Cleaning Percents
foreach percent of varlist *_percent {
	replace `percent' = string(real(`percent')/100, "%9.3g")
}

//SchName & DistName
replace DistName = substr(SchName, 1, strpos(SchName, " - ")-1) if DataLevel == 3
replace SchName = subinstr(SchName, DistName + " - ", "",.)
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel == 1

//Fixing ID's Before Merging
replace StateAssignedDistID = subinstr(StateAssignedDistID, "0000","",.)
replace StateAssignedDistID = substr(StateAssignedSchID,1,4) if DataLevel == 3

//NCES Merging
gen State_leaid = "MA-" + StateAssignedDistID if DataLevel !=1
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3

merge m:1 State_leaid using "$NCES/NCES_`prevyear'_District", gen(DistMerge)
merge m:1 seasch using "$NCES/NCES_`prevyear'_School", gen(SchMerge)

drop if DistMerge == 2 | SchMerge == 2

replace State = "Massachusetts"
replace StateFips = 25
replace StateAbbrev = "MA"
if `year' == 2023 replace SchVirtual = "Missing/not reported" if missing(SchVirtual) & DataLevel == 3 & !missing(NCESSchoolID)

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode


//StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Indicator Variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

if `year' == 2017 {
	replace Flag_AssmtNameChange = "Y" if Subject == "ela" | Subject == "math"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_sci = "N"
	
}

if `year' == 2018 replace Flag_CutScoreChange_sci = "N"

if `year' == 2019 {
	replace Flag_AssmtNameChange = "Y" if Subject == "sci"
	replace Flag_CutScoreChange_sci = "Y"
	
}

gen AssmtType = "Regular"

gen AssmtName = "Legacy MCAS" if Subject == "sci"

gen ProficiencyCriteria = "Levels 3-4"

//Empty Vars
gen Lev5_count = ""
gen Lev5_percent = ""


//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/MA_AssmtData_`year'_sci", replace

}


//Combining ela/math and sci for 2017 and 2018
forvalues year = 2017/2024 {
	if `year' == 2020 continue
	use "$Output/MA_AssmtData_`year'_E2C", clear
	if `year' == 2017 | `year' == 2018 {
		append using "$Output/MA_AssmtData_`year'_sci"
	}
	
//StateDistID update R1
replace StateAssignedDistID = StateAssignedDistID + "0000" if DataLevel !=1

replace AvgScaleScore = "--" if AvgScaleScore == "."

//Incorporating Stable Dist/SchNames
merge m:1 SchYear NCESDistrictID NCESSchoolID using "MA_StableNames", keep(match master) nogen
replace DistName = newdistname if !missing(newdistname)
replace SchName = newschname if !missing(newschname)
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/MA_AssmtData_`year'", replace
export delimited "$Output/MA_AssmtData_`year'", replace	
}

*****************************
// ** ParticipationRate ** //
*****************************

use "$Original/mass_district_participation_new_2", clear
rename A DataLevel
rename B SchYear
rename C GradeLevel
rename D StudentSubGroup
rename E Subject
rename F DistName
rename G StateAssignedDistID
drop H
rename I ParticipationRate


tempfile dist_part
save "`dist_part'", replace

use "$Original/mass_school_participation_new", clear
rename A DataLevel
rename B SchYear
rename C GradeLevel
rename D StudentSubGroup
rename E Subject
rename F SchName
rename G StateAssignedSchID
drop H
rename I ParticipationRate

append using "`dist_part'"

//DataLevel
replace DataLevel = "State" if strpos(DistName, "State Total") !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel == 1

//SchYear
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear,-2,2)

//GradeLevel
replace GradeLevel = "G" + GradeLevel

//StudentSubGroup
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Afr. Amer./Black"
* All Students
* Asian
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL and Former EL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ. Disadvantaged"
* Ever EL
* Female
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Former EL"
drop if StudentSubGroup == "High needs"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
* Male
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-race, Non-Hisp."
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students w/ disabilities"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer. Ind. or Alaska Nat."
drop if StudentSubGroup == "XXXXXXXX"

//Subject
replace Subject = "ela" if Subject == "English"
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "sci" if strpos(Subject, "Sci") !=0

//StateAssignedDistID & StateAssignedSchID
replace StateAssignedDistID = substr(StateAssignedSchID,1,4) + "0000" if DataLevel == 3

//ParticipationRate
replace ParticipationRate = string(real(ParticipationRate)/100, "%9.3g")
rename ParticipationRate ParticipationRate_1

//Final Cleaning
rename *Name *Name_1
order SchYear DataLevel StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel Subject ParticipationRate SchName_1 DistName_1
sort SchYear DataLevel

save "$Output/MA_Participation_2017_2019", replace

forvalues year = 2017/2019 {

use "$Output/MA_AssmtData_`year'", clear
merge 1:1 SchYear StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel Subject using "$Output/MA_Participation_2017_2019", gen(Merge)
drop if Merge == 2

replace ParticipationRate = ParticipationRate_1 if missing(real(ParticipationRate)) & !missing(real(ParticipationRate_1))
drop *_1

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "$Output/MA_AssmtData_`year'", replace
export delimited "$Output/MA_AssmtData_`year'", replace
}
