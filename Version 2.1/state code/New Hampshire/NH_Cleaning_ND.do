* NEW HAMPSHIRE

* File name: NH_Cleaning_ND
* Last update: 03/07/2025

*******************************************************
* Notes

	* This do file uses the two breakpoints created in NH_Cleaning.
	* It creates the non-derivation output for 2009-2024 (excluding 2020).
*******************************************************
clear

******************************
// Creating the non-derivation output
******************************
forvalues year = 2009/2024 {
	if `year' == 2020 continue
*******************************************************
*Restoring the breakpoint
*******************************************************
use "$Temp/NH_`year'_Breakpoint", clear

// Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & real(Lev3_percent) + real(Lev4_percent) <= 1
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*"

replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & Lev1_percent != "*" & Lev2_percent != "*" & 1 - real(Lev1_percent) - real(Lev2_percent) <= 1
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") > 0
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if (strpos(Lev4_percent, "-") > 0 | Lev4_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) >= 0
replace Lev4_percent = "0" if (strpos(Lev4_percent, "-") > 0 | Lev4_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) < 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0
replace Lev4_percent = "0" if Lev4_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) >= 0
replace Lev4_count = "0" if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) < 0
replace Lev4_percent = "0" if Lev4_count == "0"
replace Lev4_count = "0" if Lev4_percent == "0" & StudentSubGroup_TotalTested != "--"
replace Lev4_count = "0" if Lev4_count == "--" & ProficientOrAbove_count == "0"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0
replace Lev3_percent = "0" if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0
replace Lev3_percent = "0" if Lev3_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0
replace Lev3_count = "0" if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0
replace Lev3_percent = "0" if Lev3_count == "0"
replace Lev3_count = "0" if Lev3_percent == "0" & StudentSubGroup_TotalTested != "--"
replace Lev3_count = "0" if Lev3_count == "--" & ProficientOrAbove_percent == "0"

replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent)) if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) >= 0
replace Lev2_percent = "0" if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) < 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) >= 0
replace Lev2_count = "0" if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) < 0
replace Lev2_percent = "0" if Lev2_count == "0"
replace Lev2_count = "0" if Lev2_percent == "0" & StudentSubGroup_TotalTested != "--"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent)) if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) >= 0
replace Lev1_percent = "0" if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) < 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) >= 0
replace Lev1_count = "0" if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) < 0
replace Lev1_percent = "0" if Lev1_count == "0"
replace Lev1_count = "0" if Lev1_percent == "0" & StudentSubGroup_TotalTested != "--"

//Flags
if `year' == 2015 {
	replace Flag_AssmtNameChange = "Y" if Subject != "sci"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	
}
if `year' == 2018 {
	replace Flag_AssmtNameChange = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_sci = "Y"
}


//Final Cleaning
replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)

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
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

duplicates drop

*Exporting Temp ND output for 2017-2022 (excluding 2020)
*The Temp ND output will be merged with Aggregated District Level Data in the next loop. 
if `year' >= 2015 & `year' <= 2022 {
save "${Temp}/NH_AssmtData_`year'_ND", replace
}

// *Exporting Non-Derivation Output for 2009-2016, 2023 and 2024.
if `year' < 2017 | `year' > 2022 {
save "${Output_ND}/NH_AssmtData_`year'_ND", replace
export delimited "${Output_ND}/NH_AssmtData_`year'_ND", replace
	}
}

