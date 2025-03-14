*******************************************************
* SOUTH DAKOTA

* File name: SD_2018_2023
* Last update: 3/14/2025

*******************************************************
* Notes

	* This do file imports 2018-2023 *.xlsx SD data and saves it as a *.dta.
	* The files are cleaned and variables are renamed.
	* NCES of the previous year is merged. 
	* A breakpoint is created before derivations. 
	* This breakpoint is restored for the non-derivation output. 
	* The following outputs are created:
	* a) Non-derivation output for 2018-2023.
	* b) Final output with derivations for 2019-2023.
	* c) Temporary output with derivations for 2018.
	* The temporary output will be used in SD_EDFacts_2015_2018.do.
	
*******************************************************
clear

** Importing 2018-2023 (excluding 2020) data

//Add code to import 2018 and 2019 files. 
forvalues year = 2018/2023 {
di "~~~~~~~~~~~~"
di "`year'"
di "~~~~~~~~~~~~"	

if `year' == 2020 continue
local prevyear =`=`year'-1'
	
//Unhide below code on first run
clear 
tempfile temp1
save "`temp1'", emptyok
	if `year' == 2020 continue
	
	foreach dl in State District School {
		if `year' == 2018 {
		import excel "$Original/SD_OriginalData_`year'", firstrow sheet ("`dl' 17-18") allstring 
		}
		if `year' == 2019 {
		import excel "$Original/SD_OriginalData_`year'", firstrow sheet ("`dl' 18-19") allstring 
		}
		if `year' > 2020 {
		import excel "$Original/SD_OriginalData_`year'", firstrow sheet ("`dl'") allstring 
		}
		append using "`temp1'"
		save "`temp1'", replace
		clear
		
	}
	use "`temp1'"
	drop if missing(Academic_Year)
	save "$Original_DTA/`year'", replace
	clear

//Unhide Above code on first run
	
clear
use "$Original_DTA/`year'", clear

// Renaming
rename Entity_Level DataLevel
cap drop School_Level
drop Academic_Year
rename Grades GradeLevel
rename Subgroup StudentSubGroup
drop Subgroup_Code
rename Asmt_Type AssmtType
drop Accommodations
rename Nbr_AllStudents_Tested StudentSubGroup_TotalTested
rename Pct_AllStudents_Tested ParticipationRate
rename Nbr_AllStudentsProficient ProficientOrAbove_count
*rename Pct_AllStudentsProficient ProficientOrAbove_percent
rename Nbr_AllStudents_Below_BasicLe Lev1_count
*rename Pct_AllStudents_Below_BasicLe Lev1_percent
rename Nbr_AllStudents_BasicLevel2 Lev2_count
*rename Pct_AllStudents_BasicLevel2 Lev2_percent
rename Nbr_AllStudents_ProficientLev Lev3_count
*rename Pct_AllStudents_ProficientLev Lev3_percent
rename Nbr_AllStudents_AdvancedLevel Lev4_count
*rename Pct_AllStudents_AdvancedLevel Lev4_percent

** Percent variables have a denominator of enrollment, rather than tested, so the percents add to ParticipationRate rather than 100%. Deriving percents based on counts instead.
// Correcting DataLevel
gen DistName = Entity_Name if DataLevel == "District"
gen SchName = Entity_Name if DataLevel == "School"
gen StateAssignedDistID = Entity_ID if DataLevel == "District"
gen StateAssignedSchID = Entity_ID if DataLevel == "School"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

// Dropping Extra Variables
keep DataLevel GradeLevel Subject StudentSubGroup AssmtType StudentSubGroup_TotalTested ParticipationRate ProficientOrAbove_count Lev1_count Lev2_count Lev3_count Lev4_count DistName SchName StateAssignedDistID StateAssignedSchID

// GradeLevel
replace GradeLevel = "G" + GradeLevel
replace GradeLevel = "G38" if GradeLevel == "G03-08"
replace GradeLevel = "G38" if GradeLevel == "G5th & 8th"
forvalues n = 3/8 {
	replace GradeLevel = "G0`n'" if GradeLevel == "G`n'"
}

// Subject
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
replace Subject = "ela" if Subject == "Reading"

// StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners (EL)"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "NON-EL"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NON-Economically Disadvantaged"

// StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino"

//Missing Data
foreach var of varlist _all {
	cap replace `var' = "0" if `var' == "NULL"// edited 7/24/24 since values of NULL are paired with a count value of 0
}

// ParticipationRate
replace ParticipationRate = string(real(ParticipationRate)/100, "%9.4g") if ParticipationRate != "*"
replace ParticipationRate = "--" if missing(real(ParticipationRate)) & ParticipationRate != "*"

// Proficiency Percent Levels
foreach count of varlist *count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.4g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = "*" if `count' == "*"
	replace `percent' = "0" if `count' == "0"
	replace `percent' = "--" if missing(`percent')
}

// Merging
tempfile temp1
save "`temp1'", replace
clear

// District
use "`temp1'"
keep if DataLevel == 2
tempfile tempdist
replace StateAssignedDistID = string(real(StateAssignedDistID),"%05.0f") if DataLevel == 2
save "`tempdist'", replace
use "$NCES_District/NCES_`prevyear'_District"
keep if state_fips_id == 46 | state_name == "South Dakota"
gen StateAssignedDistID = subinstr(state_leaid, "SD-","",.)
merge 1:m StateAssignedDistID using "`tempdist'"

