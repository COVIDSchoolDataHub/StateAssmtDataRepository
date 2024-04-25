clear
set more off

cd "/Users/miramehta/Documents/"

global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
	
global years 2009 2010 2011 2012

foreach a in $years {
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	
	keep if state_location == "MO"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
		
	save "${NCES}/NCES_`a'_District_MO.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_location == "MO"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType	
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName	
	rename ncesschoolid NCESSchoolID
	rename school_name SchName
	
	save "${NCES}/NCES_`a'_School_MO.dta", replace
	
}
	
global years 2013 2014 2015 2016 2017 2018 2020 2021

foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_location == "MO"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
				
	drop if DistName == ""
	
	save "${NCES}/NCES_`a'_District_MO.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_location == "MO"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType	
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName	
	rename ncesschoolid NCESSchoolID
	rename school_name SchName
	drop if seasch == ""
	
	save "${NCES}/NCES_`a'_School_MO.dta", replace
}

//Fall 2022 NCES Data

use "${NCESSchool}/NCES_2022_School.dta", clear
rename state_name State
rename state_location StateAbbrev
rename fips StateFips
drop if StateAbbrev != "MO"
rename state_fips_id state_fips
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename lea_name DistName
replace seasch = subinstr(seasch, "MO-", "", .)
rename school_type SchType
rename school_name SchName
decode district_agency_type, gen (DistType)
drop district_agency_type
rename county_name CountyName
rename county_code CountyCode
rename state_leaid State_leaid
merge 1:1 NCESDistrictID NCESSchoolID using "${NCES}/NCES_2021_School_MO.dta", keepusing (DistLocale CountyCode CountyName DistType SchVirtual)
drop if _merge == 2
drop _merge
keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID seasch State_leaid DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual
save "${NCES}/NCES_2022_School_MO.dta", replace
		
use "${NCESDistrict}/NCES_2022_District.dta", clear
drop if state_location != "MO"
rename lea_name DistName
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename state_leaid State_leaid
drop year
merge 1:1 NCESDistrictID using "${NCES}/NCES_2021_District_MO.dta", keepusing (DistLocale CountyCode CountyName DistCharter)
drop if _merge == 2
drop _merge
save "${NCES}/NCES_2022_District_MO.dta", replace
