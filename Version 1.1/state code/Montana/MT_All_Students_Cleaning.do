clear
set more off
local Original "/Volumes/T7/State Test Project/Montana/Original"
local Output "/Volumes/T7/State Test Project/Montana/Output" 

//Combining
local Grades "3 4 5 6 7 8 3-8"

foreach Data in Levels PartRate PercentProf {

tempfile temp1
save "`temp1'", emptyok replace
foreach grade of local Grades {
	foreach Subject in ELA Math {
		import delimited "`Original'/Montana `grade' `Subject' 2015-2023 `Data'", varnames(1) case(preserve) stringcols(_all)
		rename SchoolYear SchYear
		if "`Data'" == "Levels" {
			rename AdvancedStudents Lev4_count
			rename AdvancedPercent Lev4_percent
			rename ProficientStudents Lev3_count
			rename ProficientPercent Lev3_percent
			rename NearingProficiencyStudents Lev2_count
			rename NearingProficientPercent Lev2_percent
			rename NovicePercent Lev1_percent
			rename NoviceStudents Lev1_count
		}
		if "`Data'" == "PartRate" {
			rename PercentAssessed ParticipationRate
			rename StudentsTested StudentSubGroup_TotalTested
		}
		if "`Data'" == "PercentProf" {
			rename PercentAtOrAboveProficient ProficientOrAbove_percent
		}
		gen GradeLevel = "`grade'"
		gen Subject = "`Subject'"
		append using "`temp1'"
		save "`temp1'", replace
		clear
	}
}
use "`temp1'"
save "`Original'/`Data'_ELA_Math", replace
clear
}

local Grades "5 8 5_8"
foreach Data in Levels PartRate {
tempfile temp1
save "`temp1'", emptyok replace
foreach grade of local Grades {
	import delimited "`Original'/Montana `grade' Science 2015-2023 `Data'", varnames(1) case(preserve) stringcols(_all)
	rename SchoolYear SchYear
		if "`Data'" == "Levels" {
			rename AdvancedStudents Lev4_count
			rename AdvancedPercent Lev4_percent
			rename ProficientStudents Lev3_count
			rename ProficientPercent Lev3_percent
			rename NearingProficientStudents Lev2_count
			rename NearingProficientPercent Lev2_percent
			rename NovicePercent Lev1_percent
			rename NoviceStudents Lev1_count
		}
		if "`Data'" == "PartRate" {
			rename PercentAssessed ParticipationRate
			rename NumberAssessed StudentSubGroup_TotalTested
		}
	gen GradeLevel = "`grade'"
	gen Subject = "Science"
	append using "`temp1'"
	save "`temp1'", replace
	clear
}
use "`temp1'"
save "`Original'/`Data'_Science", replace
clear	
}
use "`Original'/Levels_ELA_Math"
append using "`Original'/Levels_Science"
save "`Original'/Levels", replace
clear
use "`Original'/PartRate_ELA_Math"
append using "`Original'/PartRate_Science"
save "`Original'/PartRate", replace
clear
use "`Original'/PercentProf_ELA_Math"
save "`Original'/PercentProf", replace
clear

//Merging
use "`Original'/Levels"
merge 1:1 GradeLevel Subject SchYear using "`Original'/PartRate", nogen
merge 1:1 GradeLevel Subject SchYear using "`Original'/PercentProf", nogen

//SchYear
replace SchYear = substr(SchYear, 1,4) + "-" + substr(SchYear,-2,2)
drop if SchYear == "2019-20"

//Cleaning Percents
foreach var of varlist Lev*_percent ParticipationRate ProficientOrAbove_percent {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}
replace ProficientOrAbove_percent = string((nLev3_percent + nLev4_percent)/100, "%9.3g") if Subject == "Science"

//GradeLevel
replace GradeLevel = "38" if GradeLevel == "3-8"
replace GradeLevel = "38" if GradeLevel == "5_8"
replace GradeLevel = "G0" + GradeLevel if GradeLevel != "38"
replace GradeLevel = "G" + GradeLevel if GradeLevel == "38"

//Subject
replace Subject = lower(Subject)
replace Subject = "sci" if strpos(Subject, "sci") !=0

//ProficientOrAbove_count
foreach n in 1 2 3 4 {
	destring Lev`n'_count, gen(nLev`n'_count)
}
gen ProficientOrAbove_count = nLev3_count + nLev4_count

//Indicator Variables
gen DistName = "All Districts"
gen SchName = "All Schools"
gen AssmtName = "Smarter Balanced Assessment"
gen ProficiencyCriteria = "Levels 3-4"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
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
gen CountyCode =.
gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "`Output'/All", replace
clear

//Seperating SchYear, exporting and saving
forvalues year = 2015/2023 {
use "`Output'/All"
local prevyear =`=`year'-1'	
if `year' == 2020 continue
keep if "`year'" == substr(SchYear,1,2) + substr(SchYear, -2,2)
save "`Output'/MT_AssmtData_`year'", replace
export delimited "`Output'/MT_AssmtData_`year'", replace
clear
}
	



