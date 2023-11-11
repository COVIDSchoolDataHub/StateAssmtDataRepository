clear
set more off
cd "/Volumes/T7/State Test Project/Hawaii"
local cleaned "/Volumes/T7/State Test Project/Hawaii/Cleaned Data"
local NCES "/Volumes/T7/State Test Project/NCES/District"
local Original "/Volumes/T7/State Test Project/Hawaii/Original Data"
local dofiles Hawaii2013_2014.do hawaii2015-2019_2021-2022.do HI_2023.do
foreach file of local dofiles {
	do `file'
}
set trace off
foreach year in 2015 2016 2017 2018 2019 2021 2022 {
local prevyear =`=`year'-1'
	use "`cleaned'/HI_AssmtData_`year'.dta"
	drop if DataLevel ==2
	tempfile temp1
	save "`temp1'", replace
	keep if DataLevel ==1
	replace DataLevel = 2
	replace NCESDistrictID = "1500030"
	replace DistName = "Hawaii Department of Education"
	replace StateAssignedDistID = "HI-001"
tempfile temp2
save "`temp2'", replace
clear
use "`NCES'/NCES_`prevyear'_District.dta"
keep if state_fips == 15
decode state_name, gen(State)
rename state_fips StateFips
rename state_leaid State_leaid
decode district_agency_type, gen(DistType)
rename county_code CountyCode
rename county_name CountyName
rename state_location StateAbbrev
rename ncesdistrictid NCESDistrictID
merge 1:m NCESDistrictID using "`temp2'"
append using "`temp1'"
replace State_leaid = "HI-001"
replace Flag_CutScoreChange_read = ""
tempfile temp4
save "`temp4'", replace
clear
//Adding and cleaning strive science data for 2015, 2016, 2017, 2018, 2019, 2021, 2022
	import excel "`Original'/HI_`year'_Strive.xls", firstrow case(preserve)
	if `year' == 2015 | `year' == 2016 {
		keep MathProficiency ReadingProficiency ScienceProficiency SchoolID SchoolType~I
		rename ScienceProficiency ProficientOrAbove_percentsci
		rename MathProficiency ProficientOrAbove_percentmath
		rename ReadingProficiency ProficientOrAbove_percentela
		rename SchoolID StateAssignedSchID
		rename SchoolType~I Level
	

}

	if `year' == 2017 {
		keep MathProficiency ReadingProficiency ScienceProficiency SchoolID SchoolType~I SubgroupDescription
		rename ScienceProficiency ProficientOrAbove_percentsci
		rename MathProficiency ProficientOrAbove_percentmath
		rename ReadingProficiency ProficientOrAbove_percentela
		rename SchoolID StateAssignedSchID
		rename SchoolType~I Level
	
		rename SubgroupDescription StudentSubGroup
	}
	if `year' == 2018 {
		keep MathProficiency LA_Proficiency SchCode SchType SciProficiency SubDesc
		rename SchCode StateAssignedSchID
		rename SciProficiency ProficientOrAbove_percentsci
		rename MathProficiency ProficientOrAbove_percentmath
		rename LA_Proficiency ProficientOrAbove_percentela
		rename SchType Level
		rename SubDesc StudentSubGroup
	
}
	if `year' == 2019 {
		keep SchoolID ReadingProficiency MathProficiency SchoolType~I SubgroupDescription ScienceProficiency 
		rename SchoolID StateAssignedSchID
		rename SchoolType~I Level
		rename SubgroupDescription StudentSubGroup
		rename ScienceProficiency ProficientOrAbove_percentsci
		rename ReadingProficiency ProficientOrAbove_percentela
		rename MathProficiency ProficientOrAbove_percentmath
	
		
}
	if `year' == 2021 {
		keep MathProficiency LA_Proficiency SchCode SchType SubDesc SciProficiency MathPart ReadingPart SciencePart 
		rename SchCode StateAssignedSchID
		rename SchType Level
		rename SubDesc StudentSubGroup 
		rename SciProficiency ProficientOrAbove_percentsci
		rename MathProficiency ProficientOrAbove_percentmath
		rename LA_Proficiency ProficientOrAbove_percentela
		rename MathPart ParticipationRatemath
		rename ReadingPart ParticipationRateela
		rename SciencePart ParticipationRatesci
	
	}

	if `year' == 2022 {
	keep MathProficiency LAProficiency ScienceProficiency SchoolID SchoolType SubgroupDescription MathParticipation LAParticipation ScienceParticipation
	rename MathProficiency ProficientOrAbove_percentmath
	rename LAProficiency ProficientOrAbove_percentela
	rename ScienceProficiency ProficientOrAbove_percentsci 
	rename SchoolID StateAssignedSchID
	rename SchoolType Level
	rename SubgroupDescription StudentSubGroup
	rename MathParticipation ParticipationRatemath
	rename LAParticipation ParticipationRateela
	rename ScienceParticipation ParticipationRatesci
}

	

	
	
	
//Dropping High School Data and empty data
drop if missing(StateAssignedSchID)
keep if Level != "High"
tab Level, missing
drop Level



//Generating Variables
gen GradeLevel = "G38"



//StudentSubGroup for 2018, 2019, 2021
if `year' <2017 {
	gen StudentSubGroup = "All Students"
}
else {
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "Disadvantaged") !=0
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Hispanic") !=0
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "English") !=0
replace StudentSubGroup = "Native Hawaiian" if strpos(StudentSubGroup, "Hawaiian") !=0 
replace StudentSubGroup = "Pacific Islander" if strpos(StudentSubGroup, "Pacific") !=0
replace StudentSubGroup = "Filipino" if strpos(StudentSubGroup, "Filipino") !=0
}
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian" | StudentSubGroup == "Pacific Islander" | StudentSubGroup == "Filipino"

