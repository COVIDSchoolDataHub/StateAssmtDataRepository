clear
set more off

cd "/Users/maggie/Desktop/Washington"

global raw "/Users/maggie/Desktop/Washington/Original Data Files"
global output "/Users/maggie/Desktop/Washington/Output"
global NCES "/Users/maggie/Desktop/Washington/NCES/Cleaned"

global years 2015 2016 2017 2018 2019 2021 2022

** Converting to dta **

foreach a in $years {
		import delimited "${raw}/WA_OriginalData_`a'_all.csv", case(preserve) clear
		save "${output}/WA_AssmtData_`a'_all.dta", replace
}
