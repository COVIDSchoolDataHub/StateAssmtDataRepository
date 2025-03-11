* NEW JERSEY

* File name: NJ_2024
* Last update: 03/10/2025

*******************************************************
* Notes [EDIT]

	* This do file imports *.csv files for NJ for 2024.
	* These files are saved as *.dta.
	* The *.dta files are combined. 
	* Variables are renamed and the file is saved.
	* A breakpoint is created before any derivations and NCES Merging. 
	* NCES 2021 and 2022 are merged. 
	* This do file will need to be updated when NCES_2023 is available.
	* The usual and non-derivation output are created. 
	
*******************************************************
clear all 

global Abbrev "NJ"
global year 2024

capture log close
log using 2024_NJ, replace

local year 2024
	//Import Excel Files and Convert to .dta Files
		forvalues n = 3/8{
			if `n' == 3{
				import excel "${Original}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q26266) clear
			}
			else if `n' == 4{
				import excel "${Original}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q25702) clear
			}
			else if `n' == 5{
				import excel "${Original}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q24326) clear
			}
			else if `n' == 6{
				import excel "${Original}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q17448) clear
			}
			else if `n' == 7{
				import excel "${Original}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q17702) clear
			}
			else if `n' == 8{
				import excel "${Original}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q17482) clear
			}
			else{
				import excel "${Original}/`year'/NJ_OriginalData_`year'_ela_G0`n'", clear
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
			gen State_leaid = A + StateAssignedDistID

			save "${Original_DTA}/NJ_OriginalData_`year'_ela_G0`n'", replace
			
			if `n' == 4 {
				import excel "${Original}/`year'/NJ_OriginalData_`year'_math_G0`n'", cellrange (A1:Q25779) clear
			}
			else {
				import excel "${Original}/`year'/NJ_OriginalData_`year'_math_G0`n'", clear
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
			gen State_leaid = A + StateAssignedDistID
			
			save "${Original_DTA}/NJ_OriginalData_`year'_math_G0`n'", replace
			
			if inlist(`n', 5, 8){
				import excel "${Original}/`year'/NJ_OriginalData_`year'_sci_G0`n'", clear
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
				gen State_leaid = A + StateAssignedDistID
				
				save "${Original_DTA}/NJ_OriginalData_`year'_sci_G0`n'", replace
			}
		}
	

use "${Original_DTA}/NJ_OriginalData_`year'_ela_G03", clear
	
	append using "${Original_DTA}/NJ_OriginalData_`year'_ela_G04" ///
				"${Original_DTA}/NJ_OriginalData_`year'_ela_G05" ///
				"${Original_DTA}/NJ_OriginalData_`year'_ela_G06" ///
				"${Original_DTA}/NJ_OriginalData_`year'_ela_G07" ///
				"${Original_DTA}/NJ_OriginalData_`year'_ela_G08"
	
	append using "${Original_DTA}/NJ_OriginalData_`year'_math_G03" ///
				"${Original_DTA}/NJ_OriginalData_`year'_math_G04" ///
				"${Original_DTA}/NJ_OriginalData_`year'_math_G05" ///
				"${Original_DTA}/NJ_OriginalData_`year'_math_G06" ///
				"${Original_DTA}/NJ_OriginalData_`year'_math_G07" ///
				"${Original_DTA}/NJ_OriginalData_`year'_math_G08"
				
	append using "${Original_DTA}/NJ_OriginalData_`year'_sci_G05" ///
				"${Original_DTA}/NJ_OriginalData_`year'_sci_G08"
	
	save "${Original_DTA}/NJ_OriginalData_`year'", replace

	//Clean DTA File (Pre-Merge)
	use "${Original_DTA}/NJ_OriginalData_`year'", clear

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
	drop if StudentSubGroup == "SE Accommodation"

	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if inlist(StudentSubGroup, "Native Hawaiian or other Pacific Islander", "Native Hawaiian")
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Unknown" if StudentSubGroup == "Other"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "Current - Ml" 
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged" 
	replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Econ. Disadvantaged" 
	replace StudentSubGroup = "EL Exited" if StudentSubGroup == "Former - Ml" 
	replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Multilingual Learners"
	replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-Binary/Undesignated"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "Students With Disabilities"

	replace StudentGroup = "RaceEth" if StudentGroup ==  "Race/Ethnicity"
	replace StudentGroup = "Gender" if StudentGroup == "Gender"
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "Ever EL", "English Learner", "EL Exited")
	replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
	
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
	by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
	by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if inlist(StudentGroup, "EL Status")
	drop group_id StateAssignedDistID1 StateAssignedSchID1
	tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace 
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "."

	*Generate Additional Variables
	gen SchYear = "2023-2024"
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
	
