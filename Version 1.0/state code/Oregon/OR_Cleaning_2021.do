clear
set more off
set trace off
local Original "/Volumes/T7/State Test Project/Oregon/Original Data"
local Output "/Volumes/T7/State Test Project/Oregon/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

** NOTE: RUN OR_CLEANING FIRST **

use "`Original'/2021"

//Renaming and Dropping
drop AcademicYear
gen SchYear = "2020-21"
rename DistrictID StateAssignedDistID
rename District DistName
rename SchoolID StateAssignedSchID
rename School SchName
rename StudentGroup StudentSubGroup
rename NumberofParticipants StudentSubGroup_TotalTested
rename ObservedProficiency ProficientOrAbove_percent
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficientOrAbove_count = "--"

keep StateAssignedDistID DistName StateAssignedSchID SchName Subject StudentSubGroup GradeLevel Lev5_count Lev5_percent Lev4_count Lev4_percent Lev3_count Lev3_percent Lev2_count Lev2_percent Lev1_count Lev1_percent StudentSubGroup_TotalTested ParticipationRate DataLevel SchYear ProficientOrAbove_count ProficientOrAbove_percent

//Subject 
replace Subject = "sci" if Subject == "Science"
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "English") !=0

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = subinstr(StudentSubGroup, "Alaskan", "Alaska", .)
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "Disadvantaged") !=0
replace StudentSubGroup = subinstr(StudentSubGroup, "Learners", "Learner",.)
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Multi") !=0
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") !=0
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All students") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Unknown"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"


//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel != 3

//Dealing with ProficientOrAbove_percent ranges
replace ProficientOrAbove_percent = "0-0.05" if strpos(ProficientOrAbove_percent, "<") !=0
replace ProficientOrAbove_percent = "0.95-1" if strpos(ProficientOrAbove_percent, ">") !=0

//Proficiency Levels
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100,"%9.3g") if regexm(ProficientOrAbove_percent, "[*-]") == 0

//ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(*-)
replace ParticipationRate = string(nParticipationRate/100, "%9.3g") if regexm(ParticipationRate, "[*-]") ==0

//Missing Data
foreach var of varlist Lev* ParticipationRate ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count {
	replace `var' = "--" if `var' == "-"
	replace `var' = "--" if `var' == "."
}

**Merging with NCES Data**
tempfile temp1
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) ==3
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) ==2
replace StateAssignedSchID = "000" + StateAssignedSchID if strlen(StateAssignedSchID) ==1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES'/NCES_2020_District"
keep if state_name == 41 | state_location == "OR"
gen StateAssignedDistID = substr(state_leaid,-4,4)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2020_School"
keep if state_name == 41 | state_location == "OR"
gen StateAssignedSchID = substr(seasch, -4,4)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge ==1
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

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
replace StateFips = 41
replace StateAbbrev = "OR"

//Generating additional variables
gen State = "Oregon"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 3 and 4"
gen AssmtType = "Regular"
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "OSAS" if Subject == "sci"

//Empty Variables
gen AvgScaleScore = "--"

//StudentGroup_TotalTested
duplicates drop
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Supression
foreach var of varlist StudentSubGroup_TotalTested ParticipationRate {
	replace `var' = "*" if `var' == "--" & ProficientOrAbove_percent != "--"
}

//Dropping Empty Obs
drop if ProficientOrAbove_percent == "--"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/OR_AssmtData_2021", replace
export delimited "`Output'/OR_AssmtData_2021", replace
clear


