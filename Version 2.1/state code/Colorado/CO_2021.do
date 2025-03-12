*******************************************************
* COLORADO

* File name: CO_2021
* Last update: 2/25/2025

*******************************************************
* Notes

	* This do file imports CO 2021 data, renames variables, cleans and saves it as a dta file.
	* NCES 2020 is merged with CO 2021 data. 
	* Only the usual output is created.
*******************************************************
/////////////////////////////////////////
*** Setup ***
clear
/////////////////////////////////////////
*******************************************************
// Section 1: Appending Aggregate Data
*******************************************************
//Combines math/ela data with science data
//Imports and saves math/ela
	
import excel "$Original/2021/CO_OriginalData_2021_ela&mat.xlsx", sheet("CMAS ELA and Math") cellrange(A28:Y6477) firstrow case(lower) clear
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
save "${Temp}/CO_OriginalData_2021_ela&mat.dta", replace

//imports and saves sci
import excel "$Original/2021/CO_OriginalData_2021_sci.xlsx", sheet("CMAS Science") cellrange(A28:V831) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
gen content="sci"
save "${Temp}/CO_OriginalData_2021_sci.dta", replace

//Combines math/ela with science scores
use "${Temp}/CO_OriginalData_2021_ela&mat.dta", clear
append using "${Temp}/CO_OriginalData_2021_sci.dta"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
save "${Temp}/CO_OriginalData_2021_all.dta", replace

*******************************************************
// Section 2: Preparing Disaggregate Data
*******************************************************
// ENGLISH/LANGUAGE ARTS
	
import excel "$Original/2021/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Gender") cellrange(A28:Y6745) firstrow case(lower) clear
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
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="ela"
save "${Temp}/CO_2021_ELA_gender.dta", replace

import excel "$Original/2021/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Language Proficiency") cellrange(A28:Y20176) firstrow case(lower) clear
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
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen subject="ela"
save "${Temp}/CO_2021_ELA_language.dta", replace

import excel "$Original/2021/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Race Ethnicity") cellrange(A28:Y23582) firstrow case(lower) clear
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
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen subject="ela"
save "${Temp}/CO_2021_ELA_raceEthnicity.dta", replace

import excel "$Original/2021/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Free Reduced Lunch") cellrange(A30:Y6747) firstrow case(lower) clear
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
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen subject="ela"
save "${Temp}/CO_2021_ELA_econstatus.dta", replace

import excel "$Original/2021/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Migrant") cellrange(A28:Y6744) firstrow case(lower) clear
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
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen subject="ela"
save "${Temp}/CO_2021_ELA_migrantstatus.dta", replace

import excel "$Original/2021/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("IEP") cellrange(A28:Y6744) firstrow case(lower) clear
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
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen subject="ela"
save "${Temp}/CO_2021_ELA_disabilitystatus.dta", replace

// MATH
import excel "$Original/2021/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Gender") cellrange(A28:Y5909) firstrow case(lower) clear
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
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="math"
save "${Temp}/CO_2021_mat_gender.dta", replace

import excel "$Original/2021/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Language Proficiency") cellrange(A28:Y17667) firstrow case(lower) clear
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
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen subject="math"
save "${Temp}/CO_2021_mat_language.dta", replace

import excel "$Original/2021/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Race Ethnicity") cellrange(A28:Y20645) firstrow case(lower) clear
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
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen subject="math"
save "${Temp}/CO_2021_mat_raceEthnicity.dta", replace

import excel "$Original/2021/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Free Reduced Lunch") cellrange(A30:Y5911) firstrow case(lower) clear
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
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen subject="math"
save "${Temp}/CO_2021_mat_econstatus.dta", replace

import excel "$Original/2021/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Migrant") cellrange(A28:Y5908) firstrow case(lower) clear
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
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen subject="math"
save "${Temp}/CO_2021_mat_migrantstatus.dta", replace

import excel "$Original/2021/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("IEP") cellrange(A28:Y5908) firstrow case(lower) clear
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
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen subject="math"
save "${Temp}/CO_2021_mat_disabilitystatus.dta", replace

// SCIENCE
import excel "$Original/2021/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Gender") cellrange(A28:W1633) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="sci"
save "${Temp}/CO_2021_sci_gender.dta", replace

import excel "$Original/2021/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Language Proficiency") cellrange(A28:W4841) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen subject="sci"
save "${Temp}/CO_2021_sci_language.dta", replace

import excel "$Original/2021/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Race Ethnicity") cellrange(A28:W5654) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen subject="sci"
save "${Temp}/CO_2021_sci_raceEthnicity.dta", replace

import excel "$Original/2021/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Free Reduced Lunch") cellrange(A30:W1634) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen subject="sci"
save "${Temp}/CO_2021_sci_econstatus.dta", replace

import excel "$Original/2021/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Migrant") cellrange(A28:W1632) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen subject="sci"
save "${Temp}/CO_2021_sci_migrantstatus.dta", replace

import excel "$Original/2021/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("IEP") cellrange(A28:W1632) firstrow case(lower) clear
rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen subject="sci"
save "${Temp}/CO_2021_sci_disabilitystatus.dta", replace

*******************************************************
// Section 3: Appending Disaggregate Data
*******************************************************
use "${Temp}/CO_OriginalData_2021_all.dta", clear
// some variables need to be renamed to append correctly
rename content subject

