*******************************************************
* COLORADO

* File name: CO_2016
* Last update: 2/25/2025

*******************************************************
* Notes

	* This do file imports CO 2016 data, renames variables, cleans and saves it as a dta file.
	* NCES 2015 is merged with CO 2016 data. 
	* Only the usual output is created.
*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear all

*******************************************************
// Section 1: Appending Aggregate Data
*******************************************************
//Combines math/ela data with science data
//Imports and saves math/ela

import excel "$Original/2016/CO_OriginalData_2016_ela&mat.xlsx", sheet("ELA") cellrange(A5:X6776) firstrow case(lower) clear
rename numberdidnotyetmeetexpectat Lev1_count
rename didnotyetmeetexpectations Lev1_percent
rename numberpartiallymetexpectation Lev2_count
rename partiallymetexpectations Lev2_percent
rename numberapproachedexpectations Lev3_count
rename approachedexpectations Lev3_percent
rename numbermetexpectations Lev4_count
rename metexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename exceededexpectations Lev5_percent
save "${Temp}/CO_OriginalData_2016_ela.dta", replace


import excel "$Original/2016/CO_OriginalData_2016_ela&mat.xlsx", sheet("MATH") cellrange(A5:X7937) firstrow case(lower) clear
rename numberdidnotyetmeetexpectat Lev1_count
rename didnotyetmeetexpectations Lev1_percent
rename numberpartiallymetexpectation Lev2_count
rename partiallymetexpectations Lev2_percent
rename numberapproachedexpectations Lev3_count
rename approachedexpectations Lev3_percent
rename numbermetexpectations Lev4_count
rename metexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename exceededexpectations Lev5_percent
save "${Temp}/CO_OriginalData_2016_math.dta", replace
	
import excel "$Original/2016/CO_OriginalData_2016_sci.xlsx", sheet("District and School Detail_1") cellrange(A5:V2651) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename partiallymetexpectations Lev1_percent
rename numberapproachedexpectations Lev2_count
rename approachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename metexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename exceededexpectations Lev4_percent
save "${Temp}/CO_OriginalData_2016_sci.dta", replace

////Combines math/ela with science scores
append using "${Temp}/CO_OriginalData_2016_ela.dta"
append using "${Temp}/CO_OriginalData_2016_math.dta"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

drop numberoftotalrecords numberofnoscores 

rename level DataLevel
rename districtcode StateAssignedDistID
rename districtname DistName
rename schoolcode StateAssignedSchID
rename schoolname SchName
rename content Subject
rename test GradeLevel
rename numberofvalidscores StudentSubGroup_TotalTested
rename participationrate ParticipationRate
rename meanscalescore AvgScaleScore
rename numbermetorexceededexpectati ProficientOrAbove_count
rename metorexceededexpectations ProficientOrAbove_percent

save "${Temp}/CO_OriginalData_2016_all.dta", replace

*******************************************************
// Section 2: Preparing Disaggregate Data
*******************************************************
// ENGLISH/LANGUAGE ARTS

import excel "$Original/2016/CO_2016_ELA_gender.xlsx", sheet("Sheet 1") cellrange(A4:X13430) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename gender StudentSubGroup
gen StudentGroup = "Gender"
save "${Temp}/CO_2016_ELA_gender.dta", replace

import excel "$Original/2016/CO_2016_ELA_language.xlsx", sheet("Sheet1 1") cellrange(A4:X18849) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
save "${Temp}/CO_2016_ELA_language.dta", replace

import excel "$Original/2016/CO_2016_ELA_raceEthnicity.xlsx", sheet("Sheet1 1") cellrange(A4:X28164) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
save "${Temp}/CO_2016_ELA_raceEthnicity.dta", replace

import excel "$Original/2016/CO_2016_ELA_FreeReducedLunch.xlsx", sheet("Sheet 1") cellrange(A4:X13238) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"
save "${Temp}/CO_2016_ELA_econstatus.dta", replace

import excel "$Original/2016/CO_2016_ELA_migrant.xlsx", sheet("Sheet 1") cellrange(A4:X7858) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
save "${Temp}/CO_2016_ELA_migrantstatus.dta", replace

import excel "$Original/2016/CO_2016_ELA_individualEd.xlsx", sheet("Sheet 1") cellrange(A4:X12937) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename specialprogram StudentSubGroup
gen StudentGroup = "Disability Status"
save "${Temp}/CO_2016_ELA_disabilitystatus.dta", replace

