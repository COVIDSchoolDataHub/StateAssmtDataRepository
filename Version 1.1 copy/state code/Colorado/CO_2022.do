clear all
set more off

cd "/Users/miramehta/Documents"

global path "/Users/miramehta/Documents/CO State Testing Data/2022"
global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global output "/Users/miramehta/Documents/CO State Testing Data"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela

	
import excel "/${path}/CO_OriginalData_2022_ela&mat.xlsx", sheet("CMAS ELA and Math") cellrange(A13:AC16856) firstrow case(lower) clear

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

save "${path}/CO_OriginalData_2022_all.dta", replace


///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS
	
	
import excel "${path}/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Gender") cellrange(A13:Y16170) firstrow case(lower) clear

rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="ela"

save "${output}/CO_2022_ELA_gender.dta", replace



import excel "${path}/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Language Proficiency") cellrange(A13:Y48482) firstrow case(lower) clear


rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen subject="ela"

save "${output}/CO_2022_ELA_language.dta", replace



import excel "${path}/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Race Ethnicity") cellrange(A13:Y56673) firstrow case(lower) clear


rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen subject="ela"

save "${output}/CO_2022_ELA_raceEthnicity.dta", replace



import excel "${path}/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Free Reduced Lunch") cellrange(A13:Y16170) firstrow case(lower) clear

rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen subject="ela"

save "${output}/CO_2022_ELA_econstatus.dta", replace

import excel "${path}/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Migrant") cellrange(A13:Y16169) firstrow case(lower) clear

rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen subject="ela"

save "${output}/CO_2022_ELA_migrantstatus.dta", replace

import excel "${path}/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("IEP") cellrange(A13:Y16169) firstrow case(lower) clear

rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen subject="ela"

save "${output}/CO_2022_ELA_disabilitystatus.dta", replace



	//// MATH


import excel "${path}/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Gender") cellrange(A13:Y16166) firstrow case(lower) clear


rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="math"

save "${output}/CO_2022_mat_gender.dta", replace



import excel "${path}/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Language Proficiency") cellrange(A13:Y48470) firstrow case(lower) clear


rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen subject="math"

save "${output}/CO_2022_mat_language.dta", replace


import excel "${path}/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Race Ethnicity") cellrange(A13:Y56659) firstrow case(lower) clear

rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen subject="math"

save "${output}/CO_2022_mat_raceEthnicity.dta", replace


import excel "${path}/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Free Reduced Lunch") cellrange(A13:Y16166) firstrow case(lower) clear

rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen subject="math"

save "${output}/CO_2022_mat_econstatus.dta", replace

import excel "${path}/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Migrant") cellrange(A13:Y16165) firstrow case(lower) clear

rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen subject="math"

save "${output}/CO_2022_mat_migrantstatus.dta", replace

import excel "${path}/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("IEP") cellrange(A13:Y16165) firstrow case(lower) clear

rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen subject="math"

save "${output}/CO_2022_mat_disabilitystatus.dta", replace


///////// Section 3: Appending Disaggregate Data


use "${path}/CO_OriginalData_2022_all.dta", clear


/// some variables need to be renamed to append correctly

rename content subject
rename z percentmetorexceededexpectat 
drop aa ab change2019to2022


	//Appends subgroups
	
append using "${output}/CO_2022_ELA_gender.dta"
append using "${output}/CO_2022_mat_gender.dta"
append using "${output}/CO_2022_ELA_language.dta"
append using "${output}/CO_2022_mat_language.dta"
append using "${output}/CO_2022_ELA_raceEthnicity.dta"
append using "${output}/CO_2022_mat_raceEthnicity.dta"
append using "${output}/CO_2022_mat_econstatus.dta"
append using "${output}/CO_2022_ELA_econstatus.dta"
append using "${output}/CO_2022_ELA_migrantstatus.dta"
append using "${output}/CO_2022_mat_migrantstatus.dta"
append using "${output}/CO_2022_ELA_disabilitystatus.dta"
append using "${output}/CO_2022_mat_disabilitystatus.dta"


