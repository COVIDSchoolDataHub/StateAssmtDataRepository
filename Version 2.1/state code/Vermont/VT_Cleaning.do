clear
set more off
set trace off

global Original "/Users/miramehta/Documents/Vermont/Original Data" 
global Output "/Users/miramehta/Documents/Vermont/Output" 
global NCES_District "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES_School "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"

cd "/Users/miramehta/Documents/Vermont" 


//Converting to .dta format (unhide on first run)
/*
forvalues year = 2016/2023 {
	if `year' == 2020 continue
	foreach assessment in Smarter_Balance Science {
		if (`year' == 2016 | `year' == 2017 | `year' == 2018) & ("`assessment'" == "Science") continue
		if (`year' == 2023) & ("`assessment'" == "Smarter_Balance") continue
		import delimited "${Original}/VT_`assessment'_Assessment_`year'.csv", case(preserve)
		save "${Original}/VT_`assessment'_Assessment_`year'", replace
		clear
	}
}

foreach year in 2016 2017 2018 2019 2021 2022 {
	use "${Original}/VT_Smarter_Balance_Assessment_`year'"
	if (`year' == 2019 | `year' == 2021 | `year' == 2022) append using "${Original}/VT_Science_Assessment_`year'"
	duplicates drop
	save "${Original}/VT_OriginalData_`year'", replace
	clear
}
//2023
clear
import delimited "${Original}/VT_CAP_ELA_Math_Assessment_2023", case(preserve)
duplicates drop
save "${Original}/VT_CAP_ELA_Math_Assessment_2023", replace
clear
import delimited "${Original}/VT_Science_Assessment_2023", case(preserve)
save "${Original}/VT_Science_Assessment_2023", replace
use "${Original}/VT_CAP_ELA_Math_Assessment_2023"
append using "${Original}/VT_Science_Assessment_2023"
save "${Original}/VT_OriginalData_2023", replace
clear

//2024
clear
import delimited "${Original}/VT_OriginalData_2024_ela_mat", case(preserve)
save "${Original}/VT_OriginalData_2024", replace
clear
import delimited "${Original}/VT_OriginalData_2024_sci", case(preserve)
save "${Original}/VT_Science_Assessment_2024", replace
use "${Original}/VT_OriginalData_2024"
append using "${Original}/VT_Science_Assessment_2024"
save "${Original}/VT_OriginalData_2024", replace
clear
*/

forvalues year = 2016/2024 {
	if `year' == 2020 continue
	local prevyear =`=`year'-1'
use "${Original}/VT_OriginalData_`year'", clear

//Standardizing 2022
if `year' == 2022 rename OrganizaitonName OrganizationName
if `year' == 2022 rename OrganizationIdentifier OrganizationIdentifer // They literally mispelled Identifier each year except 2022, where they instead misspelled Organization......
if `year' == 2022 rename Indicator_Label IndicatorLabel
if `year' == 2022 replace IndicatorLabel = "Proficient With Distinction" if IndicatorLabel == "Proficient with Distinction"

//Standardizing 2023
if `year' >= 2023 {
	rename SchoolIdentifer OrganizationIdentifer
	replace IndicatorLabel = "Proficient With Distinction" if IndicatorLabel == "Proficient with Distinction"
	
}


//Reshaping from long to wide
label def IndicatorLabel 1 "Average Scaled Score" 2 "Number of Students Tested" 3 "Partially Proficient" 4 "Proficiency Cut Score" 5 "Proficient" 6 "Proficient With Distinction" 7 "Substantially Below Proficient" 8 "Total Below Proficient" 9 "Total Proficient and Above"
encode IndicatorLabel, gen(n_IndicatorLabel) label(IndicatorLabel)
drop IndicatorLabel
rename n_IndicatorLabel IndicatorLabel
reshape wide SchoolValue SupervisoryUnionValue StateValue, i(OrganizationIdentifer TestName AssessLabel) j(IndicatorLabel)

//Cleaning Grade and Subject
gen GradeLevel = "G" + substr(TestName, -2,2)
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")
gen Subject = substr(TestName, 1, strpos(TestName, "Grade")-2)
replace Subject = "ela" if strpos(Subject, "English") !=0
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "sci" if strpos(Subject, "Science") !=0
drop TestName

//DataLevel
gen DataLevel = ""
replace DataLevel = "School" if (substr(OrganizationIdentifer, 1, 2) == "PS" | substr(OrganizationIdentifer, 1, 2) == "PI")
replace DataLevel = "District" if (substr(OrganizationIdentifer, 1, 2) == "SU")
replace DataLevel = "State" if (substr(OrganizationIdentifer, 1, 2) == "VT")
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel
gen DistName = ""
replace DistName = OrganizationName if DataLevel == 2
gen SchName = ""
replace SchName = OrganizationName if DataLevel == 3
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel ==1
drop OrganizationName
gen StateAssignedDistID = OrganizationIdentifer if DataLevel == 2
gen StateAssignedSchID = OrganizationIdentifer if DataLevel == 3
drop OrganizationIdentifer
cap foreach var of varlist SchoolValue* Supervisory* State* {
	gen `var'_s = string(`var', "%10.6g")
	drop `var'
	rename `var'_s `var'
}


