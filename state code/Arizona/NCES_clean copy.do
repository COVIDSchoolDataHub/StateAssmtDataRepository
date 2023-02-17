clear
set more off

global NCESSchool "/Users/minnamgung/Desktop/NCES/School"
global NCESDistrict "/Users/minnamgung/Desktop/NCES/District"
global Arizona "/Users/minnamgung/Desktop/Arizona/NCES"

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020

foreach a in $years {
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_fips==4
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename charter Charter
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	rename virtual Virtual 
	rename school_level SchoolLevel
	
	save "${Arizona}/NCES_`a'_School.dta", replace
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_fips==4
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistrictType
	rename county_code CountyCode
	
	save "${Arizona}/NCES_`a'_District.dta", replace
	
}
	