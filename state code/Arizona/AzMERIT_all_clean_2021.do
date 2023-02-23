clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global raw "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT"
global output "/Users/minnamgung/Desktop/Arizona/Output/AzM2-AzMERIT"
global NCES "/Users/minnamgung/Desktop/Arizona/NCES"


** 2021 ELA and Math

import excel "${raw}/AZ_OriginalData_2021_all.xlsx", sheet("School") firstrow clear

save "${output}/AZ_AssmtData_school_2021.dta", replace

import excel "${raw}/AZ_OriginalData_2021_all.xlsx", sheet("District") firstrow clear

save "${output}/AZ_AssmtData_district_2021.dta", replace

import excel "${raw}/AZ_OriginalData_2021_all.xlsx", sheet("State") firstrow clear

save "${output}/AZ_AssmtData_state_2021.dta", replace


use "${output}/AZ_AssmtData_school_2021.dta", clear

** Rename existing variables
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
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

** Generating missing variables
gen DataLevel="School"

tostring StateAssignedSchlID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_school_2021.dta", replace

merge m:1 StateAssignedSchlID using "${NCES}/NCES_2020_School.dta"

rename school_type SchoolType

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2021.dta", replace

use "${output}/AZ_AssmtData_district_2021.dta", clear

** Rename existing variables
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
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

gen DataLevel="District"

tostring StateAssignedDistID, replace

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2020_District.dta"

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2021.dta", replace

use "${output}/AZ_AssmtData_state_2021.dta", clear

rename FiscalYear SchYear
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

keep if inlist(SchoolType, "All", "")
drop SchoolType
sort GradeLevel Subject

** Replace subject observations
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Mathematics"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2021.dta", replace


use "${output}/AZ_AssmtData_school_2021.dta", clear

append using "${output}/AZ_AssmtData_district_2021.dta"

save "${output}/AZ_AssmtData_2021.dta", replace

append using "${output}/AZ_AssmtData_state_2021.dta", force

save "${output}/AZ_AssmtData_2021.dta", replace

drop County
rename county_name CountyName

gen AssmtType="Regular"

tostring SchYear, replace
replace SchYear="2020-2021"

gen StudentGroup=""
gen State="arizona"

replace CountyName = lower(CountyName)

** Generating missing variables
gen AssmtName="AzM2"
gen Flag_AssmtNameChange="Y"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"


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

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchlID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

drop SchoolCTDS Alternativeschool DistrictCTDS PercentTested year lea_name

sort StateAssignedDistID StateAssignedSchlID GradeLevel Subject

replace StateAbbrev="AZ"
replace StateFips=4

save "${output}/AZ_AssmtData_2021.dta", replace

export delimited using"/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2021.csv", replace





