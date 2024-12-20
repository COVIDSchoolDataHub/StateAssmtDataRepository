cap log close

cd "/Volumes/T7/State Test Project/Alaska"
log using alaska_nces_cleaning.log, replace

global NCESOriginal "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_AK "/Volumes/T7/State Test Project/Alaska/NCES_AK"


// use NCES_2018_School.dta, clear
//
// gen seasch_og = seasch
// // use 1_NCES_2018_School_Alaska.dta, clear
//
//

global years 2016 2017 2018 2019 2020 2021

foreach a in $years {
	
	use "$NCESOriginal/NCES_`a'_School.dta", clear
	keep if state_fips == 2
	
	
	gen seasch_og = seasch
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
	* rename school_type SchType
	// rename virtual Virtual  // Might not work for 2021
	//rename school_level SchLevel
	

	if `a' == 2016 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 {

	split seasch, parse("-")
	drop seasch seasch1
	rename seasch2 seasch
	
	}
	
keep State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch DistCharter SchLevel SchVirtual CountyName CountyCode seasch_og DistLocale

	
save "$NCES_AK/1_NCES_`a'_School_Alaska.dta", replace
	
	use "$NCESOriginal/NCES_`a'_District.dta", clear 
	keep if state_fips == 2
	
	gen State_leaid_og = state_leaid
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	// rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	
	replace State_leaid = subinstr(State_leaid, "AK-", "", .)

	if `a' != 2010 { // | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 
	
	rename district_agency_type DistType
	
	}
	
	if `a' == 2010 {

	rename agency_type DistType

	}
	
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode State_leaid_og DistLocale
	
save "$NCES_AK/1_NCES_`a'_District_Alaska.dta", replace
	
}


