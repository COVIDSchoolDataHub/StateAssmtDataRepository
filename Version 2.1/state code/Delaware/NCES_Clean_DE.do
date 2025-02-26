*******************************************************
* DELAWARE

* File name: NCES_Clean_DE.do
* Last update: 2/26/2025

*******************************************************
* Notes

	* This do file reads NCES files from 2014 through 2022 one by one.
	* It keeps only DE observations. 
	* As of the last update 2/26/2025, the latest NCES file is for 2022.
	* This code will need to be updated when newer NCES files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

global years 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
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
	
	save "${NCES_DE}/NCES_`a'_School_DE.dta", replace
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
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
	
	save "${NCES_DE}/NCES_`a'_District_DE.dta", replace
	
}
* END of NCES_Clean_DE.do
****************************************************
	