clear
set more off
local Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
local Output "/Volumes/T7/State Test Project/District of Columbia/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

//Importing
tempfile temp1
save "`temp1'", replace emptyok
import delimited using "`Original'/DC_OriginalData_2023_Sch", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import delimited using "`Original'/DC_OriginalData_2023_Sch2", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "`Original'/DC_OriginalData_2023_Dist", sheet(Data) case(preserve) firstrow
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "`Original'/DC_OriginalData_2023_State", sheet(Performance Level) case(preserve) firstrow
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear
import delimited using "`Original'/DC_OriginalData_2023_Sch_Part", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "`Original'/DC_OriginalData_2023_Dist", sheet(Participation) firstrow case(preserve)
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "`Original'/DC_OriginalData_2023_State", sheet(Participation) firstrow case(preserve)
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`Original'/2023", replace

//Standardizing Varnames
replace TestedGradeSubject = GradeofEnrollment if Metric == "Participation"
rename AggregationLevel DataLevel
rename LEACode StateAssignedDistID
rename SchoolCode StateAssignedSchID
rename AssessmentName AssmtName
rename StudentGroupValue StudentSubGroup
rename TestedGradeSubject GradeLevel
drop GradeofEnrollment
keep if AssmtName == "PARCC" | AssmtName == "DC Science"
rename LEAName DistName
rename SchoolName SchName
keep if SchoolFramework == "All"
drop SchoolFramework

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ","",.)
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Reshaping from long to wide
replace Metric = subinstr(Metric, "Performance Level ","",.)
duplicates drop
duplicates tag DataLevel Subject Metric StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel, gen(ind)
drop if ind !=0 & (Count == "n<10" | Count == "DS")
save "/Volumes/T7/State Test Project/District of Columbia/Testing/2023", replace
reshape wide Count Percent TotalCount, i(DataLevel Subject StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel) j(Metric, string)

//TotalCount
gen StudentSubGroup_TotalTested = ""
drop TotalCountParticipation
foreach n in 1 2 3 4 5 {
	replace StudentSubGroup_TotalTested = TotalCount`n' if TotalCount`n' != "DS" & TotalCount`n' != "n<10"
}
forvalues n = 1/5 {
	drop TotalCount`n'
}
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)

//Renaming
foreach n in 1 2 3 4 5 {
	rename Percent`n' Lev`n'_percent
	rename Count`n' Lev`n'_count
}
drop ind
rename PercentParticipation ParticipationRate

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel ==1 | DataLevel ==2


//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL Active or Monitored 1-2 yr"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not EL Active or Monitored 1-2 yr"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Econ Dis"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino of any race"
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
drop StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

//Suppressed/ missing values
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<10" | `var' == "DS"
}

foreach n in 1 2 3 4 5 {
	replace Lev`n'_percent = "*" if missing(Lev`n'_percent)
	replace Lev`n'_count = "*" if missing(Lev`n'_count)
}

//Fixing Proficiency Levels
foreach n in 1 2 3 4 5 {
	gen range`n' = substr(Lev`n'_percent,1,1) if regexm(Lev`n'_percent, "[<>]") !=0
	gen weak`n' = substr(Lev`n'_percent,2,1) if regexm(Lev`n'_percent, "=") !=0
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-<>=%)
	replace Lev`n'_percent = range`n' + weak`n' + string(nLev`n'_percent/100, "%9.4g") if regexm(Lev`n'_percent, "[0-9]") == 1
}

//Subject
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "ELA") !=0

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

//Fixing One Unmerged
replace NCESSchoolID = "110001900779" if StateAssignedSchID == "1292"
replace NCESDistrictID = "1100019" if StateAssignedSchID == "1292"
replace State_leaid = "DC-151" if StateAssignedSchID == "1292"
replace seasch = "151-1292" if StateAssignedSchID == "1292"
replace DistType = 7 if StateAssignedSchID == "1292"
replace SchType = 1 if StateAssignedSchID == "1292"
replace SchLevel = 2 if StateAssignedSchID == "1292"
replace SchVirtual = 0 if StateAssignedSchID == "1292"
replace DistCharter = "Yes" if StateAssignedSchID == "1292"
replace CountyName = "District of Columbia" if StateAssignedSchID == "1292"
replace CountyCode = 11001 if StateAssignedSchID == "1292"
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel == 3
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
gen SchYear = "2022-23"

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

replace ProficientOrAbove_percent = range4 + weak4 + ProficientOrAbove_percent if (range5 == "" | range4==range5) & ProficientOrAbove_percent != "*"
replace ProficientOrAbove_percent = range5 + weak5 + ProficientOrAbove_percent if (range4 == "" | range4 == range5) & regexm(ProficientOrAbove_percent, "[<>]") == 0 & ProficientOrAbove_percent != "*"

//ParticipationRate
gen rangepart = substr(ParticipationRate,1,1) if regexm(ParticipationRate, "[<>]") !=0
gen weakpart = substr(ParticipationRate,2,1) if regexm(ParticipationRate, "=") !=0
destring ParticipationRate, gen(nParticipationRate) i(<>=%*)
replace ParticipationRate = rangepart + weakpart + string(nParticipationRate/100, "%9.4g") if ParticipationRate != "*"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/DC_AssmtData_2023", replace
export delimited "`Output'/DC_AssmtData_2023", replace
clear







