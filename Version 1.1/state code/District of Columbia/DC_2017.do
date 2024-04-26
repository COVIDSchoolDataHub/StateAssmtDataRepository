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
import excel "${Original}/DC_OriginalData_2017_all.xlsx", sheet(School Performance) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2017_all.xlsx", sheet(LEA Performance) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2017_all.xlsx", sheet(State Performance) firstrow
append using "`temp1'"
save "${Original}/2017", replace
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
// replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "Learner") !=0
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander or Native Hawaiian"
replace StudentSubGroup = subinstr(StudentSubGroup, "Alaskan", "Alaska",.)
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "Active or Monitored English Learner" // updated

keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "EL and Monit or Recently Ex"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex"  // updated
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

//GradeLevel
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08", "G38")

//Supressed Data
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<25"
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
use "${NCES}/NCES_2016_District"
keep if state_name == 11 | state_location == "DC"
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
use "${NCES}/NCES_2016_School"
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
append using "`tempsch'" "`tempdist'"

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
gen SchYear = "2016-17"

//Generating Missing Variables
foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"

//Leaving ParticipationRate empty for now
gen ParticipationRate = ""


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

save "${Output}/DC_AssmtData_2017", replace
export delimited "${Output}/DC_AssmtData_2017", replace
clear





