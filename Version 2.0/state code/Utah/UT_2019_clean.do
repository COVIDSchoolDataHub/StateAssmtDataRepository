clear
set more off

global raw "/Users/miramehta/Documents/UT State Testing Data/Original Data"
global output "/Users/miramehta/Documents/UT State Testing Data/Output"
global int "/Users/miramehta/Documents/UT State Testing Data/Intermediate"

global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global utah "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global edfacts "/Users/miramehta/Documents/EdFacts"


*** UT School ***

* Proficiency levels

import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("School Prof Levels by Test") firstrow allstring clear

rename SchoolYear SchYear
rename TestName GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEAName DistName
rename School SchName

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_school.dta", replace 

import excel "${raw}/UT_OriginalData_2019_proficiency.xlsx", sheet("School Results by Test") firstrow allstring clear

rename SchoolYear SchYear
rename TestName GradeLevel
rename SubjectArea Subject
rename LEADistrictorCharter DistName
rename School SchName
rename PercentProficient ProficientOrAbove_percent

keep if strpos(AssessmentType, "RISE")>0

merge 1:1 DistName SchName GradeLevel Subject using "${int}/UT_2019_levels_school.dta"

drop _merge

save "${int}/UT_2019_levels_school.dta", replace

* Append aggregated school data
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("School Prof Levels by Subject") firstrow allstring clear

rename SchoolYear SchYear
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEAName DistName
rename School SchName

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_school_all.dta", replace

import excel "${raw}/UT_OriginalData_2019_proficiency.xlsx", sheet("Overall School Results") firstrow allstring clear

rename SchoolYear SchYear
rename SubjectArea Subject
rename LEADistrictorCharter DistName
rename School SchName
rename PercentProficient ProficientOrAbove_percent

keep if strpos(AssessmentType, "RISE")>0

merge 1:1 DistName SchName Subject using "${int}/UT_2019_levels_school_all.dta"

gen GradeLevel=Subject +" All"

append using "${int}/UT_2019_levels_school.dta"

foreach x of numlist 3/8 {
	replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
}

replace GradeLevel="G38" if strpos(GradeLevel, "All")>0

drop if strpos(GradeLevel, "Secondary")>0

drop ReportingLevel

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `i'="--" if `i'==""
	replace `i'="*" if `i'=="N < 10"
}

gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

save "${int}/UT_2019_levels_school.dta", replace 

