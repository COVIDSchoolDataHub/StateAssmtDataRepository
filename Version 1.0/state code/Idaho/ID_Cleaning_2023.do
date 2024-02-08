clear
set more off
set trace off
local Original "/Volumes/T7/State Test Project/Idaho/Original Data"
local Output "/Volumes/T7/State Test Project/Idaho/Output"
local NCES "/Volumes/T7/State Test Project/NCES"
local years 2023


//Importing (hide on first run)
foreach year of local years { 

local prevyear =`=`year'-1'

/*

import excel using "`Original'/ID_OriginalData_`year'.xlsx", sheet("State of Idaho") firstrow allstring

gen DataLevel = "State"

save "`Original'/`year'_State", replace
import excel using "`Original'/ID_OriginalData_`year'.xlsx", sheet("Districts") firstrow allstring clear
gen DataLevel = "District"
save "`Original'/`year'_District", replace
import excel using "`Original'/ID_OriginalData_`year'.xlsx", sheet("Schools") firstrow allstring clear
gen DataLevel = "School"
save "`Original'/`year'_School", replace

*/

clear
use "`Original'/`year'_State"
append using "`Original'/`year'_District"
append using "`Original'/`year'_School"


//Variable Names
rename SubjectName Subject
rename Grade GradeLevel
rename Population StudentSubGroup
rename AdvancedRate Lev4_percent
rename ProficientRate Lev3_percent
rename BasicRate Lev2_percent
rename BelowBasicRate Lev1_percent
rename Advanced Lev4_count
rename Proficient Lev3_count
rename Basic Lev2_count
rename BelowBasic Lev1_count
rename TestedRate ParticipationRate
rename DistrictId StateAssignedDistID
rename DistrictName DistName
rename SchoolId StateAssignedSchID
rename SchoolName SchName
rename ProficiencyDenominator StudentSubGroup_TotalTested

//GradeLevel
drop if GradeLevel == "High School" | GradeLevel == "All Grades"
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

//StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup,"Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup,"Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Economically Disadvantaged "
replace StudentSubGroup = "Not Economically Disadvantaged" if strpos(StudentSubGroup, "Not Economically Disadvantaged") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian or Alaskan Native") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not LEP"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two Or More") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Suppressed and Missing Data
foreach var of varlist Lev* Participation* StudentSubGroup_TotalTested {
	replace `var' = "*" if `var' == "NSIZE"
	replace `var' = "--" if `var' == "N/A"
}
foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count {
	replace `var' = "*" if Lev1_percent == "*" & missing(`var')
	replace `var' = "--" if Lev1_percent == "--" & missing(`var')
	replace `var' = "*" if missing(`var')
}
replace StudentSubGroup_TotalTested = "*" if Lev1_count == "*" & missing(StudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = "--" if Lev1_count == "--" & missing(StudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)


//Proficiency Levels
foreach var of varlist Lev*_percent ParticipationRate {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}
gen ProficientOrAbove_count = string(real(Lev3_count)+ real(Lev4_count))
replace ProficientOrAbove_count = "*" if Lev3_count == "*" | Lev4_count == "*"
replace ProficientOrAbove_count = "--" if Lev3_count == "--" | Lev4_count == "--"
gen ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100, "%9.3g")
replace ProficientOrAbove_percent = rangeLev3_percent + ProficientOrAbove_percent if !missing(rangeLev3_percent) & missing(rangeLev4_percent)
replace ProficientOrAbove_percent = rangeLev4_percent + ProficientOrAbove_percent if !missing(rangeLev4_percent) & missing(rangeLev3_percent)
replace ProficientOrAbove_percent = rangeLev3_percent + ProficientOrAbove_percent if rangeLev3_percent == rangeLev4_percent & regexm(rangeLev3_percent, "[<>]") !=0
replace ProficientOrAbove_percent = "*" if rangeLev3_percent != rangeLev4_percent & regexm(rangeLev3_percent, "[<>]") !=0 & regexm(rangeLev4_percent, "[<>]") !=0
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent,">","",.) + "-1" if strpos(ProficientOrAbove_percent, ">") !=0
replace ProficientOrAbove_percent = subinstr(ProficientOrAbove_percent, "<","0-",.) if strpos(ProficientOrAbove_percent, "<") !=0
replace ProficientOrAbove_percent = "*" if (Lev3_percent == "*" | Lev4_percent == "*") & ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "--" if (Lev3_percent == "--" | Lev4_percent == "--") & ProficientOrAbove_percent == "."

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3


