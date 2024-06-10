clear
set more off
global Original "/Volumes/T7/State Test Project/Maryland/Original"
global Output "/Volumes/T7/State Test Project/Maryland/Output"
global NCES_MD "/Volumes/T7/State Test Project/Maryland/NCES"

//Importing & Combining Files
tempfile temp1
save "`temp1'", emptyok
import delimited "${Original}/MD_OriginalData_2019_ela_mat.csv", case(preserve) clear
gen GradeLevel = "G0" + substr(Assessment, -1,1)
drop if real(substr(GradeLevel, -1,1)) > 8 | real(substr(GradeLevel, -1,1)) < 3 | missing(real(substr(GradeLevel, -1,1)))
gen Subject = substr(Assessment, 1, strpos(Assessment, "Grade")-2)
drop Assessment
rename LSSNumber StateAssignedDistID
append using "`temp1'"
save "`temp1'", replace

import delimited "${Original}/MD_OriginalData_2019_sci", case(preserve) clear
rename Grade GradeLevel
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel
rename LSS StateAssignedDistID
rename School SchoolNumber
rename Year AcademicYear
gen Subject = "Science"

append using "`temp1'"
save "`temp1'", replace

** Note: No participation data disaggregated by GradeLevel for this year


//Renaming
rename AcademicYear SchYear
rename LSSName DistName
rename SchoolNumber StateAssignedSchID
rename SchoolName SchName
rename TestedCount StudentSubGroup_TotalTested
forvalues n = 1/5 {
	rename Level`n'Pct Lev`n'_percent
}
rename ProficientPct ProficientOrAbove_percent
rename ProficientCount ProficientOrAbove_count

drop CreateDate

//SchYear
tostring SchYear, replace
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear,-2,2)

//Subject
replace Subject = "sci" if Subject == "Science"
replace Subject = "ela" if Subject == "English/Language Arts"
replace Subject = "math" if Subject == "Mathematics"

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == "A" & StateAssignedSchID == "A"
replace DataLevel = "District" if StateAssignedDistID != "A" & StateAssignedSchID == "A"
replace DataLevel = "School" if StateAssignedDistID != "A" & StateAssignedSchID != "A"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1 | DataLevel == 2
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Cleaning Level Percents
foreach var of varlist *_percent {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i("*%<=>-")
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
drop n`var' range`var'
replace `var' = "*" if `var' == "."
}
//Lev1_percent not included for sci
replace Lev1_percent = "--" if Subject == "sci"

//NCES Merging
gen State_leaid = "MD-" + StateAssignedDistID
gen seasch = StateAssignedDistID + "-" + StateAssignedDistID + StateAssignedSchID
merge m:1 State_leaid using "${NCES_MD}/NCES_2018_District", keep(match master) nogen
merge m:1 seasch using "${NCES_MD}/NCES_2018_School", keep(match master) nogen

//Generating and Deriving Counts and Count Ranges
forvalues n = 1/5 {
	gen Lev`n'_count = "--"
}
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)
foreach count of varlist *_count {
local percent = subinstr("`count'","count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}



//State level data
replace State = "Maryland"
replace StateFips = 24
replace StateAbbrev = "MD"

//Indicator and Missing Variables
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

gen AssmtName = "PARCC" if Subject != "sci"
replace AssmtName = "MISA" if Subject == "sci"

gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 4-5"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MD_AssmtData_2019", replace
export delimited "${Output}/MD_AssmtData_2019", replace



