clear
set more off

global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global years 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_fips==10
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid StateAssignedDistID
	rename district_agency_type DistType	
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName	
	rename ncesschoolid NCESSchoolID
	rename school_name SchName
	rename seasch StateAssignedSchID
	
	if(`a' == 2022){
		rename school_type SchType
	}
	
	keep State StateFips NCESDistrictID StateAssignedDistID StateAbbrev DistName DistType NCESSchoolID SchName StateAssignedSchID CountyName CountyCode DistCharter SchLevel SchVirtual SchType DistLocale
	
	if `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2020 | `a' == 2021 | `a' == 2022 {
		split StateAssignedDistID, p(-)
		drop StateAssignedDistID StateAssignedDistID1
		rename StateAssignedDistID2 StateAssignedDistID
		split StateAssignedSchID, p(-)
		drop StateAssignedSchID StateAssignedSchID1
		rename StateAssignedSchID2 StateAssignedSchID
	}
	
	drop if NCESDistrictID == ""
	
	replace CountyName = strproper(CountyName)
	
	save "${NCES}/NCES_`a'_School_DE.dta", replace
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_fips==10
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid StateAssignedDistID
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	
	if `a' == 2016 | `a' == 2017 | `a' == 2017 | `a' == 2018 | `a' == 2020 | `a' == 2021 | `a' == 2022 {
		split StateAssignedDistID, p(-)
		drop StateAssignedDistID StateAssignedDistID1
		rename StateAssignedDistID2 StateAssignedDistID
	}
		
	if(`a' == 2022){
		labmask district_agency_type_num, values(DistType)
		drop DistType
		rename district_agency_type_num DistType
	}
	
	replace CountyName = strproper(CountyName)

	
	keep State StateAbbrev StateFips NCESDistrictID StateAssignedDistID DistName DistType DistCharter DistLocale CountyCode CountyName
	
	save "${NCES}/NCES_`a'_District_DE.dta", replace
	
}
	