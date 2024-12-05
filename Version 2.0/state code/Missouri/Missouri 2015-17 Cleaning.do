clear
set more off

global data "/Users/kaitlynlucas/Desktop/Missouri/MO State Testing Files"
global output "/Users/kaitlynlucas/Desktop/Missouri/MO State Testing Files/Output"
global NCES "/Users/kaitlynlucas/Desktop/Missouri/NCES School and District Demographics/Clean NCES"



set trace off

forvalues year = 2015/2017{
	local prevyear = `year' - 1
	
	** Append data into one file & rename variables
	use "${data}/MO_AssmtData_2015-2017_state.dta", clear
	append using "${data}/MO_AssmtData_2015-2017_district.dta"
	append using "${data}/MO_AssmtData_2015-2017_school.dta"
	
	rename YEAR SchYear
	rename SUMMARY_LEVEL DataLevel
	rename CATEGORY StudentGroup
	rename TYPE StudentSubGroup
	rename COUNTY_DISTRICT StateAssignedDistID 
	rename DISTRICT_NAME DistName
	rename SCHOOL_CODE StateAssignedSchID
	rename SCHOOL_NAME SchName
	rename CONTENT_AREA Subject
	rename GRADE_LEVEL GradeLevel
	rename REPORTABLE StudentSubGroup_TotalTested
	rename BELOW_BASIC Lev1_count
	rename BASIC Lev2_count
	rename PROFICIENT Lev3_count
	rename ADVANCED Lev4_count
	rename BELOW_BASIC_PCT Lev1_percent
	rename BASIC_PCT Lev2_percent
	rename PROFICIENT_PCT Lev3_percent
	rename ADVANCED_PCT Lev4_percent
	
	** Drop unncessary variables and entries
	drop ACCOUNTABLE LEVEL_NOT_DETERMINED
	
	keep if SchYear == `year'
	
	keep if inlist(GradeLevel, "3", "4", "5", "6", "7", "8")
	
	replace StudentSubGroup = strtrim(StudentSubGroup)
	drop if (strpos(StudentSubGroup, "<") | strpos(StudentSubGroup, "EL") | strpos(StudentSubGroup, "Direct Certification") > 0) & !inlist(StudentSubGroup, "LEP/ELL Monitoring", "LEP/ELL Students")
	drop if inlist(StudentSubGroup, "Gifted", "High School Vocational", "TitleI", "IEP MAPA", "IEP_student")
	
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
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic)"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
	replace StudentSubGroup = "Unknown" if StudentSubGroup == "No Response"
	replace StudentSubGroup = "White" if StudentSubGroup == "White (not Hispanic)"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP/ELL Students"
	replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "LEP/ELL Monitoring"
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Map Free and Reduced Lunch"
	replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non Free and Reduced Lunch"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP Non MAPA"
	replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non IEP Students"
	
	replace StudentGroup = "All Students" if StudentGroup == "Total"
	replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
	replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "EL Monit or Recently Ex")
	replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
	replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
	
	** Standardize other information
	tostring SchYear, replace
	replace SchYear = "`prevyear'-`year'"
	replace SchYear = substr(SchYear, 1, 5) + substr(SchYear, 8, 9)
	
	replace GradeLevel = "G0" + GradeLevel

	gen AssmtName = "MAP"
	gen AssmtType = "Regular"

	replace Subject = "ela" if Subject == "Eng. Language Arts"
	replace Subject = "math" if Subject == "Mathematics"
	replace Subject = "sci" if Subject == "Science"
	
	/*
	bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)
	replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
	replace StudentGroup_TotalTested = AllStudents_Tested if inlist(StudentSubGroup, "Migrant", "English Learner")
	replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "EL Monit or Recently Ex"
	*/
	** Generating student group total counts v2.0


	** Levels & Proficiency Information
	forvalues a = 1/4{
		destring Lev`a'_percent, replace force
		replace Lev`a'_percent = Lev`a'_percent/100
	}

	gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
	replace ProficientOrAbove_percent = 1 - (Lev1_percent + Lev2_percent) if ProficientOrAbove_percent == . & Lev1_percent != . & Lev2_percent != .

	forvalues a = 1/4{
		tostring Lev`a'_percent, replace force
		replace Lev`a'_percent = "*" if Lev`a'_percent == "."
		destring Lev`a'_count, gen(Lev`a'_count2) force
	}

	gen ProficientOrAbove_count = Lev3_count2 + Lev4_count2
	gen NotProfCount = Lev1_count2 + Lev2_count2 if Lev1_count2 != . & Lev2_count2 != .
	replace ProficientOrAbove_count = StudentSubGroup_TotalTested - NotProfCount if ProficientOrAbove_count == . & StudentSubGroup_TotalTested != . & NotProfCount != .
	replace ProficientOrAbove_count = ProficientOrAbove_percent * StudentSubGroup_TotalTested if ProficientOrAbove_count == . & StudentSubGroup_TotalTested != . & ProficientOrAbove_percent != .
	
	tostring ProficientOrAbove_percent, replace format("%7.4f") force
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	
	tostring ProficientOrAbove_count, replace force
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	drop Lev1_count2 Lev2_count2 Lev3_count2 Lev4_count2 NotProfCount

	gen Lev5_count = ""
	gen Lev5_percent = ""

	gen ProficiencyCriteria = "Levels 3-4"

	gen AvgScaleScore = "--"
	gen ParticipationRate = 100 - LEVEL_NOT_DETERMINED_PCT
	replace ParticipationRate = ParticipationRate/100
	tostring ParticipationRate, replace format("%9.2g") force
	replace ParticipationRate = "*" if ParticipationRate == "."
	
	** Merge with NCES
	gen State_leaid = StateAssignedDistID
	if `year' == 2017{
		replace State_leaid = "0" + State_leaid if substr(State_leaid, 5, 1) == ""
		replace State_leaid = "0" + State_leaid if substr(State_leaid, 6, 1) == ""
		replace State_leaid = "MO-" + State_leaid
	}
	replace State_leaid = "" if DataLevel == 1
	
	merge m:1 State_leaid using "${NCES}/NCES_`prevyear'_District_MO.dta"

	drop if _merge == 2
	drop _merge
	
	if `year' < 2017{
		gen seasch = StateAssignedSchID + State_leaid
	}
	if `year' == 2017{
		gen seasch = subinstr(State_leaid, "MO-", "", .) + "-" + StateAssignedSchID + subinstr(State_leaid, "MO-", "", .)
	}
	
	replace seasch = "" if DataLevel != 3

	merge m:1 seasch using "${NCES}/NCES_`prevyear'_School_MO.dta"
	
	drop if NCESSchoolID == "" & DataLevel == 3
	drop if _merge == 2
	drop _merge
	
	replace StateAbbrev = "MO" if DataLevel == 1
	replace State = "Missouri" if DataLevel == 1
	replace StateFips = 29 if DataLevel == 1
	
	if `year' == 2015{
		replace CountyName = strproper(CountyName)
		replace CountyName= "McDonald County" if CountyCode == "29119"
		replace CountyName= "DeKalb County" if CountyCode == "29063"
	}
	
	if `year' != 2015{
		replace CountyName= "St. Louis City" if CountyCode == "29510"
	}
	
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "Y"
	gen Flag_CutScoreChange_math = "Y"
	gen Flag_CutScoreChange_soc = "Not applicable"
	gen Flag_CutScoreChange_sci = "N"
	
	if `year' == 2017{
		replace Flag_CutScoreChange_ELA = "N"
		replace Flag_CutScoreChange_math = "N"
	}
	
	replace SchName = strtrim(SchName)
	replace SchName = stritrim(SchName)
	
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-0.0010"
	
		** Generating student group total counts (V2.0)
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1
	
	//remove leading zeros for StateAssignedDistID
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
replace DistName= "MIAMI R-I (Bates County)" if NCESDistrictID == "2920820"
replace DistName= "MIAMI R-I (Saline County)" if NCESDistrictID == "2920840"
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
