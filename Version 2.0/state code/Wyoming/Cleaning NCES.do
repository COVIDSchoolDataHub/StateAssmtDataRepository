
clear
set trace off
local NCES "/Users/kaitlynlucas/Desktop/Wyoming/NCES"
local WY_NCES "/Users/kaitlynlucas/Desktop/Wyoming/NCES"
forvalues year = 2014/2022 {
local prevyear =`=`year'-1'
	foreach dl in District School {
use "`NCES'/NCES_`prevyear'_`dl'.dta"
keep if state_location == "WY" | state_name == "Wyoming"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType

if "`dl'" == "School" drop SchType 
if "`dl'" == "School" rename SchType_str SchType 
if "`dl'" == "School" drop SchVirtual
if "`dl'" == "School" rename SchVirtual_str SchVirtual
if "`dl'" == "School" drop SchLevel 
if "`dl'" == "School" rename SchLevel_str SchLevel

rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
if "`dl'" == "School" rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 56
replace StateAbbrev = "WY"
replace lea_name = subinstr(lea_name, " ", "",.)
replace lea_name = lower(lea_name)
replace lea_name = subinstr(lea_name, "countyschooldistrict", "",.)

if "`dl'" == "School" replace school_name = lower(school_name)
if "`dl'" == "School" replace school_name = subinstr(school_name, " ", "",.)
if "`dl'" == "School" replace school_name = lea_name + "-" + school_name
cap duplicates drop school_name, force 
save "`WY_NCES'/NCESnew_`prevyear'_`dl'.dta", replace
	}	
}

use "/Users/kaitlynlucas/Desktop/Wyoming/NCES/NCES_2022_School.dta", clear
keep if state_location == "WY" | state_name == "Wyoming"

//Fixing NCES Variables
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type DistType
drop SchType 
rename school_type SchType 
tostring year, generate(year_str)
drop year
rename year_str year
decode DistType, generate(DistType_str)
drop DistType
rename DistType_str DistType
drop DistType_str
gen DistType_str = value_label(DistType)
decode SchLevel, gen(SchLevel_str)
drop SchLevel
rename SchLevel_str SchLevel
decode SchVirtual, generate(SchVirtual_str)
drop SchVirtual
rename SchVirtual_str SchVirtual
decode SchType, gen(SchType_str)
drop SchType
rename SchType_str SchType
decode DistEnrollment, gen(distenroll_str)
drop DistEnrollment
rename distenroll_str DistEnrollment
tostring number_of_schools, gen(numschool_str)
drop number_of_schools
rename numschool_str number_of_schools
tostring dist_teachers_total_fte, gen(disttotalteach_str)
drop dist_teachers_total_fte
rename disttotalteach_str dist_teachers_total_fte
decode dist_urban_centric_locale, gen(dopp_str)
drop dist_urban_centric_locale
rename dopp_str dist_urban_centric_locale
decode boundary_change_indicator, gen(dist_boundary_change_indicator)
drop boundary_change_indicator
tostring dist_staff_total_fte, gen(dstf_str)
drop dist_staff_total_fte
rename dstf_str dist_staff_total_fte
decode dist_agency_level, gen(dal_str)
drop dist_agency_level
rename dal_str dist_agency_level
decode dist_lowest_grade_offered, gen(dlgo_str)
drop dist_lowest_grade_offered
rename dlgo_str dist_lowest_grade_offered
decode dist_highest_grade_offered, gen(dhgo_str)
drop dist_highest_grade_offered
rename dhgo_str dist_highest_grade_offered
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 56
replace StateAbbrev = "WY"
replace lea_name = subinstr(lea_name, " ", "",.)
replace lea_name = lower(lea_name)
replace lea_name = subinstr(lea_name, "countyschooldistrict", "",.)
replace school_name = lower(school_name)
replace school_name = subinstr(school_name, " ", "",.)
replace school_name = lea_name + "-" + school_name
cap duplicates drop school_name, force 
save "${NCES}/NCESnew_2022_School.dta", replace
