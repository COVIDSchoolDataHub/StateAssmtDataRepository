clear
set more off

cd "/Volumes/T7/State Test Project/California/Cleaned DTA"

global nces "/Volumes/T7/State Test Project/California/NCES"
global output "/Volumes/T7/State Test Project/California/Output"
global original "/Volumes/T7/State Test Project/California/Original Data Files"

//years 2019 2021 2022 2023
foreach year in 2019 2021 2022 2023 {
	local prevyear = `year' - 1
	use "${original}/CA_OriginalData_`year'_sci", clear
	merge m:1 CountyCode DistrictCode SchoolCode using "${original}/cast_ca`year'entities_csv", nogen
	cap rename DemographicID DemographicIDNum
	cap rename StudentGroupID DemographicIDNum
	merge m:1 DemographicIDNum using California_Student_Group_Names
	drop if _merge !=3
	drop _merge

//Rename and Drop Variables
if `year' == 2019 drop Filler TestYear DemographicIDNum TestType TotalNumberTestedatEntityLevelan TotalNumberTestedatthisDemograph TestID TotalNumberofStudentswithValidSc-CountyName ZipCode StudentGroupID
if `year' > 2019 drop Filler TestYear DemographicIDNum TestType TotalTestedatReportingLevel TotalTestedwithScoresatReporting TestID StudentswithScores-CountyName ZipCode StudentGroupID
rename DistrictCode StateAssignedDistID
rename SchoolCode StateAssignedSchID
rename Grade GradeLevel
if `year' == 2019 rename CASTReportedEnrollment Enrollment
if `year' > 2019 rename StudentsEnrolled Enrollment
if `year' == 2019 rename TotalNumberofStudentsTested StudentSubGroup_TotalTested
if `year' > 2019 rename StudentsTested StudentSubGroup_TotalTested
rename MeanScaleScore AvgScaleScore
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent
rename PercentageStandardMetandAbove ProficientOrAbove_percent
rename DemographicName StudentSubGroup
rename DistrictName DistName
rename SchoolName SchName

//DataLevel
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == 0
replace DataLevel = "County" if StateAssignedDistID == 0 & StateAssignedSchID == 0
replace DataLevel = "State" if CountyCode == 0 & StateAssignedDistID == 0 & StateAssignedSchID == 0
drop if DataLevel == "County"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//State_leaid for merging Districts
tostring CountyCode StateAssignedDistID, replace
replace CountyCode = "0" + CountyCode if strlen(CountyCode) == 1
gen State_leaid = CountyCode + StateAssignedDistID
drop CountyCode


//GradeLevel
drop if GradeLevel > 8 | GradeLevel < 3
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//ParticipationRate
gen ParticipationRate = string(real(StudentSubGroup_TotalTested)/real(Enrollment), "%9.3g") if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Enrollment))
replace ParticipationRate = "--" if missing(ParticipationRate)
drop Enrollment

//Proficiency Level Conversions
foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	replace `var' = string(real(`var')/100, "%9.3g") if strpos(`var', "*") == 0
	replace `var' = "--" if missing(`var')
}

//Level Counts
foreach percent of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	gen `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `count' = "--" if missing(`count')
}

//StudentGroup & StudentSubGroup 
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if StudentSubGroup == "ADEL (Adult English learner)"  
drop if StudentSubGroup == "College graduate"
drop if StudentSubGroup == "Declined to state"
drop if StudentSubGroup == "ELs enrolled 12 months or more"
drop if StudentSubGroup == "ELs enrolled less than 12 months"

drop if StudentSubGroup == "Graduate school/Post graduate"
drop if StudentSubGroup == "High school graduate"
drop if StudentSubGroup == "Not a high school graduate"
drop if StudentSubGroup == "Some college (includes AA degree)"
drop if StudentSubGroup == "IFEP (Initial fluent English proficient)"
drop if StudentSubGroup == "TBD (To be determined)"

replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"
drop if StudentSubGroup == "Filipino" //dropping for now

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//NCES Merging
merge m:1 State_leaid using "$nces/NCES_All_District.dta", gen(DistMerge)
drop if DistMerge == 2
gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID
gen seasch2 = StateAssignedSchID
merge m:1 seasch2 using "$nces/1_NCES_`prevyear'_School.dta", gen(SchMerge) force
drop if SchMerge == 2 | (SchMerge == 1 & SchName == "") | (SchMerge == 1 & strpos(SchName, "District Lev") !=0)
drop if SchName == "San Francisco County Office of Education District "
drop DistMerge SchMerge seasch2
sort DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3

//Indicator and Missing Variables
replace State = "California"
replace StateAbbrev = "CA"
replace StateFips = 6
gen SchYear = "`prevyear'-" + substr("`year'",-2,2)

gen AssmtName = "CAST"
gen AssmtType = "Regular"

gen Subject = "sci"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "Not applicable"

gen ProficiencyCriteria = "Levels 3-4"

gen Lev5_count = ""
gen Lev5_percent = ""

//StudentGroup_TotalTested (based on new convention) & deriving StudentSubGroup_TotalTested
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(DistName SchName Subject GradeLevel StudentGroup)
order UnsuppressedSSG UnsuppressedSG StudentSubGroup_TotalTested StudentGroup_TotalTested StudentGroup StudentSubGroup
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested) - UnsuppressedSG) if !missing(real(StudentGroup_TotalTested)) & UnsuppressedSG !=0 & missing(real(StudentSubGroup_TotalTested)) & StudentGroup != "All Students" & StudentGroup != "RaceEth" & StudentGroup != "EL Status" & real(StudentGroup_TotalTested) - UnsuppressedSG >= 0

drop Unsuppressed*
order DataLevel

//Final Cleaning
replace DistName = strtrim(DistName)
replace DistName =stritrim(DistName)
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Misc Changes to DistName for Consistency
replace DistName = "Para Los Ninos Charter" if DistName == "Para Los Niños Charter"
replace DistName = "Para Los Ninos Middle" if DistName == "Para Los Niños Middle"
replace DistName = "Shanel Valley Academy" if DistName == "Shanél Valley Academy"
replace DistName = "Voices College-Bound Language Academy At" if DistName == "Voices College Bound Language Academy At" 
replace DistName = ustrtitle(DistName)

if `year' == 2023 replace DistName = DistName + " District" if DataLevel !=1 & strpos(DistName, "District") == 0

save "${output}/CA_AssmtData_`year'_sci", replace
append using "${output}/CA_AssmtData_`year'_ela_math"
save "${output}/CA_AssmtData_`year'_Stata", replace
}
