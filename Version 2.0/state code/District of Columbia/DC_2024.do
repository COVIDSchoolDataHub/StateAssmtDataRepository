clear
set more off

global Output "/Users/miramehta/Documents/DC State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global Original "/Users/miramehta/Documents/DC State Testing Data/Original Data"
cd "/Users/miramehta/Documents"

/*

//Importing
tempfile temp1
save "`temp1'", replace emptyok
import excel using "${Original}/DC_OriginalData_2024_ela_mat_school", sheet("Meeting, Exceeding") case(preserve) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_school", sheet("Performance Level") case(preserve) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_district", sheet("Meeting, Exceeding") case(preserve) firstrow
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_district", sheet("Performance Level") case(preserve) firstrow
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_state", sheet("Meeting, Exceeding") case(preserve) firstrow
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_state", sheet("Performance Level") case(preserve) firstrow
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_school", sheet("Participation") case(preserve) firstrow
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_district", sheet("Participation") firstrow case(preserve)
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2024_ela_mat_state", sheet("Participation") firstrow case(preserve)
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
/*
clear
import excel using "${Original}/DC_OriginalData_2023_sci_State", sheet(Data) firstrow case(preserve)
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2023_sci_State", sheet(Participation) firstrow case(preserve)
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2023_sci_Dist", sheet(Data) firstrow case(preserve)
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2023_sci_Dist", sheet(Participation) firstrow case(preserve)
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2023_sci_Sch", sheet(Data) firstrow case(preserve)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2023_sci_Sch", sheet(Participation) firstrow case(preserve)
append using "`temp1'"
*/
save "${Original}/2024", replace
*/

use "${Original}/2024", clear

//Standardizing Varnames
replace TestedGradeSubject = GradeofEnrollment if Metric == "Participation"
rename AggregationLevel DataLevel
rename LEACode StateAssignedDistID
rename SchoolCode StateAssignedSchID
rename AssessmentName AssmtName
rename StudentGroupValue StudentSubGroup
rename TestedGradeSubject GradeLevel
drop GradeofEnrollment
keep if AssmtName == "DCCAPE"
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
replace Metric = "ProficientOrAbove" if Metric == "Meeting or Exceeding Expectations"
reshape wide Count Percent TotalCount, i(DataLevel Subject StateAssignedDistID StateAssignedSchID StudentSubGroup GradeLevel) j(Metric, string)

//TotalCount
gen StudentSubGroup_TotalTested = ""
drop TotalCountParticipation
foreach n in 1 2 3 4 5 {
	replace StudentSubGroup_TotalTested = TotalCount`n' if TotalCount`n' != "DS" & TotalCount`n' != "n<10" & !missing(TotalCount`n')
}
forvalues n = 1/5 {
	drop TotalCount`n'
}
drop TotalCountProficientOrAbove
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)

//Renaming
foreach n in 1 2 3 4 5 {
	rename Percent`n' Lev`n'_percent
	rename Count`n' Lev`n'_count
}

rename PercentParticipation ParticipationRate
rename PercentProficientOrAbove ProficientOrAbove_percent
rename CountProficientOrAbove ProficientOrAbove_count
drop CountParticipation

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
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Dis"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino of any race"
replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-binary"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL Active"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL Active or Monitored 1-2 yr"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "CFSA"

drop if strpos(StudentSubGroup, "-") > 0
drop if StudentSubGroup == "Overage"

//StudentGroup
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

//Suppressed/ missing values
foreach var of varlist _all {
	cap replace `var' = "*" if `var' == "n<10" | `var' == "DS"
}

foreach n in 1 2 3 4 5 {
	replace Lev`n'_percent = "*" if missing(Lev`n'_percent)
	replace Lev`n'_count = "*" if missing(Lev`n'_count)
}

replace ProficientOrAbove_percent = "*" if missing(ProficientOrAbove_percent)
replace ProficientOrAbove_count = "*" if missing(ProficientOrAbove_count)

