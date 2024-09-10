clear
set more off

cd "/Volumes/T7/State Test Project/Michigan"

global raw "/Volumes/T7/State Test Project/Michigan/Original Data"
global output "/Volumes/T7/State Test Project/Michigan/Original Data"
global NCES "/Volumes/T7/State Test Project/Michigan/NCES"

global years 2015 2016 2017 2018 2019 2021 2022 2023 2024

** Converting to dta **

foreach a in $years {
		import delimited "${raw}/MI_OriginalData_`a'_all.csv", case(preserve) clear
		save "${output}/MI_AssmtData_`a'_all.dta", replace
}

import excel "MI_Unmerged_2024.xlsx", firstrow case(preserve) allstring clear
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
save "MI_Unmerged_2024", replace
