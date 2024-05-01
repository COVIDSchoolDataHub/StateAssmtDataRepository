clear
set more off

global AASA "/Users/maggie/Desktop/Arizona/AASA"
global AzSci "/Users/maggie/Desktop/Arizona/AzSci"
global output "/Users/maggie/Desktop/Arizona/Output"
global NCES "/Users/maggie/Desktop/Arizona/NCES/Cleaned"

// SCHOOLS

/*
** 2023 ELA and Math

import excel "${AASA}/AZ_OriginalData_2023_all.xlsx", sheet("School") firstrow clear

save "${AASA}/AZ_AssmtData_school_2023.dta", replace

import excel "${AASA}/AZ_OriginalData_2023_all.xlsx", sheet("District") firstrow clear   
                    
save "${AASA}/AZ_AssmtData_district_2023.dta", replace

import excel "${AASA}/AZ_OriginalData_2023_all.xlsx", sheet("State") firstrow clear

save "${AASA}/AZ_AssmtData_state_2023.dta", replace

** 2023 Science

import excel "${AzSci}/AZ_OriginalData_2023_sci.xlsx", sheet("School") firstrow clear

save "${AzSci}/AZ_AssmtData_school_sci_2023.dta", replace

import excel "${AzSci}/AZ_OriginalData_2023_sci.xlsx", sheet("District") firstrow clear

save "${AzSci}/AZ_AssmtData_district_sci_2023.dta", replace

import excel "${AzSci}/AZ_OriginalData_2023_sci.xlsx", sheet("State") firstrow clear

save "${AzSci}/AZ_AssmtData_state_sci_2023.dta", replace

*/

** 2023 School Cleaning 

use "${AASA}/AZ_AssmtData_school_2023.dta", clear

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

drop Charter Alternative DistrictCTDS SchoolCTDS

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_school_2023.dta", replace


use "${AzSci}/AZ_AssmtData_school_sci_2023.dta", clear

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

save "${output}/AZ_AssmtData_2023_school_sci.dta", replace

use "${output}/AZ_AssmtData_school_2023.dta", clear
append using "${output}/AZ_AssmtData_2023_school_sci.dta"

merge m:1 State_leaid using "${NCES}/NCES_2022_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2022_School.dta"
drop if _merge == 2
drop _merge

sort NCESSchoolID GradeLevel Subject
gen DataLevel = "School"

save "${output}/AZ_AssmtData_school_2023.dta", replace





** 2023 Dist Cleaning 

use "${AASA}/AZ_AssmtData_district_2023.dta", clear

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
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2023.dta", replace

use "${AzSci}/AZ_AssmtData_district_sci_2023.dta", clear 

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

save "${output}/AZ_AssmtData_2023_district_sci.dta", replace

use "${output}/AZ_AssmtData_district_2023.dta", clear

append using "${output}/AZ_AssmtData_2023_district_sci.dta"

merge m:1 State_leaid using "${NCES}/NCES_2022_District.dta"
drop if _merge == 2
drop _merge

sort NCESDistrictID GradeLevel Subject
gen DataLevel = "District"

save "${output}/AZ_AssmtData_district_2023.dta", replace


** 2023 State cleaning 

use "${AASA}/AZ_AssmtData_state_2023.dta", clear

rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")


save "${output}/AZ_AssmtData_state_2023.dta", replace

use "${AzSci}/AZ_AssmtData_state_sci_2023.dta", clear

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

save "${output}/AZ_AssmtData_2023_state_sci.dta", replace

use "${output}/AZ_AssmtData_state_2023.dta", clear

append using "${output}/AZ_AssmtData_2023_state_sci.dta"

keep if SchoolType == "All"
drop SchoolType
sort GradeLevel Subject

gen DataLevel = "State"

tostring StudentSubGroup_TotalTested, replace force

save "${output}/AZ_AssmtData_state_2023.dta", replace


** Append all files 
append using "${output}/AZ_AssmtData_school_2023.dta" "${output}/AZ_AssmtData_district_2023.dta"

gen SchYear = "2022-23"

gen StudentGroup = ""
drop State
gen State = "Arizona"
drop StateAbbrev
gen StateAbbrev = "AZ"
drop StateFips
gen StateFips = 4

save "${output}/AZ_AssmtData_2023.dta", replace


** Generating missing variables

keep if FAYStatus == "All"

gen AssmtName="AASA"
replace AssmtName="AzSci" if Subject == "sci"
gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

gen AvgScaleScore = "--"

gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"

//District wide
replace SchName = "All Schools" if DataLevel == "District" | DataLevel == "State"
replace DistName = "All Districts" if DataLevel == "State"

//Fixing types
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if StateAssignedSchID == "."
decode SchLevel, generate(new)
drop SchLevel
rename new SchLevel
decode SchType, generate(new)
drop SchType
rename new SchType
decode SchVirtual, generate(new)
drop SchVirtual
rename new SchVirtual

** Replace missing values
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', generate(`u'2) force
	replace `u'2 = `u'2 / 100
	tostring `u'2, replace format("%9.2g") force
	replace `u' = `u'2 if `u'2 != "."
	replace `u' = "0-0.02" if `u' == "<2"
	replace `u' = "0.98-1" if `u' == ">98"
	drop `u'2
}

replace CountyName = strproper(CountyName)

replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "Two or more Races", "White")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Income Eligibility 1 and 2")
replace StudentGroup = "EL Status" if StudentSubGroup == "Limited English Proficient"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup="Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentGroup="Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup="Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup="Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup="Foster Care Status" if StudentSubGroup == "Foster Care"
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more Races"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Income Eligibility 1 and 2"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

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

**

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
destring ProficientOrAbove_percent, gen(ProficientOrAbove_percent2) force

gen ProficientOrAbove_count = round(ProficientOrAbove_percent2 * StudentSubGroup_TotalTested2)
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

foreach x of numlist 1/4 {
    destring Lev`x'_percent, gen(Lev`x'_percent2) force
	gen Lev`x'_count = round(Lev`x'_percent2 * StudentSubGroup_TotalTested2)
	tostring Lev`x'_count, replace force
	replace Lev`x'_count = "*" if Lev`x'_count == "."
}

gen Lev5_count = ""

//order

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/AZ_AssmtData_2023.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2023.csv", replace
