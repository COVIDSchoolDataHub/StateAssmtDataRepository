clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global raw "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT"
global output "/Users/minnamgung/Desktop/Arizona/Output/AzM2-AzMERIT"
global NCES "/Users/minnamgung/Desktop/Arizona/NCES"

** CLEANING SCHOOL DATA
** ELA and Math

import excel "${raw}/AZ_OriginalData_2019_all.xlsx", sheet("School") firstrow clear

** Rename applicable variables
rename FiscalYear SchYear
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchlID
rename SchoolName SchName
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel
rename NumberTested StudentGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop Charter

** Replace subject observations
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Mathematics"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "ELA Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="School"
gen Lev5_percent=""
gen AvgScaleScore=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""

foreach x of numlist 1/5 {
    generate Lev`x'_count =""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedSchlID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_school_2019.dta", replace

** CLEANING SCHOOL DATA
** Science


import excel "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT/AZ_OriginalData_2019_sci.xlsx", sheet("School") firstrow clear

** Generating missing variables

** Rename applicable variables
rename FiscalYear SchYear
rename DistrictName DistName
rename DistrictCode StateAssignedDistID
rename SchoolCode StateAssignedSchlID
rename SchoolName SchName
rename Subgroup StudentSubGroup
rename GradeCohortHighSchooldefine GradeLevel
rename NumberTested StudentGroup_TotalTested
rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent
rename AverageAIMSScaleScore AvgScaleScore

drop Charter

** Replace subject observations
replace Subject="sci" if Subject=="Science"

sort SchName GradeLevel

** Generate grade observations from TestLevel variable
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

tostring AvgScaleScore, replace

** Generating missing variables
gen AssmtName="AIMS Science"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="School"
gen Lev5_percent=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""

foreach x of numlist 1/5 {
    generate Lev`x'_count =""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedSchlID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_2019_school_sci.dta", replace

** Append AIMS Science Data

use "${output}/AZ_AssmtData_school_2019.dta", clear
append using "${output}/AZ_AssmtData_2019_school_sci.dta"

** Merge NCES Data onto file 

merge m:1 StateAssignedSchlID using "${NCES}/NCES_2019_School.dta"

rename school_type SchoolType

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2019.dta", replace



** CLEANING DISTRICT DATA
** ELA and Math

import excel "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT/AZ_OriginalData_2019_all.xlsx", sheet("District_Charter") firstrow clear

** Rename applicable variables
rename FiscalYear SchYear
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel
rename NumberTested StudentGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

** Replace subject observations
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Mathematics"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "ELA Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="District"
gen Lev5_percent=""
gen AvgScaleScore=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""

foreach x of numlist 1/5 {
    generate Lev`x'_count =""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2019.dta", replace

** CLEANING DISTRICT DATA
** Science

import excel "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT/AZ_OriginalData_2019_sci.xlsx", sheet("District_Charter Holder") firstrow clear

rename FiscalYear SchYear
rename DistrictName DistName
rename DistrictCode StateAssignedDistID
rename Subgroup StudentSubGroup
rename GradeCohortHighSchooldefine GradeLevel
rename NumberTested StudentGroup_TotalTested
rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent
rename AverageAIMSScaleScore AvgScaleScore

** Replace subject observations
replace Subject="sci" if Subject=="Science"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

tostring AvgScaleScore, replace

** Generating missing variables
gen AssmtName="AIMS Science"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="District"
gen Lev5_percent=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""

foreach x of numlist 1/5 {
    generate Lev`x'_count =""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_2019_district_sci.dta", replace

** Append AIMS Science Data
use "${output}/AZ_AssmtData_district_2019.dta", clear

append using "${output}/AZ_AssmtData_2019_district_sci.dta"

** Merge NCES Data onto file 
tostring StateAssignedDistID, generate(State_leaid)
gen State_leaid=StateAssignedDistID

merge m:1 State_leaid using "${NCES}/NCES_2019_District.dta"

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2019.dta", replace



** CLEANING STATE DATA
** ELA and Math

import excel "${raw}/AZ_OriginalData_2019_all.xlsx", sheet("State") firstrow clear

rename FiscalYear SchYear
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel
rename NumberTested StudentGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent


** Replace subject observations
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Mathematics"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "ELA Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="State"
gen Lev5_percent=""
gen AvgScaleScore=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""

foreach x of numlist 1/5 {
    generate Lev`x'_count =""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

save "${output}/AZ_AssmtData_state_2019.dta", replace


** CLEANING STATE DATA
** Science

import excel "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT/AZ_OriginalData_2019_sci.xlsx", sheet("State") firstrow clear

rename FiscalYear SchYear
rename Subgroup StudentSubGroup
rename GradeCohortHighSchooldefine GradeLevel
rename NumberTested StudentGroup_TotalTested
rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent
rename AverageAIMSScaleScore AvgScaleScore

tostring AvgScaleScore, replace


** Replace subject observations
replace Subject="sci" if Subject=="Science"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")


** Generating missing variables
gen AssmtName="AIMS Science"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="State"
gen Lev5_percent=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""

rename DistrictType District

foreach x of numlist 1/5 {
    generate Lev`x'_count =""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

save "${output}/AZ_AssmtData_2019_state_sci.dta", replace

** Append AIMS Science Data
use "${output}/AZ_AssmtData_state_2019.dta", clear

append using "${output}/AZ_AssmtData_2019_state_sci.dta"

sort GradeLevel

keep if District=="All"
drop District

gen StateAbbrev="AZ"
gen State="ARIZONA"
gen StateFips=04

save "${output}/AZ_AssmtData_state_2019.dta", replace

use "${output}/AZ_AssmtData_school_2019.dta", clear

append using "${output}/AZ_AssmtData_district_2019.dta"

save "${output}/AZ_AssmtData_2019.dta", replace

append using "${output}/AZ_AssmtData_state_2019.dta"

save "${output}/AZ_AssmtData_2019.dta", replace

rename County CountyName

gen AssmtType="Regular"

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchlID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

drop SchoolCTDS DistrictCTDS year lea_name county_name

replace State="arizona"
replace StateAbbrev="AZ"
replace StateFips=4

replace CountyName = lower(CountyName)

tostring SchYear, replace
replace SchYear="2018-2019"

sort DataLevel StateAssignedDistID StateAssignedSchlID GradeLevel Subject

save "${output}/AZ_AssmtData_2019.dta", replace

export delimited using"/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2019.csv", replace

