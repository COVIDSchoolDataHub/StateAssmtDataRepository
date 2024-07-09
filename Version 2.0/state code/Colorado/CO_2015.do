clear
set more off

cd "/Volumes/T7/State Test Project/Colorado"

global path "/Volumes/T7/State Test Project/Colorado/Original Data Files"
global nces "/Volumes/T7/State Test Project/Colorado/NCES"
global output "/Volumes/T7/State Test Project/Colorado/Output"

//Importing & Renaming
/*
** All Students Data
import excel "${path}/CO_OriginalData_2015_ela&mat.xlsx", cellrange(A3) allstring sheet("Achievement Results") firstrow case(lower) clear
drop if missing(districtcode)
rename level DataLevel
rename districtcode StateAssignedDistID
rename districtname DistName
rename schoolcode StateAssignedSchID
rename schoolname SchName
rename year SchYear
rename contentarea Subject
rename test GradeLevel
drop numberoftotalrecords numberofnoscores
rename numberofvalidscores StudentSubGroup_TotalTested
rename participationrate ParticipationRate
rename meanscalescore AvgScaleScore
rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpecta Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectatio Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectations Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpecations Lev5_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent


save "${path}/CO_OriginalData_2015_ela&mat", replace

**Science Data
import excel "${path}/CO_OriginalData_2015_sci.xlsx", cellrange(A5) allstring clear
rename A Subject
rename B StateAssignedDistID
rename C DistName
rename D StateAssignedSchID
rename E SchName
rename F GradeLevel
drop G-U
rename V StudentSubGroup_TotalTested
drop W X
rename Y ParticipationRate
rename Z AvgScaleScore
rename AA Lev1_count
rename AB Lev1_percent
rename AC Lev2_count
rename AD Lev2_percent
rename AE Lev3_count
rename AF Lev3_percent
rename AG Lev4_count
rename AH Lev4_percent
rename AI ProficientOrAbove_count
rename AJ ProficientOrAbove_percent
drop AK
gen SchYear = "2014-2015"
gen DataLevel = ""
replace DataLevel = "State" if SchName == "STATE"
replace DataLevel = "District" if SchName == "DISTRICT"
replace DataLevel = "School" if SchName != "STATE" & SchName != "DISTRICT"

foreach var of varlist *_percent {
	replace `var' = string(real(`var')/100, "%9.3g") if !missing(real(`var'))
}


append using "${path}/CO_OriginalData_2015_ela&mat"
save "${path}/CO_OriginalData_2015_allstudents", replace
clear

**Soc Data
import excel "${path}/CO_OriginalData_2015_soc.xlsx", cellrange(A5) allstring clear
rename A Subject
rename B StateAssignedDistID
rename C DistName
rename D StateAssignedSchID
rename E SchName
rename F GradeLevel
drop G-U
rename V StudentSubGroup_TotalTested
drop W X
rename Y ParticipationRate
rename Z AvgScaleScore
rename AA Lev1_count
rename AB Lev1_percent
rename AC Lev2_count
rename AD Lev2_percent
rename AE Lev3_count
rename AF Lev3_percent
rename AG Lev4_count
rename AH Lev4_percent
rename AI ProficientOrAbove_count
rename AJ ProficientOrAbove_percent
drop AK
gen SchYear = "2014-2015"
gen DataLevel = ""
replace DataLevel = "State" if SchName == "STATE"
replace DataLevel = "District" if SchName == "DISTRICT"
replace DataLevel = "School" if SchName != "STATE" & SchName != "DISTRICT"

foreach var of varlist *_percent {
	replace `var' = string(real(`var')/100, "%9.3g") if !missing(real(`var'))
}
append using "${path}/CO_OriginalData_2015_allstudents"
save "${path}/CO_OriginalData_2015_allstudents", replace

** SubGroup Data
clear
tempfile temp1
save "`temp1'", replace emptyok
foreach s in ela mat {
	foreach sg in FreeReducedLunch raceEthnicity gender individualEd language migrant {
		import excel "$path/CO_2015_`s'_`sg'.xlsx", cellrange(A4) allstring clear
		foreach var of varlist _all {
		replace `var' = trim(`var')
		replace `var' = stritrim(`var')
		}
		rename A StateAssignedDistID
		rename B DistName
		rename C StateAssignedSchID
		rename D SchName
		rename E GradeLevel
		rename F StudentSubGroup
		rename G StudentSubGroup_TotalTested
		rename H ProficientOrAbove_percent
		gen Subject = "`s'"
		gen DataLevel = ""
		replace DataLevel = "District" if SchName == "ALL SCHOOLS"
		replace DataLevel = "School" if missing(DataLevel)
		
		foreach var of varlist *_percent {
		replace `var' = string(real(`var')/100, "%9.3g") if !missing(real(`var'))
		}
		drop if strlen(StateAssignedDistID) > 10
		
		append using "`temp1'"
		save "`temp1'", replace
	}
}
		
use "`temp1'"
save "${path}/CO_OriginalData_2015_subgroups", replace
append using "${path}/CO_OriginalData_2015_allstudents"
drop if strlen(StateAssignedDistID) > 10
recast str5 StateAssignedDistID
save "${path}/CO_OriginalData_2015", replace
*/


