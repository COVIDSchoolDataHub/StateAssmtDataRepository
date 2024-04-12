clear
set trace off
set more off

global NCESOLD "/Users/minnamgung/Desktop/SADR/NCESOld"
global NCESNEW "/Users/minnamgung/Desktop/SADR/Delaware/NCESNew"

foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 2022 {
use "${NCESOLD}/NCES_`year'_District.dta"
drop year

rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename county_name CountyName
rename county_code CountyCode
rename district_agency_type DistType


if `year' != 2022 {
	keep if state_name==10 
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
	keep if state_fips_id == 10
	gen StateAbbrev = "DE"
	rename state_fips_id StateFips
}


if `year' < 2016 {
	
gen StateAssignedDistID = State_leaid

}

else {
gen StateAssignedDistID = substr(State_leaid, strpos(State_leaid, "-")+1, .)
}

//Problem merging school and district data together onto raw data, renaming variables to maintain data. Will replace in DE do-file.
rename DistCharter DistCharter1
rename DistType DistType1
rename NCESDistrictID NCESDistrictID1
rename CountyName CountyName1
rename CountyCode CountyCode1
rename State_leaid State_leaid1
rename DistLocale DistLocale1
save "${NCESNEW}/NCES_`year'_district.dta", replace
clear
}
