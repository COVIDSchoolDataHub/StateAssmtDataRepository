clear
set more off

global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global years 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_location == "OK"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	
	if(`a' == 2022){
		labmask district_agency_type_num, values(DistType)
		drop DistType
		rename district_agency_type_num DistType
	}
	
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistName DistType DistCharter DistLocale CountyCode CountyName
	
	save "${NCES}/NCES_`a'_District_OK.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_location == "OK"
	
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
	
	if(`a' == 2022){
		rename school_type SchType
	}
	
	keep State StateFips NCESDistrictID State_leaid StateAbbrev DistName DistType NCESSchoolID SchName seasch CountyName CountyCode DistCharter SchLevel SchVirtual SchType DistLocale
	
	save "${NCES}/NCES_`a'_School_OK.dta", replace
	
}