// MATH
import excel "$Original/2016/CO_2016_mat_gender.xlsx", sheet("Sheet 1") cellrange(A4:X15545) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename gender StudentSubGroup
gen StudentGroup = "Gender"
save "${Temp}/CO_2016_mat_gender.dta", replace

import excel "$Original/2016/CO_2016_mat_language.xlsx", sheet("Sheet 1") cellrange(A4:X20888) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
save "${Temp}/CO_2016_mat_language.dta", replace

import excel "$Original/2016/CO_2016_mat_raceEthnicity.xlsx", sheet("Sheet 1") cellrange(A4:X31413) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
save "${Temp}/CO_2016_mat_raceEthnicity.dta", replace

import excel "$Original/2016/CO_2016_mat_FreeReducedLunch.xlsx", sheet("Sheet 1") cellrange(A4:X15207) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"
save "${Temp}/CO_2016_mat_econstatus.dta", replace

import excel "$Original/2016/CO_2016_mat_migrant.xlsx", sheet("Sheet 1") cellrange(A4:X9056) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
save "${Temp}/CO_2016_mat_migrantstatus.dta", replace

import excel "$Original/2016/CO_2016_mat_individualEd.xlsx", sheet("Sheet_1") cellrange(A4:X14365) firstrow case(lower) clear
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename specialprogram StudentSubGroup
gen StudentGroup = "Disability Status"
save "${Temp}/CO_2016_mat_disabilitystatus.dta", replace

// SCIENCE
import excel "$Original/2016/CO_2016_sci_gender.xlsx", sheet("Sheet 1") cellrange(A4:V5249) firstrow case(lower) clear
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent
rename gender StudentSubGroup
gen StudentGroup = "Gender"
save "${Temp}/CO_2016_sci_gender.dta", replace

import excel "$Original/2016/CO_2016_sci_language.xlsx", sheet("Sheet 1") cellrange(A4:V7323) firstrow case(lower) clear
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
save "${Temp}/CO_2016_sci_language.dta", replace

import excel "$Original/2016/CO_2016_sci_raceEthnicity.xlsx", sheet("Sheet 1") cellrange(A4:V10959) firstrow case(lower) clear
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent
rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
save "${Temp}/CO_2016_sci_raceEthnicity.dta", replace

import excel "$Original/2016/CO_2016_sci_FreeReducedLunch.xlsx", sheet("Sheet 1") cellrange(A4:V5175) firstrow case(lower) clear
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent
rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"
save "${Temp}/CO_2016_sci_econstatus.dta", replace

import excel "$Original/2016/CO_2016_sci_migrant.xlsx", sheet("Sheet 1") cellrange(A4:V3058) firstrow case(lower) clear
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
save "${Temp}/CO_2016_sci_migrantstatus.dta", replace

import excel "$Original/2016/CO_2016_sci_individualEd.xlsx", sheet("Sheet 1") cellrange(A4:V5029) firstrow case(lower) clear
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent
rename specialprogram StudentSubGroup
gen StudentGroup = "Disability Status"
save "${Temp}/CO_2016_sci_disabilitystatus.dta", replace

*******************************************************
// Section 3: Appending Disaggregate Data
*******************************************************
//Appends subgroups
append using "${Temp}/CO_2016_ELA_gender.dta"
append using "${Temp}/CO_2016_mat_gender.dta"
append using "${Temp}/CO_2016_sci_gender.dta"
append using "${Temp}/CO_2016_ELA_language.dta"
append using "${Temp}/CO_2016_mat_language.dta"
append using "${Temp}/CO_2016_sci_language.dta"
append using "${Temp}/CO_2016_ELA_raceEthnicity.dta"
append using "${Temp}/CO_2016_mat_raceEthnicity.dta"
append using "${Temp}/CO_2016_sci_raceEthnicity.dta"
append using "${Temp}/CO_2016_ELA_econstatus.dta"
append using "${Temp}/CO_2016_mat_econstatus.dta"
append using "${Temp}/CO_2016_sci_econstatus.dta"
append using "${Temp}/CO_2016_ELA_migrantstatus.dta"
append using "${Temp}/CO_2016_mat_migrantstatus.dta"
append using "${Temp}/CO_2016_sci_migrantstatus.dta"
append using "${Temp}/CO_2016_ELA_disabilitystatus.dta"
append using "${Temp}/CO_2016_mat_disabilitystatus.dta"

