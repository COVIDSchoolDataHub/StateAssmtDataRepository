
global source "/Users/hayden/Desktop/Research/IN/Pre 2014"
global yrfiles "/Users/hayden/Desktop/Research/IN/2009"
global nces "/Users/hayden/Desktop/Research/NCES"
global output "/Users/hayden/Desktop/Research/IN/Output"


//////	Import District Data

import excel "/${source}/IN_OriginalData_2005-2015_mat&ela_dist.xlsx", sheet("Spring 2009") cellrange(A2:AL340) firstrow clear


// rename variables to add grades

rename ELAPassN ProficientOrAbove_count_ELA_3
rename ELAPercentPass ProficientOrAbove_percent_ELA_3
rename MathPassN ProficientOrAbove_count_Math_3
rename MathPercentPass ProficientOrAbove_percent_Math_3

rename H ProficientOrAbove_count_ELA_4
rename I ProficientOrAbove_percent_ELA_4
rename J ProficientOrAbove_count_Math_4
rename K ProficientOrAbove_percent_Math_4

rename M ProficientOrAbove_count_ELA_5
rename N ProficientOrAbove_percent_ELA_5
rename O ProficientOrAbove_count_Math_5
rename P ProficientOrAbove_percent_Math_5

rename R ProficientOrAbove_count_ELA_6
rename S ProficientOrAbove_percent_ELA_6
rename T ProficientOrAbove_count_Math_6
rename U ProficientOrAbove_percent_Math_6

rename W ProficientOrAbove_count_ELA_7
rename X ProficientOrAbove_percent_ELA_7
rename Y ProficientOrAbove_count_Math_7
rename Z ProficientOrAbove_percent_Math_7

rename AB ProficientOrAbove_count_ELA_8
rename AC ProficientOrAbove_percent_ELA_8
rename AD ProficientOrAbove_count_Math_8
rename AE ProficientOrAbove_percent_Math_8

rename AH ProficientOrAbove_count_ELA_9
rename AI ProficientOrAbove_percent_ELA_9
rename AJ ProficientOrAbove_count_Math_9
rename AK ProficientOrAbove_percent_Math_9


// drop combined math and ELA, as well as grades 9-10

drop PassBothMathandELAPercent L Q V AA AF AG AL


// transform from wide to long, generate grade

gen id=_n

reshape long ProficientOrAbove_count_ELA_ ProficientOrAbove_count_Math_ ProficientOrAbove_percent_ELA_ ProficientOrAbove_percent_Math_, i(id) j(GradeLevel)


// rename variables to add subject (1=ELA, 2=Math)

rename ProficientOrAbove_count_ELA_ ProficientOrAbove_count1
rename ProficientOrAbove_percent_ELA_ ProficientOrAbove_percent1
rename ProficientOrAbove_count_Math_ ProficientOrAbove_count2
rename ProficientOrAbove_percent_Math_ ProficientOrAbove_percent2

drop id
gen id=_n

// transform from wide to long, generate subject

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring Subject, replace
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen DataLevel=1

save "/${yrfiles}/IN_2009_dist.dta", replace


/////////	Import School Data

import excel "/${source}/IN_OriginalData_2007-2015_mat&ela_sch.xlsx", sheet("Spring 2009") cellrange(A2:AN1582) firstrow clear


rename ELAPassN ProficientOrAbove_count_ELA_3
rename ELAPercentPass ProficientOrAbove_percent_ELA_3
rename MathPassN ProficientOrAbove_count_Math_3
rename MathPercentPass ProficientOrAbove_percent_Math_3
rename J ProficientOrAbove_count_ELA_4
rename K ProficientOrAbove_percent_ELA_4
rename L ProficientOrAbove_count_Math_4
rename M ProficientOrAbove_percent_Math_4
rename O ProficientOrAbove_count_ELA_5
rename P ProficientOrAbove_percent_ELA_5
rename Q ProficientOrAbove_count_Math_5
rename R ProficientOrAbove_percent_Math_5
rename T ProficientOrAbove_count_ELA_6
rename U ProficientOrAbove_percent_ELA_6
rename V ProficientOrAbove_count_Math_6
rename W ProficientOrAbove_percent_Math_6
rename Y ProficientOrAbove_count_ELA_7
rename Z ProficientOrAbove_percent_ELA_7
rename AA ProficientOrAbove_count_Math_7
rename AB ProficientOrAbove_percent_Math_7
rename AD ProficientOrAbove_count_ELA_8
rename AE ProficientOrAbove_percent_ELA_8
rename AF ProficientOrAbove_count_Math_8
rename AG ProficientOrAbove_percent_Math_8
rename AJ ProficientOrAbove_count_ELA_9
rename AK ProficientOrAbove_percent_ELA_9
rename AL ProficientOrAbove_count_Math_9
rename AM ProficientOrAbove_percent_Math_9

