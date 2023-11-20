clear
set more off

global raw "/Users/minnamgung/Desktop/SADR/Utah/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Utah/Output"
global int "/Users/minnamgung/Desktop/SADR/Utah/Intermediate"

global nces "/Users/minnamgung/Desktop/SADR/NCES"
global utah "/Users/minnamgung/Desktop/SADR/Utah/NCES"


*** UT School ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2014_all.xlsx", sheet("School Proficiency Levels") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename District DistName
rename School SchName

save "${int}/UT_2014_school.dta", replace 

import excel "${raw}/UT_OriginalData_2014_proficiency.xlsx", sheet("School Results by Test Subject") firstrow allstring clear 

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename DistrictLEA DistName
rename SchoolName SchName 
rename Subject GradeLevel 
rename SubjectArea Subject
rename PercentProficient ProficientOrAbove_percent

merge 1:1 SchName DistName Subject GradeLevel using "${int}/UT_2014_school.dta"

drop _merge

* replace SchName=strproper(SchName)
* replace DistName=strproper(DistName)

replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay'S")>0
replace SchName="TseBiiNidzisgai School" if strpos(SchName, "Tse'Bii")>0
replace SchName="LaVerkin School" if strpos(SchName, "La Verkin")>0
replace SchName="Scera Park" if strpos(SchName, "Scera")>0
replace SchName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0
replace DistName="The Center for Creativity Innovation and Discovery" if strpos(SchName, "Innovation")>0

replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
	replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")

merge m:1 SchName DistName using "${utah}/NCES_2014_School.dta"

gen DataLevel="School"

drop if _merge==2

save "${int}/UT_2014_school.dta", replace 

destring NCESDistrictID, replace
destring NCESSchoolID, replace

drop _merge 

merge m:1 SchName DistName SchYear using "/Users/minnamgung/Desktop/SADR/Utah/UT_unmerged_schools1.dta", update

drop if _merge==2 

replace SchName="Minersville School" if strpos(SchName, "Minersville")>0

format NCESSchoolID %12.0f
tostring NCESSchoolID, replace usedisplayformat
tostring NCESDistrictID, replace

* REVIEW 1 -------------
* REVIEW 1 -------------
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
* REVIEW 1 -------------
* REVIEW 1 -------------


save "${int}/UT_2014_school.dta", replace 


*** UT Districts ***

* Proficiency levels
import excel "${raw}/UT_OriginalData_2014_all.xlsx", sheet("LEA Proficiency Levels") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename District DistName

gen StudentSubGroup="AllStudents"

save "${int}/UT_2014_district.dta", replace 

import excel "${raw}/UT_OriginalData_2014_proficiency.xlsx", sheet("District Results by Test Subjec") firstrow allstring clear 

gen Subject1=""
replace Subject1="English Language Arts" if strpos(Subject, "Language Arts")>0
replace Subject1="Mathematics" if strpos(Subject, "Math")>0
replace Subject1="Science" if strpos(Subject, "Science")>0

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

rename SchoolYear SchYear
rename DistrictLEA DistName
rename Subject GradeLevel 
rename Subject1 Subject
rename PercentProficient ProficientOrAbove_percent

merge 1:1 DistName Subject GradeLevel using "${int}/UT_2014_district.dta"

drop _merge

replace DistName="The Center for Creativity Innovation and Discovery" if strpos(DistName, "Innovation")>0

* replace DistName=strproper(DistName)

merge m:1 DistName using "${utah}/NCES_2014_District.dta"

gen DataLevel="District"

drop if _merge==2

save "${int}/UT_2014_district.dta", replace  



*** UT state ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2014_all.xlsx", sheet("State Proficiency Levels") firstrow allstring clear

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

replace Subject="English Language Arts" if strpos(Subject, "L")>0
replace Subject="Mathematics" if strpos(Subject, "M")>0
replace Subject="Science" if strpos(Subject, "S")>0

rename State DataLevel
rename SchoolYear SchYear
rename Subject GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent

gen StudentSubGroup="AllStudents"

save "${int}/UT_2014_state.dta", replace 

