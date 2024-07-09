clear all
set more off

cd "/Volumes/T7/State Test Project/Colorado"

global path "/Volumes/T7/State Test Project/Colorado/Original Data Files"
global nces "/Volumes/T7/State Test Project/Colorado/NCES"
global output "/Volumes/T7/State Test Project/Colorado/Output"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela


import excel "${path}/CO_OriginalData_2019_ela&mat.xlsx", sheet("CMAS ELA and Math") cellrange(A12:AC15883) firstrow case(lower) clear

	//drops unneccesary variables from 2018 records used for comparison.  

rename subject Subject
rename grade GradeLevel
rename numberdidnotyetmeetexpectat Lev1_count
rename percentdidnotyetmeetexpecta Lev1_percent
rename numberpartiallymetexpectation Lev2_count
rename percentpartiallymetexpectatio Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectations Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent

	
drop n aa ab ac

save "${output}/CO_OriginalData_2019_ela&mat.dta", replace


	//imports and saves sci
	
import excel "${path}/CO_OriginalData_2019_sci.xlsx", sheet("CMAS Science") cellrange(A12:Z4717) firstrow case(lower) clear

rename grade GradeLevel
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent


drop m x y z
gen Subject="sci"


save "${output}/CO_OriginalData_2019_sci.dta", replace



	////Combines math/ela with science scores
	
use "${output}/CO_OriginalData_2019_ela&mat.dta", clear
append using "${output}/CO_OriginalData_2019_sci.dta"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

drop numberoftotalrecords numberofnoscores standarddeviation

rename level DataLevel
rename districtcode StateAssignedDistID
rename districtname DistName
rename schoolcode StateAssignedSchID
rename schoolname SchName
rename numberofvalidscores StudentSubGroup_TotalTested
rename participationrate ParticipationRate
rename meanscalescore AvgScaleScore
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent

save "${output}/CO_OriginalData_2019_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS
	
import excel "${path}/2019 CMAS ELA Disaggregated District and School Achievement Results.xlsx", sheet("Gender") cellrange(A11:Y15742) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen Subject="ela"

save "${output}/CO_2019_ELA_gender.dta", replace



import excel "${path}/2019 CMAS ELA Disaggregated District and School Achievement Results.xlsx", sheet("Language Proficiency") cellrange(A11:Y36861) firstrow case(lower) clear


rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen Subject="ela"

save "${output}/CO_2019_ELA_language.dta", replace


import excel "${path}/2019 CMAS ELA Disaggregated District and School Achievement Results.xlsx", sheet("Race Ethnicity") cellrange(A11:Y34835) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen Subject="ela"

save "${output}/CO_2019_ELA_raceEthnicity.dta", replace


import excel "${path}/2019 CMAS ELA Disaggregated District and School Achievement Results.xlsx", sheet("Free Reduced Lunch") cellrange(A11:Y15622) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen Subject="ela"

save "${output}/CO_2019_ELA_econstatus.dta", replace

import excel "${path}/2019 CMAS ELA Disaggregated District and School Achievement Results.xlsx", sheet("Migrant") cellrange(A11:Y9272) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen Subject="ela"

save "${output}/CO_2019_ELA_migrantstatus.dta", replace

import excel "${path}/2019 CMAS ELA Disaggregated District and School Achievement Results.xlsx", sheet("IEP") cellrange(A11:Y15422) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen Subject="ela"

save "${output}/CO_2019_ELA_disabilitystatus.dta", replace

	//// MATH


import excel "${path}/2019 CMAS Math Disaggregated District and School Achievement Results.xlsx", sheet("Gender") cellrange(A11:Y15741) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen Subject="math"

save "${output}/CO_2019_mat_gender.dta", replace



import excel "${path}/2019 CMAS Math Disaggregated District and School Achievement Results.xlsx", sheet("Language Proficiency") cellrange(A11:Y36922) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen Subject="math"

save "${output}/CO_2019_mat_language.dta", replace



import excel "${path}/2019 CMAS Math Disaggregated District and School Achievement Results.xlsx", sheet("Race Ethnicity") cellrange(A11:Y34833) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen Subject="math"

save "${output}/CO_2019_mat_raceEthnicity.dta", replace



import excel "${path}/2019 CMAS Math Disaggregated District and School Achievement Results.xlsx", sheet("Free Reduced Lunch") cellrange(A11:Y15622) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen Subject="math"

