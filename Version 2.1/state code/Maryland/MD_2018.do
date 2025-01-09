
clear
set more off

global Original "/Users/benjaminm/Documents/State_Repository_Research/Maryland/Original"
global Output "/Users/benjaminm/Documents/State_Repository_Research/Maryland/Output"
global NCES_MD "/Users/benjaminm/Documents/State_Repository_Research/Maryland/NCES_MD"

//Importing & Combining Files
tempfile temp1
save "`temp1'", emptyok
import delimited "$Original/MD_OriginalData_2018_ela_mat.csv", case(preserve) clear
gen GradeLevel = "G0" + substr(Assessment, -1,1)
drop if real(substr(GradeLevel, -1,1)) > 8 | real(substr(GradeLevel, -1,1)) < 3 | missing(real(substr(GradeLevel, -1,1)))
gen Subject = substr(Assessment, 1, strpos(Assessment, "Grade")-2)
drop Assessment
rename LSSNumber StateAssignedDistID
append using "`temp1'"
save "`temp1'", replace

import delimited "${Original}/MD_OriginalData_2018_sci", case(preserve) clear
rename Grade GradeLevel
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel
rename LSSNumber StateAssignedDistID
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
merge m:1 State_leaid using "${NCES_MD}/NCES_2017_District", keep(match master) nogen
merge m:1 seasch using "${NCES_MD}/NCES_2017_School", keep(match master) nogen

//Generating and Deriving Counts and Count Ranges
forvalues n = 1/5 {
	gen Lev`n'_count = "--"
}



foreach count of varlist Lev*_count {
	local percent = subinstr("`count'","count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

foreach count of varlist ProficientOrAbove_count {
replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}


** Dealing with Ranges
foreach var of varlist Lev*_percent {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var',strpos(`var', "-")+1,5)
	replace low`var' = high`var' if missing(low`var') & !missing(high`var')
	replace high`var' = low`var' if missing(high`var') & !missing(low`var')
}

//Deriving Counts with Ranges
foreach count of varlist *_count {
local percent = subinstr("`count'", "count","percent",.)	
replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

replace ProficientOrAbove_percent = string(real(lowLev4_percent) + real(lowLev5_percent)) + "-" + string(real(highLev4_percent) + real(highLev5_percent)) if strpos(Lev4_percent, "-") !=0 & regexm(Lev4_percent, "[0-9]") !=0 & Subject != "sci" | (strpos(Lev5_percent, "-") !=0 & regexm(Lev5_percent, "[0-9]") !=0) & Subject != "sci"
replace ProficientOrAbove_percent = string(real(lowLev4_percent) + real(lowLev5_percent)) + "-" + string(real(highLev4_percent) + real(highLev5_percent)) if strpos(Lev4_percent, "-") !=0 & regexm(Lev4_percent, "[0-9]") !=0 & Subject == "sci" | (strpos(Lev5_percent, "-") !=0 & regexm(Lev5_percent, "[0-9]") !=0) & Subject == "sci"
drop low* high*


** Dealing with Ranges
foreach var of varlist Lev*_count {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var',strpos(`var', "-")+1,5)
	replace low`var' = high`var' if missing(low`var') & !missing(high`var')
	replace high`var' = low`var' if missing(high`var') & !missing(low`var')
}


replace ProficientOrAbove_count = string(real(lowLev4_count) + real(lowLev5_count)) + "-" + string(real(highLev4_count) + real(highLev5_count)) if strpos(Lev4_count, "-") !=0 & regexm(Lev4_count, "[0-9]") !=0 & Subject != "sci" | (strpos(Lev5_count, "-") !=0 & regexm(Lev5_count, "[0-9]") !=0) & Subject != "sci"

replace ProficientOrAbove_count = string(real(lowLev4_count) + real(lowLev5_count)) + "-" + string(real(highLev4_count) + real(highLev5_count)) if strpos(Lev4_count, "-") !=0 & regexm(Lev4_count, "[0-9]") !=0 & Subject == "sci" | (strpos(Lev5_count, "-") !=0 & regexm(Lev5_count, "[0-9]") !=0) & Subject == "sci"
drop low* high*



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
replace Flag_AssmtNameChange = "Y" if Subject == "sci"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = "Not applicable"

gen AvgScaleScore = "--"

gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 4-5"

//Post Launch Review
replace SchName=stritrim(SchName)
replace CountyName= "Baltimore City" if CountyCode == "24510"

replace DistName = "SEED School Of Maryland" if NCESDistrictID == "2400027"


// Replace Lev3_count with the difference between ProficientOrAbove_Count and Lev2_count

destring ProficientOrAbove_count, gen(ProficientOrAbove_count1) force 
destring Lev4_count, gen(Lev4_count1) force 

gen Lev5_count1 = string(ProficientOrAbove_count1 - Lev4_count1) if !missing(Lev4_count) &  strpos(Lev5_count, "-") > 0 & !missing(ProficientOrAbove_count)
replace Lev5_count = Lev5_count1 if Lev5_count1 != "" & Lev5_count1 != "."

destring Lev5_count, gen(Lev5_count2) force 

gen Lev4_count2 = string(ProficientOrAbove_count1 - Lev5_count2) if !missing(Lev5_count) &  strpos(Lev4_count, "-") > 0 & !missing(ProficientOrAbove_count)
replace Lev4_count = Lev4_count2 if Lev4_count2 != "" & Lev4_count2 != "."

//Derive Exact count/percent where we have range and corresponding exact count/percent and StudentSubGroup_TotalTested
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`percent'))
	replace `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}