//Fixing Proficiency Levels
foreach n in 1 2 3 4 5 {
	gen range`n' = substr(Lev`n'_percent,1,1) if regexm(Lev`n'_percent, "[<>]") !=0
	gen weak`n' = substr(Lev`n'_percent,2,1) if regexm(Lev`n'_percent, "=") !=0
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-<>=%)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.4g") if regexm(Lev`n'_percent, "[0-9]") == 1 & Lev`n'_percent != "*"
	replace Lev`n'_percent = "0-" + Lev`n'_percent if range`n' == "<"
	replace Lev`n'_percent = Lev`n'_percent + "-1" if range`n' == ">"
	}

gen rangeProf = substr(ProficientOrAbove_percent, 1, 1) if regexm(ProficientOrAbove_percent, "[<>]") !=0
gen weakProf = substr(ProficientOrAbove_percent, 2, 1) if regexm(ProficientOrAbove_percent, "=") !=0
destring ProficientOrAbove_percent, gen(nProf_percent) i(*-<>=%)
replace ProficientOrAbove_percent = string(nProf_percent/100, "%9.4g") if regexm(ProficientOrAbove_percent, "[0-9]") == 1 & ProficientOrAbove_percent != "*"
replace ProficientOrAbove_percent = "0-" + ProficientOrAbove_percent if rangeProf == "<"
replace ProficientOrAbove_percent = ProficientOrAbove_percent + "-1" if rangeProf == ">"

//Subject
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "ELA") !=0
replace Subject = "sci" if strpos(Subject, "Science") !=0

//StudentGroup_TotalTested
foreach n in 1 2 3 4 5 {
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
}

replace StudentSubGroup_TotalTested = string(nLev1_count + nLev2_count + nLev3_count + nLev4_count + nLev5_count) if !missing(nLev1_count) & !missing(nLev2_count) & !missing(nLev3_count) & !missing(nLev4_count) & !missing(nLev5_count) & StudentSubGroup_TotalTested != "*"

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested

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
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District"
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
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School"
keep if state_name == "District of Columbia" | state_location == "DC"
gen StateAssignedSchID = seasch
replace StateAssignedSchID = "219" if strpos(school_name, "Bunker") !=0
replace StateAssignedSchID = substr(StateAssignedSchID, strpos(StateAssignedSchID, "-")+1,10)
merge 1:m StateAssignedSchID using "`tempsch'"
decode district_agency_type, gen(DistType)
drop district_agency_type
rename DistType district_agency_type
drop if _merge == 1
save "`tempsch'", replace

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'", force

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

gen State = "District of Columbia"
gen AvgScaleScore = "--"

// updated 
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable" //update when 2024 science data are released
gen Flag_CutScoreChange_soc = "Not applicable"

gen ProficiencyCriteria = "Levels 4-5"
replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
gen AssmtType = "Regular"
gen SchYear = "2023-24"

//Deriving Additional Information -- Designed for ELA & Math -- DOUBLE CHECK & UPDATE WHEN SCIENCE IS ADDED
replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if ProficientOrAbove_count == "*" & Lev4_count != "*" & Lev5_count != "*" & Subject != "sci"
gen Prof_p_derived = (nLev4_percent + nLev5_percent)/100 if ProficientOrAbove_percent == "*" & Lev4_percent != "*" & Lev5_percent != "*" & Subject != "sci"
replace ProficientOrAbove_percent = string(Prof_p_derived, "%9.4g") if ProficientOrAbove_percent == "*" & Lev4_percent != "*" & Lev5_percent != "*" & Subject != "sci" & range4 == "" & range5 == ""
replace ProficientOrAbove_percent = "0-" + string(Prof_p_derived, "%9.4g") if ProficientOrAbove_percent == "*" & Lev4_percent != "*" & Lev5_percent != "*" & Subject != "sci" & range4 == "<" & range5 == "<"

forvalues n = 1/5{
	replace Lev`n'_count = "0-" + string(round((nLev`n'_percent/100) * real(StudentSubGroup_TotalTested))) if Lev`n'_count == "*" & Lev`n'_percent != "*" & StudentSubGroup_TotalTested != "*" & range`n' == "<"
}

replace ProficientOrAbove_count = "0-" + string(round((nProf_percent/100) * real(StudentSubGroup_TotalTested))) if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "*" & StudentSubGroup_TotalTested != "*" & rangeProf == "<"
replace ProficientOrAbove_count = string(round((nProf_percent/100) * real(StudentSubGroup_TotalTested))) if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "*" & StudentSubGroup_TotalTested != "*" & rangeProf == ""

