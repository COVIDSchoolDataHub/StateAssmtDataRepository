clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global raw "/Users/minnamgung/Desktop/Arizona/Original Data Files/AIMS"
global output "/Users/minnamgung/Desktop/Arizona/Output/AIMS"
global NCES "/Users/minnamgung/Desktop/Arizona/NCES"




import excel "${raw}/AZ_OriginalData_2012_all.xls", sheet("School by Grade") firstrow clear

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
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(StateAssignedSchID GradeLevel) j(subject, string)

** Rename new variables
rename subject Subject
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

tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
merge m:1 StateAssignedSchID using "${NCES}/NCES_2012_School.dta"

rename school_type SchoolType

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2012.dta", replace


import excel "${raw}/AZ_OriginalData_2012_all.xls", sheet("District by Grade") firstrow clear

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
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(StateAssignedDistID GradeLevel) j(subject, string)

** Rename new variables
rename subject Subject
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

merge m:1 State_leaid using "${NCES}/NCES_2012_District.dta"

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2012.dta", replace



import excel "${raw}/AZ_OriginalData_2012_all.xls", sheet("State by Grade") firstrow clear

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

** Changing file format to "long"
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(GradeLevel) j(subject, string)

** Rename new variables
rename subject Subject
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

sort GradeLevel Subject

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2012.dta", replace


append using "${output}/AZ_AssmtData_school_2012.dta" "${output}/AZ_AssmtData_district_2012.dta"

save "${output}/AZ_AssmtData_2012.dta", replace

rename county CountyName
gen seasch=StateAssignedSchID
gen AssmtType="Regular"

gen AssmtName="AIMS"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen Lev5_percent=""

gen ProficiencyCriteria=""
gen ProficientOrAbove_count=""
gen ParticipationRate=""
gen StudentSubGroup=""
gen StudentGroup_TotalTested=""

foreach x of numlist 1/5 {
    generate Lev`x'_count =""
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

** Replace missing values
foreach v of varlist AvgScaleScore Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
		replace `v' = "-" if `v' == ""
	}

** Rename various values
replace Subject="read" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

tostring SchYear, replace
replace SchYear="2011-12"

drop County LocalEducationAgencyLEACTD SchoolCTDSNumber CharterSchool lea_name year 

replace State="arizona"
replace StateAbbrev="AZ"
replace StateFips=4
replace ProficiencyCriteria="Level 3 and 4"
	
	
order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

save "${output}/AZ_AssmtData_2012.dta", replace

keep if _merge==1
keep SchYear SchName DistName StateAssignedDistID StateAssignedSchID

export delimited using "/Users/minnamgung/Desktop/Arizona/Output/Unmerged/AZ_AssmtData_unmerged_2012.csv", replace

use "${output}/AZ_AssmtData_2012.dta", clear

drop if _merge==2
drop _merge

save "${output}/AZ_AssmtData_2012.dta", replace

export delimited using "/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2012.csv", replace





