clear
set more off

cd "/Users/miramehta/Documents"

global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

local year 2014 2015 2016 2017 2018 2019 2020 2021

foreach a of local year {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
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
	
	save "${NCES}/NCES_`a'_District_CO.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
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
	
	save "${NCES}/NCES_`a'_School_CO.dta", replace
}

use "${NCESSchool}/NCES_2022_School.dta", clear
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
merge 1:1 NCESDistrictID NCESSchoolID using "${NCES}/NCES_2021_School_CO.dta", keepusing (DistLocale CountyCode CountyName DistType SchVirtual)
drop if _merge == 2
drop _merge
keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID seasch State_leaid DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual
save "${NCES}/NCES_2022_School_CO.dta", replace
		
use "${NCESDistrict}/NCES_2022_District.dta", clear
drop if state_location != "CO"
rename lea_name DistName
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
rename state_leaid State_leaid
drop year
merge 1:1 NCESDistrictID using "${NCES}/NCES_2021_District_CO.dta", keepusing (DistLocale CountyCode CountyName DistCharter)
drop if _merge == 2
drop _merge
save "${NCES}/NCES_2022_District_CO.dta", replace
