clear
set more off

cd "/Users/maggie/Desktop/North Dakota"

global data "/Users/maggie/Desktop/North Dakota/Original Data Files"
global NCESSchool "/Users/maggie/Desktop/North Dakota/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/North Dakota/NCES/District"
global NCES "/Users/maggie/Desktop/North Dakota/NCES/Cleaned"
global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

local lev "state district school"
foreach v of local lev{
	import delimited "${EDFacts}/2022/edfacts2022`v'northdakota.csv", clear

	gen DataLevel = strproper("`v'")
	rename ncesschid NCESSchoolID
	rename ncesleaid NCESDistrictID

	rename agegrade GradeLevel
	replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0", .)

	rename academicsubject Subject
	replace Subject = "ela" if Subject == "Reading/Language Arts"
	replace Subject = "math" if Subject == "Mathematics"
	replace Subject = "sci" if Subject == "Science"

	replace subgroup = characteristics if characteristics != ""
	drop population characteristics
	rename subgroup StudentSubGroup

	if DataLevel == "State"{
		drop if StudentSubGroup == "Asian/Pacific Islander"
	}
	replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") > 0
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native/Native American"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic) African American"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
	replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
	replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian (not Hispanic)"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
	replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory students"
	replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
	replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"

	gen StudentGroup = "RaceEth"
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
	replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
	replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
	replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
	replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
	replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
	replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
	replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"

	replace datadescription = "Participation" if strpos(datadescription, "Participation") > 0
	replace datadescription = "Performance" if strpos(datadescription, "Performance") > 0
	rename denominator Count
	drop if numerator == 0
	drop numerator outcome datagroup programtype
	duplicates drop state NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup datadescription, force
	reshape wide value Count, i(state NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup) j(datadescription) str
	drop CountParticipation
	rename CountPerformance StudentSubGroup_TotalTested
	rename valueParticipation Participation
	rename valuePerformance PctProf
	
	local vars "Participation PctProf"
	foreach var of local vars{
		replace `var' = subinstr(`var', "%", "", .)
		replace `var' = "*" if `var' == "S"
		split `var', parse("-")
		destring `var'1, replace force
		replace `var'1 = `var'1/100
		tostring `var'1, replace format("%9.2g") force
		if DataLevel != "State" {
		destring `var'2, replace force
		replace `var'2 = `var'2/100			
		tostring `var'2, replace format("%9.2g") force
		replace `var' = `var'1 + "-" + `var'2 if `var'1 != "." & `var'2 != "."
		replace `var' = `var'1 if `var'1 != "." & `var'2 == "."
		drop `var'2
		}
		gen inequality = 1 if strpos(`var', ">") > 0
		replace inequality = -1 if strpos(`var', "<") > 0
		gen `var'3 = subinstr(`var', ">", "", .) if strpos(`var', ">") > 0
		replace `var'3 = subinstr(`var', ">=", "", .) if strpos(`var', ">=") > 0
		replace `var'3 = subinstr(`var', "<", "", .) if strpos(`var', "<") > 0
		replace `var'3 = subinstr(`var', "<=", "", .) if strpos(`var', "<=") > 0
		destring `var'3, replace force
		replace `var'3 = `var'3/100
		tostring `var'3, replace format("%9.2g") force
		replace `var' = `var'3 + "-1" if inequality == 1 & `var'3 != "."
		replace `var' = "0-" + `var'3 if inequality == -1 & `var'3 != "."
		if DataLevel == "State" {
			replace `var' = `var'1 if `var'1 != "." & `var'3 == "."
		}
		drop `var'1 `var'3 inequality
		}
	
	if DataLevel == "State"{
		tostring lea, replace
	}
	
	if DataLevel != "School"{
		tostring school, replace
	}
	
	save "${EDFacts}/2022/edfacts2022`v'northdakota.dta", replace
}

use "${EDFacts}/2022/edfacts2022statenorthdakota.dta", clear
append using "${EDFacts}/2022/edfacts2022districtnorthdakota.dta" "${EDFacts}/2022/edfacts2022schoolnorthdakota.dta"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
save "${EDFacts}/2022/edfacts2022northdakota.dta", replace
