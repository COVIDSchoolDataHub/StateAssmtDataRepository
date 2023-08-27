clear
set more off

global output "/Users/maggie/Desktop/Mississippi/Output"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"

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
		rename G`grd'`sub'N StudentGroup_TotalTestedG0`grd'Z`sub'
	}
}

foreach grd of local grade {
	foreach sub of local subject {
		rename G`grd'`sub'SS AvgScaleScoreG0`grd'Z`sub'
	}
}

foreach grdsci of local gradesci {
	rename G`grdsci'SN StudentGroup_TotalTestedG0`grdsci'
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

reshape long NM NB NP NA PM PB PP PA StudentGroup_TotalTested AvgScaleScore, i(StateAssignedDistID StateAssignedSchID DistName SchName Subject) j(GradeLevel) string

drop if StudentGroup_TotalTested == ""

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

gen SchYear = "2013-14"

gen AssmtName = "MCT"
gen AssmtType = "Regular"

gen StudentGroup = "All Students"
gen StudentSubGroup = StudentGroup
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested

gen ProficiencyCriteria = "Levels 3-4"

gen ParticipationRate = "--"

gen test1 = ""
gen test2 = ""
foreach a of local level {
	gen Lev`a'_count2 = Lev`a'_count
	destring Lev`a'_count2, replace force
	replace test1 = "*" if Lev`a'_count == "*"
	gen Lev`a'_percent2 = Lev`a'_percent
	destring Lev`a'_percent2, replace force
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

** Generating new variables

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
