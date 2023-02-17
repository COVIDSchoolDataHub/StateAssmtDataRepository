clear
set more off

cd "/Users/minnamgung/Desktop/Arizona"

global raw "/Users/minnamgung/Desktop/Arizona/Original Data Files/AIMS"
global output "/Users/minnamgung/Desktop/Arizona/Output/AIMS"
global NCES "/Users/minnamgung/Desktop/Arizona/NCES"


** All years up to 2013 has same file format

global years 2010 2011 2012 2013 

foreach a in $years {


** CLEANING SCHOOL LEVEL DATA


import excel "${raw}/AZ_OriginalData_`a'_all.xls", sheet("School by Grade") firstrow clear

** Replace missing values
foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing {
		replace `v' = "-" if `v' == ""
	}

** Rename applicable variables
rename FiscalYear SchYear
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID
rename SchoolEntityID StateAssignedSchlID
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
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(StateAssignedSchlID GradeLevel) j(subject, string)

** Rename new variables
rename subject Subject
rename MeanScaleScore AvgScaleScore
rename PercentFallsFarBelow Lev1_percent
rename PercentApproaches Lev2_percent
rename PercentMeets Lev3_percent
rename PercentExceeds Lev4_percent
rename PercentPassing ProficientOrAbove_percent

** Rename various values
replace Subject="read" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

sort StateAssignedSchlID GradeLevel Subject

** Generating missing variables
gen AssmtName="AIMS"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="School"
gen Lev5_percent=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.
gen StudentSubGroup=.
gen StudentGroup_TotalTested=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedDistID, replace
tostring StateAssignedSchlID, replace
merge m:1 StateAssignedSchlID using "${NCES}/NCES_`a'_School.dta"

rename school_type SchoolType

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_`a'.dta", replace



** CLEANING DISTRICT LEVEL DATA


import excel "${raw}/AZ_OriginalData_`a'_all.xls", sheet("District by Grade") firstrow clear

** Replace missing values
foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing {
		replace `v' = "-" if `v' == ""
	}

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

** Rename various values
replace Subject="read" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

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
gen AssmtName="AIMS"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="District"
gen Lev5_percent=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.
gen StudentSubGroup=.
gen StudentGroup_TotalTested=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}


tostring StateAssignedDistID, generate(State_leaid)

tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_`a'_District.dta"

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_`a'.dta", replace





** CLEANING STATE LEVEL DATA


import excel "${raw}/AZ_OriginalData_`a'_all.xls", sheet("State by Grade") firstrow clear

** Replace missing values
foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing {
		replace `v' = "-" if `v' == ""
	}

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

** Rename various values
replace Subject="read" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

sort GradeLevel Subject

gen AssmtName="AIMS"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_`a'.dta", replace



** APPENDING ALL FILES TOGETHER 

append using "${output}/AZ_AssmtData_school_`a'.dta" "${output}/AZ_AssmtData_district_`a'.dta"

save "${output}/AZ_AssmtData_`a'.dta", replace

append using "${output}/AZ_AssmtData_`a'.dta" "${output}/AZ_AssmtData_state_`a'.dta"


rename county CountyName
gen seasch=StateAssignedSchlID
gen AssmtType="Regular"

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchlID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

gen fall_year=`a'-1
tostring fall_year, replace
tostring SchYear, replace
replace SchYear=fall_year+"-"+SchYear
drop fall_year

drop County LocalEducationAgencyLEACTD SchoolCTDSNumber CharterSchool lea_name year 

save "${output}/AZ_AssmtData_`a'.dta", replace

export delimited using"/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_`a'.csv", replace




}


** 2014 alone has a different file format, requires a different code

program clean_school

import excel "${raw}/AZ_OriginalData_2014_all.xls", sheet("2014SchoolGrade") firstrow clear

** Replace missing values
foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing {
		replace `v' = "-" if `v' == ""
	}

