clear
set more off

cap log close
log using california_nces_cleaning.log, replace


cd "/Users/minnamgung/Desktop/SADR/California"

global NCESSchool1 "/Users/minnamgung/Desktop/SADR/California/NCES_School"
global NCESDistrict1 "/Users/minnamgung/Desktop/SADR/California/NCES_District"
global California1 "/Users/minnamgung/Desktop/SADR/California"



global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021

foreach a in $years {
	
	
	use "${NCESSchool1}/NCES_`a'_School.dta", clear
	keep if state_fips == 6
	
	// rename state_name State
	gen State = "California"
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	// rename charter Charter
	rename county_name CountyName
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	rename school_type SchType
	// rename virtual Virtual  // Might not work for 2021
	//rename school_level SchLevel
	
	decode DistType, gen (DistType1)
    drop DistType
    rename DistType1 DistType
	
	replace State_leaid = subinstr(State_leaid, "CA-", "", .)
	split seasch, parse("-")
	
	if `a' == 2009 | `a' == 2010 | `a' == 2011 | `a' == 2012 | `a' == 2013 | `a' == 2014 | `a' == 2015 {
	
	order State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch1  DistCharter SchLevel SchVirtual CountyName CountyCode
	keep State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch1  DistCharter SchLevel SchVirtual CountyName CountyCode
	}
	
	
	if `a' == 2016 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 {
	order State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch2  DistCharter SchLevel SchVirtual CountyName CountyCode
	keep State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch2  DistCharter SchLevel SchVirtual CountyName CountyCode
	
	}

	
	save "${California1}/1_NCES_`a'_School.dta", replace
	
	use "${NCESDistrict1}/NCES_`a'_District.dta", clear 
	keep if state_fips == 6
	
	gen State = "California"
	// rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename lea_name DistName
	// rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	
	replace State_leaid = subinstr(State_leaid, "CA-", "", .)
	replace DistName = subinstr(DistName, "District", "", .)
	replace DistName = strrtrim(DistName)
	
	
	
		if `a' != 2010 { // | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 
	
	rename district_agency_type DistType
	

	}
	
	if `a' == 2010 {

	rename agency_type DistType

	}
	
	decode DistType, gen (DistType1)
    drop DistType
    rename DistType1 DistType
	
	if `a' == 2009 | `a' == 2010 | `a' == 2011 | `a' == 2012 | `a' == 2013 {
	
	replace DistName = subinstr(DistName," Elem", " Elementary" , .)
	replace DistName = subinstr(DistName, " Unf"," Unified", .)
	replace DistName = ustrtitle(DistName)

	}

order State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName

	


	
	save "${California1}/1_NCES_`a'_District.dta", replace
	
}



use 1_NCES_2012_District.dta, clear
replace DistName = subinstr(DistName," Elem", " Elementary" , .)
	replace DistName = subinstr(DistName, " Unf"," Unified", .)
	replace DistName = ustrtitle(DistName)
	
save 1_NCES_2012_District.dta, replace
