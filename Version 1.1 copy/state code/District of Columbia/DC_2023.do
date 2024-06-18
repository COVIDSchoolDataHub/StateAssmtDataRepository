clear
set more off

global Output "/Volumes/T7/State Test Project/District of Columbia/Output"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
cd "/Volumes/T7/State Test Project/District of Columbia"


/*
//Importing
tempfile temp1
save "`temp1'", replace emptyok
import delimited using "${Original}/DC_OriginalData_2023_Sch", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import delimited using "${Original}/DC_OriginalData_2023_Sch2", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2023_Dist", sheet(Data) case(preserve) firstrow
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2023_State", sheet(Performance Level) case(preserve) firstrow
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
clear
import delimited using "${Original}/DC_OriginalData_2023_Sch_Part", case(preserve) stringcols(2,4)
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2023_Dist", sheet(Participation) firstrow case(preserve)
replace AggregationLevel = "District"
append using "`temp1'"
save "`temp1'", replace
clear
import excel using "${Original}/DC_OriginalData_2023_State", sheet(Participation) firstrow case(preserve)
replace LEACode = ""
replace SchoolCode = ""
append using "`temp1'"
save "`temp1'", replace
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

save "${Original}/2023", replace
*/


use "${Original}/2023", clear

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
keep if SchoolFramework == "All" | missing(SchoolFramework)
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
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
// replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL Active or Monitored 1-2 yr" // replaced 
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not EL Active or Monitored 1-2 yr"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Econ Dis"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino of any race"
replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-binary" // updated
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL Active" // updated
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "EL Active or Monitored 1-2 yr"  // updated

// updated
replace StudentSubGroup = "SWD" if StudentSubGroup == "SWD"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not SWD"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "Homeless"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"	
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not Military Connected"
// updated




keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Gender X" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD" | StudentSubGroup == "Homeless" |  StudentSubGroup == "Non-Homeless"| StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"  // updated

//StudentGroup
drop StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X" // updated
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL and Monit or Recently Ex" // updated 
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

// updated
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"
// updated


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
replace Subject = "sci" if strpos(Subject, "Science") !=0

//StudentGroup_TotalTested

foreach n in 1 2 3 4 5 {
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
}

replace StudentSubGroup_TotalTested = string(nLev1_count + nLev2_count + nLev3_count + nLev4_count + nLev5_count) if !missing(nLev1_count) & !missing(nLev2_count) & !missing(nLev3_count) & !missing(nLev4_count) & !missing(nLev5_count) & StudentSubGroup_TotalTested != "*"

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
use "${NCES}/NCES_2021_District"
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
use "${NCES}/NCES_2021_School"
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



//Fixing One Unmerged
replace NCESSchoolID = "110001900779" if StateAssignedSchID == "1292"
replace NCESDistrictID = "1100019" if StateAssignedSchID == "1292"
replace State_leaid = "DC-151" if StateAssignedSchID == "1292"
replace seasch = "151-1292" if StateAssignedSchID == "1292"
replace DistType = "Charter agency" if StateAssignedSchID == "1292"
replace SchType = 1 if StateAssignedSchID == "1292"
replace SchLevel = 2 if StateAssignedSchID == "1292"
replace SchVirtual = 0 if StateAssignedSchID == "1292"
replace DistCharter = "Yes" if StateAssignedSchID == "1292"
replace CountyName = "District of Columbia" if StateAssignedSchID == "1292"
replace CountyCode = "11001" if StateAssignedSchID == "1292"
replace DistLocale = "City, large" if StateAssignedSchID == "1292"
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel == 3
//Generating additional variables
gen State = "District of Columbia"
gen AvgScaleScore = "--"

// gen Flag_AssmtNameChange = "N"
// gen Flag_CutScoreChange_ELA = "N"
// gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_oth = "Y"
// gen Flag_CutScoreChange_read = ""

// updated 
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not Applicable"
// updated 



gen ProficiencyCriteria = "Levels 4-5"
replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
gen AssmtType = "Regular"
gen SchYear = "2022-23"

//ProficientOrAbove_count and Percent
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
// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
//
// keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

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

replace SchVirtual = 0 if NCESSchoolID== "110008700547"

//StudentGroup_TotalTested Convention
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen Suppressed = 0
replace Suppressed = 1 if StudentSubGroup_TotalTested == "*"
egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel NCESSchoolID NCESDistrictID)
drop Suppressed
replace StudentGroup_TotalTested = AllStudents_Tested if StudentGroup_Suppressed == 1 | StudentGroup == "EL Status"
drop AllStudents_Tested StudentGroup_Suppressed

//Deriving Lev*_count
foreach count of varlist Lev*_count {
local percent = subinstr("`count'", "count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if regexm(`count', "[*-]") !=0 & regexm(`percent', "[*-<>=]") == 0 & regexm(StudentSubGroup_TotalTested, "[*-]") == 0 
}

//For consistency with 2019 and 2022, Lev5 count and percent are replaced with missing for now
foreach var of varlist Lev5* {
	replace `var' = "" if Subject == "sci"
}

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${Output}/DC_AssmtData_2023", replace
export delimited "${Output}/DC_AssmtData_2023", replace
clear





