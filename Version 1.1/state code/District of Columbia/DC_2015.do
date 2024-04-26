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
import excel "${Original}/DC_OriginalData_2015_all.xlsx", sheet(School) firstrow allstring
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2015_all.xlsx", sheet(State & Sector) firstrow allstring
append using "`temp1'"
save "${Original}/2015", replace
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


// updated 
drop if DataLevel == "Public Charter Schools"
replace DataLevel = "District" if DataLevel == "DCPS" 

//DataLevel
replace DataLevel = "School" if missing(DataLevel)
//replace DataLevel = "District" if DataLevel != "School" & DataLevel != "State"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel
rename DataLevel_n DataLevel
//drop if DataLevel ==2 // THIS IS WHY 
replace DistName = "All Districts" if DataLevel ==1  
replace SchName = "All Schools" if DataLevel ==1 | DataLevel ==2
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel ==1 | DataLevel ==2

replace StateAssignedDistID = "001" if DataLevel ==2
replace DistName = "District of Columbia Public Schools" if DataLevel ==2


replace StateAssignedDistID = "001" if StateAssignedDistID == "1" 


//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English")
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Alaskan") !=0
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
replace GradeLevel = "G38" if GradeLevel == "G0All"
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08", "G38")

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
clear


//District Level
use "`temp1'"
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES}/NCES_2014_District"
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
use "${NCES}/NCES_2014_School"
keep if state_name == 11 | state_location == "DC"
gen StateAssignedSchID = seasch
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
save "`tempsch'", replace
clear


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


// destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
// sort StudentGroup
// egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
// tostring StudentGroup_TotalTested, replace
// replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Final Cleaning
// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
//
// keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${Output}/DC_AssmtData_2015", replace
export delimited "${Output}/DC_AssmtData_2015", replace
clear









