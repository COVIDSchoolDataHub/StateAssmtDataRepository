*******************************************************
* IOWA

* File name: 01_IA_NCES_clean
* Last update: 02/28/2025

*******************************************************
* Notes

	* This do file isolates Iowa's NCES information from the larger NCES files. 
	* Completed files are saved to the NCES_IA folder
	* As of 02/28/2025, the most recent NCES file available is NCES_2022. This will be used for 2023 and 2024 data files.
	* This file will need to be updated when NCES_2023 becomes available
	
*******************************************************
clear

/////////////////////////////////////////
*** NCES Cleaning for IA ***
/////////////////////////////////////////

global years  2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 //update as years are added. 


foreach a in $years {
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	
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

	// Formatting State_leaid for merging with raw data
		split State_leaid, p(" ")
		drop State_leaid State_leaid2
		gen State_leaid=substr(State_leaid1,-4,.)
		replace State_leaid1 = subinstr(State_leaid1, "IA-", "", 1)
		
	// Combining seasch for merging with raw school data
		split seasch, p(" ")
		replace seasch1=substr(seasch1,-4,.) // this is the district portion
		replace seasch2 = string(real(seasch2),"%04.0f")		
		gen new_sch_ID = seasch1 + "-" + seasch2 
		drop StateAssignedSchID seasch1 seasch2
		rename new_sch_ID StateAssignedSchID

	
	drop if NCESDistrictID == ""

		gsort -school_status
		duplicates drop State_leaid SchName,force
	
	if `a' == 2022{
		
		keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID seasch State_leaid StateAssignedSchID DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual SchName DistName
		
	}
	
	save "${NCES_IA}/NCES_`a'_School_IA.dta", replace
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	
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

	// Formatting State_leaid for merging with raw district data
		split State_leaid, p(" ")
		drop State_leaid State_leaid2
		gen State_leaid=substr(State_leaid1,-4,.)
		replace State_leaid1 = subinstr(State_leaid1, "IA-", "", 1)
		
	// Proper case county name
	replace CountyName = strproper(CountyName) if `a' <= 2015
	
	// Save to NCES_iowa folder
	save "${NCES_IA}/NCES_`a'_District_IA.dta", replace
	
}

{
// Extra edits to some NCES files in cases where the district is listed twice but one is "Closed"

use "${NCES_IA}/NCES_2004_District_IA.dta", clear
gsort -boundary_change_indicator
duplicates tag State_leaid, gen(test)
tab test
duplicates drop State_leaid,force
save "${NCES_IA}/NCES_2004_District_IA.dta", replace

// 2021 Edit
use "${NCES_IA}/NCES_2021_School_IA.dta", clear
replace seasch = "0418" if seasch == "4860" & State_leaid == "4860" & SchName == "Odebolt Arthur Battle Creek Ida Grove Elementary-Ida Grove" 
save "${NCES_IA}/NCES_2021_School_IA.dta", replace
}

*End of 01_Iowa_NCES_clean
****************************************************