import excel "${raw}/UT_OriginalData_2014_proficiency.xlsx", sheet("State Results by Test Subject") firstrow allstring clear 

foreach x of numlist 3/8 {
	replace Subject="G0`x'" if strpos(Subject, "`x'")>0
}

drop if inlist(Subject, "G03", "G04", "G05", "G06", "G07", "G08")==0

replace SubjectArea="English Language Arts" if strpos(SubjectArea, "L")>0
replace SubjectArea="Mathematics" if strpos(SubjectArea, "M")>0
replace SubjectArea="Science" if strpos(SubjectArea, "S")>0

rename SchoolYear SchYear
rename Subject GradeLevel 
rename SubjectArea Subject
rename PercentProficient ProficientOrAbove_percent
rename State DataLevel

gen StudentSubGroup="AllStudents"

merge 1:1 Subject GradeLevel using "${int}/UT_2014_state.dta"

save "${int}/UT_2014_state.dta", replace 

append using "${int}/UT_2014_district.dta"

append using "${int}/UT_2014_school.dta"





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

* gen StudentGroup=""

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="RaceEth" if StudentGroup==""

gen AssmtName="SAGE"

replace Subject="math" if Subject=="Mathematics" | Subject=="M"
replace Subject="ela" if Subject=="English Language Arts" | Subject=="L"
replace Subject="sci" if Subject=="Science" | Subject=="S"


gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"

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

replace SchYear="2013-14"

tostring State, replace force
replace State="Utah"
replace StateAbbrev="UT"
replace StateFips=49

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent StudentGroup_TotalTested {
	replace `i'="--" if `i'=="null" | `i'=="NULL" | `i'=="" | `i'=="-"
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
	
	replace `i'="0-0.02" if `i'=="≤2%"
	replace `i'="0-0.05" if `i'=="≤5%"
	replace `i'="0.95-1" if `i'=="≥95%"
}

foreach i of varlist StudentSubGroup_TotalTested {
	replace `i'="--" if `i'=="null" | `i'=="NULL" | `i'==""
	replace `i'="*" if `i'=="N≤10" | `i'=="n≤10" | `i'=="n<10"

}

//////////////////////////////////////////
********* Review 1 Edits ***********
//////////////////////////////////////////

* replace StudentGroup_TotalTested="--"
replace StudentSubGroup_TotalTested="--"

replace ProficientOrAbove_count="--"

drop if SchName=="Minersville School" & GradeLevel=="G38"

replace SchVirtual="Missing/not reported" if missing(SchVirtual) & DataLevel=="School"

* replace State_leaid=StateAssignedDistID

* replace StateAssignedSchID="UT-37-37179" if strpos(SchName, "Liberty")>0
* replace State_leaid="UT-37-37179" if strpos(SchName, "Liberty")>0

* replace State_leaid="37131" if strpos(SchName, "East Ridge")>0
* replace State_leaid="UT-3J-3J100" if strpos(SchName, "Mountain View Montessori")>0

replace CountyCode=49053 if strpos(DistName, "Vista at Entrada")>0
replace DistType="Charter agency" if strpos(DistName, "Vista at Entrada")>0
replace SchType="Regular school" if strpos(DistName, "Vista at Entrada")>0
replace NCESDistrictID="4900141" if strpos(DistName, "Vista at Entrada")>0
replace StateAssignedDistID="UT-2G" if strpos(DistName, "Vista at Entrada")>0
replace State_leaid="UT-2G" if strpos(DistName, "Vista at Entrada")>0
replace DistCharter="Yes" if strpos(DistName, "Vista at Entrada")>0
replace CountyName="Washington County" if strpos(DistName, "Vista at Entrada")>0

