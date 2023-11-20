clear
set more off

global NCES "/Users/sarahridley/Desktop/CSDH/Raw/NCES"
global Arizona "/Users/sarahridley/Desktop/CSDH/Raw/Test Scores/Arizona/NCES"

global NCES "/Users/minnamgung/Desktop/SADR/NCES District and School Demographics-2"
global Iowa "/Users/minnamgung/Desktop/SADR/Utah/NCES"
global utah "/Users/minnamgung/Desktop/SADR/Utah"

global years 2014 2015 2016 2017 2018 2019 2020 2021

foreach a in $years {
	
	use "${NCES}/NCES District Files, Fall 1997-Fall 2021/NCES_`a'_District.dta", clear 
	keep if state_fips==49
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	
	rename lea_name DistName
	
	foreach i of varlist DistType {
	decode `i', gen(`i'1)
	drop `i'
	rename `i'1 `i'
}
	
	save "${Iowa}/NCES_`a'_District.dta", replace
	
	use "${NCES}/NCES School Files, Fall 1997-Fall 2021/NCES_`a'_School.dta", clear
	keep if state_fips==49
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename *agency_type DistType
	rename ncesschoolid NCESSchoolID
	rename school_type SchType
	
	rename school_name SchName
	rename lea_name DistName
	
	drop if NCESDistrictID == ""
	
	replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & SchLevel==1
	replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & SchLevel==2
	
	replace SchName="MINERSVILLE SCHOOL (Primary)" if SchName=="MINERSVILLE SCHOOL" & SchLevel==1
	replace SchName="MINERSVILLE SCHOOL (Middle)" if SchName=="MINERSVILLE SCHOOL" & SchLevel==2
	
	foreach i of varlist SchType SchLevel SchVirtual DistType {
	decode `i', gen(`i'1)
	drop `i'
	rename `i'1 `i'
}
	
	save "${Iowa}/NCES_`a'_School.dta", replace
	
}

import excel "/Users/minnamgung/Desktop/SADR/Utah/UT_unmerged_schools.xlsx", sheet("UT unmerged") firstrow clear 

save "/Users/minnamgung/Desktop/SADR/Utah/UT_unmerged_schools1.dta", replace

