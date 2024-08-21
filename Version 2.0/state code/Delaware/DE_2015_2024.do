clear
set more off
set trace off

global original "/Users/kaitlynlucas/Desktop/Delaware State Task/Original Data Files"
global output "/Users/kaitlynlucas/Desktop/Delaware State Task/Output"
global nces "/Users/kaitlynlucas/Desktop/Delaware State Task/NCES_DE"
global PART2 "/Users/kaitlynlucas/Desktop/EDFacts Drive Data/Delaware/DE_2015_2022_PART2.do" //Set filepath for second do file

// foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 2024
foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 2024 { //2020 data would be empty, is thus not included

if `year' == 2015 {
	import excel "${original}/DE_OriginalData_`year'_SMARTER_ela_math_sci_soc_wri.xlsx", sheet("Sheet1") allstring clear
	rename A SchoolYear	
	rename B DistrictCode	
	rename C District	
	rename D SchoolCode	
	rename E Organization	
	rename F AssessmentName	
	rename G ContentArea	
	rename H Race	
	rename I Gender	
	rename J Grade	
	rename K SpecialDemo	
	rename L Geography	
	rename M SubGroup	
	rename N RowStatus	
	rename O Tested	
	rename P Proficient	
	rename Q PctProficient	
	rename R ScaleScoreAvg
	}
	else if `year' == 2016 {
		import excel "${original}/DE_OriginalData_`year'_SMARTER_ela_math_sci_soc.xlsx", sheet("Sheet1") firstrow allstring clear
	}
	else if `year' == 2017 {
		import excel "${original}/DE_OriginalData_`year'_SMARTER_ela_math_sci.xlsx", sheet("Sheet1") firstrow allstring clear
    }
	else if `year' == 2018 {
		import excel "${original}/DE_OriginalData_`year'_SMARTER_ela_math_sci.xlsx", sheet("Sheet1") firstrow allstring clear
    }
	else if `year' == 2019 {
		import excel "${original}/DE_OriginalData_`year'_ela_math_sci_soc.xlsx", sheet("Sheet1") firstrow allstring clear
    }
	    else if `year' == 2021 {
        import excel "${original}/DE_OriginalData_`year'_ela_math_sci_soc.xlsx", sheet("Sheet1") firstrow allstring clear
    }
    
    else if `year' == 2022 {
        import excel "${original}/DE_OriginalData_`year'_ela_math_sci_soc.xlsx", sheet("Sheet1") firstrow allstring clear
    }
    
    else if `year' == 2023 {
        import excel "${original}/DE_OriginalData_`year'_ela_math_sci_soc.xlsx", sheet("Sheet1") firstrow allstring clear
    }
	
	else if `year' == 2024 {
		import excel "${original}/DE_OriginalData_2024_ela_math_sci_soc.xlsx", firstrow allstring clear   
    }

	
//Defining DataLevel
gen DataLevel =""
replace DataLevel = "School" if SchoolCode != "0" & DistrictCode !="0"
replace DataLevel = "District" if DistrictCode !="0" & SchoolCode=="0"
replace DataLevel = "State" if DistrictCode=="0"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel

//Merging NCES school and district files

rename SchoolCode StateAssignedSchID
local prevyear =`=`year'-1'
if `year' < 2023 {
tostring StateAssignedSchID, replace
merge m:1 StateAssignedSchID using "${nces}/NCES_`prevyear'_school.dta", force
drop _merge
}
if `year' == 2023 | `year' == 2024 {
	tostring StateAssignedSchID, replace
	merge m:1 StateAssignedSchID using "${nces}/NCES_2022_school.dta", force
	drop _merge
}

if `year' < 2023 {

rename DistrictCode StateAssignedDistID
tostring StateAssignedDistID, replace
merge m:1 StateAssignedDistID using "${nces}/NCES_`prevyear'_district.dta", force
drop _merge
}
if `year' == 2023 | `year' == 2024 {
	rename DistrictCode StateAssignedDistID
	tostring StateAssignedDistID, replace
	merge m:1 StateAssignedDistID using "${nces}/NCES_2022_district.dta", force
	drop _merge
}

//Fixing District Level Variables from merge
/*
replace NCESDistrictID = NCESDistrictID1 if DataLevel==2
replace State_leaid = State_leaid1 if DataLevel==2
replace DistCharter = DistCharter1 if DataLevel==2 //For some reason, NCES has DistCharter indicators for individual schools in DE, but there are no charter districts in DE. Thus, all DistCharter indicators will be "No" at DataLevel==2. 
replace CountyName = CountyName1 if DataLevel==2
replace CountyCode = CountyCode1 if DataLevel==2
decode DistType1, gen (DistType1_str)
replace DistType = DistType1_str if DataLevel == 2
drop DistType1_str
replace DistLocale = DistLocale1 if DataLevel==2
*/



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

