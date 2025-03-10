*******************************************************
* TENNESSEE

* File name: 01_TN_NCES
* Last update: 2/11/2025

*******************************************************
* Notes

	* This do file reads NCES files from 2009 through 2022 one by one.
	* It keeps only TN observations and appends it into two files - NCES_All_District and NCES_All_School.
	* Duplicates in NCES_All_District and NCES_All_School are removed. 
	* As of the last update 2/11/2025, the latest NCES file is for 2022.
	* This code will need to be updated when newer NCES files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear
set more off

cd "C:\Users\Clare\Desktop\Zelma V2.1\Tennessee"

/////////////////////////////////////////
*** Preparing NCES files ***
/////////////////////////////////////////

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

foreach a in $years {
	
	use "${NCES_District}/NCES_`a'_District.dta", clear 
	keep if state_location == "TN"
	
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
	replace State_leaid = subinstr(State_leaid, "TN-00", "",.)
	
	save "${NCES_TN}/NCES_`a'_District.dta", replace
	
	use "${NCES_School}/NCES_`a'_School.dta", clear
	keep if state_location == "TN"
	
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
		foreach var of varlist SchType SchLevel SchVirtual {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	if `a' == 2022 {
		decode DistType, gen(temp)
		drop DistType
		rename temp DistType
	}	
	
	
		
	if `a' < 2016 {
		replace seasch = State_leaid + "-" + seasch
	}
	
	if `a' > 2015 {
		replace seasch = subinstr(seasch, "00", "",1)
		replace State_leaid = subinstr(State_leaid, "TN-00","",.)
	}
	
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName sch_lowest_grade_offered
	drop if seasch == ""

	
	save "${NCES_TN}/NCES_`a'_School.dta", replace
	
}

clear
save "$NCES_TN/NCES_All_District", emptyok replace

clear
save "$NCES_TN/NCES_All_School", emptyok replace

forvalues year = 2009/2022 {
    
	use "$NCES_TN/NCES_`year'_District"
	append using "$NCES_TN/NCES_All_District"
	duplicates drop State_leaid, force
	save "$NCES_TN/NCES_All_District", replace
	
	use "$NCES_TN/NCES_`year'_School"
	append using "$NCES_TN/NCES_All_School"
	duplicates drop seasch, force
	
	save "$NCES_TN/NCES_All_School", replace
}

* End of 01_TN_NCES