drop if _merge == 1
// drop if _merge == 2 // changed 6/3/24 hidden 11/15/24
drop year
save "`tempdist'", replace

clear

// School
use "`temp1'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear

use "$NCES_School/NCES_`prevyear'_School"
keep if state_fips_id == 46 | state_name == "South Dakota"
gen StateAssignedSchID = subinstr(seasch, "-","",.)
merge 1:m StateAssignedSchID using "`tempsch'"
drop if _merge == 1
// drop if _merge == 2 // changed 6/3/24 hidden 11/15/24
drop year 

if `year' == 2023 {
decode district_agency_type, generate(district_agency_type1) 
drop district_agency_type
rename district_agency_type1 district_agency_type
drop boundary_change_indicator
drop number_of_schools 
drop fips
}

save "`tempsch'", replace

//Appending
use "`temp1'"
keep if DataLevel==1
append using "`tempdist'" "`tempsch'"

// keep if DataLevel==1
//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
if `year' == 2023 {
 rename school_type SchType
 }
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 46
replace StateAbbrev = "SD"
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel ==3

//AssmtType / AssmtName
replace AssmtType = "Regular"
gen AssmtName = ""
replace AssmtName = "SBAC" if Subject != "sci"
replace AssmtName = "SDSA" if Subject == "sci"

//Sci assessment names
replace AssmtName = "SDSA 1.0"  if (`year' == 2018 | `year' == 2019) & Subject == "sci" 
replace AssmtName = "SDSA 2.0" if (`year' == 2021 | `year' == 2022 | `year' == 2023 ) & Subject == "sci"

//Generating additional variables
gen State = "South Dakota"

gen Flag_AssmtNameChange = "N"

if `year' == 2021 {
replace Flag_AssmtNameChange = "Y" if Subject == "sci"
} 

gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N" 
if `year' == 2021 {
replace Flag_CutScoreChange_sci = "Y"
}

gen Flag_CutScoreChange_soc = "Not applicable"

gen ProficiencyCriteria = "Levels 3-4" // Updated 6/2/24
replace AssmtType = "Regular"
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//DistName
replace DistName = lea_name if DataLevel ==3

//StateAssignedDistID
replace StateAssignedDistID = subinstr(State_leaid, "SD-","",.) if DataLevel ==3

//2022 had one unmerged district which contained only suppressed data. 2018 had unmerged schools which were all suppressed.
if (`year' == 2022 | `year' == 2018) drop if _merge ==2

//Empty Variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"

//Final cleaning and dropping extra variables

replace CountyName = proper(CountyName) // added 6/3/24

replace StateAssignedSchID = substr(StateAssignedSchID, -2, 2)
 
replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel ==3 

drop State_leaid seasch

replace CountyName = "McCook County" if CountyName == "Mccook County"
replace CountyName = "McPherson County" if CountyName == "Mcpherson County"
 
//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

gen Derivable = 1 if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if Derivable == 1

drop Unsuppressed* missing_* Derivable

//Level percent (and corresponding count) derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

foreach percent of varlist Lev*_percent {
	replace `percent' = "0" if real(`percent') <  0.005 & !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent))
replace ProficientOrAbove_percent = "*" if missing(ProficientOrAbove_percent)

*******************************************************
// Creating a Breakpoint - to restore for non-derivation data processing
*******************************************************
save "$Temp/SD_`year'_Breakpoint",replace

*********************************************************
//Derivations
*********************************************************
foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

//Misc Fixes
replace DistName = subinstr(DistName, "School District ", "",.)
replace ProficientOrAbove_percent = "1" if real(ProficientOrAbove_percent) > 1 & !missing(real(ProficientOrAbove_percent))
replace ParticipationRate = "1" if real(ParticipationRate) > 1 & !missing(real(ParticipationRate))
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
//Final Cleaning and dropping extra variables
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

*Exporting Temp Output for 2018.
if `year' == 2018 {
save "$Temp/SD_AssmtData_`year'", replace
}

*Exporting Final Output for 2019-2023.
if `year' > 2018 {
save "$Output/SD_AssmtData_`year'", replace
export delimited "$Output/SD_AssmtData_`year'", replace
}
}

*********************************************************
// Creating the non-derivation output
*********************************************************
forvalues year = 2018/2023 {
di "~~~~~~~~~~~~"
di "`year'"
di "~~~~~~~~~~~~"	

if `year' == 2020 continue
local prevyear =`=`year'-1'
	
*******************************************************
// Restoring breakpoint for non-derivation data processing
*******************************************************
use "$Temp/SD_`year'_Breakpoint", clear

//Misc Fixes
replace DistName = subinstr(DistName, "School District ", "",.)
replace ProficientOrAbove_percent = "1" if real(ProficientOrAbove_percent) > 1 & !missing(real(ProficientOrAbove_percent))
replace ParticipationRate = "1" if real(ParticipationRate) > 1 & !missing(real(ParticipationRate))
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
//Final Cleaning and dropping extra variables
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

*Exporting Non-Derivation Output.
save "$Output_ND/SD_AssmtData_`year'_ND", replace
export delimited "$Output_ND/SD_AssmtData_`year'_ND", replace
}
* END of SD_2018_2023.do
****************************************************
