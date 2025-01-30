clear
set more off
set trace off
global Original "/Users/miramehta/Documents/Hawaii/Original"
global Cleaned "/Users/miramehta/Documents/Hawaii/Output"

//Import Sci State Level Data
import excel "$Original/HI_OriginalData_2024_sci", clear sheet("STATE") cellrange(A6)
rename A GradeLevel
rename B StudentSubGroup_TotalTested
rename C ProficientOrAbove_count
rename D ProficientOrAbove_percent

drop if _n < 3

gen DataLevel = "State"
gen Subject = "sci"

save "$Original/HI_Original_State_sci", replace

//Import Sci School Level Data
import excel "$Original/HI_OriginalData_2024_sci", clear sheet("SCHOOLS") cellrange(C7)
rename C StateAssignedSchID
rename D SchName
rename E GradeLevel
rename F StudentSubGroup_TotalTested
rename G ProficientOrAbove_percent

drop if _n == 1

replace StateAssignedSchID = StateAssignedSchID[_n-1] if StateAssignedSchID == ""
replace SchName = SchName[_n-1] if SchName == ""

gen DataLevel = "School"
gen Subject = "sci"

save "$Original/HI_Original_School_sci", replace

//Import ELA/Math State Level Data
import excel "$Original/HI_OriginalData_2024_ela_mat", clear sheet("STATE") cellrange(A6)
rename A GradeLevel
rename B StudentSubGroup_TotalTestedela
rename C ProficientOrAbove_countela
rename D ProficientOrAbove_percentela
rename E StudentSubGroup_TotalTestedmath
rename F ProficientOrAbove_countmath
rename G ProficientOrAbove_percentmath

drop if _n < 3

gen DataLevel = "State"

save "$Original/HI_Original_State", replace

//Import ELA/Math School Level Data
import excel "$Original/HI_OriginalData_2024_ela_mat", clear sheet("SCHOOLS") cellrange(C7)
rename C StateAssignedSchID
rename D SchName
rename E GradeLevel
rename F StudentSubGroup_TotalTestedela
rename G ProficientOrAbove_percentela
rename H StudentSubGroup_TotalTestedmath
rename I ProficientOrAbove_percentmath

drop if _n == 1

replace StateAssignedSchID = StateAssignedSchID[_n-1] if StateAssignedSchID == ""
replace SchName = SchName[_n-1] if SchName == ""

gen DataLevel = "School"

append using "$Original/HI_Original_State"

drop if GradeLevel == ""
reshape long StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedSchID GradeLevel) j(Subject) string

append using "$Original/HI_Original_State_sci" "$Original/HI_Original_School_sci"

replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0", 1)
drop if inlist(GradeLevel, "G011", "All Grades", "High School", "")

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Performance Information
forvalues n = 1/4{
	gen Lev`n'_count = "--"
	gen Lev`n'_percent = "--"
}

replace ProficientOrAbove_count = string(round(real(StudentSubGroup_TotalTested) * real(ProficientOrAbove_percent))) if ProficientOrAbove_count == "" & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "" & ProficientOrAbove_percent == "*"

replace ProficientOrAbove_percent = substr(ProficientOrAbove_percent, 1, 4)

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

//Assessment Information
gen SchYear = "2023-24"
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "Hawaii Science Assessment - NGSS" if Subject == "sci"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel

**Creating District Level Observations as Duplicates of State Level Observations
expand 2 if DataLevel == 1, gen(Dist)
replace DataLevel = 2 if Dist == 1
gen state_leaid = "HI-001" if DataLevel !=1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedSchID = "" if DataLevel !=3
sort DataLevel
drop Dist

//Merging with NCES
tempfile temp1
save "`temp1'", replace
clear

//District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "$NCES/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District"
keep if state_name == "Hawaii"
replace state_leaid = "HI-001"
keep ncesdistrictid state_leaid lea_name district_agency_type DistCharter DistLocale county_code county_name
merge 1:m state_leaid using "`tempdist'", keep(match using) nogen
save "`tempdist'", replace
clear

//Schools
use "`temp1'"
keep if DataLevel == 3
gen seasch = StateAssignedSchID
tempfile tempsch
save "`tempsch'", replace
use "$NCES/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School"
keep if state_name == "Hawaii"
replace state_leaid = "HI-001"
keep ncesdistrictid state_leaid lea_name district_agency_type DistCharter DistLocale county_code county_name ncesschoolid SchLevel SchVirtual school_type seasch 
rename school_type SchType
foreach var of varlist district_agency_type SchType SchVirtual SchLevel {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
}

replace seasch = substr(seasch,3,4)
merge 1:m seasch using "`tempsch'", keep(match using) nogen
save "`tempsch'", replace
clear

use "`temp1'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"

//NCES Variables
gen State = "Hawaii"
gen StateAbbrev = "HI"
gen StateFips = 15
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
rename lea_name DistName
rename state_leaid StateAssignedDistID
rename district_agency_type DistType
drop seasch

replace DistName = "All Districts" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1
replace SchName = "Maemae Elementary School" if StateAssignedSchID == "136" //imported incorrectly; updating to match previous years

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Cleaned}/HI_AssmtData_2024", replace
export delimited "${Cleaned}/HI_AssmtData_2024", replace


