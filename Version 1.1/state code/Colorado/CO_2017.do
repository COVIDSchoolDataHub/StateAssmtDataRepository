clear all
set more off

cd "/Users/miramehta/Documents"

global path "/Users/miramehta/Documents/CO State Testing Data/2017"
global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global output "/Users/miramehta/Documents/CO State Testing Data"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela


import excel "${path}/CO_OriginalData_2017_ela&mat.xlsx", sheet("District and School Detail_1") cellrange(A5:X14759) firstrow case(lower) clear

rename numberdidnotyetmeetexpect Lev1_count
rename didnotyetmeetexpectation Lev1_percent
rename numberpartiallymetexpectati Lev2_count
rename partiallymetexpectations Lev2_percent
rename numberapproachedexpectations Lev3_count
rename approachedexpectations Lev3_percent
rename numbermetexpectations Lev4_count
rename metexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename exceededexpectations Lev5_percent

save "${output}/CO_OriginalData_2017_ela_math.dta", replace
	
import excel "${path}/CO_OriginalData_2017_sci.xlsx", sheet("District and School Detail_1") cellrange(A4:V2689) firstrow case(lower) clear

rename numberpartiallymetexpectati Lev1_count
rename partiallymetexpectations Lev1_percent
rename numberapproachedexpectations Lev2_count
rename approachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename metexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename exceededexpectations Lev4_percent

save "${output}/CO_OriginalData_2017_sci.dta", replace



	////Combines math/ela with science scores
	
append using "${output}/CO_OriginalData_2017_ela_math.dta"

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
rename numbermetorexceededexpecta ProficientOrAbove_count
rename metorexceededexpectations ProficientOrAbove_percent

save "${output}/CO_OriginalData_2017_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS

import excel "${path}/CO_2017_ELA_gender.xlsx", sheet("Sheet1_1") cellrange(A4:X13525) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${output}/CO_2017_ELA_gender.dta", replace



import excel "${path}/CO_2017_ELA_language.xlsx", sheet("Sheet1_1") cellrange(A4:X18811) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"

save "${output}/CO_2017_ELA_language.dta", replace


import excel "${path}/CO_2017_ELA_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:X28479) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"

save "${output}/CO_2017_ELA_raceEthnicity.dta", replace


import excel "${path}/CO_2017_ELA_FreeReducedLunch.xlsx", sheet("Sheet1_1") cellrange(A4:X13339) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${output}/CO_2017_ELA_econstatus.dta", replace

import excel "${path}/CO_2017_ELA_migrant.xlsx", sheet("Sheet1_1") cellrange(A4:X7989) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"

save "${output}/CO_2017_ELA_migrantstatus.dta", replace

import excel "${path}/CO_2017_ELA_individualEd.xlsx", sheet("Sheet1_1") cellrange(A4:X13063) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename specialprogram StudentSubGroup
gen StudentGroup = "Disability Status"

save "${output}/CO_2017_ELA_disabilitystatus.dta", replace


	//// MATH


import excel "${path}/CO_2017_mat_gender.xlsx", sheet("Sheet1_1") cellrange(A4:X15543) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${output}/CO_2017_mat_gender.dta", replace



import excel "${path}/CO_2017_mat_language.xlsx", sheet("Sheet1_1") cellrange(A4:X20787) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"

save "${output}/CO_2017_mat_language.dta", replace


import excel "${path}/CO_2017_mat_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:X31641) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"

save "${output}/CO_2017_mat_raceEthnicity.dta", replace


import excel "${path}/CO_2017_mat_FreeReducedLunch.xlsx", sheet("Sheet1_1") cellrange(A4:X15209) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${output}/CO_2017_mat_econstatus.dta", replace

import excel "${path}/CO_2017_mat_migrant.xlsx", sheet("Sheet1_1") cellrange(A4:X9147) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"

save "${output}/CO_2017_mat_migrantstatus.dta", replace

import excel "${path}/CO_2017_mat_individualEd.xlsx", sheet("Sheet1_1") cellrange(A4:X14422) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename specialprogram StudentSubGroup
gen StudentGroup = "Disability Status"

save "${output}/CO_2017_mat_disabilitystatus.dta", replace


	//// SCIENCE
	
	
import excel "${path}/CO_2017_sci_gender.xlsx", sheet("Sheet1_1") cellrange(A4:V5318) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${output}/CO_2017_sci_gender.dta", replace



import excel "${path}/CO_2017_sci_language.xlsx", sheet("Sheet1_1") cellrange(A4:V7395) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"