** Rename applicable variables
rename FiscalYear SchYear
rename LocalEducationAgencyLEANam DistName
rename LocalEducationAgencyLEAEnt StateAssignedDistID
rename SchoolEntityID StateAssignedSchlID
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
reshape long MeanScaleScore PercentFallsFarBelow PercentApproaches PercentMeets PercentExceeds PercentPassing, i(StateAssignedSchlID GradeLevel) j(subject, string)

** Rename new variables
rename subject Subject
rename MeanScaleScore AvgScaleScore
rename PercentFallsFarBelow Lev1_percent
rename PercentApproaches Lev2_percent
rename PercentMeets Lev3_percent
rename PercentExceeds Lev4_percent
rename PercentPassing ProficientOrAbove_percent

** Rename various values
replace Subject="read" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

sort StateAssignedSchlID GradeLevel Subject

** Generating missing variables
gen AssmtName="AIMS"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="School"
gen Lev5_percent=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.
gen StudentSubGroup=.
gen StudentGroup_TotalTested=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}

tostring StateAssignedDistID, replace
tostring StateAssignedSchlID, replace
merge m:1 StateAssignedSchlID using "${NCES}/NCES_2014_School.dta"

rename school_type SchoolType

sort NCESSchoolID GradeLevel Subject

save "${output}/AZ_AssmtData_school_2014.dta", replace

end







program clean_district

import excel "${raw}/AZ_OriginalData_2014_all.xls", sheet("2014LEAGrade") firstrow clear

** Replace missing values
foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing {
		replace `v' = "-" if `v' == ""
	}

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

** Rename various values
replace Subject="read" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

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
gen AssmtName="AIMS"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="District"
gen Lev5_percent=.

gen ProficiencyCriteria=.
gen ProficientOrAbove_count=.
gen ParticipationRate=.
gen StudentSubGroup=.
gen StudentGroup_TotalTested=.

foreach x of numlist 1/5 {
    generate Lev`x'_count = .
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
    label variable Lev`x'_percent "Percent of students within subgroup performing at Level `x'."
}


tostring StateAssignedDistID, generate(State_leaid)

tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES}/NCES_2014_District.dta"

sort NCESDistrictID GradeLevel Subject

save "${output}/AZ_AssmtData_district_2014.dta", replace

end









program clean_state

import excel "${raw}/AZ_OriginalData_2014_all.xls", sheet("2014StateGrade") firstrow clear

** Replace missing values
foreach v of varlist MathMeanScaleScore MathPercentFallsFarBelow MathPercentApproaches MathPercentMeets MathPercentExceeds MathPercentPassing ReadingMeanScaleScore ReadingPercentFallsFarBelow ReadingPercentApproaches ReadingPercentMeets ReadingPercentExceeds ReadingPercentPassing WritingMeanScaleScore WritingPercentFallsFarBelow WritingPercentApproaches WritingPercentMeets WritingPercentExceeds WritingPercentPassing ScienceMeanScaleScore SciencePercentFallsFarBelow SciencePercentApproaches SciencePercentMeets SciencePercentExceeds SciencePercentPassing {
		replace `v' = "-" if `v' == ""
	}

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

** Rename various values
replace Subject="read" if Subject=="Reading"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace Subject="wri" if Subject=="Writing"

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

sort GradeLevel Subject

gen AssmtName="AIMS"
gen Flag_AssmtNameChange="N"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

gen DataLevel="State"

save "${output}/AZ_AssmtData_state_2014.dta", replace

end


program append_files

append using "${output}/AZ_AssmtData_school_2014.dta" "${output}/AZ_AssmtData_district_2014.dta"

save "${output}/AZ_AssmtData_2014.dta", replace

append using "${output}/AZ_AssmtData_2014.dta" "${output}/AZ_AssmtData_state_2014.dta"

rename county CountyName
gen seasch=StateAssignedSchlID
gen AssmtType="Regular"

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchlID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

tostring SchYear, replace
replace SchYear="2013-2014"

drop County LocalEducationAgencyLEACTD SchoolCTDSNumber CharterSchool lea_name year 

save "${output}/AZ_AssmtData_2014.dta", replace

export delimited using "/Users/minnamgung/Desktop/Arizona/Output/AIMS/csv/AZ_AssmtData_2014.csv", replace

end



