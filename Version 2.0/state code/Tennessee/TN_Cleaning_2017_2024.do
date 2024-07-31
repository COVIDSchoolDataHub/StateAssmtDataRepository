
clear
set more off
set trace off

cd "/Volumes/T7/State Test Project/Tennessee"
global Original "/Volumes/T7/State Test Project/Tennessee/Original Data Files"
global NCES_TN "/Volumes/T7/State Test Project/Tennessee/NCES"
global Output "/Volumes/T7/State Test Project/Tennessee/Output"

//Combining DataLevels
	
forvalues year = 2017/2024 {
	if `year' == 2020 continue
	clear
	save "$Original/TN_OriginalData_`year'", replace emptyok
	foreach dl in state dist sch {
		use "$Original/TN_OriginalData_`year'_`dl'", clear
		gen DataLevel = "`dl'"
		append using "$Original/TN_OriginalData_`year'"
		save "$Original/TN_OriginalData_`year'", replace
	}

	
//Renaming 
drop year
rename system StateAssignedDistID
rename school StateAssignedSchID
rename subject Subject
rename grade GradeLevel
cap rename participation_rate ParticipationRate
cap rename school_name SchName
rename valid_tests StudentSubGroup_TotalTested
rename system_name DistName

if `year' >= 2018 keep if test == "TNReady"
cap drop test

if `year' < 2022 {
	rename n_below Lev1_count
	rename n_approaching Lev2_count
	rename n_on_track Lev3_count
	rename n_mastered Lev4_count
	rename pct_below Lev1_percent
	rename pct_approaching Lev2_percent
	rename pct_on_track Lev3_percent
	rename pct_mastered Lev4_percent
	rename pct_on_mastered ProficientOrAbove_percent
	rename subgroup StudentSubGroup
}

if `year' > 2021 {
	rename n_below Lev1_count
	rename n_approaching Lev2_count
	rename n_met_expectations Lev3_count
	rename n_exceeded_expectations Lev4_count
	rename pct_below Lev1_percent
	rename pct_approaching Lev2_percent
	rename pct_met_expectations Lev3_percent
	rename pct_exceeded_expectations Lev4_percent
	rename pct_met_exceeded ProficientOrAbove_percent
	rename student_group StudentSubGroup
}

save "$Original/TN_OriginalData_`year'", replace


//Subject
replace Subject = "ela" if Subject == "ELA"
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
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Learners"
replace StudentSubGroup = "EL and Monit or Recently Ex" if StudentSubGroup == "English Learners with T1/T2" | StudentSubGroup == "English Learners with Transitional 1-4"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "English Learner Transitional 1-4"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-Students with Disabilities"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically Disadvantaged (Free or Reduced Price Lunch)"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Economically Disadvantaged"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Military" if StudentSubGroup == "Students with Active Duty Military Parents"
drop if StudentSubGroup == "Black/Hispanic/Native American" | StudentSubGroup == "Non-English Learners/T1 or T2" | StudentSubGroup == "Non-Black/Hispanic/Native American" | StudentSubGroup == "Super Subgroup" | StudentSubGroup == "Non-English Learners/Transitional 1-4" | StudentSubGroup == "Gifted"

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



//Counts & Percents
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

//ParticipationRate
if `year' <= 2018 gen ParticipationRate = "--"
if `year' == 2019 gen ParticipationRate = string(tested/enrolled, "%9.3g") if !missing(tested) & !missing(enrolled)
if `year' > 2019 {
	replace ParticipationRate = string(real(ParticipationRate)/100) if !missing(real(ParticipationRate))
	drop tested enrolled
}

//DataLevel
replace DataLevel = "State" if DataLevel == "state"
replace DataLevel = "District" if DataLevel == "dist"
replace DataLevel = "School" if DataLevel == "sch"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
drop DataLevel
rename DataLevel_n DataLevel
sort DataLevel


//NCES Merging
local prevyear = `year' - 1
gen State_leaid = string(StateAssignedDistID, "%03.0f")
gen seasch = State_leaid + "-" + string(StateAssignedSchID, "%04.0f")

merge m:1 State_leaid using "$NCES_TN/NCES_All_District", gen(DistMerge) update
merge m:1 seasch using "$NCES_TN/NCES_All_School", gen(SchMerge) update
drop if DistMerge == 2 | SchMerge == 2
drop *Merge sch_lowest_grade_offered State_leaid seasch

replace State = "Tennessee"
replace StateAbbrev = "TN"
replace StateFips = 47

replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3
replace StateAssignedDistID = . if DataLevel == 1
replace StateAssignedSchID =. if DataLevel !=3

//StudentSubGroup_TotalTested
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

//ProficientOrAbove_count
gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested))) if missing(real(ProficientOrAbove_count)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested))
replace ProficientOrAbove_count = "--" if missing(ProficientOrAbove_count)

//Indicator & Missing Variables
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen AssmtName = "TNReady"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

if `year' == 2017 {
	replace Flag_AssmtNameChange = "Y" if Subject != "soc"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
	replace Flag_CutScoreChange_soc = "Not applicable"
}

if `year' == 2018 {
	replace Flag_CutScoreChange_soc = "Y"
	replace Flag_AssmtNameChange = "Y" if Subject == "soc"
} 
if `year' == 2019 replace Flag_CutScoreChange_sci = "Not applicable"
if `year' == 2021 replace Flag_CutScoreChange_sci = "Y"


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

//Dropping All Suppressed Unmerged
gen AllSuppressed = 0
	foreach var of varlist *_percent {
		replace AllSuppressed = AllSuppressed + 1 if !missing(real(`var'))

	}
drop if AllSuppressed ==0 & missing(NCESSchoolID) & DataLevel == 3

//2024 Merging New Schools
if `year' == 2024 {
merge m:1 SchName using TN_Unmerged_2024.dta, update nogen
}

//Additional Dropping
drop if SchLevel ==  "Prekindergarten"

//Response to R1

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
if `year' == 2017 drop if SchName == "Westhaven Elementary" & StudentGroup_TotalTested == "1" & GradeLevel == "G04" //Really weird data that makes no sense and screws up the code, dropping.

if `year' == 2017 drop if missing(SchName) //No way of determining which schools these are because there's no School Name variable in the 2017 files. All G38 data.

** Creating unique StateAssignedSchID
tostring StateAssignedSchID, replace
replace StateAssignedSchID = string(StateAssignedDistID) + "-" + StateAssignedSchID if DataLevel == 3
replace StateAssignedSchID = "" if DataLevel !=3

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$Output/TN_AssmtData_`year'", replace
export delimited "$Output/TN_AssmtData_`year'", replace

}
