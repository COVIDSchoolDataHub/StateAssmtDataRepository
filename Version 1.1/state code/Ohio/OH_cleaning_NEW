clear
set more off
// local Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
// local Output "/Volumes/T7/State Test Project/South Dakota/Output"
// local NCES "/Volumes/T7/State Test Project/NCES"

global Original "/Users/benjaminm/Documents/State_Repository_Research/Ohio2024/Original"
global Output "/Users/benjaminm/Documents/State_Repository_Research/Ohio2024/Output"
global NCES_District "/Users/benjaminm/Documents/State_Repository_Research/NCES/District"
global NCES_School "/Users/benjaminm/Documents/State_Repository_Research/NCES/School"
global Stata_versions "/Users/benjaminm/Documents/State_Repository_Research/South Dakota/Stata .dta versions"
global Original1 "/Users/benjaminm/Documents/State_Repository_Research/Ohio2024/Original/Ohio_Original_Files"


//import excel "${Original}/ohio_data_data_request.xlsx", sheet(SCHOOL) firstrow clear
//save "${Original}/OH_OriginalData_School.dta" , replace
use "${Original}/OH_OriginalData_School.dta" , clear

//import excel "${Original}/ohio_data_data_request.xlsx", sheet(DISTRICT) firstrow clear
//save "${Original}/OH_OriginalData_District.dta" , replace
use "${Original}/OH_OriginalData_District.dta" , clear


append using "${Original}/OH_OriginalData_School.dta" 


// variable renaming
rename SCHOOL_YEAR SchYear
rename LEA_IRN StateAssignedDistID
rename LEA_NAME DistName
drop county 
rename stdntgrp StudentSubGroup
rename subjct Subject
rename grdlev GradeLevel
rename req_testers req_testers
rename tested StudentSubGroup_TotalTested
rename limtd Lev1_count
rename basic Lev2_count
rename prfcnt Lev3_count
rename accomp Lev4_count
rename advncd Lev5_count
rename advplus Lev6_count
rename ORG_IRN StateAssignedSchID
rename ORG_NAME SchName 
drop ORG_TYPE  

// datalevel
gen DataLevel = "District"
replace DataLevel = "School" if SchName != ""


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

replace SchName = "All Schools" if DataLevel == 2

// general vars 
gen State = "Ohio"
gen StateAbbrev = "OH"
gen StateFips = 39 
gen ParticipationRate = StudentSubGroup_TotalTested/req_testers
gen AssmtName = "Ohio's State Tests (OST)"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-6"
gen AvgScaleScore = "--"

// subject renaming
replace Subject = "math" if Subject == "M"
replace Subject= "ela" if Subject == "ELA"
replace Subject  = "sci" if Subject == "S"
replace Subject = "soc" if Subject == "C"


// grade level renaming
replace GradeLevel = "G03" if GradeLevel == "03"
replace GradeLevel = "G04" if GradeLevel == "04"
replace GradeLevel = "G05" if GradeLevel == "05"
replace GradeLevel = "G06" if GradeLevel == "06"
replace GradeLevel = "G07" if GradeLevel == "07"
replace GradeLevel = "G08" if GradeLevel == "08"
drop if GradeLevel == "HS"



// student sub group renaming 

replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "I"
replace StudentSubGroup = "Asian" if StudentSubGroup == "A"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "B"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "P"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "M"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "H"
replace StudentSubGroup = "White" if StudentSubGroup == "W"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NEL"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ED"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NED"
replace StudentSubGroup = "Male" if StudentSubGroup == "MAL"
replace StudentSubGroup = "Female" if StudentSubGroup == "FEM"


// student group create 
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"

replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient"

replace StudentGroup = "Gender" if StudentSubGroup == "Male"
replace StudentGroup = "Gender" if StudentSubGroup == "Female"

replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Not Economically Disadvantaged"


// student group total tested 

//gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
//destring StudentGroup_TotalTested, replace force ignore(",")
// replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
// bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested)
// replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
// tostring StudentGroup_TotalTested, replace
// replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
// destring StudentGroup_TotalTested, replace
// destring StudentSubGroup_TotalTested, replace


// * Step 1: Create a variable to store the total number of students tested for "All Students"
// gen all_students_tested = . 
//
// sort GradeLevel Subject DataLevel SchName DistName StudentGroup
// * Step 2: Set this variable for the "All Students" group
// by GradeLevel Subject DataLevel SchName DistName StudentGroup: replace all_students_tested = StudentGroup_TotalTested if StudentSubGroup == "All Students"
//
// * Step 3: Propagate this value to all observations within the same district, grade, and subject
// by GradeLevel Subject DataLevel SchName DistName StudentGroup: replace all_students_tested = all_students_tested[_n-1] if missing(all_students_tested)
//
// * Step 4: Replace the StudentGroup_TotalTested with this propagated value for all groups
// replace StudentGroup_TotalTested = all_students_tested
//
//  //SD reivew added 6/6/24
//  sort GradeLevel Subject DataLevel SchName DistName StudentGroup
// by GradeLevel Subject DataLevel SchName DistName (StudentGroup): gen all_students_tested = StudentGroup_TotalTested if StudentGroup == "All Students"
// by GradeLevel Subject DataLevel SchName DistName: replace all_students_tested = all_students_tested[_n-1] if missing(all_students_tested)
// replace StudentGroup_TotalTested = all_students_tested