*******************************************************
// Creating a Breakpoint - to restore for non-derivation data processing
*******************************************************
save "$Temp/NJ_`year'_Breakpoint",replace

******************************
//Derivations
******************************
//Fixing Counts and Percents
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

	save "${Temp}/NJ_OriginalData_`year'", replace

		use "${NCES_School}/NCES_2022_School.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 8)
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
		merge 1:1 ncesdistrictid ncesschoolid using "${NCES_NJ}/NCES_2021_School_NJ.dta", keepusing (DistLocale county_code county_name district_agency_type SchVirtual)
		drop if _merge == 2
		drop _merge
		keep ncesdistrictid ncesschoolid StateAssignedDistID StateAssignedSchID district_agency_type DistLocale county_code county_name DistCharter SchType SchLevel SchVirtual
		save "${NCES_NJ}/NCES_2024_School_NJ.dta", replace

		use "${NCES_District}/NCES_2022_District.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 8)
		drop if state_location != "NJ"
		rename lea_name DistName
		destring StateAssignedDistID, replace force
		drop if StateAssignedDistID==.
		drop year
		merge 1:1 ncesdistrictid using "${NCES_NJ}/NCES_2021_District_NJ.dta", keepusing (DistLocale county_code county_name DistCharter)
		drop if _merge == 2
		drop _merge
		save "${NCES_NJ}/NCES_2024_District_NJ.dta", replace

	//Merge Data
	use "${Temp}/NJ_OriginalData_2024.dta", clear
		destring StateAssignedDistID, replace force
		destring StateAssignedSchID, replace force
	merge m:1 StateAssignedDistID using "${NCES_NJ}/NCES_2024_District_NJ.dta"
	drop if _merge == 2

	merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES_NJ}/NCES_2024_School_NJ.dta", gen (merge2)
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
		decode SchVirtual, gen(SchVirtual_s)
		drop SchVirtual
		rename SchVirtual_s SchVirtual

		decode SchLevel, gen(SchLevel_s)
		drop SchLevel
		rename SchLevel_s SchLevel

		decode SchType, gen (SchType_s)
		drop SchType
		rename SchType_s SchType
	
	replace SchType = "Regular school" if SchName == "People'S Achieve Community Charter School"
	replace SchLevel = "Other" if SchName == "People'S Achieve Community Charter School" 
	replace SchVirtual = "No" if SchName == "People'S Achieve Community Charter School"
	replace NCESDistrictID = "3480365" if SchName == "People'S Achieve Community Charter School"
	replace NCESSchoolID = "348036506160" if SchName == "People'S Achieve Community Charter School" & DataLevel == "School" 
	replace CountyCode = "34013" if SchName == "People'S Achieve Community Charter School"
	replace CountyName = "Essex County" if SchName == "People'S Achieve Community Charter School"
	replace DistLocale = "City, large" if SchName == "People'S Achieve Community Charter School" 
	replace DistType = "Charter agency" if SchName == "People'S Achieve Community Charter School" 
	replace DistCharter = "Yes" if SchName == "People'S Achieve Community Charter School" 
	
	
	replace NCESDistrictID = "3480365" if DistName == "People'S Achieve Community Charter School"
	replace CountyCode = "34013" if DistName == "People'S Achieve Community Charter School"
	replace CountyName = "Essex County" if DistName == "People'S Achieve Community Charter School"
	replace DistLocale = "City, large" if DistName == "People'S Achieve Community Charter School" 
	replace DistType = "Charter agency" if DistName == "People'S Achieve Community Charter School" 
	replace DistCharter = "Yes" if DistName == "People'S Achieve Community Charter School" 
	replace NCESSchoolID = "" if DistName == "People'S Achieve Community Charter School" & DataLevel == "District"
	
	replace SchType = "Regular school" if SchName == "Brilla New Jersey Charter School" & SchType == ""
	replace SchLevel = "Primary" if SchName == "Brilla New Jersey Charter School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Brilla New Jersey Charter School" & SchVirtual == ""
	replace NCESDistrictID = "3480367" if SchName == "Brilla New Jersey Charter School" & NCESDistrictID == ""
	replace NCESSchoolID =  "348036706171" if SchName == "Brilla New Jersey Charter School" & NCESSchoolID == ""
	replace CountyCode = "34031" if SchName == "Brilla New Jersey Charter School" & CountyCode == ""
	replace CountyName = "Passaic County" if SchName == "Brilla New Jersey Charter School" & CountyName == ""
	replace DistLocale = "Suburb, large" if SchName == "Brilla New Jersey Charter School" & DistLocale == ""
	replace DistType = "Charter agency" if SchName == "Brilla New Jersey Charter School" & DistType == ""
	replace DistCharter = "Yes" if SchName == "Brilla New Jersey Charter School" & DistCharter == ""
	
	replace NCESDistrictID = "3480367" if DistName == "Brilla New Jersey Charter School"
	replace CountyCode = "34031" if DistName == "Brilla New Jersey Charter School"
	replace CountyName = "Passaic County" if DistName == "Brilla New Jersey Charter School"
	replace DistLocale = "Suburb, large" if DistName == "Brilla New Jersey Charter School"
	replace DistType = "Charter agency" if DistName == "Brilla New Jersey Charter School"
	replace DistCharter = "Yes" if DistName == "Brilla New Jersey Charter School"
	replace NCESSchoolID = "" if DistName == "Brilla New Jersey Charter School" & DataLevel == "District"
	
	replace SchType = "Regular school" if SchName == "Charles And Anna Booker Elementary School" & SchType == ""
	replace SchLevel = "Primary" if SchName == "Charles And Anna Booker Elementary School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Charles And Anna Booker Elementary School" & SchVirtual == ""
	replace NCESSchoolID =  "341314005630" if SchName == "Charles And Anna Booker Elementary School" & NCESSchoolID == ""
	
	replace SchType = "Regular school" if SchName == "Pitman Elementary School" & SchType == ""
	replace SchLevel = "Primary" if SchName == "Pitman Elementary School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Pitman Elementary School" & SchVirtual == ""
	replace NCESSchoolID =  "341308006155" if SchName == "Pitman Elementary School" & NCESSchoolID == ""
	
	replace SchType = "Regular school" if SchName == "Prospect Park School Number Two/ Middle School" & SchType == ""
	replace SchLevel = "Middle" if SchName == "Prospect Park School Number Two/ Middle School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Prospect Park School Number Two/ Middle School" & SchVirtual == ""
	replace NCESSchoolID =  "341347006159" if SchName == "Prospect Park School Number Two/ Middle School" & NCESSchoolID == ""
	
	//Removing extra 
	foreach var of varlist DistName SchName {
		replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
		replace `var' = strtrim(`var') // removes leading and trailing blanks
	}
	
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == ""
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == ""
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
	replace StudentGroup_TotalTested = "*" if missing(StudentGroup_TotalTested)
	replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	drop if StudentGroup_TotalTested == "."
	
	duplicates drop DataLevel AssmtName AssmtType NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup, force
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel
	
