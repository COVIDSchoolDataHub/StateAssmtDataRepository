clear
set more off
set trace off

global original "/Volumes/T7/State Test Project/Delaware/Original"
global output "/Volumes/T7/State Test Project/Delaware/Cleaned"
global nces_school "/Volumes/T7/State Test Project/Delaware/NCESNew/School"
global nces_dist "/Volumes/T7/State Test Project/Delaware/NCESNew/District"
global PART2 "/Volumes/T7/State Test Project/Delaware/DE_2015_2022_PART2.do" //Set filepath for second do file
foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 { //2020 data would be empty, is thus not included

import excel "${original}/DE_OriginalData_`year'_all.xlsx", sheet("Sheet1") firstrow




//Defining DataLevel
gen DataLevel =""
replace DataLevel = "School" if SchoolCode != 0 & DistrictCode !=0
replace DataLevel = "District" if DistrictCode !=0 & SchoolCode==0
replace DataLevel = "State" if DistrictCode==0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel

//Merging NCES school and district files

rename SchoolCode StateAssignedSchID
local prevyear =`=`year'-1'
if `year' != 2023 {
tostring StateAssignedSchID, replace
merge m:1 StateAssignedSchID using "${nces_school}/NCES_`prevyear'_school.dta", force
drop _merge
}
if `year' == 2023 {
	tostring StateAssignedSchID, replace
	merge m:1 StateAssignedSchID using "${nces_school}/NCES_2021_school.dta", force
	drop _merge
}

if `year' !=2023 {

rename DistrictCode StateAssignedDistID
tostring StateAssignedDistID, replace
merge m:1 StateAssignedDistID using "${nces_dist}/NCES_`prevyear'_district.dta", force
drop _merge
}
if `year' == 2023 {
	rename DistrictCode StateAssignedDistID
	tostring StateAssignedDistID, replace
	merge m:1 StateAssignedDistID using "${nces_dist}/NCES_2021_district.dta", force
	drop _merge
}

//Fixing District Level Variables from merge

replace NCESDistrictID = NCESDistrictID1 if DataLevel==2
replace State_leaid = State_leaid1 if DataLevel==2
replace DistCharter = DistCharter1 if DataLevel==2 //For some reason, NCES has DistCharter indicators for individual schools in DE, but there are no charter districts in DE. Thus, all DistCharter indicators will be "No" at DataLevel==2. 
replace CountyName = CountyName1 if DataLevel==2
replace CountyCode = CountyCode1 if DataLevel==2
replace DistType = DistType1 if DataLevel==2




//Cleaning GradeLevel Variable
rename Grade GradeLevel
replace GradeLevel="G03" if GradeLevel=="3rd Grade"
replace GradeLevel="G04" if GradeLevel=="4th Grade"
replace GradeLevel="G05" if GradeLevel=="5th Grade"
replace GradeLevel="G06" if GradeLevel=="6th Grade"
replace GradeLevel="G07" if GradeLevel=="7th Grade"
replace GradeLevel="G08" if GradeLevel=="8th Grade"


//Dropping High School Data
keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")


//Fixing StudentGroup and StudentSubGroup 

//For some years (2021 and 2022 specifically), there are subgroups within subgroups, e.g, female/asians/english learners. We cannot retain this data in our current format, so it must be dropped.
generate not_all_students = 0
replace not_all_students = not_all_students + 1 if Race != "All Students"
replace not_all_students = not_all_students + 1 if Gender != "All Students"
replace not_all_students = not_all_students + 1 if SpecialDemo != "All Students"
drop if not_all_students > 1

keep if inlist(SpecialDemo, "Active EL Students", "All Students", "Low-Income")
replace SpecialDemo = "Economically Disadvantaged" if SpecialDemo== "Low-Income"
replace SpecialDemo = "English Learners" if SpecialDemo== "Active EL Students"

* Create the StudentGroup variable
gen StudentGroup = "" 

replace StudentGroup = "RaceEth" if Race != "All Students"
replace StudentGroup = "Gender" if Gender != "All Students"
replace StudentGroup = "Economic Status" if SpecialDemo == "Economically Disadvantaged"
replace StudentGroup = "EL Status" if SpecialDemo == "English Learners"
replace StudentGroup = "All Students" if Race == "All Students" & Gender == "All Students" & SpecialDemo == "All Students"

* Create the StudentSubGroup variable
gen StudentSubGroup = ""

replace StudentSubGroup = Race if StudentGroup == "RaceEth"
replace StudentSubGroup = Gender if StudentGroup == "Gender"
replace StudentSubGroup = SpecialDemo if StudentGroup == "Economic Status" | StudentGroup == "EL Status"
replace StudentSubGroup = "All Students" if StudentGroup == "All Students"


rename Tested StudentSubGroup_TotalTested
destring StudentSubGroup_TotalTested, ignore (",") replace
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StateAssignedSchID StateAssignedDistID AssessmentName ContentArea DataLevel StudentGroup GradeLevel)



//Replacing StudentSubGroup with correct values
replace StudentSubGroup = "Black or African American" if StudentSubGroup== "African American"
replace StudentSubGroup = "Asian" if StudentSubGroup== "Asian American"
replace StudentSubGroup = "Two or More" if StudentSubGroup== "Multi-Racial"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup== "Native Hawaiian/Pacific Islander"


//Fixing easy variables
replace State = "Delaware"
replace StateAbbrev = "DE"
replace StateFips= 10
recast int StateFips
drop DistName
rename District DistName
rename Organization SchName
replace DistName= "All Districts" if DataLevel==1
replace SchName = "All Schools" if DataLevel==1
replace SchName= "All Schools" if DataLevel==2
rename AssessmentName AssmtName
gen AssmtType= "Regular"

//Fixing SchYear
rename SchoolYear SchYear
tostring SchYear, replace force
replace SchYear = "`prevyear'"+ "-" + substr("`year'",-2,2)