drop oftotalrecords 

rename level DataLevel
rename districtnumber StateAssignedDistID
rename districtname DistName
rename schoolnumber StateAssignedSchID
rename schoolname SchName
rename content Subject
rename test GradeLevel
rename ofvalidscores StudentSubGroup_TotalTested
rename participationrate ParticipationRate
rename meanscalescore AvgScaleScore

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename metorexceededexpectations ProficientOrAbove_count

append using "${Temp}/CO_OriginalData_2016_all.dta"

save "${Original_Cleaned}/CO_OriginalData_2016.dta", replace

*******************************************************
// Section 4: Merging NCES Variables
*******************************************************
// Merges district variables from NCES
use "${Original_Cleaned}/CO_OriginalData_2016.dta", clear
	
replace DataLevel = strtrim(DataLevel)
replace DataLevel = strproper(DataLevel)
replace DistName = strtrim(DistName)
replace DistName = strproper(DistName)
replace SchName = strtrim(SchName)
replace SchName = strproper(SchName)

replace StateAssignedDistID = "" if DataLevel == "State"
replace DistName = "All Districts" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel != "School"
gen State_leaid = StateAssignedDistID
	
merge m:1 State_leaid using "${NCES_CO}/NCES_2015_District_CO.dta"

drop if _merge == 2
drop _merge	

replace StateAssignedSchID = "" if DataLevel != "School"
gen seasch = StateAssignedSchID
	
merge m:1 seasch using "${NCES_CO}/NCES_2015_School_CO.dta"

drop if _merge == 2
drop _merge	

*******************************************************
// Section 5: Reformatting
*******************************************************
// Removing spaces
replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)

local level 1 2 3 4 5

foreach a of local level {
	replace Lev`a'_percent = strtrim(Lev`a'_percent)
	replace Lev`a'_count = strtrim(Lev`a'_count)
}

replace ProficientOrAbove_count = strtrim(ProficientOrAbove_count)
replace ProficientOrAbove_percent = strtrim(ProficientOrAbove_percent)

replace Subject = strtrim(Subject)
replace GradeLevel = strtrim(GradeLevel)
replace StudentSubGroup = strtrim(StudentSubGroup)

replace ParticipationRate = strtrim(ParticipationRate)
replace AvgScaleScore = strtrim(AvgScaleScore)

replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, " ", "", .)

//Converting levels
local level 1 2 3 4 5

foreach a of local level {
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2 if Lev`a'_percent2 != "."
	drop Lev`a'_percent2
	replace Lev`a'_percent = "*" if Lev`a'_percent == ""
	replace Lev`a'_count = "*" if Lev`a'_count == ""
}

destring ParticipationRate, gen(ParticipationRate2) force
replace ParticipationRate2 = ParticipationRate2/100
tostring ParticipationRate2, replace force
replace ParticipationRate = ParticipationRate2 if ParticipationRate2 != "."
drop ParticipationRate2

destring ProficientOrAbove_percent, gen(ProficientOrAbove_percent2) force
replace ProficientOrAbove_percent2 = ProficientOrAbove_percent2/100
tostring ProficientOrAbove_percent2, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "."
drop ProficientOrAbove_percent2

* Derive additional infomration where possible
destring Lev4_percent, gen(Lev4) force
destring ProficientOrAbove_percent, gen(prof_p) force
replace Lev5_percent = string(prof_p - Lev4) if Subject != "sci" & inlist(Lev5_percent, "*", "--") & !inlist(Lev4_percent, "*", "--") & !inlist(ProficientOrAbove_percent, "*", "--")

destring Lev4_count, gen(Lev4_c) force
destring ProficientOrAbove_count, gen(prof_c) force
replace Lev5_count = string(round(prof_c-Lev4_c)) if Subject != "sci" & inlist(Lev5_count, "*", "--") & !inlist(Lev4_count, "*", "--") & !inlist(ProficientOrAbove_count, "*", "--")

drop Lev4 prof_p Lev4_c prof_c

//	Create new variables
gen AssmtName = "Colorado Measures of Academic Success"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable"
gen Flag_CutScoreChange_sci = "N"
gen SchYear = "2015-16"

// Relabel variable values
tab Subject
replace Subject = "math" if Subject == "Mathematics" | Subject=="Math"
replace Subject = "ela" if Subject == "English Lanuage Arts" | Subject == "ELA"
replace Subject = "sci" if Subject == "Science"

