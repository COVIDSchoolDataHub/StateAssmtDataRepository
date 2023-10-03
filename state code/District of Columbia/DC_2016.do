clear
set more off
local Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
local Output "/Volumes/T7/State Test Project/District of Columbia/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

//Importing
tempfile temp1
save "`temp1'", emptyok replace
clear
import excel "`Original'/DC_OriginalData_2016_ela.xlsx", sheet(ELA_Data) firstrow
gen Subject = "ela"
append using "`temp1'"
save "`temp1'", replace
clear
import excel "`Original'/DC_OriginalData_2016_mat.xlsx", sheet(MATH_Data) firstrow
gen Subject = "math"
append using "`temp1'"
save "`Original'/2016", replace

//Standardizing Varnames
drop SchoolWard
rename LEACode StateAssignedDistID
rename LEAName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename TestedGradeSubject GradeLevel
foreach n in 1 2 3 4 5 {
	rename level`n' Lev`n'_percent
}
rename Totalvalidtesttakers StudentSubGroup_TotalTested


//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedSchID == "Statewide"
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

//StudentGroup and StudentSubGroup
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

//GradeLevel
gen ind = regexm(GradeLevel,"[3-8]") & strpos(GradeLevel, "Test") !=0
keep if ind == 1
replace GradeLevel = "G0" + substr(GradeLevel, 1,1)

//Supressed Data
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<25"
}

//Merging with NCES
tempfile temp1
save "`temp1'"

//School Level
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2015_School"
keep if state_name == 11 | state_location == "DC"
gen StateAssignedSchID = seasch
replace StateAssignedSchID = "219" if strpos(school_name, "Bunker") !=0
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
gen SchYear = "2015-16"

//Generating Missing Variables
foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"

//Leaving ParticipationRate empty for now
gen ParticipationRate = ""

//ProficientOrAbove_percent 
foreach n in 1 2 3 4 5 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*)
}
gen ProficientOrAbove_percent = string(nLev4_percent + nLev5_percent, "%9.4g")
replace ProficientOrAbove_percent = "*" if Lev4_percent == "*" | Lev5_percent == "*"
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."


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
save "`Output'/DC_AssmtData_2016", replace
export delimited "`Output'/DC_AssmtData_2016", replace
clear

