clear
set more off
set trace off

//Importing (Unhide on first run)



foreach year in 2022 2023 2024 {
	import delimited "$Original/KY_DataRequest_COUNTS_Rec02.12.25_`year'.CSV", case(preserve) clear stringcols(1,5)
	save "$Original/KY_DataRequest_COUNTS_Rec02.12.25_`year'.dta", replace
}

//New 2024 Schools
import excel "KY 2024 New Schools.xlsx", firstrow case(preserve) clear
drop if missing(real(NCESDistrictID))
tostring CountyCode, replace
save "$NCES_KY/KY 2024 New Schools", replace


foreach year in 2022 2023 2024 {
	local prevyear = `year' -1
	
use "$Original/KY_DataRequest_COUNTS_Rec02.12.25_`year'.dta", clear


//Rename and Drop Variables
rename SchoolCode Identifier
rename DistrictName DistName
rename SchoolName SchName
drop SchoolClassification
rename Grade GradeLevel
rename Demographic StudentSubGroup
rename Novice Lev1_count
rename Apprentice Lev2_count
rename Proficient Lev3_count
rename Distinguished Lev4_count
rename ProficientDistinguished ProficientOrAbove_count

//DataLevel, District, School IDs
gen DataLevel = 3 if strlen(Identifier) > 3
replace DataLevel = 2 if strlen(Identifier) == 3
replace DataLevel = 1 if Identifier == "999"

label define DataLevel 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel
sort DataLevel
replace DistName = "All Districts" if DataLevel ==1
replace SchName = "All Schools" if DataLevel !=3

gen StateAssignedDistID = substr(Identifier, 1,3) if DataLevel !=1
gen StateAssignedSchID = StateAssignedDistID + substr(Identifier,4,6) if DataLevel == 3

drop Identifier

//GradeLevel
keep if real(GradeLevel) >= 3 & real(GradeLevel) <= 8
replace GradeLevel = "G" + GradeLevel

//Subject
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "ela" if Subject == "Reading"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"
replace Subject = "wri" if Subject == "On Demand Writing"
drop if Subject == "Editing and Mechanic"

//StudentSubGroup
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
*All Students
drop if StudentSubGroup == "Alternate Assessment"
*American Indian or Alaska Native
*Asian
*Economically Disadvantaged
*English Learner
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "English Learner including Monitored"
*Female
*Foster Care
drop if StudentSubGroup == "Gifted and Talented"
*Hispanic or Latino
*Homeless
*Male
*Migrant
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Dependent"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Economically Disadvantaged"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learner"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "Non-English Learner or monitored"
*Non-Foster Care
drop if StudentSubGroup == "Non-Gifted and Talented"
*Non-Homeless
*Non-Migrant
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Non-Military Dependent"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities (IEP)"
drop if StudentSubGroup == "Students with Disabilities/IEP Regular Assessment" | StudentSubGroup == "Students with Disabilities/IEP with Accommodations"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without IEP"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
replace StudentSubGroup = "White" if StudentSubGroup == "White (Non-Hispanic)"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex" | StudentSubGroup == "Ever EL"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//Suppression
drop if missing(Suppressed)
drop Suppressed

//StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count))
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."

//Level counts and Percents
foreach count of varlist *_count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.6g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested)) //Setting decimal places to 6 arbitrarily ("%9.6g")
	replace `percent' = "*" if missing(`percent')
}	
	
//NCES Merging
gen State_leaid = StateAssignedDistID
gen seasch = StateAssignedSchID if DataLevel == 3

if `year' != 2024 merge m:1 State_leaid using "$NCES_KY/NCES_`prevyear'_District", gen(DistMerge)
if `year' == 2024 merge m:1 State_leaid using "$NCES_KY/NCES_2022_District", gen(DistMerge) //Using NCES 2022 for 2024. Update when NCES 2023 comes out
drop if DistMerge == 2

drop if strpos(DistName, "ED COOP -") //Educational Cooperative, not merging with NCES. After some research, these are organizations designed to help districts. Dropping.

if `year' != 2024 merge m:1 seasch using "$NCES_KY/NCES_`prevyear'_School", gen(SchMerge)
if `year' == 2024 merge m:1 seasch using "$NCES_KY/NCES_2022_School", gen(SchMerge) //Using NCES 2022 for 2024. Update when NCES 2023 comes out
drop if SchMerge == 2

//2024 New Schools
if `year' == 2024 {
	merge m:1 StateAssignedSchID using "$NCES_KY/KY 2024 New Schools", update gen(NewSchMerge)
	drop if NewSchMerge == 2
}

//Schools not in NCES
//Model elementary and high school: Dropping for now as was done for prior files. No NCES data available for any year.
drop if SchName == "Model Elementary" | SchName == "Model High School"


replace State = "Kentucky"
replace StateFips = 21
replace StateAbbrev = "KY"

//Indicator Variables
gen SchYear = "`prevyear'-" + substr("`year'",-2,2)
gen AssmtName = "Kentucky Summative Assessment"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"

//Missing and Empty Variables
gen ParticipationRate = "--"
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

foreach var of varlist Flag* {
	replace `var' = "Y" if `year' == 2022
}

//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/KY_AssmtData_`year'", replace
export delimited "$Output/KY_AssmtData_`year'", replace


}
