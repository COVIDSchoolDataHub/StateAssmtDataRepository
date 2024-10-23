clear
set more off

global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global years 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2020 2021 2022


foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	
	keep if state_fips == 51
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_code CountyCode
	rename lea_name DistName
	rename county_name CountyName
	drop if State_leaid == ""
	
	if(`a' == 2022){
		labmask district_agency_type_num, values(DistType)
		drop DistType
		rename district_agency_type_num DistType
	}
	
	keep State StateFips NCESDistrictID State_leaid DistName DistType DistCharter DistLocale CountyCode CountyName StateAbbrev

	save "${NCES}/NCES_`a'_District.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	
	keep if state_fips == 51
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	rename lea_name DistName
	rename district_agency_type DistType
	rename school_name SchName
	rename county_name CountyName
	drop if seasch == ""
	
	if(`a' == 2022){
		rename school_type SchType
	}
	
	keep State StateFips NCESDistrictID State_leaid StateAbbrev DistName DistType NCESSchoolID SchName seasch CountyName CountyCode DistCharter SchLevel SchVirtual SchType DistLocale
	
	save "${NCES}/NCES_`a'_School.dta", replace
	
}
