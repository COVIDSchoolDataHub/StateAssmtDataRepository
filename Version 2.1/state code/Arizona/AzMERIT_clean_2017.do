clear
set more off

global AzMERIT "/Users/miramehta/Documents/Arizona/Original Data Files/AzM2-AzMERIT + AIMS Science"
global output "/Users/miramehta/Documents/Arizona/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

/*
** 2017 ELA and Math

import excel "${AzMERIT}/AZ_OriginalData_2017_ela_math.xlsx", sheet("Schools") firstrow clear

save "${AzMERIT}/AZ_AssmtData_school_2017.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2017_ela_math.xlsx", sheet("Districts_Charter Holders") firstrow clear 
                      
save "${AzMERIT}/AZ_AssmtData_district_2017.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2017_ela_math.xlsx", sheet("State") firstrow clear

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

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled Grade 8 Assessment")>0
replace GradeLevel = "G08" if GradeLevel=="Grade 8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

replace StateAssignedSchID = 5844 if SchName == "Indian Oasis Intermediate Elementary School"

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_school_2017.dta", replace


use "${AzMERIT}/AZ_AssmtData_school_sci_2017.dta", clear

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

merge m:1 State_leaid using "${NCES}/NCES_2016_District_AZ.dta", force
drop if _merge == 2
drop _merge

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2016_School_AZ.dta", force
drop if _merge == 2
drop _merge

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

rename ContentArea Subject

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled Grade 8 Assessment")>0
replace GradeLevel = "G08" if GradeLevel=="Grade 8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2017.dta", replace


use "${AzMERIT}/AZ_AssmtData_district_sci_2017.dta", clear 

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

merge m:1 State_leaid using "${NCES}/NCES_2016_District_AZ.dta"
drop if _merge == 2
drop _merge

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

replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8 Enrolled Grade 8 Assessment")>0
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
gen AssmtType="Regular and alt"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci = "N"

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
foreach v of varlist AvgScaleScore ParticipationRate {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace format("%9.2g") force
	replace `u' = "*" if `u' == "."
}

replace CountyName = strproper(CountyName)

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific Islander", "Two or More Races", "White", "African American", "Hispanic/Latino")
replace StudentGroup="EL Status" if inlist(StudentSubGroup, "Limited English Proficient")
replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Economic Disadvantage")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup="Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentGroup="Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup="Homeless Enrolled Status" if StudentSubGroup == "Homeless"
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economic Disadvantage"
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
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace AssmtName = "AIMS Science and AIMS A" if Subject=="sci"

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

save "${output}/AZ_AssmtData_2017.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2017.csv", replace

