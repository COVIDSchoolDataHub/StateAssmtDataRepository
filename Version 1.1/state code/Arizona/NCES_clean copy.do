clear
set more off

global NCES "/Users/maggie/Desktop/Arizona/NCES"
global Arizona "/Users/maggie/Desktop/Arizona/NCES/Cleaned"

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2020 2021

foreach a in $years {
	
	use "${NCES}/School/NCES_`a'_School.dta", clear
	keep if state_fips==4
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	
	if `a' == 2009 {
		drop _merge
	}
	
	if `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2020 | `a' == 2021 {
		split State_leaid, p(-)
		drop State_leaid State_leaid1
		rename State_leaid2 State_leaid
		split seasch, p(-)
		drop seasch seasch1
		rename seasch2 seasch
	}
	
	drop if NCESDistrictID == ""
	
	save "${Arizona}/NCES_`a'_School.dta", replace
	
	use "${NCES}/District/NCES_`a'_District.dta", clear 
	keep if state_fips==4
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_code CountyCode
	
	if `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2020 | `a' == 2021 {
		split State_leaid, p(-)
		drop State_leaid State_leaid1
		rename State_leaid2 State_leaid
	}
	
	
	save "${Arizona}/NCES_`a'_District.dta", replace
	
}
	