*******************************************************
* ARIZONA

* File name: 01_NCES_clean copy
* Last update: 2/19/2025

*******************************************************
* Notes

	* This do file reads NCES files from 2009 through 2022 one by one.
	* It keeps only AZ observations, renames variables, and saves it as a *.dta file. 
	* As of the last update 2/19/2025, the latest NCES file is for 2022.
	* This code will need to be updated when newer NCES files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////


clear

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
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
	
	save "${NCES_AZ}/NCES_`a'_School_AZ.dta", replace
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
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
	
	save "${NCES_AZ}/NCES_`a'_District_AZ.dta", replace	
}
* END of 01_NCES_clean copy.do
****************************************************
