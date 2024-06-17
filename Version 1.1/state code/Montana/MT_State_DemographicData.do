clear
set more off
set trace off

local Original "/Volumes/T7/State Test Project/Montana/Original/Montana state-level data downloads"
local Output "/Volumes/T7/State Test Project/Montana/Output"

//Importing and Combining

tempfile temp1
save "`temp1'", replace emptyok
foreach Subject in ELA Math {
	forvalues n = 3/8 {
		foreach sg in American_Indian_Or_Alaskan_Native Asian Black_or_African_American Economically_Disadvantaged EL Female Hispanic Male Multi-Racial Native_Hawaiian_or_Other_Pacific_Islander NonEL Not_Economically_Disadvantaged White {
		import excel "`Original'/MT_`Subject'_Gr`n'_`sg'"
		drop in 1/2
		foreach var of varlist _all {
		replace `var' = subinstr(`var'," ", "",.) if _n==1
		local newname = `var'[1]
		rename `var' `newname'

		}
	drop in 1
	if "`sg'" == "Economically_Disadvantaged" | "`sg'" == "Not_Economically_Disadvantaged" replace StudentSubGroup = "`sg'"
	append using "`temp1'"
	save "`temp1'", replace
	clear
		}
	}
}
use "`temp1'"
save "`Original'/Combined", replace
use "`Original'/Combined"

//Renaming
rename SchoolYear SchYear
rename AdvancedStudents Lev4_count
rename AdvancedPercent Lev4_percent
rename ProficientStudents Lev3_count
rename ProficientPercent Lev3_percent
rename NearingProficiencyStudents Lev2_count
rename NearingProficientPercent Lev2_percent
rename NovicePercent Lev1_percent
rename NoviceStudents Lev1_count
rename Grade GradeLevel
rename Assessment AssmtName
drop if SchYear == "2019-2020"
replace StudentGroup = StudentGroup2 if missing(StudentGroup)
drop StudentGroup2 

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "_", " ",.)
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Indian") !=0
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Racial") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "Not Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More" | StudentSubGroup == "Unknown"

//Cleaning Percents
foreach n in 1 2 3 4 {
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*)
	destring Lev`n'_count, gen(nLev`n'_count) i(*)
	replace Lev`n'_percent = string(nLev`n'_percent, "%9.3g") if !missing(nLev`n'_percent)
}
replace Lev3_percent = "0" if missing(Lev3_percent)
replace Lev4_percent = "0" if missing(Lev4_percent)
replace Lev3_count = "0" if missing(Lev3_count)
replace Lev4_count = "0" if missing(Lev4_count)
replace nLev4_percent = 1-nLev3_percent-nLev2_percent-nLev1_percent if missing(nLev4_percent)
replace Lev4_percent = string(nLev4_percent, "%9.3g") if nLev4_percent > 0.0001 & !regexm(Lev4_percent, "[0-9]")
replace Lev4_percent = "*" if Lev4_percent == "."

//ProficientOrAbove Count and Percent, StudentSubGroup_TotalTested
gen ProficientOrAbove_percent = string(nLev3_percent + nLev4_percent, "%9.3g") if !missing(nLev3_percent) & !missing(nLev4_percent)
replace ProficientOrAbove_percent = "*" if missing(ProficientOrAbove_percent)
gen ProficientOrAbove_count = string(nLev3_count + nLev4_count) if !missing(nLev3_count) & !missing(nLev4_count)
replace ProficientOrAbove_count = "*" if missing(ProficientOrAbove_count)
gen StudentSubGroup_TotalTested = nLev1_count + nLev2_count + nLev3_count + nLev4_count if !missing(nLev1_count) & !missing(nLev2_count) & !missing(nLev3_count) & !missing(Lev4_count)

//StudentGroup_TotalTested
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(SchYear Subject Grade StudentGroup)

tostring StudentSubGroup_TotalTested, replace
tostring StudentGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."

//Subject
replace Subject = lower(Subject)

//GradeLevel
replace GradeLevel = "G0" + GradeLevel 

//Indicator Variables
gen DistName = "All Districts"
gen SchName = "All Schools"
replace AssmtName = "Smarter Balanced Assessment"
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
replace SchYear = substr(SchYear, 1,4) + "-" + substr(SchYear,-2,2)

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
gen Lev5_percent = ""
gen Lev5_count = ""
gen AvgScaleScore = "--"
gen ParticipationRate = "--"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Integrating Counts
duplicates drop SchYear Subject GradeLevel StudentSubGroup, force
tempfile temp1
save "`temp1'", replace
clear
import excel "${Original}/MT_participation counts", clear firstrow case(preserve) allstring
rename Year SchYear
replace SchYear = string(real(SchYear)-1) + "-" + substr(SchYear,-2,2)
drop PercentAssessed PercentNotAssessed StudentsNotTested Assessment StudentGroup
replace ParticipationRate = string(real(ParticipationRate), "%9.3g")
rename ParticipationRate ParticipationRate1
merge 1:1 SchYear Subject GradeLevel StudentSubGroup using "`temp1'", nogen
replace StudentSubGroup_TotalTested = StudentsTested if !missing(StudentsTested)
replace ParticipationRate = ParticipationRate1 if !missing(ParticipationRate1)
save "`Output'/AllDemo_State", replace
clear

//Seperating by Year, Appending
forvalues year = 2016/2023 {
use "`Output'/AllDemo_State"	
local prevyear =`=`year'-1'	
if `year' == 2020 continue
keep if "`year'" == substr(SchYear,1,2) + substr(SchYear, -2,2)

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/MT_AssmtData_`year'_StateDemo", replace
clear
}






