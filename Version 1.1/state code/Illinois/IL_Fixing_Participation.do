clear
set more off
cd "/Volumes/T7/State Test Project/Misc Cleaning/IL"
forvalues year = 2015/2021 {
	if `year' == 2020 continue
import delimited IL_AssmtData_`year'.csv, case(preserve) encoding(UTF-8)
replace ParticipationRate = "--" if strpos(ParticipationRate, "n/a") !=0



//Fixing Ranges
replace ParticipationRate = subinstr(ParticipationRate, "≥", ">",.)
replace ParticipationRate = subinstr(ParticipationRate, "≤" , "<",. )

foreach var of varlist ParticipationRate {
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}


save IL_AssmtData_`year', replace
export delimited IL_AssmtData_`year', replace
clear
}
