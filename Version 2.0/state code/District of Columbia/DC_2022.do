clear
set more off

global Output "/Users/miramehta/Documents/DC State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global Original "/Users/miramehta/Documents/DC State Testing Data/Original Data"
cd "/Users/miramehta/Documents"

/*
//Importing ela/math
tempfile temp1
save "`temp1'", replace emptyok
import delimited using "${Original}/DC_OriginalData_2022_Sch", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2022_Dist", sheet(Data) firstrow allstring
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2022_State", sheet(Data) case(preserve) firstrow
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear

//Importing sci
tempfile temp2
save "`temp2'", replace emptyok
import excel using "${Original}/DC_OriginalData_2022_sci_Sch", sheet(perf_level) firstrow case(preserve) allstring
append using "`temp2'"
save "`temp2'", replace
clear
import excel using "${Original}/DC_OriginalData_2022_sci_Dist", sheet(perf_level) firstrow case(preserve) allstring
replace AggregationLevel = "District"
append using "`temp2'"
save "`temp2'", replace
clear
import excel using "${Original}/DC_OriginalData_2022_sci_State", sheet(perf_level) firstrow case(preserve)
replace LEACode = ""
replace SchoolCode = ""
append using "`temp2'"
append using "`temp1'"

replace LEAName = lea_name if missing(LEAName)
drop lea_name
replace MetricValue = metric_value if missing(MetricValue)
drop metric_value


save "${Original}/2022", replace
*/

use "${Original}/2022", clear

tab SubgroupValue

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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Econ Dis"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander or Native Hawaiian"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "Active or Monitored English Learner" // updated
replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-binary" // updated

replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "Homeless"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"	
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not Military Connected"

keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Gender X" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" | StudentSubGroup == "Homeless" |  StudentSubGroup == "Non-Homeless"| StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"  // updated



//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" 
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

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
foreach n in 1 2 3 4 5 {
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
}

replace StudentSubGroup_TotalTested = string(nLev1_count + nLev2_count + nLev3_count + nLev4_count + nLev5_count) if !missing(nLev1_count) & !missing(nLev2_count) & !missing(nLev3_count) & !missing(nLev4_count) & !missing(nLev5_count) & StudentSubGroup_TotalTested != "*"

replace SchName = stritrim(SchName)
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
use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_2021_District"
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
use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_2021_School"
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
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"

gen ProficiencyCriteria = "Levels 4-5"
gen AssmtType = "Regular"
gen SchYear = "2021-22"

//ProficientOrAbove_count and Percent
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
replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace Lev5_count = "" if Subject == "sci"
replace Lev5_percent = "" if Subject == "sci"

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
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(ProficientOrAbove_count))

//Deriving ProficientOrAbove_count and ProficientOrAbove_percent where possible if Levels 1-3 are available (for ela and math)/Levels 1-2 are available (for sci)
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count)) if Subject != "sci" & regexm(ProficientOrAbove_count, "[*-]") !=0 & regexm(Lev1_count, "[*-]") == 0 & regexm(Lev2_count, "[*-]") == 0 & regexm(Lev3_count, "[*-]") == 0
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if Subject == "sci" & regexm(ProficientOrAbove_count, "[*-]") !=0 & regexm(Lev1_count, "[*-]") == 0 & regexm(Lev2_count, "[*-]") == 0
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent), "%9.3g") if Subject != "sci" & regexm(ProficientOrAbove_percent, "[*-]") !=0 & regexm(Lev1_percent, "[*-]") == 0 & regexm(Lev2_percent, "[*-]") == 0 & regexm(Lev3_percent, "[*-]") == 0
replace ProficientOrAbove_percent = string((1 - real(Lev1_percent) - real(Lev2_percent)), "%9.4g") if Subject != "sci" & regexm(ProficientOrAbove_percent, "[*-]") !=0 & regexm(Lev1_percent, "[*-]") == 0 & regexm(Lev2_percent, "[*-]") == 0
replace ProficientOrAbove_percent = string((1 - real(Lev1_percent) - real(Lev2_percent)), "%9.4g") if Subject == "sci" & missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent))
replace ProficientOrAbove_percent = "0" if real(ProficientOrAbove_percent) < 0
replace ProficientOrAbove_percent = "0" if inlist(ProficientOrAbove_percent, "1.11e-16", "1.39e-17", "2.78e-17", "4.16e-17", "5.55e-17")

replace Lev3_percent = string((1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev2_percent)), "%9.4g") if Lev3_percent == "*" & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & Subject != "sci"
replace Lev3_percent = "0" if real(Lev3_percent) < 0

replace Lev3_percent = string((real(ProficientOrAbove_percent) - real(Lev4_percent)), "%9.4g") if missing(real(Lev3_percent)) & !missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & Subject == "sci"
replace Lev4_percent = string((real(ProficientOrAbove_percent) - real(Lev3_percent)), "%9.4g") if Lev4_percent == "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & Subject == "sci"
replace Lev4_percent = string((real(ProficientOrAbove_percent) - real(Lev5_percent)), "%9.4g") if Lev4_percent == "*" & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & Subject != "sci"
replace Lev5_percent = string((real(ProficientOrAbove_percent) - real(Lev4_percent)), "%9.4g") if Lev5_percent == "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & Subject != "sci"

replace Lev1_percent = string((1 - real(ProficientOrAbove_percent) - real(Lev2_percent)), "%9.4g") if missing(real(Lev1_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(Lev2_percent) & Subject == "sci"

//Deriving Lev*_count
foreach count of varlist Lev*_count {
local percent = subinstr("`count'", "count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if regexm(`count', "[*-]") !=0 & regexm(`percent', "[*-]") == 0 & regexm(StudentSubGroup_TotalTested, "[*-]") == 0 
}
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(ProficientOrAbove_count))

replace Lev3_count = string(round((1 - real(ProficientOrAbove_count) - real(Lev1_count) - real(Lev2_count)))) if missing(real(Lev3_count)) & !missing(real(ProficientOrAbove_count)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & Subject != "sci"
replace Lev3_count = "0" if real(Lev3_count) < 0
replace Lev3_percent = "0" if Lev3_count == "0"

//Dropping observations without "All Students" counterpart or any actual information
drop if NCESDistrictID == "1100099" & DataLevel == 2 & Subject == "sci" & GradeLevel == "G08" & inlist(StudentSubGroup, "SWD", "Homeless")
drop if NCESDistrictID == "1100099" & NCESSchoolID == "110009900502" & Subject == "sci" & GradeLevel == "G08" & inlist(StudentSubGroup, "SWD", "Homeless")

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/DC_AssmtData_2022", replace
export delimited "${Output}/DC_AssmtData_2022", replace
clear