gen ProficiencyCriteria = "Levels 3-4"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"

tab GradeLevel

drop if strpos(GradeLevel, "Algebra") | strpos(GradeLevel, "Geometry") | strpos(GradeLevel, "Integrated") | strpos(GradeLevel, "HS") | strpos(GradeLevel, "09") > 0

local grade 3 4 5 6 7 8
foreach a of local grade {
	replace GradeLevel = "G0`a'" if strpos(GradeLevel, "`a'") > 0
}

tab StudentSubGroup

drop if StudentSubGroup == "Unreported"

replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian/Pacific Islander"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "Unreported/ Not Applicable"

replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Not IEP"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"

//EL Groups Aggregation
tempfile temp1
save "`temp1'", replace
keep if StudentSubGroup == "FEP - Fluent English Proficient" | StudentSubGroup == "LEP - Limited English Proficient" | StudentSubGroup == "NEP - Non English Proficient" | StudentSubGroup == "PHLOTE/FELL/NA"

gen EL_Group = "English Learner" if StudentSubGroup == "LEP - Limited English Proficient" | StudentSubGroup == "NEP - Non English Proficient"
replace EL_Group = "English Proficient" if StudentSubGroup == "PHLOTE/FELL/NA" | StudentSubGroup == "FEP - Fluent English Proficient"

** Absolute Variables (Just need to add together)
sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
replace StateAssignedDistID = "--" if StateAssignedDistID == ""
replace StateAssignedSchID = "--" if StateAssignedSchID == ""
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel EL_Group)
foreach var of varlist StudentSubGroup_TotalTested *_count {
	destring `var', gen(n`var') force
	egen `var'_Agg = total(n`var'), by(DistName SchName Subject GradeLevel EL_Group)
	gen `var'_Miss = 1 if n`var' == .
	sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
	replace `var'_Miss = 1 if `var'_Miss[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
	replace `var'_Miss = 1 if `var'_Miss[_n-1] == 1 & uniquegrp == uniquegrp[_n-1]
	if `var' != StudentSubGroup_TotalTested{
		replace `var'_Agg = . if `var'_Miss == 1
	}
	drop `var'_Miss
}

** Adjusting StudentSubGroup_TotalTested
gen range = 1 if strpos(StudentSubGroup_TotalTested, "<16") !=0
sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
gen StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_Agg + 15 if range == . & range[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
replace StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_High[_n-1] if range == 1 & range[_n-1] == . & uniquegrp == uniquegrp[_n-1]
replace StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_Agg + 15 if range == . & range[_n-1] == 1 & uniquegrp == uniquegrp[_n-1]
replace StudentSubGroup_TotalTested_High = StudentSubGroup_TotalTested_High[_n+1] if range == 1 & range[_n+1] == . & uniquegrp == uniquegrp[_n+1]
replace range = 2 if range == 1 & range[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
replace range = 2 if range == 1 & range[_n-1] !=. & uniquegrp == uniquegrp[_n-1]

** Proportional Variables (Need to account for how many were tested in each group)
gen Prop = nStudentSubGroup_TotalTested/StudentSubGroup_TotalTested_Agg
replace Prop = . if StudentSubGroup_TotalTested_High != .
replace Prop = . if range == 2

foreach var of varlist ParticipationRate AvgScaleScore *_percent {
	gen n`var' = Prop * real(`var')
	egen `var'_Agg = total(n`var'), by(DistName SchName Subject GradeLevel EL_Group)
	gen `var'_Miss = 1 if n`var' == .
	sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
	replace `var'_Miss = 1 if `var'_Miss[_n+1] == 1 & uniquegrp == uniquegrp[_n+1]
	replace `var'_Miss = 1 if `var'_Miss[_n-1] == 1 & uniquegrp == uniquegrp[_n-1]
	replace `var'_Agg = . if `var'_Miss == 1
	drop `var'_Miss
}

** Replace Values
drop n*
foreach var of varlist *_count *_percent ParticipationRate AvgScaleScore {
	drop `var'
	rename `var'_Agg `var'
	tostring `var', replace format("%9.3g") force
	replace `var' = "*" if `var' == "0" | `var' == "."
}

replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested_Agg) if StudentSubGroup_TotalTested_High == . & range == .
replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested_Agg) + "-" + string(StudentSubGroup_TotalTested_High) if StudentSubGroup_TotalTested_High != .
replace StudentSubGroup_TotalTested = "0-30" if range == 2
drop StudentSubGroup_TotalTested_Agg StudentSubGroup_TotalTested_High range

** Check for Proper Aggregation
sort DataLevel DistName SchName Subject GradeLevel EL_Group StudentSubGroup
egen uniquegrp1 = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel EL_Group StudentSubGroup_TotalTested ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate AvgScaleScore)
tab DataLevel if uniquegrp != uniquegrp1
drop uniquegrp uniquegrp1

** Cleaning Up
replace StateAssignedSchID = "" if StateAssignedSchID == "--"
replace StateAssignedDistID = "" if StateAssignedDistID == "--"

drop StudentSubGroup Prop
rename EL_Group StudentSubGroup
sort DataLevel DistName SchName Subject GradeLevel StudentSubGroup
duplicates drop DistName SchName Subject GradeLevel StudentSubGroup, force
tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "0-15" if StudentSubGroup_TotalTested == "0"
append using "`temp1'"
drop if StudentSubGroup == "LEP - Limited English Proficient" | StudentSubGroup == "NEP - Non English Proficient" | StudentSubGroup == "PHLOTE/FELL/NA"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "FEP - Fluent English Proficient" 

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "0-15" if strpos(StudentSubGroup_TotalTested, "<16") !=0 | strpos(StudentSubGroup_TotalTested, "< 16") !=0
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