* Subgroups
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("SchoolByTestAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_subgroup_school.dta", replace 

* Append aggregated school data
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("SchoolBySubjectAndDemographic") firstrow allstring clear

drop AllStudents

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_subgroup_school.dta"

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
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

append using "${int}/UT_2019_levels_school.dta"

replace SchName=strproper(SchName)
replace DistName=strproper(DistName)

replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & (GradeLevel=="G03" | GradeLevel=="G04" | GradeLevel=="G05")
replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & (GradeLevel=="G06" | GradeLevel=="G07" | GradeLevel=="G08")

replace SchName= "Canyon View School (Primary)" if SchName == "Canyon View School"

replace SchName="The Center For Creativity Innovation And Discovery" if strpos(SchName, "Innovation")>0
replace DistName="The Center For Creativity Innovation And Discovery" if strpos(DistName, "Innovation")>0

drop _merge

replace SchName="Goldminers Daughter" if strpos(SchName, "Goldminer")>0
replace SchName="Kays Creek Elementary" if strpos(SchName, "Kay'S")>0
replace SchName="Tsebiinidzisgai School" if strpos(SchName, "Tse'Bii")>0
replace SchName="Malan's Peak Secondary" if strpos(SchName, "Malan'")>0

merge m:1 SchName DistName using "${utah}/NCES_2019_School.dta"

gen DataLevel=3

drop if _merge==2

destring NCESDistrictID, replace
destring NCESSchoolID, replace

drop _merge 

gen StateAssignedDistID = State_leaid
gen StateAssignedSchID = seasch

decode SchVirtual, gen(SchVirtual_s)
drop SchVirtual
rename SchVirtual_s SchVirtual

decode SchLevel, gen(SchLevel_s)
drop SchLevel
rename SchLevel_s SchLevel

decode SchType, gen(SchType_s)
drop SchType
rename SchType_s SchType

merge m:1 SchName DistName SchYear using "${raw}/UT_unmerged_schools.dta", update

replace StateAssignedSchID = seasch if StateAssignedSchID == ""

drop if _merge==2
drop _merge

** Prep to Merge with EdFacts
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

format NCESSchoolID %12.0f
tostring NCESSchoolID, replace usedisplayformat
tostring NCESDistrictID, replace

gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="LowIncome"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

replace StudentGroup="RaceEth" if StudentGroup == ""
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

*** Merge EdFacts Data
merge m:1 DataLevel NCESSchoolID StudentSubGroup GradeLevel Subject using "${edfacts}/2019/edfactscount2019schoolutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
replace StudentSubGroup_TotalTested = "*" if Count == 0
gen Count_n = Count if DataLevel == 3 & _merge == 3
drop if _merge == 2
drop Count stnam schnam _merge

merge m:1 DataLevel NCESSchoolID StudentSubGroup GradeLevel Subject using "${edfacts}/2019/edfactspart2019schoolutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge

save "${int}/UT_2019_school.dta", replace 

*** UT Districts ***

* Proficiency levels
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("LEA Prof Levels by Test") firstrow allstring clear

rename SchoolYear SchYear
rename TestName GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEAName DistName

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_district.dta", replace

import excel "${raw}/UT_OriginalData_2019_proficiency.xlsx", sheet("LEA Results by Test") firstrow allstring clear

rename SchoolYear SchYear
rename TestName GradeLevel
rename SubjectArea Subject
rename LEADistrictorCharter DistName
rename PercentProficient ProficientOrAbove_percent

keep if strpos(AssessmentType, "RISE")>0

merge 1:1 DistName GradeLevel Subject using "${int}/UT_2019_levels_district.dta"

drop _merge

save "${int}/UT_2019_levels_district.dta", replace

* Append aggregated district data
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("LEA Prof Levels by Subject") firstrow allstring clear

rename SchoolYear SchYear
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent
rename LEAName DistName

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_district_all.dta", replace

import excel "${raw}/UT_OriginalData_2019_proficiency.xlsx", sheet("Overall LEA Results") firstrow allstring clear

rename SchoolYear SchYear
rename SubjectArea Subject
rename LEADistrictorCharter DistName
rename PercentProficient ProficientOrAbove_percent

keep if strpos(AssessmentType, "RISE")>0

merge 1:1 DistName Subject using "${int}/UT_2019_levels_district_all.dta"
drop _merge

gen GradeLevel=Subject +" All"

append using "${int}/UT_2019_levels_district.dta"

foreach x of numlist 3/8 {
	replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
}

replace GradeLevel="G38" if strpos(GradeLevel, "All")>0

drop if strpos(GradeLevel, "Secondary")>0

foreach i of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	replace `i'="--" if `i'=="" | `i'=="null"
	replace `i'="*" if `i'=="N < 10"
}

gen StudentSubGroup="All Students"
gen StudentGroup = "All Students"

save "${int}/UT_2019_levels_district.dta", replace 

