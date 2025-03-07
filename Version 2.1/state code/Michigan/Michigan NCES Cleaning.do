* MICHIGAN

* File name: Michigan NCES Cleaning
* Last update: 03/06/2025

*******************************************************
* Notes

	* The do file uses the NCES files, keeps only MI observations and saves it as *.dta.
	* NCES files for 2014-2022 are used.
	* As of the last update, the latest file is NCES_2022.
	* This file will need to be updated as newer NCES data is available. 
*******************************************************

**********************************************

/// NCES cleaning from 2013 to 2022
/// Update: we are adding DistLocale

**********************************************

global years 2013 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_location == "MI"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	keep State StateAbbrev StateFips NCESDistrict State_leaid DistType CountyName CountyCode DistName DistLocale DistCharter
	
	
	save "${NCES_MI}/NCES_`a'_District_MI.dta", replace
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_location == "MI"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType	
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName	
	rename ncesschoolid NCESSchoolID
	rename school_name SchName
	if `a' == 2022 rename school_type SchType
	
	drop if seasch == ""
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistName NCESSchoolID SchName SchType SchLevel SchVirtual seasch DistCharter DistLocale
	
	
	if `a' == 2022 {
	foreach v of varlist SchLevel SchVirtual SchType DistType {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
}
	
	
	save "${NCES_MI}/NCES_`a'_School_MI.dta", replace
	
}
* END of Michigan NCES Cleaning.do
****************************************************
