clear all
set more off

cd "/Volumes/T7/State Test Project/West Virginia"
global data "/Volumes/T7/State Test Project/West Virginia/Original Data Files"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_clean "/Volumes/T7/State Test Project/West Virginia/NCES_Clean"
global edfacts "/Volumes/T7/State Test Project/EDFACTS"
global counts "/Volumes/T7/State Test Project/West Virginia/Counts"

forvalues year = 2015/2021 {
	if `year' == 2020 {
		continue
	}
	
use "$edfacts/edfactscount`year'mathschool.dta", clear
drop if STNAM != "WEST VIRGINIA"

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
replace CATEGORY = "SWD" if CATEGORY == "CWD"
replace CATEGORY = "Foster Care" if CATEGORY == "FCS"
replace CATEGORY = "Military" if CATEGORY == "MIL"
replace CATEGORY = "Migrant" if CATEGORY == "MIG"
replace CATEGORY = "Homeless" if CATEGORY == "HOM"
rename CATEGORY StudentSubGroup
save "$counts/WV_edfactscount`year'.dta", replace

use "$edfacts/edfactscount`year'mathdistrict.dta", clear
drop if STNAM != "WEST VIRGINIA"

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
replace CATEGORY = "SWD" if CATEGORY == "CWD"
replace CATEGORY = "Foster Care" if CATEGORY == "FCS"
replace CATEGORY = "Military" if CATEGORY == "MIL"
replace CATEGORY = "Migrant" if CATEGORY == "MIG"
rename CATEGORY StudentSubGroup
save "$counts/WV_edfactscount`year'mathdistrict.dta", replace

use "$edfacts/edfactscount`year'elaschool.dta", clear
drop if STNAM != "WEST VIRGINIA"

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
replace CATEGORY = "SWD" if CATEGORY == "CWD"
replace CATEGORY = "Foster Care" if CATEGORY == "FCS"
replace CATEGORY = "Military" if CATEGORY == "MIL"
replace CATEGORY = "Migrant" if CATEGORY == "MIG"
rename CATEGORY StudentSubGroup
save "$counts/WV_edfactscount`year'elaschool.dta", replace

use "$edfacts/edfactscount`year'eladistrict.dta", clear
drop if STNAM != "WEST VIRGINIA"

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
replace CATEGORY = "SWD" if CATEGORY == "CWD"
replace CATEGORY = "Foster Care" if CATEGORY == "FCS"
replace CATEGORY = "Military" if CATEGORY == "MIL"
replace CATEGORY = "Migrant" if CATEGORY == "MIG"
rename CATEGORY StudentSubGroup
save "$counts/WV_edfactscount`year'eladistrict.dta", replace

use "$counts/WV_edfactscount`year'.dta", clear
append using "$counts/WV_edfactscount`year'mathdistrict.dta" "$counts/WV_edfactscount`year'elaschool.dta" "$counts/WV_edfactscount`year'eladistrict.dta"
save "$counts/WV_edfactscount`year'.dta", replace
}