//StudentGroup_TotalTested

*Standardize Names for Proper Grouping
replace SchName = "Bennett Elementary School" if StateAssignedSchID == "0770" & StateAssignedDistID == "0050"
replace SchName = "Centennial Academy Of Fine Arts Education" if StateAssignedSchID == "1382" & StateAssignedDistID == "0140"
replace SchName = "Talbott Elementary School" if StateAssignedSchID == "4346" & StateAssignedDistID == "0990"

*Generate Values
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

////
replace Lev5_percent = "" if Subject == "sci"
replace Lev5_count = "" if Subject == "sci"

replace StateAbbrev = "CO" if DataLevel == "State"
replace State = "Colorado" if DataLevel == "State"
replace StateFips = 8 if DataLevel == "State"

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace SchName = "Pueblo Youth Service Center" if NCESSchoolID == "080612006350"
replace SchName = "Mountview Youth Service Center" if NCESSchoolID == "080480006347"
replace SchName = "Adams Youth Service Center" if NCESSchoolID == "080258006343"
replace SchName = "Spring Creek Youth Services Center" if NCESSchoolID == "080453006342"
replace SchName = "Platte Valley Youth Services Center" if NCESSchoolID == "080441006355"

//Cleaning EL Groups more
replace StudentSubGroup_TotalTested = "0-15" if StudentSubGroup_TotalTested == "0" & (StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient")

foreach var of varlist *_count *_percent ParticipationRate AvgScaleScore {
	replace `var' = "*" if `var' == "0" & StudentSubGroup_TotalTested == "0-15" & (StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient")
}


//Deriving StudentSubGroup_TotalTested where suppressed
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited"
drop Unsuppressed*

*******************************************************
*Derivations [0 real changes made]
*******************************************************
//Deriving Additional Information
forvalues n = 1/5{
	replace Lev`n'_count = string(round(real(Lev`n'_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev`n'_percent)) & missing(real(Lev`n'_count))
}

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent)) & missing(real(ProficientOrAbove_count))

//Removing "Empty" Observations for Subgroups
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace SchName = stritrim(SchName)

** Standardize Names
replace DistName = strproper(DistName)
replace DistName = "Moffat County Re: No 1" if NCESDistrictID == "0805730"
replace DistName = "St Vrain Valley Re1J" if NCESDistrictID == "0805370"
replace DistName = "Weld Re-8 Schools" if NCESDistrictID == "0804020"
replace DistName = "Meeker Re-1" if NCESDistrictID == "0805610"
replace DistName = "McClave Re-2" if NCESDistrictID == "0805580"
replace DistName = "Weld Re-4" if NCESDistrictID == "0807350"
replace DistName = "Elizabeth School District" if NCESDistrictID == "0803720"

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output*
save "${Output}/CO_AssmtData_2016", replace
export delimited "${Output}/CO_AssmtData_2016", replace
* END of CO_2016.do
****************************************************
