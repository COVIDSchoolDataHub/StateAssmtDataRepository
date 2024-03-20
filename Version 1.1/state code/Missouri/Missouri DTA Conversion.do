clear
set more off

cd "/Users/miramehta/Documents"

global data "/Users/miramehta/Documents/MO State Testing Data"
global output "/Users/miramehta/Documents/MO State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global years 2015-2017 2018 2019 2021 2022 2023
global level state district school

** Converting to dta **

foreach a in $level {
	import delimited "${data}/MO_OriginalData_2010-2014_all_`a'.csv", case(preserve) clear
	save "${data}/MO_AssmtData_2010-2014_`a'.dta", replace
	import delimited "${data}/MO_OriginalData_2010-2014_all_`a'disag.csv", case(preserve) clear
	save "${data}/MO_AssmtData_2010-2014_`a'disag.dta", replace
}

foreach a in $years {
	foreach b in $level {
		import excel "${data}/MO_OriginalData_`a'_all_`b'.xlsx", firstrow clear
		save "${data}/MO_AssmtData_`a'_`b'.dta", replace
	}
}
