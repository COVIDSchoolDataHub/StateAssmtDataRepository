clear
set more off
global Original "/Users/miramehta/Documents/Montana/Original"
global Output "/Users/miramehta/Documents/Montana/Output"

//Combining
local Grades "4 8"

foreach Data in AllStudents AllStudents_Participation {
	tempfile temp1
	save "`temp1'", emptyok replace
	foreach grade of local Grades {
	foreach Subject in ELA Math {
		import excel "$Original/MT_State_`Subject'_G`grade'_`Data'.xlsx", cellrange(A3) firstrow clear
		rename SchoolYear SchYear
		if "`Data'" == "AllStudents" {
			rename AdvancedStudents Lev4_count
			rename AdvancedPercent Lev4_percent
			rename ProficientStudents Lev3_count
			rename ProficientPercent Lev3_percent
			rename NearingProficiencyStudents Lev2_count
			rename NearingProficientPercent Lev2_percent
			rename NovicePercent Lev1_percent
			rename NoviceStudents Lev1_count
		}
		if "`Data'" == "AllStudents_Participation" {
			rename PercentAssessed ParticipationRate
			rename StudentsTested StudentSubGroup_TotalTested
			drop PercentNotAssessed StudentsNotTested
		}
		gen GradeLevel = "`grade'"
		gen Subject = "`Subject'"
		append using "`temp1'"
		save "`temp1'", replace
		clear
	}
}
use "`temp1'"
save "${Original}/`Data'_ELA_Math", replace
clear
}

use "$Original/AllStudents_ELA_Math.dta", clear
merge 1:1 GradeLevel Subject using "$Original/AllStudents_Participation_ELA_Math.dta"
drop _merge

//SchYear
replace SchYear = "2023-24"

//Performance & Participation Information
gen ProficientOrAbove_count = Lev3_count + Lev4_count
gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent

foreach var of varlist *_count{
	tostring `var', replace
}

foreach var of varlist *_percent ParticipationRate {
	tostring `var', replace format("%9.3g") force
}

tostring StudentSubGroup_TotalTested, replace

gen Lev5_count = ""
gen Lev5_percent = ""

//GradeLevel
replace GradeLevel = "G0" + GradeLevel

//Subject
replace Subject = lower(Subject)

//Indicator Variables
gen DistName = "All Districts"
gen SchName = "All Schools"
gen AssmtName = "Smarter Balanced Assessment"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "Not applicable"
gen DataLevel = "State"
gen State = "Montana"
gen StateFips = 30
gen StateAbbrev = "MT"
gen StudentSubGroup = "All Students"
gen StudentGroup = "All Students"
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested

//Empty Variables
gen DistType = ""
gen SchType = ""
gen NCESDistrictID = ""
gen StateAssignedDistID = ""
gen State_leaid = ""
gen NCESSchoolID = ""
gen StateAssignedSchID = ""
gen seasch = ""
gen DistCharter = ""
gen SchLevel = ""
gen SchVirtual = ""
gen CountyName = ""
gen CountyCode =""
gen DistLocale = ""
gen AvgScaleScore = "--"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${Output}/All_State", replace
clear

//Append 2022 & 2023
import delimited "$Output/MT_AssmtData_2022.csv", delimiter(",") stringcols(9, 11, 17/47) case(preserve) clear
save "$Output/MT_AssmtData_2022.dta", replace

import delimited "$Output/MT_AssmtData_2023.csv", delimiter(",") stringcols(9, 11, 17/47) case(preserve) clear
append using "$Output/MT_AssmtData_2022.dta"

keep if DataLevel == "State"
keep if StudentSubGroup == "All Students"
keep if inlist(Subject, "ela", "math")
keep if inlist(GradeLevel, "G04", "G08")

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

tostring NCESDistrictID NCESSchoolID, replace
replace NCESDistrictID = ""
replace NCESSchoolID = ""

append using "${Output}/All_State"

sort SchYear DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/All_State", replace
export delimited "${Output}/MT_ED_Data_22_24.csv", replace