//Avg Scale Score
gen AvgScaleScore = ""
replace AvgScaleScore = SchoolValue1 if DataLevel == 3
replace AvgScaleScore = SupervisoryUnionValue1 if DataLevel == 2
replace AvgScaleScore = StateValue1 if DataLevel == 1

//StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = ""
replace StudentSubGroup_TotalTested = SchoolValue2 if DataLevel == 3
replace StudentSubGroup_TotalTested = SupervisoryUnionValue2 if DataLevel ==2
replace StudentSubGroup_TotalTested = StateValue2 if DataLevel == 1

//Lev2_percent
gen Lev2_percent = ""
replace Lev2_percent = SchoolValue3 if DataLevel == 3
replace Lev2_percent = SupervisoryUnionValue3 if DataLevel == 2
replace Lev2_percent = StateValue3 if DataLevel == 1

//CutScore
gen CutScore = ""
replace CutScore = SchoolValue4 if DataLevel ==3 
replace CutScore = SupervisoryUnionValue4 if DataLevel ==2
replace CutScore = StateValue4 if DataLevel ==1

//Lev3_percent
gen Lev3_percent = ""
replace Lev3_percent = SchoolValue5 if DataLevel == 3
replace Lev3_percent = SupervisoryUnionValue5 if DataLevel == 2
replace Lev3_percent = StateValue5 if DataLevel == 1

//Lev4_percent
gen Lev4_percent = ""
replace Lev4_percent = SchoolValue6 if DataLevel == 3
replace Lev4_percent = SupervisoryUnionValue6 if DataLevel == 2
replace Lev4_percent = StateValue6 if DataLevel == 1

//Lev1_percent
gen Lev1_percent = ""
replace Lev1_percent = SchoolValue7 if DataLevel == 3
replace Lev1_percent = SupervisoryUnionValue7 if DataLevel == 2
replace Lev1_percent = StateValue7 if DataLevel == 1

//ProficientOrAbove_percent
gen ProficientOrAbove_percent = ""
replace ProficientOrAbove_percent = SchoolValue9 if DataLevel == 3
replace ProficientOrAbove_percent = SupervisoryUnionValue9 if DataLevel == 2
replace ProficientOrAbove_percent = StateValue9 if DataLevel == 1

//StudentSubGroup
rename AssessLabel StudentSubGroup
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Indian") !=0
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not ELL"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "FRL"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not FRL"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Ed"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No Special Ed" | StudentSubGroup == "Not Special ED"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not Military" //2023 only
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster" //2023 only
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not Foster" //2023 only
replace StudentSubGroup = "Homeless" if StudentSubGroup == "McKinney Vento Eligible"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not McKinney Vento Eligible"
drop if StudentSubGroup == "Historically Marginalized" | StudentSubGroup == "Not Historically Marginalized"


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"
*save "/Volumes/T7/State Test Project/Vermont/Testing/`year'", replace

//StudentGroup_TotalTested
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
sort StudentGroup
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "0"


//Dropping Extra Variables
keep DataLevel StudentSubGroup GradeLevel Subject DistName SchName StateAssignedDistID StateAssignedSchID AvgScaleScore Lev1_percent Lev2_percent Lev3_percent Lev4_percent StudentSubGroup_TotalTested ProficientOrAbove_percent StudentGroup StudentGroup_TotalTested

//Merging with NCES
tempfile temp1
save "`temp1'"

//District Level
keep if DataLevel == 2
gen state_leaid = StateAssignedDistID
if `year' > 2016 replace state_leaid = "VT-" + state_leaid
tempfile tempdist
save "`tempdist'", replace
clear
if `year' != 2024 use "${NCES_District}/NCES_`prevyear'_District.dta"
if `year' == 2024 use "${NCES_District}/NCES_2022_District.dta"
keep if state_name == "Vermont"
keep ncesdistrictid state_leaid district_agency_type DistCharter DistLocale county_code county_name lea_name
merge 1:m state_leaid using "`tempdist'", keep(match using) nogen
save "`tempdist'", replace
clear

//School Level
use "`temp1'"
keep if DataLevel == 3
gen seasch = StateAssignedSchID
tempfile tempschool
save "`tempschool'", replace
clear
if `year' != 2024 use "${NCES_School}/NCES_`prevyear'_School.dta"
if `year' == 2024 use "${NCES_School}/NCES_2022_School.dta"
keep if state_name == "Vermont"
if `year' > 2016 replace seasch = substr(seasch, strpos(seasch,"-")+1, 10)
if `year' < 2023 keep ncesdistrictid state_leaid district_agency_type DistCharter DistLocale county_code county_name ncesschoolid seasch SchVirtual SchLevel SchType lea_name
if `year' >= 2023 {
	keep ncesdistrictid state_leaid district_agency_type DistCharter DistLocale county_code county_name ncesschoolid seasch SchVirtual SchLevel school_type lea_name
	foreach var of varlist SchVirtual district_agency_type SchLevel school_type {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
	}
} 
merge 1:m seasch using "`tempschool'", keep(match using) nogen

