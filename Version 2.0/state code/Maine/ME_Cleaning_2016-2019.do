clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/Maine"
global Original "/Volumes/T7/State Test Project/Maine/Original Data Files"
global Output "/Volumes/T7/State Test Project/Maine/Output"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"

forvalues year = 2016/2019 {
	
	
local prevyear =`=`year'-1'
	
//Run code below to convert to dta format first

/*

import delimited "${Original}/ME_OriginalData_`year'.csv", case(preserve)
save "${Original}/Maine_OriginalData_`year'.dta", replace
clear

*/

use "${Original}/Maine_OriginalData_`year'.dta"



//Reshaping from long to wide
replace AchievementLevel = subinstr(AchievementLevel," ","",.)
duplicates drop SchoolName DistrictName SchoolID Assessment Population AchievementLevel, force
drop DistrictPercentageofStudent
rename TotalStudentsTested Tested_
rename PercentageofStudentsTested Part_
rename NumberofStudentsatAchievemen Count_
rename PercentageofStudentsatAchiev Perc_
rename StatewidePercentageofStuden State_
label def AchievementLevel 4 "AboveStateExpectations" 3 "AtStateExpectations" 34 "AtOrAboveStateExpectations" 2 "BelowStateExpectations" 12 "BeloworWellBelowStateExpectations" 1 "WellBelowStateExpectations"
encode AchievementLevel, gen(AchievementLevel_n) label(AchievementLevel)
drop AchievementLevel State_
rename AchievementLevel_n AchievementLevel
reshape wide Count_ Perc_, i(SchoolName DistrictName SchoolID Assessment Population) j(AchievementLevel)

//Variable Names
rename DistrictName DistName
rename SchoolID StateAssignedSchID
rename SchoolName SchName
rename Population StudentSubGroup
rename Assessment Subject
foreach n in 1 2 3 4 {
	rename Count_`n' Lev`n'_count
	rename Perc_`n' Lev`n'_percent
}
drop Count_12 Perc_12
rename Perc_35 ProficientOrAbove_percent
rename Count_35 ProficientOrAbove_count
drop LegacyData
rename DistrictID StateAssignedDistID
drop NumberofStudentsRequiredtoT
rename Tested_ StudentSubGroup_TotalTested
rename Part_ ParticipationRate

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if missing(StateAssignedDistID) & missing(StateAssignedSchID)
replace DataLevel = "District" if !missing(StateAssignedDistID) & missing(StateAssignedSchID)
replace DataLevel = "School" if !missing(StateAssignedDistID) & !missing(StateAssignedSchID)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace StateAssignedDistID =. if DataLevel ==1
replace StateAssignedSchID=. if DataLevel ==1
replace StateAssignedSchID=. if DataLevel ==2
order DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//StudentSubGroup
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "English Learners (Monitoring)"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Students in Foster Care"
replace StudentSubGroup = "Military" if StudentSubGroup == "Parent in Military on Active Duty"


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"


//Year
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//Subject
replace Subject = "ela" if strpos(Subject, "English") !=0
replace Subject = "math" if strpos(Subject,"Math") !=0
replace Subject = "sci" if Subject == "Science"


//Merging NCES Data
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
gen StateAssignedSchID1 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'", replace

//2015 NCES has unsuable seasch. Using 2016 NCES for 2015-16 SchYear

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'"
clear
if `year' != 2016 {
use "${NCES_District}/NCES_`prevyear'_District"
}
if `year' == 2016 {
use  "${NCES_District}/NCES_`year'_District"
}
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedDistID = subinstr(state_leaid,"ME-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
clear
if `year' != 2016 {
use "${NCES_School}/NCES_`prevyear'_School"
}
if `year' == 2016 {
use "${NCES_School}/NCES_`year'_School"
}
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedSchID1 = seasch
merge 1:m StateAssignedSchID1 using "`tempschool'"
drop if _merge ==1
save "`tempschool'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempschool'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 23
replace StateAbbrev = "ME"



//GradeLevel
drop if sch_lowest_grade_offered > 8 & !missing(sch_lowest_grade_offered)
gen GradeLevel = "G38"


//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3-4"

//AssmtName
gen AssmtName = "eMPowerME"
replace AssmtName = "Maine Educational Assessment" if Subject == "sci"

//State 
gen State = "Maine"

//StudentGroup_TotalTested
cap drop StateAssignedSchID1
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1


//AssmtType
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "Y" if Subject != "sci" 
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"

foreach var of varlist Flag* {
	if "`var'" == "Flag_CutScoreChange_soc" continue
	cap replace `var' = "N" if `year' !=2016
}

//Fixing StateAssignedDistID and StateAssignedSchID
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3

//Missing/empty Variables
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent= ""

//Cleaning Percents
foreach percent of varlist *_percent ParticipationRate  {
	replace `percent' = string(real(`percent'), "%9.3g") if regexm(`percent', "[0-9]") !=0
}



//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${Output}/ME_WebsiteData_`year'", replace



	
clear
}
