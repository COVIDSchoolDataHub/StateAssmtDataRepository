clear
set more off
set trace off
global raw "/Volumes/T7/State Test Project/Washington/Original Data Files"
global output "/Volumes/T7/State Test Project/Washington/Output"
global NCESOLD "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/Washington/NCES"

global years 2015 2016 2017 2018 2019 2021 2022 2023

** Converting to dta **

foreach a in $years {
		import delimited "${raw}/WA_OriginalData_`a'_all.csv", case(preserve) clear
		save "${output}/WA_AssmtData_`a'_all.dta", replace
}
