
clear
set trace off
local NCES "/Users/meghancornacchia/Desktop/DataRepository/NCES_Data_Files"
local WY_NCES "/Users/meghancornacchia/Desktop/DataRepository/Wyoming/New_NCES"
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
