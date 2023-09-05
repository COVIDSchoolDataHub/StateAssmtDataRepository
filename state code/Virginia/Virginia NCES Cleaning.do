clear
set more off

global NCESSchool "/Users/maggie/Desktop/Virginia/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Virginia/NCES/District"
global NCES "/Users/maggie/Desktop/Virginia/NCES/Cleaned"

global years 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2020 2021


foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_fips == 51
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	drop year urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte
	
	if(`a' != 2010){
		rename district_agency_type DistType
		drop district_agency_type_num
	}
	
	if(`a' > 2011 & `a' < 2021){
                 drop agency_charter_indicator
				}
	
	save "${NCES}/NCES_`a'_District.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_fips == 51
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName	
	rename ncesschoolid NCESSchoolID
	rename school_name SchName
	rename school_type SchType
	drop year school_id school_status SchEnrollment
	drop if seasch == ""
	
	if(`a' != 1998){
		rename district_agency_type DistType
		drop district_agency_type_num DistEnrollment
	}
	
	if(`a' < 1998){
		drop lowest_grade_offered highest_grade_offered bureau_indian_education urban_centric_locale lunch_program lunch_program free_lunch reduced_price_lunch free_or_reduced_price_lunch
	}
	
	if(`a' > 1997){
		drop sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch
	}
	
	if(`a' > 1998){
        drop dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte
              }
	
	if(`a' > 2012 & `a' < 2021){
         drop dist_agency_charter_indicator
              }
	
	save "${NCES}/NCES_`a'_School.dta", replace
	
}
