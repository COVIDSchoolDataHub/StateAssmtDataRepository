clear
set more off

cd "/Users/miramehta/Documents"

global data "/Users/miramehta/Documents/ND State Testing Data/Original Data Files"
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global EDFacts "/Users/miramehta/Documents/EdFacts"

use "$data/ND_EDFacts_2022.dta", clear

rename ncesschid NCESSchoolID
rename ncesleaid NCESDistrictID

gen DataLevel = "School"
replace DataLevel = "District" if school == "" & NCESSchoolID == .
replace DataLevel = "State" if lea == "" & NCESDistrictID == .

rename agegrade GradeLevel
drop if inlist(GradeLevel, "All Grades", "High School")
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

rename numerator Count
rename value Participation
drop denominator datadescription outcome datagroup programtype

replace Participation = subinstr(Participation, "%", "", 1)
replace Participation = "*" if Participation == "S"
replace Participation = subinstr(Participation, ">=", "", 1) + "-100" if strpos(Participation, ">=") != 0
replace Participation = "0-" + subinstr(Participation, "<", "", 1) if strpos(Participation, "<") != 0
split Participation, parse("-")
destring Participation1 Participation2, replace i(*)
replace Participation1 = Participation1/100
replace Participation2 = Participation2/100
tostring Participation1, replace format("%9.2g") force
tostring Participation2, replace format("%9.2g") force
replace Participation = Participation1 + "-" + Participation2 if Participation1 != "." & Participation2 != "."
replace Participation = Participation1 if Participation1 != "." & Participation2 == "."
drop Participation1 Participation2 

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
tostring NCESDistrictID, replace force
replace NCESDistrictID = "" if DataLevel == 1
recast long NCESSchoolID
format NCESSchoolID %18.0g
tostring NCESSchoolID, replace usedisplayformat
replace NCESSchoolID = "" if DataLevel != 3

save "${data}/edfacts2022northdakota.dta", replace