save "${output}/CO_2019_mat_econstatus.dta", replace

import excel "${path}/2019 CMAS Math Disaggregated District and School Achievement Results.xlsx", sheet("Migrant") cellrange(A11:Y9299) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen Subject="math"

save "${output}/CO_2019_mat_migrantstatus.dta", replace

import excel "${path}/2019 CMAS Math Disaggregated District and School Achievement Results.xlsx", sheet("IEP") cellrange(A11:Y15424) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename percentdidnotyetmeetexpec Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename percentpartiallymetexpectat Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectation Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpectations Lev5_percent
rename numbermetorexceededexpecta ProficientOrAbove_count
rename percentmetorexceededexpect ProficientOrAbove_percent
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen Subject="math"

save "${output}/CO_2019_mat_disabilitystatus.dta", replace


	//// SCIENCE
	
	
import excel "${path}/2019 CMAS Science Disaggregated District and School Achievement Results.xlsx", sheet("Gender") cellrange(A11:W9343) firstrow case(lower) clear
	

rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen Subject="sci"

save "${output}/CO_2019_sci_gender.dta", replace



import excel "${path}/2019 CMAS Science Disaggregated District and School Achievement Results.xlsx", sheet("Language Proficiency") cellrange(A11:W21613) firstrow case(lower) clear


rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen Subject="sci"

save "${output}/CO_2019_sci_language.dta", replace



import excel "${path}/2019 CMAS Science Disaggregated District and School Achievement Results.xlsx", sheet("Race Ethnicity") cellrange(A11:W20325) firstrow case(lower) clear


rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen Subject="sci"

save "${output}/CO_2019_sci_raceEthnicity.dta", replace


import excel "${path}/2019 CMAS Science Disaggregated District and School Achievement Results.xlsx", sheet("Free Reduced Lunch") cellrange(A11:W9266) firstrow case(lower) clear

rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen Subject="sci"

save "${output}/CO_2019_sci_econstatus.dta", replace

import excel "${path}/2019 CMAS Science Disaggregated District and School Achievement Results.xlsx", sheet("Migrant") cellrange(A11:W5430) firstrow case(lower) clear

rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen Subject="sci"

save "${output}/CO_2019_sci_migrantstatus.dta", replace

import excel "${path}/2019 CMAS Science Disaggregated District and School Achievement Results.xlsx", sheet("IEP") cellrange(A11:W9135) firstrow case(lower) clear

rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen Subject="sci"

save "${output}/CO_2019_sci_disabilitystatus.dta", replace


///////// Section 3: Appending Disaggregate Data

	//Appends subgroups
	
append using "${output}/CO_2019_ELA_gender.dta"
append using "${output}/CO_2019_mat_gender.dta"
append using "${output}/CO_2019_sci_gender.dta"
append using "${output}/CO_2019_ELA_language.dta"
append using "${output}/CO_2019_mat_language.dta"
append using "${output}/CO_2019_sci_language.dta"
append using "${output}/CO_2019_ELA_raceEthnicity.dta"
append using "${output}/CO_2019_mat_raceEthnicity.dta"
append using "${output}/CO_2019_sci_raceEthnicity.dta"
append using "${output}/CO_2019_ELA_econstatus.dta"
append using "${output}/CO_2019_mat_econstatus.dta"
append using "${output}/CO_2019_sci_econstatus.dta"
append using "${output}/CO_2019_ELA_migrantstatus.dta"
append using "${output}/CO_2019_mat_migrantstatus.dta"
append using "${output}/CO_2019_sci_migrantstatus.dta"
append using "${output}/CO_2019_ELA_disabilitystatus.dta"
append using "${output}/CO_2019_mat_disabilitystatus.dta"

drop numberoftotalrecords numberofnoscores standarddeviation

rename level DataLevel
rename districtcode StateAssignedDistID
rename districtname DistName
rename schoolcode StateAssignedSchID
rename schoolname SchName
rename grade GradeLevel
rename numberofvalidscores StudentSubGroup_TotalTested
rename participationrate ParticipationRate
rename meanscalescore AvgScaleScore

append using "${output}/CO_OriginalData_2019_all.dta"


///////// Section 4: Merging NCES Variables


save "${output}/CO_OriginalData_2019_all.dta", replace

	// Merges district variables from NCES

