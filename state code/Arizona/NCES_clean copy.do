clear
set more off

global NCES "/Users/sarahridley/Desktop/CSDH/Raw/NCES"
global Arizona "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/NCES"

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020

foreach a in $years {
	
	use "${NCES}/NCES_`a'_School.dta", clear
	keep if state_fips==4
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	rename school_type SchType
	
	drop if NCESDistrictID == ""
	
	save "${Arizona}/NCES_`a'_School.dta", replace
	
	use "${NCES}/NCES_`a'_District.dta", clear 
	keep if state_fips==4
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_code CountyCode
	
	save "${Arizona}/NCES_`a'_District.dta", replace
	
}
	