save "`tempschool'", replace
clear

//Appending
use "`temp1'"
keep if DataLevel == 1
append using "`tempdist'" "`tempschool'"

//Fixing NCES Variables
rename district_agency_type DistType
cap rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen StateFips = 50
gen StateAbbrev = "VT"

//DistNames at SchLevel based on NCES
replace DistName = lea_name if DataLevel == 3
replace StateAssignedDistID = State_leaid if DataLevel == 3

//Fixing Missing/Suppressed Data
foreach var of varlist Lev* ProficientOrAbove_percent AvgScaleScore StudentSubGroup_TotalTested {
	replace `var' = "*" if `var' == "."
}
replace AvgScaleScore = "--" if DataLevel == 2 & AvgScaleScore == "*"
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "." | StudentSubGroup_TotalTested == "***"
replace StudentSubGroup_TotalTested = "--" if DataLevel == 2 & StudentSubGroup_TotalTested == "*"
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "--" if DataLevel == 2 & StudentSubGroup_TotalTested == "--"
foreach var of varlist _all {
	cap replace `var' = "*" if strpos(`var',"*") !=0
}


//AssmtName
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "Vermont Science Assessment" if Subject == "sci"
replace AssmtName = "Vermont Comprehensive Assessment Program" if `year' >= 2023

//Missing/empty variables

foreach n in 1 2 3 4 {
	gen Lev`n'_count = "--"
}
gen ProficientOrAbove_count = "--"
gen ParticipationRate = "--"

//Additional Variables
gen State = "Vermont"
replace StateAbbrev = "VT"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
gen Flag_CutScoreChange_soc = "Not applicable"
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_percent = ""
gen Lev5_count = ""
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)
gen AssmtType = "Regular"


//Flags
replace Flag_CutScoreChange_sci = "Y" if `year' == 2019
replace Flag_CutScoreChange_sci = "N" if inlist(`year', 2021, 2022, 2024)
replace Flag_AssmtNameChange = "Y" if `year' == 2023
replace Flag_AssmtNameChange = "Y" if `year' == 2019 & Subject == "sci"
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2023
replace Flag_CutScoreChange_math = "Y" if `year' == 2023
replace Flag_CutScoreChange_sci = "Y" if `year' == 2023
//Aesthetic changes
replace StateAssignedDistID = subinstr(StateAssignedDistID, "VT-","",.)

//Response to R2
drop if StudentSubGroup_TotalTested == "0"
drop if Lev1_percent == "0" & Lev2_percent == "0" & Lev3_percent == "0" & Lev4_percent == "0"


//DATA DECISION: DROPPING DISTRICT LEVEL DATA
drop if DataLevel ==2

//Deriving Counts Where Possible
foreach percent of varlist *_percent {
	local count = subinstr("`percent'","percent","count",.)
	replace `count' = string(round(real(StudentSubGroup_TotalTested) * real(`percent'))) if regexm(StudentSubGroup_TotalTested, "[0-9]") !=0 & regexm(`percent', "[0-9]") !=0
}

// replacing ProficientOrAbove_count with corrected value
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if ProficiencyCriteria == "Levels 3-4" & !missing(real(Lev3_count)) &!missing(real(Lev4_count)) 


foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

gen CleanDistName = substr(DistName, 1, strpos(DistName, "#") - 1) if strpos(DistName, "#") > 0
replace DistName = CleanDistName if strpos(DistName, "#") > 0 
replace DistName = strtrim(DistName)
replace DistName = subinstr(DistName, "USD", "Union School District", 1)

//2024 New School
if `year' == 2024{
replace NCESSchoolID = "500039809276" if SchName == "VERGENNES UNION MIDDLE"
replace SchType = "Regular school" if NCESSchoolID == "500039809276"
replace SchLevel = "Middle" if NCESSchoolID == "500039809276"
replace SchVirtual = "No" if NCESSchoolID == "500039809276"
replace DistName = "Addison Northwest Unified Union School District" if NCESSchoolID == "500039809276"
replace NCESDistrictID = "5000398" if NCESSchoolID == "500039809276"
replace StateAssignedDistID = "U054" if NCESSchoolID == "500039809276"
replace DistType = "Local school district that is a component of a supervisory union" if NCESSchoolID == "500039809276"
replace DistCharter = "No" if NCESSchoolID == "500039809276"
replace DistLocale = "Rural, distant" if NCESSchoolID == "500039809276"
replace CountyName = "Addison County" if NCESSchoolID == "500039809276"
replace CountyCode = "50001" if NCESSchoolID == "500039809276"	
}

//All Students value for StudentGroup
drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1 //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != 3 //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/VT_AssmtData_`year'", replace
export delimited "${Output}/VT_AssmtData_`year'", replace
clear


}
