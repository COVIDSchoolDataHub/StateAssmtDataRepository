clear all 
set more off

global Abbrev "NJ"
global years 2019 2021 2022 2023
global data "/Users/name/Desktop/New Jersey/Original"
global NCES "/Users/name/Desktop/New Jersey/NCES"
global output "/Users/name/Desktop/New Jersey/Output"

cd "/Users/name/Desktop/New Jersey/"
capture log close
log using 2019_2023_NJ, replace

set trace off

forvalues year = 2019/2023{
	if `year' == 2021 continue
	local prevyear = `year' - 1
	
	//Import Excel Files and Convert to .dta Files
		forvalues n = 3/8{
			if `year' == 2022 & `n' == 3{
				import excel "${data}/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q26162) clear
			}
			else if `year' == 2023 & `n' == 4{
				import excel "${data}/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q25782) clear
			}
			else if `year' == 2023 & `n' == 5{
				import excel "${data}/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q24366) clear
			}
			else if `year' == 2023 & `n' == 6{
				import excel "${data}/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q19447) clear
			}
			else if `year' == 2023 & `n' == 7{
				import excel "${data}/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q17619) clear
			}
			else if `year' == 2023 & `n' == 8{
				import excel "${data}/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q17540) clear
			}
			else{
				import excel "${data}/NJ_OriginalData_`year'_ela_G0`n'", clear
			}			
			gen Subject = "ela"
	
			gen GradeLevel = "G0`n'"

			drop if A == "County Code"

			rename C StateAssignedDistID
			rename D DistName
			rename E StateAssignedSchID
			rename F SchName
			rename G StudentGroup
			rename H StudentSubGroup
			rename L AvgScaleScore
			rename M Lev1_percent
			rename N Lev2_percent
			rename O Lev3_percent
			rename P Lev4_percent
			rename Q Lev5_percent

			save "${data}/NJ_OriginalData_`year'_ela_G0`n'", replace
			
			if `year' == 2023 & `n' == 4 {
				import excel "${data}/NJ_OriginalData_`year'_mat_G0`n'", cellrange (A1:Q25854) clear
			}
			else {
				import excel "${data}/NJ_OriginalData_`year'_mat_G0`n'", clear
			}
			gen Subject = "math"
	
			gen GradeLevel = "G0`n'"

			drop if A == "County Code"

			rename C StateAssignedDistID
			rename D DistName
			rename E StateAssignedSchID
			rename F SchName
			rename G StudentGroup
			rename H StudentSubGroup
			rename L AvgScaleScore
			rename M Lev1_percent
			rename N Lev2_percent
			rename O Lev3_percent
			rename P Lev4_percent
			rename Q Lev5_percent
			save "${data}/NJ_OriginalData_`year'_mat_G0`n'", replace
			
			if inlist(`n', 5, 8){
				import excel "${data}/NJ_OriginalData_`year'_sci_G0`n'", clear
				gen Subject = "sci"
	
				gen GradeLevel = "G0`n'"

				drop if A == "County Code"

				rename C StateAssignedDistID
				rename D DistName
				rename E StateAssignedSchID
				rename F SchName
				rename G StudentGroup
				rename H StudentSubGroup
				rename L AvgScaleScore
				rename M Lev1_percent
				rename N Lev2_percent
				rename O Lev3_percent
				rename P Lev4_percent
				gen Lev5_percent = ""
				save "${data}/NJ_OriginalData_`year'_sci_G0`n'", replace
			}
		}
	

	use "${data}/NJ_OriginalData_`year'_ela_G03", clear
	
	append using "${data}/NJ_OriginalData_`year'_ela_G04" "${data}/NJ_OriginalData_`year'_ela_G05" 	"${data}/NJ_OriginalData_`year'_ela_G06" "${data}/NJ_OriginalData_`year'_ela_G07" "${data}/NJ_OriginalData_`year'_ela_G08"
	
	append using "${data}/NJ_OriginalData_`year'_mat_G03" "${data}/NJ_OriginalData_`year'_mat_G04" "${data}/NJ_OriginalData_`year'_mat_G05" "${data}/NJ_OriginalData_`year'_mat_G06" "${data}/NJ_OriginalData_`year'_mat_G07" "${data}/NJ_OriginalData_`year'_mat_G08"
	append using "${data}/NJ_OriginalData_`year'_sci_G05" "${data}/NJ_OriginalData_`year'_sci_G08"
	save "${data}/NJ_OriginalData_`year'", replace

	//Clean DTA File (Pre-Merge)
	use "${data}/NJ_OriginalData_`year'", clear

	drop if StateAssignedDistID == "DFG Not Designated"
	drop if strupper(DistName) == "DISTRICT NAME"
	drop if AvgScaleScore == ""


	*Data Levels
	gen DataLevel = "School"
	replace DataLevel = "District" if SchName == "" & DistName != ""
	replace DataLevel = "District" if SchName == "District Total"
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
	replace StudentSubGroup = "Ever EL" if strupper(StudentSubGroup) == "ENGLISH LANGUAGE LEARNERS" | strupper(StudentSubGroup) == "ENGLISH LEARNERS"
	replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-Binary/Undesignated"
	
	replace StudentGroup = "RaceEth" if strupper(StudentGroup) == "RACE/ETHNICITY"
	replace StudentGroup = "Gender" if strupper(StudentGroup) == "GENDER"
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "EL Exited")
	replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
	replace StudentGroup = "EL Status" if StudentSubGroup == "Ever EL"
	
	// Generating StudentGroup count
	rename K StudentSubGroup_TotalTested 
	destring StudentSubGroup_TotalTested, replace force
	gen StateAssignedDistID1 = StateAssignedDistID
	replace StateAssignedDistID1 = "000000" if DataLevel == "State" //Remove quotations if DistIDs are numeric
	gen StateAssignedSchID1 = StateAssignedSchID
	replace StateAssignedSchID1 = "000000" if DataLevel != "School" //Remove quotations if SchIDs are numeric
	egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
	sort group_id StudentGroup StudentSubGroup
	by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if StudentSubGroup != "All Students"
	by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
	drop group_id StateAssignedDistID1 StateAssignedSchID1
	tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace 
	
	*Generate Additional Variables
	gen SchYear = "`prevyear'-`year'"
	replace SchYear = substr(SchYear, 1, 5) + substr(SchYear, 8, 9)
	gen AssmtName = "NJSLA"
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_sci = "N"
	gen Flag_CutScoreChange_soc = "Not applicable"
	gen AssmtType = "Regular"
	gen ProficiencyCriteria = "Levels 4-5"
	replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
	gen ParticipationRate = "--"
	gen K = StudentSubGroup_TotalTested
	destring K, replace force
	
	if `year' == 2019{
		replace Flag_AssmtNameChange = "Y"
		replace Flag_CutScoreChange_sci = "Y"
	}
	
	*Fixing Counts and Percents
	forvalues x = 1/5{
		destring Lev`x'_percent, gen(Level`x') force
		replace Level`x' = Level`x'/100
		gen Lev`x'_count = K * Level`x'
		replace Lev`x'_count = . if Lev`x'_count < 0
		replace Lev`x'_count = . if Lev`x'_percent == "*"
	}
	
	gen ProficientOrAbove_percent = Level4 + Level5
	replace ProficientOrAbove_percent = Level3 + Level4 if Subject == "sci"
	gen ProficientOrAbove_count = K * ProficientOrAbove_percent
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
	replace Lev5_percent = "" if Subject == "sci"
	replace Lev5_count = "" if Subject == "sci"

	tostring ProficientOrAbove_percent, replace format("%10.3g") force
	replace ProficientOrAbove_count = round(ProficientOrAbove_count)
	tostring ProficientOrAbove_count, replace
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

	drop K

	save "${data}/NJ_OriginalData_`year'", replace

	//Clean NCES Data
	if `year' < 2022{
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
	if `year' == 2022{
		use "${NCES}/NCES_`prevyear'_School.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 10)
		gen str StateAssignedSchID = substr(seasch, 8, 11)
		save "${NCES}/NCES_`prevyear'_School_NJ.dta", replace

		use "${NCES}/NCES_`prevyear'_District.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 10)
		save "${NCES}/NCES_`prevyear'_District_NJ.dta", replace
	}
	
	if `year' == 2023{
		use "${NCES}/NCES_`prevyear'_School.dta", clear
		drop if state_location != "NJ"
		rename state_fips_id state_fips
		rename lea_name DistName
		gen str StateAssignedDistID = substr(state_leaid, 6, 9)
		gen str StateAssignedSchID = substr(seasch, 8, 10)
		destring StateAssignedDistID, replace force
		drop if StateAssignedDistID==.
		destring StateAssignedSchID, replace force
		drop if StateAssignedSchID==.
		rename school_type SchType
		rename school_name SchName
		decode district_agency_type, gen (district_agency_type_s)
		drop district_agency_type
		rename district_agency_type_s district_agency_type
		merge 1:1 ncesdistrictid ncesschoolid using "${NCES}/NCES_2021_School_NJ.dta", keepusing (DistLocale county_code county_name district_agency_type SchVirtual)
		drop if _merge == 2
		drop _merge
		keep ncesdistrictid ncesschoolid StateAssignedDistID StateAssignedSchID district_agency_type DistLocale county_code county_name DistCharter SchType SchLevel SchVirtual
		save "${NCES}/NCES_`prevyear'_School_NJ.dta", replace
		
		use "${NCES}/NCES_`prevyear'_District.dta", clear
		drop if state_location != "NJ"
		rename lea_name DistName
		gen str StateAssignedDistID = substr(state_leaid, 6, 9)
		destring StateAssignedDistID, replace force
		drop if StateAssignedDistID==.
		drop year
		merge 1:1 ncesdistrictid using "${NCES}/NCES_2021_District_NJ.dta", keepusing (DistLocale county_code county_name DistCharter)
		drop if _merge == 2
		drop _merge
		save "${NCES}/NCES_`prevyear'_District_NJ.dta", replace
	}

	//Merge Data
	use "/Users/mikaeloberlin/Desktop/New Jersey/Original/NJ_OriginalData_`year'.dta", clear
	if `year' == 2023{
		destring StateAssignedDistID, replace force
		destring StateAssignedSchID, replace force
	}
	merge m:1 StateAssignedDistID using "${NCES}/NCES_`prevyear'_District_NJ.dta"
	drop if _merge == 2

	merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES}/NCES_`prevyear'_School_NJ.dta", gen (merge2)
	drop if merge2 == 2

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

	*Variable Types
	if `year' != 2023{
		decode SchVirtual, gen(SchVirtual_s)
		drop SchVirtual
		rename SchVirtual_s SchVirtual

		decode SchLevel, gen(SchLevel_s)
		drop SchLevel
		rename SchLevel_s SchLevel

		decode SchType, gen (SchType_s)
		drop SchType
		rename SchType_s SchType
	}
	
	//Removing extra spaces
	foreach var of varlist DistName SchName {
		replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
		replace `var' = strtrim(`var') // removes leading and trailing blanks
	}
	
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == ""
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == ""
	drop if StudentSubGroup_TotalTested == ""
	drop if StudentGroup_TotalTested == ""
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
	replace StudentGroup_TotalTested = "*" if missing(StudentGroup_TotalTested)
	replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	drop if StudentGroup_TotalTested == "."
	replace Lev5_count = "*" if missing(Lev5_count)
	replace Lev5_percent = "*" if missing(Lev5_percent)
	duplicates drop DataLevel AssmtName AssmtType NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup, force
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel
	
//Organize Variables

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	save "${output}/NJ_AssmtData_`year'", replace
	export delimited "${output}/NJ_AssmtData_`year'", replace
	clear
}