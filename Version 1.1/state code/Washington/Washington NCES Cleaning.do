clear
set more off

cd "/Users/minnamgung/Desktop/SADR/Washington"

global raw "/Users/minnamgung/Desktop/SADR/Washington/Original Data Files"
global output "/Users/minnamgung/Desktop/SADR/Washington/Output"
global NCES "/Users/minnamgung/Desktop/SADR/Washington/NCES"

global NCESOLD "/Users/minnamgung/Desktop/SADR/NCESOld"

global years 2014 2015 2016 2017 2018 2020 2021 2022

foreach year in $years {
	
	use "${NCESOLD}/NCES_`year'_District.dta", clear 
	
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename lea_name DistName
	rename county_name CountyName
	rename county_code CountyCode
	rename district_agency_type DistType
	
	if `year' != 2022 {
	keep if state_location == "WA"
	rename state_name State
	decode State, gen (State1)
	drop State
	rename State1 State
	rename state_location StateAbbrev
	rename state_fips StateFips
	
	rename urban_centric_locale DistLocale
	
	foreach v of varlist DistType DistLocale {
	decode `v', gen (`v'1)
	drop `v'
	rename `v'1 `v'
	}
	}
	
	if `year' == 2022 {
	keep if state_fips_id == 53
	gen StateAbbrev = "WA"
	rename state_fips_id StateFips
	}

	
	save "${NCES}/NCES_`year'_District.dta", replace
	
	use "${NCESOLD}/NCES_`year'_School.dta", clear
	
	if `year' != 2022 {
	keep if state_location == "WA"
	rename state_name State
	decode State, gen (State1)
	drop State
	rename State1 State
	rename state_location StateAbbrev
	rename state_fips StateFips
}

if `year' == 2022 {
	keep if state_fips_id == 53
	gen StateAbbrev = "WA"
	rename state_fips_id StateFips
	drop DistLocale
}
	
	rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename county_name CountyName
rename county_code CountyCode
rename school_name SchName
rename school_type SchType
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename dist_urban_centric_locale DistLocale

foreach v of varlist DistType SchVirtual SchLevel SchType DistLocale {
	decode `v', gen (`v'1)
	drop `v'
	rename `v'1 `v'
}

	
	save "${NCES}/NCES_`year'_School.dta", replace
	
}