//Appends subgroups
append using "${Temp}/CO_2021_ELA_gender.dta"
append using "${Temp}/CO_2021_mat_gender.dta"
append using "${Temp}/CO_2021_sci_gender.dta"
append using "${Temp}/CO_2021_ELA_language.dta"
append using "${Temp}/CO_2021_mat_language.dta"
append using "${Temp}/CO_2021_sci_language.dta"
append using "${Temp}/CO_2021_ELA_raceEthnicity.dta"
append using "${Temp}/CO_2021_mat_raceEthnicity.dta"
append using "${Temp}/CO_2021_sci_raceEthnicity.dta"
append using "${Temp}/CO_2021_ELA_econstatus.dta"
append using "${Temp}/CO_2021_mat_econstatus.dta"
append using "${Temp}/CO_2021_sci_econstatus.dta"
append using "${Temp}/CO_2021_ELA_migrantstatus.dta"
append using "${Temp}/CO_2021_mat_migrantstatus.dta"
append using "${Temp}/CO_2021_sci_migrantstatus.dta"
append using "${Temp}/CO_2021_ELA_disabilitystatus.dta"
append using "${Temp}/CO_2021_mat_disabilitystatus.dta"
append using "${Temp}/CO_2021_sci_disabilitystatus.dta"

drop if level=="* The value for this field is not displayed in order to protect student privacy."
drop if level==""
drop if level=="* The value for this field is not displayed in order to ensure student privacy."

gen state_leaidnumber =.
gen state_leaid = string(state_leaidnumber)
replace state_leaid = "CO-" + districtcode

gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = districtcode + "-" + schoolcode

save "${Original_Cleaned}/CO_OriginalData_2021.dta", replace

*******************************************************
// Section 4: Merging NCES Variables
*******************************************************
// Merges district variables from NCES
use "${NCES_District}/NCES_2020_District.dta", clear
drop if state_fips != 8
save "${NCES_CO}/NCES_2020_District_CO.dta", replace
//
use "${Original_Cleaned}/CO_OriginalData_2021.dta", clear
merge m:1 state_leaid using "${NCES_CO}/NCES_2020_District_CO.dta"

rename _merge district_merge
replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${Temp}/CO_OriginalData_2021.dta", replace

// Merges school variables from NCES
	
use "${NCES_School}/NCES_2020_School.dta"
drop if state_fips != 8
save "${NCES_CO}/NCES_2020_School_CO.dta", replace

use "${Temp}/CO_OriginalData_2021.dta", clear
	
merge m:1 seasch state_fips using "${NCES_CO}/NCES_2020_School_CO.dta"
drop if state_fips != 8

*******************************************************
// Section 5: Reformatting
*******************************************************

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
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent

//	Create new variables
gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
replace ProficiencyCriteria = "Levels 4-5" if Subject != "sci"
gen SchYear="2020-21"

// Relabel variable values
replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)

tab Subject
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="ela" if Subject=="ELA"
replace Subject="sci" if Subject=="Science"
drop if Subject == "Spanish Language Arts"

replace StudentSubGroup = strtrim(StudentSubGroup)
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

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "0-15" if strpos(StudentSubGroup_TotalTested, "<16") !=0 | strpos(StudentSubGroup_TotalTested, "< 16") !=0
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

replace DataLevel="District" if DataLevel=="DISTRICT"
replace DataLevel="School" if DataLevel=="SCHOOL"
replace DataLevel="State" if DataLevel=="STATE"
replace StateAssignedDistID="0000" if StateAssignedDistID=="000"
replace StateAssignedSchID="0000" if StateAssignedSchID=="000"
replace StateAbbrev="CO" if StateAbbrev==""

replace SchYear="2020-21"

replace GradeLevel="G03" if GradeLevel=="03"
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G06" if GradeLevel=="06"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"

// Drops observations that aren't grades 3 through 8
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

////
replace Lev5_percent = "" if Subject == "sci"
replace Lev5_count = "" if Subject == "sci"

replace StateAssignedSchID="" if StateAssignedSchID=="0000"
replace State= "Colorado"

replace SchName= "All Schools" if DataLevel!= "School" 
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedSchID="" if DataLevel != "School"
replace StateAssignedDistID="" if DataLevel== "State"

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace AvgScaleScore="*" if AvgScaleScore=="- -"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving StudentSubGroup_TotalTested where suppressed
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited"
drop Unsuppressed*

*******************************************************
*Derivations [0 real changes made]
*******************************************************
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)* real(StudentSubGroup_TotalTested))) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_percent)) & missing(real(ProficientOrAbove_count))

//Removing "Empty" Observations for Subgroups
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"

//Standardize Names
replace DistName = strproper(DistName)
replace DistName = "McClave Re-2" if NCESDistrictID == "0805580"
replace DistName = "Weld Re-4" if NCESDistrictID == "0807350"
replace DistName = "Elizabeth School District" if NCESDistrictID == "0803720"

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested *_count *_percent {
	replace `var' = subinstr(`var', ",","",.)
	replace `var' = subinstr(`var', " ", "",.)
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
save "${Output}/CO_AssmtData_2021", replace
export delimited "${Output}/CO_AssmtData_2021", replace
* END of CO_2021.do
****************************************************
