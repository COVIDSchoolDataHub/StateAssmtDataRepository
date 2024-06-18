clear
set more off

cd "/Volumes/T7/State Test Project/Michigan"

global raw "/Volumes/T7/State Test Project/Michigan/Original Data"
global output "/Volumes/T7/State Test Project/Michigan/Original Data"
global NCES "/Volumes/T7/State Test Project/Michigan/NCES"

global years 2015 2016 2017 2018 2019 2021 2022 2023

** Converting to dta **

foreach a in $years {
		import delimited "${raw}/MI_OriginalData_`a'_all.csv", case(preserve) clear
		save "${output}/MI_AssmtData_`a'_all.dta", replace
}
