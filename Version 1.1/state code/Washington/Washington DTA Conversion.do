clear
set more off

cd "/Users/minnamgung/Desktop/SADR/Washington"

global raw "/Users/minnamgung/Desktop/SADR/Washington/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Washington/Output"
global NCES "/Users/minnamgung/Desktop/SADR/Washington/NCES"

global years 2015 2016 2017 2018 2019 2021 2022 2023

** Converting to dta **

foreach a in $years {
		import delimited "${raw}/WA_OriginalData_`a'_all.csv", case(preserve) clear
		save "${output}/WA_AssmtData_`a'_all.dta", replace
}
