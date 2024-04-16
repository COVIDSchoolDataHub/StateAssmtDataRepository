clear
set more off

// global NCES "/Users/sarahridley/Desktop/CSDH/Raw/NCES"
// global Arizona "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/NCES"
// global NCES "/Users/minnamgung/Desktop/SADR/NCES District and School Demographics-2"
// global Iowa "/Users/minnamgung/Desktop/SADR/Iowa/NCES"

global NCES "/Users/benjaminm/Documents/State_Repository_Research/NCES"
global Iowa "/Users/benjaminm/Documents/State_Repository_Research/Iowa/NCES"
cd "/Users/benjaminm/Documents/State_Repository_Research/NCES"


// file imports 

// import excel "${NCES}/NCES_District/NCES_2003_District.xlsx", clear firstrow
// save "${NCES}/NCES_District/NCES_2003_District.dta", replace

// import excel "${NCES}/NCES_District/NCES_2004_District.xlsx", clear firstrow
// save "${NCES}/NCES_District/NCES_2004_District.dta", replace

//
// import excel "${NCES}/NCES_School/NCES_2003_School.xlsx", clear firstrow
// save NCES_2003_School.dta, replace


//import excel "${NCES}/NCES_School/NCES_2022_School.xlsx", clear firstrow
//save "${NCES}/NCES_District/NCES_2022_School.dta", replace


//import excel "${NCES}/NCES_School/NCES_2022_School.xlsx", clear firstrow
//save "${NCES}/NCES_School/NCES_2022_School.dta", replace


global years 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021


foreach a in $years {
	
	use "${NCES}/NCES_School/NCES_`a'_School.dta", clear
	
		if `a' == 2003 {
			keep if state_fips_id==19
		} 
		
			if `a' != 2003 {
				keep if state_fips==19
			}
	
	
	rename state_name State
	rename state_location StateAbbrev
	
		if `a' == 2003 {
			rename state_fips_id StateFips	
		} 
		
			if `a' != 2003 {
				rename state_fips StateFips	
			}
	

	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename ncesschoolid NCESSchoolID
	rename SchType SchType
	rename lea_name DistName
	rename school_id StateAssignedSchID
	rename school_name SchName
	
	if `a' == 2014 | `a' == 2015 | `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 {
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
	
	replace StateAssignedSchID=substr(StateAssignedSchID, -4,.)
	
		gsort -school_status
		duplicates drop State_leaid SchName,force
	
	save "${Iowa}/NCES_`a'_School.dta", replace
	
	use "${NCES}/NCES_District/NCES_`a'_District.dta", clear 
	
		if `a' == 2003 {
			keep if state_fips_id==19
		} 
		
			if `a' != 2003 {
				keep if state_fips==19
			}
	
	
	rename state_name State
	rename state_location StateAbbrev
	
		if `a' == 2003 {
			rename state_fips_id StateFips	
		} 
		
			if `a' != 2003 {
				rename state_fips StateFips	
			}
	
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	
	if `a' == 2015 | `a' == 2014 |`a' == 2013 |`a' == 2012 |`a' == 2011 |`a' == 2010 |`a' == 2009 |`a' == 2008 |`a' == 2007 |`a' == 2006 |`a' == 2005 |`a' == 2004 |`a' == 2003 |`a' == 2002 |`a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 {
		split State_leaid, p(" ")
		drop State_leaid State_leaid2
		rename State_leaid1 State_leaid
		replace State_leaid=substr(State_leaid,-4,.)
	}
	
	
	save "${Iowa}/NCES_`a'_District.dta", replace
	
}


// extra changes to some files 

use "${iowa}/NCES_2004_district.dta", clear
gsort -boundary_change_indicator
duplicates tag State_leaid, gen(test)
duplicates drop State_leaid,force
save "${iowa}/NCES_2004_district.dta", replace

use "${iowa}/NCES_2005_district.dta", clear
gsort -boundary_change_indicator
duplicates tag State_leaid, gen(test)
duplicates drop State_leaid,force
save "${iowa}/NCES_2005_district.dta", replace


use "${iowa}/NCES_2014_school.dta", clear
gsort -school_status
duplicates tag State_leaid SchName, gen(test)
duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2014_school.dta", replace

use "${iowa}/NCES_2015_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2015_school.dta", replace

use "${iowa}/NCES_2016_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2016_school.dta", replace

use "${iowa}/NCES_2017_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2017_school.dta", replace

use "${iowa}/NCES_2018_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2018_school.dta", replace

use "${iowa}/NCES_2019_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2019_school.dta", replace

use "${iowa}/NCES_2020_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2020_school.dta", replace

use "${iowa}/NCES_2021_school.dta", clear
gsort -school_status

replace seasch = "0418" if seasch == "4860" & State_leaid == "4860" & SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" 
//replace State_leaid = "0418" if seasch == "0418" & State_leaid == "4860" & SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" 

duplicates drop State_leaid SchName,force
save "${iowa}/NCES_2021_school.dta", replace

