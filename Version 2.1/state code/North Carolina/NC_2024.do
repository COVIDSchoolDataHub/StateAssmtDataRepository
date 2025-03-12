*******************************************************
* NORTH CAROLINA 

* File name: NC_2024
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file imports 2024 *.txt files and saves it as *.dta.
	* Variables are renamed and the file is cleaned.
	* The file is merged with NCES 2022. 
	* As of 3/5/25, the latest NCES is 2022. 
	* This file will need to be updated when NCES_2023 becomes available.
	* The do file also replaces the names with Stable Names. 
	* Both the derivation and non-derivation output are created. 

*******************************************************
clear 

*******************************************************
// Importing data, renaming variables and cleaning the file
*******************************************************
//2023-2024
// import delimited "$Original/Disag_2023-24_Data.txt", clear
// save "$Original_DTA/NC_OriginalData_2024.dta", replace


use "$Original_DTA/NC_OriginalData_2024", clear 
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

merge m:1 State_leaid using "$NCES_NC/NCES_2022_District_NC.dta"
rename _merge DistMerge
drop if DistMerge == 2

drop DistMerge

rename StateAssignedSchID seasch
merge m:1 State_leaid seasch using "$NCES_NC/NCES_2022_School_NC.dta"
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop SchoolMerge 

merge m:1 State_leaid using  "$NCES_NC/NC_district_IDs_2022.dta" 
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

******************************
// Creating a breakpoint file. This will be restored to create the non-derivation output.
******************************
save "$Temp/NC_AssmtData_2024_Breakpoint", replace

** Generating student group total counts
tostring StudentSubGroup_TotalTested, replace
destring StudentSubGroup_TotalTested, gen(num) force

gen Lev1_c = Lev1_percent
gen Lev2_c = Lev2_percent
gen Lev3_c = Lev3_percent
gen Lev4_c = Lev4_percent

destring Lev1_c Lev2_c Lev3_c Lev4_c, replace force 

******************************
//Derivations//
******************************
//Counts derived from using percentages * SSGT
replace Lev1_c = Lev1_c * num
replace Lev2_c = Lev2_c * num
replace Lev3_c = Lev3_c * num
replace Lev4_c = Lev4_c * num

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
	replace `var'1 = `var'1
	destring `var'2, replace i(-)
	replace `var'2 = `var'2
	replace `var'1 = `var'1 * num
	replace `var'2 = `var'2 * num
	replace `var'1 = round(`var'1/100)
	replace `var'2 = round(`var'2/100) if `var'2 != num
	replace `var' = string(`var'1, "%8.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(`var'1, "%8.0g") + "-" + string(`var'2, "%8.0g") if !inlist(`var', "*", "--") & `var'2 != .
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
	replace `var'1 = round(`var'1/100)
	replace `var'2 = round(`var'2/100) if `var'2 != num
	replace `var' = string(`var'1, "%8.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(`var'1, "%8.0g") + "-" + string(`var'2, "%8.0g") if !inlist(`var', "*", "--") & `var'2 != .
}

tostring AvgScaleScore, replace force
replace AvgScaleScore = "--" if AvgScaleScore == "."

replace Lev1_count = Lev1_c if length(Lev1_count) >= 5 & Lev1_c != "."
replace Lev2_count = Lev2_c if length(Lev2_count) >= 5 & Lev2_c != "."
replace Lev3_count = Lev3_c if length(Lev3_count) >= 5 & Lev3_c != "."
replace Lev4_count = Lev4_c if length(Lev4_count) >= 5 & Lev4_c != "."

drop Lev1_c Lev2_c Lev3_c Lev4_c

//Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev2_percent) + real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & Lev4_percent != "*" & ProficiencyCriteria == "Levels 2-4"
replace ProficientOrAbove_count = string(real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & Lev2_count != "*" & Lev3_percent != "*" & Lev4_count != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) >= 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) < 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count)) if strpos(Lev4_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & Lev3_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev2_count) >= 0
replace Lev4_percent = "0" if Lev4_count == "0"
replace Lev4_count = "0" if Lev4_percent == "0"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent) >= 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent) < 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count) - real(Lev2_count)) if strpos(Lev3_count, "-") > 0 & strpos(Lev2_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"
replace Lev3_percent = "0" if Lev3_count == "0"
replace Lev3_count = "0" if Lev3_percent == "0"

replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent) >= 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent) < 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev2_count = string(real(ProficientOrAbove_count) - real(Lev3_count) - real(Lev4_count)) if strpos(Lev2_count, "-") > 0 & strpos(Lev3_count, "-") == 0 & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"
replace Lev2_percent = "0" if Lev2_count == "0"
replace Lev2_count = "0" if Lev2_percent == "0"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & 1 - real(ProficientOrAbove_percent) >= 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "-") > 0 & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & 1 - real(ProficientOrAbove_percent) < 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if strpos(Lev1_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & ProficiencyCriteria == "Levels 2-4"
replace Lev1_percent = "0" if Lev1_count == "0"
replace Lev1_count = "0" if Lev1_percent == "0"

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

save "$Temp/NC_AssmtData_2024_Stata", replace

use "$Original_DTA/NC_StableNames", clear
tostring NCESDistrictID, replace
replace NCESDistrictID = "" if NCESDistrictID == "."
tostring NCESSchoolID, format("%18.0f") replace
replace NCESSchoolID = "" if NCESSchoolID == "."
keep if SchYear == "2022-23"
drop SchYear
merge 1:m DataLevel NCESDistrictID NCESSchoolID using "$Temp/NC_AssmtData_2024_Stata", gen(merge2)
drop if merge2 == 1
replace DistName = newdistname if DataLevel !=1 & merge2 == 3
replace SchName = newschname if DataLevel == 3 & merge2 == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel ==1

rename DistName1 DistName

local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 	keep `vars'
	order `vars'

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
//Exporting Output
save "$Output/NC_AssmtData_2024", replace
export delimited "$Output/NC_AssmtData_2024.csv", replace

******************************
// Creating the non-derivation output
******************************
*Restoring the breakpoint
use "$Temp/NC_AssmtData_2024_Breakpoint", clear

** Generating student group total counts
tostring StudentSubGroup_TotalTested, replace
destring StudentSubGroup_TotalTested, gen(num) force

gen Lev1_c = Lev1_percent
gen Lev2_c = Lev2_percent
gen Lev3_c = Lev3_percent
gen Lev4_c = Lev4_percent

destring Lev1_c Lev2_c Lev3_c Lev4_c, replace force 

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
	replace `var'1 = `var'1
	destring `var'2, replace i(-)
	replace `var'2 = `var'2
	replace `var'1 = `var'1 * num
	replace `var'2 = `var'2 * num
	replace `var'1 = round(`var'1/100)
	replace `var'2 = round(`var'2/100) if `var'2 != num
	replace `var' = string(`var'1, "%8.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(`var'1, "%8.0g") + "-" + string(`var'2, "%8.0g") if !inlist(`var', "*", "--") & `var'2 != .
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
	replace `var'1 = round(`var'1/100)
	replace `var'2 = round(`var'2/100) if `var'2 != num
	replace `var' = string(`var'1, "%8.0g") if !inlist(`var', "*", "--") & `var'2 == .
	replace `var' = string(`var'1, "%8.0g") + "-" + string(`var'2, "%8.0g") if !inlist(`var', "*", "--") & `var'2 != .
}

tostring AvgScaleScore, replace force
replace AvgScaleScore = "--" if AvgScaleScore == "."

//Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev2_percent) + real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & Lev4_percent != "*" & ProficiencyCriteria == "Levels 2-4"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent)) if strpos(Lev4_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) >= 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev3_percent) - real(Lev2_percent) < 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent)) if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent) >= 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "-") > 0 & strpos(Lev2_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev2_percent) < 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0

replace Lev2_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent)) if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent) >= 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "-") > 0 & strpos(Lev3_percent, "-") == 0 & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & & real(ProficientOrAbove_percent) - real(Lev4_percent) - real(Lev3_percent) < 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent)) if strpos(Lev1_percent, "-") > 0 & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & 1 - real(ProficientOrAbove_percent) >= 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "-") > 0 & strpos(ProficientOrAbove_percent, "-") == 0 & ProficientOrAbove_percent != "*" & ProficiencyCriteria == "Levels 2-4" & 1 - real(ProficientOrAbove_percent) < 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

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

save "$Temp/NC_AssmtData_2024_Stata_ND", replace

use "$Original_DTA/NC_StableNames", clear
tostring NCESDistrictID, replace
replace NCESDistrictID = "" if NCESDistrictID == "."
tostring NCESSchoolID, format("%18.0f") replace
replace NCESSchoolID = "" if NCESSchoolID == "."
keep if SchYear == "2022-23"
drop SchYear
merge 1:m DataLevel NCESDistrictID NCESSchoolID using "$Temp/NC_AssmtData_2024_Stata_ND", gen(merge2)
drop if merge2 == 1
replace DistName = newdistname if DataLevel !=1 & merge2 == 3
replace SchName = newschname if DataLevel == 3 & merge2 == 3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel ==1

rename DistName1 DistName

replace Lev1_count = "--"
replace Lev2_count = "--"
replace Lev3_count = "--"
replace Lev4_count = "--"
replace ProficientOrAbove_count = "--"

//Sorting, ordering and keeping select variables.
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// assmtname update 2024 for sci 
replace AssmtName = "End-of-Grade Tests - Edition 2" if Subject == "sci"

//Exporting Non-Derivation Output
save "$Output_ND/NC_AssmtData_2024_ND", replace
export delimited "$Output_ND/NC_AssmtData_2024_ND.csv", replace
* END of NC_2024.do
****************************************************
