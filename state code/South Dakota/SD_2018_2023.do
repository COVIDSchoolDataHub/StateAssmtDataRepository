clear
set more off
local Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
local Output "/Volumes/T7/State Test Project/South Dakota/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

** Importing


forvalues year = 2018/2023 {
di "~~~~~~~~~~~~"
di "`year'"
di "~~~~~~~~~~~~"	

if `year' == 2020 continue
local prevyear =`=`year'-1'
	
//Unhide below code on first run

/*

tempfile temp1
save "`temp1'", emptyok
	if `year' == 2020 continue
	foreach dl in State District School {
		import excel "`Original'/SD_OriginalData_`year'", firstrow sheet ("`dl'") allstring
		append using "`temp1'"
		save "`temp1'", replace
		clear
		
	}
	use "`temp1'"
	drop if missing(Academic_Year)
	save "`Original'/`year'", replace
	clear
	
*/

//Unhide Above code on first run
	
clear
use "`Original'/`year'"

// Renaming
rename Entity_Level DataLevel
cap drop School_Level
drop Academic_Year
rename Grades GradeLevel
rename Subgroup StudentSubGroup
drop Subgroup_Code
rename Asmt_Type AssmtType
drop Accommodations
rename Nbr_AllStudents_Tested StudentSubGroup_TotalTested
rename Pct_AllStudents_Tested ParticipationRate
rename Nbr_AllStudentsProficient ProficientOrAbove_count
rename Pct_AllStudentsProficient ProficientOrAbove_percent
rename Nbr_AllStudents_Below_BasicLe Lev1_count
rename Pct_AllStudents_Below_BasicLe Lev1_percent
rename Nbr_AllStudents_BasicLevel2 Lev2_count
rename Pct_AllStudents_BasicLevel2 Lev2_percent
rename Nbr_AllStudents_ProficientLev Lev3_count
rename Pct_AllStudents_ProficientLev Lev3_percent
rename Nbr_AllStudents_AdvancedLevel Lev4_count
rename Pct_AllStudents_AdvancedLevel Lev4_percent

// Correcting DataLevel
gen DistName = Entity_Name if DataLevel == "District"
gen SchName = Entity_Name if DataLevel == "School"
gen StateAssignedDistID = Entity_ID if DataLevel == "District"
gen StateAssignedSchID = Entity_ID if DataLevel == "School"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3


// Dropping Extra Variables
keep DataLevel GradeLevel Subject StudentSubGroup AssmtType StudentSubGroup_TotalTested ParticipationRate ProficientOrAbove_count ProficientOrAbove_percent Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent DistName SchName StateAssignedDistID StateAssignedSchID

// GradeLevel
replace GradeLevel = "G" + GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G03-08"
replace GradeLevel = "G38" if GradeLevel == "G5th & 8th"
forvalues n = 3/8 {
	replace GradeLevel = "G0`n'" if GradeLevel == "G`n'"
}

// Subject
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
replace Subject = "ela" if Subject == "Reading"

// StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners (EL)"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NON-EL"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NON-Economically Disadvantaged"

// StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"

// StudentGroup_TotalTested
duplicates drop
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Missing Data
foreach var of varlist _all {
	cap replace `var' = "--" if `var' == "NULL"
}

// ParticipationRate
destring ParticipationRate, gen(nParticipationRate) i(*-)
replace ParticipationRate = string(nParticipationRate/100, "%9.3g") if ParticipationRate != "*"


// Proficiency Levels
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*-)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.3g") if ProficientOrAbove_percent != "*"

foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.3g") if Lev`n'_percent != "*"
}

// Merging

tempfile temp1
save "`temp1'", replace
clear

// District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
if `year' > 2021 replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
save "`tempdist'", replace
clear
use "`NCES'/NCES_`prevyear'_District"
keep if state_name == 46 | state_location == "SD"
gen StateAssignedDistID = subinstr(state_leaid, "SD-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
save "`tempdist'", replace
clear

// School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_`prevyear'_School"
keep if state_name == 46 | state_location == "SD"
gen StateAssignedSchID = subinstr(seasch, "-","",.)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
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
replace StateFips = 46
replace StateAbbrev = "SD"
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel ==3
*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace

//AssmtType / AssmtName
replace AssmtType = "Regular"
gen AssmtName = ""
replace AssmtName = "SBAC" if Subject != "sci"
replace AssmtName = "SDSA" if Subject == "sci"

//Sci assessment names
replace AssmtName = "SDSA 1.0" if (`year' == 2018 | `year' == 2019) & Subject == "sci"
replace AssmtName = "SDSA 2.0" if (`year' ==2021 | `year' == 2022) & Subject == "sci"

//Generating additional variables
gen State = "South Dakota"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
replace Flag_CutScoreChange_oth = "Y" if `year' == 2018 | `year' == 2021
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 3 and 4"
replace AssmtType = "Regular"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//DistName
replace DistName = lea_name if DataLevel ==3

//StateAssignedDistID
replace StateAssignedDistID = subinstr(State_leaid, "SD-","",.) if DataLevel ==3

//2022 had one unmerged district which contained only suppressed data. 2018 had unmerged schools which were all suppressed.
if `year' == 2022 | `year' == 2018 drop if _merge ==2

//Empty Variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"

//Final cleaning and dropping extra variables
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Saving
save "`Output'/SD_AssmtData_`year'", replace
export delimited "`Output'/SD_AssmtData_`year'", replace

}
