clear
set more off
global raw "C:\Users\philb\Downloads\Kentucky\raw\"
global clean "C:\Users\philb\Downloads\Kentucky\clean\"
global nces "C:\Users\philb\Downloads\NCES School Files, Fall 1997-Fall 2021\"



import delimited "${raw}KY_OriginalData_2021_all.csv", case(preserve) stringcols(_all)


gen SchYear = substr(SCHOOLYEAR, 1, 4) + "-"+ substr(SCHOOLYEAR, 7, 2) 

drop SCHOOLYEAR

label def DataLevel 1 "State" 2 "District" 3 "School"
gen DataLevel = ""
replace DataLevel = "District" if SCHOOLNAME == "---District Total---"
replace DataLevel = "State" if SCHOOLNAME == "---State Total---"
replace DataLevel = "School" if DataLevel != "District" & DataLevel != "State"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 

gen deprecated_SCH_NAME = SCHOOLNAME
rename SCHOOLNAME SchName
replace SchName = "All Schools" if deprecated_SCH_NAME == "---District Total---"
rename DISTRICTNAME DistName
replace SchName = "All Schools" if deprecated_SCH_NAME == "---State Total---"
replace DistName = "All Districts" if deprecated_SCH_NAME == "---State Total---"
drop deprecated_SCH_NAME

rename DISTRICTNUMBER StateAssignedDistID

// only if SCH_CD has length 6
rename SCHOOLNUMBER StateAssignedSchID

replace StateAssignedDistID = "" if SchName == "All Schools" & DistName == "All Districts"

gen AssmtName = "KSA"
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
replace StudentGroup = "All Students" if DEMOGRAPHIC == "All Students"
replace StudentGroup = "Gender" if DEMOGRAPHIC == "Male" | DEMOGRAPHIC == "Female"
replace StudentGroup = "RaceEth" if DEMOGRAPHIC == "White (non-Hispanic)" | DEMOGRAPHIC == "African American" | DEMOGRAPHIC == "Hispanic or Latino" | DEMOGRAPHIC == "Asian" | DEMOGRAPHIC == "American Indian or Alaska Native" | DEMOGRAPHIC == "Native Hawaiian or Pacific Islander" | DEMOGRAPHIC == "Two or More Races"
replace StudentGroup = "EL Status" if DEMOGRAPHIC == "English Learner" | DEMOGRAPHIC == "Non-English Learner"
replace StudentGroup = "Economic Status" if DEMOGRAPHIC == "Economically Disadvantaged" | DEMOGRAPHIC == "Non-Economically Disadvantaged"

destring NAPDPOPULATION, replace force
rename NAPDPOPULATION StudentSubGroup_TotalTested

bysort StateAssignedDistID StateAssignedSchID StudentGroup Grade Subject SchYear: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested)

replace DEMOGRAPHIC = "Black or African American" if DEMOGRAPHIC == "African American"
replace DEMOGRAPHIC = "Native Hawaiian or Pacific Islander" if DEMOGRAPHIC == "Native Hawaiian or Other Pacific Islander"
replace DEMOGRAPHIC = "Two or More" if DEMOGRAPHIC == "Two or More Races"
replace DEMOGRAPHIC = "White" if DEMOGRAPHIC == "White (non-Hispanic)"
replace DEMOGRAPHIC = "English Proficient" if DEMOGRAPHIC == "Non-English Learner"
replace DEMOGRAPHIC = "Not Economically Disadvantaged" if DEMOGRAPHIC == "Non-Economically Disadvantaged"

drop if StudentGroup == ""

// 2016+ : drop Gifted/Talented

rename DEMOGRAPHIC StudentSubGroup

rename NOVICE Lev1_percent
rename APPRENTICE Lev2_percent
rename PROFICIENT Lev3_percent
rename DISTINGUISHED Lev4_percent
rename PROFICIENTDISTINGUISHED ProficientOrAbove_percent


gen ProficiencyCriteria = "Lev3 and Lev4"

rename PARTICIPATIONRATE ParticipationRate
destring ProficientOrAbove_percent, replace force

gen Flag_AssmtNameChange = "Y"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_read = "N"
	gen Flag_CutScoreChange_oth = "N"

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${clean}KY_AssmtData_2021", replace