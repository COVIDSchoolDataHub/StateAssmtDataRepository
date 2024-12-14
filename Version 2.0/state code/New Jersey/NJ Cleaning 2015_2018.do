//Name: New Jersey Re-cleaning State Assessment
//purpose: Cleaning NJ State Assessment Data
//author: Mikael Oberlin
//date created: 12/02/24

clear all 
set more off

global Abbrev "NJ"
global years 2015 2016 2017 2018
global data "/Users/mikaeloberlin/Desktop/New Jersey/Original"
global NCES "/Users/mikaeloberlin/Desktop/New Jersey/NCES"
global output "/Users/mikaeloberlin/Desktop/New Jersey/Output"

cd "/Users/mikaeloberlin/Desktop/New Jersey/"
capture log close
log using 2015_2018_NJ, replace
set trace off

forvalues year = 2015/2018{
	local prevyear = `year' - 1
	
	//Import Excel Files and Convert to .dta Files
	local subject "ela mat"
	foreach s of local subject{
		forvalues n = 3/8{
			import excel "${data}/NJ_OriginalData_`year'_`s'_G0`n'", clear
			gen Subject = "`s'"
	
			gen GradeLevel = "G0`n'"

			drop if A == "DFG"

			drop A B G J K
			rename C StateAssignedDistID
			rename D DistName
			rename E StateAssignedSchID
			rename F SchName
			rename H StudentGroup
			rename I StudentSubGroup
			rename M AvgScaleScore
			rename N Lev1_percent
			rename O Lev2_percent
			rename P Lev3_percent
			rename Q Lev4_percent
			rename R Lev5_percent
			save "${data}/NJ_OriginalData_`year'_`s'_G0`n'", replace
		}
	}
	
