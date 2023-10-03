clear
set more off
local Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
local Output "/Volumes/T7/State Test Project/District of Columbia/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

//Importing
tempfile temp1
save "`temp1'", emptyok replace
clear
import excel "`Original'/DC_OriginalData_2018_all.xlsx", sheet(School Performance) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/DC_OriginalData_2018_all.xlsx", sheet(State Performance) firstrow
append using "`temp1'"
save "`Original'/2018", replace
replace K = P if !missing(SchoolName)
drop P

//Standardizing Varnames
rename AssessmentType AssmtName
keep if AssmtName == "PARCC"
rename TestedGradeSubject GradeLevel
drop GradeofEnrollment
rename SubgroupValue StudentSubGroup
rename PercentMee~p ProficientOrAbove_percent
drop PercentLevel3
rename K PercentLevel3
foreach n in 1 2 3 4 5 {
	rename PercentLevel`n' Lev`n'_percent
}
rename TotalNumberValidTestTakers StudentSubGroup_TotalTested
drop SchoolWard
rename LEACode StateAssignedDistID
rename LEAName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if missing(StateAssignedDistID)
replace DataLevel = "School" if missing(DataLevel)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel ==1
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel ==1

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "Learner") !=0
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander or Native Hawaiian"
replace StudentSubGroup = subinstr(StudentSubGroup, "Alaskan", "Alaska",.)
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

//GradeLevel
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Supressed Data
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<10"
}

//Subject
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "ELA") !=0

//Levels
foreach n in 1 2 3 4 5 {
destring Lev`n'_percent, gen(nLev`n'_percent) i(*%)
replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4g") if Lev`n'_percent != "*"
}

//Proficiency
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*%)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.4g") if ProficientOrAbove_percent != "*"

//Merging with NCES
tempfile temp1
save "`temp1'"

//School Level
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2017_School"
keep if state_name == 11 | state_location == "DC"
gen StateAssignedSchID = seasch
replace StateAssignedSchID = "219" if strpos(school_name, "Bunker") !=0
replace StateAssignedSchID = substr(StateAssignedSchID, strpos(StateAssignedSchID, "-")+1,10)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
save "`tempsch'", replace

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempsch'"

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
replace StateFips = 11
replace StateAbbrev = "DC"

//Generating additional variables
gen State = "District of Columbia"
gen AvgScaleScore = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = ""
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 4 and 5"
gen AssmtType = "Regular"
gen SchYear = "2017-18"

//Generating Missing Variables
foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"

//Leaving ParticipationRate empty for now
gen ParticipationRate = ""

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Dropping unmerged school with fully suppressed data
drop if SchName == "Youth Services Center"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/DC_AssmtData_2018", replace
export delimited "`Output'/DC_AssmtData_2018", replace
clear







