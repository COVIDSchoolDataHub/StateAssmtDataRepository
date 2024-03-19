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

import excel "${NCESSchool}/NCES_2022_School.xlsx", clear
gen State = "Missouri"
drop if C != "MO"
rename C StateAbbrev
rename D StateFips
destring state_fips, replace force
rename E DistName
rename F NCESDistrictID
rename G State_leaid
rename N seasch
replace seasch = subinstr(seasch, "MO-", "", .)
rename I NCESSchoolID
rename J SchType
rename K SchVirtual
rename L SchLevel
rename M SchName
merge 1:1 NCESDistrictID NCESSchoolID using "${NCES}/NCES_2021_School_MO.dta", keepusing (DistLocale CountyCode CountyName district_agency_type)
drop if _merge == 2
drop _merge
save "${NCES}/NCES_2022_School_MO.dta", replace
		
import excel "${NCESDistrict}/NCES_2022_District.xlsx", clear
drop if C != "MO"
rename E DistName
rename G State_leaid
rename F NCESDistrictID
rename H DistType
merge 1:1 NCESDistrictID using "${NCES}/NCES_2021_District_MO.dta", keepusing (DistLocale CountyCode CountyName DistCharter)
drop if _merge == 2
drop _merge
save "${NCES}/NCES_2022_District_MO.dta", replace
