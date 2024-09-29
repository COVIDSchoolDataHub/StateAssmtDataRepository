
clear
set more off
global Original "/Users/benjaminm/Documents/State_Repository_Research/Maryland/Original"
global Output "/Users/benjaminm/Documents/State_Repository_Research/Maryland/Output"
global NCES_MD "/Users/benjaminm/Documents/State_Repository_Research/Maryland/NCES_MD"


tempfile temp1
save "`temp1'", replace emptyok

//Importing
foreach Subject in ela mat sci {
	foreach dl in State_Level LEA_Level School_Level {
	import excel "${Original}/MD_OriginalData_2021_`Subject'", allstring sheet(`dl') firstrow
	gen DataLevel = "`dl'"
	gen Subject = "`Subject'"
	append using "`temp1'"
	save "`temp1'", replace
	clear
	
	}
}
use "`temp1'"

//Renaming
rename Year SchYear
replace SchYear = "2020-21"
rename LEA StateAssignedDistID
rename LEAName DistName
rename School StateAssignedSchID
rename SchoolName SchName
rename Assessment GradeLevel
rename Studentgroup StudentSubGroup
rename TestedCount StudentSubGroup_TotalTested
rename ProficientCount ProficientOrAbove_count
rename ProficientPct ProficientOrAbove_percent
foreach n in 1 2 3 {
	rename Level`n'Pct Lev`n'_percent
}
drop CreateDate

//GradeLevel
replace GradeLevel = "G0" + substr(GradeLevel,-1,1)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Latino") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-economically Disadvantaged"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"
** Extra Subgroups:
drop if StudentSubGroup == "ADA/504" //Using Students with Disabilities
drop if StudentSubGroup == "FARMS" //I don't know what this is
drop if StudentSubGroup == "Title I" //Using Economically Disadvantaged

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//DataLevel
replace DataLevel = "State" if strpos(DataLevel, "State") !=0
replace DataLevel = "District" if strpos(DataLevel, "LEA") !=0
replace DataLevel = "School" if strpos(DataLevel, "School") !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

//Subject
replace Subject = "math" if Subject == "mat"

//StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Proficiency Levels
foreach var of varlist Lev* ProficientOrAbove_percent {
replace `var' = subinstr(`var'," ", "",.)
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i("*%<>=-")
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}

//NCES Merging
gen State_leaid = "MD-" + StateAssignedDistID
gen seasch = StateAssignedDistID + "-" + StateAssignedDistID + StateAssignedSchID
merge m:1 State_leaid using "${NCES_MD}/NCES_2020_District", keep(match master) nogen
merge m:1 seasch using "${NCES_MD}/NCES_2020_School", keep(match master) nogen

//State level data
replace State = "Maryland"
replace StateFips = 24
replace StateAbbrev = "MD"

//Indicator Variables
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 2-3"
gen AssmtName = ""
replace AssmtName = "MCAP Early Fall 2021 Assessment" if Subject != "sci"
replace AssmtName = "MISA Early Fall 2021 Assessment" if Subject == "sci"

gen AssmtType = "Regular"
foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
	
}
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen Lev4_percent = "--"
gen Lev5_percent = "--"

//Deriving Counts and Count Ranges
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)
foreach count of varlist *_count {
local percent = subinstr("`count'","count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

//ProficientOrAbove_count and ProficientOrAbove_percent
replace ProficientOrAbove_percent = string(real(Lev2_percent)+real(Lev3_percent)) if !missing(real(Lev2_percent)) & !missing(real(Lev3_percent)) 
replace ProficientOrAbove_count = string(real(Lev2_count)+real(Lev3_count)) if !missing(real(Lev2_count)) & !missing(real(Lev3_count)) 

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

replace ProficientOrAbove_percent = string(real(lowLev2_percent) + real(lowLev3_percent)) + "-" + string(real(highLev2_percent) + real(highLev3_percent)) if strpos(Lev2_percent, "-") !=0 & regexm(Lev2_percent, "[0-9]") !=0 | (strpos(Lev3_percent, "-") !=0 & regexm(Lev3_percent, "[0-9]") !=0)
drop low* high*

** Dealing with Ranges
foreach var of varlist Lev*_count {
	gen low`var' = substr(`var', 1, strpos(`var', "-")-1)
	gen high`var' = substr(`var',strpos(`var', "-")+1,5)
	replace low`var' = high`var' if missing(low`var') & !missing(high`var')
	replace high`var' = low`var' if missing(high`var') & !missing(low`var')
}


replace ProficientOrAbove_count = string(real(lowLev2_count) + real(lowLev3_count)) + "-" + string(real(highLev2_count) + real(highLev3_count)) if strpos(Lev2_count, "-") !=0 & regexm(Lev2_count, "[0-9]") !=0 | (strpos(Lev3_count, "-") !=0 & regexm(Lev3_count, "[0-9]") !=0)
drop low* high*

replace ProficientOrAbove_count = "--" if Lev2_count == "--" & Lev3_count == "--" 

//Post Launch Review
replace CountyName= "Baltimore City" if CountyCode == "24510"

replace DistName = "SEED School Of Maryland" if NCESDistrictID == "2400027"


// Replace Lev3_count with the difference between ProficientOrAbove_Count and Lev2_count

destring ProficientOrAbove_count, gen(ProficientOrAbove_count1) force 
destring Lev2_count, gen(Lev2_count1) force 

gen Lev3_count1 = string(ProficientOrAbove_count1 - Lev2_count1) if !missing(Lev2_count) &  strpos(Lev3_count, "-") > 0 & !missing(ProficientOrAbove_count)
replace Lev3_count = Lev3_count1 if Lev3_count1 != "" & Lev3_count1 != "."

destring Lev3_count, gen(Lev3_count2) force 

gen Lev2_count2 = string(ProficientOrAbove_count1 - Lev3_count2) if !missing(Lev3_count) &  strpos(Lev2_count, "-") > 0 & !missing(ProficientOrAbove_count)
replace Lev2_count = Lev2_count2 if Lev2_count2 != "" & Lev2_count2 != "."

//Derive Exact count/percent where we have range and corresponding exact count/percent and StudentSubGroup_TotalTested
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`percent'))
	replace `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

// deriving proficient_or above count
gen ProficientOrAbove_count2 = string(Lev2_count1 + Lev3_count2) if !missing(Lev2_count) & !missing(Lev3_count) 
replace ProficientOrAbove_count = ProficientOrAbove_count2 if ProficientOrAbove_count2 != "" & ProficientOrAbove_count2 != "." 



destring Lev2_percent, gen(Lev2_percent1) force 
destring Lev3_percent, gen(Lev3_percent2) force

// deriving proficient_or above count
gen ProficientOrAbove_percent2 = string(Lev2_percent1 + Lev3_percent2) if !missing(Lev2_percent) & !missing(Lev3_percent)
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "" & ProficientOrAbove_percent2 != "." 


local a  4 5

foreach b in `a' {

replace Lev`b'_count = ""
replace Lev`b'_percent = ""

}


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MD_AssmtData_2021", replace
export delimited "${Output}/MD_AssmtData_2021.csv", replace