save "${output}/CO_2017_sci_language.dta", replace



import excel "${path}/CO_2017_sci_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:V11184) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"

save "${output}/CO_2017_sci_raceEthnicity.dta", replace


import excel "${path}/CO_2017_sci_FreeReducedLunch.xlsx", sheet("Sheet1_1") cellrange(A4:V5251) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${output}/CO_2017_sci_econstatus.dta", replace

import excel "${path}/CO_2017_sci_migrant.xlsx", sheet("Sheet1_1") cellrange(A4:V3165) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"

save "${output}/CO_2017_sci_migrantstatus.dta", replace

import excel "${path}/CO_2017_sci_individualEd.xlsx", sheet("Sheet1_1") cellrange(A4:V5073) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename specialprogram StudentSubGroup
gen StudentGroup = "Disability Status"

save "${output}/CO_2017_sci_disabilitystatus.dta", replace


///////// Section 3: Appending Disaggregate Data

	//Appends subgroups
	
append using "${output}/CO_2017_ELA_gender.dta"
append using "${output}/CO_2017_mat_gender.dta"
append using "${output}/CO_2017_sci_gender.dta"
append using "${output}/CO_2017_ELA_language.dta"
append using "${output}/CO_2017_mat_language.dta"
append using "${output}/CO_2017_sci_language.dta"
append using "${output}/CO_2017_ELA_raceEthnicity.dta"
append using "${output}/CO_2017_mat_raceEthnicity.dta"
append using "${output}/CO_2017_sci_raceEthnicity.dta"
append using "${output}/CO_2017_ELA_econstatus.dta"
append using "${output}/CO_2017_mat_econstatus.dta"
append using "${output}/CO_2017_sci_econstatus.dta"
append using "${output}/CO_2017_ELA_migrantstatus.dta"
append using "${output}/CO_2017_mat_migrantstatus.dta"
append using "${output}/CO_2017_sci_migrantstatus.dta"
append using "${output}/CO_2017_ELA_disabilitystatus.dta"
append using "${output}/CO_2017_mat_disabilitystatus.dta"

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

append using "${output}/CO_OriginalData_2017_all.dta"


///////// Section 4: Merging NCES Variables


save "${output}/CO_OriginalData_2017_all.dta", replace

	// Merges district variables from NCES

replace DataLevel = strtrim(DataLevel)
replace DataLevel = strproper(DataLevel)
replace DistName = strtrim(DistName)
replace DistName = strproper(DistName)
replace SchName = strtrim(SchName)
replace SchName = strproper(SchName)

replace StateAssignedDistID = "" if DataLevel == "State"
gen State_leaid = "CO-" + StateAssignedDistID if DataLevel != "State"
	
merge m:1 State_leaid using "${nces}/Cleaned NCES Data/NCES_2016_District.dta"

drop if _merge == 2
drop _merge	

replace StateAssignedSchID = "" if DataLevel != "School"
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
	
merge m:1 seasch using "${nces}/Cleaned NCES Data/NCES_2016_School.dta"

drop if _merge == 2
drop _merge	


///////// Section 5: Reformatting

// Drop NCES variables
	
drop agency_charter_indicator dist_agency_charter_indicator

// Removing spaces

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

//	Create new variables

gen AssmtName = "Colorado Measures of Academic Success"
gen AssmtType = "Regular"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = ""
gen Flag_CutScoreChange_sci = "N"
gen SchYear = "2016-17"


// Relabel variable values

tab Subject
replace Subject = "math" if Subject == "Mathematics" | Subject == "Math"
replace Subject = "ela" if Subject == "English Language Arts" | Subject == "ELA"
replace Subject = "sci" if Subject == "Science"

gen ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
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

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"

//Aggregating Language Groups
gen EL_group = ""
replace EL_group = "English Learner" if StudentSubGroup == "NEP - Non English Proficient" | StudentSubGroup == "LEP - Limited English Proficient"
replace EL_group = "English Proficient" if StudentSubGroup == "FEP - Fluent English Proficient" | StudentSubGroup == "PHLOTE/FELL/NA"
gen K = StudentSubGroup_TotalTested
destring K, replace force
replace K = -1000000 if K == .
bys SchName EL_group GradeLevel Subject: egen L = total(K)
replace L =. if L < 0

gen proportion = K/L
replace proportion = . if K ==. | L == .

gen Avg = AvgScaleScore
destring Avg, replace force
replace Avg = -1000000 if Avg == .
replace Avg = proportion * Avg
bys SchName EL_group GradeLevel Subject: egen Average = total(Avg)
replace Average = . if Average < 0

