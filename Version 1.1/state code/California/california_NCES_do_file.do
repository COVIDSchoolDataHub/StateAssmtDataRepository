clear
set more off

cap log close
log using california_nces_cleaning.log, replace

cd "/Users/minnamgung/Desktop/SADR/California"

global NCESOld "/Users/minnamgung/Desktop/SADR/NCESOld"
global California1 "/Users/minnamgung/Desktop/SADR/California/NCES"

**********************************************

/// NCES cleaning from 2013 to 2021
/// Update: we are adding DistLocale

**********************************************

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021

foreach a in $years {
	
	
	use "${NCESOld}/NCES_`a'_School.dta", clear
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
	rename dist_urban_centric_locale DistLocale
	// rename virtual Virtual  // Might not work for 2021
	//rename school_level SchLevel
	
	foreach v of varlist SchLevel SchType DistType DistLocale {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	
	replace State_leaid = subinstr(State_leaid, "CA-", "", .)
	split seasch, parse("-")
	
	if `a' == 2009 | `a' == 2010 | `a' == 2011 | `a' == 2012 | `a' == 2013 | `a' == 2014 | `a' == 2015 {
	
	order State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch1 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode
	keep State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch1 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode
	}
	
	
	if `a' == 2016 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 {
	order State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch2 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode
	keep State StateAbbrev StateFips SchType NCESDistrictID NCESSchoolID seasch2 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode
	
	}

	
	save "${California1}/1_NCES_`a'_School.dta", replace
	
	use "${NCESOld}/NCES_`a'_District.dta", clear 
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
	rename urban_centric_locale DistLocale
	
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
	
	decode DistLocale, generate(DistLocale1)
	drop DistLocale
	rename DistLocale1 DistLocale
	
	if `a' == 2009 | `a' == 2010 | `a' == 2011 | `a' == 2012 | `a' == 2013 {
	
	replace DistName = subinstr(DistName," Elem", " Elementary" , .)
	replace DistName = subinstr(DistName, " Unf"," Unified", .)
	replace DistName = ustrtitle(DistName)

	}

order State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter DistLocale CountyName CountyCode DistName
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter DistLocale CountyName CountyCode DistName

	


	
	save "${California1}/1_NCES_`a'_District.dta", replace
	
}



use "${California1}/1_NCES_2012_District.dta", clear
replace DistName = subinstr(DistName," Elem", " Elementary" , .)
	replace DistName = subinstr(DistName, " Unf"," Unified", .)
	replace DistName = ustrtitle(DistName)
	
save "${California1}/1_NCES_2012_District.dta", replace


**********************************************

/// NCES cleaning 2022 (incomplete file)
/// Merge in DistLocale, CountyName, CountyCode
/// from the 2021 file until we receive update

**********************************************

/// School 

use "${NCESOld}/NCES_2022_School.dta", clear

keep if StateAbbrev=="CA"
rename SchoolType SchType

gen seasch = substr(st_schid, 4, .)

replace NCESSchoolID="0"+NCESSchoolID

merge 1:1 NCESSchoolID using "${California1}/1_NCES_2021_School.dta", keepusing (DistLocale CountyCode CountyName DistType)

foreach v of varlist DistLocale CountyName DistType {
	replace `v'="Missing/not reported" if _merge==1
}

replace CountyCode=. if _merge==1

drop if _merge==2
drop _merge SchYear sy_status_text st_schid schid

drop StateFips
gen StateFips=6

save "${California1}/1_NCES_2022_School.dta", replace


/// District

use "${NCESOld}/NCES_2022_District.dta", clear

keep if StateAbbrev=="CA"

rename ncesdistrictid NCESDistrictID

replace NCESDistrictID="0"+NCESDistrictID

merge 1:1 NCESDistrictID using "${California1}/1_NCES_2021_District.dta", keepusing (DistLocale CountyCode CountyName DistCharter)

foreach v of varlist DistLocale CountyName {
	replace `v'="Missing/not reported" if _merge==1
}

replace CountyCode=. if _merge==1

drop if _merge==2
drop _merge SchYear effective_date updated_status_text



drop StateFips
gen StateFips=6

save "${California1}/1_NCES_2022_District.dta", replace
