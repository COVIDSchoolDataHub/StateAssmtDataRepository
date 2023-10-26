clear
set more off

cd "/Users/maggie/Desktop/Missouri"

global raw "/Users/maggie/Desktop/Missouri/Original Data Files"
global output "/Users/maggie/Desktop/Missouri/Output"
global NCES "/Users/maggie/Desktop/Missouri/NCES/Cleaned"

global years 2015-2017 2018 2019 2021 2022
global data state district school

** CoMOerting to dta **

foreach a in $data {
	import delimited "${raw}/MO_OriginalData_2010-2014_all_`a'.csv", case(preserve) clear
	save "${output}/MO_AssmtData_2010-2014_`a'.dta", replace
	import delimited "${raw}/MO_OriginalData_2010-2014_all_`a'disag.csv", case(preserve) clear
	save "${output}/MO_AssmtData_2010-2014_`a'disag.dta", replace
}

foreach a in $years {
	foreach b in $data {
		import excel "${raw}/MO_OriginalData_`a'_all_`b'.xlsx", firstrow clear
		save "${output}/MO_AssmtData_`a'_`b'.dta", replace
	}
}
