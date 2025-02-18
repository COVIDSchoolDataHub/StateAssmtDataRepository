clear
set more off

***************************
*KENTUCKY

*File Name: 01_KY_NCES
*Last update: 02/17/25

***************************

*NOTES:

*This do-file loops through 2009-2022 NCES files and filters for Kentucky observations only. 
*It then standardizes NCES variables to the same name and type across years. 
*Finally, it edits State_leaid and seasch for merging. It then saves the cleaned nces files to the NCES_KY folder

*As of last update, the latest NCES files are for 2022

*Important: The cleaned NCES files are currently ONLY used for 2022-2024. Previous years clean raw NCES files before merging.


***************************


global Abbrev "KY"
** Preparing NCES files

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

foreach a in $years {
	
	use "${NCES_Original}/NCES_`a'_District.dta", clear 
	keep if state_location == "$Abbrev"
	
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
	
	if `a' >= 2021 replace State_leaid = substr(State_leaid, -6,3)
	
	
	save "${NCES_$Abbrev}/NCES_`a'_District.dta", replace
	
	use "${NCES_Original}/NCES_`a'_School.dta", clear
	keep if state_location == "$Abbrev"
	
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
		foreach var of varlist SchType SchLevel SchVirtual {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	if `a' == 2022 {
		decode DistType, gen(temp)
		drop DistType
		rename temp DistType
	}	
	
	
		
	if `a' < 2016 {
		replace seasch = State_leaid + seasch
	}
	
	if `a' >= 2021 replace State_leaid = substr(State_leaid, -6,3)
	if `a' >= 2021 replace seasch = State_leaid + substr(seasch,-3,3)
	
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""

	
	save "${NCES_$Abbrev}/NCES_`a'_School.dta", replace
	
}

*****************

* END of 01_KY_NCES

*****************
