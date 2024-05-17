clear
set more off

global NCES "/Users/miramehta/Documents/NCES District and School Demographics"
global iowa "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global Iowa "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
cd "/Users/miramehta/Documents"

global years 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022


foreach a in $years {
	
	use "${NCES}/NCES School Files, Fall 1997-Fall 2022/NCES_`a'_School.dta", clear
	
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
	rename lea_name DistName
	rename school_id StateAssignedSchID
	rename school_name SchName
	
	if `a' == 2022{
		rename school_type SchType
		decode district_agency_type, gen(DistType)
		drop district_agency_type
	}
	
	replace CountyName = strproper(CountyName) if `a' <= 2015

		split State_leaid, p(" ")
		drop State_leaid State_leaid2
		rename State_leaid1 State_leaid
		replace State_leaid=substr(State_leaid,-4,.)
		split seasch, p(" ")
		drop seasch seasch2
		rename seasch1 seasch
		replace seasch=substr(seasch,-4,.)

	
	drop if NCESDistrictID == ""
	
	replace StateAssignedSchID=substr(StateAssignedSchID, -4,.)
	
		gsort -school_status
		duplicates drop State_leaid SchName,force
	
	if `a' == 2022{
		keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID seasch State_leaid DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual SchName DistName
	}
	
	save "${Iowa}/NCES_`a'_School.dta", replace
	
	use "${NCES}/NCES District Files, Fall 1997-Fall 2022/NCES_`a'_District.dta", clear 
	
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

		split State_leaid, p(" ")
		drop State_leaid State_leaid2
		rename State_leaid1 State_leaid
		replace State_leaid=substr(State_leaid,-4,.)
	
	replace CountyName = strproper(CountyName) if `a' <= 2015
	
	
	save "${Iowa}/NCES_`a'_District.dta", replace
	
}


// extra changes to some files 

use "${Iowa}/NCES_2004_district.dta", clear
gsort -boundary_change_indicator
duplicates tag State_leaid, gen(test)
duplicates drop State_leaid,force
save "${Iowa}/NCES_2004_district.dta", replace

use "${Iowa}/NCES_2005_district.dta", clear
gsort -boundary_change_indicator
duplicates tag State_leaid, gen(test)
duplicates drop State_leaid,force
save "${Iowa}/NCES_2005_district.dta", replace


use "${Iowa}/NCES_2014_school.dta", clear
gsort -school_status
duplicates tag State_leaid SchName, gen(test)
duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2014_school.dta", replace

use "${Iowa}/NCES_2015_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2015_school.dta", replace

use "${Iowa}/NCES_2016_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2016_school.dta", replace

use "${Iowa}/NCES_2017_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2017_school.dta", replace

use "${Iowa}/NCES_2018_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2018_school.dta", replace

use "${Iowa}/NCES_2019_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2019_school.dta", replace

use "${Iowa}/NCES_2020_school.dta", clear
gsort -school_status
duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2020_school.dta", replace

use "${Iowa}/NCES_2021_school.dta", clear
gsort -school_status

replace seasch = "0418" if seasch == "4860" & State_leaid == "4860" & SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" 

duplicates drop State_leaid SchName,force
save "${Iowa}/NCES_2021_school.dta", replace

