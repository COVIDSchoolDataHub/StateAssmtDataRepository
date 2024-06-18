clear
set more off
set trace off
cap log close
log using california_nces_cleaning.log, replace

cd "/Volumes/T7/State Test Project/California"

global NCESOld "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global California1 "/Volumes/T7/State Test Project/California/NCES"

global years 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022

foreach a in $years {
	
	
	use "${NCESOld}/NCES_`a'_School.dta", clear
	keep if state_fips == 6
	
	gen State = "California"
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	destring CountyCode, replace
	rename ncesschoolid NCESSchoolID
	rename lea_name DistName1
	
	if `a' == 2022 {
		decode DistType, gen(temp)
		drop DistType
		rename temp DistType
		rename school_type SchType
	}
	
	foreach v of varlist SchLevel SchVirtual SchType {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	
	//Dealing with duplicate seasch values
	duplicates tag seasch, gen(ind)
	tab ind
	tab school_name if ind !=0
	duplicates drop seasch, force  //Arbitary decision, NCES ID's are different, DistTypes are different, but they all seem to be the same school based on ID and school_name
	

	replace State_leaid = subinstr(State_leaid, "CA-", "", .)
	split seasch, parse("-")
	
	if `a' == 2009 | `a' == 2010 | `a' == 2011 | `a' == 2012 | `a' == 2013 | `a' == 2014 | `a' == 2015 {
	
	order State StateAbbrev StateFips SchType NCESDistrictID DistName1 NCESSchoolID seasch1 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode school_name
	keep State StateAbbrev StateFips SchType NCESDistrictID DistName1 NCESSchoolID seasch1 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode school_name
	}
	
	
	if `a' == 2016 | `a' == 2017 | `a' == 2018 | `a' == 2019 | `a' == 2020 | `a' == 2021 | `a' == 2022 {
	order State StateAbbrev StateFips SchType NCESDistrictID DistName1 NCESSchoolID seasch2 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode school_name
	keep State StateAbbrev StateFips SchType NCESDistrictID DistName1 NCESSchoolID seasch2 DistType DistCharter DistLocale SchLevel SchVirtual CountyName CountyCode school_name
	duplicates drop seasch2, force
	}

	
	save "${California1}/1_NCES_`a'_School.dta", replace
	
	use "${NCESOld}/NCES_`a'_District.dta", clear 
	keep if state_fips == 6
	
	gen State = "California"
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename lea_name DistName
	rename district_agency_type DistType
	// rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	destring CountyCode, replace force
	
	replace State_leaid = subinstr(State_leaid, "CA-", "", .)
	replace DistName = subinstr(DistName, "District", "", .)
	replace DistName = strrtrim(DistName)
	

	
	
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
