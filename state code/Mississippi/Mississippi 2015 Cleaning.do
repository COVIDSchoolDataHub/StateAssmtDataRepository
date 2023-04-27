clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

** Cleaning 2014-2015 **

use "${output}/MS_AssmtData_2015_all.dta", clear

** Rename existing variables

rename StateAssignedDistrictID StateAssignedDistID
rename StateAssignedSchoolID StateAssignedSchID
rename SchoolName SchName 

replace Subject = lower(Subject)

** Generating missing variables

gen GradeLevel = ""

replace GradeLevel = "G03" if Grade == 3
replace GradeLevel = "G04" if Grade == 4
replace GradeLevel = "G05" if Grade == 5
replace GradeLevel = "G06" if Grade == 6
replace GradeLevel = "G07" if Grade == 7
replace GradeLevel = "G08" if Grade == 8

drop Grade

gen AssmtName = "PARCC"
gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = ""
gen AssmtType = "Regular"
gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

** Merging Rows

replace DataType = "Z Aggregated by Levels 1-3 and 4-5" if DataType == "State Aggregated by Levels 1-3 and 4-5" | DataType == "Aggregated by Levels 1-3 and 4-5"

sort DataLevel District SchName GradeLevel Subject DataType
replace Levels45PCT = Levels45PCT[_n+1] if missing(Levels45PCT)

drop if DataType == "Z Aggregated by Levels 1-3 and 4-5"
drop DataType Levels13PCT

** Rename existing variables

rename Level1PCT Lev1_percent
rename Level2PCT Lev2_percent
rename Level3PCT Lev3_percent
rename Level4PCT Lev4_percent
rename Level5PCT Lev5_percent
rename TestTakers StudentGroup_TotalTested

gen Lev1_count = ""
gen Lev2_count = ""
gen Lev3_count = ""
gen Lev4_count = ""
gen Lev5_count = ""
gen AvgScaleScore = ""
gen ProficiencyCriteria = "Levels 4-5"
gen ProficientOrAbove_count = ""
gen ParticipationRate = ""
gen SchYear = "2014-15"

** Merging with NCES

replace NCESDistrictID = "2801191" if District == "Mississippi Dept. of Human Services" | District == "Mississippi Dept. Of Human Services"
replace StateAssignedDistID = "2562" if District == "Mississippi Dept. of Human Services" | District == "Mississippi Dept. Of Human Services"
replace NCESSchoolID = "280119101197" if SchName == "Williams School"
replace StateAssignedSchID = "2562008" if SchName == "Williams School"

merge m:1 NCESDistrictID using "${NCES}/NCES_2014_District.dta"

drop if _merge == 2
drop _merge

replace DistName = "MDHS DIVISION OF YOUTH SERVICES" if District == "Mississippi Dept. of Human Services" | District == "Mississippi Dept. Of Human Services"
replace DistName = "University Of Southern Mississippi" if District == "University Of Southern Mississippi"

replace NCESSchoolID = "280018601404" if SchName == "Brooks Elementary School"
replace NCESSchoolID = "280018601416" if SchName == "It Montgomery Elementary School"
replace NCESSchoolID = "280018701408" if SchName == "James C. Rosser Elementary School"
replace NCESSchoolID = "280018601405" if SchName == "John F Kennedy High School"
replace NCESSchoolID = "280243001429" if SchName == "Lauderdale County Education Skills Center"
replace NCESSchoolID = "280383000712" if SchName == "Learning Center Alternative School"
replace NCESSchoolID = "280279000939" if SchName == "Madison Co Alternati"
replace NCESSchoolID = "280018501409" if SchName == "Mcevans School"
replace NCESSchoolID = "280018701412" if SchName == "Moorhead Middle School"
replace NCESSchoolID = "280303001423" if SchName == "Morgantown College Prep"
replace NCESSchoolID = "280303001406" if SchName == "Morgantown Leadership Academy"
replace NCESSchoolID = "280303001397" if SchName == "Natchez Freshman Academy"
replace NCESSchoolID = "280383001424" if SchName == "Puckett Elementary School"
replace NCESSchoolID = "280018501402" if SchName == "Ray Brooks School"
replace NCESSchoolID = "280018701421" if SchName == "Robert L Merritt Mid"
replace NCESSchoolID = "280018601415" if SchName == "Shelby Middle School"
replace NCESSchoolID = "280273000531" if SchName == "West Lowndes Hs"
replace NCESSchoolID = "280162001361" if SchName == "Weston Sr H"
replace NCESSchoolID = "280198001417" if SchName == "William Dean Jr. Elementary"
replace NCESSchoolID = "missing" if SchName == "Dubard School For Language Disorders"

gen seasch = StateAssignedSchID
merge m:1 NCESSchoolID using "${NCES}/NCES_2014_School.dta"

drop if _merge == 2
drop _merge year lea_name county_name District

replace State = 28
replace StateAbbrev = "MS"
replace StateFips = 28

** Aggregating Proficient Data

local level 1 2 3 4 5

foreach a of local level {
	replace Lev`a'_percent = "-100" if Lev`a'_percent == "*"
	destring Lev`a'_percent, replace
	replace Lev`a'_percent = Lev`a'_percent/100
}

generate ProficientOrAbove_percent = Lev4_percent + Lev5_percent

foreach a of local level {
	tostring Lev`a'_percent, replace force
	replace Lev`a'_percent = "*" if Lev`a'_percent == "-1"
}

tostring ProficientOrAbove_percent, replace force format(%4.3f)
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-2.000"

replace ProficientOrAbove_percent = "*" if Levels45PCT == "*"
drop Levels45PCT

** Converting

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

sort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "${output}/MS_AssmtData_2015.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2015.csv", replace
