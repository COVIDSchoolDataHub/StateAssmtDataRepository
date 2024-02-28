clear
set trace off
set more off

local old "/Users/minnamgung/Desktop/SADR/NCESOld"
local new "/Users/minnamgung/Desktop/SADR/Delaware/NCESNew"

foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 {
use "`old'/NCES_`year'_district.dta"
drop year
keep if state_name==10
rename state_name State
decode State, gen (State1)
drop State
rename State1 State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid

if `year' < 2016 {
	
gen StateAssignedDistID = State_leaid

}

else {
gen StateAssignedDistID = substr(State_leaid, strpos(State_leaid, "-")+1, .)
}

rename lea_name DistName
rename district_agency_type DistType
rename county_name CountyName
rename county_code CountyCode
decode DistType, gen (DistType1)
drop DistType
rename DistType1 DistType
//Problem merging school and district data together onto raw data, renaming variables to maintain data. Will replace in DE do-file.
rename DistCharter DistCharter1
rename DistType DistType1
rename NCESDistrictID NCESDistrictID1
rename CountyName CountyName1
rename CountyCode CountyCode1
rename State_leaid State_leaid1
save "`new'/NCES_`year'_district.dta", replace
clear
}

