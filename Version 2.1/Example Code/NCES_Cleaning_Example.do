clear
set more off


global Abbrev "TN" //Set State Abbreviation Here
global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_$Abbrev "/Volumes/T7/State Test Project/Tennessee/NCES" //Create a folder for state specific NCES files


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
		replace seasch = State_leaid + "-" + seasch
	}
	
	
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""

	
	save "${NCES_$Abbrev}/NCES_`a'_School.dta", replace
	
}
