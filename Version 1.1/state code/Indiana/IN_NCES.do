clear
set more off

global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_New "/Volumes/T7/State Test Project/Indiana/NCES"


** Preparing NCES files

global years 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

tempfile tempncess
save "`tempncess'", replace emptyok
tempfile tempncesd
save "`tempncesd'", replace emptyok

foreach a in $years {
	
	use "${NCES_Original}/NCES_`a'_District.dta", clear 
	keep if state_location == "IN"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	replace State_leaid = subinstr(State_leaid, "IN-","",.)
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistLocale DistCharter DistName
	
	
	save "${NCES_New}/NCES_`a'_District.dta", replace
	append using "`tempncesd'"
	save "`tempncesd'", replace
	
	use "${NCES_Original}/NCES_`a'_School.dta", clear
	keep if state_location == "IN"
	
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
	replace State_leaid = subinstr(State_leaid, "IN-", "",.)
	if `a' == 2022 rename school_type SchType
	if `a' == 2022 {
		foreach var of varlist SchType SchLevel SchVirtual DistType {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	
	}
	if `a' != 2022 {
		foreach var of varlist SchType SchLevel SchVirtual {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	}
	replace seasch = substr(seasch, strpos(seasch, "-")+1,10)
	if `a' == 2013 duplicates drop seasch, force
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""

	
	save "${NCES_New}/NCES_`a'_School.dta", replace
	append using "`tempncess'"
	save "`tempncess'", replace
}

use "`tempncesd'", clear
duplicates drop NCESDistrictID, force
save "${NCES_New}/NCES_All_District", replace
use "`tempncess'", clear
duplicates drop NCESSchool, force
save "${NCES_New}/NCES_All_School", replace

