*******************************************************
* NORTH CAROLINA

* File name: NC_NCES
* Last update: 03/03/2025

*******************************************************
* Notes

	* This do file isolates North Carolina's NCES information from the larger NCES files. 
	* Completed files are saved to the NCES_NC folder
	* As of 03/03/2025, the most recent NCES file available is NCES_2022. This will be used for 2023 and 2024 data files.
	* This file will need to be updated when NCES_2023 becomes available
	
*******************************************************
clear
/////////////////////////////////////////
*** NCES Cleaning for NC ***
/////////////////////////////////////////
cap log close
log using nc_nces_cleaning.log, replace

// match schools by district and ID
global years 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

foreach a in $years {
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_fips == 37
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	// rename charter Charter
	rename county_name CountyName
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	
if `a' == 2022 {
	rename school_type SchType
}
	rename lea_name DistName1
	// rename virtual Virtual  // Might not work for 2021
	//rename school_level SchLevel

	if `a' == 2016 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 | `a' == 2022 {

	replace seasch = substr(seasch, 5, .)
	
	replace State_leaid = subinstr(State_leaid, "NC-", "", .)	
	}
	
keep State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID State_leaid seasch DistCharter SchLevel SchVirtual CountyName CountyCode DistName1 
order State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID State_leaid seasch DistCharter SchLevel SchVirtual CountyName CountyCode DistName1 

save "$NCES_NC/NCES_`a'_School_NC.dta", replace

keep State_leaid DistName1
duplicates drop State_leaid, force

save "$NCES_NC/NC_district_IDs_`a'", replace

//use NCES_2021_District.dta, clear
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_fips == 37
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	replace State_leaid = subinstr(State_leaid, "NC-", "", .)

keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistLocale
order State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistLocale
save "$NCES_NC/NCES_`a'_District_NC.dta", replace
}
* END of NC_NCES.do
****************************************************
