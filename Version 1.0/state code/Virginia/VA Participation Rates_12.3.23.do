clear all
set more off

cd "/Users/miramehta/Documents"

global participation "/Users/miramehta/Documents/VA State Testing Data/Participation Rates"
global output "/Users/miramehta/Documents/VA State Testing Data"

// ELA
forvalues year = 2016/2023{
	
	if `year' == 2020{
		continue
	}
	
	local prev_year = `year' - 1
	import excel "$participation/`prev_year'-`year' Participation.xlsx", sheet("Reading") clear
	
	//Variable Names
	rename B DataLevel
	rename C StateAssignedDistID
	rename D DistName
	rename E StateAssignedSchID
	rename F SchName
	rename G GradeLevel
	rename H Subject
	rename I StudentSubGroup
	rename L ParticipationRate
	drop A J K
	
	//Data Levels
	drop if DataLevel == "LEVEL_CODE"
	replace SchName = "All Schools" if DataLevel != "SCH"
	replace DistName = "All Districts" if DataLevel == "STATE"
	
	//Grade Levels & Subjects
	drop if GradeLevel == "02"
	replace GradeLevel = substr(GradeLevel, 2, 2)
	drop if strpos(Subject, GradeLevel) == 0
	drop if GradeLevel == ""
	replace GradeLevel = "G0" + GradeLevel
	replace Subject = "ela"
	
	//StudentSubGroups
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiple Races"
	
	//StudentGroups
	gen StudentGroup = "RaceEth"
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
	replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
	replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
	
	//Participation Rate
	replace ParticipationRate = "*" if ParticipationRate == "<"
	destring ParticipationRate, gen(part) force
	replace part = part/100
	tostring part, replace format("%6.0g") force
	replace ParticipationRate = part if ParticipationRate != "<"
	
	drop part
	
	save "$participation/VA_Participation_`year'.dta", replace
}

//Math
forvalues year = 2016/2023{
	
	if `year' == 2020{
		continue
	}
	
	local prev_year = `year' - 1
	import excel "$participation/`prev_year'-`year' Participation.xlsx", sheet("Math") clear
	
	//Variable Names
	rename B DataLevel
	rename C StateAssignedDistID
	rename D DistName
	rename E StateAssignedSchID
	rename F SchName
	rename G GradeLevel
	rename H Subject
	rename I StudentSubGroup
	rename L ParticipationRate
	drop A J K
	
	//Data Levels
	drop if DataLevel == "LEVEL_CODE"
	replace SchName = "All Schools" if DataLevel != "SCH"
	replace DistName = "All Districts" if DataLevel == "STATE"
	
	//Grade Levels & Subjects
	drop if GradeLevel == "02"
	replace GradeLevel = substr(GradeLevel, 2, 2)
	drop if strpos(Subject, GradeLevel) == 0
	drop if GradeLevel == ""
	replace GradeLevel = "G0" + GradeLevel
	replace Subject = "math"
	
	//StudentSubGroups
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiple Races"
	
	//Participation Rate
	replace ParticipationRate = "*" if ParticipationRate == "<"
	destring ParticipationRate, gen(part) force
	replace part = part/100
	tostring part, replace format("%6.0g") force
	replace ParticipationRate = part if ParticipationRate != "<"
	
	drop part
	
	save "$participation/VA_Participation_`year'_math.dta", replace
}

//Writing
forvalues year = 2016/2023{
	
	if `year' == 2020{
		continue
	}
	
	local prev_year = `year' - 1
	import excel "$participation/`prev_year'-`year' Participation.xlsx", sheet("Writing") clear
	
	//Variable Names
	rename B DataLevel
	rename C StateAssignedDistID
	rename D DistName
	rename E StateAssignedSchID
	rename F SchName
	rename G GradeLevel
	rename H Subject
	rename I StudentSubGroup
	rename L ParticipationRate
	drop A J K
	
	//Data Levels
	drop if DataLevel == "LEVEL_CODE"
	replace SchName = "All Schools" if DataLevel != "SCH"
	replace DistName = "All Districts" if DataLevel == "STATE"
	
	//Grade Levels & Subjects
	drop if GradeLevel == "02"
	replace GradeLevel = substr(GradeLevel, 2, 2)
	drop if strpos(Subject, GradeLevel) == 0
	drop if GradeLevel == ""
	replace GradeLevel = "G0" + GradeLevel
	replace Subject = "wri"
	
	//StudentSubGroups
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiple Races"
	
	//Participation Rate
	replace ParticipationRate = "*" if ParticipationRate == "<"
	destring ParticipationRate, gen(part) force
	replace part = part/100
	tostring part, replace format("%6.0g") force
	replace ParticipationRate = part if ParticipationRate != "<"
	
	drop part
	
	save "$participation/VA_Participation_`year'_wri.dta", replace
}

//Science
forvalues year = 2016/2023{
	
	if `year' == 2020{
		continue
	}
	
	local prev_year = `year' - 1
	import excel "$participation/`prev_year'-`year' Participation.xlsx", sheet("Science") clear
	
	//Variable Names
	rename B DataLevel
	rename C StateAssignedDistID
	rename D DistName
	rename E StateAssignedSchID
	rename F SchName
	rename G GradeLevel
	rename H Subject
	rename I StudentSubGroup
	rename L ParticipationRate
	drop A J K
	
	//Data Levels
	drop if DataLevel == "LEVEL_CODE"
	replace SchName = "All Schools" if DataLevel != "SCH"
	replace DistName = "All Districts" if DataLevel == "STATE"
	
	//Grade Levels & Subjects
	replace Subject = "Grade 3 Science" if Subject == "Earth Science" & GradeLevel == "03"
	drop if GradeLevel == "02"
	replace GradeLevel = substr(GradeLevel, 2, 2)
	drop if strpos(Subject, GradeLevel) == 0
	drop if GradeLevel == ""
	replace GradeLevel = "G0" + GradeLevel
	replace Subject = "sci"
	
	//StudentSubGroups
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learners"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiple Races"
	
	//Participation Rate
	replace ParticipationRate = "*" if ParticipationRate == "<"
	destring ParticipationRate, gen(part) force
	replace part = part/100
	tostring part, replace format("%6.0g") force
	replace ParticipationRate = part if ParticipationRate != "<"
	
	drop part
	
	save "$participation/VA_Participation_`year'_sci.dta", replace
}

//Append & Clean
forvalues year = 2016/2023{
	
	if `year' == 2020{
		continue
	}
	
	use "$participation/VA_Participation_`year'.dta", clear
	append using "$participation/VA_Participation_`year'_math.dta" "$participation/VA_Participation_`year'_wri.dta" "$participation/VA_Participation_`year'_sci.dta"
	replace DataLevel = "School" if DataLevel == "SCH"
	replace DataLevel = "District" if DataLevel == "DIV"
	replace DataLevel = "State" if DataLevel == "STATE"
	destring StateAssignedDistID, replace
	destring StateAssignedSchID, replace
	save "$participation/VA_Participation_`year'.dta", replace
}

//Merge
forvalues year = 2016/2023{
	
	if `year' == 2020{
		continue
	}
	
	import delimited "$output/VA_AssmtData_`year'.csv", case(preserve) clear
	drop ParticipationRate
	merge 1:1 StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup using "$participation/VA_Participation_`year'.dta"
	replace ParticipationRate = "--" if _merge == 1
	drop if _merge == 2
	drop _merge
	
	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	save "$output/VA_AssmtData_`year'.dta", replace
	export delimited "$output/VA_AssmtData_`year'.csv", replace
}

