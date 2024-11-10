clear
set more off

global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/California/NCES"


** Preparing NCES files

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

foreach a in $years {
	
	use "${NCES_Original}/NCES_`a'_District.dta", clear 
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
	
	save "${NCES}/NCES_`a'_District.dta", replace
	
	use "${NCES_Original}/NCES_`a'_School.dta", clear
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

	
	save "${NCES}/NCES_`a'_School.dta", replace
	
}
