clear
set more off

cd "/Users/minnamgung/Desktop/SADR"

global EDFacts "/Users/minnamgung/Desktop/SADR/EdFacts"

import delimited "${EDFacts}/EdFacts_2022_KY.csv", clear


// Generate DataLevel
gen DataLevel="School"
replace DataLevel="District" if missing(school)
replace DataLevel="State" if missing(school) & missing(lea)

sort DataLevel

// Put subgroups together
replace subgroup=characteristics if missing(subgroup)
drop characteristics 

rename subgroup StudentSubGroup

// Subject
rename academicsubject Subject
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

// Grade
rename agegrade GradeLevel
drop if inlist(GradeLevel, "High School", "All Grades")
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0", .)

// Subgroup cleaning
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students in SEA" | StudentSubGroup == "All Students in LEA" | StudentSubGroup == "All Students in School"
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native/Native American"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic) African American"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multicultural/Multiethnic/Multiracial/other"
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

// Distinguishing participation/percentage proficient

rename ncesschid NCESSchoolID
rename ncesleaid NCESDistrictID
	
replace datadescription = "Participation" if strpos(datadescription, "Participation") > 0
	replace datadescription = "Performance" if strpos(datadescription, "Performance") > 0
	rename denominator Count
	drop numerator outcome datagroup programtype
	reshape wide value Count, i(state NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup) j(datadescription) str
	drop CountParticipation
	rename valueParticipation Participation
	rename valuePerformance PctProf

	local vars "Participation PctProf"
	foreach var of local vars{
		replace `var' = subinstr(`var', "%", "", .)
		gen Above = 0
		replace Above = 1 if strpos(`var', ">=") > 0 | strpos(`var', ">") > 0
		replace `var' = subinstr(`var', ">=", "", .) if Above == 1
		replace `var' = subinstr(`var', ">", "", .) if Above == 1
		gen Below = 0
		replace Below = 1 if strpos(`var', "<=") > 0 | strpos(`var', "<") > 0
		replace `var' = subinstr(`var', "<=", "", .) if Below == 1
		replace `var' = subinstr(`var', "<", "", .) if Below == 1
		split `var', parse("-")
		replace `var'1 = "-1" if `var' == "S"
		destring `var'1, replace
		replace `var'1 = `var'1/100
		replace `var'1 = . if `var'1 < 0
		tostring `var'1, replace format("%9.2g") force
		if DataLevel == "school"{
			destring `var'2, replace
			replace `var'2 = `var'2/100
			replace `var'2 = . if `var'2 < 0
			tostring `var'2, replace format("%9.2g") force
			replace `var' = `var'1 + "-" + `var'2 if `var'2 != "."
			drop `var'2
		}
		replace `var' = `var'1
		replace `var' = "*" if `var'1 == "."
		replace `var' = `var'1 + "-1" if Above == 1
		replace `var' = "0-" + `var'1 if Below == 1
		drop Above Below `var'1
	}

// Finalizing variables
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
rename CountPerformance Count

save "${EDFacts}/edfacts2022_KY.dta", replace
