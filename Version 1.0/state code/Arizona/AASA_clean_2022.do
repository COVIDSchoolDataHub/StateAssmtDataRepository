clear
set more off

global AASA "/Users/maggie/Desktop/Arizona/AASA"
global AzSci "/Users/maggie/Desktop/Arizona/AzSci"
global output "/Users/maggie/Desktop/Arizona/Output"
global NCES "/Users/maggie/Desktop/Arizona/NCES/Cleaned"

// SCHOOLS

/*
** 2022 ELA and Math

import excel "${AASA}/AZ_OriginalData_2022_all.xlsx", sheet("School") firstrow clear

save "${AASA}/AZ_AssmtData_school_2022.dta", replace

import excel "${AASA}/AZ_OriginalData_2022_all.xlsx", sheet("District") firstrow clear   
                    
save "${AASA}/AZ_AssmtData_district_2022.dta", replace

import excel "${AASA}/AZ_OriginalData_2022_all.xlsx", sheet("State") firstrow clear

save "${AASA}/AZ_AssmtData_state_2022.dta", replace

** 2022 Science

import excel "${AzSci}/AZ_OriginalData_2022_sci.xlsx", sheet("School") firstrow clear

save "${AzSci}/AZ_AssmtData_school_sci_2022.dta", replace

import excel "${AzSci}/AZ_OriginalData_2022_sci.xlsx", sheet("District") firstrow clear

save "${AzSci}/AZ_AssmtData_district_sci_2022.dta", replace

import excel "${AzSci}/AZ_OriginalData_2022_sci.xlsx", sheet("State") firstrow clear

save "${AzSci}/AZ_AssmtData_state_sci_2022.dta", replace

*/

** 2022 School Cleaning 

use "${AASA}/AZ_AssmtData_school_2022.dta", clear

** Rename existing variables
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop Charter DistrictCTDS SchoolCTDS

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

gen State_leaid = StateAssignedDistID
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_school_2022.dta", replace


use "${AzSci}/AZ_AssmtData_school_sci_2022.dta", clear

rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename Subgroup StudentSubGroup

rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

replace Subject="sci"

drop Charter DistrictCTDS SchoolCTDS

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

keep if FAYStatus == "All"

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_2022_school_sci.dta", replace

use "${output}/AZ_AssmtData_school_2022.dta", clear
append using "${output}/AZ_AssmtData_2022_school_sci.dta"

sort StateAssignedSchID GradeLevel Subject
tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta", force
drop _merge

replace lea_name = strproper(lea_name)
replace DistName = lea_name if DistName == ""

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2021_School.dta", force
drop _merge
drop if SchName == ""

sort NCESSchoolID GradeLevel Subject
gen DataLevel="School"

save "${output}/AZ_AssmtData_school_2022.dta", replace


** 2022 Dist Cleaning 

use "${AASA}/AZ_AssmtData_district_2022.dta", clear

** Rename existing variables
rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID

rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop DistrictCTDS

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

gen State_leaid = StateAssignedDistID

save "${output}/AZ_AssmtData_district_2022.dta", replace

use "${AzSci}/AZ_AssmtData_district_sci_2022.dta", clear 

rename DistrictName DistName
rename DistrictEntityID StateAssignedDistID
rename Subgroup StudentSubGroup

rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop DistrictCTDS

replace Subject="sci"

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0

replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

keep if FAYStatus == "All"

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_2022_district_sci.dta", replace

use "${output}/AZ_AssmtData_district_2022.dta", clear

append using "${output}/AZ_AssmtData_2022_district_sci.dta"

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

drop if _merge == 1
drop _merge
drop if StateAssignedDistID == ""

replace lea_name = strproper(lea_name)
replace DistName = lea_name if DistName == ""

sort NCESDistrictID GradeLevel Subject
gen DataLevel="District"

save "${output}/AZ_AssmtData_district_2022.dta", replace


** 2022 State cleaning 

use "${AASA}/AZ_AssmtData_state_2022.dta", clear

rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
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
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

save "${output}/AZ_AssmtData_state_2022.dta", replace

use "${AzSci}/AZ_AssmtData_state_sci_2022.dta", clear

rename TestLevel GradeLevel
rename Subgroup StudentSubGroup

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

replace Subject="sci"

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0

tostring GradeLevel, replace
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")
keep if FAYStatus == "All"

tostring Lev1_percent, replace force
tostring Lev2_percent, replace force
tostring Lev3_percent, replace force
tostring Lev4_percent, replace force

tostring ProficientOrAbove_percent, replace force

save "${output}/AZ_AssmtData_2022_state_sci.dta", replace

use "${output}/AZ_AssmtData_state_2022.dta", clear

append using "${output}/AZ_AssmtData_2022_state_sci.dta"

keep if SchoolType == "All"
drop SchoolType
sort GradeLevel Subject

gen DataLevel="State"

tostring StudentSubGroup_TotalTested, replace force

save "${output}/AZ_AssmtData_state_2022.dta", replace


** Append all files 
append using "${output}/AZ_AssmtData_school_2022.dta" "${output}/AZ_AssmtData_district_2022.dta"

gen SchYear="2021-22"

gen StudentGroup=""
drop State
gen State="Arizona"
drop StateAbbrev
gen StateAbbrev = "AZ"
drop StateFips
gen StateFips = 4

save "${output}/AZ_AssmtData_2022.dta", replace


** Generating missing variables
gen AssmtName="AASA"
replace AssmtName="AzSci" if Subject == "sci"
gen Flag_AssmtNameChange="Y"
gen AssmtType="Regular"

gen AvgScaleScore = "--"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="Y"

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
foreach v of varlist Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ParticipationRate {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace force
	replace `u' = "*" if `u' == "."
}

rename county_name CountyName

replace CountyName = strproper(CountyName)

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Native Hawaiian or Pacific Islander", "Multiple Races", "White", "African American", "Hispanic/Latino")
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian/Alaska Native", "Native Hawaiian/Other Pacific Islander", "Two or More Races", "Black or African American", "Hispanic or Latino", "Two or more Races")
replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Income Eligibility 1 and 2")
replace StudentGroup = "EL Status" if StudentSubGroup == "Limited English Proficient"
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more Races" | StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Income Eligibility 1 and 2"
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
replace Subject="math" if Subject=="Mathematics"

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

save "${output}/AZ_AssmtData_2022.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2022.csv", replace