save test1, replace 
use test1, clear 

// levels 
local a  "1 2 3 4 5 6" 
foreach b in `a' {	
destring Lev`b'_count, replace ignore("Z")
gen Lev`b'_percent = string(round(Lev`b'_count / StudentSubGroup_TotalTested, .001))
tostring Lev`b'_count, replace 
replace Lev`b'_count = "*" if Lev`b'_count == "."
replace Lev`b'_percent = "*" if Lev`b'_percent == "."

}

destring Lev3_count Lev4_count Lev5_count Lev6_count, replace ignore("*")
gen ProficientOrAbove_count = Lev3_count + Lev4_count + Lev5_count + Lev6_count if Lev3_count != . & Lev4_count != . & Lev5_count != . & Lev6_count != .
gen ProficientOrAbove_percent = string(round(ProficientOrAbove_count / StudentSubGroup_TotalTested, .001))
tostring Lev3_count Lev4_count Lev5_count Lev6_count ProficientOrAbove_count, replace

local a  "3 4 5 6" 
foreach b in `a' {	
replace Lev`b'_count = "*" if Lev`b'_count == "."
}

replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."


tostring SchYear , replace

// flags 
gen Flag_AssmtNameChange = "N"
replace Flag_AssmtNameChange = "Y"  if SchYear == "2016"


gen Flag_CutScoreChange_ELA = "N"
replace Flag_CutScoreChange_ELA = "Y" if SchYear == "2016"

gen Flag_CutScoreChange_math = "N"
replace Flag_CutScoreChange_math = "Y" if SchYear == "2016"

gen Flag_CutScoreChange_sci = "N" 
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2016"

gen Flag_CutScoreChange_soc = "N"
replace Flag_CutScoreChange_soc = "Y" if SchYear == "2016"
replace Flag_CutScoreChange_soc = "Not applicable"  if SchYear == "2018" | SchYear == "2019" | SchYear == "2021" | SchYear == "2022" | SchYear == "2023"

save  "${Output}/OH_AssmtData_Intermediate", replace 


forvalues year = 2016/2023 {
if `year' == 2020 continue


use  "${Output}/OH_AssmtData_Intermediate", clear 

// keeps certain year here
keep if SchYear == "`year'"

local prevyear =`=`year'-1'

replace SchYear = "`prevyear'"+ "-" + substr("`year'",3, 2)

save  "${Output}/OH_AssmtData_Intermediate_`year'", replace 

// use "${NCES_District}/NCES_2015_District", clear


// district nces merging
use "${NCES_District}/NCES_`prevyear'_District"
keep if state_fips_id == 39 | state_name == "Ohio"
rename state_leaid StateAssignedDistID

if year != "2015" {
replace StateAssignedDistID = subinstr(StateAssignedDistID, "OH-","",.)
}

merge 1:m StateAssignedDistID using "${Output}/OH_AssmtData_Intermediate_`year'"
drop if _merge == 1 
drop _merge


save  "${Output}/OH_AssmtData_Intermediate_`year'", replace 

// school nces merging
use "${NCES_School}/NCES_`prevyear'_School"
keep if state_fips_id == 39 | state_name == "Ohio"

rename seasch StateAssignedSchID

drop year 
gen year = "`prevyear'"

if `year' == 2023 { 
decode district_agency_type, generate(district_agency_type1) 
drop district_agency_type
rename district_agency_type1 district_agency_type
drop boundary_change_indicator
drop number_of_schools 
drop fips
}

if year != "2015" {
replace StateAssignedSchID = substr(StateAssignedSchID, strpos(StateAssignedSchID, "-") + 1, .)
}


merge 1:m StateAssignedSchID using  "${Output}/OH_AssmtData_Intermediate_`year'"
drop if _merge == 1 
tab SchName if _merge == 2 & SchName != "All Schools"




rename district_agency_type DistType
if `year' == 2023 { // FIX BACK
 rename school_type SchType
 }
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode

destring NCESDistrictID NCESSchoolID, replace



replace DistName=strtrim(DistName) // adjusted district spacing
replace SchName =strtrim(SchName) // adjusted school spacing

gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
tostring StudentGroup_TotalTested, replace
sort GradeLevel Subject DataLevel SchName DistName StudentGroup
by GradeLevel Subject DataLevel SchName DistName (StudentGroup): gen all_students_tested = StudentGroup_TotalTested if StudentGroup == "All Students"
by GradeLevel Subject DataLevel SchName DistName: replace all_students_tested = all_students_tested[_n-1] if missing(all_students_tested)
replace StudentGroup_TotalTested = all_students_tested
destring StudentGroup_TotalTested, replace


// final cleaning and organizing 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent Lev6_count Lev6_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent Lev6_count Lev6_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/OH_AssmtData_`year'", replace
export delimited "${Output}/OH_AssmtData_`year'", replace

} 


