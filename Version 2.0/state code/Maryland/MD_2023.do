

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
	import excel "${Original}/MD_OriginalData_2023_`Subject'", allstring sheet(`dl') firstrow
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
replace SchYear = "2022-23"
rename LEA StateAssignedDistID
rename LEAName DistName
rename School StateAssignedSchID
rename SchoolName SchName
rename Assessment GradeLevel
rename StudentGroup StudentSubGroup
rename TestedCount StudentSubGroup_TotalTested
rename ProficientCount ProficientOrAbove_count
rename ProficientPct ProficientOrAbove_percent
foreach n in 1 2 3 4 {
	rename Level`n'Pct Lev`n'_percent
}
drop CreateDate

//GradeLevel
replace GradeLevel = "38" if strpos(GradeLevel, "3-8") !=0
drop if strpos(GradeLevel, "3-5") !=0 | strpos(GradeLevel, "6-8") !=0
replace GradeLevel = "G0" + substr(GradeLevel,-1,1) if GradeLevel != "38"
replace GradeLevel = "G38" if GradeLevel == "38"
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08", "G38")

//StudentSubGroup
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Latino") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-economically Disadvantaged"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black/African American"
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
merge m:1 State_leaid using "${NCES_MD}/NCES_2022_District", keep(match master) nogen
merge m:1 seasch using "${NCES_MD}/NCES_2022_School", keep(match master) nogen


/*
//Fixing Unmerged
replace NCESSchoolID = "240048090484" if SchName == "Harriet R. Tubman Elementary"
replace NCESDistrictID = "2400480" if SchName == "Harriet R. Tubman Elementary"
replace DistCharter = "No" if SchName == "Harriet R. Tubman Elementary"
replace SchType = 1 if SchName == "Harriet R. Tubman Elementary"
replace DistType = 1 if SchName == "Harriet R. Tubman Elementary"
replace State_leaid = "MD-15" if SchName == "Harriet R. Tubman Elementary"
replace seasch = "15-150580" if SchName == "Harriet R. Tubman Elementary"
replace SchLevel = 1 if SchName == "Harriet R. Tubman Elementary"
replace SchVirtual = 0 if SchName == "Harriet R. Tubman Elementary"
replace CountyName = "Montgomery County" if SchName == "Harriet R. Tubman Elementary"
replace CountyCode = 24031 if SchName == "Harriet R. Tubman Elementary"

replace NCESSchoolID = "240012090482" if SchName == "Rossville Elementary"
replace NCESDistrictID = "2400120" if SchName == "Rossville Elementary"
replace DistCharter = "No" if SchName == "Rossville Elementary"
replace SchType = 1 if SchName == "Rossville Elementary"
replace DistType = 1 if SchName == "Rossville Elementary"
replace State_leaid = "MD-03" if SchName == "Rossville Elementary"
replace seasch = "03-031407" if SchName == "Rossville Elementary"
replace SchLevel = 1 if SchName == "Rossville Elementary"
replace SchVirtual = 0 if SchName == "Rossville Elementary"
replace CountyName = "Baltimore County" if SchName == "Rossville Elementary"
replace CountyCode = 24005 if SchName == "Rossville Elementary"
*/

//State level data
replace State = "Maryland"
replace StateFips = 24
replace StateAbbrev = "MD"


** Dropping Virtual Academy ES and MS for now **
drop if SchName == "Virtual Academy ES"
drop if SchName == "Virtual Academy MS"

//Indicator Variables
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtName = ""
replace AssmtName = "MCAP" if Subject != "sci"
replace AssmtName = "MISA" if Subject == "sci"
gen AssmtType = "Regular"
foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
	
}
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen Lev5_percent = "--"

//Deriving Counts and Count Ranges
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)
foreach count of varlist *_count {
local percent = subinstr("`count'","count", "percent",.)
replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
replace `count' = string(round(real(substr(`percent', 1, strpos(`percent', "-")-1))*real(StudentSubGroup_TotalTested))) + "-" + string(round(real(substr(`percent',strpos(`percent', "-")+1,5))*real(StudentSubGroup_TotalTested))) if missing(real(`count')) & strpos(`percent', "-") !=0 & regexm(`percent', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0
}

//Post Launch Review
replace CountyName= "Baltimore City" if CountyCode == "24510"


replace DistName = "SEED School Of Maryland" if NCESDistrictID == "2400027"

// Replace Lev4_count with the difference between ProficientOrAbove_Count and Lev3_count
destring ProficientOrAbove_count, gen(ProficientOrAbove_count1) force 
destring Lev3_count, gen(Lev3_count1) force 

gen Lev4_count1 = string(ProficientOrAbove_count1 - Lev3_count1) if !missing(Lev3_count) &  strpos(Lev4_count, "-") > 0 & !missing(ProficientOrAbove_count)
replace Lev4_count = Lev4_count1 if Lev4_count1 != "" & Lev4_count1 != "."


destring Lev4_count, gen(Lev4_count2) force 

gen Lev3_count2 = string(ProficientOrAbove_count1 - Lev4_count2) if !missing(Lev4_count) &  strpos(Lev3_count, "-") > 0 & !missing(ProficientOrAbove_count)
replace Lev3_count = Lev3_count2 if Lev3_count2 != "" & Lev3_count2 != "."

//Derive Exact count/percent where we have range and corresponding exact count/percent and StudentSubGroup_TotalTested
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`percent'))
	replace `count' = string(round(real(`percent')* real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

// deriving proficient_or above count
gen ProficientOrAbove_count2 = string(Lev3_count1 + Lev4_count2) if !missing(Lev3_count) & !missing(Lev4_count) 
replace ProficientOrAbove_count = ProficientOrAbove_count2 if ProficientOrAbove_count2 != "" & ProficientOrAbove_count2 != "." 


destring Lev3_percent, gen(Lev3_percent1) force 
destring Lev4_percent, gen(Lev4_percent2) force

// deriving proficient_or above count
gen ProficientOrAbove_percent2 = string(Lev3_percent1 + Lev4_percent2) if !missing(Lev3_percent) & !missing(Lev4_percent)
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "" & ProficientOrAbove_percent2 != "." 

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MD_AssmtData_2023", replace
export delimited "${Output}/MD_AssmtData_2023.csv", replace






