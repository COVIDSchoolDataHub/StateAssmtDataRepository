*******************************************************
* CALIFORNIA

* File name: 02_CA_NCES_NEW
* Last update: 2/18/2025

*******************************************************
* Notes

	* This do file reads NCES files from 2009 through 2022 one by one.
	* It keeps only CA observations and saves it as *.dta file.
	* Duplicates in NCES School diles are removed. 
	* As of the last update 2/18/2025, the latest NCES file is for 2022.
	* This code will need to be updated when newer NCES files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear
set more off

** Preparing NCES files

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

foreach a in $years {
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_location == "CA"
	
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
	
	save "${NCES_CA}/NCES_`a'_District_CA.dta", replace
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_location == "CA"
	
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
	if `a' == 2009 | `a' == 2010 | `a' == 2011 | `a' == 2013 { // Couple of the same schools with multiple ncesschoolids in the data. Just choosing which one to use randomly.
		duplicates drop seasch, force
	}
	gen seasch_new = substr(seasch, strpos(seasch,"-")+1,.)
	if `a' == 2022 rename school_type SchType
	if `a' != 2022 {
		foreach var of varlist SchType SchLevel SchVirtual {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	}
	if `a' == 2022 {
		foreach var of varlist SchType SchLevel SchVirtual DistType {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	}
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch seasch_new DistName
	drop if seasch == ""

	
	save "${NCES_CA}/NCES_`a'_School_CA.dta", replace
}
* END of 02_CA_NCES_NEW.do
****************************************************