//Adding Aggregated District-Level Data
foreach year in 2017 2018 2019 2021 2022 {
*******************************************************
*Restoring the breakpoint
*******************************************************
use "$Temp/NH_`year'_BreakpointG38", clear

//Appending Data
append using "${Temp}/NH_AssmtData_`year'_ND"

//Response to R1
replace NCESDistrictID = "3301710" if NCESDistrictID == "3399939"
drop if SchName == "MicroSociety Academy Charter School of Southern NH" & `year' == 2017 & missing(StateAssignedSchID) //Not sure whats happening here, but it's not merging and its a duplicate observation, so dropping
drop if SchName == ""

// Deriving Additional Information
replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev4_percent, "-") == 0 & strpos(Lev3_percent, "-") == 0 & Lev3_percent != "*" & Lev4_percent != "*" & real(Lev3_percent) + real(Lev4_percent) <= 1
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(Lev4_count, "-") == 0 & strpos(Lev3_count, "-") == 0 & Lev3_count != "*" & Lev4_count != "*"

replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent)) if strpos(ProficientOrAbove_percent, "-") > 0 & strpos(Lev1_percent, "-") == 0 & strpos(Lev2_percent, "-") == 0 & Lev1_percent != "*" & Lev2_percent != "*" & 1 - real(Lev1_percent) - real(Lev2_percent) <= 1
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if strpos(ProficientOrAbove_count, "-") > 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(Lev1_count, "-") == 0 & strpos(Lev2_count, "-") == 0 & StudentSubGroup_TotalTested != "*" & Lev1_count != "*" & Lev2_count != "*"
replace ProficientOrAbove_percent = "0" if strpos(ProficientOrAbove_percent, "e") > 0
replace ProficientOrAbove_percent = "0" if ProficientOrAbove_count == "0"
replace ProficientOrAbove_count = "0" if ProficientOrAbove_percent == "0"

replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent)) if (strpos(Lev4_percent, "-") > 0 | Lev4_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) >= 0
replace Lev4_percent = "0" if (strpos(Lev4_percent, "-") > 0 | Lev4_percent == "*") & strpos(Lev3_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev3_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev3_percent) < 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0
replace Lev4_percent = "0" if Lev4_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) >= 0
replace Lev4_count = "0" if (strpos(Lev4_count, "-") > 0 | Lev4_count == "*") & strpos(Lev3_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev3_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev3_count) < 0
replace Lev4_percent = "0" if Lev4_count == "0"
replace Lev4_count = "0" if Lev4_percent == "0" & StudentSubGroup_TotalTested != "--"
replace Lev4_count = "0" if Lev4_count == "--" & ProficientOrAbove_count == "0"

replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent)) if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) >= 0
replace Lev3_percent = "0" if (strpos(Lev3_percent, "-") > 0 | Lev3_percent == "*") & strpos(Lev4_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev4_percent != "*" & ProficientOrAbove_percent != "*" & real(ProficientOrAbove_percent) - real(Lev4_percent) < 0
replace Lev3_percent = "0" if strpos(Lev3_percent, "e") > 0
replace Lev3_percent = "0" if Lev3_percent == "--" & ProficientOrAbove_percent == "0"

replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) >= 0
replace Lev3_count = "0" if (strpos(Lev3_count, "-") > 0 | Lev3_count == "*") & strpos(Lev4_count, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev4_count != "*" & ProficientOrAbove_count != "*" & real(ProficientOrAbove_count) - real(Lev4_count) < 0
replace Lev3_percent = "0" if Lev3_count == "0"
replace Lev3_count = "0" if Lev3_percent == "0" & StudentSubGroup_TotalTested != "--"
replace Lev3_count = "0" if Lev3_count == "--" & ProficientOrAbove_percent == "0"
replace Lev4_percent = "0" if ProficientOrAbove_percent == "0" & Lev3_percent == "0"
replace Lev4_count = "0" if Lev4_percent == "0"

replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent)) if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) >= 0
replace Lev2_percent = "0" if (strpos(Lev2_percent, "-") > 0 | Lev2_percent == "*") & strpos(Lev1_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev1_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) < 0
replace Lev2_percent = "0" if strpos(Lev2_percent, "e") > 0

replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) >= 0
replace Lev2_count = "0" if (strpos(Lev2_count, "-") > 0 | Lev2_count == "*") & strpos(Lev1_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev1_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count) < 0
replace Lev2_percent = "0" if Lev2_count == "0"
replace Lev2_count = "0" if Lev2_percent == "0" & StudentSubGroup_TotalTested != "--"

replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent)) if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) >= 0
replace Lev1_percent = "0" if (strpos(Lev1_percent, "-") > 0 | Lev1_percent == "*") & strpos(Lev2_percent, "-") == 0 & strpos(ProficientOrAbove_percent, "-") == 0 & Lev2_percent != "*" & ProficientOrAbove_percent != "*" & 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) < 0
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) >= 0
replace Lev1_count = "0" if (strpos(Lev1_count, "-") > 0 | Lev1_count == "*") & strpos(Lev2_count, "-") == 0 & strpos(StudentSubGroup_TotalTested, "-") == 0 & strpos(ProficientOrAbove_count, "-") == 0 & Lev2_count != "*" & StudentSubGroup_TotalTested != "*" & ProficientOrAbove_count != "*" & real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count) < 0
replace Lev1_percent = "0" if Lev1_count == "0"
replace Lev1_count = "0" if Lev1_percent == "0" & StudentSubGroup_TotalTested != "--"

//Assessment Info
if `year' <= 2017 & `year' >= 2015 replace AssmtName = "NECAP" if Subject == "sci"
if `year' >= 2018 replace AssmtName = "NH SAS"
replace AssmtName = "Smarter Balanced Assessment" if Subject != "sci" & `year' < 2018 & `year' >= 2015

//Flags
if `year' == 2015 {
	replace Flag_AssmtNameChange = "Y" if Subject != "sci"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_soc = "Not applicable"
	
}
if `year' == 2018 {
	replace Flag_AssmtNameChange = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_sci = "Y"
	replace Flag_CutScoreChange_soc = "Not applicable"
}

if !inlist(`year', 2015, 2018) {
	replace Flag_AssmtNameChange = "N"
	replace Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_sci = "N"
	replace Flag_CutScoreChange_soc = "Not applicable"
}

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
duplicates drop 
*Exporting Final ND output for 2017-2022 (excluding 2020)
save "${Output_ND}/NH_AssmtData_`year'_ND", replace
export delimited "${Output_ND}/NH_AssmtData_`year'_ND", replace
clear
}
*End of NH_Cleaning_ND.do
****************************************************
