clear
set more off

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"
global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

local grade 3 4 5 6 7 8
local gradesci 5 8
local level 1 2 3 4
local subject L M
local levelname NM NB NP NA PM PB PP PA

cd "/Users/maggie/Desktop/Mississippi"

use "${output}/MS_AssmtData_2014_ela_mat.dta", clear
append using "${output}/MS_AssmtData_2014_sci.dta"

** Dropping extra variables

drop SCH

** Rename existing variables

rename DISTSCH StateAssignedSchID 
rename DIST StateAssignedDistID
rename DISTRICT_NAME DistName
rename SCHOOL_NAME SchName

** Changing to long

foreach grd of local grade {
	foreach sub of local subject {
		rename G`grd'`sub'N StudentSubGroup_TotalTestedG0`grd'Z`sub'
	}
}

foreach grd of local grade {
	foreach sub of local subject {
		rename G`grd'`sub'SS AvgScaleScoreG0`grd'Z`sub'
	}
}

foreach grdsci of local gradesci {
	rename G`grdsci'SN StudentSubGroup_TotalTestedG0`grdsci'
}

foreach grdsci of local gradesci {
	rename G`grdsci'SSS AvgScaleScoreG0`grdsci'
}

foreach grd of local grade {
	foreach sub of local subject {
			foreach lvl of local levelname {
				rename G`grd'`sub'`lvl' `lvl'G0`grd'Z`sub'
		}
	}
}

foreach grdsci of local gradesci {
		foreach lvl of local levelname {
			rename G`grdsci'S`lvl' `lvl'G0`grdsci'
	}
}

reshape long NM NB NP NA PM PB PP PA StudentSubGroup_TotalTested AvgScaleScore, i(StateAssignedDistID StateAssignedSchID DistName SchName Subject) j(GradeLevel) string

drop if StudentSubGroup_TotalTested == ""

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

split GradeLevel, parse("Z") generate(GradeLevel)

replace Subject = "ela" if GradeLevel2 == "L" 
replace Subject = "math" if GradeLevel2 == "M"

drop GradeLevel GradeLevel2

rename GradeLevel1 GradeLevel

** Generating missing variables

gen StudentGroup = "All Students"
gen StudentSubGroup = StudentGroup

gen ParticipationRate = "--"

gen test1 = ""
gen test2 = ""
foreach a of local level {
	destring Lev`a'_count, gen(Lev`a'_count2) force
	replace test1 = "*" if Lev`a'_count == "*"
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	replace test2 = "*" if Lev`a'_percent == "*"
}

gen ProficientOrAbove_count = Lev3_count2 + Lev4_count2 
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = test1 if test1 != ""
gen ProficientOrAbove_percent = Lev3_percent2 + Lev4_percent2
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = test2 if test2 != ""
drop test1 test2

foreach a of local level {
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2 if Lev`a'_percent != "*"
	drop Lev`a'_count2
	drop Lev`a'_percent2
}

gen DataLevel = "School"
replace DataLevel = "District" if strpos(SchName, "Districtwide Data") > 0
replace DataLevel = "State" if SchName == "Statewide Data"

replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel != "School"
replace SchName = subinstr(SchName, " (E)", "", .)

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

replace StateAssignedDistID = "" if DataLevel == 1
gen State_leaid = StateAssignedDistID

merge m:1 State_leaid using "${NCES}/NCES_2013_District.dta"

drop if _merge == 2
drop _merge

replace StateAssignedSchID = "" if DataLevel != 3
gen seasch = StateAssignedSchID

merge m:1 seasch using "${NCES}/NCES_2013_School.dta"

drop if _merge == 2
drop _merge

** Merging with EDFacts Datasets

gen test = 1
append using "${EDFacts}/2014/edfactscount2014districtmississippi.dta"
merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2014/edfactspart2014districtmississippi.dta", update
drop if _merge == 2
drop _merge

replace SchName = "All Schools" if SchName == ""

append using "${EDFacts}/2014/edfactscount2014schoolmississippi.dta"
merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2014/edfactspart2014schoolmississippi.dta", update
drop if _merge == 2
drop _merge

replace test = 2 if test == .
sort DataLevel NCESDistrictID NCESSchoolID test

replace AvgScaleScore = "--" if AvgScaleScore == ""
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""
local level 1 2 3 4
foreach a of local level {
	replace Lev`a'_percent = "--" if Lev`a'_percent == ""
	replace Lev`a'_count = "--" if Lev`a'_count == ""
}
replace DistName = DistName[_n-1] if test == 2
replace SchName = SchName[_n-1] if test == 2
replace StateAssignedDistID = StateAssignedDistID[_n-1] if StateAssignedDistID == ""
replace StateAssignedSchID = StateAssignedSchID[_n-1] if StateAssignedSchID == ""
replace State_leaid = State_leaid[_n-1] if State_leaid == ""
replace seasch = seasch[_n-1] if seasch == ""
replace DistType = DistType[_n-1] if DistType == .
replace SchType = SchType[_n-1] if SchType == .
replace SchVirtual = SchVirtual[_n-1] if SchVirtual == ""
replace SchLevel = SchLevel[_n-1] if SchLevel == .
replace DistCharter = DistCharter[_n-1] if DistCharter == ""
replace CountyCode = CountyCode[_n-1] if CountyCode == .
replace CountyName = CountyName[_n-1] if CountyName == ""

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test2 = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test2 != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test test2

** Generating new variables

gen SchYear = "2013-14"

gen AssmtName = "MCT2" if Subject != "sci"
replace AssmtName = "MST" if Subject == "sci"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"

replace State = 28
replace StateAbbrev = "MS"
replace StateFips = 28

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/MS_AssmtData_2014.dta", replace

export delimited using "${output}/csv/MS_AssmtData_2014.csv", replace
