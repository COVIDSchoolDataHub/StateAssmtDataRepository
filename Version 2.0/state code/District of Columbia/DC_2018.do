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
import excel "${Original}/DC_OriginalData_2018_all.xlsx", sheet(School Performance) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2018_all.xlsx", sheet(LEA Performance) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2018_all.xlsx", sheet(State Performance) firstrow
append using "`temp1'"
save "${Original}/2018", replace
replace K = M if !missing(LEAName) & missing(SchoolName)
replace K = P if !missing(SchoolName)
drop P
drop M

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
replace DataLevel = "District" if !missing(StateAssignedDistID) & missing(StateAssignedSchID)
replace DataLevel = "School" if !missing(StateAssignedDistID) & !missing(StateAssignedSchID)
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel ==1 | DataLevel ==2
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel ==1 | DataLevel ==2

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander or Native Hawaiian"
replace StudentSubGroup = subinstr(StudentSubGroup, "Alaskan", "Alaska",.)
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "Active or Monitored English Learner"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"


keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Gender X" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" | StudentSubGroup == "Homeless" |  StudentSubGroup == "Non-Homeless"| StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex"  // updated
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"

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
clear
//District Level
use "`temp1'"
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2017_District"
keep if state_name == "District of Columbia" | state_location == "DC"
gen StateAssignedDistID = subinstr(state_leaid, "DC-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge ==1
save "`tempdist'", replace
clear
//School Level
use "`temp1'"
keep if DataLevel ==3
tempfile tempsch
save "`tempsch'", replace
clear
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2017_School"
keep if state_name == "District of Columbia" | state_location == "DC"
gen StateAssignedSchID = seasch
replace StateAssignedSchID = "219" if strpos(school_name, "Bunker") !=0
replace StateAssignedSchID = substr(StateAssignedSchID, strpos(StateAssignedSchID, "-")+1,10)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
save "`tempsch'", replace

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempsch'" "`tempdist'"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
// rename school_type SchType
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
gen Flag_CutScoreChange_sci = "Not applicable"
gen Flag_CutScoreChange_soc = "Not applicable"

gen ProficiencyCriteria = "Levels 4-5"
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
foreach n in 1 2 3 4 5 {
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
}

replace StudentSubGroup_TotalTested = string(nLev1_count + nLev2_count + nLev3_count + nLev4_count + nLev5_count) if !missing(nLev1_count) & !missing(nLev2_count) & !missing(nLev3_count) & !missing(nLev4_count) & !missing(nLev5_count) & StudentSubGroup_TotalTested != "*"

replace SchName = stritrim(SchName)
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

//Dropping unmerged school with fully suppressed data
drop if SchName == "Youth Services Center"

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

save "${Output}/DC_AssmtData_2018", replace
export delimited "${Output}/DC_AssmtData_2018", replace
clear






