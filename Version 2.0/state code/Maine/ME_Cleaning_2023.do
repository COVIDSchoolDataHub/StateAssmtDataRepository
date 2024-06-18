clear
set more off

global Original "/Volumes/T7/State Test Project/Maine/Original Data Files"
global Output "/Volumes/T7/State Test Project/Maine/Output"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"

//Unhide below code on first run

/*
import delimited "${Original}/ME_OriginalData_2023", case(preserve) clear
save "${Original}/Maine_OriginalData_2023", replace
*/

use "${Original}/Maine_OriginalData_2023", clear

//Reshaping from long to wide
replace AchievementLevel = subinstr(AchievementLevel," ","",.)
duplicates drop SchoolName DistrictName SchoolID Assessment Population AchievementLevel, force
drop DistrictPercentageofStudent
rename TotalStudentsTested Tested_
rename PercentageofStudentsTested Part_
rename NumberofStudentsatAchievemen Count_
rename PercentageofStudentsatAchiev Perc_
rename StatewidePercentageofStuden State_
label def AchievementLevel 4 "AboveStateExpectations" 3 "AtStateExpectations" 34 "AtOrAboveStateExpectations" 2 "BelowStateExpectations" 1 "WellBelowStateExpectations"
encode AchievementLevel, gen(AchievementLevel_n) label(AchievementLevel)
drop AchievementLevel State_
rename AchievementLevel_n AchievementLevel
drop Students PercentProficient NumberofStudentsRequiredtoT
reshape wide Count_ Perc_ Tested_ Part_, i(SchoolName DistrictName SchoolID Assessment Population) j(AchievementLevel)

//Cleaning up Tested_ and Part_
gen ParticipationRate = ""
gen StudentSubGroup_TotalTested = ""
foreach n in 1 2 3 4 35 {
	replace ParticipationRate = Part_`n' if regexm(Part_`n', "[0-9]") !=0
	drop Part_`n'
	replace StudentSubGroup_TotalTested = Tested_`n' if regexm(Tested_`n', "[0-9]") !=0
	drop Tested_`n'
}
replace ParticipationRate = "*" if missing(ParticipationRate)
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)

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
rename Perc_35 ProficientOrAbove_percent
rename Count_35 ProficientOrAbove_count
drop LegacyData
rename DistrictID StateAssignedDistID

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Multilingual Learners"
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two") !=0
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non Students with Disabilities"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Multilingual Learners (Monitoring)"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Students in Foster Care"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Non Students in Foster Care"
replace StudentSubGroup = "Military" if StudentSubGroup == "Parent in Military on Active Duty"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Non Parent in Military on Active Duty"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non Economically Disadvantaged"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non Multilingual Learners"
replace StudentSubGroup = subinstr(StudentSubGroup, "Non ", "Non-",.)

drop if StudentSubGroup == "Not Selected"

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

//Subject
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

//Merging NCES Data
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace
gen StateAssignedSchID1 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'", replace

//District
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'"
clear
use "${NCES_District}/NCES_2022_District"
keep state_name state_fips_id ncesdistrictid state_leaid district_agency_type DistCharter DistLocale county_code county_name lowest_grade_offered state_location
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedDistID = subinstr(state_leaid,"ME-","",.)
merge 1:m StateAssignedDistID using "`tempdist'", keep(match using)
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
clear
use "${NCES_School}/NCES_2022_School"
keep state_name state_fips_id ncesdistrictid district_agency_type DistCharter DistLocale county_code county_name ncesschoolid SchVirtual SchLevel school_name school_type sch_lowest_grade_offered state_leaid seasch state_location
foreach var of varlist district_agency_type SchVirtual SchLevel school_type sch_lowest_grade_offered {
	decode `var', gen(n`var')
	drop `var'
	rename n`var' `var'
}
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedSchID1 = seasch
replace StateAssignedSchID1 = "1013-1014" if school_name == "Beatrice Rafferty School"
replace StateAssignedSchID1 = "1009-1010" if school_name == "Indian Island School"
replace StateAssignedSchID1 = "1011-1012" if school_name == "Indian Township School"
merge 1:m StateAssignedSchID1 using "`tempschool'", keep(match)
//Unmerged Schools are Private, List:

/*
529. |       Sipayik Elementary School |
530. | John Bapst Memorial High School |
531. |          George Stevens Academy |
532. |                 Erskine Academy |
533. |                Foxcroft Academy |
     |---------------------------------|
534. |              Washington Academy |
535. |                Fryeburg Academy |
536. |                     Lee Academy |
537. |                 Lincoln Academy |
538. |         Maine Central Institute |
     |---------------------------------|
539. |                Thornton Academy |
540. |         Blue Hill Harbor School |
541. |          The Eddy Middle School |
*/
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
rename school_type SchType
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 23
replace StateAbbrev = "ME"

//GradeLevel
drop if real(lowest_grade_offered) > 8  & !missing(real(lowest_grade_offered))
drop if real(sch_lowest_grade_offered) > 8 & !missing(real(sch_lowest_grade_offered))
drop lowest_grade_offered sch_lowest_grade_offered
gen GradeLevel = "GZ"

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0" | StudentGroup_TotalTested == "."

//Fixing StateAssignedDistID and StateAssignedSchID
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3

//Indicator Vars
gen SchYear = "2022-23"
gen State = "Maine"
gen AssmtName = "Maine Through Year Assessment" if Subject != "sci"
replace AssmtName = "Maine Science Assessment" if Subject == "sci"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "Y"
replace Flag_AssmtNameChange = "N" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"

//Cleaning up counts/percents
foreach var of varlist Lev* ProficientOrAbove* {
	replace `var' = "*" if missing(`var')
}
foreach percent of varlist *_percent ParticipationRate  {
	replace `percent' = string(real(`percent'), "%9.3g") if regexm(`percent', "[0-9]") !=0
}

//StudentGroup_TotalTested Convention
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
replace StudentGroup_TotalTested = AllStudents if regexm(StudentGroup_TotalTested, "[0-9]") ==0

//Review Response
drop if DistName == "Indian Island" //NCESDistrictID == 5900160
drop if DistName == "Indian Township" // NCESDistrictID == 5900042
drop if SchName == "Beatrice Rafferty School" //NCESSchoolID == 5900137

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

save "${Output}/ME_AssmtData_2023", replace
export delimited "${Output}/ME_AssmtData_2023.csv", replace