use "${path}/CO_OriginalData_2015", clear
order SchYear DataLevel StateAssignedDistID DistName StateAssignedSchID SchName Subject GradeLevel StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate AvgScaleScore

//SchYear
replace SchYear = "2014-15"

//DataLevel
replace DataLevel = proper(DataLevel)
replace DataLevel = "District" if strpos(DataLevel, "Dist") !=0
replace DataLevel = "School" if strpos(DataLevel, "Sch") !=0
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
order DataLevel
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Subject
replace Subject = lower(Subject)
replace Subject = "math" if Subject == "mat"
replace Subject = "soc" if Subject == "ss"

//GradeLevel
keep if real(substr(GradeLevel, -2,2)) >= 3 & real(substr(GradeLevel, -2,2)) <= 8
replace GradeLevel = "G" + substr(GradeLevel, -2,2)

//StudentSubGroup
replace StudentSubGroup = "All Students" if missing(StudentSubGroup)
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Pacific Islander"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Multiracial"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Not Reported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"
replace StudentSubGroup="White" if StudentSubGroup=="White"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="American Indian"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-IEP"
replace StudentSubGroup="English Learner" if StudentSubGroup=="English Learner (Not English Proficient/Limited English Proficient)**"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="Non-English Learner***"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Free/Reduced Lunch Eligible"

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "0-15" if strpos(StudentSubGroup_TotalTested, "<16") | strpos(StudentSubGroup_TotalTested, "< 16") !=0
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

//Counts and Percents ranges
foreach var of varlist *_count *_percent {
	replace `var' = subinstr(`var', "=", "",.)
	replace `var' = subinstr(`var', "%", "",.)
}

foreach percent of varlist *_percent {
	gen range`percent' = substr(`percent',1,1) if regexm(`percent', "[<>]") !=0
	replace `percent' = subinstr(`percent', range`percent', "",.)
	replace `percent' = string(real(`percent')/100, "%9.3g") if !missing(range`percent') & !missing(real(`percent'))
	replace `percent' = `percent' + "-1" if range`percent' == ">"
	replace `percent' = "0-" + `percent' if range`percent' == "<"
	local count = subinstr("`percent'", "percent", "count",.)
	gen range`count' = substr(`count',1,1) if regexm(`count', "[<>]") !=0
	replace `count' = subinstr(`count', range`count',"",.)
	replace `count' = "0-" + `count' if range`count' == "<"
	replace `count' = `count' + "-" + StudentSubGroup_TotalTested if !missing(real(StudentSubGroup_TotalTested)) & range`count' == ">"
}
drop range*

foreach var of varlist *_count *_percent {
	replace `var' = subinstr(`var', " ", "",.)
	replace `var' = "--" if missing(`var') | `var' == "-"
}

replace Lev5_count = "" if Subject == "sci" | Subject == "soc"
replace Lev5_percent = "" if Subject == "sci" | Subject == "soc"

//ParticipationRate & AvgScaleScore
replace ParticipationRate = string(real(ParticipationRate), "%9.3g") if !missing(real(ParticipationRate))
replace ParticipationRate = "--" if missing(ParticipationRate) | ParticipationRate == "-"

replace AvgScaleScore = "--" if missing(real(AvgScaleScore))

//Converting NA's
foreach var of varlist Lev* StudentSubGroup_TotalTested ProficientOrAbove* ParticipationRate {
	replace `var' = "--" if `var' == "NA"
}

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner" | StudentSubGroup == "EL Monit or Recently Ex" | StudentSubGroup == "EL Exited"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"
order DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

//NCES Merging
foreach var of varlist StateAssigned* {
replace `var' = string(real(`var'), "%04.0f") if !missing(`var')
}
replace StateAssignedDistID = "0190" if SchName == "COLORADO VIRTUAL ACADEMY (COVA)" 
replace StateAssignedDistID = "0980" if SchName == "SPRING CREEK YOUTH SERVICES CENTER"
gen State_leaid = StateAssignedDistID
gen seasch = StateAssignedSchID

merge m:1 State_leaid using "$nces/NCES_2014_District_CO", gen(DistMerge)
merge m:1 seasch using "$nces/NCES_2014_School_CO", gen(SchMerge)
drop if DistMerge == 2 | SchMerge == 2
drop if SchName == "PIKES PEAK BOCES" | DistName  == "PIKES PEAK BOCES"

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving StudentSubGroup_TotalTested where suppressed
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited"
drop Unsuppressed*

//Indicator Variables
replace State = "Colorado"
replace StateAbbrev = "CO"
replace StateFips = 8

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="Y"
gen Flag_CutScoreChange_math="Y"
gen Flag_CutScoreChange_sci="N"
gen Flag_CutScoreChange_soc="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 4-5"
replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci" | Subject == "soc"

//Response to review
drop if SchName=="FAMILY EDUCATION NETWORK OF WELD CO" & StateAssignedSchID=="6169"
replace DistName = "BYERS 32J" if NCESDistrictID == "0802700"
replace DistName = "HARRISON 2" if NCESDistrictID == "0804530"

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent)) & missing(real(ProficientOrAbove_count))

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
replace CountyName = proper(CountyName)
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2015", replace
export delimited "${output}/CO_AssmtData_2015", replace








