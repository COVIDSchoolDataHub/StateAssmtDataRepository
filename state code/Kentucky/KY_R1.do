clear
set more off

**Note: This code should be run last

cd "/Volumes/T7/State Test Project/KY R1 (In depth)"
local Output "/Volumes/T7/State Test Project/KY R1 (In depth)/Output"
local NCES "/Volumes/T7/State Test Project/NCES"

forvalues year = 2012/2022 {
if `year' == 2020 continue
local prevyear =`=`year'-1'
use "`Output'/KY_AssmtData_`year'", clear
//Generating missing Variables
foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen ParticipationRate = "--"
gen ProficientOrAbove_count = "--"
gen AvgScaleScore = "--"



//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel != 3
drop if SchName == "---COOP Total---"
**Remerging NCES**
cap drop DistType
cap drop SchType
cap drop NCESDistrictID
cap drop State_leaid
cap drop NCESSchoolID
cap drop seasch
cap drop DistCharter
cap drop SchLevel
cap drop SchVirtual
cap drop CountyName
cap drop CountyCode
cap drop StateAbbrev
cap drop StateFips


//Fixing StateAssignedDistID and StateAssignedSchID
tostring StateAssignedDistID StateAssignedSchID, replace
replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 1
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) == 1
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 2
replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3


//Merging
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist 
save "`tempdist'", replace
clear
use "`NCES'/NCES_`prevyear'_District"
keep if state_location == "KY" | state_name == 21
gen StateAssignedDistID = subinstr(state_leaid, "KY-","",.)
replace StateAssignedDistID = substr(StateAssignedDistID, 4,3)
duplicates drop StateAssignedDistID, force
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
use "`NCES'/NCES_`prevyear'_School"
keep if state_location == "KY" | state_name == 21
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,10)
replace StateAssignedSchID = substr(StateAssignedSchID, 4,6)
duplicates drop StateAssignedSchID, force
merge 1:m StateAssignedSchID using "`tempsch'"
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
replace StateFips = 21
replace StateAbbrev = "KY"



//Converting Proficiency Levels to decimal
foreach n in 1 2 3 4 {
	rename Lev`n'_percent nLev`n'_percent
	destring nLev`n'_percent, replace i(*)
	gen Lev`n'_percent = ""
}
rename ProficientOrAbove_percent nProficientOrAbove_percent
gen ProficientOrAbove_percent = ""

foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	replace `var' = string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
	replace `var' = "*" if `var' == "."
}

//GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Regular
replace AssmtType = "Regular"









gen Lev5_count = "--"
gen Lev5_percent = "--"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/KY_AssmtData_`year'", replace
export delimited "`Output'/KY_AssmtData_`year'", replace
clear

}





