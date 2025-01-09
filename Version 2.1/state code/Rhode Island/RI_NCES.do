clear
set more off

global NCES_Original "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/Rhode Island/NCES"


** Preparing NCES files
clear
tempfile tempdist
save "`tempdist'", emptyok replace
tempfile tempsch
save "`tempsch'", emptyok replace

global years 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCES_Original}/NCES_`a'_District.dta", clear 
	keep if state_location == "RI"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistLocale DistCharter DistName
	
	gen SchYear = string(`a') + "-" + substr(string(`a'+1),-2,2)
	expand 2 if SchYear == "2022-23", gen(ind)
	replace SchYear = "2023-24" if ind ==1
	drop ind
	append using "`tempdist'"
	save "`tempdist'", replace
	
	use "${NCES_Original}/NCES_`a'_School.dta", clear
	keep if state_location == "RI"
	
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
	if `a' != 2022 {
	foreach var of varlist SchType SchLevel SchVirtual {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	}
	if `a' == 2022 {
		foreach var of varlist SchType SchLevel SchVirtual DistType {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	}
	duplicates drop seasch, force
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""

	gen SchYear = string(`a') + "-" + substr(string(`a'+1),-2,2)
	expand 2 if SchYear == "2022-23", gen(ind)
	replace SchYear = "2023-24" if ind ==1
	drop ind
	replace SchName = "Blackstone Valley Prep Jr High" if NCESSchoolID == "440001500475"
	append using "`tempsch'"
	save "`tempsch'", replace
	
}
use "`tempdist'", clear
save "$NCES/NCES_District", replace
use "`tempsch'", clear
save "$NCES/NCES_School", replace
