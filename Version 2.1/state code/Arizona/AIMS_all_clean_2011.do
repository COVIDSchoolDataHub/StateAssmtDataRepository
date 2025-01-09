clear
set more off

global AIMS "/Users/miramehta/Documents/Arizona/Original Data Files/AIMS"
global output "/Users/miramehta/Documents/Arizona/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EDFacts"

// SCHOOLS

import excel "${AIMS}/AZ_OriginalData_2011_all.xlsx", sheet("School by Grade") firstrow clear

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

merge m:1 State_leaid using "${NCES}/NCES_2010_District_AZ.dta", force
drop if _merge == 2
drop _merge

tostring StateAssignedSchID, generate(seasch)

merge m:1 seasch NCESDistrictID using "${NCES}/NCES_2010_School_AZ.dta", force
drop if _merge == 2
drop _merge

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2011.dta", replace


//DISTRICT

import excel "${AIMS}/AZ_OriginalData_2011_all.xlsx", sheet("District by Grade") firstrow clear

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

merge m:1 State_leaid using "${NCES}/NCES_2010_District_AZ.dta", force
drop if _merge == 2
drop _merge

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2011.dta", replace


//STATE

import excel "${AIMS}/AZ_OriginalData_2011_all.xlsx", sheet("State by Grade") firstrow clear

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

save "${output}/AZ_AssmtData_state_2011.dta", replace


// PUTTING IT TOGETHER

append using "${output}/AZ_AssmtData_school_2011.dta" "${output}/AZ_AssmtData_district_2011.dta"

save "${output}/AZ_AssmtData_2011.dta", replace

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
replace SchYear="2010-11"

drop County LocalEducationAgencyLEACTD SchoolCTDSNumber CharterSchool

replace State="Arizona"
replace StateAbbrev="AZ"
replace StateFips=4

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

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2011/edfactscount2011districtarizona.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop stnam-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2011/edfactscount2011schoolarizona.dta"
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
save "${EDFacts}/AZ_AssmtData_2011_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${EDFacts}/AZ_AssmtData_2011_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge

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

** 

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
destring ProficientOrAbove_percent, gen(ProficientOrAbove_percent2) force

gen ProficientOrAbove_count = round(ProficientOrAbove_percent2 * StudentSubGroup_TotalTested2)
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

foreach x of numlist 1/4 {
    destring Lev`x'_percent, gen(Lev`x'_percent2) force
}

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

drop if strpos(DistName, "Ombudsman") > 0
	
//order
duplicates drop

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/AZ_AssmtData_2011.dta", replace
export delimited using "${output}/csv/AZ_AssmtData_2011.csv", replace


/*
keep if _merge==1
keep SchYear SchName DistName StateAssignedDistID StateAssignedSchID

export delimited using "/Users/minnamgung/Desktop/Arizona/Output/Unmerged/AZ_AssmtData_unmerged_2011.csv", replace

use "${output}/AZ_AssmtData_2011.dta", clear

drop if _merge==2
drop _merge

save "${output}/AZ_AssmtData_2011.dta", replace

export delimited using "/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2011.csv", replace

*/