// keep if inlist(SpecialDemo, "Active EL Students", "All Students", "Low-Income")
replace SpecialDemo = "Economically Disadvantaged" if SpecialDemo== "Low-Income"
replace SpecialDemo = "Not Economically Disadvantaged" if SpecialDemo== "Non Low-Income"
replace SpecialDemo = "English Learner" if SpecialDemo== "Active EL Students"
replace SpecialDemo = "English Proficient" if SpecialDemo== "Non-EL Students"
replace SpecialDemo = "Military" if SpecialDemo== "Military Connected Youth"
replace SpecialDemo = "SWD" if SpecialDemo== "Students with Disabilities"
replace SpecialDemo = "Non-SWD" if SpecialDemo== "Students without Disabilities"

* Create the StudentGroup variable
gen StudentGroup = "" 

replace StudentGroup = "RaceEth" if Race != "All Students"
replace StudentGroup = "Gender" if Gender != "All Students"
replace StudentGroup = "Economic Status" if SpecialDemo == "Economically Disadvantaged" | SpecialDemo == "Not Economically Disadvantaged"
replace StudentGroup = "EL Status" if SpecialDemo == "English Learner" | SpecialDemo == "English Proficient"
replace StudentGroup = "Disability Status" if SpecialDemo == "SWD" | SpecialDemo == "Non-SWD"
replace StudentGroup = "Homeless Enrolled Status" if SpecialDemo == "Homeless" | SpecialDemo == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if SpecialDemo == "Foster Care" | SpecialDemo == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if SpecialDemo == "Military" 
replace StudentGroup = "All Students" if Race == "All Students" & Gender == "All Students" & SpecialDemo == "All Students"

* Create the StudentSubGroup variable
gen StudentSubGroup = ""

replace StudentSubGroup = Race if StudentGroup == "RaceEth"
replace StudentSubGroup = Gender if StudentGroup == "Gender"
replace StudentSubGroup = SpecialDemo if StudentGroup == "Economic Status" | StudentGroup == "EL Status" | StudentGroup == "Disability Status" | StudentGroup == "Homeless Enrolled Status" | StudentGroup == "Foster Care Status" | StudentGroup == "Military Connected Status"
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
replace SchName = Organization if SchName == ""
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
gen Flag_CutScoreChange_soc="N"
gen Flag_CutScoreChange_sci="N"
*replace Flag_CutScoreChange_oth = "" if `year' == 2018
*replace Flag_CutScoreChange_oth = "Y" if `year'==2019 & Subject== "sci"
*replace Flag_AssmtNameChange = "Y" if `year' == 2018 & Subject== "sci"



//More formatting
rename ScaleScoreAvg AvgScaleScore
rename Proficient ProficientOrAbove_count
destring PctProficient, replace
gen ProficientOrAbove_percent = (PctProficient/100)
tostring ProficientOrAbove_percent, replace force
drop PctProficient
replace ProficientOrAbove_percent = substr(ProficientOrAbove_percent,1,4)
recast str4 ProficientOrAbove_percent
replace SchVirtual = "Missing/not reported" if SchVirtual == "" 

//SUPPRESSED DATA 
tostring StudentGroup_TotalTested, replace
tostring StudentSubGroup_TotalTested, replace
/*
if `year' ==2023 {
gen AvgScore = string(AvgScaleScore, "%10.0f")
drop AvgScaleScore
rename AvgScore AvgScaleScore
gen profcount = string(ProficientOrAbove_count, "%10.0g")
drop ProficientOrAbove_count
rename profcount ProficientOrAbove_count
}
*/

replace StudentGroup_TotalTested = "*" if RowStatus== "REDACTED" & (StudentGroup_TotalTested == "0" | StudentGroup_TotalTested== "." )
replace StudentSubGroup_TotalTested = "*" if RowStatus== "REDACTED" & (StudentSubGroup_TotalTested == "0" | StudentSubGroup_TotalTested == "." )
replace AvgScaleScore = "*" if RowStatus== "REDACTED"
replace ProficientOrAbove_count = "*" if RowStatus== "REDACTED"
replace ProficientOrAbove_percent = "*" if RowStatus== "REDACTED"



//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3-4"


//Ordering, Sorting, Dropping Alternative Assessments
drop if AssmtName != "Smarter Balanced Summative Assessment" & (Subject== "ela" | Subject == "math")
if `year' == 2019 | `year' == 2021 | `year' == 2022 | `year' == 2023 | `year' == 2024 {
	drop if AssmtName== "DeSSA Alternate Assessment"
}