* Load the data
use "${Output}/OH_AssmtData_2021", clear

forvalues year = 2016/2023 {
if `year' == 2020 continue

use  "${Output}/OH_AssmtData_`year'", clear 

keep if DataLevel == 2

destring Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count Lev6_count ProficientOrAbove_count, replace ignore("*")
* Aggregate the data to the state level
collapse (sum) StudentSubGroup_TotalTested Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count Lev6_count ProficientOrAbove_count, by(State StateAbbrev StateFips AssmtName AssmtType AvgScaleScore ProficiencyCriteria Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc SchYear Subject Grade StudentGroup StudentSubGroup)

keep if StudentGroup == "RaceEth" | StudentGroup == "Gender" | StudentGroup == "All Students" 

gen DistName = "All Districts"
gen SchName = "All Schools"
gen NCESDistrictID = .
gen StateAssignedDistID = ""
gen NCESSchoolID = .
gen StateAssignedSchID = ""

gen DataLevel = "State"

encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


local a  "1 2 3 4 5 6" 
foreach b in `a' {	
gen Lev`b'_percent = Lev`b'_count/StudentSubGroup_TotalTested
}



replace ProficientOrAbove_count = Lev3_count + Lev4_count + Lev5_count + Lev6_count
gen ProficientOrAbove_percent = ProficientOrAbove_count/StudentSubGroup_TotalTested
gen ParticipationRate = . 

gen DistType = ""
gen DistCharter = ""
gen DistLocale = ""

gen SchType = . 
gen SchLevel = . 
gen SchVirtual = . 
gen CountyName = ""
gen CountyCode = ""

gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
tostring StudentGroup_TotalTested, replace
sort GradeLevel Subject DataLevel SchName DistName StudentGroup
by GradeLevel Subject DataLevel SchName DistName (StudentGroup): gen all_students_tested = StudentGroup_TotalTested if StudentGroup == "All Students"
by GradeLevel Subject DataLevel SchName DistName: replace all_students_tested = all_students_tested[_n-1] if missing(all_students_tested)
replace StudentGroup_TotalTested = all_students_tested
destring StudentGroup_TotalTested, replace



keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent Lev6_count Lev6_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent Lev6_count Lev6_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// tostring StudentGroup_TotalTested, replace


local a  "1 2 3 4 5 6" 
foreach b in `a' {	
tostring Lev`b'_percent, replace force 
tostring Lev`b'_count, replace force
}

tostring ProficientOrAbove_count, replace force 
tostring ProficientOrAbove_percent, replace force 

append using  "${Output}/OH_AssmtData_`year'"
 

save "${Output}/OH_AssmtData_`year'_x", replace
}





forvalues year = 2016/2023 {
if `year' == 2020 continue
	
//import delimited "${Original1}/OH_AssmtData_`year'", case(preserve) clear  
//save "${Original1}/OH_OG_AssmtData_`year'", replace 
use "${Original1}/OH_OG_AssmtData_`year'", clear 



// import all files, then run 

// use "${Original1}/OH_OG_AssmtData_2016", clear 
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

keep if DataLevel == 1

destring StudentSubGroup_TotalTested ProficientOrAbove_percent, ignore("--") replace
drop ProficientOrAbove_count
gen ProficientOrAbove_count = round(ProficientOrAbove_percent*StudentSubGroup_TotalTested, 1)
tostring ProficientOrAbove_percent ProficientOrAbove_count, replace force 
// replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
 
gen Lev6_count = "--"
gen Lev6_percent = "--"

keep Subject GradeLevel DataLevel Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent Lev6_count Lev6_percent StudentSubGroup_TotalTested ProficientOrAbove_percent ProficientOrAbove_count StudentSubGroup DistName SchName 

merge 1:m DistName SchName Subject GradeLevel DataLevel StudentSubGroup using "${Output}/OH_AssmtData_`year'_x"
drop if _merge == 1

drop StudentGroup_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
tostring StudentGroup_TotalTested, replace
sort GradeLevel Subject DataLevel SchName DistName StudentGroup
by GradeLevel Subject DataLevel SchName DistName (StudentGroup): gen all_students_tested = StudentGroup_TotalTested if StudentGroup == "All Students"
by GradeLevel Subject DataLevel SchName DistName: replace all_students_tested = all_students_tested[_n-1] if missing(all_students_tested)
replace StudentGroup_TotalTested = all_students_tested
destring StudentGroup_TotalTested, replace


tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."


keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent Lev6_count Lev6_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent Lev6_count Lev6_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


save "${Output}/OH_AssmtData_`year'", replace
export delimited "${Output}/OH_AssmtData_`year'", replace

}


