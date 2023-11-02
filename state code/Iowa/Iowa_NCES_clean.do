clear
set more off

global NCES "/Users/sarahridley/Desktop/CSDH/Raw/NCES"
global Arizona "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/NCES"

global NCES "/Users/minnamgung/Desktop/NCES"
global Iowa "/Users/minnamgung/Desktop/Iowa/NCES"

global years 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020

foreach a in $years {
	
	use "${NCES}/School/NCES_`a'_School.dta", clear
	keep if state_fips==19
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename ncesschoolid NCESSchoolID
	rename school_type SchType
	
	if `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 {
		split State_leaid, p(" ")
		drop State_leaid State_leaid2
		rename State_leaid1 State_leaid
		replace State_leaid=substr(State_leaid,-4,.)
		split seasch, p(" ")
		drop seasch seasch2
		rename seasch1 seasch
		replace seasch=substr(seasch,-4,.)
	}
	
	drop if NCESDistrictID == ""
	
	save "${Iowa}/NCES_`a'_School.dta", replace
	
	use "${NCES}/District/NCES_`a'_District.dta", clear 
	keep if state_fips==19
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	
	if `a' == 2015 | `a' == 2014 |`a' == 2013 |`a' == 2012 |`a' == 2011 |`a' == 2010 |`a' == 2009 |`a' == 2008 |`a' == 2007 |`a' == 2006 |`a' == 2005 |`a' == 2004 |`a' == 2003 |`a' == 2002 |`a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 {
		split State_leaid, p(" ")
		drop State_leaid State_leaid2
		rename State_leaid1 State_leaid
		replace State_leaid=substr(State_leaid,-4,.)
	}
	
	
	save "${Iowa}/NCES_`a'_District.dta", replace
	
}