// deriving proficient_or above count
gen ProficientOrAbove_count2 = string(Lev4_count1 + Lev5_count2) if !missing(Lev4_count) & !missing(Lev5_count) 
replace ProficientOrAbove_count = ProficientOrAbove_count2 if ProficientOrAbove_count2 != "" & ProficientOrAbove_count2 != "." 

destring Lev4_percent, gen(Lev4_percent1) force 
destring Lev5_percent, gen(Lev5_percent2) force

// deriving proficient_or above count
gen ProficientOrAbove_percent2 = string(Lev4_percent1 + Lev5_percent2) if !missing(Lev4_percent) & !missing(Lev5_percent)
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "" & ProficientOrAbove_percent2 != "." 

local a  1 2 3 4

foreach b in `a' {
	local d = `b' + 1
	display `d'
replace Lev`b'_count = Lev`d'_count if Subject == "sci"
replace Lev`b'_percent = Lev`d'_percent if Subject == "sci"

}

replace Lev5_count = "" if Subject == "sci"
replace Lev5_percent = "" if Subject == "sci"

replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"

** Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficiencyCriteria == "Levels 3-4"
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*" & ProficiencyCriteria == "Levels 3-4"
replace ProficientOrAbove_percent = string(real(Lev4_percent) + real(Lev5_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & Lev4_percent != "*" & Lev5_percent == "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_count = string(real(Lev4_count) + real(Lev5_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev5_count, "-") == 0 & Lev4_count != "*" & Lev5_count == "*" & ProficiencyCriteria == "Levels 4-5"

replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & Lev1_percent != "*" & Lev2_percent != "*" & ProficiencyCriteria == "Levels 3-4"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*" & ProficiencyCriteria == "Levels 3-4"
replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent) - real(Lev3_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") ==0 & Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & ProficiencyCriteria == "Levels 4-5"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") > 0
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

replace Lev5_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if strpos(Lev5_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if strpos(Lev5_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if strpos(Lev5_percent, "e") > 0
replace Lev5_percent = "0" if Lev5_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev5_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if strpos(Lev5_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_count = "0" if strpos(Lev5_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev5_percent = "0" if Lev5_count == "0"
replace Lev5_count = "0" if Lev5_percent == "0"
replace Lev5_count = "0" if Lev5_count == "--" & ProficientOrAbove_count == "0"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if (strpos(Lev4_percent, "-") > 0 | Lev4_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev4_percent = "0" if (strpos(Lev4_percent, "-") > 0 | Lev4_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev5_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev5_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if strpos(Lev4_percent, "-") > 0 & strpos(Lev5_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev5_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev5_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0
replace Lev4_percent = "0" if Lev4_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev4_count = "0" if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev5_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev5_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_count = "0" if strpos(Lev4_count, "-") > 0 & strpos(Lev5_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev5_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev5_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev4_percent = "0" if Lev4_count == "0"
replace Lev4_count = "0" if Lev4_percent == "0"
replace Lev4_count = "0" if Lev4_count == "--" & ProficientOrAbove_count == "0"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev3_percent = "0" if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev3_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev2_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev1_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev1_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0
replace Lev3_percent = "0" if Lev3_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev3_count = "0" if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev3_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev2_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_count = "0" if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev2_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev2_count) - real(Lev1_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev3_percent = "0" if Lev3_count == "0"
replace Lev3_count = "0" if Lev3_percent == "0"
replace Lev3_count = "0" if Lev3_count == "--" & ProficientOrAbove_percent == "0"

replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent)) if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev2_percent = "0" if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev3_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev1_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev2_count = "0" if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count)) if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_count = "0" if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev1_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev1_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev2_percent = "0" if Lev2_count == "0"
replace Lev2_count = "0" if Lev2_percent == "0"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent)) if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev1_percent = "0" if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev3_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) - real(Lev3_percent) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if strpos(Lev1_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) >= 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev1_count = "0" if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) < 0 & ProficiencyCriteria == "Levels 3-4"
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count)) if strpos(Lev1_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev2_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) >= 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_count = "0" if strpos(Lev1_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & Lev3_count != "*" & Lev2_count != "*" & ProficientOrAbove_count != "*" & StudentSubGroup_TotalTested != "*" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) < 0 & ProficiencyCriteria == "Levels 4-5"
replace Lev1_percent = "0" if Lev1_count == "0"
replace Lev1_count = "0" if Lev1_percent == "0"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MD_AssmtData_2018", replace
export delimited "${Output}/MD_AssmtData_2018", replace



