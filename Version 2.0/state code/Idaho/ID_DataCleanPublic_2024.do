clear all
set more off
cd "/Users/miramehta/Documents"

// Define file paths

global original_files "/Users/miramehta/Documents/ID State Testing Data/Original Data"
global NCES_files "/Users/miramehta/Documents/NCES District and School Demographics"
global output_files "/Users/miramehta/Documents/ID State Testing Data/Output"
global temp_files "/Users/miramehta/Documents/ID State Testing Data/Temp"

// 2023-2024

import excel "${original_files}/ID_OriginalData_2024_ela_math_sci.xlsx", sheet("State of Idaho") firstrow clear
gen DataLevel = "State"
save "${temp_files}/ID_AssmtData_2024_state.dta", replace

import excel "$original_files/ID_OriginalData_2024_ela_math_sci.xlsx", sheet("Districts") firstrow clear
gen DataLevel = "District"
save "${temp_files}/ID_AssmtData_2024_district.dta", replace

import excel "$original_files/ID_OriginalData_2024_ela_math_sci.xlsx", sheet("Schools") firstrow clear
gen DataLevel = "School"
save "${temp_files}/ID_AssmtData_2024_school.dta", replace

clear

append using "${temp_files}/ID_AssmtData_2024_state.dta" "${temp_files}/ID_AssmtData_2024_district.dta" "${temp_files}/ID_AssmtData_2024_school.dta"

save "${temp_files}/ID_AssmtData_2024_all.dta", replace


// Renaming Variables

use "${temp_files}/ID_AssmtData_2024_all.dta", clear

rename SubjectName Subject
rename Grade GradeLevel
rename Population StudentSubGroup
rename Advanced Lev4_count
rename AdvancedRate	Lev4_percent
rename Proficient Lev3_count
rename ProficientRate Lev3_percent
rename Basic Lev2_count
rename BasicRate Lev2_percent
rename BelowBasic Lev1_count
rename BelowBasicRate Lev1_percent
rename ProficiencyDenominator StudentSubGroup_TotalTested
rename TestedRate ParticipationRate
rename DistrictId StateAssignedDistID
rename DistrictName DistName
rename SchoolId StateAssignedSchID
rename SchoolName SchName
drop NonTestedRate


// Dropping irrelevant Observations
//drop if Lev1_percent == "N/A"
drop if GradeLevel == "High School"
drop if GradeLevel == "All Grades"

// StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup,"Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup,"Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Economically Disadvantaged "
replace StudentSubGroup = "Not Economically Disadvantaged" if strpos(StudentSubGroup, "Not Economically Disadvantaged") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian or Alaskan Native") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not LEP"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two Or More") !=0
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"

// StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

// GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ","",.)
keep if GradeLevel == "3" | GradeLevel == "4" | GradeLevel == "5" | GradeLevel == "6" | GradeLevel == "7" | GradeLevel == "8"
replace GradeLevel = "G0" + GradeLevel

// DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

//Derive Missing Student Counts
replace StudentSubGroup_TotalTested = Lev1_count + Lev2_count + Lev3_count + Lev4_count if StudentSubGroup_TotalTested == .

