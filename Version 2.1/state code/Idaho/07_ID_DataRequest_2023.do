*******************************************************
* IDAHO

* File name: 07_ID_DataRequest_2023
* Last update: 2/7/2025

*******************************************************
* Notes

	* This do file first cleans ID's 2023 data.  
	* Then this file merges ID's data with NCES_2022
	* The completed file is saved to the the Output folder.
	
*******************************************************
clear all

///////////////////////////////
// Setup
///////////////////////////////

// Define file paths
global orig_files_DR_112723 "C:\Users\Clare\Desktop\Zelma V2.1\Idaho\Original Data\Idaho data received from data request 11-27-23"
global NCES_files "C:\Users\Clare\Desktop\Zelma V2.0\Iowa - Version 2.0\NCES_full"
global output_files "C:\Users\Clare\Desktop\Zelma V2.1\Idaho\Output"
global temp_files "C:\Users\Clare\Desktop\Zelma V2.1\Idaho\Temp"

///////////////////////////////
// Appending State, District, and School tabs into one file for editing
///////////////////////////////

import excel "$original_files/2022-2023 Assessment Aggregates (Redacted).xlsx", sheet("State Of Idaho") firstrow clear
gen DataLevel = "State"
save "${temp_files}/ID_AssmtData_2023_state.dta", replace

import excel "$original_files/2022-2023 Assessment Aggregates (Redacted).xlsx", sheet("Districts") firstrow clear
gen DataLevel = "District"
save "${temp_files}/ID_AssmtData_2023_district.dta", replace

import excel "$original_files/2022-2023 Assessment Aggregates (Redacted).xlsx", sheet("Schools") firstrow clear
gen DataLevel = "School"
save "${temp_files}/ID_AssmtData_2023_school.dta", replace

clear

append using "${temp_files}/ID_AssmtData_2023_state.dta" "${temp_files}/ID_AssmtData_2023_district.dta" "${temp_files}/ID_AssmtData_2023_school.dta"

save "${temp_files}/ID_AssmtData_2023_all.dta", replace

///////////////////////////////
// Cleaning ID 2023 file
///////////////////////////////

// Renaming Variables
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
rename Tested StudentSubGroup_TotalTested
rename TestedRate ParticipationRate
rename DistrictId StateAssignedDistID
rename DistrictName DistName
rename SchoolId StateAssignedSchID
rename SchoolName SchName
drop ParticipationDenominator
drop ProficiencyDenominator

// Dropping irrelevant Observations
drop if Lev1_percent == "N/A"
drop if GradeLevel == "High School"
drop if GradeLevel == "All Grades"

// StudentSubGroup
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup,"Asian")
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup,"Black")
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Economically Disadvantaged "
replace StudentSubGroup = "Not Economically Disadvantaged" if strpos(StudentSubGroup, "Not Economically Disadvantaged")
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian or Alaskan Native")
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not LEP"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian")
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two Or More")
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

// Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"

// Additional File Variables
gen State = "Idaho"
gen SchYear = "2022-23"
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

// Generating IDs to faciliate merging with NCES
gen State_leaid = "ID-"+StateAssignedDistID
gen seasch = StateAssignedDistID+"-"+StateAssignedSchID

// Generating + Formatting Student Group Counts
gen statedistid = "000000" if DataLevel == "State"
gen stateschid = "000000" if inlist(DataLevel, "State", "District")