//Organize Variables

//Cleaning and dropping extra variables
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars' State_leaid
	order `vars' State_leaid
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting output for 2024
replace State_leaid = "" if DataLevel == 1
save "${Output_HMH}/NJ_AssmtData_`year'_HMH", replace
export delimited "${Output_HMH}/NJ_AssmtData_`year'_HMH", replace
forvalues n = 1/3 {
		preserve
		keep if DataLevel == `n'
		if `n' == 1{
			export excel "${Output_HMH}/NJ_AssmtData_`year'_HMH.xlsx", sheet("State") sheetreplace firstrow(variables)
		}
		if `n' == 2{
			export excel "${Output_HMH}/NJ_AssmtData_`year'_HMH.xlsx", sheet("District") sheetreplace firstrow(variables)
		}
		if `n' == 3{
			export excel "${Output_HMH}/NJ_AssmtData_`year'_HMH.xlsx", sheet("School") sheetreplace firstrow(variables)
		}
		restore
	}
drop State_leaid //remove alternate ID for non-HMH output
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${Output}/NJ_AssmtData_`year'", replace
export delimited "${Output}/NJ_AssmtData_`year'", replace
clear

******************************
// Creating the non-derivation output
******************************
*Restoring the breakpoint
use "$Temp/NJ_`year'_Breakpoint", clear