drop if level=="* The value for this field is not displayed in order to protect student privacy."
drop if level==""
drop if level=="* The value for this field is not displayed in order to ensure student privacy."


///////// Section 4: Merging NCES Variables


gen state_leaidnumber =.
gen state_leaid = string(state_leaidnumber)
replace state_leaid = "CO-" + districtcode

gen seasch=""
replace seasch = districtcode + "-" + schoolcode


save "${path}/CO_OriginalData_2022_all.dta", replace

		// Merges district variables from NCES
	
use "${nces}/NCES District Files, Fall 1997-Fall 2022/NCES_2021_District.dta"
drop if state_fips != 8
save "${nces}/Cleaned NCES Data/NCES_2021_District_CO.dta", replace


use "${path}/CO_OriginalData_2022_all.dta"
merge m:1 state_leaid using "${nces}/Cleaned NCES Data/NCES_2021_District_CO.dta"

rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${path}/CO_OriginalData_2022_all.dta", replace


	// Merges school variables from NCES
	
use "${nces}/NCES School Files, Fall 1997-Fall 2022/NCES_2021_School.dta"
drop if state_fips != 8
save "${nces}/Cleaned NCES Data/NCES_2021_School_CO.dta", replace

use "${path}/CO_OriginalData_2022_all.dta", clear

merge m:1 seasch using "${nces}/Cleaned NCES Data/NCES_2021_School_CO.dta"	
drop if state_fips != 8



///////// Section 5: Reformatting


	// Renames variables 
	
rename level DataLevel
rename districtcode StateAssignedDistID
rename districtname DistName
rename schoolcode StateAssignedSchID
rename schoolname SchName
rename subject Subject
rename grade GradeLevel
rename numberofvalidscores StudentSubGroup_TotalTested
rename participationrate ParticipationRate
rename meanscalescore AvgScaleScore
rename state_name State
rename state_fips StateFips
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename district_agency_type DistType
rename state_location StateAbbrev
rename county_name CountyName
rename county_code CountyCode


//Rename proficiency levels
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
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent


//	Create new variables

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci="Not applicable"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 4-5"
gen SchYear="2021-22"


// Relabel variable values

replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)

tab Subject
replace Subject="math" if Subject=="Mathematics"
replace Subject="math" if Subject=="Math"
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="ela" if Subject=="ELA"
drop if Subject == "Spanish Language Arts"

tab StudentSubGroup
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Not Reported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"

replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Learner (EL)"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "Not EL: FEP (Fluent English Proficient), FELL (Former English Language Learner)"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not English Learner (Not EL)"
drop if StudentSubGroup == "EL: LEP (Limited English Proficient)"
drop if StudentSubGroup == "EL: NEP (Not English Proficient)"
drop if StudentSubGroup == "Not EL: PHLOTE, NA, Not Reported"

replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No IEP"

replace DataLevel="District" if DataLevel=="DISTRICT"
replace DataLevel="School" if DataLevel=="SCHOOL"
replace DataLevel="State" if DataLevel=="STATE"
replace seasch="0000-0000" if seasch=="000-000"
replace StateAssignedDistID="0000" if StateAssignedDistID=="000"
replace StateAssignedSchID="0000" if StateAssignedSchID=="000"
replace StateAbbrev="CO" if StateAbbrev==""


replace SchYear="2021-22"

replace State= "Colorado"

tab GradeLevel

replace GradeLevel = "G38" if GradeLevel == "All Grades"
replace GradeLevel = "G" + GradeLevel if GradeLevel != "G38"

drop if GradeLevel=="G38"

drop if district_merge==2
drop if _merge==2
drop _merge
drop district_merge


destring ParticipationRate, replace ignore(",* %NA<>=-")
replace ParticipationRate=ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate="*" if ParticipationRate=="."

