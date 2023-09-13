clear
set more off
set trace off
cd "/Volumes/T7/State Test Project/Maine"
local Original "/Volumes/T7/State Test Project/Maine/Original Data Files"
local Output "/Volumes/T7/State Test Project/Maine/Output"
local NCES_District "/Volumes/T7/State Test Project/NCES/District"
local NCES_School "/Volumes/T7/State Test Project/NCES/School"
local Unmerged "/Volumes/T7/State Test Project/Maine/Unmerged"

forvalues year = 2016/2019 {
	
	
local prevyear =`=`year'-1'
	
//Run code below to convert to dta format first

/*

import delimited "`Original'/Maine_OriginalData_`year'.csv", case(preserve)
save "`Original'/Maine_OriginalData_`year'.dta", replace
clear

*/

use "`Original'/Maine_OriginalData_`year'.dta"



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
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

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

//2015 NCES has totally wrong seasch for some reason. Using 2016 NCES for 2015-16 SchYear

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'"
clear
if `year' != 2016 {
use "`NCES_District'/NCES_`prevyear'_District"
}
if `year' == 2016 {
use  "`NCES_District'/NCES_`year'_District"
}
keep if state_name ==23
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
use "`NCES_School'/NCES_`prevyear'_School"
}
if `year' == 2016 {
use "`NCES_School'/NCES_`year'_School"
}
keep if state_name == 23
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
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 23
replace StateAbbrev = "ME"



//GradeLevel
drop if sch_lowest_grade_offered == 9
gen GradeLevel = "G38"

//Creating Unmerged sheet
if `year' != 2019 {
tempfile all
save "`all'"
cap keep if _merge ==2
keep SchName DistName StateAssignedDistID StateAssignedSchID
duplicates drop
export excel using "`Unmerged'/`year'_unmerged.xlsx", firstrow(variables) replace
}
clear
use "`all'"


//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3 and 4"
gen AssmtName = "Maine Educational Assessment"

//State 
gen State = "Maine"

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0" | StudentGroup_TotalTested == "."


//AssmtType
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read=.
gen Flag_CutScoreChange_oth = "Y"

foreach var of varlist Flag* {
	cap replace `var' = "N" if `year' !=2016
}

//Fixing StateAssignedDistID and StateAssignedSchID
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3

//Missing/empty Variables
gen AvgScaleScore = "--"
gen Lev5_count =.
gen Lev5_percent=.


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/ME_AssmtData_`year'", replace
export delimited "`Output'/ME_AssmtData_`year'", replace



	
clear
}
