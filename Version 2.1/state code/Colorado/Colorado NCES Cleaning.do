*******************************************************
* COLORADO

* File name: Colorado NCES Cleaning.do
* Last update: 2/25/2025

*******************************************************
* Notes

	* This do file reads NCES files from 2014 through 2022 one by one.
	* It keeps only CO observations. 
	* As of the last update 2/25/2025, the latest NCES file is for 2022.
	* This code will need to be updated when newer NCES files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear

local year 2014 2015 2016 2017 2018 2019 2020 2021

foreach a of local year {
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_location == "CO"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	drop year district_agency_type_num urban_centric_locale supervisory_union_number boundary_change_indicator number_of_schools teachers_total_fte staff_total_fte
	
	save "${NCES_CO}/NCES_`a'_District_CO.dta", replace
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_location == "CO"
	
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
	drop year district_agency_type_num school_id school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_supervisory_union_number dist_boundary_change_indicator dist_teachers_total_fte dist_staff_total_fte sch_bureau_indian_education sch_charter sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch
	drop if seasch == ""
	
	save "${NCES_CO}/NCES_`a'_School_CO.dta", replace
}

use "${NCES_School}/NCES_2022_School.dta", clear
rename state_name State
rename state_location StateAbbrev
rename state_fips_id StateFips
drop if StateAbbrev != "CO"
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename lea_name DistName
rename school_type SchType
rename school_name SchName
decode district_agency_type, gen (DistType)
drop district_agency_type
rename county_name CountyName
rename county_code CountyCode
rename state_leaid State_leaid
merge 1:1 NCESDistrictID NCESSchoolID using "${NCES_CO}/NCES_2021_School_CO.dta", keepusing (DistLocale CountyCode CountyName DistType SchVirtual)
drop if _merge == 2
drop _merge
keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID seasch State_leaid DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual
save "${NCES_CO}/NCES_2022_School_CO.dta", replace
		
use "${NCES_District}/NCES_2022_District.dta", clear
drop if state_location != "CO"
rename lea_name DistName
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename state_leaid State_leaid
drop year
merge 1:1 NCESDistrictID using "${NCES_CO}/NCES_2021_District_CO.dta", keepusing (DistLocale CountyCode CountyName DistCharter)
drop if _merge == 2
drop _merge
save "${NCES_CO}/NCES_2022_District_CO.dta", replace

* END of Colorado NCES Cleaning.do
****************************************************
