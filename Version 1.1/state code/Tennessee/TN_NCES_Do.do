clear
global path "/Users/minnamgung/Desktop/SADR/Tennessee"
global nces "/Users/minnamgung/Desktop/SADR/NCESOld"

global ncesyears 2009 2011 2012 2013 2014 2016 2017 2018 2020 2021 2022
foreach n in $ncesyears {
	
	** NCES School Data

	use "${nces}/NCES_`n'_School.dta", clear
	
	if `n' == 2022 {
		drop DistLocale
		
		foreach v of varlist SchVirtual {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	}

	** Rename Variables

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
	rename school_type SchType
	rename dist_urban_centric_locale DistLocale
	
	foreach v of varlist DistLocale {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}

	** Isolate Tennessee Data

	drop if StateFips != 47
	drop if school_status == 2
	
	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter DistLocale NCESSchoolID seasch SchVirtual SchLevel SchType school_name 
	
	** Fix Variable Types

	decode SchLevel, gen(SchLevel2)
	decode SchType, gen(SchType2)
	drop SchLevel SchType
	rename SchLevel2 SchLevel 
	rename SchType2 SchType 
	replace seasch = "00" + State_leaid + "-" + seasch if `n' < 2016
	replace State_leaid = "TN-00" + State_leaid if `n' < 2016
	
	local m = `n' - 1999
	save "${path}/Intermediate/`n'_`m'_NCES_Cleaned_School.dta", replace

	** NCES District Data

	clear
	use "${nces}/NCES_`n'_District.dta", clear
	
	if `n' == 2022 {
		drop DistLocale
	}

	** Rename Variables

	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename urban_centric_locale DistLocale
	
	if `n' != 2022 {
	foreach v of varlist DistLocale {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	}

	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter CountyCode CountyName lea_name DistType DistLocale 
	
	** Fix Variable Types
	
	replace State_leaid = "TN-00" + State_leaid if `n' < 2016

	* Isolate Rhode Island Data

	drop if StateFips != 47
	save "${path}/Intermediate/`n'_`m'_NCES_Cleaned_District.dta", replace
}

use "${path}/Intermediate/2011_12_NCES_Cleaned_School.dta"
gen SchYear = "2011-12"
append using "${path}/Intermediate/2012_13_NCES_Cleaned_School.dta"
drop if SchYear == "2011-12" & NCESSchoolID != "470294001075"
drop SchYear
save "${path}/Intermediate/2012_13_NCES_Cleaned_School.dta", replace

global ncesyear 2010  
foreach n in $ncesyear {
	
	** NCES School Data

	use "${nces}/NCES_`n'_School.dta", clear

	** Rename Variables

	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename lea_name DistName
	rename dist_urban_centric_locale DistLocale
	rename school_type SchType

	** Isolate Tennessee Data

	drop if StateFips != 47
	drop if school_status == 2
	
	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter DistLocale NCESSchoolID seasch SchVirtual SchLevel SchType school_name 
	
	** Fix Variable Types

	decode SchLevel, gen(SchLevel2)
	decode SchType, gen(SchType2)
	drop SchLevel SchType
	rename SchLevel2 SchLevel 
	rename SchType2 SchType 
	replace seasch = "00" + State_leaid + "-" + seasch
	replace State_leaid = "TN-00" + State_leaid
	
	foreach v of varlist DistLocale {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	
	local m = `n' - 1999
	save "${path}/Intermediate/`n'_`m'_NCES_Cleaned_School.dta", replace

	** NCES District Data

	clear
	use "${nces}/NCES_`n'_District.dta", clear

	** Rename Variables

	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename state_fips StateFips
	rename agency_type DistType
	rename urban_centric_locale DistLocale

	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter DistLocale CountyCode CountyName lea_name DistType 
	
	** Fix Variable Types
	foreach v of varlist DistType DistLocale {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	
	replace State_leaid = "TN-00" + State_leaid

	* Isolate Rhode Island Data

	drop if StateFips != 47
	save "${path}/Intermediate/`n'_`m'_NCES_Cleaned_District.dta", replace
}
