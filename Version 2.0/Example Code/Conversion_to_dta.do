clear
set more off
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"
forvalues year = 2014/2021 {
	if `year' == 2020 continue
	foreach subject in ela math {
		foreach type in part count {
			foreach dl in district school {
				import delimited "${EDFacts}/`year'/edfacts`type'`year'`subject'`dl'.csv", clear
				save "${EDFacts}/`year'/edfacts`type'`year'`subject'`dl'.dta", replace
			}
		}
	}
	
	
}