//Proficient or above percent and Dealing with ranges
gen missing = ""
foreach n in 1 2 3 4 {
	gen Range`n' = ""
}
foreach n in 1 2 3 4 {
	gen Suppressed`n' = "*" if strpos(Lev`n'_percent,"*") !=0 | strpos(Lev`n'_percent, "NSIZE") !=0
	replace Range`n' = "-1" if strpos(Lev`n'_percent, ">") !=0
	replace Range`n' = "0-" if strpos(Lev`n'_percent, "<") !=0
	replace missing = "Y" if Lev`n'_percent == "N/A"
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*NSIZE/A<>)
	replace nLev`n'_percent = nLev`n'_percent/100
	replace Lev`n'_percent = Range`n' + string(nLev`n'_percent, "%9.3f")
	replace Lev`n'_percent = substr(Lev`n'_percent, 3, 8) + Range`n' if Range`n' == "-1"
	replace Lev`n'_percent = "*" if Suppressed`n' == "*"
	replace Lev`n'_percent = "--" if missing == "Y"

}
gen ProficientOrAbove_percent = string(nLev3_percent + nLev4_percent, "%9.3f")
replace ProficientOrAbove_percent = "*" if Suppressed3 == "*" | Suppressed4 == "*"
replace ProficientOrAbove_percent = "*" if Range3 != Range4 & !missing(Range3) & !missing(Range4)
replace ProficientOrAbove_percent = Lev3_percent + "-" + ProficientOrAbove_percent if Range4 == "0-" & missing(Range3)
replace ProficientOrAbove_percent = Lev4_percent + "-" + ProficientOrAbove_percent if Range3 == "0-" & missing(Range4)
replace ProficientOrAbove_percent = "0-" + ProficientOrAbove_percent if Range3 == "0-" & Range4 == "0-"
replace ProficientOrAbove_percent = ProficientOrAbove_percent + "-1" if Range3 == "-1" & ProficientOrAbove_percent != "*"
replace ProficientOrAbove_percent = ProficientOrAbove_percent + "-1" if Range4 == "-1" & ProficientOrAbove_percent != "*"

destring ProficientOrAbove_percent, gen(ind) i(*-) force
replace ind = 1 if ind > 1 & !missing(ind)
replace ProficientOrAbove_percent = "*" if ind == 1 & !missing(Range3) & !missing(Range4)
drop ind
replace ProficientOrAbove_percent = "--" if missing== "Y"

replace ParticipationRate = "--" if ParticipationRate == "N/A"
replace ParticipationRate = "*" if ParticipationRate == "NSIZE" | strpos(ParticipationRate, "*") !=0
gen PartRange = "Y" if strpos(ParticipationRate,">") !=0
destring ParticipationRate, gen(Part) i(*->)
replace Part = Part/100
replace ParticipationRate = string(Part, "%9.3f") if !missing(Part)
replace ParticipationRate = ParticipationRate + "-1" if PartRange == "Y"
drop PartRange

generate ProficientOrAbove_count = Lev3_count + Lev4_count
replace ProficientOrAbove_count = StudentSubGroup_TotalTested - (Lev1_count + Lev2_count) if ProficientOrAbove_count == .

foreach n in 1 2 3 4 {
replace Lev`n'_percent = "--" if Lev`n'_percent == "*" & (Suppressed1 != Suppressed2 | Suppressed3 != Suppressed4 | Suppressed2 != Suppressed3)
tostring Lev`n'_count, replace force
replace Lev`n'_count = "*" if Lev`n'_count == "."
replace Lev`n'_count = "--" if Lev`n'_percent == "--"
}
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
replace ParticipationRate = "--" if Lev1_percent == "--" & Lev2_percent == "--" & Lev3_percent == "--" & Lev4_percent == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_percent == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_percent == "--"
drop Part

foreach i in Lev1 Lev2 Lev3 Lev4 ProficientOrAbove {	
	split `i'_percent, parse("-")
	replace `i'_percent1 = "" if `i'_percent == `i'_percent1
	destring `i'_percent1, replace force
	destring `i'_percent2, replace force
	gen `i'_count1 = round(`i'_percent1 * StudentSubGroup_TotalTested)
	gen `i'_count2 = round(`i'_percent2 * StudentSubGroup_TotalTested)
	tostring `i'_count1, replace
	tostring `i'_count2, replace
	replace `i'_count = `i'_count1 + "-" + `i'_count2 if inlist(`i'_count, "*", "--") & `i'_count1 != "." & `i'_count2 != "." & `i'_count1 != `i'_count2
	replace `i'_count = `i'_count1 if inlist(`i'_count, "*", "--") & `i'_count1 != "." & `i'_count2 != "." & `i'_count1 == `i'_count2
	replace `i'_count = `i'_count1 if inlist(`i'_count, "*", "--") & `i'_count1 != "." & `i'_count2 == "."
}

// Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

// Missing Variables
gen State = "Idaho"
gen SchYear = "2023-24"
gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"
gen AssmtName = "ISAT"
gen AssmtType = "Regular"
gen State_leaid = "ID-"+StateAssignedDistID
gen seasch = StateAssignedDistID+"-"+StateAssignedSchID

// Generating + Formatting Student Group Counts
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
tostring StudentGroup_TotalTested, replace

// Saving transformed data
save "${output_files}/ID_AssmtData_2024.dta", replace

// Merging with NCES District Data

use "${NCES_files}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District.dta" 

rename state_leaid State_leaid
keep state_location state_fips district_agency_type ncesdistrictid State_leaid DistCharter DistLocale county_name county_code
keep if substr(ncesdistrictid, 1, 2) == "16"

merge 1:m State_leaid using "${output_files}/ID_AssmtData_2024.dta"
//export excel using "C:\Users\hxu15\Downloads\Idaho\Output\NCESUnMergedDistricts.xlsx" if _merge == 2, firstrow(variables) replace
keep if _merge == 2 | _merge == 3
drop _merge

save "${output_files}/ID_AssmtData_2024.dta", replace


// Merging with NCES School Data

use "${NCES_files}/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School.dta" 
rename state_leaid State_leaid
keep state_location state_fips district_agency_type school_type ncesdistrictid State_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code
decode district_agency_type, gen(temp)
drop district_agency_type
rename temp district_agency_type

drop if seasch == ""

keep if substr(ncesschoolid, 1, 2) == "16"

merge 1:m seasch using "${output_files}/ID_AssmtData_2024.dta"
//export excel using "C:\Users\hxu15\Downloads\Idaho\Output\NCESUnMergedSchools.xlsx" if _merge == 2, firstrow(variables) replace
keep if _merge == 2 | _merge == 3
drop _merge

save "${output_files}/ID_AssmtData_2024.dta", replace

tabulate SchVirtual

* This shows us the following value labels:
*	0 = No
*	1 = Yes
* 	2 = Virtual with face to face options

