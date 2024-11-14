clear
set more off

global NCES_Original "/Users/miramehta/Documents/NCES District and School Demographics/"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"


** Preparing NCES files

global years 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

tempfile tempncess
save "`tempncess'", replace emptyok
tempfile tempncesd
save "`tempncesd'", replace emptyok

foreach a in $years {
	
	use "${NCES_Original}/NCES District Files, Fall 1997-Fall 2022/NCES_`a'_District.dta", clear 
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
	
	replace DistName = strproper(DistName)
	replace DistName = subinstr(DistName, " Of ", " of ", .)
	replace DistName = subinstr(DistName, "21ST", "21st", .)
	
	save "${NCES}/NCES_`a'_District_IN.dta", replace
	append using "`tempncesd'"
	save "`tempncesd'", replace
	
	use "${NCES_Original}/NCES School Files, Fall 1997-Fall 2022/NCES_`a'_School.dta", clear
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
	
	replace DistName = strproper(DistName)
	replace DistName = subinstr(DistName, " Of ", " of ", .)
	replace DistName = subinstr(DistName, "21ST", "21st", .)
	
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""

	
	save "${NCES}/NCES_`a'_School_IN.dta", replace
	append using "`tempncess'"
	save "`tempncess'", replace
}

use "`tempncesd'", clear
duplicates drop NCESDistrictID, force
save "${NCES}/NCES_All_District", replace
use "`tempncess'", clear
duplicates drop NCESSchool, force
save "${NCES}/NCES_All_School", replace

