clear
set more off

global AzMERIT "/Users/maggie/Desktop/Arizona/AzMERIT"
global output "/Users/maggie/Desktop/Arizona/Output"
global NCES "/Users/maggie/Desktop/Arizona/NCES/Cleaned"
global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

/*
** 2015 ELA and Math

import excel "${AzMERIT}/AZ_OriginalData_2015_ela_math.xlsx", sheet("SCHOOLS") firstrow clear

save "${AzMERIT}/AZ_AssmtData_school_2015.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2015_ela_math.xlsx", sheet("DISTRICTS_CHARTER HOLDERS") firstrow clear 
                      
save "${AzMERIT}/AZ_AssmtData_district_2015.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2015_ela_math.xlsx", sheet("STATE") firstrow clear

save "${AzMERIT}/AZ_AssmtData_state_2015.dta", replace


** 2015 Science

import excel "${AzMERIT}/AZ_OriginalData_2015_sci.xls", sheet("2015SchoolGrade") firstrow clear

save "${AzMERIT}/AZ_AssmtData_school_sci_2015.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2015_sci.xls", sheet("2015LEAGrade") firstrow clear

save "${AzMERIT}/AZ_AssmtData_district_sci_2015.dta", replace

import excel "${AzMERIT}/AZ_OriginalData_2015_sci.xls", sheet("2015StateGrade") firstrow clear

save "${AzMERIT}/AZ_AssmtData_state_sci_2015.dta", replace
*/


** 2015 School Cleaning 

use "${AzMERIT}/AZ_AssmtData_school_2015.dta", clear

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
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_school_2015.dta", replace


use "${AzMERIT}/AZ_AssmtData_school_sci_2015.dta", clear

rename FiscalYear SchYear
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName

rename GradeCohortHighSchooldefine GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

drop State CharterSchool

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${output}/AZ_AssmtData_2015_school_sci.dta", replace

use "${output}/AZ_AssmtData_school_2015.dta", clear
append using "${output}/AZ_AssmtData_2015_school_sci.dta"

sort StateAssignedSchID GradeLevel Subject
tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_2014_District.dta", force
drop if _merge == 2
drop _merge

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2014_School.dta", force
drop if _merge == 2
drop _merge

sort NCESSchoolID GradeLevel Subject
gen DataLevel="School"

save "${output}/AZ_AssmtData_school_2015.dta", replace


** 2015 Dist Cleaning 

use "${AzMERIT}/AZ_AssmtData_district_2015.dta", clear

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

rename ContentArea Subject

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_district_2015.dta", replace


use "${AzMERIT}/AZ_AssmtData_district_sci_2015.dta", clear 

rename FiscalYear SchYear
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID

rename GradeCohortHighSchooldefine GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

drop State 

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${output}/AZ_AssmtData_2015_district_sci.dta", replace

use "${output}/AZ_AssmtData_district_2015.dta", clear

append using "${output}/AZ_AssmtData_2015_district_sci.dta"

merge m:1 State_leaid using "${NCES}/NCES_2014_District.dta"
drop if _merge == 2
drop _merge

sort NCESDistrictID GradeLevel Subject
gen DataLevel="District"

save "${output}/AZ_AssmtData_district_2015.dta", replace


** 2015 State cleaning 

use "${AzMERIT}/AZ_AssmtData_state_2015.dta", clear

rename FiscalYear SchYear
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
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")


save "${output}/AZ_AssmtData_state_2015.dta", replace


use "${AzMERIT}/AZ_AssmtData_state_sci_2015.dta", clear

rename FiscalYear SchYear

rename GradeCohortHighSchooldefine GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

drop State 

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

save "${output}/AZ_AssmtData_2015_state_sci.dta", replace

use "${output}/AZ_AssmtData_state_2015.dta", clear

append using "${output}/AZ_AssmtData_2015_state_sci.dta"

keep if inlist(SchoolType, "All", "")
drop SchoolType
sort GradeLevel Subject

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2015.dta", replace


** Append all files 
append using "${output}/AZ_AssmtData_school_2015.dta" "${output}/AZ_AssmtData_district_2015.dta"

tostring SchYear, replace
replace SchYear="2014-15"

gen StudentGroup=""

drop State
gen State="Arizona"
drop StateAbbrev
gen StateAbbrev = "AZ"
drop StateFips
gen StateFips = 4

save "${output}/AZ_AssmtData_2015.dta", replace


** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="Y" if Subject != "sci"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen AssmtType="Regular and alt"

gen Flag_CutScoreChange_ELA="Y"
gen Flag_CutScoreChange_math="Y"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci = "N"

gen Lev5_percent=""

gen ProficiencyCriteria="Levels 3-4"
gen ParticipationRate="--"

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

foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore ParticipationRate {
	replace `v' = "--" if `v' == ""
}
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace format("%9.2g") force
	replace `u' = "*" if `u' == "."
}

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific", "Two or More Races", "White", "African American", "Hispanic/Latino")
replace StudentGroup="EL Status" if inlist(StudentSubGroup, "Limited English Proficient")
replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup="Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentGroup="Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup="Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "All Students" if Subject == "sci"
replace StudentSubGroup = "All Students" if Subject == "sci"
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/Other Pacific"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace AssmtName = "AIMS Science and AIMS A" if Subject=="sci"

replace CountyName = strproper(CountyName)

//sort
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop DataLevel 
rename DataLevel_n DataLevel 
replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

** Merging with EDFacts Datasets

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactscount2015districtarizona.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop stnam-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactspart2015districtarizona.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop stnam-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactscount2015schoolarizona.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop stnam-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2015/edfactspart2015schoolarizona.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop stnam-_merge

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort State_leaid seasch StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0"
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

**

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
destring ProficientOrAbove_percent, gen(ProficientOrAbove_percent2) force

gen ProficientOrAbove_count = round(ProficientOrAbove_percent2 * StudentSubGroup_TotalTested2)
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

foreach x of numlist 1/4 {
    destring Lev`x'_percent, gen(Lev`x'_percent2) force
	gen Lev`x'_count = round(Lev`x'_percent2 * StudentSubGroup_TotalTested2)
	tostring Lev`x'_count, replace force
	replace Lev`x'_count = "*" if Lev`x'_count == "."
	replace Lev`x'_count = "--" if StudentSubGroup_TotalTested == "--"
}

gen Lev5_count = ""

replace DistName = "ASU Preparatory Academy" if inlist(NCESDistrictID, "0400764", "0400857", "0400884", "0400890")
	
//order
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/AZ_AssmtData_2015.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2015.csv", replace
