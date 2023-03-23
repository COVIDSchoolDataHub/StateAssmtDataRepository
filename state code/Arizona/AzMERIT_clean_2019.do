clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global raw "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT"
global output "/Users/minnamgung/Desktop/Arizona/Output/AzM2-AzMERIT"
global NCES "/Users/minnamgung/Desktop/Arizona/NCES"
global dta "/Users/minnamgung/Desktop/Arizona/dta"

** 2019 ELA and Math

import excel "${raw}/AZ_OriginalData_2019_all.xlsx", sheet("School") firstrow clear

save "${dta}/AZ_AssmtData_school_2019.dta", replace

import excel "${raw}/AZ_OriginalData_2019_all.xlsx", sheet("District_Charter") firstrow clear                       
save "${dta}/AZ_AssmtData_district_2019.dta", replace

import excel "${raw}/AZ_OriginalData_2019_all.xlsx", sheet("State") firstrow clear

save "${dta}/AZ_AssmtData_state_2019.dta", replace

** 2019 Science

import excel "${raw}/AZ_OriginalData_2019_sci.xlsx", sheet("School") firstrow clear

save "${dta}/AZ_AssmtData_school_sci_2019.dta", replace

import excel "${raw}/AZ_OriginalData_2019_sci.xlsx", sheet("District_Charter Holder") firstrow clear

save "${dta}/AZ_AssmtData_district_sci_2019.dta", replace

import excel "${raw}/AZ_OriginalData_2019_sci.xlsx", sheet("State") firstrow clear

save "${dta}/AZ_AssmtData_state_sci_2019.dta", replace






** 2019 School Cleaning 

use "${dta}/AZ_AssmtData_school_2019.dta", clear

** Rename existing variables
rename FiscalYear SchYear
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
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

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if GradeLevel=="Grade 8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_school_2019.dta", replace


use "${dta}/AZ_AssmtData_school_sci_2019.dta", clear

rename FiscalYear SchYear
rename DistrictName DistName
rename DistrictCode StateAssignedDistID
rename SchoolCode StateAssignedSchID
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


** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_2019_school_sci.dta", replace

use "${output}/AZ_AssmtData_school_2019.dta", clear

append using "${output}/AZ_AssmtData_2019_school_sci.dta"

merge m:1 StateAssignedSchID using "${NCES}/NCES_2019_School.dta"

rename school_type SchoolType
gen DataLevel="School"
sort NCESSchoolID GradeLevel Subject

tostring AvgScaleScore, replace 

save "${output}/AZ_AssmtData_school_2019.dta", replace



** 2019 Dist Cleaning 

use "${dta}/AZ_AssmtData_district_2019.dta", clear

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

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if GradeLevel=="Grade 8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2019.dta", replace


use "${dta}/AZ_AssmtData_district_sci_2019.dta", clear 

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


** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, replace
tostring AvgScaleScore, replace

save "${output}/AZ_AssmtData_2019_district_sci.dta", replace

use "${output}/AZ_AssmtData_district_2019.dta", clear

append using "${output}/AZ_AssmtData_2019_district_sci.dta"

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2019_District.dta"

sort NCESDistrictID GradeLevel Subject
gen DataLevel="District"

save "${output}/AZ_AssmtData_district_2019.dta", replace


** 2019 State cleaning 

use "${dta}/AZ_AssmtData_state_2019.dta", clear

rename FiscalYear SchYear
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel
rename NumberTested StudentGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if GradeLevel=="Grade 8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

save "${output}/AZ_AssmtData_state_2019.dta", replace


use "${dta}/AZ_AssmtData_state_sci_2019.dta", clear

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

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring Lev1_percent, replace force
tostring Lev2_percent, replace force
tostring Lev3_percent, replace force
tostring Lev4_percent, replace force
tostring AvgScaleScore, replace force

tostring StudentGroup_TotalTested, replace force

tostring ProficientOrAbove_percent, replace force

keep if DistrictType=="All"

save "${output}/AZ_AssmtData_2019_state_sci.dta", replace

use "${output}/AZ_AssmtData_state_2019.dta", clear

append using "${output}/AZ_AssmtData_2019_state_sci.dta"

keep if inlist(District, "All", "")
drop District DistrictType
sort GradeLevel Subject

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2019.dta", replace


** Append all files 
use "${output}/AZ_AssmtData_school_2019.dta", clear

append using "${output}/AZ_AssmtData_district_2019.dta"

save "${output}/AZ_AssmtData_2019.dta", replace

append using "${output}/AZ_AssmtData_state_2019.dta", force

tostring SchYear, replace
replace SchYear="2018-19"

gen StudentGroup=""
gen State="arizona"

save "${output}/AZ_AssmtData_2019.dta", replace

keep if _merge==1
keep SchYear SchName DistName StateAssignedDistID StateAssignedSchID

export delimited using "/Users/minnamgung/Desktop/Arizona/Output/Unmerged/AZ_AssmtData_unmerged_2019.csv", replace

use "${output}/AZ_AssmtData_2019.dta", clear


** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"
gen AssmtType="Regular"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen Lev5_percent=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""

foreach x of numlist 1/5 {
    generate Lev`x'_count = ""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

drop County
rename county_name CountyName

drop if _merge==2
drop _merge

replace CountyName = lower(CountyName)

replace StudentSubGroup="American Indian/Alaska Native" if StudentSubGroup=="American Indian or Alaska Native"
replace StudentSubGroup="American Indian/Alaska Native" if StudentSubGroup=="Hispanic or Latino"
replace StudentSubGroup="Native Hawaiian/Other Pacific Islander" if StudentSubGroup=="Native Hawaiian or Pacific Islander"

replace StudentGroup="All students" if StudentSubGroup=="All Students"
replace StudentGroup="Race" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific Islander", "Two or More Races", "White", "African American", "Multiple Races")
replace StudentGroup="Ethnicity" if StudentSubGroup=="Hispanic/Latino"
replace StudentGroup="EL status" if inlist(StudentSubGroup, "English Learner")
replace StudentGroup="Economic status" if inlist(StudentSubGroup, "Income Eligibility 1 and 2", "Homeless")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")

drop if inlist(StudentSubGroup, "Migrant", "Students with Disabilities", "Military")

replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"

replace ProficiencyCriteria="Levels 3 and 4"

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

drop SchoolCTDS DistrictCTDS year lea_name

sort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "${output}/AZ_AssmtData_2019.dta", replace

export delimited using"/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2019.csv", replace












