clear
set more off

cd "/Users/minnamgung/Desktop/SADR/Michigan"

global NCESSchool "/Users/minnamgung/Desktop/SADR/Michigan/NCES/School"
global NCESDistrict "/Users/minnamgung/Desktop/SADR/Michigan/NCES/District"
global NCESOld "/Users/minnamgung/Desktop/SADR/NCESOld"


**********************************************

/// NCES cleaning from 2013 to 2021
/// Update: we are adding DistLocale

**********************************************

global years 2013 2014 2015 2016 2017 2018 2020 2021 2021

foreach a in $years {
	
	use "${NCESOld}/NCES_`a'_District.dta", clear 
	keep if state_location == "MI"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	rename urban_centric_locale DistLocale
	drop year district_agency_type_num bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte
	
	decode DistType, generate(DistType1)
	drop DistType 
	rename DistType1 DistType
	
	decode DistLocale, generate(DistLocale1)
	drop DistLocale
	rename DistLocale1 DistLocale
	
	if(`a' != 2021){
                 drop agency_charter_indicator
				}
	
	save "${NCESDistrict}/NCES_`a'_District.dta", replace
	
	use "${NCESOld}/NCES_`a'_School.dta", clear
	keep if state_location == "MI"
	
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
	rename school_type SchType
	rename dist_urban_centric_locale DistLocale
	
	drop year district_agency_type_num school_id school_status DistEnrollment SchEnrollment dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch
	drop if seasch == ""
	
	foreach v of varlist SchLevel SchType DistType DistLocale {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	
	if(`a' != 2021){
                 drop dist_agency_charter_indicator
              }
	
	save "${NCESSchool}/NCES_`a'_School.dta", replace
	
}

**********************************************

/// NCES cleaning 2022 (incomplete file)
/// Merge in DistLocale, CountyName, CountyCode
/// from the 2021 file until we receive update

**********************************************

/// School 

use "${NCESOld}/NCES_2022_School.dta", clear

keep if StateAbbrev=="MI"
rename SchoolType SchType

gen seasch = substr(st_schid, 4, .)

merge 1:1 NCESDistrictID NCESSchoolID using "${NCESSchool}/NCES_2021_School.dta", keepusing (DistLocale CountyCode CountyName DistType)

foreach v of varlist DistLocale CountyName DistType {
	replace `v'="Missing/not reported" if _merge==1
}

replace CountyCode=. if _merge==1

drop if _merge==2
drop _merge SchYear sy_status_text st_schid schid

save "${NCESSchool}/NCES_2022_School.dta", replace


/// District

use "${NCESOld}/NCES_2022_District.dta", clear

keep if StateAbbrev=="MI"

rename ncesdistrictid NCESDistrictID

merge 1:1 NCESDistrictID using "${NCESDistrict}/NCES_2021_District.dta", keepusing (DistLocale CountyCode CountyName DistCharter)

foreach v of varlist DistLocale CountyName {
	replace `v'="Missing/not reported" if _merge==1
}

replace CountyCode=. if _merge==1

drop if _merge==2
drop _merge SchYear effective_date updated_status_text

save "${NCESDistrict}/NCES_2022_District.dta", replace
