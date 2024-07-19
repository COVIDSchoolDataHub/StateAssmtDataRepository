clear
set trace off
set more off

global original "/Users/kaitlynlucas/Desktop/Delaware State Task/Original Data Files"
global output "/Users/kaitlynlucas/Desktop/Delaware State Task/Output"
global nces "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESNew"
global PART2 "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/Delaware/DE_2015_2022_PART2.do"

global NCESOLD "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESOld1"
global NCESNEW "/Users/kaitlynlucas/Desktop/Delaware State Task/NCESNew"

global data "/Users/kaitlynlucas/Desktop/Delaware State Task/2015-2017 DCAS files"


foreach year in 2014 2015 2016 2017 2018 2019 2020 2021 2022 {
use "${NCESOLD}/NCES_`year'_District.dta"
drop year

rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename county_name CountyName
rename county_code CountyCode
rename district_agency_type DistType

if `year' != 2022 {
	keep if state_name=="Delaware" 
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
}

if `year' == 2022 {
	keep if state_fips_id == 10
	gen StateAbbrev = "DE"
	rename state_fips_id StateFips
}

if `year' < 2016 {
	
gen StateAssignedDistID = State_leaid

}

else {
gen StateAssignedDistID = substr(State_leaid, strpos(State_leaid, "-")+1, .)
}


//Problem merging school and district data together onto raw data, renaming variables to maintain data. Will replace in DE do-file.
rename DistCharter DistCharter1
rename DistType DistType1
rename NCESDistrictID NCESDistrictID1
rename CountyName CountyName1
rename CountyCode CountyCode1
rename State_leaid State_leaid1
rename DistLocale DistLocale1
encode DistType1, gen(temp)
drop DistType1
rename temp DistType1
save "${NCESNEW}/NCES_`year'_district.dta", replace
clear
}
