clear
set more off
cd "/Volumes/T7/State Test Project/Maine"
local Output "/Volumes/T7/State Test Project/Maine/Output"
local dofiles ME_Cleaning_2015.do ME_Cleaning_2016-2019.do ME_Cleaning_2021-2022.do 

foreach file of local dofiles {
	do `file'
}
forvalues year = 2015/2022 {
	if `year' == 2020 {
		continue
	}
use "`Output'/ME_AssmtData_`year'"

	
clear	
}