* Subgroups
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("LEAByTestAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_subgroup_district.dta", replace 

* Append aggregated subgroup data
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("LEABySubjectAndDemographic") firstrow allstring clear

drop AllStudents

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_subgroup_district.dta"

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
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

append using "${int}/UT_2019_levels_district.dta"

merge m:1 DistName using "${utah}/NCES_2019_District.dta"
drop if _merge==2
drop _merge

gen DataLevel = 2
gen StateAssignedDistID = State_leaid

** Prep to Merge with EdFacts
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

gen StudentSubGroup_TotalTested = "--"
gen ParticipationRate = "--"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="LowIncome"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

replace StudentGroup="RaceEth" if StudentGroup == ""
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

*** Merge EdFacts Data
merge m:1 DataLevel NCESDistrictID StudentSubGroup GradeLevel Subject using "${edfacts}/2019/edfactscount2019districtutah.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "." & string(Count) != ""
replace StudentSubGroup_TotalTested = "*" if Count == 0
rename Count Count_n
drop if _merge == 2
drop stnam _merge

merge m:1 DataLevel NCESDistrictID StudentSubGroup GradeLevel Subject using "${edfacts}/2019/edfactspart2019districtutah.dta"
replace ParticipationRate = Participation if _merge == 3 & Participation != ""
drop if _merge == 2
drop stnam _merge Participation

save "${int}/UT_2019_district.dta", replace 

*** UT state ***
* Proficiency levels

import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("State Prof Levels by Test") firstrow allstring clear

rename SchoolYear SchYear
rename TestName GradeLevel
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_state.dta", replace 

import excel "${raw}/UT_OriginalData_2019_proficiency.xlsx", sheet("State Results by Test") firstrow allstring clear

rename SchoolYear SchYear
rename TestName GradeLevel
rename SubjectArea Subject
rename NumberTested StudentSubGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename PercentProficient ProficientOrAbove_percent

keep if strpos(AssessmentType, "RISE")>0

merge 1:1 GradeLevel Subject using "${int}/UT_2019_levels_state.dta"
drop _merge

save "${int}/UT_2019_levels_state.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2019_all.xlsx", sheet("State Prof Levels by Subject") firstrow allstring clear

rename SchoolYear SchYear
rename SubjectArea Subject
rename BelowProficient Lev1_percent
rename ApproachingProficient Lev2_percent 
rename Proficient Lev3_percent 
rename HighlyProficient Lev4_percent

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_levels_state_all.dta", replace

import excel "${raw}/UT_OriginalData_2019_proficiency.xlsx", sheet("Overall State Results") firstrow allstring clear

rename SchoolYear SchYear
rename SubjectArea Subject
rename NumberTested StudentSubGroup_TotalTested
rename NumberProficient ProficientOrAbove_count
rename PercentProficient ProficientOrAbove_percent

keep if strpos(AssessmentType, "RISE")>0
drop H I J

merge 1:1 Subject using "${int}/UT_2019_levels_state_all.dta"
drop _merge

gen GradeLevel=Subject +" All"

append using "${int}/UT_2019_levels_state.dta"

foreach x of numlist 3/8 {
	replace GradeLevel="G0`x'" if strpos(GradeLevel, "`x'")>0
}

replace GradeLevel="G38" if strpos(GradeLevel, "All")>0

drop if strpos(GradeLevel, "Secondary")>0

gen StudentSubGroup="All Students"
gen StudentGroup = "All Students"

save "${int}/UT_2019_levels_state.dta", replace

* Subgroups
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("StateByTestAndDemographic") firstrow allstring clear

keep if strpos(AssessmentType, "RISE")>0

save "${int}/UT_2019_subgroup_state.dta", replace 

* Append aggregated state data
import excel "${raw}/UT_OriginalData_2019_subgroup.xlsx", sheet("StateBySubjectAndDemographic") firstrow allstring clear

drop AllStudents

keep if strpos(AssessmentType, "RISE")>0

gen TestName=SubjectArea+" All"

append using "${int}/UT_2019_subgroup_state.dta"

foreach i of varlist AfAmBlack AmericanIndian Asian HispanicLatino MultipleRaces PacificIslander White LowIncome StudentswDisabilities EnglishLearners {
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

append using "${int}/UT_2019_levels_state.dta"

replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

replace StudentSubGroup="All Students" if StudentSubGroup=="AllStudents"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="AfAmBlack"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="AmericanIndian"
replace StudentSubGroup="English Learner" if StudentSubGroup=="EnglishLearners"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="LowIncome"
replace StudentSubGroup="Two or More" if StudentSubGroup=="MultipleRaces"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="HispanicLatino"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="PacificIslander"
replace StudentSubGroup="SWD" if StudentSubGroup=="StudentswDisabilities"

replace StudentGroup="RaceEth" if StudentGroup==""
replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged"
replace StudentGroup="Disability Status" if StudentSubGroup=="SWD"

gen DataLevel= 1

save "${int}/UT_2019_state.dta", replace 

append using "${int}/UT_2019_district.dta"

append using "${int}/UT_2019_school.dta"

** State counts
preserve
keep if DataLevel == 2
rename Count_n Count
collapse (sum) Count, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "${int}/UT_AssmtData_2019_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "${int}/UT_AssmtData_2019_State.dta"
replace StudentSubGroup_TotalTested = string(Count) if string(Count) != "0" & string(Count) != "." & StudentSubGroup != "All Students"
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == ""
replace Count_n = Count if !inlist(Count, 0, .)
drop if _merge == 2
drop Count _merge

*** Other Cleaning
replace AssmtName="RISE"
gen AssmtType="Regular"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

replace SchYear = "2018-19"
replace State = "Utah"
replace StateAbbrev = "UT"
replace StateFips = 49

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

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3
replace StateAssignedDistID = "" if DataLevel == 1

** Proficiency Values
destring StudentSubGroup_TotalTested, gen(x) force
replace Count_n = x if DataLevel == 1

forvalues i = 1/4 {
	gen Lev`i'_count = "--"
	
	replace Lev`i'_percent = "--" if inlist(Lev`i'_percent, "null", "NULL", "", "-")
	replace Lev`i'_percent ="*" if inlist(Lev`i'_percent, "N≤10", "n≤10", "n<10", "N<10")
	
	replace Lev`i'_percent = subinstr(Lev`i'_percent, " to ", "-", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, "%", "", 1)
	gen Below = 0
	replace Below = 1 if strpos(Lev`i'_percent, "<") > 0
	replace Below = 1 if strpos(Lev`i'_percent, "≤") > 0
	gen Above = 0
	replace Above = 1 if strpos(Lev`i'_percent, ">") > 0
	replace Above = 1 if strpos(Lev`i'_percent, "≥") > 0
	replace Lev`i'_percent = subinstr(Lev`i'_percent, "< ", "", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, "<= ", "", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, "≤", "", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, "> ", "", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, ">= ", "", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, "≥", "", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, "<", "", 1)
	replace Lev`i'_percent = subinstr(Lev`i'_percent, ">", "", 1)
	gen Lev`i'_percent1 = Lev`i'_percent
	destring Lev`i'_percent1, replace force
	replace Lev`i'_percent1 = Lev`i'_percent1/100 if Below == 1 | Above == 1
	gen Lev`i'_percent_count = .
	replace Lev`i'_percent_count = round(Lev`i'_percent1 * Count_n) if Below == 0 & Above == 0
	replace Lev`i'_count = string(Lev`i'_percent_count) if Lev`i'_percent_count != .
	tostring Lev`i'_percent1, replace format("%9.2g") force
	replace Lev`i'_percent = "0-" + Lev`i'_percent1 if Below == 1
	replace Lev`i'_percent = Lev`i'_percent1 + "-1" if Above == 1
	drop Lev`i'_percent1
	
	split Lev`i'_percent, parse("-")
	replace Lev`i'_percent1 = "" if Lev`i'_percent == Lev`i'_percent1
	destring Lev`i'_percent1, replace force
	destring Lev`i'_percent2, replace force
	replace Lev`i'_percent1 = Lev`i'_percent1/100 if Above == 0 & Below == 0
	replace Lev`i'_percent2 = Lev`i'_percent2/100 if Above == 0 & Below == 0
	gen Lev`i'_count1 = round(Lev`i'_percent1 * Count_n)
	gen Lev`i'_count2 = round(Lev`i'_percent2 * Count_n)
	tostring Lev`i'_count1, replace
	tostring Lev`i'_count2, replace
	replace Lev`i'_count1 = "" if Lev`i'_count1 == "."
	replace Lev`i'_count = Lev`i'_count1 + "-" + Lev`i'_count2 if Lev`i'_count1 != "" & Lev`i'_count2 != "."
	replace Lev`i'_count = Lev`i'_count1 if Lev`i'_count1 != "" & Lev`i'_count2 != "." & Lev`i'_count1 == Lev`i'_count2
	tostring Lev`i'_percent1, replace format("%9.2g") force
	tostring Lev`i'_percent2, replace format("%9.2g") force
	replace Lev`i'_percent = Lev`i'_percent1 + "-" + Lev`i'_percent2 if !inlist(Lev`i'_percent1, "", ".")
	drop Lev`i'_percent1 Lev`i'_percent2 Lev`i'_count1 Lev`i'_count2 Lev`i'_percent_count Above Below
	
	replace Lev`i'_count = "--" if inlist(Lev`i'_count, "", ".")
	replace Lev`i'_count = "--" if Lev`i'_percent == "--"
	replace Lev`i'_count = "*" if Lev`i'_percent == "*"
}

replace ProficientOrAbove_percent = "--" if inlist(ProficientOrAbove_percent, "null", "NULL", "", "-")
replace ProficientOrAbove_percent ="*" if inlist(ProficientOrAbove_percent, "N≤10", "n≤10", "n<10", "N<10")

gen flag_edfacts = 1 if !inlist(PctProf, "", ".", "--", "*") & inlist(ProficientOrAbove_percent, "--", "*")
replace ProficientOrAbove_percent = PctProf if flag_edfacts == 1

replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, " to ", "-", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "%", "", 1)
gen Below = 0
replace Below = 1 if strpos(ProficientOrAbove_percent, "<") > 0
replace Below = 1 if strpos(ProficientOrAbove_percent, "≤") > 0
gen Above = 0
replace Above = 1 if strpos(ProficientOrAbove_percent, ">") > 0
replace Above = 1 if strpos(ProficientOrAbove_percent, "≥") > 0
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "< ", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "<=", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≤", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "> ", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, ">=", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "≥", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "<", "", 1)
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, ">", "", 1)
gen ProficientOrAbove_percent1 = ProficientOrAbove_percent
destring ProficientOrAbove_percent1, replace force
replace ProficientOrAbove_percent1 = ProficientOrAbove_percent1/100 if Below == 1 | Above == 1
gen ProfCount = .
replace ProfCount = round(ProficientOrAbove_percent1 * Count_n) if Below == 0 & Above == 0
gen flag1 = 1 if DataLevel == 1 & StudentSubGroup == "All Students"
replace ProficientOrAbove_count = string(ProfCount) if flag1 != 1 & !inlist(ProfCount, 0, .)
tostring ProficientOrAbove_percent1, replace format("%9.2g") force
replace ProficientOrAbove_percent = "0-" + ProficientOrAbove_percent1 if Below == 1
replace ProficientOrAbove_percent = ProficientOrAbove_percent1 + "-1" if Above == 1
drop ProficientOrAbove_percent1
	
split ProficientOrAbove_percent, parse("-")
replace ProficientOrAbove_percent1 = "" if ProficientOrAbove_percent == ProficientOrAbove_percent1
destring ProficientOrAbove_percent1, replace force
destring ProficientOrAbove_percent2, replace force
replace ProficientOrAbove_percent1 = ProficientOrAbove_percent1/100 if ProficientOrAbove_percent1!= 0 & ProficientOrAbove_percent2 != 1
replace ProficientOrAbove_percent2 = ProficientOrAbove_percent2/100 if ProficientOrAbove_percent1 != 0 & ProficientOrAbove_percent2 != 1
gen ProficientOrAbove_count1 = round(ProficientOrAbove_percent1 * Count_n)
gen ProficientOrAbove_count2 = round(ProficientOrAbove_percent2 * Count_n)
tostring ProficientOrAbove_count1, replace
tostring ProficientOrAbove_count2, replace
replace ProficientOrAbove_count1 = "" if ProficientOrAbove_count1 == "."
replace ProficientOrAbove_count = ProficientOrAbove_count1 + "-" + ProficientOrAbove_count2 if ProficientOrAbove_count1 != "" & ProficientOrAbove_count2 != "." & ProficientOrAbove_count1 != ProficientOrAbove_count2
replace ProficientOrAbove_count = ProficientOrAbove_count1 if ProficientOrAbove_count1 != "" & ProficientOrAbove_count2 != "." & ProficientOrAbove_count1 == ProficientOrAbove_count2
tostring ProficientOrAbove_percent1, replace format("%9.2g") force
tostring ProficientOrAbove_percent2, replace format("%9.2g") force
replace ProficientOrAbove_percent = ProficientOrAbove_percent1 + "-" + ProficientOrAbove_percent2 if !inlist(ProficientOrAbove_percent1, "", ".")
drop ProficientOrAbove_percent1 ProficientOrAbove_percent2 ProficientOrAbove_count1 ProficientOrAbove_count2

replace ProficientOrAbove_count = "--" if inlist(ProficientOrAbove_count, "", ".")
replace ProficientOrAbove_count = "--" if ProficientOrAbove_percent == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*"
replace ParticipationRate = "--" if ParticipationRate == ""

gen Lev5_count = ""
gen Lev5_percent = ""

** Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*"
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*"

replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & Lev1_percent != "*" & Lev2_percent != "*"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") > 0
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) >= 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) < 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0
replace Lev4_percent = "0" if Lev4_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) >= 0
replace Lev4_count = "0" if strpos(Lev4_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) < 0
replace Lev4_percent = "0" if Lev4_count == "0"
replace Lev4_count = "0" if Lev4_count == "--" & ProficientOrAbove_count == "0"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0
replace Lev3_percent = "0" if Lev3_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0
replace Lev3_count = "0" if strpos(Lev3_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0
replace Lev3_percent = "0" if Lev3_count == "0"
replace Lev3_count = "0" if Lev3_count == "--" & ProficientOrAbove_percent == "0"

replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) >= 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) < 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if strpos(Lev2_count, "-") > 0 & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) >= 0
replace Lev2_count = "0" if strpos(Lev2_count, "-") > 0 & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) < 0
replace Lev2_percent = "0" if Lev2_count == "0"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) >= 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) < 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if strpos(Lev1_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) >= 0
replace Lev1_count = "0" if strpos(Lev1_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) < 0
replace Lev1_percent = "0" if Lev1_count == "0"

