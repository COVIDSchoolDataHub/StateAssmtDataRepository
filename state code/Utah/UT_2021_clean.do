clear
set more off

global raw "/Users/minnamgung/Desktop/SADR/Utah/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Utah/Output"
global int "/Users/minnamgung/Desktop/SADR/Utah/Intermediate"

global nces "/Users/minnamgung/Desktop/SADR/NCES"
global utah "/Users/minnamgung/Desktop/SADR/Utah/NCES"


*** UT School ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2021_all.xlsx", sheet("School Prof Levels by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2021_levels_school.dta", replace 

* Append aggregated school data
import excel "${raw}/UT_OriginalData_2021_all.xlsx", sheet("School Prof Levels by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2021_levels_school.dta"

foreach x of numlist 3/8 {
	replace TestName="G0`x'" if strpos(TestName, "`x'")>0
}

replace TestName="G38" if strpos(TestName, "All")>0

drop if strpos(TestName, "Secondary")>0

rename SchoolYear SchYear
rename ReportingLevel DataLevel
rename TestName GradeLevel
rename SubjectArea Subject
rename AssessmentType AssmtName 
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEAName DistName
rename SchoolName SchName

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `i'="--" if `i'==""
	replace `i'="*" if `i'=="N < 10"
}

gen StudentSubGroup="AllStudents"

save "${int}/UT_2021_levels_school.dta", replace 

