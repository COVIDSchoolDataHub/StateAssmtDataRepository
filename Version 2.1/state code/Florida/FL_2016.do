clear all

// Define file paths
global original_files "/Volumes/T7/State Test Project/Florida post-launch/Original Data/FL_OriginalData_1999_2017"
global NCES_files "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global output_files "/Volumes/T7/State Test Project/Florida post-launch/Output"
global temp_files "/Volumes/T7/State Test Project/Florida post-launch/Temp"

// 2015-2016


// Importing and Appending
forvalues i = 3/8 {
	foreach subj in ELA M {
			import excel "$original_files/FL_OriginalData_2016_DistState_`subj'_G0`i'", cellrange(A5) firstrow allstring clear
			gen Subject = "`subj'"
			rename *Level*3* ProficientOrAbove_percent
	save "$temp_files/FL_OriginalData_2016_DistState_`subj'_G0`i'.dta", replace
	}
	
	clear
	append using "$temp_files/FL_OriginalData_2016_DistState_ELA_G0`i'.dta" "$temp_files/FL_OriginalData_2016_DistState_M_G0`i'.dta"
	gen DataLevel = "District"
	replace DataLevel = "State" if DistrictName == "STATE TOTALS"
	gen SchoolNumber = ""
	gen SchoolName = "All Schools"
	rename G Lev1_percent
	rename H Lev2_percent
	rename I Lev3_percent
	rename J Lev4_percent
	rename K Lev5_percent
	save "$temp_files/FL_OriginalData_2016_DistState_MELA_G0`i'.dta", replace
	
	clear
		foreach subj in ELA M {
			import excel "$original_files/FL_OriginalData_2016_School_`subj'_G0`i'", cellrange(A5) firstrow allstring clear
			gen Subject = "`subj'"
			rename *Level*3* ProficientOrAbove_percent
	save "$temp_files/FL_OriginalData_2016_School_`subj'_G0`i'.dta", replace
	}
	
	clear
	append using "$temp_files/FL_OriginalData_2016_School_ELA_G0`i'.dta" "$temp_files/FL_OriginalData_2016_School_M_G0`i'.dta"
	gen DataLevel = "School"
	drop if DistrictName == "STATE TOTALS"
	rename I Lev1_percent
	rename J Lev2_percent
	rename K Lev3_percent
	rename L Lev4_percent
	rename M Lev5_percent
	save "$temp_files/FL_OriginalData_2016_School_MELA_G0`i'.dta", replace
	
	clear
	append using "$temp_files/FL_OriginalData_2016_DistState_MELA_G0`i'.dta" "$temp_files/FL_OriginalData_2016_School_MELA_G0`i'.dta"
	save "$temp_files/FL_OriginalData_2016_All_MELA_G0`i'.dta", replace
}

foreach i in 5 8 {
	import excel "$original_files/FL_OriginalData_2016_DistState_S_G0`i'", cellrange(A9) firstrow allstring clear
	
	keep Grade DistrictNumber DistrictName NumberofStudents MeanScaleScore F G H I J *Percentage*
	drop if DistrictNumber == "Number of Points Possible"
	gen DataLevel = "District"
	replace DataLevel = "State" if DistrictName == "STATE TOTALS"
	gen SchoolNumber = ""
	gen SchoolName = "All Schools"
	rename F Lev1_percent
	rename G Lev2_percent
	rename H Lev3_percent
	rename I Lev4_percent
	rename J Lev5_percent
	rename *Percentage* ProficientOrAbove_percent
	save "$temp_files/FL_OriginalData_2016_DistState_S_G0`i'.dta", replace
	
	import excel "$original_files/FL_OriginalData_2016_School_S_G0`i'", cellrange(A9) firstrow allstring clear
	
	keep Grade DistrictNumber DistrictName SchoolNumber SchoolName NumberofStudents MeanScaleScore H I J K L *Percentage*
	drop if DistrictNumber == "Number of Points Possible"
	gen DataLevel = "School"
	drop if DistrictName == "STATE TOTALS"
	rename H Lev1_percent
	rename I Lev2_percent
	rename J Lev3_percent
	rename K Lev4_percent
	rename L Lev5_percent
	rename *Percentage* ProficientOrAbove_percent
	save "$temp_files/FL_OriginalData_2016_School_S_G0`i'.dta", replace
	
	clear
	append using "$temp_files/FL_OriginalData_2016_DistState_S_G0`i'.dta" "$temp_files/FL_OriginalData_2016_School_S_G0`i'.dta"
	gen Subject = "sci"
	save "$temp_files/FL_OriginalData_2016_All_S_G0`i'.dta", replace
}

clear
append using "$temp_files/FL_OriginalData_2016_All_MELA_G03.dta" "$temp_files/FL_OriginalData_2016_All_MELA_G04.dta" "$temp_files/FL_OriginalData_2016_All_MELA_G05.dta" "$temp_files/FL_OriginalData_2016_All_MELA_G06.dta" "$temp_files/FL_OriginalData_2016_All_MELA_G07.dta" "$temp_files/FL_OriginalData_2016_All_MELA_G08.dta" "$temp_files/FL_OriginalData_2016_All_S_G05.dta" "$temp_files/FL_OriginalData_2016_All_S_G08.dta"
save "$temp_files/FL_OriginalData_2016_All_All_All.dta", replace


use "$temp_files/FL_OriginalData_2016_All_All_All.dta", clear

// Trimming
drop if Grade == ""

// Relabelling Variables
rename DistrictNumber StateAssignedDistID
rename DistrictName DistName
rename Grade GradeLevel
rename NumberofStudents StudentSubGroup_TotalTested
rename MeanScaleScore AvgScaleScore
rename SchoolNumber StateAssignedSchID
rename SchoolName SchName

