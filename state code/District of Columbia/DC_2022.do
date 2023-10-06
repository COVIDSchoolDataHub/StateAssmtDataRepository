clear
set more off
local Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
local Output "/Volumes/T7/State Test Project/District of Columbia/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

//Importing ela/math
tempfile temp1
save "`temp1'", replace emptyok
import delimited using "`Original'/DC_OriginalData_2022_Sch", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "`Original'/DC_OriginalData_2022_Dist", sheet(Data) firstrow allstring
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "`Original'/DC_OriginalData_2022_State", sheet(Data) case(preserve) firstrow
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear

//Importing sci
tempfile temp2
save "`temp2'", replace emptyok
import excel using "`Original'/DC_OriginalData_2022_sci_Sch", sheet(perf_level) firstrow case(preserve) allstring
append using "`temp2'"
save "`temp2'", replace
clear
import excel using "`Original'/DC_OriginalData_2022_sci_Dist", sheet(perf_level) firstrow case(preserve) allstring
replace AggregationLevel = "District"
append using "`temp2'"
save "`temp2'", replace
clear
import excel using "`Original'/DC_OriginalData_2022_sci_State", sheet(perf_level) firstrow case(preserve)
replace LEACode = ""
replace SchoolCode = ""
append using "`temp2'"
append using "`temp1'"

replace LEAName = lea_name if missing(LEAName)
drop lea_name
replace MetricValue = metric_value if missing(MetricValue)
drop metric_value
save "`Original'/2022", replace

//Standardizing Varnames
rename AggregationLevel DataLevel
rename LEACode StateAssignedDistID
rename SchoolCode StateAssignedSchID
rename AssessmentName AssmtName
rename SubgroupValue StudentSubGroup
rename TestedGradeSubject GradeLevel
drop GradeofEnrollment
keep if AssmtName == "PARCC" | AssmtName == "DC Science"
rename LEAName DistName
rename SchoolName SchName
rename TotalCount StudentSubGroup_TotalTested

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ","",.)
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Reshaping from long to wide
replace MetricValue = subinstr(MetricValue, "Performance Level ","",.)
duplicates drop
duplicates tag DataLevel Subject MetricValue StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel, gen(ind)
drop if ind !=0 & (Count == "n<10" | Count == "DS")
drop if Count == "DS"
reshape wide Count Percent, i(DataLevel Subject StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel) j(MetricValue, string)

//Renaming
foreach n in 1 2 3 4 5 {
	rename Percent`n' Lev`n'_percent
	rename Count`n' Lev`n'_count
}
drop ind

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel ==1 | DataLevel == 2

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not an English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Econ Dis"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander or Native Hawaiian"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

//Suppressed/ missing values
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<10"
}
foreach n in 1 2 3 4 5 {
	replace Lev`n'_count = "*" if missing(Lev`n'_count)
	replace Lev`n'_percent = "*" if missing(Lev`n'_percent)
}
replace Lev5_count = "" if Subject == "Science"
replace Lev5_percent = "" if Subject == "Science"

//Fixing Proficiency Levels
foreach n in 1 2 3 4 5 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4g") if regexm(Lev`n'_percent, "[0-9]") == 1
}

//Subject
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "ELA") !=0
replace Subject = "sci" if strpos(Subject, "Science") !=0

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"

//Merging with NCES
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2
tempfile temp1
save "`temp1'"
clear
//District Level
use "`temp1'"
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES'/NCES_2021_District"
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
use "`NCES'/NCES_2021_School"
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
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 4 and 5"
gen AssmtType = "Regular"
gen SchYear = "2021-22"

//ProficientOrAbove_count and Percent
foreach n in 1 2 3 4 5 {
	destring Lev`n'_count, gen(nLev`n'_count) i(-*)
}
gen ProficientOrAbove_percent = string((nLev4_percent + nLev5_percent)/100, "%9.4g") if Subject != "sci"
replace ProficientOrAbove_percent = "*" if (Lev4_percent == "*" | Lev5_percent == "*") & Subject != "sci"
gen ProficientOrAbove_count = string(nLev4_count + nLev5_count, "%9.4g") if Subject != "sci"
replace ProficientOrAbove_count = "*" if (Lev4_count == "*" | Lev5_count == "*") & Subject != "sci"


replace ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100, "%9.4g") if Subject == "sci"
replace ProficientOrAbove_percent = "*" if (Lev3_percent == "*" | Lev4_percent == "*") & Subject == "sci"
replace ProficientOrAbove_count = string(nLev3_count + nLev4_count, "%9.4g") if Subject == "sci"
replace ProficientOrAbove_count = "*" if (Lev3_count == "*" | Lev4_count == "*") & Subject == "sci"

//Leaving ParticipationRate blank for now
gen ParticipationRate = ""

//Extra cleaning for sci 
replace ProficiencyCriteria = "Levels 3 and 4" if Subject == "sci"
replace Lev5_count = "" if Subject == "sci"
replace Lev5_percent = "" if Subject == "sci"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/DC_AssmtData_2022", replace
export delimited "`Output'/DC_AssmtData_2022", replace
clear