//Student Group
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Native Hawaiian" | StudentSubGroup == "Pacific Islander" | StudentSub == "Filipino"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
di upper("`year'")
//reshaping
if `year' == 2021 | `year' == 2022 {
reshape long ParticipationRate ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject, string)
}
else {
reshape long ProficientOrAbove_percent, i(StateAssignedSchID StudentSubGroup) j(Subject, string)
}

//ParticipationRate for 2021 and 2022
if `year' == 2021 | `year' == 2022{
destring ParticipationRate, gen(Part) i(*-)
replace Part = Part/100
replace ParticipationRate = string(Part, "%9.2f")
drop Part
}

//ProficientOrAbove_percent
destring ProficientOrAbove_percent, gen(Proficient) i(*-)
replace Proficient = Proficient/100
replace ProficientOrAbove_percent = string(Proficient, "%9.2f")
drop Proficient

//Missing Variables
gen ProficientOrAbove_count = "--"
gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"
if `year' <2021 {
	gen ParticipationRate = "--"
}



//Merging with cleaned data
tempfile tempsci
save "`tempsci'", replace
clear
use "`temp4'"
duplicates drop StateAssignedSchID, force
keep if DataLevel == 3
drop Subject GradeLevel StudentGroup StudentSubGroup ProficientOrAbove_percent StudentGroup_TotalTested StudentSubGroup_TotalTested ProficientOrAbove_count ParticipationRate
merge 1:m StateAssignedSchID using "`tempsci'", nogen
save "`tempsci'", replace
clear
use "`temp4'"
append using "`tempsci'"

//Fixing AssmtName and flags for sci
replace AssmtName = "Hawaii State Assessment - HCPS III" if Subject == "sci" & `year' <2021
replace AssmtName = "Hawaii State Assessment - NGSS" if Subject == "sci" & `year' >=2021
replace Flag_CutScoreChange_oth = "Y" if `year'==2021
replace Flag_AssmtNameChange = "Y" if `year' == 2021 & Subject == "sci"

//Final cleaning
drop if missing(SchName) // No data for certain schools
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "." | missing(ProficientOrAbove_percent)
replace ParticipationRate = "--" if ParticipationRate == "."
drop if missing(DataLevel)
drop if missing(GradeLevel)
replace State_leaid = "" if DataLevel ==1
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`cleaned'/HI_AssmtData_`year'.dta", replace
export delimited "`cleaned'/HI_AssmtData_`year'.csv", replace
clear
}

