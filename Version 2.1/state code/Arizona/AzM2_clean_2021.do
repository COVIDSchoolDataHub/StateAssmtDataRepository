clear
set more off

global AzMERIT "/Users/miramehta/Documents/Arizona/Original Data Files/AzM2-AzMERIT + AIMS Science"
global output "/Users/miramehta/Documents/Arizona/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

// SCHOOLS
/*
** 2021 ELA and Math

import excel "${AzMERIT}/AZ_OriginalData_2021_all.xlsx", sheet("School") firstrow clear

save "${AzMERIT}/AZ_AssmtData_school_2021.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2021_all.xlsx", sheet("District") firstrow clear        
               
save "${AzMERIT}/AZ_AssmtData_district_2021.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2021_all.xlsx", sheet("State") firstrow clear

save "${AzMERIT}/AZ_AssmtData_state_2021.dta", replace
*/


** 2021 School Cleaning 

use "${AzMERIT}/AZ_AssmtData_school_2021.dta", clear

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

drop if strpos(GradeLevel, "Alt") > 0

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

merge m:1 State_leaid using "${NCES}/NCES_2020_District_AZ.dta", force
drop if _merge == 2
drop _merge

//replace StateAssignedSchID = 92731 if SchName == "Leman Academy of Excellence - Central Tucson"
//replace StateAssignedSchID = 92230 if SchName == "Incito Schools-Phoenix"

tostring StateAssignedSchID, generate(seasch)

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2020_School_AZ.dta", force
drop if _merge == 2
drop _merge

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2021_School_AZ.dta", update
drop if _merge == 2
drop _merge

drop if SchName == ""

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2021.dta", replace


** 2021 Dist Cleaning 

use "${AzMERIT}/AZ_AssmtData_district_2021.dta", clear

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

** Generate grade observations from TestLevel variable
drop if strpos(GradeLevel, "Alt") > 0
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2021.dta", replace


gen DataLevel="District"

tostring StateAssignedDistID, replace

gen State_leaid=StateAssignedDistID
merge m:1 State_leaid using "${NCES}/NCES_2020_District_AZ.dta"
drop if _merge == 2
drop _merge

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2021.dta", replace


** 2021 State cleaning 

use "${AzMERIT}/AZ_AssmtData_state_2021.dta", clear
rename Subgroup StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentProficiencyLevel1 Lev1_percent
rename PercentProficiencyLevel2 Lev2_percent
rename PercentProficiencyLevel3 Lev3_percent
rename PercentProficiencyLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

drop if strpos(GradeLevel, "Alt") > 0
keep if District == "All"
drop District
sort GradeLevel Subject

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

gen DataLevel = "State"

save "${output}/AZ_AssmtData_state_2021.dta", replace



** Append all files 
use "${output}/AZ_AssmtData_school_2021.dta", clear

append using "${output}/AZ_AssmtData_district_2021.dta"

save "${output}/AZ_AssmtData_2021.dta", replace

append using "${output}/AZ_AssmtData_state_2021.dta", force

gen SchYear="2020-21"

gen AvgScaleScore = "--"
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
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci="Not applicable"

gen Lev5_percent=""

gen ProficiencyCriteria="Levels 3-4"

gen ParticipationRate="--"

//District wide
replace SchName = "All Schools" if DataLevel == "District" | DataLevel == "State"
replace DistName = "All Districts" if DataLevel == "State"
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)

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
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace format("%9.2g") force
	replace `u' = "*" if `u' == "."
}

replace CountyName = strproper(CountyName)

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific Islander", "Two or more Races", "White", "African American", "Hispanic/Latino")
replace StudentGroup="EL Status" if inlist(StudentSubGroup, "Limited English Proficient")
replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Income Eligibility 1 and 2")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup="Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentGroup="Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup="Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup="Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup="Foster Care Status" if StudentSubGroup == "Foster Care"
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
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID AssmtName Subject GradeLevel)
gen flag = 1 if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup_TotalTested[_n-1] != "*" & StudentSubGroup == StudentSubGroup[_n-1] & uniquegrp == uniquegrp[_n-1]
replace flag = 1 if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup_TotalTested[_n+1] != "*" & StudentSubGroup == StudentSubGroup[_n+1] & uniquegrp == uniquegrp[_n+1]
drop if flag == 1
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
drop uniquegrp flag

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) i(*-)
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = sum(StudentSubGroup_TotalTested2) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"

gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

gen x = 1 if missing(real(StudentSubGroup_TotalTested))
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentGroup: egen flag = sum(x)

replace StudentSubGroup_TotalTested2 = max - RaceEth if StudentGroup == "RaceEth" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Gender if StudentGroup == "Gender" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag <= 1

replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested2) if missing(real(StudentSubGroup_TotalTested)) & StudentSubGroup_TotalTested2 != . & inlist(StudentGroup, "RaceEth", "Gender")
drop if inlist(StudentSubGroup_TotalTested, "", "0") & StudentSubGroup != "All Students"
drop StudentSubGroup_TotalTested2

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
replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

**

foreach v of varlist StudentSubGroup_TotalTested Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `v', gen(`v'2) force
}

replace ProficientOrAbove_percent2 = Lev3_percent2 + Lev4_percent2 if ProficientOrAbove_percent2 == . & Lev3_percent2 != . & Lev4_percent2 != .

gen ProficientOrAbove_count = round(ProficientOrAbove_percent2 * StudentSubGroup_TotalTested2)
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

tostring ProficientOrAbove_percent2, format("%9.2g") replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "."

replace Lev1_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) if missing(real(Lev1_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev2_percent))
replace Lev2_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) if missing(real(Lev2_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent))
replace Lev3_percent2 = real(ProficientOrAbove_percent) - real(Lev4_percent) if missing(real(Lev3_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev4_percent))
replace Lev4_percent2 = real(ProficientOrAbove_percent) - real(Lev3_percent) if missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent))

foreach x of numlist 1/4 {
	replace Lev`x'_percent2 = 0 if Lev`x'_percent2 < 0 & Lev`x'_percent2 != .
	replace Lev`x'_percent = string(Lev`x'_percent2, "%9.2g") if missing(real(Lev`x'_percent)) & Lev`x'_percent2 != .
	replace Lev`x'_percent = "0" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") == 0
	replace Lev`x'_percent = "0-0.02" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") > 0
	gen Lev`x'_count = round(Lev`x'_percent2 * StudentSubGroup_TotalTested2)
	tostring Lev`x'_count, replace force
	replace Lev`x'_count = "*" if Lev`x'_count == "."
}

gen Lev5_count = ""
	
//order
duplicates drop

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/AZ_AssmtData_2021.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2021.csv", replace