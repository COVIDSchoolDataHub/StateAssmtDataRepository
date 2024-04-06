clear all
set more off

cd "/Volumes/T7/State Test Project/Nebraska"
global data "/Volumes/T7/State Test Project/Nebraska/Original Data Files"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global counts "/Volumes/T7/State Test Project/EDFACTS"

forvalues year = 2016/2017 {
	
use "$counts/edfactscount`year'mathschool.dta", clear
drop if STNAM != "NEBRASKA"

rename NCESSCH NCESSchoolID
rename LEAID NCESDistrictID
rename SCHNAM SchName
rename LEANM DistName

drop if GRADE == "HS"
replace GRADE = "G" + GRADE
replace GRADE = "G38" if GRADE == "G00"
rename GRADE GradeLevel

rename SUBJECT Subject
replace Subject = "math"

gen DataLevel = "School"

replace CATEGORY = "All Students" if CATEGORY == "ALL"
replace CATEGORY = "American Indian or Alaska Native" if CATEGORY == "MAM"
replace CATEGORY = "Asian" if CATEGORY == "MAS"
replace CATEGORY = "Black or African American" if CATEGORY == "MBL"
replace CATEGORY = "Hispanic or Latino" if CATEGORY == "MHI"
replace CATEGORY = "White" if CATEGORY == "MWH"
replace CATEGORY = "Two or More" if CATEGORY == "MTR"
replace CATEGORY = "Economically Disadvantaged" if CATEGORY == "ECD"
replace CATEGORY = "Female" if CATEGORY == "F"
replace CATEGORY = "Male" if CATEGORY == "M"
replace CATEGORY = "English Learner" if CATEGORY == "LEP"
replace CATEGORY = "Migrant" if CATEGORY == "MIG"
replace CATEGORY = "SWD" if CATEGORY == "CWD"
replace CATEGORY = "Homeless" if CATEGORY == "HOM"
rename CATEGORY StudentSubGroup
save "$counts/NE_edfactscount`year'.dta", replace

use "$counts/edfactscount`year'mathdistrict.dta", clear
drop if STNAM != "NEBRASKA"

rename LEAID NCESDistrictID
rename LEANM DistName
gen SchName = "All Schools"
gen NCESSchoolID = ""

drop if GRADE == "HS"
replace GRADE = "G" + GRADE
replace GRADE = "G38" if GRADE == "G00"
rename GRADE GradeLevel

rename SUBJECT Subject
replace Subject = "math"

gen DataLevel = "District"

replace CATEGORY = "All Students" if CATEGORY == "ALL"
replace CATEGORY = "American Indian or Alaska Native" if CATEGORY == "MAM"
replace CATEGORY = "Asian" if CATEGORY == "MAS"
replace CATEGORY = "Black or African American" if CATEGORY == "MBL"
replace CATEGORY = "Hispanic or Latino" if CATEGORY == "MHI"
replace CATEGORY = "White" if CATEGORY == "MWH"
replace CATEGORY = "Two or More" if CATEGORY == "MTR"
replace CATEGORY = "Economically Disadvantaged" if CATEGORY == "ECD"
replace CATEGORY = "Female" if CATEGORY == "F"
replace CATEGORY = "Male" if CATEGORY == "M"
replace CATEGORY = "English Learner" if CATEGORY == "LEP"
rename CATEGORY StudentSubGroup
save "$counts/NE_edfactscount`year'mathdistrict.dta", replace

use "$counts/edfactscount`year'elaschool.dta", clear
drop if STNAM != "NEBRASKA"

rename NCESSCH NCESSchoolID
rename LEAID NCESDistrictID
rename SCHNAM SchName
rename LEANM DistName

drop if GRADE == "HS"
replace GRADE = "G" + GRADE
replace GRADE = "G38" if GRADE == "G00"
rename GRADE GradeLevel

rename SUBJECT Subject
replace Subject = "ela"

gen DataLevel = "School"

replace CATEGORY = "All Students" if CATEGORY == "ALL"
replace CATEGORY = "American Indian or Alaska Native" if CATEGORY == "MAM"
replace CATEGORY = "Asian" if CATEGORY == "MAS"
replace CATEGORY = "Black or African American" if CATEGORY == "MBL"
replace CATEGORY = "Hispanic or Latino" if CATEGORY == "MHI"
replace CATEGORY = "White" if CATEGORY == "MWH"
replace CATEGORY = "Two or More" if CATEGORY == "MTR"
replace CATEGORY = "Economically Disadvantaged" if CATEGORY == "ECD"
replace CATEGORY = "Female" if CATEGORY == "F"
replace CATEGORY = "Male" if CATEGORY == "M"
replace CATEGORY = "English Learner" if CATEGORY == "LEP"
rename CATEGORY StudentSubGroup
save "$counts/NE_edfactscount`year'elaschool.dta", replace

use "$counts/edfactscount`year'eladistrict.dta", clear
drop if STNAM != "NEBRASKA"

rename LEAID NCESDistrictID
rename LEANM DistName
gen SchName = "All Schools"
gen NCESSchoolID = ""

drop if GRADE == "HS"
replace GRADE = "G" + GRADE
replace GRADE = "G38" if GRADE == "G00"
rename GRADE GradeLevel

rename SUBJECT Subject
replace Subject = "ela"

gen DataLevel = "District"

replace CATEGORY = "All Students" if CATEGORY == "ALL"
replace CATEGORY = "American Indian or Alaska Native" if CATEGORY == "MAM"
replace CATEGORY = "Asian" if CATEGORY == "MAS"
replace CATEGORY = "Black or African American" if CATEGORY == "MBL"
replace CATEGORY = "Hispanic or Latino" if CATEGORY == "MHI"
replace CATEGORY = "White" if CATEGORY == "MWH"
replace CATEGORY = "Two or More" if CATEGORY == "MTR"
replace CATEGORY = "Economically Disadvantaged" if CATEGORY == "ECD"
replace CATEGORY = "Female" if CATEGORY == "F"
replace CATEGORY = "Male" if CATEGORY == "M"
replace CATEGORY = "English Learner" if CATEGORY == "LEP"
rename CATEGORY StudentSubGroup
save "$counts/NE_edfactscount`year'eladistrict.dta", replace

use "$counts/NE_edfactscount`year'.dta", clear
append using "$counts/NE_edfactscount`year'mathdistrict.dta" "$counts/NE_edfactscount`year'elaschool.dta" "$counts/NE_edfactscount`year'eladistrict.dta"
save "$counts/NE_edfactscount`year'.dta", replace
}