//Response to R1
replace DistType = "Regular local school district" if SchName == "Meadowood Program" & `year' == 2015
replace NCESDistrictID = "1001300" if SchName == "Meadowood Program" & `year' == 2015
replace State_leaid = "32" if SchName == "Meadowood Program" & `year' == 2015
replace DistCharter = "No" if SchName == "Meadowood Program" & `year' == 2015
replace CountyName = "New Castle County" if SchName == "Meadowood Program" & `year' == 2015
replace CountyCode = "10003" if SchName == "Meadowood Program" & `year' == 2015
replace SchType = "MISSING" if SchName == "Meadowood Program" & `year' == 2015
replace seasch = "MISSING" if SchName == "Meadowood Program" & `year' == 2015
replace SchLevel = "MISSING" if SchName == "Meadowood Program" & `year' == 2015

replace DistType = "State-operated agency" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace NCESDistrictID = "1000022" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace State_leaid = "97" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace StateAssignedDistID = "97" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace CountyName = "New Castle County" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace CountyCode = "10003" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace SchType = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace seasch = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace SchLevel = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace NCESSchoolID = "MISSING" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3
replace DistCharter = "No" if DistName == "Dept. of Svs. for Children Youth & Their Families" & DataLevel == 3

replace SchVirtual = "" if DataLevel !=3
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel !=3
* replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"

if `year' == 2018 {
	drop if AssmtName != "Smarter Balanced Summative Assessment"
}
if `year' == 2023 {
	drop if AssmtName == "DeSSA Alternate Assessment"
	drop if SchName == "Appoquinimink PreSchool Center"
}
if `year' == 2024 {
	drop if AssmtName == "DeSSA Alternate Assessment"
	drop if SchName == "Appoquinimink PreSchool Center"
}

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Exporting
save "${output}/DE_AssmtData_`year'.dta", replace
clear
}

set trace off
do "${PART2}"


//RESPONSE TO R3

// foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 2024
foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 2024 {
	
clear 
local prevyear = `year'-1

use "${output}/DE_AssmtData_`year'"

	replace DistType = "Regular local school district" if DistType == "Colonial School District"
	drop if DistName == "Dept. of Svs. for Children Youth & Their Families"
	replace SchType = "Missing/not reported" if SchType == "MISSING"
	if `year' == 2015 | `year' == 2016 {
	* replace State_leaid = "DE-" + State_leaid if DataLevel !=1
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

// for tracking reference 
/*
"ELA/Math
• 2014-15 to 2022-23: Smarter Balanced Summative Assessment

Science
• 2014-15 to 2016-17: Delaware Comprehensive Assessment System (DCAS)
• 2017-18: No science assessment (due to field testing)
• 2018-19 to 2021-23: Delaware System of Student Assessment - Science (DeSSA)

Social Studies:
• 2014-15 to 2015-16: DCAS Statewide Assessment
• 2016-17 to 2017-18: No social studies assessment (due to field testing)
• 2018-19 to 2021-22: Delaware System of Student Assessment - Social Studies (DeSSA)
• 2022-23: No Summative (non-alternate) Assessment"
*/

// 2024 updates
// Subgroup testing is edited in the original loop



foreach year in 2015 2016 2017 2018 2019 2021 2022 2023 2024 {

use "${output}/DE_AssmtData_`year'", clear
local prevyear =`=`year'-1'

	replace ProficiencyCriteria = "Levels 3-4"
	
	replace Flag_CutScoreChange_sci="N"
	replace Flag_CutScoreChange_soc="N"
	
	if `year' == 2015 {
		replace Flag_AssmtNameChange = "Y" if Subject == "math" | Subject == "ela"
		replace Flag_CutScoreChange_ELA = "Y"
		replace Flag_CutScoreChange_math = "Y"
	}
	
	if `year' == 2017 {
	replace Flag_CutScoreChange_soc="Not applicable"
	}
	
	if `year' == 2018 {
	replace Flag_CutScoreChange_sci="Not applicable"
	replace Flag_CutScoreChange_soc="Not applicable"
	}
	
	if `year' == 2019 {
	replace Flag_CutScoreChange_sci="Y"
	replace Flag_CutScoreChange_soc="Y"
	}
	
	if `year' == 2015 | `year' == 2016 {
	
		drop if Subject == "sci" & DataLevel == 1 & Lev1_count == "--" & Lev1_percent == "--"
		drop if Subject == "soc" & DataLevel == 1 & Lev1_count == "--" & Lev1_percent == "--"
		
		replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if Subject == "sci" & DataLevel == 1 & StudentGroup != "RaceEth"
		replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if Subject == "soc" & DataLevel == 1 & StudentGroup != "RaceEth"
		
		destring StudentGroup_TotalTested, gen(totaltest1) force
		replace totaltest1 = totaltest1 / 2
		tostring totaltest1, replace
		
		replace StudentGroup_TotalTested = totaltest1 if Subject == "sci" & DataLevel == 1 & StudentGroup == "RaceEth"
		replace StudentGroup_TotalTested = totaltest1 if Subject == "soc" & DataLevel == 1 & StudentGroup == "RaceEth"
		drop totaltest1
		
		replace SchLevel = "Other" if SchName == "The Wallace Wallin School"
		replace SchVirtual = "No" if SchName == "The Wallace Wallin School"

	}
	
	if `year' == 2015 | `year' == 2016 | `year' == 2017 {
		replace StudentSubGroup_TotalTested = "1-16" if StudentSubGroup_TotalTested == "<= 15"
		
		replace Lev1_count="*" if Subject=="sci" & Lev1_percent=="<0.01" & `year' == 2015
		replace Lev1_percent="*" if Subject=="sci" & Lev1_percent=="<0.01" & `year' == 2015
		
		replace ParticipationRate=".99-1" if ParticipationRate==">0.99"
		replace ParticipationRate=".95-1" if ParticipationRate==">0.95"
		
		destring ProficientOrAbove_percent, gen(profpercent) ignore("*" & "--")
		destring StudentSubGroup_TotalTested, gen(totaltested) ignore("*" & "--")
		
		replace totaltested=0 if totaltested==116
		
		gen profcount = profpercent * totaltested 
		
		format profcount %4.0f
		tostring profcount, replace format("%4.0f") force
		
		replace ProficientOrAbove_count = profcount if ProficientOrAbove_count=="--" & AssmtName == "DCAS Assessment" 
		replace ProficientOrAbove_count = "*" if ProficientOrAbove_count=="0" & AssmtName == "DCAS Assessment" & StudentSubGroup_TotalTested == "1-16"
		replace ProficientOrAbove_count = "--" if ProficientOrAbove_count=="." & AssmtName == "DCAS Assessment" & StudentSubGroup_TotalTested == "--"
		drop profcount totaltested profpercent
	}
	
	if `year' < 2022 {
		foreach v of varlist ProficientOrAbove_count AvgScaleScore {
			replace `v' = "999999" if `v'=="*"
			replace `v' = "888888" if `v'=="--"
		
			destring `v', generate(`v'_new) ignore(",")
			drop `v'
			
			tostring `v'_new, gen(`v')
			drop `v'_new
			
			replace `v' = "*" if `v'=="999999"
			replace `v' = "--" if `v'=="888888"

		}
		
	}
	
	if `year' == 2017 {
		destring Lev1_percent, generate(Lev1_p) ignore("*" & "--") 
		destring Lev2_percent, generate(Lev2_p) ignore("*" & "--")
		destring Lev3_percent, generate(Lev3_p) ignore("*" & "--")
		
		replace Lev4_percent = "999999999" if Lev4_percent == "<0.05"
		destring Lev4_percent, generate(Lev4_p) ignore("*" & "--")
		
		replace Lev4_p = 1 - Lev1_p - Lev2_p - Lev3_p if Lev4_p == 999999999
		
		tostring Lev4_p, replace force
		
		replace Lev4_percent = Lev4_p if Lev4_percent == "999999999"

	}
		if `year' == 2015 | `year' ==2016{
		replace DistLocale = "Suburb, large" if NCESSchoolID == "100023000378"
	}

//Update Jun 2024: Unmerged Schools from sci and soc data (Delaware School for the Deaf and Sussex Academy)
if `year' == 2015 | `year' == 2016 {
	tempfile temp1
	save "`temp1'", replace
	keep if missing(DistName)
	replace SchName = "Sussex Academy" if strpos(SchName, "Sussex") !=0
	replace SchName = "Delaware School for the Deaf" if strpos(SchName, "Deaf") !=0
	merge m:1 SchName using "${nces}/NCES_`prevyear'_school.dta", update force
	drop if _merge == 2
	drop _merge
	tempfile tempunmerged
	save "`tempunmerged'", replace
	clear
	use "`temp1'"
	drop if missing(DistName)
	append using "`tempunmerged'"
}
	
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	save "${output}/DE_AssmtData_`year'", replace
	export delimited using "${output}/DE_AssmtData_`year'.csv", replace
	clear
}
