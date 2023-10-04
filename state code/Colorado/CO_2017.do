clear
set more off

global output "/Users/maggie/Desktop/Colorado/Output"
global nces "/Users/maggie/Desktop/Colorado/NCES/Cleaned"
global path "/Users/maggie/Desktop/Colorado/Original Data Files/Original Data Files/CMAS Aggregate Data"
global disagg "/Users/maggie/Desktop/Colorado/Original Data Files/Original Data Files/CMAS Disaggregate-SubPop Data/2017"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela


import excel "${path}/CO_OriginalData_2017_ela_mat.xlsx", sheet("District and School Detail_1") cellrange(A5:X14759) firstrow case(lower) clear

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

save "${path}/CO_OriginalData_2017_ela_math.dta", replace
	
import excel "${path}/CO_OriginalData_2017_sci.xlsx", sheet("District and School Detail_1") cellrange(A4:V2689) firstrow case(lower) clear

rename numberpartiallymetexpectati Lev1_count
rename partiallymetexpectations Lev1_percent
rename numberapproachedexpectations Lev2_count
rename approachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename metexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename exceededexpectations Lev4_percent

save "${path}/CO_OriginalData_2017_sci.dta", replace



	////Combines math/ela with science scores
	
append using "${path}/CO_OriginalData_2017_ela_math.dta"

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

save "${path}/CO_OriginalData_2017_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS

import excel "${disagg}/CO_2017_ELA_gender.xlsx", sheet("Sheet1_1") cellrange(A4:X13525) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2017_ELA_gender.dta", replace



import excel "${disagg}/CO_2017_ELA_language.xlsx", sheet("Sheet1_1") cellrange(A4:X18811) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"

save "${path}/CO_2017_ELA_language.dta", replace


import excel "${disagg}/CO_2017_ELA_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:X28479) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"

save "${path}/CO_2017_ELA_raceEthnicity.dta", replace


import excel "${disagg}/CO_2017_ELA_FreeReducedLunch.xlsx", sheet("Sheet1_1") cellrange(A4:X13339) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${path}/CO_2017_ELA_econstatus.dta", replace


	//// MATH


import excel "${disagg}/CO_2017_mat_gender.xlsx", sheet("Sheet1_1") cellrange(A4:X15543) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2017_mat_gender.dta", replace



import excel "${disagg}/CO_2017_mat_language.xlsx", sheet("Sheet1_1") cellrange(A4:X20787) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"

save "${path}/CO_2017_mat_language.dta", replace


import excel "${disagg}/CO_2017_mat_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:X31641) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"

save "${path}/CO_2017_mat_raceEthnicity.dta", replace


import excel "${disagg}/CO_2017_mat_FreeReducedLunch.xlsx", sheet("Sheet1_1") cellrange(A4:X15209) firstrow case(lower) clear

rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename v Lev5_percent
rename x ProficientOrAbove_percent

rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${path}/CO_2017_mat_econstatus.dta", replace


	//// SCIENCE
	
	
import excel "${disagg}/CO_2017_sci_gender.xlsx", sheet("Sheet1_1") cellrange(A4:V5318) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2017_sci_gender.dta", replace



import excel "${disagg}/CO_2017_sci_language.xlsx", sheet("Sheet1_1") cellrange(A4:V7395) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"

save "${path}/CO_2017_sci_language.dta", replace



import excel "${disagg}/CO_2017_sci_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:V11184) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename ethnicity StudentSubGroup
gen StudentGroup = "RaceEth"

save "${path}/CO_2017_sci_raceEthnicity.dta", replace


import excel "${disagg}/CO_2017_sci_FreeReducedLunch.xlsx", sheet("Sheet1_1") cellrange(A4:V5251) firstrow case(lower) clear

rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename v ProficientOrAbove_percent

rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${path}/CO_2017_sci_econstatus.dta", replace


///////// Section 3: Appending Disaggregate Data

	//Appends subgroups
	
append using "${path}/CO_2017_ELA_gender.dta"
append using "${path}/CO_2017_mat_gender.dta"
append using "${path}/CO_2017_sci_gender.dta"
append using "${path}/CO_2017_ELA_language.dta"
append using "${path}/CO_2017_mat_language.dta"
append using "${path}/CO_2017_sci_language.dta"
append using "${path}/CO_2017_ELA_raceEthnicity.dta"
append using "${path}/CO_2017_mat_raceEthnicity.dta"
append using "${path}/CO_2017_sci_raceEthnicity.dta"
append using "${path}/CO_2017_ELA_econstatus.dta"
append using "${path}/CO_2017_mat_econstatus.dta"

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

append using "${path}/CO_OriginalData_2017_all.dta"


///////// Section 4: Merging NCES Variables


save "${path}/CO_OriginalData_2017_all.dta", replace

	// Merges district variables from NCES

replace DataLevel = strtrim(DataLevel)
replace DataLevel = strproper(DataLevel)
replace DistName = strtrim(DistName)
replace DistName = strproper(DistName)
replace SchName = strtrim(SchName)
replace SchName = strproper(SchName)

replace StateAssignedDistID = "" if DataLevel == "State"
gen State_leaid = "CO-" + StateAssignedDistID if DataLevel != "State"
	
merge m:1 State_leaid using "${nces}/NCES_2016_District.dta"

drop if _merge == 2
drop _merge	

replace StateAssignedSchID = "" if DataLevel != "School"
gen seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
	
merge m:1 seasch using "${nces}/NCES_2016_School.dta"

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
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"
gen SchYear = "2016-17"


