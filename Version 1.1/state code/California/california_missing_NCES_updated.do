cap log close
log using california_cleaning.log, replace

cd "/Users/minnamgung/Desktop/SADR/California"


// unmerged districts, available on gdrive
global unmerged "/Users/minnamgung/Desktop/SADR/California/Unmerged Districts"
global nces "/Users/minnamgung/Desktop/SADR/California/NCES"


// 2022

import delimited "${unmerged}/CA_Unmerged_Districts_2022_With_NCES.csv", case(preserve) clear

gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 
gen CountyName = ""
gen CountyCode = . 

rename Charter DistCharter
rename DistrictType DistType


// keep State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter DistName

replace NCESDistrictID = "00" if NCESDistrictID == "missing"
	
//destring NCESDistrictID, generate(NCESDistrictID1)
//drop NCESDistrictID
//rename NCESDistrictID1 NCESDistrictID

replace DistCharter = "Yes" if DistCharter == "LEA for federal programs"
replace DistCharter = "No" if DistCharter == "Not a charter district"

replace State_leaid = subinstr(State_leaid, "CA-", "", .)

replace DistType = "Regular local school district" if DistType == "Regular public school district that is not a component of a supervisory union"
replace DistType = "Charter agency" if DistType == "Independent charter district"
// replace DistType = "Supervisory union" if DistType == "Local school district that is a component of a supervisory union"
replace DistType = "Regional education service agency" if DistType == "Service agency"
replace DistType = "State-operated agency" if DistType == "State agency"
// replace DistType = "Other education agency" if DistType == "Specialized public school district"

replace DistCharter = "Yes" if DistType == "Charter agency"
replace DistCharter = "No" if DistType == "Regular local school district"


order State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName

// 

gen State_leaid1 = substr(State_leaid, 4, .)
drop State_leaid

* rename DistrictType DistType
* rename Charter DistCharter

replace NCESDistrictID="0"+NCESDistrictID

save "${unmerged}/CA_Unmerged_Districts_2022_With_NCES.dta", replace 

// 2021
use "${nces}/1_NCES_2021_District.dta", clear

append using "${unmerged}/CA_Unmerged_Districts_2022_With_NCES.dta"

keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter DistLocale CountyName CountyCode DistName

save "${nces}/1_NCES_2021_District_With_Extra_Districts", replace

// repeat for 2022
use "${nces}/1_NCES_2022_District.dta", clear

gen State_leaid1 = substr(State_leaid, 4, .)
drop State_leaid
rename State_leaid1 State_leaid

append using "${unmerged}/CA_Unmerged_Districts_2022_With_NCES.dta"

drop lea_type

keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter DistLocale CountyName CountyCode DistName 

save "${nces}/1_NCES_2022_District_With_Extra_Districts", replace

// All Others
// import excel using "CA_Unmerged_Districts_2017_v2.xlsx", firstrow case(preserve) clear

// exception of 2014


global year 2010 2011 2012 2013 2015 2016 2017 2018 2019 2021

foreach a in $year {
	local prevyear = `a' - 1
	
	use "${unmerged}/CA_Unmerged_Districts_`a'_With_NCES.dta", clear
	
	/*
	if `a' > 2017 {
		rename DistrictType DistType 
		rename Charter DistCharter
	}
	*/
	
	if strpos(State_leaid, "CA-") {
		gen State_leaid1 = substr(State_leaid, 4, .)
		drop State_leaid
		rename State_leaid1 State_leaid
	}
	
	save "${unmerged}/CA_Unmerged_Districts_`a'_With_NCES.dta", replace
	
	use "${nces}/1_NCES_`prevyear'_District.dta", clear

	append using "${unmerged}/CA_Unmerged_Districts_`a'_With_NCES.dta"
	save "${nces}/1_NCES_`prevyear'_District_With_Extra_Districts", replace
}

