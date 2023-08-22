clear
set more off

cd "/Users/maggie/Desktop/Michigan"

global raw "/Users/maggie/Desktop/Michigan/Original Data Files"
global output "/Users/maggie/Desktop/Michigan/Output"
global NCES "/Users/maggie/Desktop/Michigan/NCES/Cleaned"

global years 2015 2016 2017 2018 2019 2021 2022

** Converting to dta **

foreach a in $years {
		import delimited "${raw}/MI_OriginalData_`a'_all.csv", case(preserve) clear
		save "${output}/MI_AssmtData_`a'_all.dta", replace
}
