clear
set more off

global NCESOLD "/Users/minnamgung/Desktop/SADR/NCESOld"
global NCESNEW "/Users/minnamgung/Desktop/SADR/Delaware/NCESNew"

foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 { 

use "${NCESOLD}/NCES_`year'_School.dta"
drop year
keep if state_name==10
rename state_name State
decode State, gen (State1)
drop State
rename State1 State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename district_agency_type DistType
decode DistType, gen (DistType1)
drop DistType
rename DistType1 DistType
rename county_name CountyName
rename county_code CountyCode
rename school_name SchName
rename school_type SchType
rename ncesschoolid NCESSchoolID
decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual
decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel
decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType
drop SchName


if `year' <2016 {
	gen StateAssignedSchID = seasch
}
else {

	gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, .)
}
drop if StateAssignedSchID==""
save "${NCESNEW}/NCES_`year'_school.dta", replace

}
