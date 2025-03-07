* MICHIGAN

* File name: Michigan DTA Conversion
* Last update: 03/06/2025

*******************************************************
* Notes

	* This do file imports *.csv MI data for 2015-2024 and saves it as *.dta.

*******************************************************

clear

global years 2015 2016 2017 2018 2019 2021 2022 2023 2024

** Converting to dta **

foreach a in $years {
		import delimited "${Original}/MI_OriginalData_`a'_all.csv", case(preserve) clear
		save "${Original_DTA}/MI_AssmtData_`a'_all.dta", replace
}

import excel "${Original}/MI_Unmerged_2024.xlsx", firstrow case(preserve) allstring clear
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
save "${Original_DTA}/MI_Unmerged_2024", replace

import excel "${Original}/MI_NCESUpdates_2018_2024.xlsx", firstrow case(preserve) allstring clear
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
save "${Original_DTA}/MI_NCESUpdates_2018_2024", replace

* END of Michigan DTA Conversion.do
****************************************************
