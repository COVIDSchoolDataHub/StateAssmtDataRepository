clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global output "/Users/maggie/Desktop/Mississippi/Output"
global MS "/Users/maggie/Desktop/Mississippi/Missing Schools"
global years 2016 2017 2018 2019 2021 2022

foreach a in $years {
	
	use "${output}/MS_AssmtData_`a'.dta", clear
	keep if DataLevel == "School"
	
	drop State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType CountyName CountyCode AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate
	
	order DistName SchName SchYear
	
	gen Charter = ""
	gen NCESSchoolID = ""
	gen SchoolType = ""
	gen Virtual = ""
	gen seasch = ""
	gen SchoolLevel = ""
	gen StateAssignedDistID = ""
	gen StateAssignedSchID = ""
	
	sort DistName SchName
	quietly by DistName SchName:  gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	replace Subject = "" if dup == 1
	replace GradeLevel = "" if dup == 1
	drop dup

	save "${MS}/Missing Schools_`a'.dta", replace
	}

use "${MS}/Missing Schools_2016.dta", clear
append using "${MS}/Missing Schools_2017.dta"
append using "${MS}/Missing Schools_2018.dta"
append using "${MS}/Missing Schools_2019.dta"
append using "${MS}/Missing Schools_2021.dta"
append using "${MS}/Missing Schools_2022.dta"
sort DistName SchName SchYear
quietly by DistName SchName:  gen dup = cond(_N==1,0,_n)
drop if dup > 1
replace SchYear = "" if dup == 1
drop dup

save "${MS}/Missing Schools.dta", replace
export delimited using "${MS}/Missing Schools.csv", replace