** Clean up from Unmerged
drop if SchName=="Minersville School" & GradeLevel=="G38"
replace SchVirtual="Missing/not reported" if missing(SchVirtual) & DataLevel==3
replace CountyName="Weber County" if DistName=="Ogden City District" & CountyName==""
replace DistLocale="City, small" if DistName=="Ogden City District" & DistLocale==""

replace SchName="Canyon View School" if SchName == "Canyon View School (Primary)"

replace StateAssignedSchID = subinstr(StateAssignedSchID, "UT-", "", .) if strpos(StateAssignedSchID, "UT-") > 0

** StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested

drop if StudentGroup_TotalTested == "0" & inlist(ProficientOrAbove_percent, "*", "--")
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "0"
replace StudentSubGroup_TotalTested = "--" if StudentGroup_TotalTested == "--" & StudentGroup == "All Students"

** Cleaning up from unmerged
gen flag = 1 if inlist(SchName, "East School", "Legacy School")
replace SchName = SchName + " (" + DistName + ")" if flag == 1
replace SchName = subinstr(SchName, " District", "", 1) if flag == 1
drop flag

*** Cleaning Inconsistent School & District Names
merge m:m SchYear NCESSchoolID NCESDistrictID using "${raw}/ut_full-dist-sch-stable-list_through2023.dta"
drop if _merge == 2
replace SchName = newschname if _merge == 3 & SchName != newschname
replace DistName = newdistname if _merge == 3 & DistName != newdistname

