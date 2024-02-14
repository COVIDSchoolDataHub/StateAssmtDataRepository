clear
set more off

global raw "/Users/minnamgung/Desktop/SADR/Utah/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Utah/Output"
global int "/Users/minnamgung/Desktop/SADR/Utah/Intermediate"

global nces "/Users/minnamgung/Desktop/SADR/NCES"
global utah "/Users/minnamgung/Desktop/SADR/Utah/NCES"

global edfacts "/Users/minnamgung/Desktop/EdFacts/Output"


*** UT School ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("School Prof Levels by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_school.dta", replace 

* Append aggregated school data
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("School Prof Levels by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_levels_school.dta"

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

save "${int}/UT_2019_levels_school.dta", replace 

* Subgroups
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("SchoolByTestAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_subgroup_school.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("SchoolBySubjectAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_subgroup_school.dta"

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

save "${int}/UT_2019_subgroup_school.dta", replace 

merge m:1 SchName DistName StudentSubGroup GradeLevel Subject using "${int}/UT_2019_levels_school.dta"

replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
	replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")

drop _merge

replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay's")>0
replace SchName="TseBiiNidzisgai School" if strpos(SchName, "Tse'Bii")>0

merge m:1 SchName DistName using "${utah}/NCES_2019_School.dta"

replace DataLevel="School"

drop if _merge==2

destring NCESDistrictID, replace
destring NCESSchoolID, replace

drop _merge 

merge m:1 SchName DistName SchYear using "/Users/minnamgung/Desktop/SADR/Utah/UT_unmerged_schools1.dta", update

drop if _merge==2 | _merge==5

replace SchName="Minersville School" if strpos(SchName, "Minersville")>0

format NCESSchoolID %12.0f
tostring NCESSchoolID, replace usedisplayformat
tostring NCESDistrictID, replace

save "${int}/UT_2019_school.dta", replace 



*** UT Districts ***

* Proficiency levels
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("LEA Prof Levels by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_district.dta", replace 

* Append aggregated district data
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("LEA Prof Levels by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_levels_district.dta"

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

save "${int}/UT_2019_levels_district.dta", replace 

* Subgroups
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("LEAByTestAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_subgroup_district.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("LEABySubjectAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_subgroup_district.dta"

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

save "${int}/UT_2019_subgroup_district.dta", replace 

merge m:1 DistName StudentSubGroup GradeLevel Subject using "${int}/UT_2019_levels_district.dta"

* replace DistName="Intech Collegiate Academy" if strpos(DistName, "InTech")>0
* replace SchName="Mt. Nebo Middle" if strpos(SchName, "Mt. Nebo Middle")>0

drop _merge

merge m:1 DistName using "${utah}/NCES_2019_District.dta"

replace DataLevel="District"

drop if _merge==2

save "${int}/UT_2019_district.dta", replace 



*** UT state ***

* Total Tested
import excel "${raw}/UT_OriginalData_2019_proficiency.xlsx", sheet("State Results by Test") firstrow allstring clear


foreach x of numlist 3/8 {
	replace TestName="G0`x'" if strpos(TestName, "`x'")>0
}

drop if inlist(TestName, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename ResultsLevel DataLevel
rename SchoolYear SchYear
rename TestName GradeLevel
rename SubjectArea Subject
rename NumberTested StudentGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename AssessmentType AssmtName

drop PercentProficient testSubjectId
gen StudentSubGroup="AllStudents"

save "${int}/UT_2019_state.dta", replace 

* Proficiency levels

import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("State Prof Levels by Test") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_state.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("State Prof Levels by Subject") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_levels_state.dta"

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

merge m:1 Subject GradeLevel StudentSubGroup using "${int}/UT_2019_state.dta"

drop _merge

save "${int}/UT_2019_levels_state.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("StateByTestAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_subgroup_state.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("StateBySubjectAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_subgroup_state.dta"

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

save "${int}/UT_2019_subgroup_state.dta", replace 

* drop _merge

merge m:1 StudentSubGroup GradeLevel Subject using "${int}/UT_2019_levels_state.dta"

replace DataLevel="State"

save "${int}/UT_2019_state.dta", replace 

append using "${int}/UT_2019_district.dta"

append using "${int}/UT_2019_school.dta"





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


gen Flag_AssmtNameChange="Y"
gen Flag_CutScoreChange_ELA="Y"
gen Flag_CutScoreChange_math="Y"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="Y"

gen AssmtType="Regular"

//////////////////////////////////////////
********* Review 1 Edits ***********
//////////////////////////////////////////


foreach i of varlist StateAssignedDistID StateAssignedSchID {
	
	gen `i'1=""
	
}

replace StateAssignedDistID1=State_leaid
replace StateAssignedSchID1=school_id

replace State_leaid=StateAssignedDistID if StateAssignedDistID!=""

foreach i of varlist StateAssignedDistID StateAssignedSchID {
	
	replace `i'1=`i' if `i'!=""
	drop `i'
	rename `i'1 `i'
	
}

* gen StudentGroup_TotalTested=""
gen StudentSubGroup_TotalTested=""

foreach x of numlist 1/4 {
    generate Lev`x'_count = "--"
    label variable Lev`x'_count "Count of students within subgroup performing at Level `x'."
}

gen Lev5_count=""
gen Lev5_percent=""

gen AvgScaleScore="--"

gen ProficiencyCriteria="Levels 3-4"
* gen ProficientOrAbove_count=""
gen ParticipationRate="--"

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `i'="--" if `i'==""
}

replace DistName="All Districts" if DataLevel=="State"
replace SchName="All Schools" if DataLevel!="School"

replace SchYear="2018-19"

tostring State, replace force
replace State="Utah"
replace StateAbbrev="UT"
replace StateFips=49

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ProficientOrAbove_count StudentGroup_TotalTested {
	replace `i'="--" if `i'=="null" | `i'=="NULL" | `i'==""| `i'=="-"
	replace `i'="*" if `i'=="N≤10" | `i'=="n≤10" | `i'=="n<10"| `i'=="N<10"
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
	
	replace `i'="0.1-0.19" if `i'=="10-19%" | `i'=="11-19%"
	replace `i'="0.2-0.29" if `i'=="20-29%" | `i'=="21-29%"
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
	
	replace `i'="0-0.1" if `i'=="≤10%"
	replace `i'="0-0.2" if `i'=="≤20%"
	replace `i'="0.8-1" if `i'=="≥80%"
	replace `i'="0.9-1" if `i'=="≥90%"
	replace `i'="0.99-1" if `i'=="≥99%"
	
	replace `i'="0.98-1" if `i'==">=98%"
}

foreach i of varlist StudentSubGroup_TotalTested {
	replace `i'="--" if `i'=="null" | `i'=="NULL" | `i'==""
	replace `i'="*" if `i'=="N≤10" | `i'=="n≤10" | `i'=="n<10"

}

foreach i of varlist NCESDistrictID State_leaid NCESSchoolID seasch DistCharter CountyName SchType SchLevel SchVirtual DistType {
	* tostring `i', replace 
	replace `i'="Missing/not reported" if missing(DistType) &  DataLevel!="State"
}

//////////////////////////////////////////
********* Review 1 Edits ***********
//////////////////////////////////////////

* replace StudentGroup_TotalTested="--"
replace StudentSubGroup_TotalTested="--"

* replace ProficientOrAbove_count="--"

drop if SchName=="Minersville School" & GradeLevel=="G38"

replace SchVirtual="Missing/not reported" if missing(SchVirtual) & DataLevel=="School"

* replace State_leaid=StateAssignedDistID

* replace StateAssignedSchID="UT-37-37179" if strpos(SchName, "Liberty")>0
* replace State_leaid="UT-37-37179" if strpos(SchName, "Liberty")>0

* replace State_leaid="37131" if strpos(SchName, "East Ridge")>0
* replace State_leaid="UT-3J-3J100" if strpos(SchName, "Mountain View Montessori")>0

save "${output}/UT_AssmtData_2019.dta", replace

use "${output}/UT_AssmtData_2019.dta", clear

//////////////////////////////////////////
********* EdFacts ***********
//////////////////////////////////////////

drop _merge

merge m:1 NCESSchoolID Subject GradeLevel StudentSubGroup DataLevel using "${edfacts}/UT_edfact_2019_school.dta", update replace

drop if _merge==2

drop _merge

merge m:1 NCESDistrictID Subject GradeLevel StudentSubGroup DataLevel using "${edfacts}/UT_edfact_2019_district.dta", update replace

drop if _merge==2

drop _merge

merge m:1 Subject GradeLevel StudentSubGroup DataLevel using "${edfacts}/UT_edfact_2019_state.dta", update replace

drop if _merge==2

replace StudentSubGroup_TotalTested="--" if StudentSubGroup_TotalTested==""

//////////////////////////////////////////
********* Sorting ***********
//////////////////////////////////////////

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2019.dta", replace

export delimited using "${output}/UT_AssmtData_2019.csv", replace