gen Part = ParticipationRate
destring Part, replace force
replace Part = -1000000 if Part == .
replace Part = proportion * Part
bys SchName EL_group GradeLevel Subject: egen Participation = total(Part)
replace Participation = . if Participation <= 0

forvalues n = 1/5{
	gen K`n' = Lev`n'_count
	destring K`n', replace force
	replace K`n' = -1000000 if K`n' == .
	bys SchName EL_group GradeLevel Subject: egen L`n' = total(K`n')
	replace L`n' = . if L`n' < 0
	gen K`n'_percent = Lev`n'_percent
	destring K`n'_percent, replace force
	replace K`n'_percent = -1000000 if K`n'_percent == .
	gen weighted`n' = proportion*K`n'_percent
	bys SchName EL_group GradeLevel Subject: egen L`n'_percent = total(weighted`n')
	replace L`n'_percent = . if L`n'_percent < 0
	
	tostring L`n', replace
	replace L`n' = "*" if L`n' == "."
	replace Lev`n'_count = L`n' if StudentSubGroup == "NEP - Non English Proficient"| StudentSubGroup == "PHLOTE/FELL/NA"
	tostring L`n'_percent, replace format("%10.0g") force
	replace L`n'_percent = "*" if L`n'_percent == "."
	replace Lev`n'_percent = L`n'_percent if StudentSubGroup == "NEP - Non English Proficient"| StudentSubGroup == "PHLOTE/FELL/NA"
	drop K`n' L`n' K`n'_percent weighted`n' L`n'_percent
}

gen Prof = ProficientOrAbove_count
destring Prof, replace force
replace Prof = -1000000 if Prof == .
bys SchName EL_group GradeLevel Subject: egen Prof_count = total(Prof)
replace Prof_count = . if Prof_count < 0

gen P = ProficientOrAbove_percent
destring P, replace force
replace P = -1000000 if P == .
gen weightedP = proportion * P
bys SchName EL_group GradeLevel Subject: egen P_pct = total(weightedP)
replace P_pct = . if P_pct < 0

tostring Prof_count, replace
replace Prof_count = "*" if Prof_count == "."
replace ProficientOrAbove_count = Prof_count if StudentSubGroup == "NEP - Non English Proficient"| StudentSubGroup == "PHLOTE/FELL/NA"
tostring P_pct, replace format("%10.0g") force
replace P_pct = "*" if P_pct == "."
replace ProficientOrAbove_percent = P_pct if StudentSubGroup == "NEP - Non English Proficient"| StudentSubGroup == "PHLOTE/FELL/NA"
drop Prof Prof_count P weightedP P_pct

tostring L, replace
replace L = "*" if L == "."
replace StudentSubGroup_TotalTested = L if StudentSubGroup == "NEP - Non English Proficient"| StudentSubGroup == "PHLOTE/FELL/NA"

tostring Average, replace format("%10.0g") force
replace Average = "*" if Average == "." | Average == "0"
replace AvgScaleScore = Average if StudentSubGroup == "NEP - Non English Proficient"| StudentSubGroup == "PHLOTE/FELL/NA"
tostring Part, replace format("%10.0g") force
replace Part = "*" if Part == "."
replace ParticipationRate = Part if StudentSubGroup == "NEP - Non English Proficient"| StudentSubGroup == "PHLOTE/FELL/NA"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "NEP - Non English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "PHLOTE/FELL/NA"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "FEP - Fluent English Proficient"
drop if StudentSubGroup == "LEP - Limited English Proficient"

drop EL_group K L proportion Avg Average Part Participation

//Aggregating Total Tested
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test


////

replace State = 8
replace StateAbbrev = "CO" if DataLevel == "State"
replace StateFips = 8 if DataLevel == "State"

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace SchName = "Prairie Vista Youth Service Center" if NCESSchoolID == "080258006343"
replace SchName = "Marvin W Foote Youth Services" if NCESSchoolID == "080291006344"
replace SchName = "Gilliam School" if NCESSchoolID == "080336006345"
replace SchName = "Spring Creek Youth Services Center" if NCESSchoolID == "080453006342"
replace SchName = "Mountview Youth Service Center" if NCESSchoolID == "080480006347"
replace SchName = "Pueblo Youth Service Center" if NCESSchoolID == "080612006350"

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2017.dta", replace

export delimited using "${output}/CO_AssmtData_2017.csv", replace