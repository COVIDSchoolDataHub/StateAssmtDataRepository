* OKLAHOMA

* File name: Oklahoma NCES Cleaning
* Last update: 03/11/2025

*******************************************************
* Notes 

	* This do file uses NCES data from 2016-2022.
	* It keeps Oklahoma only observations.
	* The files are saved in the NCES_OK folder. 
	* As of the last update, the latest NCES data is NCES_2022.
	* This do file will need to be updated when newer NCES data is released. 
	
*******************************************************
clear
set more off

global years 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_location == "OK"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	
	if(`a' == 2022){
		labmask district_agency_type_num, values(DistType)
		drop DistType
		rename district_agency_type_num DistType
	}
	
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistName DistType DistCharter DistLocale CountyCode CountyName
	
	save "${NCES_OK}/NCES_`a'_District_OK.dta", replace
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_location == "OK"
	
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
	
	if(`a' == 2022){
		rename school_type SchType
	}
	
	keep State StateFips NCESDistrictID State_leaid StateAbbrev DistName DistType NCESSchoolID SchName seasch CountyName CountyCode DistCharter SchLevel SchVirtual SchType DistLocale
	save "${NCES_OK}/NCES_`a'_School_OK.dta", replace
}
*End of Oklahoma NCES Cleaning.do
****************************************************
