clear
set more off
global raw "C:\Users\philb\Downloads\Kentucky\raw\"
global clean "C:\Users\philb\Downloads\Kentucky\clean\"
global nces "C:\Users\philb\Downloads\NCES School Files, Fall 1997-Fall 2021\"


forvalues year = 2018/2019 {
	clear

	import excel "${raw}KY_OriginalData_`year'_all.xlsx", firstrow allstring case(preserve) sheet("DATA")


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

	gen AssmtName = "KPREP"
	gen AssmtType = "Regular*"

	replace SUBJECT = "math" if SUBJECT == "MA"
	replace SUBJECT = "sci" if SUBJECT == "SC"
	replace SUBJECT = "soc" if SUBJECT == "SS"
	replace SUBJECT = "wri" if SUBJECT == "WR"
	replace SUBJECT = "ela" if SUBJECT == "RD"
	rename SUBJECT Subject

	// ela, eng?
	replace GRADE = "G03" if GRADE == "03"
	replace GRADE = "G04" if GRADE == "04"
	replace GRADE = "G05" if GRADE == "05"
	replace GRADE = "G06" if GRADE == "06"
	replace GRADE = "G07" if GRADE == "07"
	replace GRADE = "G08" if GRADE == "08"
	replace GRADE = "G09" if GRADE == "09"
	replace GRADE = "G10" if GRADE == "10"
	replace GRADE = "G11" if GRADE == "11"
	replace GRADE = "G12" if GRADE == "12"
	rename GRADE GradeLevel


	gen StudentGroup = ""
	replace StudentGroup = "All Students" if DEMOGRAPHIC == "TST"
	replace StudentGroup = "Gender" if DEMOGRAPHIC == "SXM" | DEMOGRAPHIC == "SXF"
	replace StudentGroup = "RaceEth" if DEMOGRAPHIC == "ETW" | DEMOGRAPHIC == "ETB" | DEMOGRAPHIC == "ETH" | DEMOGRAPHIC == "ETA" | DEMOGRAPHIC == "ETI" | DEMOGRAPHIC == "ETP" | DEMOGRAPHIC == "ETO" | DEMOGRAPHIC == "ETX"
	replace StudentGroup = "EL Status" if DEMOGRAPHIC == "LEP" | DEMOGRAPHIC == "LEN"
	replace StudentGroup = "Economic Status" if DEMOGRAPHIC == "LUP" | DEMOGRAPHIC == "LUN"

	destring TESTED, replace force
	rename TESTED StudentSubGroup_TotalTested

	bysort StateAssignedDistID StateAssignedSchID StudentGroup Grade Subject SchYear: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

	replace DEMOGRAPHIC = "All Students" if DEMOGRAPHIC == "TST"
	replace DEMOGRAPHIC = "American Indian or Alaska Native" if DEMOGRAPHIC == "ETI"
	replace DEMOGRAPHIC = "Black or African American" if DEMOGRAPHIC == "ETB"
	replace DEMOGRAPHIC = "Native Hawaiian or Pacific Islander" if DEMOGRAPHIC == "ETP"
	replace DEMOGRAPHIC = "Two or More" if DEMOGRAPHIC == "ETO"
	replace DEMOGRAPHIC = "White" if DEMOGRAPHIC == "ETW"
	replace DEMOGRAPHIC = "Hispanic or Latino" if DEMOGRAPHIC == "ETH"
	replace DEMOGRAPHIC = "Unknown" if DEMOGRAPHIC == "ETX"
	replace DEMOGRAPHIC = "English Learner" if DEMOGRAPHIC == "LEP"
	replace DEMOGRAPHIC = "English Proficient" if DEMOGRAPHIC == "LEN"
	replace DEMOGRAPHIC = "Economically Disadvantaged" if DEMOGRAPHIC == "LUP"
	replace DEMOGRAPHIC = "Not Economically Disadvantaged" if DEMOGRAPHIC == "LUN"
	replace DEMOGRAPHIC = "Male" if DEMOGRAPHIC == "SXM"
	replace DEMOGRAPHIC = "Female" if DEMOGRAPHIC == "SXF"
	replace DEMOGRAPHIC = "Unknown" if DEMOGRAPHIC == "SXX"


	drop if StudentGroup == ""

	rename DEMOGRAPHIC StudentSubGroup

	rename NOVICE Lev1_percent
	rename APPRENTICE Lev2_percent
	rename PROFICIENT Lev3_percent
	rename distinguished Lev4_percent
	rename PROFICIENT_DISTINGUISHED ProficientOrAbove_percent


	gen ProficiencyCriteria = "Lev3 and Lev4"

	rename PART_RATE ParticipationRate
	destring ProficientOrAbove_percent, replace force

	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_read = "N"
	gen Flag_CutScoreChange_oth = "N"
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	save "${clean}/KY_AssmtData_`year'", replace
}