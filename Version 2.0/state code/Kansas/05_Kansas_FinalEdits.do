****************************************************************
** Producing Final Output
****************************************************************
clear
set more off

global raw "C:\Users\Clare\Desktop\Zelma V2.0\Kansas - Version 2.0\Raw"
global temp "C:\Users\Clare\Desktop\Zelma V2.0\Kansas - Version 2.0\temp"
global NCESDistrict "C:\Users\Clare\Desktop\Zelma V2.0\Kansas - Version 2.0\NCES District Files, Fall 1997-Fall 2022"
global NCESSchool "C:\Users\Clare\Desktop\Zelma V2.0\Kansas - Version 2.0\NCES School Files, Fall 1997-Fall 2022"
global EDFacts "C:\Users\Clare\Desktop\Zelma V2.0\Kansas - Version 2.0\EdFacts"
global output "C:\Users\Clare\Desktop\Zelma V2.0\Kansas - Version 2.0\Output"

****************************************************************
** Final updates across all files
****************************************************************

// Added 11/21/24 to better align level counts/percents with ProficientOrAbove_counts/percents. Previously, ProficientOrAbove_count/percent were being pulled in from EDFacts, but this meant that there was misalignment when we compared outcomes to the sums of levels 3 + 4. 
{
forvalues year = 2015/2024 {
    
	if `year' == 2020 continue
	
	use "${output}/KS_AssmtData_`year'.dta", clear

	//Deriving Proficient Or Above counts  
	gen ProfAbove_count_new = .
	
		// First derived as a sum of level 3 + level 4, when available in the data 
		replace ProfAbove_count_new = real(Lev3_count) + real(Lev4_count) if !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--")	
		
		// Next applied from the EDFacts file, when missing
		replace ProfAbove_count_new = real(ProficientOrAbove_count) if ProfAbove_count_new == .
		
		// Dropping ProficientOrAbove_count (which was previously all from EDFacts and did not align with publicly reported data)
		drop ProficientOrAbove_count
		rename ProfAbove_count_new ProficientOrAbove_count 
		
		// String for final output
		tostring ProficientOrAbove_count, replace 
		replace ProficientOrAbove_count = "*" if Lev3_count == "*" & Lev4_count == "*" & ProficientOrAbove_count=="."
		replace ProficientOrAbove_count = "--" if Lev3_count == "--" & Lev4_count == "--" & ProficientOrAbove_count=="."

	//Deriving Proficient Or Above percents  
	gen ProfAbove_per_new = .
	
		// First derived as a sum of level 3 + level 4, when available in the data 
		replace ProfAbove_per_new = real(Lev3_percent) + real(Lev4_percent) if !inlist(Lev3_percent, "*", "--") & !inlist(Lev4_percent, "*", "--")	
		
		// Next applied from the EDFacts file, when missing
		replace ProfAbove_per_new = real(ProficientOrAbove_percent) if ProfAbove_per_new == .
		
		// Dropping ProficientOrAbove_percent (which was previously all from EDFacts and did not align with publicly reported data)
		drop ProficientOrAbove_percent
		rename ProfAbove_per_new ProficientOrAbove_percent 
		
		// String for final output
		tostring ProficientOrAbove_percent, replace force
		replace ProficientOrAbove_percent = "*" if Lev3_percent == "*" & Lev4_percent == "*" & ProficientOrAbove_percent=="."
		replace ProficientOrAbove_percent  = "--" if Lev3_percent == "--" & Lev4_percent == "--" & ProficientOrAbove_percent=="."
		
		//Ensure that where ProficientOrAbove_percent = 100%, that ProficientOrAbove_count does not surpass tested counts 
		replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)) if real(ProficientOrAbove_count) > real(StudentSubGroup_TotalTested) & !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_count)) & ProficientOrAbove_percent == "1"
		
//Cleanup and Ordering
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
		
save "${output}/KS_AssmtData_`year'.dta", replace
export delimited using "${output}/KS_AssmtData_`year'.csv", replace
}
}
