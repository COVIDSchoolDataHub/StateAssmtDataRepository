clear
set more off

global AIMS "/Users/maggie/Desktop/Arizona/AIMS"
global output "/Users/maggie/Desktop/Arizona/Output"
global NCES "/Users/maggie/Desktop/Arizona/NCES/Cleaned"
global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

// SCHOOLS

import excel "${AIMS}/AZ_OriginalData_2010_all.xlsx", sheet("School by Grade") firstrow clear

** Rename applicable variables
rename FiscalYear SchYear
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename GradeCohortHighSchooldefine GradeLevel

foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing  {
		local new = substr("`v'", 5, .)+"Math"
        rename `v' `new'
}

foreach v of varlist ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing  {
		local new = substr("`v'", 8, .)+"Reading"
        rename `v' `new'
}

foreach v of varlist WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing  {
		local new = substr("`v'", 8, .)+"Writing"
        rename `v' `new'
}

foreach v of varlist ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing  {
		local new = substr("`v'", 8, .)+"Science"
        rename `v' `new'
}

** Changing file format to "long"
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(StateAssignedSchID GradeLevel) j(Subject, string)

** Rename new variables
rename MeanScaleScore AvgScaleScore
rename PercentFallsFarBelow Lev1_percent
rename PercentApproaches Lev2_percent
rename PercentMeets Lev3_percent
rename PercentExceeds Lev4_percent
rename PercentPassing ProficientOrAbove_percent

** Rename various values
tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

sort StateAssignedSchID GradeLevel Subject

gen DataLevel="School"

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_2009_District.dta", force
drop if _merge == 2
drop _merge

tostring StateAssignedSchID, generate(seasch)

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2009_School.dta", force
drop if _merge == 2
drop _merge

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2010.dta", replace


// DISTRICT

import excel "${AIMS}/AZ_OriginalData_2010_all.xlsx", sheet("District by Grade") firstrow clear

** Rename applicable variables
rename FiscalYear SchYear
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID
rename GradeCohortHighSchooldefine GradeLevel

foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing  {
		local new = substr("`v'", 5, .)+"Math"
        rename `v' `new'
}

foreach v of varlist ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing  {
		local new = substr("`v'", 8, .)+"Reading"
        rename `v' `new'
}

foreach v of varlist WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing  {
		local new = substr("`v'", 8, .)+"Writing"
        rename `v' `new'
}

foreach v of varlist ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing  {
		local new = substr("`v'", 8, .)+"Science"
        rename `v' `new'
}

** Changing file format to "long"
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(StateAssignedDistID GradeLevel) j(Subject, string)

** Rename new variables
rename MeanScaleScore AvgScaleScore
rename PercentFallsFarBelow Lev1_percent
rename PercentApproaches Lev2_percent
rename PercentMeets Lev3_percent
rename PercentExceeds Lev4_percent
rename PercentPassing ProficientOrAbove_percent

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

sort StateAssignedDistID GradeLevel Subject

** Generating missing variables

gen DataLevel="District"

tostring StateAssignedDistID, generate(State_leaid)

tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_2009_District.dta", force
drop if _merge == 2
drop _merge

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2010.dta", replace


//STATE

import excel "${AIMS}/AZ_OriginalData_2010_all.xlsx", sheet("State by Grade") firstrow clear

** Rename applicable variables
rename FiscalYear SchYear
rename GradeCohortHighSchooldefine GradeLevel

foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing  {
		local new = substr("`v'", 5, .)+"Math"
        rename `v' `new'
}

foreach v of varlist ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing  {
		local new = substr("`v'", 8, .)+"Reading"
        rename `v' `new'
}

foreach v of varlist WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing  {
		local new = substr("`v'", 8, .)+"Writing"
        rename `v' `new'
}

foreach v of varlist ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing  {
		local new = substr("`v'", 8, .)+"Science"
        rename `v' `new'
}

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

** Changing file format to "long"
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(GradeLevel) j(Subject, string)


** Rename new variables
rename MeanScaleScore AvgScaleScore
rename PercentFallsFarBelow Lev1_percent
rename PercentApproaches Lev2_percent
rename PercentMeets Lev3_percent
rename PercentExceeds Lev4_percent
rename PercentPassing ProficientOrAbove_percent

sort GradeLevel Subject

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2010.dta", replace


//PUTTING IT TOGETHER

append using "${output}/AZ_AssmtData_school_2010.dta" "${output}/AZ_AssmtData_district_2010.dta"

save "${output}/AZ_AssmtData_2010.dta", replace

gen AssmtType="Regular and alt"

gen AssmtName="AIMS"
replace AssmtName = "AIMS Science and AIMS A" if Subject == "Science"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci="N"

gen Lev5_percent=""

gen ProficiencyCriteria="Levels 3-4"
gen ParticipationRate=""
gen StudentGroup = "All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested="--"

** Replace missing values
foreach v of varlist AvgScaleScore ParticipationRate {
	replace `v' = "--" if `v' == ""
}

foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace format("%9.2g") force
	replace `u' = "*" if `u' == "."
}

** Rename various values
replace Subject="ela" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

tostring SchYear, replace
replace SchYear="2009-10"

drop County LocalEducationAgencyLEACTD SchoolCTDSNumber CharterSchool 

replace State="Arizona"
replace StateAbbrev="AZ"
replace StateFips=4

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

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2010/edfactscount2010districtarizona.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop stnam-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2010/edfactscount2010schoolarizona.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop stnam-_merge

** State counts

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${EDFacts}/AZ_AssmtData_2010_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${EDFacts}/AZ_AssmtData_2010_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge

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

drop if strpos(DistName, "Ombudsman") > 0
replace CountyName = "Maricopa County" if NCESDistrictID == "0400234"
replace CountyCode = "4013" if NCESDistrictID == "0400234"
	
//order
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/AZ_AssmtData_2010.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2010.csv", replace

/*
keep if _merge==1
keep SchYear SchName DistName StateAssignedDistID StateAssignedSchID

export delimited using "${output}/AZ_AssmtData_unmerged_2010.csv", replace

use "${output}/AZ_AssmtData_2010.dta", clear

drop if _merge==2
drop _merge

save "${output}/AZ_AssmtData_2010.dta", replace

export delimited using "${output}/AZ_AssmtData_2010.csv", replace

*/
