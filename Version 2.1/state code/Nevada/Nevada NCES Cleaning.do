*******************************************************
* NEVADA

* File name: Nevada NCES Cleaning
* Last update: 2/27/2025

*******************************************************
* Notes

	* This do file reads NCES files from 2015 through 2022 one by one.
	* It keeps only NV observations. 
	* As of the last update 2/27/2025, the latest NCES file is for 2022.
	* This code will need to be updated when newer NCES files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

global years 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_location == "NV"
	
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
	
	save "${NCES_NV}/NCES_`a'_District_NV.dta", replace
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_location == "NV"
	
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
	
	save "${NCES_NV}/NCES_`a'_School_NV.dta", replace
}
* END of Nevada NCES Cleaning.do
****************************************************
