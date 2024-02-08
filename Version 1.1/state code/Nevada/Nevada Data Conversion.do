clear
set more off

cd "/Users/maggie/Desktop/Nevada"

global raw "/Users/maggie/Desktop/Nevada/Original Data Files"
global output "/Users/maggie/Desktop/Nevada/Output"
global NCES "/Users/maggie/Desktop/Nevada/NCES/Cleaned"

global years 2017 2018 2019 2021 2022 2023
global subject ela math sci

** Converting to dta **

import delimited "${raw}/NV_OriginalData_2016_ela.csv", varnames(3) case(preserve) clear
save "${output}/NV_AssmtData_2016_ela.dta", replace

import delimited "${raw}/NV_OriginalData_2016_math.csv", varnames(3) case(preserve) clear
save "${output}/NV_AssmtData_2016_math.dta", replace

foreach a in $years {
	foreach b in $subject {
		import delimited "${raw}/NV_OriginalData_`a'_`b'.csv", varnames(3) case(preserve) clear
		save "${output}/NV_AssmtData_`a'_`b'.dta", replace
	}
}
