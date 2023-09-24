clear
set more off

cd "/Users/maggie/Desktop/Indiana"

global raw "/Users/maggie/Desktop/Indiana/Original Data Files"
global output "/Users/maggie/Desktop/Indiana/Output"
global NCES "/Users/maggie/Desktop/Indiana/NCES/Cleaned"

//////	ORGANIZING AND APPENDING DATA


//// Create district level data

//math and ela
import excel "/${raw}/Pre 2014/IN_OriginalData_2005-2015_mat_ela_dist", sheet("Fall 2005") cellrange(A3:AU325) clear

rename A StateAssignedDistID
rename B DistName

rename C ProficientOrAbove_countela3
rename D ProficientOrAbove_percentela3

rename E ProficientOrAbove_countmath3
rename F ProficientOrAbove_percentmath3

drop G

rename H ProficientOrAbove_countela4
rename I ProficientOrAbove_percentela4

rename J ProficientOrAbove_countmath4
rename K ProficientOrAbove_percentmath4

drop L

rename M ProficientOrAbove_countela5
rename N ProficientOrAbove_percentela5

rename O ProficientOrAbove_countmath5
rename P ProficientOrAbove_percentmath5

drop Q

rename R ProficientOrAbove_countela6
rename S ProficientOrAbove_percentela6

rename T ProficientOrAbove_countmath6
rename U ProficientOrAbove_percentmath6

drop V

rename W ProficientOrAbove_countela7
rename X ProficientOrAbove_percentela7

rename Y ProficientOrAbove_countmath7
rename Z ProficientOrAbove_percentmath7

drop AA

rename AB ProficientOrAbove_countela8
rename AC ProficientOrAbove_percentela8

rename AD ProficientOrAbove_countmath8
rename AE ProficientOrAbove_percentmath8

drop AF

drop AG AH AI AJ AK AL AM AN AO AP

rename AQ ProficientOrAbove_countela38
rename AR ProficientOrAbove_percentela38

rename AS ProficientOrAbove_countmath38
rename AT ProficientOrAbove_percentmath38

drop AU

tostring Proficient*, replace force

reshape long ProficientOrAbove_countela ProficientOrAbove_percentela ProficientOrAbove_countmath ProficientOrAbove_percentmath, i(StateAssignedDistID) j(GradeLevel) string

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(StateAssignedDistID GradeLevel) j(Subject) string

gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"

drop if ProficientOrAbove_count == ""

gen DataLevel = "District"


////	MERGE NCES

gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "/${NCES}/NCES_2004_District.dta"

tab DistName StateAssignedDistID if _merge == 1 & DataLevel != "State"

drop if _merge==2
drop _merge

gen seasch = ""

merge m:1 seasch using "/${NCES}/NCES_2004_School.dta"

drop if _merge==2
drop _merge


/////	FINISH CLEANING


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace SchName = "All Schools"

gen StateAssignedSchID = ""

gen SchYear = "2004-05"

gen AssmtName = "ISTEP+"
gen AssmtType = "Regular"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

replace GradeLevel = "G38" if GradeLevel == "38"
replace GradeLevel = "G0" + GradeLevel if GradeLevel != "G38"

drop if ProficientOrAbove_count == ""

gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""

local level 1 2 3

foreach a of local level{
	gen Lev`a'_percent = "--"
	gen Lev`a'_count = "--"
}

replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "***"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "***"
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "***"

gen AvgScaleScore = "--"
gen ParticipationRate = "--"

gen ProficiencyCriteria = "Levels 2 and 3"

replace State = 18
replace StateAbbrev = "IN"
replace StateFips = 18

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IN_AssmtData_2005.dta", replace

export delimited using "${output}/csv/IN_AssmtData_2005.csv", replace
