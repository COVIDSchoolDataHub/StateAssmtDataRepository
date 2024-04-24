clear
set more off

global data "/Users/miramehta/Documents/MO State Testing Data"
global output "/Users/miramehta/Documents/MO State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

cd "/Users/miramehta/Documents"

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
	
	bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
	replace StudentGroup_TotalTested = AllStudents_Tested if inlist(StudentGroup, "EL Status", "Economic Status")
	
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
	
	gen flag = 1 if NCESSchoolID == "290825000226" & StudentSubGroup == "White" & Subject == "sci" & GradeLevel == "G05"
	
	forvalues n = 1/4{
		tostring Lev`n'_percent, replace format("%7.3f") force
		tostring Lev`n'_count, replace
		replace Lev`n'_percent = "*" if flag == 1
		replace Lev`n'_count = "*" if flag == 1
	}
	
	** Unmerged Districts
	
	replace NCESDistrictID = "2900607" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace DistType = "State-operated agency" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace DistCharter = "No" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace DistLocale = "City, small" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace CountyName = "Cole County" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	replace CountyCode = "29051" if DistName == "MO VIRTUAL INSTRUCTION PROGRAM"
	drop if inlist(DistName, "NORTHWEST MISSOURI STATE UNIV", "SOUTHWEST MISSOURI STATE UNIV")
		
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save "${output}/MO_AssmtData_`year'.dta", replace
	
	export delimited using "${output}/MO_AssmtData_`year'.csv", replace
}
