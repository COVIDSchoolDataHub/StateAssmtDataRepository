
//Name: North Carolina 2024 State Assessment
//purpose: Cleaning NC State Assessment Data
//author: Mikael Oberlin
//date created: 10/01/24


clear all 
set more off

global Abbrev "NC"

global data "/Users/miramehta/Documents/NC State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//2023-2024
import delimited "$data/Disag_2023-24_Data.txt", clear
save "$data/NC_OriginalData_2024.csv", replace
export delimited "$data/NC_OriginalData_2024.csv", replace
save "$data/NC_OriginalData_2024.dta", replace
use "$data/NC_OriginalData_2024", clear 

rename school_code StateAssignedSchID 
rename name SchName
rename subject Subject
rename grade GradeLevel
rename type AssmtType
rename subgroup StudentSubGroup
rename num_tested StudentSubGroup_TotalTested	
rename pct_notprof Lev1_percent
rename pct_l3 Lev2_percent
rename pct_l4 Lev3_percent
rename pct_l5 Lev4_percent
rename pct_glp ProficientOrAbove_percent
rename avg_score AvgScaleScore
drop pct_ccr grade_span

gen State = "North Carolina"
gen StateAbbrev = "NC"
gen StateFips = 37 
gen Lev5_count = ""
gen Lev5_percent = ""
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
gen Flag_CutScoreChange_soc = "Not applicable"

gen SchYear = "2023-24"

gen AssmtName = "End-of-Grade Tests - Edition 5" 

// keeping necessary grades 
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == "03"
replace GradeLevel2 = "G04" if GradeLevel == "04"
replace GradeLevel2 = "G05" if GradeLevel == "05"
replace GradeLevel2 = "G06" if GradeLevel == "06"
replace GradeLevel2 = "G07" if GradeLevel == "07"
replace GradeLevel2 = "G08" if GradeLevel == "08"
replace GradeLevel2 = "G38" if GradeLevel == "GS"

drop if GradeLevel2 == ""
drop GradeLevel
rename GradeLevel2 GradeLevel

// keeping necessary test types
keep if AssmtType == "RG"
replace AssmtType = "Regular" if AssmtType == "RG"

// keeping necessary subjects 
gen Subject2 = ""
replace Subject2 = "math" if Subject == "MA"
replace Subject2 = "ela" if Subject == "RD"
replace Subject2 = "sci" if Subject == "SC"
drop if Subject2 == ""
drop Subject
rename Subject2 Subject

// keeping necessary subroups 

gen StudentSubGroup2 = ""
replace StudentSubGroup2 = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup2 = "American Indian or Alaska Native" if StudentSubGroup == "AMIN"
replace StudentSubGroup2 = "Asian" if StudentSubGroup == "ASIA"
replace StudentSubGroup2 = "Black or African American" if StudentSubGroup == "BLCK"
replace StudentSubGroup2 = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "PACI"
replace StudentSubGroup2 = "Two or More" if StudentSubGroup == "MULT"
replace StudentSubGroup2 = "Hispanic or Latino" if StudentSubGroup == "HISP"
replace StudentSubGroup2 = "White" if StudentSubGroup == "WHTE"

display "El Late"
replace StudentSubGroup2 = "English Learner" if StudentSubGroup == "ELS"
replace StudentSubGroup2 = "English Proficient" if StudentSubGroup == "NOT_ELS"

replace StudentSubGroup2 = "Economically Disadvantaged" if StudentSubGroup == "EDS"
replace StudentSubGroup2 = "Not Economically Disadvantaged" if StudentSubGroup== "NOT_EDS"

replace StudentSubGroup2 = "Male" if StudentSubGroup == "MALE"
replace StudentSubGroup2 = "Female" if StudentSubGroup == "FEM"

