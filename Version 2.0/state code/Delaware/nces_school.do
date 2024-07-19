clear
set more off
set trace off


global NCESOLD "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESOld1"
global NCESNEW "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESNew"

* foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 2022
foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 2022 { 

use "${NCESOLD}/NCES_`year'_School.dta"
drop year

if `year' != 2022 {
	keep if state_name=="Delaware" 
	rename state_name State
	drop State
	rename state_location StateAbbrev
	rename state_fips StateFips
}

if `year' == 2022 {
	keep if state_fips_id == 10
	gen StateAbbrev = "DE"
	rename state_fips_id StateFips
}

rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename county_name CountyName
rename county_code CountyCode
rename school_name SchName
if `year' == 2022{
	rename school_type SchType
}
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID

foreach v of varlist SchVirtual SchLevel SchType {
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
