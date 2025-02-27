*******************************************************
* RHODE ISLAND
* File name: RI_Cleaning_2018_2024
* Last update: 2/27/2025

*******************************************************
* Notes

	* This do file first cleans RI's 2018 - 2024 data, except 2020. 
	* The non-derivation and usual output are created for all years, except 2020.
	
*******************************************************
///////////////////////////////
// Setup
///////////////////////////////
clear

//Combine Subjects
tempfile temp1
save "`temp1'", replace emptyok
foreach subject in ela math sci {
	use "$Original_DTA/RI_OriginalData_`subject'_2018_2024", clear
	gen Subject = "`subject'"
	if "`subject'" == "sci" {
		rename BeginningtoMeetExpectations Lev1_percent
		rename ApproachingExpectations Lev2_percent 
	}
	if "`subject'" != "sci" {
		rename NotMeetingExpectations Lev1_percent
		rename PartiallyMeetingExpectations Lev2_percent
	}
	append using "`temp1'"
	save "`temp1'", replace
}
use "`temp1'"
save "$Original_DTA/RI_OriginalData_2018_2024", replace

//Drop duplicate obs
duplicates drop

//Rename and drop Vars
drop Growth* AvgGrowthPercentile
rename Year SchYear
rename District DistName
rename School SchName
rename Grade GradeLevel
rename StudentGroup StudentSubGroup
rename StudentTestedNumber StudentSubGroup_TotalTested
rename StudentTestedPercentage ParticipationRate
rename MeetingExpectations Lev3_percent
rename ExceedingExpectations Lev4_percent
rename MeetingorExceedingExpectation ProficientOrAbove_percent

//Merging

merge m:1 SchYear DistName SchName using "$Original_DTA/RI_NCES_CW1", gen(NCESMerge)

**Merge with NCES data from additional Crosswalk
replace SchName = "The R.Y.S.E. School" if SchName == "The R.Y.S.E School"
replace SchName = "Highlander Charter School" if SchName == "Highlander Charter"
replace SchName = "Joseph H. Gaudet Learning Academy" if SchName == "Joseph Gaudet Academy"
replace SchName = "Marieville Elementary School" if SchName == "Marieville School"
replace SchName = "Dr. Harry L. Halliwell Memorial School" if SchName == "Dr. Halliwell School"
replace SchName = "Randall Holden School" if SchName == "Holden School"
replace SchName = "Warwick Veterans Jr. High School" if SchName == "Warwick Veterans Jr. High Sch"
replace SchName = "John Wickes School" if SchName == "Wickes School"
replace SchName = "RISE Prep Mayoral Academy Middle School" if SchName == "RISE Prep Mayoral Acad Middle"

merge m:1 SchYear DistName SchName using "$Original_DTA/RI_NCES_CW2", update replace gen(NCESMerge2)

//DataLevel
gen DataLevel = 1 if DistName == "Statewide"
replace DataLevel = 2 if DistName != "Statewide" & SchName == "All Schools"
replace DataLevel = 3 if DistName != "Statewide" & SchName != "All Schools"
label def DataLevel 1 "State" 2 "District" 3 "School"
label values DataLevel DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel != 3
sort SchYear DataLevel Subject StudentSubGroup

//GradeLevel
replace GradeLevel = "38" if GradeLevel == "All Grades" & Subject != "sci"
replace GradeLevel = subinstr(GradeLevel, "Grade: ","",.)
drop if real(GradeLevel) > 8 & real(GradeLevel) != 38 //This also drops the GradeLevel value "All Grades" for science
replace GradeLevel = "G" + GradeLevel
drop if SchName == "Blackstone Valley Prep" & GradeLevel == "G38" & (SchYear == "2018-19" | SchYear == "2017-18") //two sets of G38 values for each of grades 3 & 4 and 5-8, so dropping. 

//StudentSubGroup
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Other"
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Groups") !=0
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Current English Learners"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learners"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "EL Monit or Recently Ex" if strpos(,StudentSubGroup, "Recently (3 yrs)") !=0
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Students in Foster Care"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Students not in Foster Care"
replace StudentSubGroup = "Military" if StudentSubGroup == "Students with Active Military Parent"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Students without Active Military Parent"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
drop if strpos(StudentSubGroup, "Accommodations")
drop if StudentSubGroup == "Unknown"

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

//Cleaning Percents (Some percents decimal, some numeric out of 100). Determining which here because there's not really a pattern. Also sometimes one level is a percent and another is a decimal, so not even consistent across the same observation

foreach var of varlist *_percent ParticipationRate {
	gen `var'_perx = 1 if strpos(`var', "%")
}

foreach var of varlist *_percent ParticipationRate {
	replace `var' = subinstr(`var', "%","",.)
}

foreach var of varlist Lev*_percent ProficientOrAbove_percent ParticipationRate {
	gen `var'_dec = 1 if real(`var') <= 1 & !missing(real(`var'))
	replace `var'_dec = 0 if real(`var') >1.01 & !missing(real(`var'))
}


foreach var of varlist Lev*_percent ProficientOrAbove_percent ParticipationRate {
	replace `var' = string(real(`var')/100) if !missing(real(`var')) & (`var'_perx == 1 | `var'_dec == 0)
	replace `var' = "*" if missing(real(`var'))
}

//A couple numeric Lev4_percents less than 1 causing remaining problems
gen sumperc = real(Lev1_percent) + real(Lev2_percent) + real(Lev3_percent) + real(Lev4_percent)
replace Lev4_percent = string(real(Lev4_percent)/100) if abs(1-sumperc) > .01 & !missing(sumperc) & !missing(real(Lev4_percent))
replace Lev4_percent = "0" if abs(real(ProficientOrAbove_percent) - real(Lev3_percent)) < 0.001 & !missing(real(ProficientOrAbove_percent) - real(Lev3_percent))
drop *_perx *_dec sumperc

