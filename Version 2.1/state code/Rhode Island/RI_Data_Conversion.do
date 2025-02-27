*******************************************************
* RHODE ISLAND

* File name: RI_Data Conversion
* Last update: 2/27/2025

*******************************************************
* Notes

	* This do file imports and saves RI data in a dta format. 

*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear
foreach subject in ela math sci {
	import excel "$Original/RI_OriginalData_`subject'_2018_2024", firstrow case(preserve) clear
	save "$Original_DTA/RI_OriginalData_`subject'_2018_2024", replace
}

import excel "$Original/RI_2018_2024_NCES ID crosswalk", firstrow case(preserve) clear
rename Year SchYear
rename District DistName
rename School SchName
drop if missing(SchYear)
save "$Original_DTA/RI_NCES_CW1", replace

import excel "$Original/RI_District_School_CW", firstrow case(preserve) clear
keep SchYear DistName SchName NCESSchoolID NCESDistrictID
save "$Original_DTA/RI_NCES_CW2", replace
* END of RI_Data Conversion.do
****************************************************