display "Homeless"
replace StudentSubGroup2 = "Homeless" if StudentSubGroup == "HMS"
replace StudentSubGroup2 = "Non-Homeless" if StudentSubGroup == "NOT_HMS"
display "Military"
replace StudentSubGroup2 = "Military" if StudentSubGroup == "MIL"
replace StudentSubGroup2 = "Non-Military" if StudentSubGroup == "NOT_MIL"
display "Migrant"
replace StudentSubGroup2 = "Migrant" if StudentSubGroup == "MIG"
replace StudentSubGroup2 = "Non-Migrant" if StudentSubGroup == "NOT_MIG"
display "SWD"
replace StudentSubGroup2 = "SWD" if StudentSubGroup == "SWD"
replace StudentSubGroup2 = "Non-SWD" if StudentSubGroup == "NOT_SWD"
display "Foster Care"
replace StudentSubGroup2 = "Foster Care" if StudentSubGroup == "FCS"
replace StudentSubGroup2 = "Non-Foster Care" if StudentSubGroup == "NOT_FCS"

drop if StudentSubGroup2 == ""
drop StudentSubGroup
rename StudentSubGroup2 StudentSubGroup

// creating student groups 
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Native Hawaiian or Pacific Islander", "Two or More", "Hispanic or Latino", "White")
replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "English Proficient")
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless" 
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military" 
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"

// proficiency level 
gen ProficiencyCriteria = "Levels 2-4" 
// split CODE into district piece, and school piece 
gen StateAssignedDistID = ""
replace StateAssignedDistID = StateAssignedSchID if strpos(StateAssignedSchID, "LEA") > 0
// remove LEA piece from stateassigneddistrictID 
replace StateAssignedDistID = subinstr(StateAssignedDistID, "LEA", "", .)
// drop entries which are "regions" by datalevel 
drop if regexm(StateAssignedSchID, "^NC-SB")
// create datalevel funciton based on codes 
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedDistID != ""
replace DataLevel = "State" if StateAssignedSchID == "NC-SEA"

replace StateAssignedSchID = "" if DataLevel == "District" | DataLevel == "State"
replace StateAssignedDistID = substr(StateAssignedSchID, 1, 3) if DataLevel == "School"
rename StateAssignedDistID State_leaid

gen StateAssignedSchID_full = StateAssignedSchID

//making state assigned school ID just 3 for match 
replace StateAssignedSchID = substr(StateAssignedSchID, 4, .)

merge m:1 State_leaid using "$NCES/1_NCES_2022_District_NC.dta"
rename _merge DistMerge
drop if DistMerge == 2

drop DistMerge

rename StateAssignedSchID seasch
merge m:1 State_leaid seasch using "$NCES/1_NCES_2022_School_NC.dta"
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop SchoolMerge 

merge m:1 State_leaid using  "$data/1_NC_district_IDs_2022.dta" 
drop if _merge == 2
rename seasch StateAssignedSchID 
rename State_leaid StateAssignedDistID 

// create separate district and school names, based on length of code (or datalevel function)
replace DistName = SchName if DataLevel == "District"

// hardcoding DataLevel 
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

// "All Districts" and "All School" creation
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

//Unmerged Schools
replace NCESSchoolID = "370201003674" if SchName == "LaFayette Elementary"
replace SchVirtual = 0 if SchName == "LaFayette Elementary"
replace SchType = 1 if SchName == "LaFayette Elementary"
replace SchLevel = 1 if SchName == "LaFayette Elementary"
replace DistName = "Harnett County Schools" if SchName == "LaFayette Elementary"

replace NCESSchoolID = "370399003447" if SchName == "Moss Street Elementary"
replace SchVirtual = 0 if SchName == "Moss Street Elementary"
replace SchType = 1 if SchName == "Moss Street Elementary"
replace SchLevel = 1 if SchName == "Moss Street Elementary"
replace DistName = "Rockingham County Schools" if SchName == "Moss Street Elementary"