//drop combined math and ela proficiency and grades 9+
drop PassBothMathandELAPercent N S X AC AH AI AN


// transform from wide to long, generate grade, drop blanks and footnotes
gen id=_n
drop if id==1579
drop if id==1580

reshape long ProficientOrAbove_count_ELA_ ProficientOrAbove_count_Math_ ProficientOrAbove_percent_ELA_ ProficientOrAbove_percent_Math_, i(id) j(GradeLevel)


// rename variables to add subject (1=ELA, 2=Math)

rename ProficientOrAbove_count_ELA_ ProficientOrAbove_count1
rename ProficientOrAbove_percent_ELA_ ProficientOrAbove_percent1
rename ProficientOrAbove_count_Math_ ProficientOrAbove_count2
rename ProficientOrAbove_percent_Math_ ProficientOrAbove_percent2

drop id
gen id=_n


// transform from wide to long, generate subject

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring Subject, replace
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen DataLevel=2


// append school and district data

append using "/${yrfiles}/IN_2009_dist.dta"


// prepare for NCES merge

rename CorpID StateAssignedDistID
gen state_leaid=StateAssignedDistID
rename SchoolID seasch

save "/${yrfiles}/IN_2009_base.dta", replace


// dist

use "/${nces}/NCES_2008_District.dta", clear

keep if state_location=="IN"

save "/${yrfiles}/IN_2008_NCESDistricts.dta", replace


// sch

use "/${nces}/NCES_2008_School.dta", clear

keep if state_location=="IN"

save "/${yrfiles}/IN_2008_NCESSchools.dta", replace


// merge NCES district data

use "/${yrfiles}/IN_2009_base.dta", clear

merge m:1 state_leaid using "/${yrfiles}/IN_2008_NCESDistricts.dta"
drop if _merge==2
drop _merge

merge m:1 state_leaid seasch using "/${yrfiles}/IN_2008_NCESSchools.dta"
drop if _merge==2
drop _merge


// drop blank observations from outside of a school's offered grade levels (like G03 results at a middle school) since data transfered from wide to long

replace ProficientOrAbove_count="*" if ProficientOrAbove_count==""
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="***"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="***"

drop if GradeLevel<sch_lowest_grade_offered & ProficientOrAbove_count=="*" & ProficientOrAbove_percent=="*" & DataLevel==2
drop if GradeLevel>sch_highest_grade_offered & ProficientOrAbove_count=="*" & ProficientOrAbove_percent=="*" & DataLevel==2


// finish cleaning

tostring GradeLevel, replace
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"
replace GradeLevel="G38" if GradeLevel=="9"

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename lea_name DistName
rename district_agency_type DistType
rename school_name SchName
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename school_id StateAssignedSchID
rename county_name CountyName
rename county_code CountyCode

gen SchYear="2008-09"
gen AssmtName="ISTEP+"
gen AssmtType="Regular"
gen StudentGroup="All Students"
gen StudentGroup_TotalTested="*"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested="*"
gen Lev1_count="*"
gen Lev1_percent="*"
gen Lev2_count="*"
gen Lev2_percent="*"
gen Lev3_count="*"
gen Lev3_percent="*"
gen Lev4_count="*"
gen Lev4_percent="*"
gen Lev5_count="*"
gen Lev5_percent="*"
gen AvgScaleScore="*"
gen ProficiencyCriteria="Lev 2 & Lev 3"
gen ParticipationRate="*"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"

label define LevelIndicator 0 "State" 1 "District" 2 "School"
label values DataLevel LevelIndicator

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

replace StudentGroup="RaceEth" if StudentGroup=="Race/Eth"
replace GradeLevel="G38" if StudentGroup=="RaceEth"
replace GradeLevel="G38" if StudentGroup=="EL Status"
replace GradeLevel="G38" if StudentGroup=="Gender"
replace GradeLevel="G38" if StudentGroup=="Economic Status"
drop if StateAssignedDistID=="***Due to federal privacy laws, student performance data may not be displayed for any group of less than 10 students."
drop if StateAssignedDistID=="" & (DataLevel==1 | DataLevel==2)


save "/${yrfiles}/IN_2009.dta", replace
export delimited using "/${output}/IN_AssmtData_2009.csv", replace
