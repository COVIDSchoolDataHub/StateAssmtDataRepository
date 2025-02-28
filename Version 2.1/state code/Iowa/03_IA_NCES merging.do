*******************************************************
* IOWA

* File name: 03_IA_NCES merging
* Last update: 02/28/2025

*******************************************************
* Notes

	* This do file uses *.dta files created in 02_IA_clean_preNCES.
	* It merges Iowa specific NCES District and School data for the previous year.
	* The NCES merged files are saved in a Temp folder. 
	* NCES_2022 is used for 2023 and 2024.
	* As of 02/28/2025, the latest data is NCES_2022. 
	* This code will need to be updated when NCES_2023 is available. 

*******************************************************
clear

/////////////////////////////////////////
*** Merging in NCES Data ***
/////////////////////////////////////////

//Looping through NCES_2003 to NCES_2013 (ONLY DISTRICT DATA AVAILABLE)  (applies to Spring 2004 to Spring 2014)

// _merge = 1 is in the assessment data but not merged with NCES (should only be state data)
// _merge = 2 is only in the NCES data and can be dropped 
// _merge = 3 is matched data 


foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014  {
		
    local prevyear =`=`year'-1'
    
	use "${Original_DTA}/IA_AssmtData_`year'", clear
	merge m:1 State_leaid using "${NCES_IA}/NCES_`prevyear'_District_IA.dta", gen(DistMerge) 
	
			drop if DistMerge==2
			drop DistMerge
			
	keep State_leaid State StateAbbrev StateFips SchYear DataLevel DistName SchName StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc SchLevel SchType SchVirtual year NCESDistrictID DistType district_agency_type_num DistCharter DistLocale CountyCode CountyName
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	save "${Temp}/IA_AssmtData_`year'.dta", replace
}


//Looping through NCES_2014 to NCES_2022 

foreach year in 2015 2016 2017 2018 2019 2021 2022 2023  {
    
    	if `year' == 2020 continue
		
    local prevyear =`=`year'-1'
    
	use "${Original_DTA}/IA_AssmtData_`year'", clear
	merge m:1 State_leaid using "${NCES_IA}/NCES_`prevyear'_District_IA.dta", gen(DistMerge)
	
			drop if DistMerge==2
			drop DistMerge
		
	merge m:1 State_leaid StateAssignedSchID using "${NCES_IA}/NCES_`prevyear'_School_IA.dta", gen(SchMerge)
	
	 	drop if SchMerge==2
		drop SchMerge
		
	save "${Temp}/IA_AssmtData_`year'.dta", replace
}

// For 2024: Applying NCES_2022 and identifying new schools - UPDATE WHEN NCES_2023 BECOMES AVAILABLE 

foreach year in 2024 {
		
    local prevyear = 2022
    
	use "${Original_DTA}/IA_AssmtData_`year'", clear
	merge m:1 State_leaid using "${NCES_IA}/NCES_`prevyear'_District_IA.dta", gen(DistMerge)
	

	// DistMerge = 1 : In assmt data but not NCES. Confirmed that these are all state values
	// DistMerge = 2 : In NCES data but not assmt data, can drop
	// DistMerge = 3 : matched
	
	/*
		// to identify new districts in 2024 - none were identified
		preserve
		keep if (missing(NCESDistrictID) & DataLevel != "State")
		cap keep DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID  SchType SchLevel SchVirtual DistType DistCharter DistLocale CountyName CountyCode
		duplicates drop 
		export excel using "${Original}/IA 2024 New Districts.xlsx", firstrow(variables) replace
		restore
*/
			drop if DistMerge==2
			drop DistMerge
		
	merge m:1 State_leaid StateAssignedSchID using "${NCES_IA}/NCES_`prevyear'_School_IA.dta", gen(SchMerge)
	
	
		// to identify new schools in 2024 - resolved these cases below and do not need to unhide code
		/*
		preserve
		keep if (missing(NCESSchoolID) & DataLevel == "School") | (missing(SchVirtual) & DataLevel == "School") | (missing(NCESDistrictID) & DataLevel != "State")
		keep DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID  SchType SchLevel SchVirtual DistType DistCharter DistLocale CountyName CountyCode
		duplicates drop 
		export excel using "${Original}/IA 2024 New Schools.xlsx", firstrow(variables) replace
		restore
		*/
		
		// 2024 new school updates

		*Southeast Valley Elementary
		replace NCESSchoolID = "199901902324" if SchName == "Southeast Valley Elementary" & StateAssignedSchID == "6096-0436"
		replace SchVirtual = 0 if SchName == "Southeast Valley Elementary" & StateAssignedSchID == "6096-0436" // No 
		replace SchLevel = 1 if SchName == "Southeast Valley Elementary" & StateAssignedSchID == "6096-0436" // Primary
		replace SchType = 1 if SchName == "Southeast Valley Elementary" & StateAssignedSchID == "6096-0436" //Regular school
		
		*Valerius Elementary School
		replace NCESSchoolID = "192868002325" if SchName == "Valerius Elementary School" & StateAssignedSchID == "6579-0451"
		replace SchVirtual = 0 if SchName == "Valerius Elementary School" & StateAssignedSchID == "6579-0451" // No
		replace SchLevel = 1 if SchName == "Valerius Elementary School" & StateAssignedSchID == "6579-0451" // Primary
		replace SchType = 1 if SchName == "Valerius Elementary School" & StateAssignedSchID == "6579-0451" //Regular school
		
		*Trailridge School
		replace NCESSchoolID = "193051002326" if SchName == "Trailridge School" & StateAssignedSchID == "6822-0232"
		replace SchVirtual = 0 if SchName == "Trailridge School" & StateAssignedSchID == "6822-0232" // No
		replace SchLevel = 2 if SchName == "Trailridge School" & StateAssignedSchID == "6822-0232" // Middle
		replace SchType = 1 if SchName == "Trailridge School" & StateAssignedSchID == "6822-0232" //Regular school
		
		*Horizon Science Academy Des Moines
		replace NCESSchoolID = "199902002316" if SchName == "Horizon Science Academy Des Moines" & StateAssignedSchID == "8200-0101"
		replace SchVirtual = 0 if SchName == "Horizon Science Academy Des Moines" & StateAssignedSchID == "8200-0101" // No
		replace SchLevel = 1 if SchName == "Horizon Science Academy Des Moines" & StateAssignedSchID == "8200-0101" // Primary
		replace SchType = 1 if SchName == "Horizon Science Academy Des Moines" & StateAssignedSchID == "8200-0101" //Regular school
	
	 	drop if SchMerge==2
		drop SchMerge
	
	save "${Temp}/IA_AssmtData_`year'.dta", replace
}

* End of 03_IA_NCES_merging
********************************************************