replace NCESSchoolID = "370001203668" if SchName == "Pitt County Virtual"
replace SchVirtual = 1 if SchName == "Pitt County Virtual"
replace SchType = 1 if SchName == "Pitt County Virtual"
replace SchLevel = 4 if SchName == "Pitt County Virtual"
replace DistName = "Pitt County Schools" if SchName == "Pitt County Virtual"

replace NCESSchoolID = "370297003663" if SchName == "Turning Point Middle"
replace SchVirtual = 0 if SchName == "Turning Point Middle"
replace SchType = 4 if SchName == "Turning Point Middle"
replace SchLevel = 2 if SchName == "Turning Point Middle"
replace DistName = "Charlotte-mecklenburg Schools" if SchName == "Turning Point Middle"

replace SchVirtual = 0 if SchName == "Wayne STEM Academy"
replace SchLevel = 1 if SchName == "Wayne STEM Academy"

replace SchVirtual = 0 if SchName == "Tabor City School"
replace SchLevel = 1 if SchName == "Tabor City School"

replace SchVirtual = 0 if SchName == "Selma Burke Middle"
replace SchLevel = 2 if SchName == "Selma Burke Middle"

replace SchVirtual = 0 if NCESSchoolID == "370297003649"
replace SchLevel = 1 if NCESSchoolID == "370297003649"

replace SchVirtual = 0 if NCESSchoolID == "370297003650"
replace SchLevel = 1 if NCESSchoolID == "370297003650"

replace SchVirtual = 0 if NCESSchoolID == "370058003643"
replace SchLevel = 4 if NCESSchoolID == "370058003643"

replace SchVirtual = 0 if NCESSchoolID == "370047903617"
replace SchLevel = 4 if NCESSchoolID == "370047903617"

replace SchVirtual = 0 if NCESSchoolID == "370507103642"
replace SchLevel = 1 if NCESSchoolID == "370507103642"

replace SchVirtual = 0 if NCESSchoolID == "370507703655"
replace SchLevel = 1 if NCESSchoolID == "370507703655"

replace StateAssignedSchID = StateAssignedDistID + StateAssignedSchID

gen ParticipationRate = "--" 

** Generating student group total counts
tostring StudentSubGroup_TotalTested, replace
destring StudentSubGroup_TotalTested, gen(num) force

gen Lev1_c = Lev1_percent
gen Lev2_c = Lev2_percent
gen Lev3_c = Lev3_percent
gen Lev4_c = Lev4_percent

destring Lev1_c Lev2_c Lev3_c Lev4_c, replace force 

replace Lev1_c = round(Lev1_c) * num
replace Lev2_c = round(Lev2_c) * num
replace Lev3_c = round(Lev3_c) * num
replace Lev4_c = round(Lev4_c) * num

replace Lev1_c = round(Lev1_c/100)
replace Lev2_c = round(Lev2_c/100)
replace Lev3_c = round(Lev3_c/100)
replace Lev4_c = round(Lev4_c/100)

tostring Lev1_c Lev2_c Lev3_c Lev4_c, replace

gen Lev1_count = Lev1_percent
gen Lev2_count = Lev2_percent 
gen Lev3_count = Lev3_percent
gen Lev4_count = Lev4_percent
gen ProficientOrAbove_count = ProficientOrAbove_percent

foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_count ProficientOrAbove_percent {
    // Replace ">" with a range (remove ">" and add "-1")
    replace `var' = subinstr(`var', ">", "", .) + "-1" if strpos(`var', ">") != 0
    
    // Replace "<" with a range (replace "<" with "0-")
    replace `var' = subinstr(`var', "<", "0-", .) if strpos(`var', "<") != 0
}

//Code to Convert to Decimals with Ranges
foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent {
	split `var', parse("-")
	destring `var'1, replace i(-)
	destring `var'2, replace i(-)
	replace `var'1 = `var'1/100
	replace `var'2 = `var'2/100 if `var'2 != 1
	replace `var' = string(`var'1, "%6.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(`var'1, "%6.0g") + "-" + string(`var'2, "%6.0g") if !inlist(`var', "*", "--") & `var'2 != .
}

