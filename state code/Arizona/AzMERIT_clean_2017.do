clear
set more off

global AzMERIT "/Users/maggie/Desktop/Arizona/AzMERIT"
global output "/Users/maggie/Desktop/Arizona/Output"
global NCES "/Users/maggie/Desktop/Arizona/NCES/Cleaned"

/*
** 2017 ELA and Math

import excel "${AzMERIT}/AZ_OriginalData_2017_all.xlsx", sheet("Schools") firstrow clear

save "${AzMERIT}/AZ_AssmtData_school_2017.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2017_all.xlsx", sheet("Districts_Charter Holders") firstrow clear 
                      
save "${AzMERIT}/AZ_AssmtData_district_2017.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2017_all.xlsx", sheet("State") firstrow clear

save "${AzMERIT}/AZ_AssmtData_state_2017.dta", replace


** 2017 Science

import excel "${AzMERIT}/AZ_OriginalData_2017_sci.xlsx", sheet("School by Grade by Subgroup") firstrow clear

save "${AzMERIT}/AZ_AssmtData_school_sci_2017.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2017_sci.xlsx", sheet("LEA by Grade by Subgroup") firstrow clear

save "${AzMERIT}/AZ_AssmtData_district_sci_2017.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2017_sci.xlsx", sheet("State by Grade by Subgroup") firstrow clear

save "${AzMERIT}/AZ_AssmtData_state_sci_2017.dta", replace
*/

** 2017 School Cleaning 

use "${AzMERIT}/AZ_AssmtData_school_2017.dta", clear

** Rename existing variables
rename DistrictCharterHolderName DistName
rename DistrictCharterHolderEntityI StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename SubgroupEthnicity StudentSubGroup
rename NumberTested StudentSubGroup_TotalTested
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

replace StateAssignedSchID = 5844 if SchName == "Indian Oasis Intermediate Elementary School"

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_school_2017.dta", replace


use "${AzMERIT}/AZ_AssmtData_school_sci_2017.dta", clear

rename County CountyName
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore
rename SubgroupEthnicity StudentSubGroup
rename NumberTested StudentSubGroup_TotalTested

replace Subject="sci"

drop CharterSchool

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_2017_school_sci.dta", replace

use "${output}/AZ_AssmtData_school_2017.dta", clear
append using "${output}/AZ_AssmtData_2017_school_sci.dta"

sort StateAssignedSchID GradeLevel Subject
tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_2016_District.dta", force
drop _merge

replace lea_name = strproper(lea_name)
replace DistName = lea_name if DistName == ""

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2016_School.dta", force
drop _merge
drop if SchName == ""

sort NCESSchoolID GradeLevel Subject
gen DataLevel="School"

save "${output}/AZ_AssmtData_school_2017.dta", replace


** 2017 Dist Cleaning 

use "${AzMERIT}/AZ_AssmtData_district_2017.dta", clear

** Rename existing variables
rename DistrictCharterHolderName DistName
rename DistrictCharterHolderEntityI StateAssignedDistID

rename SubgroupEthnicity StudentSubGroup
rename NumberTested StudentSubGroup_TotalTested
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

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2017.dta", replace


use "${AzMERIT}/AZ_AssmtData_district_sci_2017.dta", clear 

rename County CountyName
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore
rename SubgroupEthnicity StudentSubGroup
rename NumberTested StudentSubGroup_TotalTested

replace Subject="sci"


** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_2017_district_sci.dta", replace

use "${output}/AZ_AssmtData_district_2017.dta", clear

append using "${output}/AZ_AssmtData_2017_district_sci.dta"

merge m:1 State_leaid using "${NCES}/NCES_2016_District.dta"
drop _merge
drop if StateAssignedDistID == ""

replace lea_name = strproper(lea_name)
replace DistName = lea_name if DistName == ""

sort NCESDistrictID GradeLevel Subject
gen DataLevel="District"

save "${output}/AZ_AssmtData_district_2017.dta", replace


** 2017 State cleaning 

use "${AzMERIT}/AZ_AssmtData_state_2017.dta", clear

rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel
rename NumberTested StudentSubGroup_TotalTested
rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

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


save "${output}/AZ_AssmtData_state_2017.dta", replace


use "${AzMERIT}/AZ_AssmtData_state_sci_2017.dta", clear

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore
rename SubgroupEthnicity StudentSubGroup
rename NumberTested StudentSubGroup_TotalTested

replace Subject="sci"

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

save "${output}/AZ_AssmtData_2017_state_sci.dta", replace

use "${output}/AZ_AssmtData_state_2017.dta", clear

append using "${output}/AZ_AssmtData_2017_state_sci.dta"

keep if inlist(SchoolType, "All", "")
drop SchoolType
sort GradeLevel Subject

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2017.dta", replace


** Append all files 
append using "${output}/AZ_AssmtData_school_2017.dta" "${output}/AZ_AssmtData_district_2017.dta"

gen SchYear="2016-17"

gen StudentGroup=""
drop State
gen State="Arizona"
drop StateAbbrev
gen StateAbbrev = "AZ"
drop StateFips
gen StateFips = 4

save "${output}/AZ_AssmtData_2017.dta", replace


** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"
gen AssmtType="Regular"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"

gen Lev5_percent=""

gen ProficiencyCriteria="Levels 3 and 4"
gen ProficientOrAbove_count="--"
gen ParticipationRate="--"

//District wide
replace SchName = "All Schools" if DataLevel == "District" | DataLevel == "State"
replace DistName = "All Districts" if DataLevel == "State"

//Fixing types
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if StateAssignedSchID == "."
decode DistType, generate(new)
drop DistType
rename new DistType
decode SchLevel, generate(new)
drop SchLevel
rename new SchLevel
decode SchType, generate(new)
drop SchType
rename new SchType
recast int CountyCode
decode SchVirtual, generate(new)
drop SchVirtual
rename new SchVirtual

foreach x of numlist 1/5 {
    generate Lev`x'_count = ""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

** Replace missing values
foreach v of varlist AvgScaleScore Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ParticipationRate {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace force
	replace `u' = "*" if `u' == "."
}

drop CountyName County
rename county_name CountyName

replace CountyName = strproper(CountyName)

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific", "Two or More Races", "White", "African American", "Hispanic/Latino", "Unknown")
replace StudentGroup="EL Status" if inlist(StudentSubGroup, "Limited English Proficient")
replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/Other Pacific"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"

gen StudentSubGroup_TotalTested2 = StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace AssmtName = "AIMS Science" if Subject=="sci"

//sort
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop DataLevel 
rename DataLevel_n DataLevel 
replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3
	
//order
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

save "${output}/AZ_AssmtData_2017.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2017.csv", replace

