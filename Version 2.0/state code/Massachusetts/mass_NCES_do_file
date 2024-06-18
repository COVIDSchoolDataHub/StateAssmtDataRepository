cap log close
log using massachussets_nces_cleaning.log, replace



cd "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
*global nces "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Massachusetts_Dir "/Volumes/T7/State Test Project/Massachusetts"

//use NCES_2016_School.dta, clear
// use NCES_2015_School.dta, clear


//use 1_NCES_2013_School_Mass.dta, clear

*use "${NCES}/NCES_District/NCES_2009_District.dta", clear
*use "NCES_2009_District.dta", clear


global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021

foreach a in $years {
	
	*use "${NCES}/NCES_School/NCES_`a'_School.dta", clear
	use "NCES_`a'_School.dta", clear
	keep if state_fips == 25
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	// rename charter Charter
	rename county_name CountyName
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	//rename school_type SchType
	// rename virtual Virtual  // Might not work for 2021
	//rename school_level SchLevel

	if `a' == 2016 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 {

	split seasch, parse("-")
	drop seasch seasch1
	rename seasch2 seasch
	
	}
	
keep State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch DistCharter SchLevel SchVirtual CountyName CountyCode 


	
save "$Massachusetts_Dir/2_NCES_`a'_School_Mass.dta", replace
	
	*use "${NCES}/NCES_District/NCES_`a'_District.dta", clear
	use "NCES_`a'_District.dta"
	keep if state_fips == 25
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	// rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	
	replace State_leaid = subinstr(State_leaid, "MA-", "", .)

	//if `a' != 2010 { // | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 
	
	rename district_agency_type DistType
	

	//}
	
	//if `a' == 2010 {

	//rename agency_type DistType

	//}
	
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistLocale
	
save "$Massachusetts_Dir/2_NCES_`a'_District_Mass.dta", replace
	
}

// fix to Mass 2013 NCES

use "$Massachusetts_Dir/2_NCES_2013_School_Mass", clear
duplicates drop seasch, force

save "$Massachusetts_Dir/2_NCES_2013_School_Mass", replace

//use "2_NCES_2011_District_Mass.dta", clear
	

