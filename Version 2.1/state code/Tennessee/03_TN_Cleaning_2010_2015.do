*******************************************************
* TENNESSEE

* File name: 03_TN_Cleaning_2010_2015
* Last update: 2/6/2025

*******************************************************
* Notes

	* This do file cleans TN's yearly data from 2010 through 2015 and merges with NCES.

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear

cd "C:/Zelma/Tennessee"

/////////////////////////////////////////
*** Cleaning ***
/////////////////////////////////////////

//Combining DataLevels
forvalues year = 2010/2015 {
	clear
	save "$Original/TN_OriginalData_`year'", replace emptyok
	foreach dl in state dist sch {
		use "$Original/TN_OriginalData_`year'_`dl'", clear
		cap drop P-Z
		gen DataLevel = "`dl'"
		append using "$Original/TN_OriginalData_`year'"
		save "$Original/TN_OriginalData_`year'", replace
	}
	
//Renaming 
if `year' < 2013 {
rename DistrictName DistName
rename SchoolName SchName
rename DistrictID StateAssignedDistID
rename SchoolID StateAssignedSchID
rename Subject Subject
rename Grade GradeLevel
rename StudentGroup StudentSubGroup
rename NumberEnrolled Enrolled
rename NumberofValidTests StudentSubGroup_TotalTested
rename NumberBelowBasic Lev1_count
rename NumberBasic Lev2_count
rename NumberProficient Lev3_count
rename NumberAdvanced Lev4_count
rename PercentBelowBasic Lev1_percent
rename PercentBasic Lev2_percent
rename PercentProficient Lev3_percent
rename PercentAdvanced Lev4_percent
rename PercentProficientorAdvanced ProficientOrAbove_percent
drop PercentBelowBasicorBasic
}
if `year' > 2012 {
drop year
rename system StateAssignedDistID
rename system_name DistName
rename school StateAssignedSchID
rename school_name SchName
rename subject Subject
rename grade GradeLevel
rename subgroup StudentSubGroup
rename valid_tests StudentSubGroup_TotalTested
rename n_below_bsc Lev1_count
rename n_bsc Lev2_count
rename n_prof Lev3_count
rename n_adv Lev4_count
rename pct_below_bsc Lev1_percent
rename pct_bsc Lev2_percent
rename pct_prof Lev3_percent
rename pct_adv Lev4_percent
drop pct_bsc_and_below
rename pct_prof_adv ProficientOrAbove_percent
}

//Subject
replace Subject = "ela" if Subject == "Reading/Language" | Subject == "RLA"
replace Subject = "math" if Subject == "Math"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"

keep if inlist(Subject, "ela", "math", "sci","soc")

//GradeLevel
replace GradeLevel = "38" if GradeLevel == "All Grades"
drop if missing(real(GradeLevel))
keep if (real(GradeLevel) >= 3 & real(GradeLevel) <= 8) | GradeLevel == "38"
replace GradeLevel = "G" + string(real(GradeLevel), "%02.0f")

//StudentSubGroup
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All") !=0
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learners"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "English Language Learners with T1/T2"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-Students with Disabilities"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged (Free or Reduced Price Lunch)"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Economically Disadvantaged"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
drop if StudentSubGroup == "Black/Hispanic/Native American" | StudentSubGroup == "Non-English Language Learners/T1 or T2"

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited" | StudentSubGroup == "EL and Monit or Recently Ex"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//DataLevel
replace DataLevel = "State" if DataLevel == "state"
replace DataLevel = "District" if DataLevel == "dist"
replace DataLevel = "School" if DataLevel == "sch"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedDistID = . if DataLevel == 1
replace StateAssignedSchID =. if DataLevel !=3

