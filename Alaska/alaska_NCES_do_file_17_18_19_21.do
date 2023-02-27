cap log close
log using alaska_cleaning.log, replace

cd "/Users/benjaminm/Documents/State_Repository_Research/Alaska"

// 2016-17
use "NCES_2017_District.dta", clear

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename district_agency_type DistrictType
rename county_name CountyName
rename county_code CountyCode

drop year

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistName "District name"
label var DistrictType "District type as defined by NCES"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"

decode State, gen(State2)
drop State
rename State2 State 
keep if State == "Alaska"

replace DistName = "Delta/Greely School District" if DistName == "Delta-Greely School District"

save NCES_2017_District_Data_Cleaned, replace

// 2017-18
use "NCES_2018_District.dta", clear

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename district_agency_type DistrictType
rename county_name CountyName
rename county_code CountyCode

drop year

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistName "District name"
label var DistrictType "District type as defined by NCES"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"

decode State, gen(State2)
drop State
rename State2 State 
keep if State == "Alaska"

replace DistName = "Delta/Greely School District" if DistName == "Delta-Greely School District"

save NCES_2018_District_Data_Cleaned, replace

// 2018-19
use "NCES_2019_District.dta", clear

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename district_agency_type DistrictType
rename county_name CountyName
rename county_code CountyCode

drop year

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistName "District name"
label var DistrictType "District type as defined by NCES"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"

decode State, gen(State2)
drop State
rename State2 State 
keep if State == "Alaska"

replace DistName = "Delta/Greely School District" if DistName == "Delta-Greely School District"

save NCES_2019_District_Data_Cleaned, replace

// 2020-21
import excel "NCES_2020-2021_District_Demographics_opt.xlsx", clear

rename A State
rename B StateAbbrev
rename C StateFips
rename D NCESDistrictID
rename E State_leaid
rename F DistName
rename G DistrictType
rename I CountyName
rename J CountyCode

drop K, H

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistName "District name"
label var DistrictType "District type as defined by NCES"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"

keep if State == "Alaska"

replace DistName = "Delta/Greely School District" if DistName == "Delta-Greely School District"

save NCES_2021_District_Data_Cleaned, replace
 
 
