* OHIO

* File name: OH Importing Raw Data
* Last update: 03/10/2025

*******************************************************
* Notes

	* This do file imports *.txt 2016-2024 OH data.
	* The files are saved as *.dta by level.
	* The files are appended and saved as a combined file.
	* The combined file is then used in subsequent yearly do files.
*******************************************************

clear

forvalues n = 2016/2024{
	if `n' == 2020{
		continue
	}
	local levels "sch lea state"
	foreach lev of local levels{
		import delimited "$Original/brownuniv_`lev'_testlev24.txt", clear
		keep if school_year == `n'
		gen DataLevel = "`lev'"
		tostring *_ct, replace
		save "$Original_DTA/OH_OriginalData_`n'_`lev'.dta", replace
	}
	append using "$Original_DTA/OH_OriginalData_`n'_sch.dta" "$Original_DTA/OH_OriginalData_`n'_lea.dta"
	replace DataLevel = "School" if DataLevel == "sch"
	replace DataLevel = "District" if DataLevel == "lea"
	replace DataLevel = "State" if DataLevel == "state"
	save "$Original_DTA/OH_OriginalData_`n'.dta", replace
}
*End of OH Importing Raw Data.do
****************************************************
