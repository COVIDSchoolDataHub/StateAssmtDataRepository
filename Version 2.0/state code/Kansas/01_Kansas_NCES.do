****************************************************************
** Preparing NCES files 
****************************************************************
clear
set more off

global raw "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Raw"
global temp "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\temp"
global NCESDistrict "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES District Files, Fall 1997-Fall 2022"
global NCESSchool "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES School Files, Fall 1997-Fall 2022"
global EDFacts "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\EdFacts"
global output "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Output"

****************************************************************
** NCES_2014 to NCES_2021 (for Spring 2015 through Spring 2022)
****************************************************************

global years 2014 2015 2016 2017 2018 2020 2021

foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_location == "KS"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	
	save "${NCESDistrict}/NCES_`a'_District_KS.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_location == "KS"
	
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
	drop if seasch == ""
	
	save "${NCESSchool}/NCES_`a'_School_KS.dta", replace
	
}

****************************************************************
** NCES_2022 (for Spring 2023, Spring 2024)
****************************************************************

use "${NCESSchool}/NCES_2022_School.dta", clear

	// Renaming 
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips_id StateFips
	drop if StateAbbrev != "KS"
	rename ncesschoolid NCESSchoolID
	rename ncesdistrictid NCESDistrictID
	rename lea_name DistName
	rename school_type SchType
	rename school_name SchName
	decode district_agency_type, gen (DistType)
	drop district_agency_type
	rename county_name CountyName
	rename county_code CountyCode
	rename state_leaid State_leaid
	
	
	merge 1:1 NCESDistrictID NCESSchoolID using "${NCESSchool}/NCES_2021_School_KS.dta", keepusing (DistLocale CountyCode CountyName DistType SchVirtual)
	drop if _merge == 2
	drop _merge
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID seasch State_leaid DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual
	
	save "${NCESSchool}/NCES_2022_School_KS.dta", replace
			
	use "${NCESDistrict}/NCES_2022_District.dta", clear
	drop if state_location != "KS"
	rename lea_name DistName
	rename ncesdistrictid NCESDistrictID
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename state_leaid State_leaid
	drop year
	
	merge 1:1 NCESDistrictID using "${NCESDistrict}/NCES_2021_District_KS.dta", keepusing (DistLocale CountyCode CountyName DistCharter)
	drop if _merge == 2
	drop _merge
	
save "${NCESDistrict}/NCES_2022_District_KS.dta", replace

