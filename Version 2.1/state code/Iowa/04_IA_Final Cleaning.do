*******************************************************
* IOWA

* File name: 04_IA_Final Cleaning
* Last update: 02/28/2025

*******************************************************
clear

*******************************************************
* Notes

	* This do file uses 
	
	
	*uses *.dta files created in 02_IA_clean_preNCES.
	* It merges Iowa specific NCES District and School data for the previous year.
	* The NCES merged files are saved in a Temp folder. 
	* NCES_2022 is used for 2023 and 2024.
	* As of 02/28/2025, the latest data is NCES_2022. 
	* This code will need to be updated when NCES_2023 is available. 

*******************************************************


/////////////////////////////////////////
// Stable Names
/////////////////////////////////////////
import excel "${Stable}/ia_full-dist-sch-stable-list_through2023.xlsx", sheet("Sheet1") firstrow clear
save "${Stable}/ia_full-dist-sch-stable-list_through2023.dta", replace


use "${Stable}/ia_full-dist-sch-stable-list_through2023.dta", clear
keep State SchYear NCESDistrictID newdistname olddistname  
duplicates drop 
save "${Stable}/ia_distnames.dta", replace

// 2004 to 2014
foreach a in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014  {
	use "${Temp}/IA_AssmtData_`a'", clear
	save "${Temp}/IA_AssmtData_`a'_temp.dta", replace
}

// 2015 to 2023

foreach a in 2015 2016 2017 2018 2019 2021 2022 2023 {
	use "${Temp}/IA_AssmtData_`a'", clear
	destring NCESDistrictID, replace force
	destring NCESSchoolID, replace force
	
	//Merging

	tempfile tempall
	save "`tempall'", replace
	
	keep if DataLevel == "District"
	tempfile tempdist
	save "`tempdist'", replace
	
	clear
	use "`tempall'"
	keep if DataLevel == "School"
	tempfile tempsch
	save "`tempsch'", replace
	clear

	//School Merge
	use "`tempsch'"
	merge m:1 SchYear NCESDistrictID NCESSchoolID DataLevel using "${Stable}/ia_full-dist-sch-stable-list_through2023.dta", gen(SchMerge) 
	drop if SchMerge == 2
	save "`tempsch'", replace
	clear 
	
	//District Merge
	use "`tempdist'"
	merge m:1 NCESDistrictID SchYear using "${Stable}/ia_distnames.dta", gen(DistMerge) 
	drop if DistMerge == 2
	save "`tempdist'", replace
	clear

	//Combining DataLevels
	use "`tempall'"
	keep if DataLevel == "State"
	append using "`tempdist'" "`tempsch'"
	save "`tempall'", replace
	
// Name updates 
drop DistName olddistname SchName oldschname
rename newschname SchName
rename newdistname DistName 

save "${Temp}/IA_AssmtData_`a'_temp.dta", replace
}

// 2024

foreach year in 2024 {
    
	use "${Temp}/IA_AssmtData_`year'", clear
	//DistName updates - // updated 12/15/24
	replace DistName = subinstr(DistName, "Mt ", "Mt. ", 1)
	replace DistName = subinstr(DistName, "St ", "St. ", 1)
	replace DistName = "Waco Comm School District" if NCESDistrictID == "1929490"
		
save "${Temp}/IA_AssmtData_`year'_temp.dta", replace
}

/////////////////////////////////////////
// County Names
/////////////////////////////////////////


foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2021 2022 2023 2024 {
    
	use "${Temp}/IA_AssmtData_`year'_temp.dta", clear
	destring CountyCode, replace force
	
	merge m:1 SchYear CountyCode using "${Original_DTA}/ia_county-list_through2023.dta"
	drop CountyName oldcountyname
	rename newcountyname CountyName
	
	drop if _merge == 2
	drop _merge 
	
save "${Temp}/IA_AssmtData_`year'_temp.dta", replace

}

foreach year in 2024 {
    
	use "${Temp}/IA_AssmtData_`year'_temp.dta", clear
	destring CountyCode, replace force
	
	merge m:1 CountyCode using "${Original_DTA}/ia_county-list_noyear.dta"
	drop CountyName oldcountyname
	rename newcountyname CountyName
	
	drop if _merge == 2
	drop _merge 
	
save "${Temp}/IA_AssmtData_`year'_temp.dta", replace

}

/////////////////////////////////////////
// Final Cleaning 
/////////////////////////////////////////
foreach year in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2021 2022 2023 2024 {

	use "${Temp}/IA_AssmtData_`year'_temp.dta", clear
	
	// Cleaning up DistNames & SchNames
	replace DistName = "All Districts" if DataLevel == "State"
	replace SchName = "All Schools" if DataLevel != "School"
	
	replace DistName =strtrim(DistName) 
	replace DistName =stritrim(DistName) 
	replace SchName =strtrim(SchName) 
	replace SchName =stritrim(SchName) 

	// Generating student group total counts
	gen StateAssignedDistID1 = StateAssignedDistID
	replace StateAssignedDistID1 = "000000" if DataLevel == "State" 
	gen StateAssignedSchID1 = StateAssignedSchID
	replace StateAssignedSchID1 = "000000" if DataLevel !="School" 
	
	egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
	sort group_id StudentGroup StudentSubGroup
	
	drop StudentGroup_TotalTested
	by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
	drop group_id StateAssignedDistID1 StateAssignedSchID1	
	
	//ProficiencyLevels that Iowa does not use
	replace Lev4_count=""
	replace Lev4_percent=""
	replace Lev5_count=""
	replace Lev5_percent=""
		
	//DataLevel
// 	gen DataLev_n = .
// 	replace DataLev_n = 1 if DataLevel == "State"
// 	replace DataLev_n = 2 if DataLevel == "District"
// 	replace DataLev_n = 3 if DataLevel == "School"
		
	duplicates drop 

	drop if DataLevel==""

// Reordering variables and sorting data
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

*Exporting Output*
save "${Output}/IA_AssmtData_`year'.dta", replace
export delimited using "${Output}/IA_AssmtData_`year'.csv", replace
}

// 2023 update for Ruby Van Meter 
use "${Output}/IA_AssmtData_2023.dta", clear
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested==""
save "${Output}/IA_AssmtData_2023.dta", replace
export delimited "${Output}/IA_AssmtData_2023.csv", replace

*End of 04_IA_Final Cleaning
********************************************************
