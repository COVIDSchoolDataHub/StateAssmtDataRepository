
clear
set more off
global Original "/Users/benjaminm/Documents/State_Repository_Research/Maryland/Original"
global Output "/Users/benjaminm/Documents/State_Repository_Research/Maryland/Output"
global NCES_District "/Users/benjaminm/Documents/State_Repository_Research/NCES/District"
global NCES_School "/Users/benjaminm/Documents/State_Repository_Research/NCES/School"

tempfile temp1
save "`temp1'", replace emptyok

//Importing
foreach Subject in ela mat sci {
	foreach dl in State_Level LEA_Level School_Level {
	import excel "${Original}/MD_OriginalData_2024_`Subject'", allstring sheet(`dl') firstrow
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
replace SchYear = "2023-24"
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Multilingual Learner"

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
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" 



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

drop if SchName == "Online Campus Academy" 

replace SchLevel = "Primary" if SchName == "Cabin Branch Elementary" 
replace SchVirtual = "No" if SchName == "Cabin Branch Elementary" 


replace SchLevel = "Other" if SchName == "Colin L Powell Academy" 
replace SchVirtual = "No" if SchName == "Colin L Powell Academy" 

replace SchLevel = "Middle" if SchName == "Non-Traditional Program Middle" 
replace SchVirtual = "No" if SchName == "Non-Traditional Program Middle" 

replace SchLevel = "Middle" if SchName == "Phoenix International School of the Arts" 
replace SchVirtual = "No" if SchName == "Phoenix International School of the Arts" 


replace SchLevel = "Other" if SchName == "Sonia Sotomayor Middle at Adelphi" 
replace SchVirtual = "No" if SchName == "Sonia Sotomayor Middle at Adelphi" 



//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/MD_AssmtData_2024", replace
export delimited "${Output}/MD_AssmtData_2024.csv", replace

tab SchName if SchVirtual == "" & DataLevel == 3