egen uniquegrp = group(DataLevel statedistid stateschid AssmtName AssmtType Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

*tostring StudentGroup_TotalTested, replace
*tostring StudentSubGroup_TotalTested, replace

//ParticipationRate 
replace ParticipationRate = "--" if ParticipationRate == "N/A"
replace ParticipationRate = "*" if ParticipationRate == "NSIZE" | strpos(ParticipationRate, "*") !=0
gen PartRange = "Y" if strpos(ParticipationRate,">") !=0
destring ParticipationRate, gen(Part) i(*->)
replace Part = Part/100
replace ParticipationRate = string(Part, "%9.3f") if !missing(Part)
replace ParticipationRate = ParticipationRate + "-1" if PartRange == "Y"
drop PartRange

//Deriving ProficientOrAbove_percent and Dealing with ranges in level percents
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

//Derive ProficientOrAbove_count
generate ProficientOrAbove_count = Lev3_count + Lev4_count if (Lev3_count !=. & Lev4_count !=.)
replace ProficientOrAbove_count = StudentSubGroup_TotalTested - (Lev1_count + Lev2_count) if ProficientOrAbove_count == . & (Lev1_count !=. & Lev2_count !=.)

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

//Deriving ProficientOrAbove_percent if the new ProficientOrAbove_count is not a range
gen ProfAbove_count_num = real(ProficientOrAbove_count)  // Convert to numeric
gen ProfAbove_count_rngflag =1 if strpos(ProficientOrAbove_count, "-") & (ProficientOrAbove_count != "--") & (ProficientOrAbove_count > "0")
gen ProfAbove_per_rngflag =1 if strpos(ProficientOrAbove_percent, "-") & (ProficientOrAbove_percent != "--") & (ProficientOrAbove_percent > "0")
gen OG_ProficientOrAbove_percent = ProficientOrAbove_percent // use for reference only 

	* Where ProficientOrAbove_p is currently a range but ProficientOrAbove_c is not
	replace ProficientOrAbove_percent = string(ProfAbove_count_num/StudentSubGroup_TotalTested, "%9.3f") if ProfAbove_count_rngflag != 1 & ProfAbove_per_rngflag == 1 & StudentSubGroup_TotalTested !=.

	* Where ProficientOrAbove_p is currently SUPPRESSED but ProficientOrAbove_c is not missing or suppressed
	replace ProficientOrAbove_percent = string(ProfAbove_count_num/StudentSubGroup_TotalTested, "%9.3f") if ProfAbove_count_rngflag != 1 & ProficientOrAbove_percent =="*" & StudentSubGroup_TotalTested !=.
	
// DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

// Order 
local vars State SchYear DataLevel StateAssignedDistID state_leaid DistName StateAssignedSchID seasch SchName AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent ProficiencyCriteria ParticipationRate AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_soc Flag_CutScoreChange_sci

	keep `vars'
	order `vars'

// Saving transformed data
save "${output_files}/ID_AssmtData_2023.dta", replace


//////////////////////////////////////////////////////////
// Merging with NCES School Data
//////////////////////////////////////////////////////////

use "$NCES_files/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School.dta" 
rename state_leaid State_leaid
keep state_location state_fips district_agency_type school_type ncesdistrictid State_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code
decode district_agency_type, gen(temp)
drop district_agency_type
rename temp district_agency_type

drop if seasch == ""

*Retain NCESSchoolIDs that start with "16". This includes all schools in ID except for 2 BIE schools that start with "59"
keep if substr(ncesschoolid, 1, 2) == "16"
merge 1:m seasch using "${output_files}/ID_AssmtData_2023.dta", keep(match using) nogenerate

save "${output_files}/ID_AssmtData_2023.dta", replace

//////////////////////////////////////////////////////////
// Merging with NCES District Data
//////////////////////////////////////////////////////////

use "$NCES_files/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District.dta" 

rename state_leaid State_leaid
keep state_location state_fips district_agency_type ncesdistrictid State_leaid DistCharter DistLocale county_name county_code

*Retain NCESSchoolIDs that start with "16". This includes all schools in ID except for 2 BIE schools that start with "59"
keep if substr(ncesdistrictid, 1, 2) == "16"

merge 1:m State_leaid using "${output_files}/ID_AssmtData_2023.dta", keep(match using) nogenerate

// Removing extra variables and renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_location StateAbbrev
rename county_code CountyCode
rename state_fips StateFips
rename county_name CountyName
rename school_type SchType

// Adding StateAbbrev and StateFips to state data
replace StateAbbrev = "ID" if DataLevel == 1
replace StateFips = 16 if DataLevel == 1

// Dropping non-ID data. This district ("PLEASANT VALLEY ELEM DIST") is in Oregon and the data are all suppressed.
*tab DistName if StateAbbrev !="ID"
drop if StateAbbrev != "ID"

//Standardizing District & School Names
replace DistName =stritrim(DistName)
replace DistName =strtrim(DistName)
replace SchName=stritrim(SchName)
replace SchName=strtrim(SchName)
replace DistName = subinstr(DistName, " INC.", ", INC.", 1) if strpos(DistName, ", INC.") <= 0 & strpos(DistName, "INC.") > 0
replace SchName = subinstr(SchName, " INC.", ", INC.", 1) if strpos(SchName, ", INC.") <= 0 & strpos(SchName, "INC.") > 0
replace DistName = "AVERY SCHOOL DISTRICT" if NCESDistrictID == "1600150"

// Derive additional information
destring Lev2_percent, gen(Lev2_p) force
destring Lev2_count, gen(Lev2_c) force
destring Lev3_percent, gen(Lev3_p) force
destring Lev3_count, gen(Lev3_c) force
destring ProficientOrAbove_percent, gen(prof_p) force
destring ProficientOrAbove_count, gen(prof_c) force
gen studcount = StudentSubGroup_TotalTested


	* Deriving Lev1_percent
	replace Lev1_percent = string(1 - prof_p - Lev2_p) if 	///
		inlist(Lev1_percent, "*", "--") & 					///
		!inlist(Lev2_percent, "*", "--") & 					///
		!inlist(ProficientOrAbove_percent, "*", "--")

	* Deriving Lev1_count
	replace Lev1_count = string(round(studcount - prof_c - Lev2_c)) if ///
		inlist(Lev1_count, "*", "--") & 					///
		!inlist(Lev2_count, "*", "--") & 					///
		!missing(StudentSubGroup_TotalTested) & 			///
		!inlist(ProficientOrAbove_count, "*", "--")

	* Deriving Lev4_percent
	replace Lev4_percent = string(prof_p - Lev3_p) if 		///
		inlist(Lev4_percent, "*", "--") & 					///
		!inlist(Lev3_percent, "*", "--") & 					///
		!inlist(ProficientOrAbove_percent, "*", "--")

	* Deriving Lev4_count
	replace Lev4_count = string(round(prof_c - Lev3_c)) if 	///
		inlist(Lev4_count, "*", "--") & 					///
		!inlist(Lev3_count, "*", "--") & 					///
		!inlist(ProficientOrAbove_count, "*", "--")

// Reordering variables and sorting data
local vars 	State StateAbbrev StateFips SchYear DataLevel DistName SchName 		/// 
		NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID 	///
		AssmtName AssmtType Subject GradeLevel StudentGroup 			///
		StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested	///
		Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count 		///
		Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent 		///
		AvgScaleScore ProficiencyCriteria ProficientOrAbove_count 		///
		ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange 	///
		Flag_CutScoreChange_ELA Flag_CutScoreChange_math 			///
		Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType 		///
		DistCharter DistLocale SchType SchLevel SchVirtual CountyName 		///
		CountyCode

	keep `vars'
	order `vars'

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

*save "${output_files}/ID_AssmtData_2023.dta", replace
export delimited using "$output_files/ID_AssmtData_2023.csv", replace
