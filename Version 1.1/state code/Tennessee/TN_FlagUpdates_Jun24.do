clear
set more off

cd "/Volumes/T7/State Test Project/Tennessee/Output"

//Importing

/*
forvalues year = 2010/2023 {
	if `year' == 2020 | `year' == 2016 continue
	
	import delimited "TN_AssmtData_`year'", case(preserve) clear stringcols(_all)
	save "TN_AssmtData_`year'.dta", replace
}
*/

//Updating Flags
forvalues year = 2010/2023 {
if `year' == 2020 | `year' == 2016 continue	
use  "TN_AssmtData_`year'.dta", clear
if `year' == 2013 replace Flag_CutScoreChange_soc = "N"

if `year' == 2018 replace Flag_AssmtNameChange = "Y" if Subject == "soc"

replace CountyCode = "" if CountyCode == "."
save "TN_AssmtData_`year'.dta", replace
export delimited "TN_AssmtData_`year'.csv", replace
}
