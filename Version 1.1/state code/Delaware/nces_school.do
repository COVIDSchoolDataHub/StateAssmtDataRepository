clear
set more off

global NCESOLD "/Users/minnamgung/Desktop/SADR/NCESOld"
global NCESNEW "/Users/minnamgung/Desktop/SADR/Delaware/NCESNew"

* foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 2022
foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 2022 { 

use "${NCESOLD}/NCES_`year'_School.dta"
drop year

if `year' != 2022 {
	keep if state_name==10 
	rename state_name State
	decode State, gen (State1)
	drop State
	rename State1 State
	rename state_location StateAbbrev
	rename state_fips StateFips
}

if `year' == 2022 {
	keep if state_fips_id == 10
	gen StateAbbrev = "DE"
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

if `year' < 2016 {
	gen StateAssignedSchID = seasch
}
else {

	gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, .)
}
drop if StateAssignedSchID==""
save "${NCESNEW}/NCES_`year'_school.dta", replace
}
