clear
set more off

global NCESOLD "G:\Test Score Repository Project\Hawaii\NCES\NCESOLD"
global NCESNEW "G:\Test Score Repository Project\Hawaii\NCES\NCESCLEANED"

foreach year in 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 { 

use "${NCESOLD}/NCES_`year'_School.dta"
drop year
keep if state_name==15
rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename school_name SchName
rename school_type SchType
rename ncesschoolid NCESSchoolID
gen StateAssignedSchID= substr(seasch, 3, .)

save "${NCESNEW}/NCES_`year'_school.dta", replace

}
