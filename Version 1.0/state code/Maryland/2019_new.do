clear
set more off
local Original "/Volumes/T7/State Test Project/MD R3 Response/Original"
local Output "/Volumes/T7/State Test Project/MD R3 Response/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

tempfile temp1
save "`temp1'", replace emptyok

//Importing and Appending
import delimited "`Original'/MD_OriginalData_2019_ela_mat.csv", case(preserve)
gen GradeLevel = real(substr(Assessment, -1,1))
append using "`temp1'"
save "`temp1'", replace
clear
import delimited "`Original'/MD_OriginalData_2019_sci_gr5_gr8", case(preserve)
rename Year AcademicYear
rename School SchoolNumber
rename LSS LSSNumber
rename Grade GradeLevel
gen Assessment = "sci"

append using "`temp1'"

//Lev1Pct
replace Level1Pct = "--" if missing(Level1Pct)

//Renaming Variables
drop AcademicYear
gen SchYear = "2018-19"
rename LSSNumber StateAssignedDistID
rename LSSName DistName
rename SchoolNumber StateAssignedSchID
rename SchoolName SchName
rename TestedCount StudentSubGroup_TotalTested
rename ProficientCount ProficientOrAbove_count
rename ProficientPct ProficientOrAbove_percent
foreach n in 1 2 3 4 5 {
	rename Level`n'Pct Lev`n'_percent
}
rename Assessment Subject
drop CreateDate

//Subject
replace Subject = "ela" if strpos(Subject, "English") !=0
replace Subject = "math" if strpos(Subject, "Math") !=0
keep if inlist(Subject, "math", "ela", "sci", "soc", "wri")

//GradeLevel
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//ProficientOrAbove_count
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if StateAssignedDistID == "A"
replace DataLevel = "District" if StateAssignedSchID == "A" & StateAssignedDistID != "A"
replace DataLevel = "School" if StateAssignedSchID != "A" & StateAssignedDistID != "A"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

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
use "`NCES'/NCES_2018_District"
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
use "`NCES'/NCES_2018_School"
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
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_oth = "N"
gen Flag_CutScoreChange_read = ""
gen ProficiencyCriteria = "Levels 4 and 5"
gen AssmtName = ""
replace AssmtName = "MISA" if Subject == "sci"
replace AssmtName = "PARCC" if Subject != "sci"
gen AssmtType = "Regular"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested
foreach n in 1 2 3 4 5 {
	gen Lev`n'_count = "--"
	
}
gen AvgScaleScore = "--"
gen ParticipationRate = "--"


//Final Cleaning and Exporting
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
duplicates drop
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/MD_AssmtData_2019", replace
export delimited "`Output'/MD_AssmtData_2019.csv", replace
clear






