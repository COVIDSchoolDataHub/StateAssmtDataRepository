clear
set more off
local Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
local Output "/Volumes/T7/State Test Project/District of Columbia/Output"
local NCES "/Volumes/T7/State Test Project/NCES"


//Importing
tempfile temp1
save "`temp1'", emptyok replace
clear
import excel "`Original'/DC_OriginalData_2015_all.xlsx", sheet(School) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/DC_OriginalData_2015_all.xlsx", sheet(State & Sector) firstrow
append using "`temp1'"
save "`Original'/2015", replace
replace J = N if !missing(SchoolName)
replace K = O if !missing(SchoolName)
drop N O

//Standardizing Varnames
rename SubjectCategory Subject
rename Sector DataLevel
rename TestedGrade GradeLevel
rename Subgroup StudentSubGroup
drop EnrollmentGrade
rename level4 ProficientOrAbove_percent
drop level3
rename level1 Lev1_percent
rename level2 Lev2_percent
rename J Lev3_percent
rename K Lev4_percent
rename level5 Lev5_percent
rename Totalvalidtests StudentSubGroup_TotalTested
drop oftotaltestedpopulation
drop SchoolWard
rename LEACode StateAssignedDistID
rename SchoolCode StateAssignedSchID
rename LEAName DistName
rename SchoolName SchName

//DataLevel
replace DataLevel = "School" if missing(DataLevel)
replace DataLevel = "District" if DataLevel != "School" & DataLevel != "State"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel
rename DataLevel_n DataLevel
drop if DataLevel ==2
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel ==1
replace StateAssignedDistID =. if DataLevel ==1
replace StateAssignedSchID =. if DataLevel ==1

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English")
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
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

//GradeLevel
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Supressed Data
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<25"
}

//Subject
keep if strpos(Subject, "3to8") !=0 | strpos(Subject, "ELA") !=0
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "ELA") !=0

//Levels
foreach n in 1 2 3 4 5 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4g") if Lev`n'_percent != "*" & DataLevel ==1
	replace Lev`n'_percent = string(nLev`n'_percent, "%9.4g") if Lev`n'_percent != "*" & DataLevel ==3
}
//Proficiency
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.4g") if ProficientOrAbove_percent != "*" & DataLevel ==1
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent, "%9.4g") if ProficientOrAbove_percent != "*" & DataLevel ==3

//Merging with NCES
tempfile temp1
save "`temp1'"

//School Level
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2014_School"
keep if state_name == 11 | state_location == "DC"
destring seasch, gen(StateAssignedSchID)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
save "`tempsch'", replace
clear

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
gen AssmtName = "PARCC"
gen SchYear = "2014-15"

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

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/DC_AssmtData_2015", replace
export delimited "`Output'/DC_AssmtData_2015", replace
clear










