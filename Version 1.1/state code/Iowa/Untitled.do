clear
set more off

****************************
** Set working directory: **
****************************
cd "/Users/mnamgung/Desktop/Oregon/Output"

global years 2015 2016 2017 2018 2019 2021 2022 2023

local variables "State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth"

foreach a in $years {
	
	import delimited "OR_AssmtData_`a'.csv", case(preserve) clear
	
	di `a'
	
**(8) Levels 

foreach v of varlist Lev* ProficientOrAbove_percent ParticipationRate {
	gen n`v'=`v'
	destring n`v', replace i(* -) 
}

foreach v of varlist nLev*percent nProficientOrAbove_percent nParticipationRate {
		if `v' >1  & !missing(`v') {
		di as error "`v' is not a decimal"
	}
}

egen tot=rowtotal(nLev*percent)
gen row=_n

tab ProficiencyCriteria

egen check_count=rowtotal(nLev3_count nLev4_count)
egen check_perc=rowtotal(nLev3_percent nLev4_percent)

preserve
drop if Lev3_percent == "*"
drop if Lev4_percent == "*"
drop if Lev3_percent == "--"
drop if Lev4_percent == "--"
drop if Lev3_count == "*"
drop if Lev4_count == "*"
drop if Lev3_count == "--"
drop if Lev4_count == "--"
destring ProficientOrAbove_count, gen(xProficientOrAbove_count) force
destring ProficientOrAbove_percent, gen(xProficientOrAbove_percent) force
list row NCESSchoolID NCESDistrictID if check_count != xProficientOrAbove_count
list row NCESSchoolID NCESDistrictID if !inrange(check_perc, xProficientOrAbove_percent - 0.01, xProficientOrAbove_percent + 0.01)
restore

drop tot nLev* check* nProficientOrAbove_percent nParticipationRate row
}