//// ADJUST PERCENTS AND COUNTS
forvalues n = 1/5{
	replace Lev`n'_count = subinstr(Lev`n'_count, ",", "", 1)
	replace Lev`n'_count = strtrim(Lev`n'_count)
	destring Lev`n'_percent, replace force
	replace Lev`n'_percent = Lev`n'_percent/100
	tostring Lev`n'_percent, replace format("%9.2g") force
	replace Lev`n'_percent = "*" if Lev`n'_percent == "."
	replace Lev`n'_count = "*" if Lev`n'_count == "- -"
}

replace ProficientOrAbove_count = subinstr(ProficientOrAbove_count, ",", "", 1)
replace ProficientOrAbove_count = strtrim(ProficientOrAbove_count)
destring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace format("%9.2g") force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="- -"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == ""

destring Lev4_count, gen(Lev4) force
destring Lev5_count, gen(Lev5) force
gen Prof = Lev4 + Lev5
replace ProficientOrAbove_count = string(Prof) if inlist(ProficientOrAbove_count, "*", "") & Prof !=.
drop Lev4 Lev5 Prof

//Aggregating Total Tested
replace StudentGroup = "EL Exited" if StudentSubGroup == "EL Exited"
replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",", "", 1)
replace StudentSubGroup_TotalTested = "1-15" if StudentSubGroup_TotalTested == "< 16"
split StudentSubGroup_TotalTested, parse("-")
destring StudentSubGroup_TotalTested1, replace force
destring StudentSubGroup_TotalTested2, replace force
replace StudentSubGroup_TotalTested1 = 0 if StudentSubGroup_TotalTested1 == .
replace StudentSubGroup_TotalTested2 = 0 if StudentSubGroup_TotalTested2 == .
bysort DistName SchName StudentGroup GradeLevel Subject: egen test = min(StudentSubGroup_TotalTested1)
bysort DistName SchName StudentGroup GradeLevel Subject: egen test2 = min(StudentSubGroup_TotalTested2)
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = sum(StudentSubGroup_TotalTested1) if test != 0
bysort DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested2 = sum(StudentSubGroup_TotalTested2) if test2 != 0
tostring StudentGroup_TotalTested, replace force
tostring StudentGroup_TotalTested2, replace force
replace StudentGroup_TotalTested = StudentGroup_TotalTested + "-" + StudentGroup_TotalTested2 if !inlist(StudentGroup_TotalTested2, ".", "0")
replace StudentGroup_TotalTested = "*" if strpos(StudentGroup_TotalTested, ".") > 0
drop StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested2 StudentGroup_TotalTested2 test
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen Suppressed = 0
replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel seasch StateAssignedDistID DistName SchName)
drop Suppressed
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
replace StudentGroup_TotalTested = AllStudents_Tested if StudentGroup_Suppressed == 1
replace StudentGroup_TotalTested = AllStudents_Tested if AllStudents_Tested == "1-15"
drop AllStudents_Tested StudentGroup_Suppressed
replace StudentGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "--"
replace StudentGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "*"
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "EL Exited"
replace StudentGroup = "EL Status" if StudentSubGroup == "EL Exited"

////
replace StateAbbrev="CO" if StateAbbrev==""
replace StateAssignedSchID="" if StateAssignedSchID=="0000"

replace StateAssignedSchID="" if StateAssignedSchID=="0000"

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace AvgScaleScore="*" if AvgScaleScore=="- -"

replace StateAssignedSchID="" if DataLevel != "School"
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedDistID="" if DataLevel=="State"
replace DistName = "All Districts" if DataLevel=="State"

replace Lev5_count="*" if Lev5_count==""
replace ProficientOrAbove_count="*" if ProficientOrAbove_count==""
replace AvgScaleScore="*" if AvgScaleScore==""

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2022.dta", replace
export delimited using "${output}/CO_AssmtData_2022.csv", replace

