

clear
set more off
set trace off

cd "/Users/benjaminm/Documents/State_Repository_Research"
local Original "/Users/benjaminm/Documents/State_Repository_Research/Oregon/Original"
local Output "/Users/benjaminm/Documents/State_Repository_Research/Oregon/Output"
local NCESDistrict "/Users/benjaminm/Documents/State_Repository_Research/NCES/District"
local NCESSchool "/Users/benjaminm/Documents/State_Repository_Research/NCES/School"

** NOTE: RUN OR_CLEANING FIRST **

use "`Output'/OR_AssmtData_2021", clear
sort DistName SchName Subject GradeLevel StudentSubGroup StudentSubGroup_TotalTested
//
// tab DistName if DistName == "Salem-Keizer SD 24J" & Subject == "ela" & GradeLevel == "G03" & StudentSubGroup == "All students" & DataLevel == "District"
list DistName SchName Subject GradeLevel StudentSubGroup StudentSubGroup_TotalTested if DistName == "Salem-Keizer SD 24J" & Subject == "ela" & GradeLevel == "G03" & StudentSubGroup == "All Students" & DataLevel == 2



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
replace StudentSubGroup = "Migrant" if strpos(StudentSubGroup, "Migrant Education") != 0
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Military" if strpos(StudentSubGroup, "Military") != 0
replace StudentSubGroup = "Foster Care" if strpos(StudentSubGroup, "Foster Care") != 0
replace StudentSubGroup = "Gender X" if strpos(StudentSubGroup, "Non-Binary") != 0

keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Unknown" | StudentSubGroup == "SWD" | StudentSubGroup == "Migrant" | StudentSubGroup == "Military" | StudentSubGroup == "Homeless" | StudentSubGroup == "Foster Care" | StudentSubGroup == "Gender X"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Unknown"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

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

//Derive Additional Information
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
gen flag1 = 1 if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "0-0.05"
gen flag2 = 1 if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "0.95-1"
gen xlow = round(0.05 * nStudentSubGroup_TotalTested)
gen xhigh = round(0.95 * nStudentSubGroup_TotalTested)
replace ProficientOrAbove_count = "0-" + string(xlow) if flag1 == 1 & xlow != .
replace ProficientOrAbove_percent = string(xhigh) + "-1" if flag2 == 1 & xhigh != .

replace nProficientOrAbove_percent = nProficientOrAbove_percent/100
gen ProfCount = round(nProficientOrAbove_percent * nStudentSubGroup_TotalTested)
replace ProficientOrAbove_count = string(ProfCount) if inlist(ProficientOrAbove_count, "*", "--", "") & ProfCount != .
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*" & ProficientOrAbove_count == "--"
replace ProficientOrAbove_count = "*" if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_count == "--"

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
use "`NCESDistrict'/NCES_2020_District"
keep if state_name == "Oregon" | state_location == "OR"
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
use "`NCESSchool'/NCES_2020_School"
keep if state_name == "Oregon" | state_location == "OR"
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
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "OSAS" if Subject == "sci"

//Empty Variables
gen AvgScaleScore = "--"

//StudentGroup_TotalTested
duplicates drop
sort StudentGroup


gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0

drop Unsuppressed* missing_*

//
//
// egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
// tostring StudentGroup_TotalTested, replace
// replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"
// replace StudentGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "*"
//
// sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
// gen Suppressed = 0
// replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
// egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel seasch StateAssignedDistID DistName SchName)
// drop Suppressed
// gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
// replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
// replace StudentGroup_TotalTested = AllStudents_Tested if StudentGroup_Suppressed == 1
// replace StudentGroup_TotalTested = AllStudents_Tested if inlist(StudentGroup, "Homeless Enrolled Status", "Migrant Status", "Foster Care Status", "Military Connected Status", "Disability Status", "Economic Status", "EL Status")
// drop AllStudents_Tested StudentGroup_Suppressed


//Supression
foreach var of varlist StudentSubGroup_TotalTested ParticipationRate {
	replace `var' = "*" if `var' == "--" & ProficientOrAbove_percent != "--"
}

foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

//Dropping Empty Obs
// drop if ProficientOrAbove_percent == "--"
replace StudentGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "*" & StudentSubGroup == "All Students"


replace StateAssignedDistID = "000000" if DataLevel==1

replace StateAssignedSchID = "000000" if DataLevel==1

replace StateAssignedSchID = "000000" if DataLevel==2

 
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID AssmtName Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)


replace StudentGroup_TotalTested = "*" if AllStudents == "*" 

replace StateAssignedDistID = "" if DataLevel==1

replace StateAssignedSchID = "" if DataLevel==1

replace StateAssignedSchID = "" if DataLevel==2


duplicates drop
sort StudentGroup
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*


replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."


//Final Cleaning
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/OR_AssmtData_2021", replace
export delimited "`Output'/OR_AssmtData_2021", replace
clear



