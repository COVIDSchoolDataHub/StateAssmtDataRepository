set more off
global raw "C:\Users\philb\Downloads\Kentucky\raw\"
global clean "C:\Users\philb\Downloads\Kentucky\clean\"
global nces "C:\Users\philb\Downloads\NCES School Files, Fall 1997-Fall 2021\"

forvalues year = 2012/2017 {
	clear
	import excel "${raw}KY_OriginalData_`year'_all.xlsx", firstrow allstring case(preserve)
	gen SchYear = substr(SCH_YEAR, 1, 4) + "-"+ substr(SCH_YEAR, 7, 2) 

	drop SCH_YEAR

	label def DataLevel 1 "State" 2 "District" 3 "School"
	gen DataLevel = ""
	replace DataLevel = "District" if SCH_NAME == "---District Total---"
	replace DataLevel = "State" if SCH_NAME == "---State Total---"
	replace DataLevel = "School" if DataLevel != "District" & DataLevel != "State"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel 

	gen deprecated_SCH_NAME = SCH_NAME
	rename SCH_NAME SchName
	replace SchName = "All Schools" if deprecated_SCH_NAME == "---District Total---"
	rename DIST_NAME DistName
	replace SchName = "All Schools" if deprecated_SCH_NAME == "---State Total---"
	replace DistName = "All Districts" if deprecated_SCH_NAME == "---State Total---"
	drop deprecated_SCH_NAME

	// only if SCH_CD has length 6
	gen StateAssignedDistID = substr(SCH_CD, 1, 3)

	// only if SCH_CD has length 6
	gen StateAssignedSchID = substr(SCH_CD, 4, 3)

	replace StateAssignedDistID = "" if SchName == "All Schools" & DistName == "All Districts"

	drop SCH_CD

	rename TEST_TYPE AssmtName
	gen AssmtType = "Regular*"

	replace CONTENT_TYPE = "math" if CONTENT_TYPE == "Mathematics"
	replace CONTENT_TYPE = "sci" if CONTENT_TYPE == "Science"
	replace CONTENT_TYPE = "soc" if CONTENT_TYPE == "Social Studies"
	replace CONTENT_TYPE = "wri" if CONTENT_TYPE == "Writing"
	replace CONTENT_TYPE = "ela" if CONTENT_TYPE == "Reading"
	drop if CONTENT_TYPE == "Language Mechanics"
	rename CONTENT_TYPE Subject

	replace GRADE_LEVEL = "G03" if GRADE_LEVEL == "03"
	replace GRADE_LEVEL = "G04" if GRADE_LEVEL == "04"
	replace GRADE_LEVEL = "G05" if GRADE_LEVEL == "05"
	replace GRADE_LEVEL = "G06" if GRADE_LEVEL == "06"
	replace GRADE_LEVEL = "G07" if GRADE_LEVEL == "07"
	replace GRADE_LEVEL = "G08" if GRADE_LEVEL == "08"
	replace GRADE_LEVEL = "G09" if GRADE_LEVEL == "09"
	replace GRADE_LEVEL = "G10" if GRADE_LEVEL == "10"
	replace GRADE_LEVEL = "G11" if GRADE_LEVEL == "11"
	replace GRADE_LEVEL = "G12" if GRADE_LEVEL == "12"
	rename GRADE_LEVEL GradeLevel


	gen StudentGroup = ""
	replace StudentGroup = "All Students" if DISAGG_LABEL == "All Students"
	replace StudentGroup = "Gender" if DISAGG_LABEL == "Male" | DISAGG_LABEL == "Female"
	replace StudentGroup = "RaceEth" if DISAGG_LABEL == "White (Non-Hispanic)" | DISAGG_LABEL == "African American" | DISAGG_LABEL == "Hispanic" | DISAGG_LABEL == "Asian" | DISAGG_LABEL == "American Indian or Alaska Native" | DISAGG_LABEL == "Native Hawaiian or Other Pacific Islander" | DISAGG_LABEL == "Two or more races"
	replace StudentGroup = "EL Status" if DISAGG_LABEL == "Limited English Proficiency"
	replace StudentGroup = "Economic Status" if DISAGG_LABEL == "Free/Reduced-Price Meals"

	destring NBR_TESTED, replace force
	rename NBR_TESTED StudentSubGroup_TotalTested

	bysort StateAssignedDistID StateAssignedSchID StudentGroup Grade Subject SchYear: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

	replace DISAGG_LABEL = "Black or African American" if DISAGG_LABEL == "African American"
	replace DISAGG_LABEL = "Native Hawaiian or Pacific Islander" if DISAGG_LABEL == "Native Hawaiian or Other Pacific Islander"
	replace DISAGG_LABEL = "Two or More" if DISAGG_LABEL == "Two or more races"
	replace DISAGG_LABEL = "White" if DISAGG_LABEL == "White (Non-Hispanic)"
	replace DISAGG_LABEL = "Hispanic or Latino" if DISAGG_LABEL == "Hispanic"
	replace DISAGG_LABEL = "English Learner" if DISAGG_LABEL == "Limited English Proficiency"
	replace DISAGG_LABEL = "English Learner" if DISAGG_LABEL == "English Learners"
	replace DISAGG_LABEL = "Economically Disadvantaged" if DISAGG_LABEL == "Free/Reduced-Price Meals"

	drop if DISAGG_LABEL == "Migrant" | DISAGG_LABEL == "Disability-With IEP (Total)" | DISAGG_LABEL == "Disability-With IEP (not including Alternate)" | DISAGG_LABEL == "Disability-With Accommodation (not including Alternate)" | DISAGG_LABEL == "Disability-Alternate Only" | DISAGG_LABEL == "Gap Group (non-duplicated)" | DISAGG_LABEL == "Gifted/Talented" | DISAGG_LABEL == "Homeless"

	rename DISAGG_LABEL StudentSubGroup

	rename PCT_NOVICE Lev1_percent
	rename PCT_APPRENTICE Lev2_percent
	rename PCT_PROFICIENT Lev3_percent
	rename PCT_DISTINGUISHED Lev4_percent
	rename PCT_PROFICIENT_DISTINGUISHED ProficientOrAbove_percent

	// Make Lev5 variable, but blank


	// AvgScaleScore blank: --

	gen ProficiencyCriteria = "Lev3 and Lev4"
	destring ProficientOrAbove_percent, replace force
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_read = "N"
	gen Flag_CutScoreChange_oth = "N"
	
	if (`year' >= 2014) {
		rename PARTICIP_RATE ParticipationRate
	}
	else {
		gen ParticipationRate = "--"
	}
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save "${clean}/KY_AssmtData_`year'", replace
}