***Calculations***
//Deriving & Formatting Level Count and Percent Information
foreach percent of varlist Lev*_percent {
local count = subinstr("`percent'", "percent", "count",.)
replace `percent' = "--" if missing(`percent')
replace `percent' = "*" if strpos(`percent',"*") !=0
replace `count' = "*" if strpos(`count',"*") !=0
replace `count' = "--" if missing(`count')
replace `percent' = string(real(`percent')/100, "%9.3g") if !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(ProficientOrAbove_percent)/100, "%9.3g") if !missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_percent = "--" if missing(ProficientOrAbove_percent)
replace ProficientOrAbove_percent = "*" if strpos(ProficientOrAbove_percent,"*") !=0

if `year' < 2013 {
	gen ParticipationRate = string(StudentSubGroup_TotalTested/Enrolled, "%9.3g")
	drop Enrolled
}
else {
	gen ParticipationRate = "--"
}

***Merging with NCES***
local prevyear = `year' - 1
gen State_leaid = string(StateAssignedDistID, "%03.0f")
gen seasch = State_leaid + "-" + string(StateAssignedSchID, "%04.0f")

merge m:1 State_leaid using "$NCES_TN/NCES_All_District", gen(DistMerge)
merge m:1 seasch using "$NCES_TN/NCES_All_School", gen(SchMerge)
drop if DistMerge == 2 | SchMerge == 2
drop *Merge sch_lowest_grade_offered State_leaid seasch

replace State = "Tennessee"
replace StateAbbrev = "TN"
replace StateFips = 47

//StudentSubGroup_TotalTested
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

//StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = 000000 if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = 000000 if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1


***Calculations***
//ProficientOrAbove_count
gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

//Indicator & Missing Variables

*Generating empty Level 5 counts and percentages - since TN has only 4 Levels. 
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen AssmtName = "TCAP Achievement Assessments"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
if `year' >= 2013 & `year' != 2015 replace Flag_CutScoreChange_soc = "N"

gen SchYear = string(`year'-1) + "-" + substr("`year'",-2,2)

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
replace CountyName = proper(CountyName)
replace CountyName = "McMinn County" if CountyName == "Mcminn County"
replace CountyName = "McNairy County" if CountyName == "Mcnairy County"

//Self review
replace SchVirtual = "Missing/not reported" if missing(SchVirtual) & DataLevel == 3
replace CountyName = "DeKalb County" if CountyName == "Dekalb County"

//Weird SchName & DistName in 2012
if `year' == 2012 replace DistName = "Memphis" if NCESSchoolID == "470294001164" & DistName == "*"
if `year' == 2012 replace SchName = "Treadwell Elementary" if NCESSchoolID == "470294001164" & SchName == "*"



//Dropping All Suppressed Unmerged
gen AllSuppressed = 0
	foreach var of varlist *_percent {
		replace AllSuppressed = AllSuppressed + 1 if !missing(real(`var'))

	}
drop if AllSuppressed ==0 & missing(NCESSchoolID) & DataLevel == 3

if `year' == 2013 drop if SchName == "Martin Luther King Transition Center" & SchType == "High"

//Response to R1

** Creating unique StateAssignedSchID
tostring StateAssignedSchID, replace
replace StateAssignedSchID = string(StateAssignedDistID) + "-" + StateAssignedSchID if DataLevel == 3
replace StateAssignedSchID = "" if DataLevel !=3

if `year' == 2010 replace SchName = proper("WEST CARROLL PRIMARY") if NCESSchoolID == "470449000149" & missing(SchName)

//Additional Dropping
drop if SchLevel ==  "Prekindergarten"

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data
*Exporting into a separate folder Output for Stanford - without derivations* 
save "${Output_ND}/TN_AssmtData_`year'_NoDev", replace //Do not comment! This file gets used in the 06_TN_StableNames do file.
*export delimited "${Output_ND}/TN_AssmtData_`year'_NoDev", replace //Commented out, suggest using the output generated in Stable_Names_Output_ND.

***Derivations***
//ProficientOrAbove_count
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if missing(real(ProficientOrAbove_count)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested))

*Exporting into the usual output file* 
save "$Output/TN_AssmtData_`year'", replace //Do not comment! This file gets used in the 06_TN_StableNames do file.
*export delimited "$Output/TN_AssmtData_`year'", replace  //Commented out because it's not a final version final.
}
