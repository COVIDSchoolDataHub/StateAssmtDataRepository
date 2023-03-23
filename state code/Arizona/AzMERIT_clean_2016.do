clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global raw "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT"
global output "/Users/minnamgung/Desktop/Arizona/Output/AzM2-AzMERIT"
global NCES "/Users/minnamgung/Desktop/Arizona/NCES"
global dta "/Users/minnamgung/Desktop/Arizona/dta"

** 2016 ELA and Math

import excel "${raw}/AZ_OriginalData_2016_all.xlsx", sheet("SCHOOLS") firstrow clear

save "${dta}/AZ_AssmtData_school_2016.dta", replace

import excel "${raw}/AZ_OriginalData_2016_all.xlsx", sheet("DISTRICTS_CHARTER HOLDERS") firstrow clear                       
save "${dta}/AZ_AssmtData_district_2016.dta", replace

import excel "${raw}/AZ_OriginalData_2016_all.xlsx", sheet("STATE") firstrow clear

save "${dta}/AZ_AssmtData_state_2016.dta", replace

** 2016 Science

import excel "${raw}/AZ_OriginalData_2016_sci.xlsx", sheet("Schools") firstrow clear

save "${dta}/AZ_AssmtData_school_sci_2016.dta", replace

import excel "${raw}/AZ_OriginalData_2016_sci.xlsx", sheet("Districts-Charter Holders") firstrow clear

save "${dta}/AZ_AssmtData_district_sci_2016.dta", replace

import excel "${raw}/AZ_OriginalData_2016_sci.xlsx", sheet("State") firstrow clear

save "${dta}/AZ_AssmtData_state_sci_2016.dta", replace






** 2016 School Cleaning 

use "${dta}/AZ_AssmtData_school_2016.dta", clear

** Rename existing variables
rename FiscalYear SchYear
rename DistrictCharterHolderName DistName
rename DistrictCharterHolderEntityI StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel

rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

rename ContentArea Subject

drop CharterSchool

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if GradeLevel=="Grade 8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_school_2016.dta", replace


use "${dta}/AZ_AssmtData_school_sci_2016.dta", clear


rename County CountyName
rename LocalEducationAgencyLEANam DistName
rename LEAEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

drop CharterSchool

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_2016_school_sci.dta", replace

use "${output}/AZ_AssmtData_school_2016.dta", clear

append using "${output}/AZ_AssmtData_2016_school_sci.dta"

merge m:1 StateAssignedSchID using "${NCES}/NCES_2016_School.dta"

rename school_type SchoolType
gen DataLevel="School"
sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2016.dta", replace



** 2016 Dist Cleaning 

use "${dta}/AZ_AssmtData_district_2016.dta", clear

** Rename existing variables
rename FiscalYear SchYear
rename DistrictCharterHolderName DistName
rename DistrictCharterHolderEntityI StateAssignedDistID

rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel

rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

rename County CountyName
rename ContentArea Subject

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

save "${output}/AZ_AssmtData_district_2016.dta", replace


use "${dta}/AZ_AssmtData_district_sci_2016.dta", clear 

rename County CountyName
rename LocalEducationAgencyLEANam DistName
rename LEAEntityID StateAssignedDistID

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, replace
tostring AvgScaleScore, replace

save "${output}/AZ_AssmtData_2016_district_sci.dta", replace

use "${output}/AZ_AssmtData_district_2016.dta", clear

append using "${output}/AZ_AssmtData_2016_district_sci.dta"

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2016_District.dta"

sort NCESDistrictID GradeLevel Subject
gen DataLevel="District"

save "${output}/AZ_AssmtData_district_2016.dta", replace


** 2016 State cleaning 

use "${dta}/AZ_AssmtData_state_2016.dta", clear

rename FiscalYear SchYear
rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentGroup_TotalTested
rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

gen AvgScaleScore=""

rename ContentArea Subject

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled All Math Assessment")>0
replace GradeLevel = "G08" if GradeLevel=="Grade 8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")


save "${output}/AZ_AssmtData_state_2016.dta", replace


use "${dta}/AZ_AssmtData_state_sci_2016.dta", clear


rename GradeCohortHighSchooldefine GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

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

tostring ProficientOrAbove_percent, replace

save "${output}/AZ_AssmtData_2016_state_sci.dta", replace

use "${output}/AZ_AssmtData_state_2016.dta", clear

append using "${output}/AZ_AssmtData_2016_state_sci.dta"

keep if inlist(SchoolType, "All", "")
drop SchoolType
sort GradeLevel Subject

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2016.dta", replace


** Append all files 
use "${output}/AZ_AssmtData_school_2016.dta", clear

append using "${output}/AZ_AssmtData_district_2016.dta"

save "${output}/AZ_AssmtData_2016.dta", replace

append using "${output}/AZ_AssmtData_state_2016.dta"

tostring SchYear, replace
replace SchYear="2015-16"

gen StudentGroup=""
gen State="arizona"

save "${output}/AZ_AssmtData_2016.dta", replace

keep if _merge==1
keep SchYear SchName DistName StateAssignedDistID StateAssignedSchID

export delimited using "/Users/minnamgung/Desktop/Arizona/Output/Unmerged/AZ_AssmtData_unmerged_2016.csv", replace

use "${output}/AZ_AssmtData_2016.dta", clear


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

drop CountyName County
rename county_name CountyName

drop if _merge==2
drop _merge

replace CountyName = lower(CountyName)

replace StudentGroup="All students" if StudentSubGroup=="All Students"
replace StudentGroup="Race" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific", "Two or More Races", "White", "African American")
replace StudentGroup="Ethnicity" if StudentSubGroup=="Hispanic/Latino"
replace StudentGroup="EL status" if inlist(StudentSubGroup, "Limited English Proficient")
replace StudentGroup="Economic status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Homeless")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")

drop if inlist(StudentSubGroup, "Migrant", "Students with Disabilities")

replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"

replace ProficiencyCriteria="Levels 3 and 4"

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

drop SchoolCTDSNumber DistrictCharterHolderCTDSNum LEACTDSNumber year lea_name

sort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "${output}/AZ_AssmtData_2016.dta", replace

export delimited using"/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2016.csv", replace