******************************
//Derivations - Deleting code that replaces counts calculated using a percentage * SSGT
******************************
//Fixing Counts and Percents
	forvalues x = 1/5{
		destring Lev`x'_percent, gen(Level`x') force
		replace Level`x' = Level`x'/100
		gen Lev`x'_count = "--"'
	}

	gen ProficientOrAbove_percent = Level4 + Level5
	replace ProficientOrAbove_percent = Level3 + Level4 if Subject == "sci"
	gen ProficientOrAbove_count = "--"'

	forvalues x = 1/5{
		tostring Level`x', replace format("%10.0g") force
		replace Lev`x'_percent = Level`x' if Lev`x'_percent != "*"
		drop Level`x'
	}
	replace Lev5_percent = "" if Subject == "sci"
	replace Lev5_count = "" if Subject == "sci"

	tostring ProficientOrAbove_percent, replace format("%10.3g") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	drop K

	save "${Temp}/NJ_OriginalData_`year'_ND", replace

	//Merge Data
	use "${Temp}/NJ_OriginalData_`year'_ND.dta", clear
		destring StateAssignedDistID, replace force
		destring StateAssignedSchID, replace force
	merge m:1 StateAssignedDistID using "${NCES_NJ}/NCES_2024_District_NJ.dta"
	drop if _merge == 2

	merge m:1 StateAssignedSchID StateAssignedDistID using "${NCES_NJ}/NCES_2024_School_NJ.dta", gen (merge2)
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
		decode SchVirtual, gen(SchVirtual_s)
		drop SchVirtual
		rename SchVirtual_s SchVirtual

		decode SchLevel, gen(SchLevel_s)
		drop SchLevel
		rename SchLevel_s SchLevel

		decode SchType, gen (SchType_s)
		drop SchType
		rename SchType_s SchType
	
	replace SchType = "Regular school" if SchName == "People'S Achieve Community Charter School"
	replace SchLevel = "Other" if SchName == "People'S Achieve Community Charter School" 
	replace SchVirtual = "No" if SchName == "People'S Achieve Community Charter School"
	replace NCESDistrictID = "3480365" if SchName == "People'S Achieve Community Charter School"
	replace NCESSchoolID = "348036506160" if SchName == "People'S Achieve Community Charter School" & DataLevel == "School" 
	replace CountyCode = "34013" if SchName == "People'S Achieve Community Charter School"
	replace CountyName = "Essex County" if SchName == "People'S Achieve Community Charter School"
	replace DistLocale = "City, large" if SchName == "People'S Achieve Community Charter School" 
	replace DistType = "Charter agency" if SchName == "People'S Achieve Community Charter School" 
	replace DistCharter = "Yes" if SchName == "People'S Achieve Community Charter School" 
	
	
	replace NCESDistrictID = "3480365" if DistName == "People'S Achieve Community Charter School"
	replace CountyCode = "34013" if DistName == "People'S Achieve Community Charter School"
	replace CountyName = "Essex County" if DistName == "People'S Achieve Community Charter School"
	replace DistLocale = "City, large" if DistName == "People'S Achieve Community Charter School" 
	replace DistType = "Charter agency" if DistName == "People'S Achieve Community Charter School" 
	replace DistCharter = "Yes" if DistName == "People'S Achieve Community Charter School" 
	replace NCESSchoolID = "" if DistName == "People'S Achieve Community Charter School" & DataLevel == "District"
	
	replace SchType = "Regular school" if SchName == "Brilla New Jersey Charter School" & SchType == ""
	replace SchLevel = "Primary" if SchName == "Brilla New Jersey Charter School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Brilla New Jersey Charter School" & SchVirtual == ""
	replace NCESDistrictID = "3480367" if SchName == "Brilla New Jersey Charter School" & NCESDistrictID == ""
	replace NCESSchoolID =  "348036706171" if SchName == "Brilla New Jersey Charter School" & NCESSchoolID == ""
	replace CountyCode = "34031" if SchName == "Brilla New Jersey Charter School" & CountyCode == ""
	replace CountyName = "Passaic County" if SchName == "Brilla New Jersey Charter School" & CountyName == ""
	replace DistLocale = "Suburb, large" if SchName == "Brilla New Jersey Charter School" & DistLocale == ""
	replace DistType = "Charter agency" if SchName == "Brilla New Jersey Charter School" & DistType == ""
	replace DistCharter = "Yes" if SchName == "Brilla New Jersey Charter School" & DistCharter == ""
	
	replace NCESDistrictID = "3480367" if DistName == "Brilla New Jersey Charter School"
	replace CountyCode = "34031" if DistName == "Brilla New Jersey Charter School"
	replace CountyName = "Passaic County" if DistName == "Brilla New Jersey Charter School"
	replace DistLocale = "Suburb, large" if DistName == "Brilla New Jersey Charter School"
	replace DistType = "Charter agency" if DistName == "Brilla New Jersey Charter School"
	replace DistCharter = "Yes" if DistName == "Brilla New Jersey Charter School"
	replace NCESSchoolID = "" if DistName == "Brilla New Jersey Charter School" & DataLevel == "District"
	
	replace SchType = "Regular school" if SchName == "Charles And Anna Booker Elementary School" & SchType == ""
	replace SchLevel = "Primary" if SchName == "Charles And Anna Booker Elementary School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Charles And Anna Booker Elementary School" & SchVirtual == ""
	replace NCESSchoolID =  "341314005630" if SchName == "Charles And Anna Booker Elementary School" & NCESSchoolID == ""
	
	replace SchType = "Regular school" if SchName == "Pitman Elementary School" & SchType == ""
	replace SchLevel = "Primary" if SchName == "Pitman Elementary School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Pitman Elementary School" & SchVirtual == ""
	replace NCESSchoolID =  "341308006155" if SchName == "Pitman Elementary School" & NCESSchoolID == ""
	
	replace SchType = "Regular school" if SchName == "Prospect Park School Number Two/ Middle School" & SchType == ""
	replace SchLevel = "Middle" if SchName == "Prospect Park School Number Two/ Middle School" & SchLevel == ""
	replace SchVirtual = "No" if SchName == "Prospect Park School Number Two/ Middle School" & SchVirtual == ""
	replace NCESSchoolID =  "341347006159" if SchName == "Prospect Park School Number Two/ Middle School" & NCESSchoolID == ""
	
	//Removing extra 
	foreach var of varlist DistName SchName {
		replace `var' = stritrim(`var') // collapses all consecutive, internal blanks to one blank.
		replace `var' = strtrim(`var') // removes leading and trailing blanks
	}
	
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == ""
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentGroup_TotalTested == "*" & StudentSubGroup_TotalTested == ""
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
	replace StudentGroup_TotalTested = "*" if missing(StudentGroup_TotalTested)
	replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	drop if StudentGroup_TotalTested == "."
	
	duplicates drop DataLevel AssmtName AssmtType NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup StudentSubGroup, force
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel
	
	keep `vars'
	order `vars'
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	*Exporting Non-Derivation Output.
	save "${Output_ND}/NJ_AssmtData_`year'_ND", replace
	export delimited "${Output_ND}/NJ_AssmtData_`year'_ND", replace

*End of NJ_2024.do
****************************************************
