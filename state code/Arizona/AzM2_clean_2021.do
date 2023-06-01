clear
set more off

global raw "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/Original Data"
global output "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/Output"
global NCES "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/NCES"

// SCHOOLS

** 2021 ELA and Math
/*
import excel "${raw}/AZ_OriginalData_2021_all.xlsx", sheet("School") firstrow clear

save "${raw}/AZ_AssmtData_school_2021.dta", replace

import excel "${raw}/AZ_OriginalData_2021_all.xlsx", sheet("District") firstrow clear        
               
save "${raw}/AZ_AssmtData_district_2021.dta", replace

import excel "${raw}/AZ_OriginalData_2021_all.xlsx", sheet("State") firstrow clear

save "${raw}/AZ_AssmtData_state_2021.dta", replace
*/


** 2021 School Cleaning 

use "${raw}/AZ_AssmtData_school_2021.dta", clear

** Rename existing variables
rename FiscalYear SchYear
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

drop Charter

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

sort StateAssignedSchID GradeLevel Subject

gen DataLevel="School"

tostring StateAssignedDistID, generate(State_leaid)

tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_2020_District.dta", force
drop _merge

replace lea_name = strproper(lea_name)
replace DistName = lea_name if DistName == ""

replace StateAssignedSchID = 92731 if SchName == "Leman Academy of Excellence - Central Tucson"
replace StateAssignedSchID = 92230 if SchName == "Incito Schools-Phoenix"

tostring StateAssignedSchID, generate(seasch)

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2020_School.dta", force
drop _merge
drop if SchName == ""

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2021.dta", replace


** 2021 Dist Cleaning 

use "${raw}/AZ_AssmtData_district_2021.dta", clear

** Rename existing variables
rename FiscalYear SchYear
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

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2021.dta", replace


gen DataLevel="District"

tostring StateAssignedDistID, replace

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2020_District.dta"
drop _merge
drop if StateAssignedDistID == ""

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2021.dta", replace


** 2021 State cleaning 

use "${raw}/AZ_AssmtData_state_2021.dta", clear
rename FiscalYear SchYear
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

keep if inlist(SchoolType, "All", "")
drop SchoolType
sort GradeLevel Subject

gen AvgScaleScore=""

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

gen DataLevel = "State"

save "${output}/AZ_AssmtData_state_2021.dta", replace



** Append all files 
use "${output}/AZ_AssmtData_school_2021.dta", clear

append using "${output}/AZ_AssmtData_district_2021.dta"

save "${output}/AZ_AssmtData_2021.dta", replace

append using "${output}/AZ_AssmtData_state_2021.dta", force

tostring SchYear, replace
replace SchYear="2020-21"

gen StudentGroup=""
drop State
gen State="Arizona"
drop StateAbbrev
gen StateAbbrev="AZ"
drop StateFips
gen StateFips = 4

save "${output}/AZ_AssmtData_2021.dta", replace


** Generating missing variables
gen AssmtName="AzM2"
gen Flag_AssmtNameChange="Y"
gen AssmtType="Regular"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth=""

gen Lev5_percent=""

gen ProficiencyCriteria="Levels 3 and 4"

gen ProficientOrAbove_count=""
gen ParticipationRate=""
gen StudentGroup_TotalTested = "-"

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
foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ParticipationRate {
	tostring `v', replace
	replace `v' = "-" if `v' == "" | `v' == "."
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
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific Islander", "Two or more Races", "White", "African American", "Hispanic/Latino", "Unknown")
replace StudentGroup="EL Status" if inlist(StudentSubGroup, "Limited English Proficient")
replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Income Eligibility 1 and 2")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup = "All Students" if Subject == "sci"
replace StudentSubGroup = "All Students" if Subject == "sci"
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/Other Pacific Islander"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more Races"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Income Eligibility 1 and 2"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"

replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Mathematics"
replace Subject="sci" if Subject=="Science"
replace AssmtName = "AIMS Science" if Subject=="sci"

//sort
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop DataLevel 
rename DataLevel_n DataLevel 
replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3

// Insert Robert J. C. Rice data from 2021 NCES School
replace NCESSchoolID = "040187003766" if SchName == "Robert J.C. Rice Elementary School"
replace SchType = "Regular school" if SchName == "Robert J.C. Rice Elementary School"
replace SchLevel = "Primary" if SchName == "Robert J.C. Rice Elementary School"


	
//order
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

save "${output}/AZ_AssmtData_2021.dta", replace
export delimited using "${output}/AZ_AssmtData_2021.csv", replace

