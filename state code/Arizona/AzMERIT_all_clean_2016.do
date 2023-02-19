clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global raw "/Users/minnamgung/Desktop/Arizona/Original Data Files/AzM2-AzMERIT"
global output "/Users/minnamgung/Desktop/Arizona/Output/AzM2-AzMERIT"
global NCES "/Users/minnamgung/Desktop/Arizona/NCES"

use "${output}/AZ_AssmtData_school_2016.dta", clear

** Rename existing variables
rename FiscalYear SchYear
rename DistrictCharterHolderName DistName
rename DistrictCharterHolderEntityI StateAssignedDistID
rename SchoolEntityID StateAssignedSchlID
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


** Replace subject observations
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="School"
gen Lev5_percent=.
gen AvgScaleScore=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedSchlID, replace
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_school_2016.dta", replace

use "${output}/AZ_AssmtData_school_sci_2016.dta", clear

rename County CountyName
rename LocalEducationAgencyLEANam DistName
rename LEAEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchlID
rename SchoolName SchName

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent

gen Subject="sci"

drop CharterSchool

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"
replace GradeLevel = "G38" if strpos(GradeLevel, "All Assessments")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")


** Generating missing variables
gen AssmtName="AIMS Science"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="School"
gen Lev5_percent=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedSchlID, replace
tostring StateAssignedDistID, replace

rename ScienceMeanScaleScore AvgScaleScore
tostring AvgScaleScore, replace

save "${output}/AZ_AssmtData_2016_school_sci.dta", replace

use "${output}/AZ_AssmtData_school_2016.dta", clear

tostring AvgScaleScore, replace

append using "${output}/AZ_AssmtData_2016_school_sci.dta"

merge m:1 StateAssignedSchlID using "${NCES}/NCES_2016_School.dta"

rename school_type SchoolType

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2016.dta", replace


use "${output}/AZ_AssmtData_district_2016.dta", clear

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

** Replace subject observations
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")


** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="District"
gen Lev5_percent=.
gen AvgScaleScore=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2016.dta", replace


use "${output}/AZ_AssmtData_district_sci_2016.dta", clear 

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
replace GradeLevel = "G38" if strpos(GradeLevel, "All Assessments")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")


** Generating missing variables
gen AssmtName="AIMS Science"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="District"
gen Lev5_percent=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedDistID, replace
tostring AvgScaleScore, replace

save "${output}/AZ_AssmtData_2016_district_sci.dta", replace


use "${output}/AZ_AssmtData_district_2016.dta", clear

tostring AvgScaleScore, replace

append using "${output}/AZ_AssmtData_2016_district_sci.dta"

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2016_District.dta"

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2016.dta", replace

use "${output}/AZ_AssmtData_state_2016.dta", clear


rename FiscalYear SchYear
rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentGroup_TotalTested
rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

rename ContentArea Subject

drop SchoolType


** Replace subject observations
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")


** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="Y"

gen Flag_CutScoreChange_ELA="Y"
gen Flag_CutScoreChange_math="Y"
gen Flag_CutScoreChange_read="Y"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="State"
gen Lev5_percent=.
gen AvgScaleScore=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

save "${output}/AZ_AssmtData_state_2016.dta", replace


use "${output}/AZ_AssmtData_state_sci_2016.dta", clear

rename GradeCohortHighSchooldefine GradeLevel

drop SchoolType

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


** Generating missing variables
gen AssmtName="AIMS Science"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="State"
gen Lev5_percent=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.

foreach x of numlist 1/5 {
	tostring Lev`x'_percent, replace format("%1.0f")
    ** generate Lev`x'_count = .
    ** label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    ** label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring AvgScaleScore, replace
tostring ProficientOrAbove_percent, replace

save "${output}/AZ_AssmtData_2016_state_sci.dta", replace

use "${output}/AZ_AssmtData_state_2016.dta", clear

tostring AvgScaleScore, replace
tostring Lev5_percent, replace

append using "${output}/AZ_AssmtData_2016_state_sci.dta"

sort GradeLevel Subject

save "${output}/AZ_AssmtData_state_2016.dta", replace

use "${output}/AZ_AssmtData_school_2016.dta", clear

tostring AvgScaleScore, replace

append using "${output}/AZ_AssmtData_district_2016.dta"

save "${output}/AZ_AssmtData_2016.dta", replace

tostring Lev5_percent, replace

append using "${output}/AZ_AssmtData_state_2016.dta"

save "${output}/AZ_AssmtData_2016.dta", replace

drop CountyName County
rename county_name CountyName

gen AssmtType="Regular"

tostring SchYear, replace
replace SchYear="2015-2016"

gen StudentGroup=""
gen State="ARIZONA"

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchlID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

drop SchoolCTDSNumber DistrictCharterHolderCTDSNum LEACTDSNumber year lea_name

sort DataLevel StateAssignedDistID StateAssignedSchlID GradeLevel Subject

save "${output}/AZ_AssmtData_2016.dta", replace

export delimited using"/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2016.csv", replace


