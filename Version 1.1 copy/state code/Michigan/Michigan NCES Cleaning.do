clear
set more off

cd "/Volumes/T7/State Test Project/Michigan"

global NCESNew "/Volumes/T7/State Test Project/Michigan/NCES"
global NCESOld "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"


**********************************************

/// NCES cleaning from 2013 to 2022
/// Update: we are adding DistLocale

**********************************************

global years 2013 2014 2015 2016 2017 2018 2020 2021 2022

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
	keep State StateAbbrev StateFips NCESDistrict State_leaid DistType CountyName CountyCode DistName DistLocale DistCharter
	
	
	save "${NCESNew}/NCES_`a'_District.dta", replace
	
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
	if `a' == 2022 rename school_type SchType
	
	drop if seasch == ""
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistName NCESSchoolID SchName SchType SchLevel SchVirtual seasch DistCharter DistLocale
	
	
	if `a' == 2022 {
	foreach v of varlist SchLevel SchVirtual SchType DistType {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
}
	
	
	save "${NCESNew}/NCES_`a'_School.dta", replace
	
}
/*
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

save "${NCESNew}/NCES_2022_School.dta", replace


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

save "${NCESNew}/NCES_2022_District.dta", replace