// Fixing school and district numbers and grades
replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) < 2
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) < 4
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) < 4
replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) < 4
replace StateAssignedSchID = "" if DataLevel != "School"
replace GradeLevel = "0" + GradeLevel if strlen(GradeLevel) < 2

// Transforming Variable Values
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "M"
replace GradeLevel = "G" + GradeLevel

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent {
	destring `var', generate(num`var') force
}

foreach var of varlist numLev1_percent numLev2_percent numLev3_percent numLev4_percent numLev5_percent numProficientOrAbove_percent{
	replace `var' = `var'/100
}

foreach var of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent {
	tostring num`var', replace force
	replace `var' = num`var' if `var' != "*"
	drop num`var'
}

// Generating Missing Variables
gen SchYear = "2015-16"
gen AssmtName = "FSA"
replace AssmtName = "Statewide Science Assessment" if Subject == "sci"
gen AssmtType = "Regular"
gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen ProficiencyCriteria = "Levels 3, 4, 5"
gen ProficientOrAbove_count = "--"
gen ParticipationRate = "--"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "Y"

// Relabelling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

// Generate ID to match NCES
gen seasch = StateAssignedSchID
gen state_leaid = StateAssignedDistID

// Saving Transformed Data
save "$output_files/FL_AssmtData_2016.dta", replace

// Merging with NCES School Data

use "$NCES_files/NCES_2015_School.dta", clear 

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

keep if state_location == "FL"

drop if ncesdistrictid == ""

merge 1:m state_leaid seasch using "${output_files}/FL_AssmtData_2016.dta", keep(match using) 

drop if _merge == 2 & DataLevel == 3
drop _merge

save "$output_files/FL_AssmtData_2016.dta", replace

// Merging with NCES District Data

use "$NCES_files/NCES_2015_District.dta", clear 

keep state_location state_fips district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

keep if state_location == "FL"

merge 1:m state_leaid using "${output_files}/FL_AssmtData_2016.dta", keep(match using) nogenerate

// Renaming NCES variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Florida"
rename county_code CountyCode
*rename school_type SchType
rename state_fips StateFips
rename county_name CountyName

// Fixing State Level Data
replace StateAbbrev = "FL" if DataLevel == 1
replace StateFips = 12 if DataLevel == 1
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2
replace seasch = "" if DataLevel == 1 | DataLevel == 2
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

// Removing commas
replace StudentGroup_TotalTested = subinstr(StudentGroup_TotalTested, ",","",.)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",","",.)

// Fixing Wabasso missing percents
replace Lev1_percent = "*" if Lev1_percent == "."
replace Lev2_percent = "*" if Lev2_percent == "."
replace Lev3_percent = "*" if Lev3_percent == "."
replace Lev4_percent = "*" if Lev4_percent == "."
replace Lev5_percent = "*" if Lev5_percent == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace AvgScaleScore = "*" if AvgScaleScore == ""

//S2024 Changes
gen Flag_CutScoreChange_sci = Flag_CutScoreChange_oth
gen Flag_CutScoreChange_soc = "Not applicable"
replace ProficiencyCriteria = "Levels 3-5"
drop Flag_CutScoreChange_oth Flag_CutScoreChange_read State_leaid seasch

//Reformatting Percents to three Decimal Places
foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	destring `var', gen(n`var') i(*-)
	replace `var' = string(n`var', "%9.3g") if regexm(`var', "[*-]") ==0
	drop n`var'
}

//Updates according to crosswalk
replace Flag_AssmtNameChange = "Y" if Subject == "sci"
replace Flag_CutScoreChange_sci = "N"

//Post Launch Review Response
replace DistName = proper(DistName)
replace SchName = proper(SchName)
replace DistName = "St. Johns" if DistName=="St Johns"
replace DistName = "St. Lucie" if DistName=="St Lucie"
destring StateAssigned*, replace
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if DataLevel !=3
// replace StateAssignedSchID = string(StateAssignedDistID) + "-" + StateAssignedSchID if DataLevel == 3

**Updating CountyName and CountyCode of Select Districts
replace CountyName = "Duval County" if NCESSchoolID == "120008410710" | NCESSchoolID == "120008410711" 
replace CountyName = "Hillsborough County" if NCESSchoolID == "120008410712" | NCESSchoolID == "120008410714"
replace CountyCode = "12031" if NCESSchoolID == "120008410710" | NCESSchoolID == "120008410711" 
replace CountyCode = "12057" if NCESSchoolID == "120008410712" | NCESSchoolID == "120008410714"
replace CountyName = "Hidalgo County" if NCESDistrictID == "1200084" & DataLevel == 2
replace CountyCode = "48215" if NCESDistrictID == "1200084" & DataLevel == 2

//Adding the following code to standardize names across all years, but should be checked for yearly changes
replace DistName = "UF Lab School" if NCESDistrictID == "1202015"
replace DistName = "Miami-Dade" if NCESDistrictID == "1200390"
replace DistName = "FAMU Lab School" if NCESDistrictID == "1202014"
replace DistName = "FSU Lab School" if NCESDistrictID == "1202013"
replace DistName = "FAU Lab School" if NCESDistrictID == "1202012"
replace DistName = "FL Virtual" if NCESDistrictID == "1200002"
replace DistName = "Florida School for the Deaf and the Blind (FSDB)" if NCESDistrictID == "1202016"

//Deriving Counts Where Possible
foreach count of varlist *_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

// Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data

save "${output_files}/FL_AssmtData_2016.dta", replace
export delimited using "$output_files/FL_AssmtData_2016.csv", replace