//Fixing Subject
rename ContentArea Subject
replace Subject = lower(Subject)
replace Subject = "math" if Subject== "mat"
keep if inlist(Subject, "ela", "math", "sci", "soc" )

//Creating Variables
gen Lev1_count= "--"
gen Lev1_percent= "--"
gen Lev2_count= "--"
gen Lev2_percent= "--"
gen Lev3_count= "--"
gen Lev3_percent= "--"
gen Lev4_count= "--"
gen Lev4_percent= "--"
gen Lev5_count= ""
gen Lev5_percent= ""
gen ParticipationRate= "--"
gen Flag_AssmtNameChange="N"
*replace Flag_AssmtNameChange = "Y" if `year'==2019 & (Subject== "sci" | Subject == "soc")
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"
replace Flag_CutScoreChange_oth = "" if `year' == 2018
*replace Flag_CutScoreChange_oth = "Y" if `year'==2019 & Subject== "sci"
*replace Flag_AssmtNameChange = "Y" if `year' == 2018 & Subject== "sci"



//More formatting
rename ScaleScoreAvg AvgScaleScore
rename Proficient ProficientOrAbove_count
gen ProficientOrAbove_percent = (PctProficient/100)
tostring ProficientOrAbove_percent, replace force
drop PctProficient
replace ProficientOrAbove_percent = substr(ProficientOrAbove_percent,1,4)
recast str4 ProficientOrAbove_percent
replace SchVirtual = "Missing/not reported" if SchVirtual == ""

//SUPPRESSED DATA 
tostring StudentGroup_TotalTested, replace
tostring StudentSubGroup_TotalTested, replace
if `year' ==2023 {
gen AvgScore = string(AvgScaleScore, "%10.0g")
drop AvgScaleScore
rename AvgScore AvgScaleScore
gen profcount = string(ProficientOrAbove_count, "%10.0g")
drop ProficientOrAbove_count
rename profcount ProficientOrAbove_count
}
replace StudentGroup_TotalTested = "*" if RowStatus== "REDACTED" & (StudentGroup_TotalTested == "0" | StudentGroup_TotalTested== "." )
replace StudentSubGroup_TotalTested = "*" if RowStatus== "REDACTED" & (StudentSubGroup_TotalTested == "0" | StudentSubGroup_TotalTested == "." )
replace AvgScaleScore = "*" if RowStatus== "REDACTED"
replace ProficientOrAbove_count = "*" if RowStatus== "REDACTED"
replace ProficientOrAbove_percent = "*" if RowStatus== "REDACTED"



//Proficiency Criteria
gen ProficiencyCriteria = "Level 3 or 4"


//Ordering, Sorting, Dropping Alternative Assessments
drop if AssmtName != "Smarter Balanced Summative Assessment" & (Subject== "ela" | Subject == "math")
if `year' == 2019 | `year' == 2021 | `year' == 2022 {
	drop if AssmtName== "DeSSA Alternate Assessment"
}

//Response to R1
replace DistType = "Regular local school district" if SchName == "Meadowood Program" & `year' == 2015
replace NCESDistrictID = "1001300" if SchName == "Meadowood Program" & `year' == 2015
replace State_leaid = "32" if SchName == "Meadowood Program" & `year' == 2015
replace DistCharter = "No" if SchName == "Meadowood Program" & `year' == 2015
replace CountyName = "NEW CASTLE COUNTY" if SchName == "Meadowood Program" & `year' == 2015
replace CountyCode = 10003 if SchName == "Meadowood Program" & `year' == 2015
replace SchType = "MISSING" if SchName == "Meadowood Program" & `year' == 2015
replace seasch = "MISSING" if SchName == "Meadowood Program" & `year' == 2015
replace SchLevel = "MISSING" if SchName == "Meadowood Program" & `year' == 2015

replace DistType = "State-operated agency" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace NCESDistrictID = "1000022" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace State_leaid = "97" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace StateAssignedDistID = "97" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace CountyName = "NEW CASTLE COUNTY" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace CountyCode = 10003 if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace SchType = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace seasch = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace SchLevel = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace NCESSchoolID = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace DistCharter = "No" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3

replace SchVirtual = "" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"

if `year' == 2018 {
	drop if AssmtName != "Smarter Balanced Summative Assessment"
}
if `year' == 2023 {
	drop if AssmtName == "DeSSA Alternate Assessment"
}

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Exporting
save "${output}/DE_AssmtData_`year'.dta", replace
clear
}


do "${PART2}"

//RESPONSE TO R3
foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 {

use "${output}/DE_AssmtData_`year'"
	if `year' == 2016 {
	replace DistType = "Regular local school district" if DistType == "Colonial School District"
	}
	drop if DistName == "Dept. of Svs. for Children Youth & Their Families"
	replace SchType = "Missing/not reported" if SchType == "MISSING"
	if `year' == 2015 | `year' == 2016 {
	replace State_leaid = "DE-" + State_leaid if DataLevel !=1
	}
	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == "MISSING"
	if `year' == 2019 {
	drop if SchLevel == "Prekindergarten"
	replace Flag_AssmtNameChange = "Y" if Subject == "sci" | Subject == "soc"
	}
	replace SchLevel = "Missing/not reported" if SchLevel == "MISSING"
	replace CountyName = proper(CountyName)
	save "${output}/DE_AssmtData_`year'", replace
	export delimited using "${output}/DE_AssmtData_`year'.csv", replace
	clear
}
