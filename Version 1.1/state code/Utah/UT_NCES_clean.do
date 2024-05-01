clear
set more off

global raw "/Users/miramehta/Documents/UT State Testing Data/Original Data"
global output "/Users/miramehta/Documents/UT State Testing Data/Output"
global int "/Users/miramehta/Documents/UT State Testing Data/Intermediate"

global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global utah "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

global edfacts "/Users/miramehta/Documents/EdFacts/Output"

global years 2013 2014 2015 2016 2017 2018 2019 2020 2021

foreach a in $years {
	
	use "${nces}/NCES District Files, Fall 1997-Fall 2022/NCES_`a'_District.dta", clear 
	keep if state_location == "UT"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	
	rename lea_name DistName
	
	save "${utah}/NCES_`a'_District.dta", replace
	
	use "${nces}/NCES School Files, Fall 1997-Fall 2022/NCES_`a'_School.dta", clear
	keep if state_location == "UT"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename *agency_type DistType
	rename ncesschoolid NCESSchoolID
	
	rename school_name SchName
	rename lea_name DistName
	
	drop if NCESDistrictID == ""
	
	replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & SchLevel==1
	replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & SchLevel==2
	
	replace SchName="MINERSVILLE SCHOOL (Primary)" if SchName=="MINERSVILLE SCHOOL" & SchLevel==1
	replace SchName="MINERSVILLE SCHOOL (Middle)" if SchName=="MINERSVILLE SCHOOL" & SchLevel==2
	
	replace SchName="CANYON VIEW SCHOOL (Primary)" if SchName=="CANYON VIEW SCHOOL" & SchLevel==1
	replace SchName="CANYON VIEW SCHOOL (Middle)" if SchName=="CANYON VIEW SCHOOL" & SchLevel==2
	
	replace SchName="Canyon View School (Primary)" if SchName=="Canyon View School" & SchLevel==1
	replace SchName="Canyon View School (Middle)" if SchName=="Canyon View School" & SchLevel==2
	
	if `a' == 2016 {
		drop if SchName == "Canyon View School"
	}
	
	replace SchName=strproper(SchName)
	replace DistName=strproper(DistName)
	
	save "${utah}/NCES_`a'_School.dta", replace
	
}

use "${nces}/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School.dta", clear

rename state_name State
rename state_location StateAbbrev
rename fips StateFips
drop if StateAbbrev != "UT"
rename state_fips_id state_fips
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename lea_name DistName
rename school_name SchName

replace SchName="Minersville School (Primary)" if SchName=="Minersville School" & SchLevel == 1
replace SchName="Minersville School (Middle)" if SchName=="Minersville School" & SchLevel == 2
drop SchVirtual

merge 1:1 NCESDistrictID NCESSchoolID using "${utah}/NCES_2021_School.dta", keepusing (DistLocale CountyCode CountyName district_agency_type SchVirtual)
drop if _merge == 2
drop _merge

rename school_type SchType

replace SchVirtual = -1 if SchName == "Glacier Hills Elementary"
replace CountyName = "Salt Lake County" if SchName == "Glacier Hills Elementary"
replace CountyCode = "49035" if SchName == "Glacier Hills Elementary"
replace district_agency_type = 1 if SchName == "Glacier Hills Elementary"
replace DistLocale = "City, midsize" if SchName == "Glacier Hills Elementary"

replace SchVirtual = -1 if SchName == "Nebo Online School"
replace CountyName = "Utah County" if SchName == "Nebo Online School"
replace CountyCode = "49049" if SchName == "Nebo Online School"
replace district_agency_type = 1 if SchName == "Nebo Online School"
replace DistLocale = "City, midsize" if SchName == "Nebo Online School"

decode district_agency_type, gen (DistType)
drop district_agency_type

keep NCESDistrictID NCESSchoolID SchName DistName seasch State_leaid DistType DistLocale CountyCode CountyName DistCharter SchType SchLevel SchVirtual

save "${utah}/NCES_2022_School.dta", replace

use "${nces}/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District.dta", clear
rename state_name State
rename state_location StateAbbrev
rename fips StateFips
drop if StateAbbrev != "UT"
rename ncesdistrictid NCESDistrictID
rename lea_name DistName
rename state_leaid State_leaid
rename district_agency_type DistType
merge 1:1 NCESDistrictID using "${utah}/NCES_2021_District.dta", keepusing (DistLocale CountyCode CountyName DistCharter)
drop if _merge == 2
drop _merge
save "${utah}/NCES_2022_District.dta", replace

import excel "${raw}/UT_unmerged_schools.xlsx", sheet("UT unmerged") firstrow clear 
tostring CountyCode, replace
save "${raw}/UT_unmerged_schools.dta", replace format() force

use "${raw}/ut_full-dist-sch-stable-list_through2023.dta", clear
tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format("%12.0f")
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
drop DataLevel 
rename DataLevel_n DataLevel
save "${raw}/ut_full-dist-sch-stable-list_through2023.dta", replace