replace DataLevel = strtrim(DataLevel)
replace DataLevel = strproper(DataLevel)
replace DistName = strtrim(DistName)
replace DistName = strproper(DistName)
replace SchName = strtrim(SchName)
replace SchName = strproper(SchName)

replace StateAssignedDistID = "" if DataLevel == "State"
gen State_leaid = "CO-" + StateAssignedDistID if DataLevel != "State"
	
merge m:1 State_leaid using "${nces}/NCES_2018_District_CO.dta"

drop if _merge == 2
drop _merge	

replace StateAssignedSchID = "" if DataLevel != "School"
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
	
merge m:1 seasch using "${nces}/NCES_2018_School_CO.dta"

drop if _merge == 2
drop _merge


///////// Section 5: Reformatting

// Removing spaces

local level 1 2 3 4 5

foreach a of local level {
	replace Lev`a'_percent = strtrim(Lev`a'_percent)
	replace Lev`a'_count = strtrim(Lev`a'_count)
	replace Lev`a'_count = subinstr(Lev`a'_count, ",", "", .)
}

replace ProficientOrAbove_count = strtrim(ProficientOrAbove_count)
replace ProficientOrAbove_count = subinstr(ProficientOrAbove_count, ",", "", .)
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "- -"
replace ProficientOrAbove_percent = strtrim(ProficientOrAbove_percent)

replace Subject = strtrim(Subject)
replace GradeLevel = strtrim(GradeLevel)
replace StudentSubGroup = strtrim(StudentSubGroup)

replace ParticipationRate = strtrim(ParticipationRate)
replace AvgScaleScore = strtrim(AvgScaleScore)
replace AvgScaleScore = "*" if AvgScaleScore == "- -"

replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, " ", "", .)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",", "", .)

replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)


//Converting to decimal

local level 1 2 3 4 5

foreach a of local level {
	destring Lev`a'_percent, gen(Lev`a'_percent2) force
	replace Lev`a'_percent2 = Lev`a'_percent2/100
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2 if Lev`a'_percent2 != "."
	replace Lev`a'_percent = "*" if Lev`a'_percent == "- -"
	replace Lev`a'_count = "*" if Lev`a'_count == "- -"
	drop Lev`a'_percent2
}

destring ParticipationRate, gen(ParticipationRate2) force
replace ParticipationRate2 = ParticipationRate2/100
tostring ParticipationRate2, replace force
replace ParticipationRate = ParticipationRate2 if ParticipationRate2 != "."
replace ParticipationRate = "*" if ParticipationRate == "- -"
drop ParticipationRate2

destring ProficientOrAbove_percent, gen(ProficientOrAbove_percent2) force
replace ProficientOrAbove_percent2 = ProficientOrAbove_percent2/100
tostring ProficientOrAbove_percent2, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if ProficientOrAbove_percent2 != "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "- -"
drop ProficientOrAbove_percent2


//	Create new variables

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci="N"
gen AssmtType = "Regular"
gen SchYear="2018-19"


// Relabel variable values

replace Subject = "math" if Subject == "Mathematics"
replace Subject = "ela" if Subject == "English Language Arts"

gen ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"

drop if GradeLevel == "HS"

replace GradeLevel = "G38" if GradeLevel == "All Grades"
replace GradeLevel = "G" + GradeLevel if GradeLevel != "G38"
drop if GradeLevel == "G38" & Subject == "sci"

drop if inlist(StudentSubGroup, "EL: LEP (Limited English Proficient)", "EL: NEP (Not English Proficient)", "Not EL: PHLOTE, NA, Not Reported")

replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian/Pacific Islander"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Unknown" if StudentSubGroup ==  "Not Reported"

replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No IEP"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner (EL)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learner (Not EL)"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "Not EL: FEP (Fluent English Proficient), FELL (Former English Language Learner)"

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"


////
replace Lev5_percent = "" if Subject == "sci"
replace Lev5_count = "" if Subject == "sci"

////

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace StateAbbrev = "CO" if DataLevel == 1
replace State = "Colorado" if DataLevel == 1
replace StateFips = 8 if DataLevel == 1

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving StudentSubGroup_TotalTested where suppressed
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited"
drop Unsuppressed*

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent)) & missing(real(ProficientOrAbove_count))

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2019.dta", replace

export delimited using "${output}/CO_AssmtData_2019.csv", replace
