clear
set more off
cd "/Volumes/T7/State Test Project/Nebraska"
global data "/Volumes/T7/State Test Project/Nebraska/Original Data Files/NE Counts, 2016 and 2017"
global counts "/Volumes/T7/State Test Project/Nebraska/Counts_2016_2017"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global output "/Volumes/T7/State Test Project/Nebraska/Output"

//Importing
foreach year in 2016 2017 {
	local prevyear `=`year'-1'
tempfile temp1
save "`temp1'", emptyok replace
clear	
	foreach subject in ELA Math Science {
		if `year' == 2017 & "`subject'" == "Reading" continue
		import delimited "$data/NeSA_`subject'_Detail_`prevyear'`year'", case(preserve) stringcols(_all)
		append using "`temp1'"
		save "`temp1'", replace
		clear
	}
use "`temp1'"	
save "$data/NE_Count_`year'", replace
clear
}

//Cleaning
foreach year in 2016 2017 {
	use "$data/NE_Count_`year'"

//Only need count information
duplicates drop Type AgencyName Subject Grade_Code AYPGroup, force
	
//Renaming
rename Type DataLevel
rename DataYears SchYear
rename Grade_Code GradeLevel
rename AYPGroup StudentSubGroup
rename Category StudentGroup
rename StudentCount StudentSubGroup_TotalTested

//seasch & State_leaid
gen State_leaid = County + District + "000"
gen seasch = County + District + School
replace State_leaid = "" if DataLevel == "ST"
replace seasch = "" if DataLevel != "SC"

//Retaining relevant variables
gen DistName = AgencyName if DataLevel == "DI"
gen SchName = AgencyName if DataLevel == "SC"
drop  County District School AgencyName StandardCode Standard StandardCorrectPercent DataAsOf

//DataLevel
replace DataLevel = "State" if DataLevel == "ST"
replace DataLevel = "District" if DataLevel == "DI"
replace DataLevel = "School" if DataLevel == "SC"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel == 1

//SchYear
drop SchYear

//Subject
replace Subject = "sci" if Subject == "Science"
replace Subject = "ela" if Subject == "Reading" | Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"

//GradeLevel
drop if real(GradeLevel) > 8
replace GradeLevel = "G" + GradeLevel

//StudentSubGroup
drop if StudentGroup == "Mobile"
replace StudentSubGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Students eligible for free and reduced lunch"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Receiving Free or Reduced Lunch"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentSubGroup = "Military" if StudentSubGroup == "Parent in Military"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Students served in migrant programs"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education Students"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not in Special Education"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
drop if StudentSubGroup == "Special Education Students - Alternate Assessment"

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "-1"

//Final Cleaning and Saving
order DataLevel DistName State_leaid SchName seasch
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$counts/NE_Counts_`year'", replace
clear	
}