use "${data}/NJ_OriginalData_`year'_ela_G03", clear
	
	append using "${data}/NJ_OriginalData_`year'_ela_G04" "${data}/NJ_OriginalData_`year'_ela_G05" 	"${data}/NJ_OriginalData_`year'_ela_G06" "${data}/NJ_OriginalData_`year'_ela_G07" "${data}/NJ_OriginalData_`year'_ela_G08"
	
	append using "${data}/NJ_OriginalData_`year'_mat_G03" "${data}/NJ_OriginalData_`year'_mat_G04" "${data}/NJ_OriginalData_`year'_mat_G05" "${data}/NJ_OriginalData_`year'_mat_G06" "${data}/NJ_OriginalData_`year'_mat_G07" "${data}/NJ_OriginalData_`year'_mat_G08"
	save "${data}/NJ_OriginalData_`year'", replace

	save "${data}/NJ_OriginalData_`year'", replace

	//Clean DTA File (Pre-Merge)
	use "${data}/NJ_OriginalData_`year'", clear
	replace Subject = "math" if Subject == "mat"

	drop if StateAssignedDistID == "DFG Not Designated"
	drop if strupper(DistName) == "DISTRICT NAME"
	drop if AvgScaleScore == ""

	*Data Levels
	gen DataLevel = "School"
	replace DataLevel = "District" if SchName == "" & DistName != ""
	replace DataLevel = "State" if SchName == "" & DistName == ""

	replace SchName = "All Schools" if DataLevel != "School"
	replace DistName = "All Districts" if DataLevel == "State"
	replace StateAssignedSchID = "" if DataLevel != "School"
	replace StateAssignedDistID = "" if DataLevel == "State"

	*Student Groups, SubGroups, & Counts
	drop if strupper(StudentSubGroup) == "SE ACCOMMODATION"

	replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL STUDENTS"
	replace StudentSubGroup = "American Indian or Alaska Native" if strupper(StudentSubGroup) == "AMERICAN INDIAN"
	replace StudentSubGroup = "Asian" if StudentSubGroup == "ASIAN"
	replace StudentSubGroup = "Black or African American" if strupper(StudentSubGroup) == "AFRICAN AMERICAN"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if inlist(StudentSubGroup, "NATIVE HAWAIIAN", "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER", "Native Hawaiian")
	replace StudentSubGroup = "White" if StudentSubGroup == "WHITE"
	replace StudentSubGroup = "Hispanic or Latino" if strupper(StudentSubGroup) == "HISPANIC"
	replace StudentSubGroup = "Unknown" if strupper(StudentSubGroup) == "OTHER"
	replace StudentSubGroup = "Male" if StudentSubGroup == "MALE"
	replace StudentSubGroup = "Female" if StudentSubGroup == "FEMALE"
	replace StudentSubGroup = "SWD" if strupper(StudentSubGroup) == "STUDENTS WITH DISABILITIES" | StudentSubGroup == "STUDENTS WITH DISABLITIES"
	replace StudentSubGroup = "English Learner" if strupper(StudentSubGroup) == "CURRENT - ELL"
	replace StudentSubGroup = "Economically Disadvantaged" if strupper(StudentSubGroup) == "ECONOMICALLY DISADVANTAGED"
	replace StudentSubGroup = "Not Economically Disadvantaged" if strupper(StudentSubGroup) == "NON-ECON. DISADVANTAGED" |StudentSubGroup == "NON ECON. DISADVANTAGED"
	replace StudentSubGroup = "EL Exited" if strupper(StudentSubGroup) == "FORMER - ELL"
	replace StudentSubGroup = "Ever EL" if strupper(StudentSubGroup) == "ENGLISH LANGUAGE LEARNERS"
	
	replace StudentGroup = "RaceEth" if strupper(StudentGroup) == "RACE/ETHNICITY"
	replace StudentGroup = "Gender" if strupper(StudentGroup) == "GENDER"
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "EL Exited")
	replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
	replace StudentGroup = "EL Status" if StudentSubGroup == "Ever EL"
	

	// Generating StudentGroup count
	gen StudentSubGroup_TotalTested = L
	destring L, replace force
	gen StateAssignedDistID1 = StateAssignedDistID
	replace StateAssignedDistID1 = "000000" if DataLevel == "State" //Remove quotations if DistIDs are numeric
	gen StateAssignedSchID1 = StateAssignedSchID
	replace StateAssignedSchID1 = "000000" if DataLevel != "School" //Remove quotations if SchIDs are numeric
	egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
	sort group_id StudentGroup StudentSubGroup
	by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
	drop group_id StateAssignedDistID1 StateAssignedSchID1
	tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace 
	drop if StudentGroup_TotalTested == "." & StudentSubGroup_TotalTested == "."
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == ""
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == ""
	drop if StudentSubGroup_TotalTested == ""
	drop if StudentGroup_TotalTested == ""

	*Generate Additional Variables
	gen SchYear = "`prevyear'-`year'"
	replace SchYear = substr(SchYear, 1, 5) + substr(SchYear, 8, 9)
	gen AssmtName = "PARCC"
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_sci = "Not applicable"
	gen Flag_CutScoreChange_soc = "Not applicable"
	gen AssmtType = "Regular"
	gen ProficiencyCriteria = "Levels 4-5"
	gen ParticipationRate = "--"
	
	if `year' == 2015{
		replace Flag_AssmtNameChange = "Y"
		replace Flag_CutScoreChange_ELA = "Y"
		replace Flag_CutScoreChange_math = "Y"
	}

	*Fixing Counts and Percents
	forvalues x = 1/5{
		destring Lev`x'_percent, gen(Level`x') force
		replace Level`x' = Level`x'/100
		gen Lev`x'_count = L * Level`x'
		replace Lev`x'_count = . if Lev`x'_count < 0
		replace Lev`x'_count = . if Lev`x'_percent == "*"
	}

	gen ProficientOrAbove_percent = Level4 + Level5
	gen ProficientOrAbove_count = L * ProficientOrAbove_percent
	replace ProficientOrAbove_count = . if ProficientOrAbove_count < 0
	replace ProficientOrAbove_count = . if ProficientOrAbove_percent == .

	forvalues x = 1/5{
		tostring Level`x', replace format("%10.0g") force
		replace Lev`x'_percent = Level`x' if Lev`x'_percent != "*"
		replace Lev`x'_count = round(Lev`x'_count)
		tostring Lev`x'_count, replace
		replace Lev`x'_count = "*" if Lev`x'_count == "."
		drop Level`x'
	}
	tostring ProficientOrAbove_percent, replace format("%10.3g") force
	replace ProficientOrAbove_count = round(ProficientOrAbove_count)
	tostring ProficientOrAbove_count, replace
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	drop L

	save "${data}/NJ_OriginalData_`year'", replace

	//Clean NCES Data
	if `year' < 2017{
		use "${NCES}/NCES_`prevyear'_School.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 3, 6)
		gen StateAssignedSchID = seasch
		save "${NCES}/NCES_`prevyear'_School_NJ.dta", replace

		use "${NCES}/NCES_`prevyear'_District.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 3, 6)
		save "${NCES}/NCES_`prevyear'_District_NJ.dta", replace
	}
	if `year' >= 2017{
		use "${NCES}/NCES_`prevyear'_School.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 8)
		gen str StateAssignedSchID = substr(seasch, 8, 10)
		save "${NCES}/NCES_`prevyear'_School_NJ.dta", replace

		use "${NCES}/NCES_`prevyear'_District.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 8)
		save "${NCES}/NCES_`prevyear'_District_NJ.dta", replace
	}

	//Merge Data
	use "${data}/NJ_OriginalData_`year'", clear
	merge m:1 StateAssignedDistID using "${NCES}/NCES_`prevyear'_District_NJ.dta"

	merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/NCES_`prevyear'_School_NJ.dta", gen (merge2)

	//Clean Merged Data
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename ncesschoolid NCESSchoolID
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode

	replace State = "New Jersey"
	replace StateAbbrev = "NJ"
	replace StateFips = 34
	
	if `year' == 2015{
		replace CountyName = strproper(CountyName)
	}

	*Variable Types
	decode SchVirtual, gen(SchVirtual_s)
	drop SchVirtual
	rename SchVirtual_s SchVirtual

	decode SchLevel, gen(SchLevel_s)
	drop SchLevel
	rename SchLevel_s SchLevel

	decode SchType, gen (SchType_s)
	drop SchType
	rename SchType_s SchType

	*Unmerged Schools
	replace NCESSchoolID = "340077203313" if SchName == "MASTERY SCHOOLS OF CAMDEN" & NCESSchoolID == ""
	replace SchType = "Regular school" if SchName == "MASTERY SCHOOLS OF CAMDEN" & SchType == ""
	replace SchLevel = "Other" if SchName == "MASTERY SCHOOLS OF CAMDEN" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "MASTERY SCHOOLS OF CAMDEN" & SchVirtual == ""
	
	replace NCESSchoolID = "341269003369" if SchName == "SINGLE GENDER ACADEMY" & NCESSchoolID == ""
	replace SchType = "Regular school" if SchName == "SINGLE GENDER ACADEMY" & SchType == ""
	replace SchLevel = "Primary" if SchName == "SINGLE GENDER ACADEMY" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "SINGLE GENDER ACADEMY" & SchVirtual == ""
	
	replace NCESDistrictID = "3400772" if DistName == "MASTERY SCHOOLS OF CAMDEN" & NCESDistrictID == ""
	replace DistType = "Regular local school district" if DistName == "MASTERY SCHOOLS OF CAMDEN" & DistType == ""
	replace DistCharter = "No" if DistName == "MASTERY SCHOOLS OF CAMDEN" & DistCharter == ""
	replace DistLocale = "City, small" if DistName == "MASTERY SCHOOLS OF CAMDEN" & DistLocale == ""
	replace CountyName = "Camden County" if DistName == "MASTERY SCHOOLS OF CAMDEN" & CountyName == ""
	replace CountyCode = "34007" if DistName == "MASTERY SCHOOLS OF CAMDEN" & CountyCode == ""
	
		//Removing extra spaces
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
	replace `var' = strtrim(`var') // removes leading and trailing blanks
	replace `var' = lower(`var')
	replace `var' = proper(`var')
}

	drop if missing(SchYear)
	drop if missing(DistName) & missing(SchName)
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	drop if StudentGroup_TotalTested == "."
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel
	
	//Organize Variables
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	save "${data}/NJ_AssmtData_`year'", replace
	export delimited "${data}/NJ_AssmtData_`year'", replace
	clear
}