// Relabel variable values

tab Subject
replace Subject = "math" if Subject == "Mathematics" | Subject == "Math"
replace Subject = "ela" if Subject == "English Language Arts" | Subject == "ELA"
replace Subject = "sci" if Subject == "Science"

gen ProficiencyCriteria = "Lev3 or Lev4" if Subject == "sci"
replace ProficiencyCriteria = "Lev4 or Lev5" if Subject != "sci"

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

replace StudentSubGroup = "English Learner" if StudentSubGroup == "NEP - Non English Proficient" | StudentSubGroup == "LEP - Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "FEP - Fluent English Proficient" | StudentSubGroup == "PHLOTE/FELL/NA"

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if test != 0
tostring StudentGroup_TotalTested, replace force
replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

// Combining EL Status Subgroups

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
destring ParticipationRate, gen(Participation2) force
replace Participation2 = round(StudentSubGroup_TotalTested2 / Participation2)

//// Combining student counts

replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentSubGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentSubGroup GradeLevel Subject: egen StudentELGroup_TotalTested = sum(StudentSubGroup_TotalTested2) if (test != 0 & StudentGroup == "EL Status")
tostring StudentELGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested = StudentELGroup_TotalTested if StudentGroup == "EL Status"
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "."
drop StudentSubGroup_TotalTested2 test

//// Recalculating participation rates

replace Participation2 = 0 if Participation2 == .
bysort DistName SchName StudentSubGroup GradeLevel Subject: egen test = min(Participation2)
bysort DistName SchName StudentSubGroup GradeLevel Subject: egen ParticipationEL = sum(Participation2) if (test != 0 & StudentGroup == "EL Status")
replace Participation2 = ParticipationEL if StudentGroup == "EL Status"
drop ParticipationEL test

destring StudentELGroup_TotalTested, replace force
gen ParticipationRate2 = StudentELGroup_TotalTested/Participation2 if StudentGroup == "EL Status"
tostring ParticipationRate2, replace force
replace ParticipationRate = ParticipationRate2 if StudentGroup == "EL Status"
replace ParticipationRate = "*" if ParticipationRate == "."

drop ParticipationRate2 StudentELGroup_TotalTested Participation2

//// Combining level counts

local level 1 2 3 4 5
foreach a of local level {
	destring Lev`a'_count, gen(Lev`a'_count2) force
	replace Lev`a'_count2 = 0 if Lev`a'_count2 == .
	bysort DistName SchName StudentSubGroup GradeLevel Subject: egen test = min(Lev`a'_count2)
	bysort DistName SchName StudentSubGroup GradeLevel Subject: egen Lev`a'_countEL = sum(Lev`a'_count2) if (test != 0 & StudentGroup == "EL Status")
	tostring Lev`a'_countEL, replace force
	replace Lev`a'_count = Lev`a'_countEL if StudentGroup == "EL Status"
	replace Lev`a'_count = "*" if Lev`a'_count == "."
	drop Lev`a'_count2 Lev`a'_countEL test
}

replace Lev5_count = "" if Subject == "sci"

//// Combining proficient counts

destring ProficientOrAbove_count, gen(ProficientOrAbove_count2) force
replace ProficientOrAbove_count2 = 0 if ProficientOrAbove_count2 == .
bysort DistName SchName StudentSubGroup GradeLevel Subject: egen test = min(ProficientOrAbove_count2)
bysort DistName SchName StudentSubGroup GradeLevel Subject: egen ProficientOrAbove_countEL = sum(ProficientOrAbove_count2) if (test != 0 & StudentGroup == "EL Status")
tostring ProficientOrAbove_countEL, replace force
replace ProficientOrAbove_count = ProficientOrAbove_countEL if StudentGroup == "EL Status"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
drop ProficientOrAbove_count2 ProficientOrAbove_countEL test

//// Dropping duplicates

sort DistName SchName StudentSubGroup GradeLevel Subject
quietly by DistName SchName StudentSubGroup GradeLevel Subject: gen dup = cond(_N == 1, 0,_n)

sort DistName SchName StudentSubGroup GradeLevel Subject dup

drop if dup > 1
drop dup

//// Recalculating proficient percents

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force

destring ProficientOrAbove_count, gen(ProficientOrAbove_count2) force
gen ProficientOrAbove_percent2 = ProficientOrAbove_count2/StudentSubGroup_TotalTested2
tostring ProficientOrAbove_percent2, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent2 if StudentGroup == "EL Status"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
drop ProficientOrAbove_count2 ProficientOrAbove_percent2


//// Recalculating level percents

local level 1 2 3 4 5
foreach a of local level {
	destring Lev`a'_count, gen(Lev`a'_count2) force
	gen Lev`a'_percent2 = Lev`a'_count2/StudentSubGroup_TotalTested2
	tostring Lev`a'_percent2, replace force
	replace Lev`a'_percent = Lev`a'_percent2 if StudentGroup == "EL Status"
	replace Lev`a'_percent = "*" if Lev`a'_percent == "."
	drop Lev`a'_percent2 Lev`a'_count2
}

replace Lev5_percent = "" if Subject == "sci"

drop StudentSubGroup_TotalTested2

replace AvgScaleScore = "--" if StudentGroup == "EL Status"


////

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

replace StateAbbrev = "CO" if DataLevel == 1
replace State = 8 if DataLevel == 1
replace StateFips = 8 if DataLevel == 1

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2017.dta", replace

export delimited using "${output}/csv/CO_AssmtData_2017.csv", replace