foreach i of varlist seasch NCESSchoolID SchLevel SchVirtual {
	
	replace `i'="" if DataLevel=="District" & strpos(DistName, "Vista at Entrada")>0
}

replace SchType="" if DistName=="Athenian Eacademy" & DataLevel=="District"

//////////////////////////////////////////
********* Sorting ***********
//////////////////////////////////////////

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2014.dta", replace

keep if DataLevel=="School"
duplicates drop DistName, force
replace DataLevel="District"

keep DistName DataLevel DistType NCESDistrictID StateAssignedDistID State_leaid DistCharter CountyName CountyCode

save "${int}/UT_AssmtData_DISTRICT_2014.dta", replace

use "${output}/UT_AssmtData_2014.dta", clear

merge m:1 DistName DataLevel using "${int}/UT_AssmtData_DISTRICT_2014.dta", update replace force

foreach i of varlist NCESDistrictID State_leaid NCESSchoolID seasch DistCharter CountyName SchType SchLevel SchVirtual DistType {
	* tostring `i', replace 
	replace `i'="Missing/not reported" if missing(DistType) &  DataLevel!="State"
}

replace CountyCode=49049 if strpos(DistName, "Athenian Eacademy")>0
replace DistType="Charter agency" if strpos(DistName, "Athenian Eacademy")>0
replace SchType="Regular school" if strpos(DistName, "Athenian Eacademy")>0
replace NCESDistrictID="4900181" if strpos(DistName, "Athenian Eacademy")>0
replace StateAssignedDistID="UT-4K" if strpos(DistName, "Athenian Eacademy")>0
replace State_leaid="UT-4K" if strpos(DistName, "Athenian Eacademy")>0
replace DistCharter="Yes" if strpos(DistName, "Athenian Eacademy")>0
replace CountyName="Utah County" if strpos(DistName, "Athenian Eacademy")>0

replace SchName="Minersville School (Middle)" if SchName=="MINERSVILLE SCHOOL" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
	replace SchName="Minersville School (Primary)" if SchName=="MINERSVILLE SCHOOL" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")

replace CountyCode=49001 if strpos(SchName, "Minersville")>0
replace DistType="Regular local school district" if strpos(SchName, "Minersville")>0
replace SchType="Regular school" if strpos(SchName, "Minersville")>0
replace NCESDistrictID="4900060" if strpos(SchName, "Minersville")>0
replace StateAssignedDistID="UT-02" if strpos(SchName, "Minersville")>0
replace State_leaid="UT-02" if strpos(SchName, "Minersville")>0
replace DistCharter="No" if strpos(SchName, "Minersville")>0
replace CountyName="Beaver County" if strpos(SchName, "Minersville")>0
replace SchVirtual="No" if strpos(SchName, "Minersville")>0
replace SchType="Regular school" if strpos(SchName, "Minersville")>0

replace seasch="02-02712" if SchName=="Minersville School (Middle)"
replace SchLevel="Middle" if SchName=="Minersville School (Middle)"
replace NCESSchoolID="490006000912" if SchName=="Minersville School (Middle)"
replace StateAssignedSchID="UT-49009" if SchName=="Minersville School (Middle)"

replace seasch="02-02112" if SchName=="Minersville School (Primary)"
replace SchLevel="Primary" if SchName=="Minersville School (Primary)"
replace NCESSchoolID="490006000040" if SchName=="Minersville School (Primary)"
replace StateAssignedSchID="UT-49000" if SchName=="Minersville School (Primary)"

replace SchName="MINERSVILLE SCHOOL" if strpos(SchName, "Minersville")>0

foreach i of varlist seasch NCESSchoolID SchLevel SchVirtual {
	
	replace `i'="" if DataLevel=="District" & strpos(DistName, "Athenian Eacademy")>0
}

drop if SchName=="South Region Deaf"

replace StateAssignedSchID="1457" if SchName=="American International School Of Utah"
replace StateAssignedSchID="1274" if SchName=="Thomas O Smith School"
replace StateAssignedSchID="991" if SchName=="Walden School Of Liberal Arts"

replace StateAssignedSchID="UT-"+StateAssignedSchID if strpos(StateAssignedSchID, "UT-")<=0
replace StateAssignedDistID="UT-"+StateAssignedDistID if strpos(StateAssignedDistID, "UT-")<=0
replace StateAssignedSchID="" if DataLevel!="School"
replace StateAssignedDistID="" if DataLevel=="State"
replace State_leaid=StateAssignedDistID

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2014.dta", replace

export delimited using "${output}/UT_AssmtData_2014.csv", replace