* Subgroups
import excel "${raw}/UT_OriginalData_2021_subgroup.xlsx", sheet("School by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2021_subgroup_school.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2021_subgroup.xlsx", sheet("School by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2021_subgroup_school.dta"

foreach i of varlist AllStudents AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

reshape long subgroup, i(TestName LEAName SchoolName) j(StudentSubGroup) string

rename subgroup ProficientOrAbove_percent

foreach x of numlist 3/8 {
	replace TestName="G0`x'" if strpos(TestName, "`x'")>0
}

replace TestName="G38" if strpos(TestName, "All")>0

drop if strpos(TestName, "Secondary")>0

replace ProficientOrAbove_percent="--" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="n<10"

rename TestName GradeLevel
rename SubjectArea Subject
rename AssessmentType AssmtName
rename SchoolYear SchYear
rename LEAName DistName
rename SchoolName SchName

save "${int}/UT_2021_subgroup_school.dta", replace 

replace SchName="Mt. Nebo Middle" if strpos(SchName, "Mt. Nebo Middle")>0

merge m:1 SchName DistName StudentSubGroup GradeLevel Subject using "${int}/UT_2021_levels_school.dta"

replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
	replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")

drop _merge

merge m:1 SchName DistName using "${utah}/NCES_2020_School.dta"

replace DataLevel="School"

drop if _merge==2

destring NCESDistrictID, replace
destring NCESSchoolID, replace

drop _merge 

merge m:1 SchName DistName SchYear using "/Users/minnamgung/Desktop/SADR/Utah/UT_unmerged_schools.dta", update

drop if _merge==2 | _merge==5

replace SchName="Minersville School" if strpos(SchName, "Minersville")>0

format NCESSchoolID %12.0f
tostring NCESSchoolID, replace usedisplayformat
tostring NCESDistrictID, replace

save "${int}/UT_2021_school.dta", replace 


*** UT Districts ***

* Proficiency levels
import excel "${raw}/UT_OriginalData_2021_all.xlsx", sheet("LEA Prof Levels by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2021_levels_district.dta", replace 

* Append aggregated district data
import excel "${raw}/UT_OriginalData_2021_all.xlsx", sheet("LEA Prof Levels by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2021_levels_district.dta"

foreach x of numlist 3/8 {
	replace TestName="G0`x'" if strpos(TestName, "`x'")>0
}

replace TestName="G38" if strpos(TestName, "All")>0

drop if strpos(TestName, "Secondary")>0

rename SchoolYear SchYear
rename ReportingLevel DataLevel
rename TestName GradeLevel
rename SubjectArea Subject
rename AssessmentType AssmtName 
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEAName DistName

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `i'="--" if `i'=="" | `i'=="null"
	replace `i'="*" if `i'=="N < 10"
}

gen StudentSubGroup="AllStudents"

save "${int}/UT_2021_levels_district.dta", replace 

* Subgroups
import excel "${raw}/UT_OriginalData_2021_subgroup.xlsx", sheet("LEA by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2021_subgroup_district.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2021_subgroup.xlsx", sheet("LEA by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2021_subgroup_district.dta"

foreach i of varlist AllStudents AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

reshape long subgroup, i(TestName LEAName) j(StudentSubGroup) string

rename subgroup ProficientOrAbove_percent

foreach x of numlist 3/8 {
	replace TestName="G0`x'" if strpos(TestName, "`x'")>0
}

replace TestName="G38" if strpos(TestName, "All")>0

drop if strpos(TestName, "Secondary")>0

replace ProficientOrAbove_percent="--" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="N<10"

rename TestName GradeLevel
rename SubjectArea Subject
rename AssessmentType AssmtName
rename SchoolYear SchYear
rename LEAName DistName

save "${int}/UT_2021_subgroup_district.dta", replace 

merge m:1 DistName StudentSubGroup GradeLevel Subject using "${int}/UT_2021_levels_district.dta"

* replace DistName="Intech Collegiate Academy" if strpos(DistName, "InTech")>0
* replace SchName="Mt. Nebo Middle" if strpos(SchName, "Mt. Nebo Middle")>0

drop _merge

merge m:1 DistName using "${utah}/NCES_2021_District.dta"

replace DataLevel="District"

drop if _merge==2

save "${int}/UT_2021_district.dta", replace 



*** UT state ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2021_all.xlsx", sheet("State Prof Levels by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2021_levels_state.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2021_all.xlsx", sheet("State Prof Levels by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2021_levels_state.dta"

foreach x of numlist 3/8 {
	replace TestName="G0`x'" if strpos(TestName, "`x'")>0
}

replace TestName="G38" if strpos(TestName, "All")>0

drop if strpos(TestName, "Secondary")>0

rename SchoolYear SchYear
rename ReportingLevel DataLevel
rename TestName GradeLevel
rename SubjectArea Subject
rename AssessmentType AssmtName 
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent

gen StudentSubGroup="AllStudents"

save "${int}/UT_2021_levels_state.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2021_subgroup.xlsx", sheet("State by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2021_subgroup_state.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2021_subgroup.xlsx", sheet("State by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2021_subgroup_state.dta"

foreach i of varlist AllStudents AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
	rename `i' subgroup`i'
}

reshape long subgroup, i(TestName) j(StudentSubGroup) string

rename subgroup ProficientOrAbove_percent

foreach x of numlist 3/8 {
	replace TestName="G0`x'" if strpos(TestName, "`x'")>0
}

replace TestName="G38" if strpos(TestName, "All")>0

drop if strpos(TestName, "Secondary")>0

replace ProficientOrAbove_percent="--" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="n<10"

rename TestName GradeLevel
rename SubjectArea Subject
rename AssessmentType AssmtName
rename SchoolYear SchYear

save "${int}/UT_2021_subgroup_state.dta", replace 

merge m:1 StudentSubGroup GradeLevel Subject using "${int}/UT_2021_levels_state.dta"

drop _merge

replace DataLevel="State"

save "${int}/UT_2021_state.dta", replace 

append using "${int}/UT_2021_district.dta"

append using "${int}/UT_2021_school.dta"





* Clean everything 

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="LowIncome"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"

drop if StudentSubGroup=="StudentswDisabilities"

gen StudentGroup=""

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="RaceEth" if StudentGroup==""

replace AssmtName="RISE"

replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="sci" if Subject=="Science"


gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"

gen AssmtType="Regular"

drop StateAssignedDistID
drop StateAssignedSchID
gen StateAssignedDistID=State_leaid
gen StateAssignedSchID=school_id

gen StudentGroup_TotalTested=""
gen StudentSubGroup_TotalTested=""

foreach x of numlist 1/4 {
    generate Lev`x'_count = "--"
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
}

gen Lev5_count=""
gen Lev5_percent=""

gen AvgScaleScore="--"

gen ProficiencyCriteria="Levels 3-4"
gen ProficientOrAbove_count=""
gen ParticipationRate="--"

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `i'="--" if `i'==""
}

replace DistName="All Districts" if DataLevel=="State"
replace SchName="All Schools" if DataLevel!="School"

replace SchYear="2020-21"

tostring State, replace force
replace State="Utah"
replace StateAbbrev="UT"
replace StateFips=49

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	replace `i'="--" if `i'=="null" | `i'=="NULL"
	replace `i'="*" if `i'=="N<10"
	replace `i'="0.1-0.19" if `i'=="10 to 19%"
	replace `i'="0.2-0.29" if `i'=="20 to 29%"
	replace `i'="0.3-0.39" if `i'=="30 to 39%"
	replace `i'="0.4-0.49" if `i'=="40 to 49%"
	replace `i'="0.5-0.59" if `i'=="50 to 59%"
	replace `i'="0.6-0.69" if `i'=="60 to 69%"
	replace `i'="0.7-0.79" if `i'=="70 to 79%"
	replace `i'="0.8-0.89" if `i'=="80 to 89%"
	replace `i'="0-0.1" if `i'=="< 10%"
	replace `i'="0-0.01" if `i'=="< 1%"
	replace `i'="0-0.02" if `i'=="< 2%"
	replace `i'="0-0.2" if `i'=="< 20%"
	replace `i'="0-0.05" if `i'=="< 5%"
	replace `i'="0.8-1" if `i'==">= 80%"
	replace `i'="0.9-1" if `i'==">= 90%"
	replace `i'="0.95-1" if `i'==">= 95%"
	
	replace `i'="0.1-0.19" if `i'=="10-19%"
	replace `i'="0.2-0.29" if `i'=="20-29%"
	replace `i'="0.3-0.39" if `i'=="30-39%"
	replace `i'="0.4-0.49" if `i'=="40-49%"
	replace `i'="0.5-0.59" if `i'=="50-59%"
	replace `i'="0.6-0.69" if `i'=="60-69%"
	replace `i'="0.7-0.79" if `i'=="70-79%"
	replace `i'="0.8-0.89" if `i'=="80-89%"
	
	replace `i'="0-0.1" if `i'=="<10%"
	replace `i'="0-0.02" if `i'=="<2%"
	replace `i'="0-0.2" if `i'=="<20%"
	replace `i'="0-0.05" if `i'=="<5%"
	replace `i'="0.8-1" if `i'==">=80%"
	replace `i'="0.9-1" if `i'==">=90%"
	replace `i'="0.95-1" if `i'==">=95%"
}

foreach i of varlist NCESDistrictID State_leaid NCESSchoolID seasch DistCharter CountyName SchType SchLevel SchVirtual DistType {
	* tostring `i', replace 
	replace `i'="Missing/not reported" if missing(DistType) &  DataLevel!="State"
}


keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2021.dta", replace

export delimited using "${output}/UT_AssmtData_2021.csv", replace