** Merging
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES'/NCES_2021_District"
keep if state_location == "ID" | state_name == 16
gen StateAssignedDistID = subinstr(state_leaid, "ID-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2021_School"
keep if state_location == "ID" | state_name == 16
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-") +1, 10)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel == 1
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
replace StateFips = 16
replace StateAbbrev = "ID"

//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3 and 4"

//AssmtName
gen AssmtName = "ISAT"

//State 
gen State = "Idaho"

//AssmtType
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth = "N"

//Missing/empty Variables
gen Lev5_count = ""
gen Lev5_percent= ""
gen AvgScaleScore = "--"

//SchYear
gen SchYear = "2022-23"

//Fixing Unmerged
replace NCESSchoolID = "160219001178" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace NCESDistrictID = "1602190" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace State_leaid = "ID-331" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace seasch = "331-1495" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace DistCharter = "No" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace SchType = 4 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace DistType = 1 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace CountyName = "Minidoka County" if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace CountyCode = 16067 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace SchLevel = 2 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"
replace SchVirtual = 0 if _merge == 2 & SchName == "MINIDOKA JUNIOR HIGH ALTERNATIVE"

replace NCESSchoolID = "160093001171" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace NCESDistrictID = "1600930" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace State_leaid = "ID-093" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace seasch = "093-1482" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace DistCharter = "No" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace SchType = 1 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace DistType = 1 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace CountyName = "Bonneville County" if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace CountyCode = 16019 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace SchLevel = 2 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"
replace SchVirtual = 0 if _merge == 2 & SchName == "PRAXIUM MASTERY ACADEMY"

replace NCESSchoolID = "160309001177" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace NCESDistrictID = "1603090" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace State_leaid = "ID-322" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace seasch = "322-1483" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace DistCharter = "No" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace SchType = 1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace DistType = 1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace CountyName = "Madison County" if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace CountyCode = 16065 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace SchLevel = -1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"
replace SchVirtual = 1 if _merge == 2 & SchName == "SUGAR-SALEM ONLINE"

replace NCESSchoolID = "160225001174" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace NCESDistrictID = "1602250" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace State_leaid = "ID-193" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace seasch = "193-1494" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace DistCharter = "No" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace SchType = 4 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace DistType = 1 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace CountyName = "Elmore County" if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace CountyCode = 16039 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace SchLevel = 2 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"
replace SchVirtual = 0 if _merge == 2 & SchName == "TIGER LEARN PROGRAM"

//Dropping if StudentSubGroup_TotalTested == "--"
drop if StudentSubGroup_TotalTested == "--"

//SchVirtual for Select Schools
label define SchVirtual -1 "Missing/not reported", add
replace SchVirtual = 1 if SchName == "COEUR D'ALENE VIRTUAL ACADMEY"
replace SchVirtual = -1 if SchName == "ELEVATE ACADEMY NAMPA"
replace SchVirtual = -1 if SchName == "ELEVATE ACADEMY NORTH"
replace SchVirtual = -1 if SchName == "GEM PREP: MERIDIAN SOUTH"
replace SchVirtual = -1 if SchName == "MOUNTAIN COMMUNITY SCHOOL"
replace SchVirtual = 1 if SchName == "IDAHO FUTURE READY ACADEMY FOR VIRTUAL LEARNING"


//Final cleaning and dropping extra variables

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/ID_AssmtData_2023", replace
export delimited "`Output'/ID_AssmtData_2023", replace

}
