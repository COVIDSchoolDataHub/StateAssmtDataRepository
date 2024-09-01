clear
set more off
cd "/Volumes/T7/State Test Project/Tennessee"
global Original "/Volumes/T7/State Test Project/Tennessee/Original Data Files"


forvalues year = 2010/2015 {
	foreach dl in dist sch state {
	import excel "$Original/TN_OriginalData_`year'_all_`dl'.xlsx", firstrow case(preserve) clear
	save "$Original/TN_OriginalData_`year'_`dl'", replace
	}
}

foreach year in 2017 2018 2019 2021 {
	foreach dl in dist sch state {
		import delimited "$Original/TN_OriginalData_`year'_all_`dl'.csv", case(preserve) clear
		save "$Original/TN_OriginalData_`year'_`dl'", replace
	}
}

forvalues year = 2022/2024 {
	foreach dl in dist sch state {
	import excel "$Original/TN_OriginalData_`year'_all_`dl'.xlsx", firstrow case(preserve) clear
	save "$Original/TN_OriginalData_`year'_`dl'", replace
	}
}

import excel TN_Unmerged_2024, firstrow case(preserve) clear
format NCESSchoolID %18.0g
tostring NCESSchoolID, replace usedisplayformat
keep SchName NCESSchoolID SchType SchLevel SchVirtual
save TN_Unmerged_2024, replace
