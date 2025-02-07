*******************************************************
* TENNESSEE

* File name: 02_TN_DTA
* Last update: 2/6/2025

*******************************************************
* Notes

	* This do file imports TN data csv or excel format files from 2010 through 2024. 
	* It converts it to a STATA .dta file. 
	* This code will need to be updated when newer TN data files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear
set more off

cd "C:/Zelma/Tennessee"

*Imports excel files from 2010 through 2015 and saves it into .dta format.
forvalues year = 2010/2015 {
	foreach dl in dist sch state {
	import excel "$Original/TN_OriginalData_`year'_all_`dl'.xlsx", firstrow case(preserve) clear
	save "$Original/TN_OriginalData_`year'_`dl'", replace
	}
}

*Imports csv files from 2017 through 2021 and saves it into .dta format.
foreach year in 2017 2018 2019 2021 {
	foreach dl in dist sch state {
		import delimited "$Original/TN_OriginalData_`year'_all_`dl'.csv", case(preserve) clear
		save "$Original/TN_OriginalData_`year'_`dl'", replace
	}
}

*Imports excel files from 2022 through 2024 and saves it into .dta format.
forvalues year = 2022/2024 {
	foreach dl in dist sch state {
	import excel "$Original/TN_OriginalData_`year'_all_`dl'.xlsx", firstrow case(preserve) clear
	save "$Original/TN_OriginalData_`year'_`dl'", replace
	}
}

*Imports TN_Unmerged_2024 and saves it as a STATA .dta file.
import excel TN_Unmerged_2024, firstrow case(preserve) clear
format NCESSchoolID %18.0g
tostring NCESSchoolID, replace usedisplayformat
keep SchName NCESSchoolID SchType SchLevel SchVirtual
save TN_Unmerged_2024, replace
