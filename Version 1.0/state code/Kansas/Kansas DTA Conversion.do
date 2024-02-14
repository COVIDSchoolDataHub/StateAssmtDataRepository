clear
set more off

cd "/Users/maggie/Desktop/Kansas"

global raw "/Users/maggie/Desktop/Kansas/Original Data Files"
global output "/Users/maggie/Desktop/Kansas/Output"
global NCES "/Users/maggie/Desktop/Kansas/NCES/Cleaned"

global years 2015 2016 2017 2018 2019 2021 2022 2023

** Converting to dta **

foreach a in $years {
	if `a' == 2016 {
	import excel "${raw}/KS_OriginalData_`a'_all.xlsx", sheet("AssessmentResults") firstrow clear
	save "${raw}/KS_AssmtData_`a'.dta", replace		
	}
	if `a' != 2016 {
	import excel "${raw}/KS_OriginalData_`a'_all.xlsx", sheet(`a') firstrow clear
	save "${raw}/KS_AssmtData_`a'.dta", replace
	}
}
