clear
set more off

global Output "/Users/miramehta/Documents/DC State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global Original "/Users/miramehta/Documents/DC State Testing Data/Original Data"
cd "/Users/miramehta/Documents"

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
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2015_School"
keep if state_name == "District of Columbia" | state_location == "DC"
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
gen Flag_CutScoreChange_sci = "Not Applicable"
gen Flag_CutScoreChange_soc = "Not Applicable"

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

//StudentGroup_TotalTested
foreach n in 1 2 3 4 5 {
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
}

replace StudentSubGroup_TotalTested = string(nLev1_count + nLev2_count + nLev3_count + nLev4_count + nLev5_count) if !missing(nLev1_count) & !missing(nLev2_count) & !missing(nLev3_count) & !missing(nLev4_count) & !missing(nLev5_count) & StudentSubGroup_TotalTested != "*"

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested

// deriving ProficientOrAbove_count (updated)
destring StudentSubGroup_TotalTested, gen (var1) force 
destring ProficientOrAbove_percent, gen (var2) force
gen var3 = round(var1 * var2, 1)
drop ProficientOrAbove_count
rename var3 ProficientOrAbove_count 
tostring ProficientOrAbove_count, replace force
replace  ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

//Response to Post Launch Review
replace DistName="BASIS DC PCS" if NCESDistrictID== "1100083"
replace DistName="Cesar Chavez PCS for Public Policy" if NCESDistrictID== "1100005"
replace DistName="DC Bilingual PCS" if NCESDistrictID== "1100042"
replace DistName="DC Prep PCS" if NCESDistrictID== "1100048"
replace DistName="Department of Youth Rehabilitation Services (DYRS)" if NCESDistrictID== "1100087"
replace DistName="Democracy Prep Congress Heights PCS" if NCESDistrictID== "1100095"
replace DistName="DC International School" if NCESDistrictID== "1100097"
replace DistName="E.L. Haynes PCS" if NCESDistrictID== "1100043"
replace DistName="Harmony DC PCS" if NCESDistrictID== "1100096"
replace DistName="Hope Community PCS" if NCESDistrictID== "1100051"
replace DistName="Howard University Middle School of Mathematics and Science PCS" if NCESDistrictID== "1100058"
replace DistName="Latin American Montessori Bilingual PCS" if NCESDistrictID== "1100032"
replace DistName="Mary McLeod Bethune Day Academy PCS" if NCESDistrictID== "1100044"
replace DistName="Perry Street Preparatory PCS" if NCESDistrictID== "1100011"
replace DistName="Rocketship Education DC PCS" if NCESDistrictID=="1100106"
replace DistName="SEED PCS of Washington DC" if NCESDistrictID== "1100022"
replace DistName="Shining Stars Montessori Academy PCS" if NCESDistrictID== "1100081"
replace DistName="Somerset Preparatory Academy PCS" if NCESDistrictID== "1100089"
replace DistName="Statesmen College Preparatory Academy for Boys PCS" if NCESDistrictID== "1100110"
replace DistName="The Children's Guild DC PCS" if NCESDistrictID== "1100101"
replace DistName="City Arts & Prep PCS" if NCESDistrictID== "1100053" // this was also Doar, but same dist/sch 

//Deriving Lev*_count
foreach count of varlist Lev*_count {
local percent = subinstr("`count'", "count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if regexm(`count', "[*-]") !=0 & regexm(`percent', "[*-]") == 0 & regexm(StudentSubGroup_TotalTested, "[*-]") == 0 
}

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${Output}/DC_AssmtData_2016", replace
export delimited "${Output}/DC_AssmtData_2016", replace
*clear

