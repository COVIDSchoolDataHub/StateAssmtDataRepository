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

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"
drop _merge

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2021_School.dta"
drop _merge
drop if SchName == ""

sort NCESSchoolID GradeLevel Subject
gen DataLevel = "School"

** Updating 2023 districts

replace DistType = 7 if StateAssignedDistID == "90915"
replace NCESDistrictID = "0400832" if StateAssignedDistID == "90915"
replace DistCharter = "Yes" if StateAssignedDistID == "90915"

replace DistType = 7 if StateAssignedDistID == "1001937"
replace NCESDistrictID = "0409737" if StateAssignedDistID == "1001937"
replace DistCharter = "Yes" if StateAssignedDistID == "1001937"

replace DistType = 7 if DistName == "Legacy Traditional School-San Tan"
replace NCESDistrictID = "0409736" if DistName == "Legacy Traditional School-San Tan"
replace DistCharter = "Yes" if DistName == "Legacy Traditional School-San Tan"

replace county_name = "Missing/not reported" if inlist(DistName, "Archway Classical Academy Trivium West", "Legacy Traditional School-San Tan")
replace CountyCode = -1 if inlist(DistName, "Archway Classical Academy Trivium West", "Legacy Traditional School-San Tan")
label def county_codedf -1 "Missing/not reported", modify

**** Updating 2023 schools

replace SchType = 1 if SchName == "Bravie T. Soto Elementary School"
replace NCESSchoolID = "040789003813" if SchName == "Bravie T. Soto Elementary School"

replace SchType = 1 if SchName == "Crismon High School"
replace NCESSchoolID = "040681003802" if SchName == "Crismon High School"

replace SchType = 4 if SchName == "Desert Sunset Elementary School"
replace NCESSchoolID = "040717003804" if SchName == "Desert Sunset Elementary School"

replace SchType = 1 if SchName == "Great Hearts Online - Arizona"
replace NCESSchoolID = "040973703762" if SchName == "Great Hearts Online - Arizona"

replace SchType = 1 if SchName == "Inspiration Mountain School"
replace NCESSchoolID = "040775003803" if SchName == "Inspiration Mountain School"

replace SchType = 1 if SchName == "La Paloma Academy Marana"
replace NCESSchoolID = "040019003824" if SchName == "La Paloma Academy Marana"

replace SchType = 1 if SchName == "Leading Edge Academy Flagstaff"
replace NCESSchoolID = "040039503826" if SchName == "Leading Edge Academy Flagstaff"

replace SchType = 4 if SchName == "Legacy Traditional-San Tan"
replace NCESSchoolID = "040973603835" if SchName == "Legacy Traditional-San Tan"

replace SchType = 1 if SchName == "Path to Potential"
replace NCESSchoolID = "040095303833" if SchName == "Path to Potential"

replace SchType = 1 if NCESDistrictID == "0406250" & StateAssignedSchID == "5004"
replace NCESSchoolID = "040625001425" if NCESDistrictID == "0406250" & StateAssignedSchID == "5004"

replace SchType = 1 if NCESDistrictID == "0407890" & StateAssignedSchID == "1001915"
replace NCESSchoolID = "040789003814" if NCESDistrictID == "0407890" & StateAssignedSchID == "1001915"

replace SchType = 1 if SchName == "Washington Elementary School District Online Learning Academy"
replace NCESSchoolID = "040906003805" if SchName == "Washington Elementary School District Online Learning Academy"

replace SchLevel = -1 if SchName == "Bravie T. Soto Elementary School" | SchName == "Crismon High School" | SchName == "Desert Sunset Elementary School" | SchName == "Great Hearts Online - Arizona" | SchName == "Inspiration Mountain School" | SchName == "La Paloma Academy Marana" | SchName == "Leading Edge Academy Flagstaff" | SchName == "Legacy Traditional-San Tan" | SchName == "Path to Potential" | SchName == "Sun Valley Elementary School" | SchName == "Washington Elementary School District Online Learning Academy"
replace SchVirtual = -1 if SchName == "Bravie T. Soto Elementary School" | SchName == "Crismon High School" | SchName == "Desert Sunset Elementary School" | SchName == "Great Hearts Online - Arizona" | SchName == "Inspiration Mountain School" | SchName == "La Paloma Academy Marana" | SchName == "Leading Edge Academy Flagstaff" | SchName == "Legacy Traditional-San Tan" | SchName == "Path to Potential" | SchName == "Sun Valley Elementary School" | SchName == "Washington Elementary School District Online Learning Academy"
label def SchLevel -1 "Missing/not reported"
label def SchVirtual -1 "Missing/not reported"

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

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"
drop _merge
drop if DistName == ""

sort NCESDistrictID GradeLevel Subject
gen DataLevel = "District"

** Updating 2023 districts

replace DistType = 7 if StateAssignedDistID == "90915"
replace NCESDistrictID = "0400832" if StateAssignedDistID == "90915"
replace DistCharter = "Yes" if StateAssignedDistID == "90915"

replace DistType = 7 if StateAssignedDistID == "1001937"
replace NCESDistrictID = "0409737" if StateAssignedDistID == "1001937"
replace DistCharter = "Yes" if StateAssignedDistID == "1001937"

replace DistType = 7 if DistName == "Legacy Traditional School-San Tan"
replace NCESDistrictID = "0409736" if DistName == "Legacy Traditional School-San Tan"
replace DistCharter = "Yes" if DistName == "Legacy Traditional School-San Tan"

replace county_name = "Missing/not reported" if inlist(DistName, "Archway Classical Academy Trivium West", "Legacy Traditional School-San Tan")
replace CountyCode = -1 if inlist(DistName, "Archway Classical Academy Trivium West", "Legacy Traditional School-San Tan")
label def county_codedf -1 "Missing/not reported", modify

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
gen Flag_CutScoreChange_soc = ""
gen Flag_CutScoreChange_sci = "N"

gen AvgScaleScore = "--"

gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = "--"
gen ParticipationRate = "--"

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
foreach v of varlist Lev1_count Lev2_count Lev3_count Lev4_count {
	tostring `v', replace
	replace `v' = "--" if `v' == ""
}
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', generate(`u'2) force
	replace `u'2 = `u'2 / 100
	tostring `u'2, replace force
	replace `u' = `u'2 if `u'2 != "."
	replace `u' = "0-0.02" if `u' == "<2"
	replace `u' = "0.98-1" if `u' == ">98"
	drop `u'2
}

rename county_name CountyName

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

replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3

	
//order
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

save "${output}/AZ_AssmtData_2023.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2023.csv", replace
