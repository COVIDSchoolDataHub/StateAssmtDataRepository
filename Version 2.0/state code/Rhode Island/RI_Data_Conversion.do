clear
set more off

cd "/Volumes/T7/State Test Project/Rhode Island"
global Original "/Volumes/T7/State Test Project/Rhode Island/Original"
global Output "/Volumes/T7/State Test Project/Rhode Island/Output"
global NCES "/Volumes/T7/State Test Project/Rhode Island/NCES"

foreach subject in ela math sci {
	import excel "$Original/RI_OriginalData_`subject'_2018_2024", firstrow case(preserve) clear
	save "$Original/RI_OriginalData_`subject'_2018_2024", replace
}

import excel "RI_2018_2024_NCES ID crosswalk", firstrow case(preserve) clear
rename Year SchYear
rename District DistName
rename School SchName
drop if missing(SchYear)
save "RI_NCES_CW1", replace

import excel "RI_District_School_CW", firstrow case(preserve) clear
keep SchYear DistName SchName NCESSchoolID NCESDistrictID
save "RI_NCES_CW2", replace