replace Lev4_percent = string((real(ProficientOrAbove_percent) - (nLev5_percent/100)), "%9.4g") + "-" + ProficientOrAbove_percent if Lev4_percent == "*" & ProficientOrAbove_percent != "*" & Lev5_percent != "*" & range5 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev5_percent = string((real(ProficientOrAbove_percent) - (nLev4_percent/100)), "%9.4g") + "-" + ProficientOrAbove_percent if Lev5_percent == "*" & ProficientOrAbove_percent != "*" & Lev4_percent != "*" & range4 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
split ProficientOrAbove_percent, parse("-")
replace Lev4_percent = string((real(ProficientOrAbove_percent1) - (nLev5_percent/100)), "%9.4g") + "-" + string((real(ProficientOrAbove_percent2) - (nLev5_percent/100)), "%9.4g") if Lev4_percent == "*" & ProficientOrAbove_percent != "*" & Lev5_percent != "*" & range5 == "<" & ProficientOrAbove_percent2 != ""
drop ProficientOrAbove_percent1 ProficientOrAbove_percent2

replace rangeProf = "<" if strpos(ProficientOrAbove_percent, "0-") > 0 & rangeProf == ""

replace Lev1_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev2_percent + nLev3_percent)/100))), "%9.4g") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev1_percent = string((1 - ((nProf_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-1" if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & range2 == "<" & range3 == "<" & rangeProf == "<"
replace Lev1_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev2_percent + nLev3_percent)/100))), "%9.4g") + "-" + string((1 - real(ProficientOrAbove_percent)), "%9.4g") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & range2 == "<" & range3 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev1_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev2_percent + nLev3_percent)/100))), "%9.4g") + "-" + string((1 - (real(ProficientOrAbove_percent) + (nLev2_percent/100))), "%9.4g") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*"& strpos(Lev2_percent, "-") == 0 & range3 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev1_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev2_percent + nLev3_percent)/100))), "%9.4g") + "-" + string((1 - (real(ProficientOrAbove_percent) + (nLev3_percent/100))), "%9.4g") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & range2 == "<" & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev1_percent = string((1 - ((nProf_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - ((nLev2_percent + nLev3_percent)/100)), "%9.4g") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & rangeProf == "<"
replace Lev1_percent = string((1 - ((nProf_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - (nLev2_percent/100)), "%9.4g") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & strpos(Lev2_percent, "-") == 0 & range3 == "<" & rangeProf == "<"
replace range1 = "<" if strpos(Lev1_percent, "0-") > 0 & range1 == ""

replace Lev2_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev3_percent)/100))), "%9.4g") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev3_percent != "*" & strpos(Lev1_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev2_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev3_percent)/100))), "%9.4g") + "-" + string((1 - real(ProficientOrAbove_percent)), "%9.4g") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev3_percent != "*" & range1 == "<" & range3 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev2_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev3_percent)/100))), "%9.4g") + "-" + string((1 - (real(ProficientOrAbove_percent) + (nLev1_percent/100))), "%9.4g") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev3_percent != "*" & strpos(Lev1_percent, "-") == 0 & range3 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev2_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev3_percent)/100))), "%9.4g") + "-" + string((1 - (real(ProficientOrAbove_percent) + (nLev3_percent/100))), "%9.4g") if Lev2_percent == "*" &ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev3_percent != "*" & range1 == "<" & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev2_percent = string((1 - ((nProf_percent + nLev1_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - ((nLev1_percent + nLev3_percent)/100)), "%9.4g") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev3_percent != "*" & strpos(Lev1_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & rangeProf == "<"
replace Lev2_percent = string((1 - ((nProf_percent + nLev1_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - (nLev1_percent/100)), "%9.4g") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev3_percent != "*" & strpos(Lev1_percent, "-") == 0 & range3 == "<" & rangeProf == "<"
replace Lev2_percent = string((1 - ((nProf_percent + nLev1_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - (nLev3_percent/100)), "%9.4g") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev3_percent != "*" & range1 == "<" & strpos(Lev3_percent, "-") == 0 & rangeProf == "<"
replace Lev2_percent = "0" + substr(Lev2_percent, 6, 8) if strpos(Lev2_percent, "-") == 1 & strlen(Lev2_percent) == 10
replace Lev2_percent = "0" + substr(Lev2_percent, 5, 7) if strpos(Lev2_percent, "-") == 1 & strlen(Lev2_percent) == 8
replace range2 = "<" if strpos(Lev2_percent, "0-") > 0 & range2 == ""

replace Lev3_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev2_percent)/100))), "%9.4g") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev2_percent != "*" & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev3_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev2_percent)/100))), "%9.4g") + "-" + string((1 - real(ProficientOrAbove_percent)), "%9.4g") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev2_percent != "*" & range1 == "<" & range2 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev3_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev2_percent)/100))), "%9.4g") + "-" + string((1 - (real(ProficientOrAbove_percent) + (nLev1_percent/100))), "%9.4g") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev2_percent != "*" & strpos(Lev1_percent, "-") == 0 & range2 == "<" & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev3_percent = string((1 - (real(ProficientOrAbove_percent) + ((nLev1_percent + nLev2_percent)/100))), "%9.4g") + "-" + string((1 - (real(ProficientOrAbove_percent) + (nLev2_percent/100))), "%9.4g") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev2_percent != "*" & range1 == "<" & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0
replace Lev3_percent = string((1 - ((nProf_percent + nLev1_percent + nLev2_percent)/100)), "%9.4g") + "-" + string((1 - ((nLev1_percent + nLev2_percent)/100)), "%9.4g") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev2_percent != "*" & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & rangeProf == "<"
replace Lev3_percent = string((1 - ((nProf_percent + nLev1_percent + nLev2_percent)/100)), "%9.4g") + "-" + string((1 - (nLev1_percent/100)), "%9.4g") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev2_percent != "*" & strpos(Lev1_percent, "-") == 0 & range2 == "<" & rangeProf == "<"
replace Lev3_percent = string((1 - ((nProf_percent + nLev1_percent + nLev2_percent)/100)), "%9.4g") + "-" + string((1 - (nLev2_percent/100)), "%9.4g") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*" & Lev2_percent != "*" & range1 == "<" & strpos(Lev2_percent, "-") == 0 & rangeProf == "<"
replace Lev3_percent = "0" + substr(Lev3_percent, 6, 8) if strpos(Lev3_percent, "-") == 1 & strlen(Lev3_percent) == 10
replace Lev3_percent = "0" + substr(Lev3_percent, 5, 7) if strpos(Lev3_percent, "-") == 1 & strlen(Lev3_percent) == 8
replace range3 = "<" if strpos(Lev3_percent, "0-") > 0 & range3 == ""

