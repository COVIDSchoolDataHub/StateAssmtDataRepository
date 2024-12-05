clear
set more off

global data "/Users/kaitlynlucas/Desktop/Missouri/MO State Testing Files"
global output "/Users/kaitlynlucas/Desktop/Missouri/MO State Testing Files/Output"
global NCES "/Users/kaitlynlucas/Desktop/Missouri/NCES School and District Demographics/Clean NCES"

set trace off

forvalues year = 2010/2014{
	local prevyear = `year' - 1
	
	** Append data into one file & rename variables
	use "${data}/MO_AssmtData_2010-2014_state.dta", clear
	append using "${data}/MO_AssmtData_2010-2014_statedisag.dta"

	keep if YEAR == `year'
	drop if strpos(CATEGORY, "MSIP5") > 0
	destring MEAN_SCALE_SCORE, replace
	gen DataLevel = "State"

	append using "${data}/MO_AssmtData_2010-2014_district.dta", force
	append using "${data}/MO_AssmtData_2010-2014_districtdisag.dta", force

	replace DataLevel = "District" if DataLevel == ""

	append using "${data}/MO_AssmtData_2010-2014_school.dta", force
	
	rename SCHOOL_CODE* StateAssignedSchID
	
	append using "${data}/MO_AssmtData_2010-2014_schooldisag.dta", force
	
	replace StateAssignedSchID = SCHOOL_CODE if StateAssignedSchID == .
	drop SCHOOL_CODE
	rename SCHOOL_NAME SchName
	replace DataLevel = "School" if DataLevel == ""
	
	rename COUNTY_DISTRICT StateAssignedDistID 
	rename DISTRICT_NAME DistName
	rename YEAR SchYear
	rename CATEGORY StudentGroup
	rename TYPE StudentSubGroup
	rename CONTENT_AREA Subject
	rename GRADE_LEVEL GradeLevel
	rename REPORTABLE StudentSubGroup_TotalTested
	rename BELOW_BASIC Lev1_count
	rename BASIC Lev2_count
	rename PROFICIENT Lev3_count
	rename ADVANCED Lev4_count
	rename TOP_TWO_LEVELS ProficientOrAbove_count
	rename BELOW_BASIC_PCT Lev1_percent
	rename BASIC_PCT Lev2_percent
	rename PROFICIENT_PCT Lev3_percent
	rename ADVANCED_PCT Lev4_percent
	rename TOP_TWO_LEVELS_PCT ProficientOrAbove_percent
	rename MEAN_SCALE_SCORE AvgScaleScore
	
	** Drop unncessary variables and entries
	drop COUNTY_DISTRICT_SCHOOL_CODE SUMMARY_LEVEL ACCOUNTABLE PARTICIPANT LEVEL_NOT_DETERMINED BOTTOM_TWO_LEVELS BOTTOM_TWO_LEVELS_PCT MAP_INDEX MEDIAN_SCALE_SCORE MEDIAN_TERRANOVA
	
	keep if SchYear == `year'
	
	drop if strpos(StudentGroup, "MSIP5") > 0
	drop if inlist(GradeLevel, "A1", "A2", "AH", "B1", "E1", "E2", "GE", "GV")
	drop if StudentSubGroup == "IEP_student"
	
	** Change DataLevel

	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel
	rename DataLevel_n DataLevel
	
	replace SchName = "All Schools" if DataLevel != 3
	replace DistName = "All Districts" if DataLevel == 1

	tostring StateAssignedSchID, replace
	replace StateAssignedSchID = "" if DataLevel != 3
	tostring StateAssignedDistID, replace
	replace StateAssignedDistID = "" if DataLevel == 1
	
	** Student Groups & SubGroups
	
	replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Amer. Indian or Alaska Native"
	replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black(not Hispanic)"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
	replace StudentSubGroup = "White" if StudentSubGroup == "White(not Hispanic)"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP/ELL Students"
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Map Free and Reduced Lunch"
	
	replace StudentGroup = "All Students" if StudentGroup == "Total"
	replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
	replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
	replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
	
	** Standardize other information
	tostring SchYear, replace
	replace SchYear = "`prevyear'-`year'"
	replace SchYear = substr(SchYear, 1, 5) + substr(SchYear, 8, 9)
	
	replace GradeLevel = "G0" + subinstr(GradeLevel, "0", "", .)
	
	** Standardize other information
	tostring SchYear, replace
	replace SchYear = "`prevyear'-`year'"
	replace SchYear = substr(SchYear, 1, 5) + substr(SchYear, 8, 9)
	
	replace GradeLevel = "G0" + subinstr(GradeLevel, "G0", "", .)

	gen AssmtName = "MAP"
	gen AssmtType = "Regular"

	replace Subject = "ela" if Subject == "Eng. Language Arts"
	replace Subject = "math" if Subject == "Mathematics"
	replace Subject = "sci" if Subject == "Science"
	/*
	bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
	replace StudentGroup_TotalTested = AllStudents_Tested if inlist(StudentGroup, "EL Status", "Economic Status")
	*/

	** Levels & Proficiency Information
	forvalues a = 1/4{
		destring Lev`a'_percent, replace force
		replace Lev`a'_percent = Lev`a'_percent/100
	}

	replace ProficientOrAbove_percent = ProficientOrAbove_percent/100

	gen Lev5_count = ""
	gen Lev5_percent = ""
	
	gen ProficiencyCriteria = "Levels 3-4"

	gen ParticipationRate = 100 - LEVEL_NOT_DETERMINED_PCT
	replace ParticipationRate = ParticipationRate/100
	tostring ParticipationRate, replace format("%9.2g") force
	replace ParticipationRate = "*" if ParticipationRate == "."
	
	** Merge NCES Data
	
	gen State_leaid = StateAssignedDistID
	replace State_leaid = "0" + State_leaid if substr(State_leaid, 5, 1) == ""
	replace State_leaid = "0" + State_leaid if substr(State_leaid, 6, 1) == ""
	replace State_leaid = "" if DataLevel == 1
	
	merge m:1 State_leaid using "${NCES}/NCES_`prevyear'_District_MO.dta"
	
	if `year' < 2014{
		rename district_agency_type DistType
	}
	
	drop if _merge == 2
	drop _merge
	
	if `year' == 2010{
		merge m:1 State_leaid using "${NCES}/NCES_2013_District_MO.dta", update gen(merge3)

		drop if NCESDistrictID == "" & DataLevel != 1

		drop if merge3 == 2
		drop merge3
	}
	
	gen seasch = StateAssignedSchID + State_leaid
	replace seasch = "" if DataLevel != 3
	
	merge m:1 seasch using "${NCES}/NCES_`prevyear'_School_MO.dta", gen(merge2)
	
	drop if NCESSchoolID == "" & DataLevel == 3
	drop if merge2 == 2
	drop merge2
	
	if `year' == 2010{
		merge m:1 seasch using "${NCES}/NCES_2013_School_MO.dta", update gen(merge4)

		drop if NCESSchoolID == "" & DataLevel == 3

		drop if merge4 == 2
		drop merge4
	}
	
	replace StateAbbrev = "MO"
	replace State = "Missouri"
	replace StateFips = 29
	
	replace CountyName = strproper(CountyName)
	
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_soc = "Not applicable"
	gen Flag_CutScoreChange_sci = "N"
	

	//only way to make sure the values are stored as strings in the output .csv file
	gen flag = 1 if NCESSchoolID == "290825000226" & StudentSubGroup == "White" & Subject == "sci" & GradeLevel == "G05"
	
	forvalues n = 1/4{
		tostring Lev`n'_percent, replace format("%7.3f") force
		tostring Lev`n'_count, replace
		replace Lev`n'_percent = "*" if flag == 1
		replace Lev`n'_count = "*" if flag == 1
	}
	
	tostring ProficientOrAbove_percent, replace format("%7.4f") force
	tostring ProficientOrAbove_count, replace
	replace ProficientOrAbove_percent = "*" if flag == 1
	replace ProficientOrAbove_count = "*" if flag == 1
	
	replace CountyName= "McDonald County" if CountyCode == "29119"
	replace CountyName= "DeKalb County" if CountyCode == "29063"
	
	** Unmerged Districts
	
	replace NCESDistrictID = "2900607" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace DistType = "State-operated agency" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace DistCharter = "No" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace DistLocale = "City, small" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace CountyName = "Cole County" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace CountyCode = "29051" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	drop if inlist(DistName, "NORTHWEST MISSOURI STATE UNIV", "SOUTHWEST MISSOURI STATE UNIV")
	
	replace SchName = strtrim(SchName)
	replace SchName = stritrim(SchName)
	
	//dropped school name
	replace SchName = "IA OF ACADEMIC SUCCESS" if NCESSchoolID == "290058103170"

		** Generating student group total counts (V2.0) 
//there are missing SG_TT values from 2010-2014 but these are missing in the raw data and likely due to data suppression <10
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//remove leading zeros/standardizing for StateAssignedDistID
replace StateAssignedDistID = substr(StateAssignedDistID, 2, .) if substr(StateAssignedDistID, 1, 1) == "0"
replace StateAssignedDistID = "7123" if DistName == "ADRIAN R-III"
replace StateAssignedDistID = "2090" if DistName == "AVENUE CITY R-IX"
replace StateAssignedDistID = "7122" if DistName == "BALLARD R-II"
replace StateAssignedDistID = "1092" if DistName == "ADAIR CO. R-II"
replace StateAssignedDistID = "7129" if DistName == "BUTLER R-V"
replace StateAssignedDistID = "5123" if DistName == "CASSVILLE R-IV"
replace StateAssignedDistID = "8111" if DistName == "COLE CAMP R-I"
replace StateAssignedDistID = "4106" if DistName == "COMMUNITY R-VI"
replace StateAssignedDistID = "5122" if DistName == "EXETER R-VI"
replace StateAssignedDistID = "3033" if DistName == "FAIRFAX R-III"
replace StateAssignedDistID = "6103" if DistName == "GOLDEN CITY R-III"
replace StateAssignedDistID = "7125" if DistName == "HUME R-VIII"
replace StateAssignedDistID = "1091" if DistName == "KIRKSVILLE R-III"
replace StateAssignedDistID = "6104" if DistName == "LAMAR R-I"
replace StateAssignedDistID = "9078" if DistName == "LEOPOLD R-III"
replace StateAssignedDistID = "6101" if DistName == "LIBERAL R-II"
replace StateAssignedDistID = "8106" if DistName == "LINCOLN R-II"
replace StateAssignedDistID = "9080" if DistName == "WOODLAND R-IV"
replace StateAssignedDistID = "4110" if DistName == "MEXICO 59"
replace StateAssignedDistID = "7121" if DistName == "MIAMI R-I" & StateAssignedDistID == "07121"
replace StateAssignedDistID = "5128" if DistName == "MONETT R-I"
replace StateAssignedDistID = "2089" if DistName == "NORTH ANDREW CO. R-VI"
replace StateAssignedDistID = "1090" if DistName == "ADAIR CO. R-I"
replace StateAssignedDistID = "9077" if DistName == "MEADOW HEIGHTS R-II"
replace StateAssignedDistID = "5124" if DistName == "PURDY R-II"
replace StateAssignedDistID = "7124" if DistName == "RICH HILL R-IV"
replace StateAssignedDistID = "3032" if DistName == "ROCK PORT R-II"
replace StateAssignedDistID = "2097" if DistName == "SAVANNAH R-III"
replace StateAssignedDistID = "5127" if DistName == "SHELL KNOB 78"
replace StateAssignedDistID = "5121" if DistName == "SOUTHWEST R-V"
replace StateAssignedDistID = "3031" if DistName == "TARKIO R-I"
replace StateAssignedDistID = "4109" if DistName == "VAN-FAR R-I"
replace StateAssignedDistID = "8107" if DistName == "WARSAW R-IX"
replace StateAssignedDistID = "5120" if DistName == "WHEATON R-III"
replace StateAssignedDistID = "9079" if DistName == "ZALMA R-V"

//changing these districts' names because they are the exact same
replace DistName = "MIAMI R-I (Bates County)" if NCESDistrictID == "2920820"
replace DistName = "MIAMI R-I (Saline County)" if NCESDistrictID == "2920840"
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == ""

//deriving additional level counts and percents
tostring StudentSubGroup_TotalTested, replace

replace ProficientOrAbove_percent = string(1 - real(Lev1_percent) - real(Lev2_percent), "%9.8f") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*"
replace Lev3_percent = string(real(ProficientOrAbove_percent) - real(Lev4_percent), "%9.8f") if Lev3_percent == "*" & ProficientOrAbove_percent != "*" & Lev4_percent != "*"
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent), "%9.8f") if Lev4_percent == "*" & ProficientOrAbove_percent != "*" & Lev3_percent != "*"
replace Lev1_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev2_percent), "%9.8f") if Lev1_percent == "*" & ProficientOrAbove_percent != "*" & Lev2_percent != "*"
replace Lev2_percent = string(1 - real(ProficientOrAbove_percent) - real(Lev1_percent), "%9.8f") if Lev2_percent == "*" & ProficientOrAbove_percent != "*" & Lev1_percent != "*"


replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count)) if inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(Lev1_count, "*", "0-3") & !inlist(Lev2_count, "*", "0-3")
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev2_count)) if inlist(Lev1_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev2_count, "*", "0-3")
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count) - real(Lev1_count)) if inlist(Lev2_count, "*", "0-3") & !inlist(StudentSubGroup_TotalTested, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev1_count, "*", "0-3")
replace Lev3_count = string(real(ProficientOrAbove_count) - real(Lev4_count)) if inlist(Lev3_count, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev4_count, "*", "0-3")
replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count)) if inlist(Lev4_count, "*", "0-3") & !inlist(ProficientOrAbove_count, "*", "0-3") & !inlist(Lev3_count, "*", "0-3")

	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save "${output}/MO_AssmtData_`year'.dta", replace
	
	export delimited using "${output}/MO_AssmtData_`year'.csv", replace
}




