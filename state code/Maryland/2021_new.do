clear
set more off
local Original "/Volumes/T7/State Test Project/MD R3 Response/Original"
local Output "/Volumes/T7/State Test Project/MD R3 Response/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

tempfile temp1
save "`temp1'", replace emptyok

//Importing
foreach Subject in ela mat sci {
	foreach dl in State_Level LEA_Level School_Level {
	import excel "`Original'/MD_OriginalData_2021_`Subject'", allstring sheet(`dl') firstrow
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
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"

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
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

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

//Merging NCES
gen StateAssignedSchID1 = StateAssignedDistID + StateAssignedSchID
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "`NCES'/NCES_2020_District"
keep if state_location == "MD" | state_name == 24
gen StateAssignedDistID = subinstr(state_leaid, "MD-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge == 1
save "`tempdist'", replace
clear

//School 
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear
use "`NCES'/NCES_2020_School"
keep if state_location == "MD" | state_name == 24
gen StateAssignedSchID1 = substr(seasch, strpos(seasch, "-")+1,10)
merge 1:m StateAssignedSchID1 using "`tempsch'"
drop if _merge == 1
save "`tempsch'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

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
replace StateFips = 24
replace StateAbbrev = "MD"

//Indicator Variables
gen State = "Maryland"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_oth = "Y"
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 2 and 3"
gen AssmtName = ""
replace AssmtName = "MCAP 2021 Early Fall Assessments"
gen AssmtType = "Regular"
foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
	
}
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen Lev4_percent = "--"
gen Lev5_percent = "--"

//Final Cleaning and Exporting
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
duplicates drop
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/MD_AssmtData_2021", replace
export delimited "`Output'/MD_AssmtData_2021.csv", replace
clear





