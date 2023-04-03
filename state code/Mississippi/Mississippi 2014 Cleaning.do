clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

** Cleaning 2013-2014 ELA & Math **

use "${output}/MS_AssmtData_2014_ela_mat.dta", clear

** Rename existing variables

rename DISTRICT_NAME DistName
rename DIST StateAssignedDistID
rename SCHOOL_NAME SchName
rename SCH StateAssignedSchID 

** Changing to long

global grade 3 4 5 6 7 8
global subject L M
global data NM NB NP NA PM PB PP PA

foreach a in $grade {
	foreach b in $subject {
		foreach c in $data {
			rename G`a'`b'`c' `c'G`a'Z`b'
		}
	}
}

foreach a in $grade {
	foreach b in $subject {
			rename G`a'`b'N StudentGroup_TotalTestedG`a'Z`b'
	}
}

foreach a in $grade {
	foreach b in $subject {
			rename G`a'`b'SS AvgScaleScoreG`a'Z`b'
	}
}

reshape long NM NB NP NA PM PB PP PA StudentGroup_TotalTested AvgScaleScore, i(DISTSCH StateAssignedDistID StateAssignedSchID DistName SchName)  j(GradeLevel) string

** Generating missing variables

split GradeLevel, parse("Z") generate(Subject)
drop GradeLevel

rename Subject1 GradeLevel
rename Subject2 Subject

replace Subject = "ela" if Subject == "L" 
replace Subject = "math" if Subject == "M"

replace GradeLevel = "G03" if GradeLevel == "G3"
replace GradeLevel = "G04" if GradeLevel == "G4"
replace GradeLevel = "G05" if GradeLevel == "G5"
replace GradeLevel = "G06" if GradeLevel == "G6"
replace GradeLevel = "G07" if GradeLevel == "G7"
replace GradeLevel = "G08" if GradeLevel == "G8"

gen AssmtName = "MCT2"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "Districtwide Data"
replace DataLevel = "State" if SchName == "Statewide Data"

gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

** Rename existing variables

rename NM Lev1_count
rename NB Lev2_count
rename NP Lev3_count
rename NA Lev4_count
gen Lev5_count = ""

rename PM Lev1_percent
rename PB Lev2_percent
rename PP Lev3_percent
rename PA Lev4_percent
gen Lev5_percent = ""
gen ProficiencyCriteria = ""
gen ProficientOrAbove_count = ""
gen ProficientOrAbove_percent = ""
gen ParticipationRate = ""
gen SchYear = "2013-2014"

** Merging with NCES

replace DISTSCH = "" if DataLevel == "District" | DataLevel == "State"
rename DISTSCH seasch
replace DistName = subinstr(DistName, " (E)", "", .)
merge m:1 DistName using "${NCES}/NCES_2013_District.dta"
drop if _merge == 2
drop _merge
merge m:1 seasch using "${NCES}/NCES_2013_School.dta"
drop if _merge == 2
drop _merge year lea_name
replace SchName = "" if DataLevel == "District" | DataLevel == "State"
replace DistName = "" if DataLevel == "State"
replace State = 28
replace StateAbbrev = "MS"
replace StateFips = 28

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "${output}/MS_AssmtData_2014_ela_mat.dta", replace

** Cleaning 2013-2014 Science **

use "${output}/MS_AssmtData_2014_sci.dta", clear

** Rename existing variables

rename DISTRICT_NAME DistName
rename DIST StateAssignedDistID
rename SCHOOL_NAME SchName
rename SCH StateAssignedSchID 

** Changing to long

global grade 5 8
global data NM NB NP NA PM PB PP PA

foreach a in $grade {
		foreach b in $data {
			rename G`a'S`b' `b'G`a'
	}
}

foreach a in $grade {
			rename G`a'SN StudentGroup_TotalTestedG`a'
}

foreach a in $grade {
			rename G`a'SSS AvgScaleScoreG`a'
}

reshape long NM NB NP NA PM PB PP PA StudentGroup_TotalTested AvgScaleScore, i(DISTSCH StateAssignedDistID StateAssignedSchID DistName SchName)  j(GradeLevel) string

** Generating missing variables

gen Subject = "sci"

replace GradeLevel = "G05" if GradeLevel == "G5"
replace GradeLevel = "G08" if GradeLevel == "G8"

gen AssmtName = "MST2"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen AssmtType = "Regular"

gen DataLevel = "School"
replace DataLevel = "District" if SchName == "Districtwide Data"
replace DataLevel = "State" if SchName == "Statewide Data"

gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

** Rename existing variables

rename NM Lev1_count
rename NB Lev2_count
rename NP Lev3_count
rename NA Lev4_count
gen Lev5_count = ""

rename PM Lev1_percent
rename PB Lev2_percent
rename PP Lev3_percent
rename PA Lev4_percent
gen Lev5_percent = ""
gen ProficiencyCriteria = ""
gen ProficientOrAbove_count = ""
gen ProficientOrAbove_percent = ""
gen ParticipationRate = ""
gen SchYear = "2013-2014"

** Merging with NCES

replace DISTSCH = "" if DataLevel == "District" | DataLevel == "State"
rename DISTSCH seasch
merge m:1 DistName using "${NCES}/NCES_2013_District.dta"
drop if _merge == 2
drop _merge
merge m:1 seasch using "${NCES}/NCES_2013_School.dta"
sort _merge SchName
order _merge SchName
drop if _merge == 2
drop _merge year lea_name
replace SchName = "" if DataLevel == "District" | DataLevel == "State"
replace DistName = "" if DataLevel == "State"
replace State = 28
replace StateAbbrev = "MS"
replace StateFips = 28

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "${output}/MS_AssmtData_2014_sci.dta", replace

** Appending subjects

use "${output}/MS_AssmtData_2014_ela_mat.dta", clear

append using "${output}/MS_AssmtData_2014_sci.dta"

sort StateAssignedDistID StateAssignedSchID GradeLevel Subject

save "${output}/MS_AssmtData_2014.dta", replace

export delimited using "/Users/maggie/Desktop/Mississippi/Output/csv/MS_AssmtData_2014.csv", replace
