clear
set more off

cd "/Users/minnamgung/Desktop/SADR/Michigan"

global raw "/Users/minnamgung/Desktop/SADR/Michigan/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Michigan/Output"
global NCES "/Users/minnamgung/Desktop/SADR/Michigan/NCES"

global years 2015 2016 2017 2018 2019 2021 2022 2023

** Converting to dta **

foreach a in $years {
		import delimited "${raw}/MI_OriginalData_`a'_all.csv", case(preserve) clear
		save "${output}/MI_AssmtData_`a'_all.dta", replace
}
