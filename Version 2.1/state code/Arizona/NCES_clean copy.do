clear
set more off

global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_fips==4
	
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
	
	if `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2020 | `a' == 2021 | `a' == 2022 {
		split State_leaid, p(-)
		drop State_leaid State_leaid1
		rename State_leaid2 State_leaid
		split seasch, p(-)
		drop seasch seasch1
		rename seasch2 seasch
	}
	
	drop if NCESDistrictID == ""
	
	save "${NCES}/NCES_`a'_School_AZ.dta", replace
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_fips==4
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	
	if `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2020 | `a' == 2021 | `a' == 2022 {
		split State_leaid, p(-)
		drop State_leaid State_leaid1
		rename State_leaid2 State_leaid
	}
	
	if(`a' == 2022){
		labmask district_agency_type_num, values(DistType)
		drop DistType
		rename district_agency_type_num DistType
	}
	
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistName DistType DistCharter DistLocale CountyCode CountyName
	
	save "${NCES}/NCES_`a'_District_AZ.dta", replace
	
}
	