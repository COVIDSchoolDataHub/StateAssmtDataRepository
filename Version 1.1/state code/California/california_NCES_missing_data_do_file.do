clear
set more off

cap log close
log using california_cleaning.log, replace

cd "/Users/minnamgung/Desktop/SADR/California"


// 2021
* use NCES_2021_District, clear
* use NCES_2020_District, clear
* rename ncesdistrictid NCESDistrictID





import delimited "CA_Unmerged_Districts_2022_With_NCES.csv", case(preserve) clear


gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 
gen CountyName = ""
gen CountyCode = . 

// drop DistName 
rename v3 DistName1

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


order State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName DistName1
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName DistName1

// 
save 1_CA_Unmerged_Districts_20212With_NCES, replace 


use 1_NCES_2021_District, clear
append using 1_CA_Unmerged_Districts_20212With_NCES

replace DistName1=DistName if DistName1=="" & NCESDistrictID!="00"

duplicates drop DistName, force

save 1_NCES_2021_District_With_Extra_Districts, replace



// All Others
// import excel using "CA_Unmerged_Districts_2017_v2.xlsx", firstrow case(preserve) clear


global time 2018 2019 2021  

foreach a in $time {

local prevyear = `a' - 1

import excel using "CA_Unmerged_Districts_`a'_With_NCES.xlsx", firstrow case(preserve) clear


gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 
gen CountyName = ""
gen CountyCode = . 

drop DistName 
rename DistName1 DistName

// NEW ADDED
rename Charter DistCharter
rename DistrictType DistType
// NEW ADDED

if `a' != 2018 {
replace NCESDistrictID = 00 if NCESDistrictID == .
}

if `a' == 2018 {
replace NCESDistrictID = "00" if NCESDistrictID == "missing"
}

if `a' != 2018 {
tostring NCESDistrictID, generate(NCESDistrictID1)
drop NCESDistrictID
rename NCESDistrictID1 NCESDistrictID
}

// NEW ADDED
replace DistCharter = "Yes" if DistCharter == "LEA for federal programs"
replace DistCharter = "No" if DistCharter == "Not a charter district"

replace DistCharter = "Yes" if DistType == "Charter agency"
replace DistCharter = "No" if DistType == "Regular local school district"


replace State_leaid = subinstr(State_leaid, "CA-", "", .)

replace DistType = "Regular local school district" if DistType == "Regular public school district that is not a component of a supervisory union"
replace DistType = "Charter agency" if DistType == "Independent charter district"

replace DistType = "Regular local school district" if DistType == "Regular public school district that is not a component of a supervisory union"
replace DistType = "Charter agency" if DistType == "Independent charter district"
// replace DistType = "Supervisory union" if DistType == "Local school district that is a component of a supervisory union"
replace DistType = "Regional education service agency" if DistType == "Service agency"
replace DistType = "State-operated agency" if DistType == "State agency"
// replace DistType = "Other education agency" if DistType == "Specialized public school district"



order State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName

// NEW ADDED

save 1_CA_Unmerged_Districts_`a'_With_NCES, replace 


use 1_NCES_`prevyear'_District, clear


//decode State, generate(State1)
//decode DistrictType, generate(DistrictType1)


//drop State DistrictType 
//rename State1 State
// rename DistrictType1 DistrictType

append using 1_CA_Unmerged_Districts_`a'_With_NCES
save 1_NCES_`prevyear'_District_With_Extra_Districts, replace

}





// Prior to 2018 

global time1 2010 2011 2012 2013 2014 2015 2016 2017

foreach a in $time1 {

local prevyear = `a' - 1 

use 1_NCES_`prevyear'_District, clear


//decode State, generate(State1)
//decode DistrictType, generate(DistrictType1)


//drop State DistrictType 
//rename State1 State
//rename DistrictType1 DistrictType

append using 1_CA_Unmerged_Districts_2018_With_NCES

save 1_NCES_`prevyear'_District_With_Extra_Districts, replace

}





//import excel using "CA_Unmerged_Districts_2016_v2.xlsx", firstrow case(preserve) clear

// Second Round of Unmerged Districts

global time4 2010 2011 2012 2013 2015 2016 2017 

foreach a in $time4 {

local prevyear = `a' - 1

import excel using "CA_Unmerged_Districts_`a'_v2.xlsx", firstrow case(preserve) clear


gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 
gen CountyName = ""
gen CountyCode = . 


drop DistName 
rename DistName1 DistName

// NEW ADDED
rename Charter DistCharter
rename DistrictType DistType
// NEW ADDED

// NEW ADDED
replace DistCharter = "Yes" if DistCharter == "LEA for federal programs"
replace DistCharter = "No" if DistCharter == "Not a charter district"

replace DistCharter = "Yes" if DistType == "Charter agency"
replace DistCharter = "No" if DistType == "Regular local school district"


replace State_leaid = subinstr(State_leaid, "CA-", "", .)

replace DistType = "Regular local school district" if DistType == "Regular public school district that is not a component of a supervisory union"
replace DistType = "Charter agency" if DistType == "Independent charter district"

replace DistType = "Regular local school district" if DistType == "Regular public school district that is not a component of a supervisory union"
replace DistType = "Charter agency" if DistType == "Independent charter district"
// replace DistType = "Supervisory union" if DistType == "Local school district that is a component of a supervisory union"
replace DistType = "Regional education service agency" if DistType == "Service agency"
replace DistType = "State-operated agency" if DistType == "State agency"
// replace DistType = "Other education agency" if DistType == "Specialized public school district"



order State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName
keep State StateAbbrev StateFips DistType NCESDistrictID State_leaid DistCharter CountyName CountyCode DistName

// NEW ADDED

replace NCESDistrictID = "00" if NCESDistrictID == "missing"




save 1_CA_Unmerged_Districts_`a'_With_NCES, replace 

use 1_NCES_`prevyear'_District_With_Extra_Districts, clear



append using 1_CA_Unmerged_Districts_`a'_With_NCES



save 1_NCES_`prevyear'_District_With_Extra_Districts_2, replace

}




use 1_NCES_2012_District_With_Extra_Districts_2, clear
replace DistName = ustrtitle(DistName)
save 1_NCES_2012_District_With_Extra_Districts_2, replace

use 1_NCES_2011_District_With_Extra_Districts_2, clear
replace DistName = ustrtitle(DistName)
save 1_NCES_2011_District_With_Extra_Districts_2, replace

use 1_NCES_2010_District_With_Extra_Districts_2, clear
replace DistName = ustrtitle(DistName)
save 1_NCES_2010_District_With_Extra_Districts_2, replace

use 1_NCES_2009_District_With_Extra_Districts_2, clear
replace DistName = ustrtitle(DistName)
save 1_NCES_2009_District_With_Extra_Districts_2, replace


use 1_NCES_2012_District_With_Extra_Districts_2, clear