//Code to Convert to Decimals with Ranges
foreach var of varlist ProficientOrAbove_percent {
	split `var', parse("-")
	destring `var'1, replace i(-)
	destring `var'2, replace i(-)
	replace `var'1 = `var'1/100
	replace `var'2 = `var'2/100 if `var'2 != 1
	replace `var' = string(`var'1, "%6.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(`var'1, "%6.0g") + "-" + string(`var'2, "%6.0g") if !inlist(`var', "*", "--") & `var'2 != .
}

//Code to Convert to Decimals with Ranges
foreach var of varlist Lev1_count Lev2_count Lev3_count Lev4_count  {
	split `var', parse("-")
	destring `var'1, replace i(-)
	replace `var'1 = round(`var'1)
	destring `var'2, replace i(-)
	replace `var'2 = round(`var'2)
	replace `var'1 = round(`var'1 * num)
	replace `var'2 = round(`var'2 * num)
	replace `var'1 = round(`var'1/100)
	replace `var'2 = round(`var'2/100) if `var'2 != num
	replace `var' = string(round(`var'1), "%8.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(round(`var'1), "%8.0g") + "-" + string(round(`var'2), "%8.0g") if !inlist(`var', "*", "--") & `var'2 != .
}

//Code to Convert to Decimals with Ranges
foreach var of varlist ProficientOrAbove_count {
	split `var', parse("-")
	destring `var'1, replace i(-)
	replace `var'1 = `var'1
	destring `var'2, replace i(-)
	replace `var'2 = `var'2
	replace `var'1 = `var'1 * num
	replace `var'2 = `var'2 * num
	replace `var'1 = (`var'1/100)
	replace `var'2 = (`var'2/100) if `var'2 != num
	replace `var' = string(round(`var'1), "%8.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(round(`var'1), "%8.0g") + "-" + string(round(`var'2), "%8.0g") if !inlist(`var', "*", "--") & `var'2 != .
}
tostring AvgScaleScore, replace force
replace AvgScaleScore = "--" if AvgScaleScore == "."

replace Lev1_count = Lev1_c if length(Lev1_count) >= 5 & Lev1_c != "."
replace Lev2_count = Lev2_c if length(Lev2_count) >= 5 & Lev2_c != "."
replace Lev3_count = Lev3_c if length(Lev3_count) >= 5 & Lev3_c != "."
replace Lev4_count = Lev4_c if length(Lev4_count) >= 5 & Lev4_c != "."

drop Lev1_c Lev2_c Lev3_c Lev4_c

//Deriving Additional Information
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) >= 0

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & Lev3_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) >= 0

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count) - real(Lev2_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev2_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev4_count)) if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if strpos(Lev1_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"

//Standardizing IDs & Names
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1
replace StateAssignedSchID = "" if (DataLevel == 1 | DataLevel == 2) & StateAssignedSchID != ""

save "$data/NC_AssmtData_2024_Stata", replace

use "NC_StableNames", clear
tostring NCESDistrictID, replace
replace NCESDistrictID = "" if NCESDistrictID == "."
tostring NCESSchoolID, format("%18.0f") replace
replace NCESSchoolID = "" if NCESSchoolID == "."
keep if SchYear == "2022-23"
drop SchYear
merge 1:m DataLevel NCESDistrictID NCESSchoolID using "NC_AssmtData_2024_Stata", gen(merge2)
drop if merge2 == 1
drop merge2
replace DistName = newdistname if DataLevel !=1
replace SchName = newschname if DataLevel == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel ==1

rename DistName1 DistName

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$data/NC_AssmtData_2024", replace
export delimited "$data/NC_AssmtData_2024.csv", replace
