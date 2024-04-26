clear
set more off

global Output "/Users/benjaminm/Documents/State_Repository_Research/DC/Output"
global NCES "/Users/benjaminm/Documents/State_Repository_Research/DC/NCES"
global Original "/Users/benjaminm/Documents/State_Repository_Research/DC/Original"
cd "/Users/benjaminm/Documents/State_Repository_Research/DC"

//Importing
tempfile temp1
save "`temp1'", emptyok replace
clear
import excel "${Original}/DC_OriginalData_2016_ela.xlsx", sheet(ELA_Data) firstrow allstring
gen Subject = "ela"
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2016_mat.xlsx", sheet(MATH_Data) firstrow allstring
gen Subject = "math"
append using "`temp1'"
save "${Original}/2016", replace

//Standardizing Varnames
drop if missing(SchoolWard)
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
keep if ind == 1 | GradeLevel == "All ELA" | GradeLevel == "All Math"
replace GradeLevel = "G0" + substr(GradeLevel, 1,1)
replace GradeLevel = "G38" if strpos(GradeLevel, "A") !=0

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
use "${NCES}/NCES_2015_School"
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
// gen Flag_AssmtNameChange = "N"
// gen Flag_CutScoreChange_ELA = "N"
// gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_oth = ""
// gen Flag_CutScoreChange_read = ""

// updated 
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""
// updated 

gen ProficiencyCriteria = "Levels 4-5"
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


//drop StudentGroup_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested 
destring StudentGroup_TotalTested, replace force ignore(",")
// replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

// deriving ProficientOrAbove_count (updated)
destring StudentSubGroup_TotalTested, gen (var1) force 
destring ProficientOrAbove_percent, gen (var2) force
gen var3 = round(var1 * var2, 1)
drop ProficientOrAbove_count
rename var3 ProficientOrAbove_count 
tostring ProficientOrAbove_count, replace force
replace  ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."


//Final Cleaning
// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
//
// keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${Output}/DC_AssmtData_2016", replace
export delimited "${Output}/DC_AssmtData_2016", replace
clear