* Let's get our SchVirtual variable set up in a way that will allow merging

tostring SchVirtual, gen(schvirt_str)

* This pulls in the value labels of 0, 1 and 2 as strings into our new variable. Let's change these to the right string labels.

replace schvirt_str = "No" if schvirt_str == "0"
replace schvirt_str = "Yes" if schvirt_str == "1"
replace schvirt_str = "Virtual with face to face options" if schvirt_str == "2"

* Always test your work
tab SchVirtual schvirt_str // this shows us we converted everything properly.

* Drop vars we don't need
drop SchVirtual

* Rename 
rename schvirt_str SchVirtual

******************
* SchLevel
******************* 

tabulate SchLevel

* This shows us the following value labels:
*	-1: Missing/not reported
*	1 = Primary
*	2 = Middle
* 	3 = High
*	4 = Other
*	7 = Secondary

* Let's get our SchLevel variable set up in a way that will allow merging

tostring SchLevel, gen(schlev_str)

* This pulls in the value labels of 0, 1 and 2 as strings into our new variable. Let's change these to the right string labels.

replace schlev_str = "Missing/not reported" if schlev_str == "-1"
replace schlev_str = "Primary" if schlev_str == "1"
replace schlev_str = "Middle" if schlev_str == "2"
replace schlev_str = "High" if schlev_str == "3"
replace schlev_str = "Other" if schlev_str == "4"
replace schlev_str = "Secondary" if schlev_str == "7"

* Always test your work
tab SchLevel schlev_str // this shows us we converted everything properly.

* Drop vars we don't need
drop SchLevel

* Rename 
rename schlev_str SchLevel


**SchType
* 1 = Regular school
* 2 = Special Education school
* 4 = Other/alternative school
tostring school_type, gen(schtype_str)
replace schtype_str = "Regular school" if schtype_str == "1"
replace schtype_str = "Special education school" if schtype_str == "2"
replace schtype_str = "Other/alternative school" if schtype_str == "4"
tab school_type schtype_str
drop school_type
rename schtype_str school_type

save "${output_files}/ID_AssmtData_2024.dta", replace


// merging with NCES new schools

import excel "${original_files}/Idaho 2024 new schools.xlsx", firstrow allstring clear

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
drop DataLevel
rename DataLevel_n DataLevel 


merge 1:m seasch using "${output_files}/ID_AssmtData_2024.dta"

drop _merge


save "${output_files}/ID_AssmtData_2024.dta", replace



// Removing extra variables and renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename county_code CountyCode
rename county_name CountyName
rename school_type SchType
keep State SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc

// Fixing missing state data
gen StateAbbrev = "ID"
gen StateFips = 16
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

// Dropping not ID data
drop if StateAbbrev != "ID"

//Response to post-launch review

//Deriving Percents if the count is not a range
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
if "`var'" == "Lev5_percent" continue
local count = subinstr("`percent'", "percent", "count",.)
replace `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if regexm(`percent', "[*-]") !=0 & regexm(StudentSubGroup_TotalTested, "[*-]") == 0 & regexm(`count', "[-*]") == 0 
}

// removing spaces in names
replace DistName =stritrim(DistName)
replace DistName =strtrim(DistName)
replace SchName=stritrim(SchName)
replace SchName=strtrim(SchName)

//Cleaning up NCES Data
replace SchType =stritrim(SchType)
replace SchType = "" if SchType == "."
replace SchType = "Special education school" if SchType == "Special Education school"
replace SchLevel = "" if SchLevel == "." & SchName == "All Schools"
replace SchVirtual = "" if SchVirtual == "." & SchName == "All Schools"
replace SchVirtual = "Missing/not reported" if SchVirtual == "." & SchName != "All Schools"

* Add information for 2024 new schools
replace SchLevel = "Primary" if NCESSchoolID == "160036001166"
replace SchVirtual = "No" if NCESSchoolID == "160036001166"
replace SchLevel = "Primary" if NCESSchoolID == "160351201179"
replace SchVirtual = "No" if NCESSchoolID == "160351201179"
replace SchLevel = "Primary" if NCESSchoolID == "160351301180"
replace SchVirtual = "No" if NCESSchoolID == "160351301180"
replace SchLevel = "Primary" if NCESSchoolID == "160351401181"
replace SchVirtual = "No" if NCESSchoolID == "160351401181"
replace SchLevel = "Other" if NCESSchoolID == "160351501182"
replace SchVirtual = "No" if NCESSchoolID == "160351501182"

//Removing leading zeroes in District IDs
replace StateAssignedDistID = subinstr(StateAssignedDistID, "0", "", 1) if strpos(StateAssignedDistID, "0") == 1
*replace StateAssignedSchID = subinstr(StateAssignedSchID, "0", "", 1) if strpos(StateAssignedSchID, "0") == 1

// Reordering variables and sorting data
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/ID_AssmtData_2024.dta", replace
export delimited using "${output_files}/ID_AssmtData_2024.csv", replace