replace ProficientOrAbove_percent = string((1 - ((nLev1_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0
replace ProficientOrAbove_percent = string((1 - ((nLev1_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - ((nLev1_percent + nLev2_percent)/100)), "%9.4g") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & range3 == "<"
replace ProficientOrAbove_percent = string((1 - ((nLev1_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - ((nLev1_percent + nLev3_percent)/100)), "%9.4g") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & strpos(Lev1_percent, "-") == 0 & range2 == "<" & strpos(Lev3_percent, "-") == 0
replace ProficientOrAbove_percent = string((1 - ((nLev1_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - ((nLev2_percent + nLev3_percent)/100)), "%9.4g") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & range1 == "<" & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0
replace ProficientOrAbove_percent = string((1 - ((nLev1_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - (nLev3_percent/100)), "%9.4g") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & range1 == "<" & range2 == "<" & strpos(Lev3_percent, "-") == 0
replace ProficientOrAbove_percent = string((1 - ((nLev1_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-" + string((1 - (nLev2_percent/100)), "%9.4g") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & range1 == "<" & strpos(Lev2_percent, "-") == 0 & range3 == "<"
replace ProficientOrAbove_percent = string((1 - ((nLev1_percent + nLev2_percent + nLev3_percent)/100)), "%9.4g") + "-1" if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & range1 == "<" & range2 == "<" & range3 == "<"

split ProficientOrAbove_percent, parse("-")
replace Lev4_percent = string((real(ProficientOrAbove_percent) - (nLev5_percent/100)), "%9.4g") + "-" + ProficientOrAbove_percent if Lev4_percent == "*" & ProficientOrAbove_percent != "*" & Lev5_percent != "*" & range5 == "<" & ProficientOrAbove_percent2 == ""
replace Lev4_percent = string((real(ProficientOrAbove_percent1) - (nLev5_percent/100)), "%9.4g") + "-" + ProficientOrAbove_percent2 if Lev4_percent == "*" & ProficientOrAbove_percent != "*" & Lev5_percent != "*" & range5 == "<" & ProficientOrAbove_percent2 != "" & real(ProficientOrAbove_percent1) > 0
replace Lev4_percent = "0" + substr(Lev4_percent, 6, 8) if strpos(Lev4_percent, "-") == 1 & strlen(Lev4_percent) == 10
replace Lev4_percent = "0" + substr(Lev4_percent, 5, 7) if strpos(Lev4_percent, "-") == 1 & strlen(Lev4_percent) == 8
replace Lev5_percent = string((real(ProficientOrAbove_percent) - (nLev4_percent/100)), "%9.4g") + "-" + ProficientOrAbove_percent if Lev5_percent == "*" & ProficientOrAbove_percent != "*" & Lev4_percent != "*" & range4 == "<" & ProficientOrAbove_percent2 == ""
gen flag = 1 if Lev5_percent == "*" & ProficientOrAbove_percent != "*" & Lev4_percent != "*"
sort flag
replace Lev5_percent = string((real(ProficientOrAbove_percent1) - (nLev4_percent/100)), "%9.4g") + "-" + ProficientOrAbove_percent2 if Lev5_percent == "*" & ProficientOrAbove_percent != "*" & Lev4_percent != "*" & range4 == "<" & ProficientOrAbove_percent2 != "" & real(ProficientOrAbove_percent1) > 0

forvalues n = 1/5{
	split Lev`n'_percent, parse("-")
	replace Lev`n'_count = string(round(real(Lev`n'_percent1) * real(StudentSubGroup_TotalTested))) if Lev`n'_count == "*" & Lev`n'_percent != "*" & StudentSubGroup_TotalTested != "*" & Lev`n'_percent2 == ""
	replace Lev`n'_count = string(round(real(Lev`n'_percent1) * real(StudentSubGroup_TotalTested))) + "-" + string(round(real(Lev`n'_percent2) * real(StudentSubGroup_TotalTested))) if Lev`n'_count == "*" & Lev`n'_percent != "*" & StudentSubGroup_TotalTested != "*" & Lev`n'_percent2 != ""
	drop Lev`n'_percent1 Lev`n'_percent2
}

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent1) * real(StudentSubGroup_TotalTested))) if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_percent2 == ""
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent1) * real(StudentSubGroup_TotalTested))) + "-" + string(round(real(ProficientOrAbove_percent2) * real(StudentSubGroup_TotalTested))) if ProficientOrAbove_count == "*" & ProficientOrAbove_percent != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_percent2 != ""
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
drop ProficientOrAbove_percent1 ProficientOrAbove_percent2

//ParticipationRate
gen rangepart = substr(ParticipationRate,1,1) if regexm(ParticipationRate, "[<>]") !=0
gen weakpart = substr(ParticipationRate,2,1) if regexm(ParticipationRate, "=") !=0
destring ParticipationRate, gen(nParticipationRate) i(<>=%*)
replace ParticipationRate = "0-" + string(nParticipationRate/100, "%9.4g") if ParticipationRate != "*" & rangepart == "<"
replace ParticipationRate = string(nParticipationRate/100, "%9.4g") + "-1" if ParticipationRate != "*" & rangepart == ">"
replace ParticipationRate = string(nParticipationRate/100, "%9.4g") if ParticipationRate != "*" & rangepart == ""

//Response to Post Launch Review
replace DistName="Department of Youth Rehabilitation Services (DYRS)" if NCESDistrictID== "1100087"
replace DistName="DC International School" if NCESDistrictID== "1100097" 

//Standardize Level 5 Values for Science
foreach var of varlist Lev5* {
	replace `var' = "" if Subject == "sci"
}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${Output}/DC_AssmtData_2024", replace
export delimited "${Output}/DC_AssmtData_2024", replace
clear





