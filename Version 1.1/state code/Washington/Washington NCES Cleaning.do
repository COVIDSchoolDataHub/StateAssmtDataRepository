clear
set more off
set trace off
global raw "/Volumes/T7/State Test Project/Washington/Original Data Files"
global output "/Volumes/T7/State Test Project/Washington/Output"
global NCESOLD "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/Washington/NCES"


** Preparing NCES files

global years 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCESOLD}/NCES_`a'_District.dta", clear 
	keep if state_location == "WA"
	
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
	
	use "${NCESOLD}/NCES_`a'_School.dta", clear
	keep if state_location == "WA"
	
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
	
	if `a' !=2022 {
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
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""

	
	save "${NCES}/NCES_`a'_School.dta", replace
	
}