replace DistName = "Weilenmann School of Discovery" if NCESDistrictID == "4900145"
replace DistName = "Walden School of Liberal Arts" if NCESDistrictID == "4900061"
replace DistName = "Vista School" if NCESDistrictID == "4900141"
replace DistName = "Academy for Math Engineering & Science (Ames)" if NCESDistrictID == "4900017"
replace DistName = "American Academy of Innovation" if NCESDistrictID == "4900186"
replace DistName = "American International School of Utah" if NCESDistrictID == "4900172"
replace DistName = "American Preparatory Academy (District)" if NCESDistrictID == "4900005"
replace DistName = "Ascent Academies of Utah" if NCESDistrictID == "4900174"
replace DistName = "Athenian eAcademy" if NCESDistrictID == "4900181"
replace DistName = "Beehive Science & Technology Academy" if NCESDistrictID == "4900023"
replace DistName = "C.S. Lewis Academy" if NCESDistrictID == "4900074"
replace DistName = "Early Light Academy at Daybreak" if NCESDistrictID == "4900140"
replace DistName = "InTech Collegiate Academy" if NCESDistrictID == "4900039"
replace DistName = "Karl G. Maeser Preparatory Academy" if NCESDistrictID == "4900056"
replace DistName = "No. UT Academy for Math Engineering & Science" if NCESDistrictID == "4900063"
replace DistName = "Pioneer High School for the Performing Arts" if NCESDistrictID == "4900164"
replace DistName = "Promontory School of Expeditionary Learning" if NCESDistrictID == "4900157"
replace DistName = "Salt Lake Center for Science Education" if NCESDistrictID == "4900123"
replace DistName = "Salt Lake School for the Performing Arts" if NCESDistrictID == "4900050"
replace DistName = "The Center for Creativity Innovation and Discovery" if NCESDistrictID == "4900193"
replace DistName = "Thomas Edison (District)" if NCESDistrictID == "4900015"
replace DistName = "Tuacahn High School for the Performing Arts" if NCESDistrictID == "4900012"
replace DistName = "Utah County Academy of Science (UCAS)" if NCESDistrictID == "4900020"
replace DistName = "Utah Schools for Deaf & Blind" if NCESDistrictID == "4900069"
replace DistName = "Mountain View Montessori" if NCESDistrictID == "4900169"

*** Clean up variables & save file
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

label def DataLevel_l 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel_l

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/UT_AssmtData_2019.dta", replace

export delimited using "${output}/UT_AssmtData_2019.csv", replace
