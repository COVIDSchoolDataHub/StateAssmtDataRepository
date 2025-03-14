*******************************************************
* MARYLAND

* File name: MD_NCES
* Last update: 3/14/2025

*******************************************************
* Notes

	* This do file uses NCES from 2014-2022 and keeps MD observations.
	* These select observations are saved as a *.dta in NCES_MD.
	* As of the latest update, the latest file is NCES_2022. 
	* This do file will need to be updated as newer data is available. 
		
*******************************************************
clear

** Preparing NCES files

global years 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCES_District}/NCES_`a'_District", clear 
	keep if state_location == "MD"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistLocale DistCharter DistName
	
	save "${NCES_MD}/NCES_`a'_District_MD", replace
	
	use "${NCES_School}/NCES_`a'_School", clear
	keep if state_location == "MD"
	
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
	if `a' == 2022 {
		foreach var of varlist SchType SchLevel SchVirtual DistType {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	} 
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName sch_lowest_grade_offered
	drop if seasch == ""
	
	save "${NCES_MD}/NCES_`a'_School_MD", replace	
}
* END of MD_NCES.do
****************************************************
