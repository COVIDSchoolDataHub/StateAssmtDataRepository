clear
set more off
local Original "/Volumes/T7/State Test Project/District of Columbia/Original Data"
local Output "/Volumes/T7/State Test Project/District of Columbia/Output"
local NCES "/Volumes/T7/State Test Project/NCES"
cd "/Volumes/T7/State Test Project/District of Columbia"
local dofiles DC_2015 DC_2016 DC_2017 DC_2018 DC_2019 DC_2022 DC_2023 DC_ParticipationRate_2015_2022

foreach file of local dofiles {
	do `file'
}

//Response to R2
forvalues year = 2015/2023 {
if `year' == 2020 | `year' == 2021 continue
use "`Output'/DC_AssmtData_`year'"
foreach var of varlist Lev*_percent ParticipationRate ProficientOrAbove_percent {
	replace `var' = subinstr(`var', "=","",.)
	replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
	replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}

save "`Output'/DC_AssmtData_`year'.dta", replace
export delimited "`Output'/DC_AssmtData_`year'.csv", replace


clear
}