//Generate Counts
foreach percent of varlist *_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	gen `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `count' = "*" if missing(real(`count'))
}

//NCES Merging
merge m:1 SchYear NCESDistrictID using "$NCES_RI/NCES_District_RI", gen(DistMerge)
drop if DistMerge == 2
merge m:1 SchYear NCESSchoolID using "$NCES_RI/NCES_School_RI", gen(SchMerge)
drop if SchMerge == 2

//New Schools (Both are high schools already dropped)

// //Aventure Academy 440090000547 (NEW)
// replace NCESSchoolID = "440090000547" if DistName == "Providence" & SchName == "Aventure Academy"
// replace NCESDistrictID = "4400900" if DistName == "Providence" & SchName == "Aventure Academy"
// replace State_leaid = "RI-28" if DistName == "Providence" & SchName == "Aventure Academy"
// replace DistType = "Regular local school district" if DistName == "Providence" & SchName == "Aventure Academy"
// replace DistCharter = "No" if DistName == "Providence" & SchName == "Aventure Academy"
// replace DistLocale = "City, midsize" if DistName == "Providence" & SchName == "Aventure Academy"
// replace CountyCode = "44007" if DistName == "Providence" & SchName == "Aventure Academy"
// replace CountyName = "Providence County" if DistName == "Providence" & SchName == "Aventure Academy"
// replace SchType = "Regular school" if DistName == "Providence" & SchName == "Aventure Academy"
// replace SchLevel = "High" if DistName == "Providence" & SchName == "Aventure Academy"
// replace SchVirtual = "No" if DistName == "Providence" & SchName == "Aventure Academy"
//
// //Newcomer Academy 440090000328 (NEW)
// replace NCESSchoolID = "440090000328" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace NCESDistrictID = "4400900" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace State_leaid = "RI-28" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace DistType = "Regular local school district" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace DistCharter = "No" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace DistLocale = "City, midsize" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace CountyCode = "44007" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace CountyName = "Providence County" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace SchType = "Regular school" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace SchLevel = "High" if DistName == "Providence" & SchName == "Newcomer Academy"
// replace SchVirtual = "No" if DistName == "Providence" & SchName == "Newcomer Academy"

//Indicator Variables
replace State = "Rhode Island"
replace StateAbbrev = "RI"
replace StateFips = 44

**IDs
gen StateAssignedDistID = subinstr(State_leaid, "RI-","",.) if DataLevel !=1
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1,.) if DataLevel == 3

gen AssmtName = "NGSA" if Subject == "sci"
replace AssmtName = "RICAS" if Subject != "sci"

**Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

replace Flag_AssmtNameChange = "Y" if SchYear == "2017-18" & Subject != "sci"
replace Flag_CutScoreChange_ELA = "Y" if SchYear == "2017-18"
replace Flag_CutScoreChange_math = "Y" if SchYear == "2017-18"

replace Flag_AssmtNameChange = "Y" if SchYear == "2018-19" & Subject == "sci"
replace Flag_CutScoreChange_sci = "Y" if SchYear == "2018-19"
replace Flag_CutScoreChange_sci = "Not applicable" if SchYear == "2017-18"

**Proficiency
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_count = ""
gen Lev5_percent = ""

**AssmtType
gen AssmtType = "Regular"

save "$Original_DTA/RI_AssmtData_All", replace

//Splitting By Year
forvalues year = 2018/2024 {
	if `year' == 2020 continue
	local prevyear = `year'-1
use "$Original_DTA/RI_AssmtData_All", clear
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
keep if SchYear == "`prevyear'-" + substr("`year'",-2,2)
	
**StudentGroup_TotalTested
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

//Calculations
//Derive Level percent if we have ProficientOrAbove_percent
replace Lev3_percent = string(real(ProficientOrAbove_percent)-real(Lev4_percent)) if !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev4_percent)) & missing(real(Lev3_percent))
replace Lev4_percent = string(real(ProficientOrAbove_percent)- real(Lev3_percent)) if !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent)) & missing(real(Lev4_percent))

//Level percent (and corresponding count) derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

foreach percent of varlist Lev*_percent {
	replace `percent' = "0" if real(`percent') <  0.005 & !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent)) & missing(real(ProficientOrAbove_percent))

// Saving transformed data, will restore this file for non-derivation output. 
save "${Temp}/RI_AssmtData_`year'_Breakpoint", replace

*******************************************************
**Derivations***
*******************************************************
foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
}

//Misc fixes
foreach var of varlist Lev* Proficient* {
	replace `var' = ustrregexra(`var', "\u00A0", "") //nonbreaking whitespace removal
}

//Final Cleaning

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output*
save "$Output/RI_AssmtData_`year'", replace
export delimited "$Output/RI_AssmtData_`year'", replace

///////////////////////////////////////////////////////
*******************************************************
** Creating the non-derivation file 
*******************************************************
///////////////////////////////////////////////////////
// Restoring the break-point 
use "${Temp}/RI_AssmtData_`year'_Breakpoint", clear

//Misc fixes
foreach var of varlist Lev* Proficient* {
	replace `var' = ustrregexra(`var', "\u00A0", "") //nonbreaking whitespace removal
}

//Final Cleaning

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

// Reordering variables and sorting data
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Non-Derivation Output*
save "${Output_ND}/RI_AssmtData_`year'_ND", replace
export delimited "${Output_ND}/RI_AssmtData_`year'_ND", replace
}
* END of RI_Cleaning_2018_2024.do
****************************************************
