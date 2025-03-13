*******************************************************
* COLORADO

* File name: CO_2022
* Last update: 2/25/2025

*******************************************************
* Notes

	* This do file imports CO 2022 data, renames variables, cleans and saves it as a dta file.
	* NCES 2021 is merged with CO 2022 data. 
	* The non-derivation and usual output are created. 
*******************************************************
/////////////////////////////////////////
*** Setup ***
clear
*******************************************************
// Section 1: Appending Aggregate Data
*******************************************************
//Combines math/ela data with science data
//Imports and saves math/ela
	
import excel "$Original/2022/CO_OriginalData_2022_ela&mat.xlsx", sheet("CMAS ELA and Math") cellrange(A13:AC16856) firstrow case(lower) clear

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"

save "${Temp}/CO_OriginalData_2022_all.dta", replace

*******************************************************
// Section 2: Preparing Disaggregate Data
*******************************************************
// ENGLISH/LANGUAGE ARTS
	
import excel "$Original/2022/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Gender") cellrange(A13:Y16170) firstrow case(lower) clear
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="ela"
save "${Temp}/CO_2022_ELA_gender.dta", replace

import excel "$Original/2022/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Language Proficiency") cellrange(A13:Y48482) firstrow case(lower) clear
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen subject="ela"
save "${Temp}/CO_2022_ELA_language.dta", replace

import excel "$Original/2022/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Race Ethnicity") cellrange(A13:Y56673) firstrow case(lower) clear
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen subject="ela"
save "${Temp}/CO_2022_ELA_raceEthnicity.dta", replace

import excel "$Original/2022/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Free Reduced Lunch") cellrange(A13:Y16170) firstrow case(lower) clear
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen subject="ela"
save "${Temp}/CO_2022_ELA_econstatus.dta", replace

import excel "$Original/2022/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Migrant") cellrange(A13:Y16169) firstrow case(lower) clear
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen subject="ela"
save "${Temp}/CO_2022_ELA_migrantstatus.dta", replace

import excel "$Original/2022/2022 CMAS ELA School and District Achievement Results - Disaggregated by Group.xlsx", sheet("IEP") cellrange(A13:Y16169) firstrow case(lower) clear
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen subject="ela"
save "${Temp}/CO_2022_ELA_disabilitystatus.dta", replace

// MATH

import excel "$Original/2022/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Gender") cellrange(A13:Y16166) firstrow case(lower) clear
rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="math"
save "${Temp}/CO_2022_mat_gender.dta", replace

import excel "$Original/2022/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Language Proficiency") cellrange(A13:Y48470) firstrow case(lower) clear
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL Status"
gen subject="math"
save "${Temp}/CO_2022_mat_language.dta", replace

import excel "$Original/2022/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Race Ethnicity") cellrange(A13:Y56659) firstrow case(lower) clear
rename raceethnicity StudentSubGroup
gen StudentGroup = "RaceEth"
gen subject="math"
save "${Temp}/CO_2022_mat_raceEthnicity.dta", replace

import excel "$Original/2022/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Free Reduced Lunch") cellrange(A13:Y16166) firstrow case(lower) clear
rename freereducedlunchstatus StudentSubGroup
gen StudentGroup = "Economic Status"
gen subject="math"
save "${Temp}/CO_2022_mat_econstatus.dta", replace

import excel "$Original/2022/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("Migrant") cellrange(A13:Y16165) firstrow case(lower) clear
rename migrant StudentSubGroup
gen StudentGroup = "Migrant Status"
gen subject="math"
save "${Temp}/CO_2022_mat_migrantstatus.dta", replace

import excel "$Original/2022/2022 CMAS Math School and District Achievement Results - Disaggregated by Group.xlsx", sheet("IEP") cellrange(A13:Y16165) firstrow case(lower) clear
rename iepstatus StudentSubGroup
gen StudentGroup = "Disability Status"
gen subject="math"
save "${Temp}/CO_2022_mat_disabilitystatus.dta", replace

*******************************************************
// Section 3: Appending Disaggregate Data
*******************************************************

use "${Temp}/CO_OriginalData_2022_all.dta", clear

// some variables need to be renamed to append correctly
rename content subject
rename z percentmetorexceededexpectat 
drop aa ab change2019to2022

//Appends subgroups
	
append using "${Temp}/CO_2022_ELA_gender.dta"
append using "${Temp}/CO_2022_mat_gender.dta"
append using "${Temp}/CO_2022_ELA_language.dta"
append using "${Temp}/CO_2022_mat_language.dta"
append using "${Temp}/CO_2022_ELA_raceEthnicity.dta"
append using "${Temp}/CO_2022_mat_raceEthnicity.dta"
append using "${Temp}/CO_2022_mat_econstatus.dta"
append using "${Temp}/CO_2022_ELA_econstatus.dta"
append using "${Temp}/CO_2022_ELA_migrantstatus.dta"
append using "${Temp}/CO_2022_mat_migrantstatus.dta"
append using "${Temp}/CO_2022_ELA_disabilitystatus.dta"
append using "${Temp}/CO_2022_mat_disabilitystatus.dta"


drop if level=="* The value for this field is not displayed in order to protect student privacy."
drop if level==""
drop if level=="* The value for this field is not displayed in order to ensure student privacy."

*******************************************************
/// Section 4: Merging NCES Variables
*******************************************************
gen state_leaidnumber =.
gen state_leaid = string(state_leaidnumber)
replace state_leaid = "CO-" + districtcode

gen seasch=""
replace seasch = districtcode + "-" + schoolcode

save "${Original_Cleaned}/CO_OriginalData_2022.dta", replace

// Merges district variables from NCES
use "${NCES_District}/NCES_2021_District.dta", clear
drop if state_fips != 8
save "${NCES_CO}/NCES_2021_District_CO.dta", replace

use "${Original_Cleaned}/CO_OriginalData_2022.dta", clear
merge m:1 state_leaid using "${NCES_CO}/NCES_2021_District_CO.dta"

rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${Original_Cleaned}/CO_OriginalData_2022.dta", replace

// Merges school variables from NCES
	
use "${NCES_School}/NCES_2021_School.dta", clear
drop if state_fips != 8
save "${NCES_CO}/NCES_2021_School_CO.dta", replace

use "${Original_Cleaned}/CO_OriginalData_2022.dta", clear

merge m:1 seasch using "${NCES_CO}/NCES_2021_School_CO.dta"	
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
rename ncesschoolid NCES_SchoolID
rename ncesdistrictid NCES_DistrictID
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
rename numbermetorexceededexpectati Prof_c
rename percentmetorexceededexpectat Prof_p

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

//StudentSubGroup_TotalTested
replace StudentSubGroup_TotalTested = "0-15" if strpos(StudentSubGroup_TotalTested, "<16") !=0 | strpos(StudentSubGroup_TotalTested, "< 16") !=0
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)

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

drop if district_merge==2
drop if _merge==2
drop _merge
drop district_merge

destring ParticipationRate, replace ignore(",* %NA<>=-")
replace ParticipationRate=ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate="*" if ParticipationRate=="."

//StudentGroup_TotalTested
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)

//Deriving StudentSubGroup_TotalTested where suppressed
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(StudentGroup_TotalTested)) & real(StudentGroup_TotalTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited"
drop Unsuppressed*

//// ADJUST PERCENTS AND COUNTS
forvalues n = 1/5{
	replace Lev`n'_count = subinstr(Lev`n'_count, ",", "", 1)
	replace Lev`n'_count = strtrim(Lev`n'_count)
	destring Lev`n'_percent, replace force
	replace Lev`n'_percent = Lev`n'_percent/100
	tostring Lev`n'_percent, replace format("%9.3g") force
	replace Lev`n'_percent = "*" if Lev`n'_percent == "."
	replace Lev`n'_count = "*" if Lev`n'_count == "- -"
}

destring Lev4_count, gen(Lev4_c) force
destring Lev4_percent, gen(Lev4_p) force
destring Lev5_count, gen(Lev5_c) force
destring Lev5_percent, gen(Lev5_p) force
replace Prof_c = subinstr(Prof_c, ",", "", .)
destring Prof_c, gen(Prof_count) force
destring Prof_p, gen(Prof_percent) force
replace Prof_percent = Prof_percent/100

gen ProficientOrAbove_count = Lev4_c + Lev5_c
gen ProficientOrAbove_percent = Lev4_p + Lev5_p

replace ProficientOrAbove_percent = Prof_percent if ProficientOrAbove_percent == . & Prof_percent != .
replace ProficientOrAbove_count = Prof_count if ProficientOrAbove_count == . & Prof_count != .

*Temporarily saving the file so we can restore it for the usual output. 
save "${Temp}/CO_OriginalData_2022.dta", replace

tostring ProficientOrAbove_count, replace
tostring ProficientOrAbove_count, replace
tostring ProficientOrAbove_percent, replace format("%9.3g") force
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Prof_c == ""
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Prof_c == "- -"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "." & Prof_p == "- -"

drop Lev4_c Lev4_p Lev5_c Lev5_p Prof_c Prof_p Prof_count Prof_percent

//Removing "Empty" Observations for Subgroups
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
gen AllPart = ParticipationRate if StudentSubGroup == "All Students"
replace AllPart = AllPart[_n-1] if missing(AllPart) & StudentSubGroup != "All Students"
gen flag = 1 if AllPart == "0" & StudentSubGroup != "All Students" & inlist(ProficientOrAbove_percent, "*", "--")
drop if flag == 1
drop AllPart flag

////
replace StateAbbrev="CO" if StateAbbrev==""
replace StateAssignedSchID="" if StateAssignedSchID=="0000"
replace StateAssignedSchID="" if StateAssignedSchID=="0000"

tostring NCES_DistrictID, replace force
tostring NCES_SchoolID, replace force

replace AvgScaleScore="*" if AvgScaleScore=="- -"
replace StateAssignedSchID="" if DataLevel != "School"
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedDistID="" if DataLevel=="State"
replace DistName = "All Districts" if DataLevel=="State"

replace Lev5_count="*" if Lev5_count==""
replace ProficientOrAbove_count="*" if ProficientOrAbove_count==""
replace AvgScaleScore="*" if AvgScaleScore==""

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Standardize Names
replace DistName = strproper(DistName)
replace DistName = "McClave Re-2" if NCES_DistrictID == "0805580"
replace DistName = "Weld Re-4" if NCES_DistrictID == "0807350"
replace DistName = "Elizabeth School District" if NCES_DistrictID == "0803720"

rename NCES_DistrictID NCESDistrictID
rename NCES_SchoolID NCESSchoolID

foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested *_count *_percent {
	replace `var' = subinstr(`var', ",","",.)
	replace `var' = subinstr(`var', " ", "",.)
}

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

*Exporting Non-Derivation Output*
save "${Output_ND}/CO_AssmtData_2022_ND", replace
export delimited "${Output_ND}/CO_AssmtData_2022_ND", replace

*******************************************************
*Derivations
*******************************************************
use "${Temp}/CO_OriginalData_2022.dta", clear

replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, ",", "", 1)
replace ProficientOrAbove_count = round(ProficientOrAbove_percent * real(StudentSubGroup_TotalTested)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(ProficientOrAbove_percent) & missing(ProficientOrAbove_count)

tostring ProficientOrAbove_count, replace
tostring ProficientOrAbove_count, replace
tostring ProficientOrAbove_percent, replace format("%9.3g") force
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Prof_c == ""
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Prof_c == "- -"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "." & Prof_p == "- -"

//Removing "Empty" Observations for Subgroups
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
gen AllPart = ParticipationRate if StudentSubGroup == "All Students"
replace AllPart = AllPart[_n-1] if missing(AllPart) & StudentSubGroup != "All Students"
gen flag = 1 if AllPart == "0" & StudentSubGroup != "All Students" & inlist(ProficientOrAbove_percent, "*", "--")
drop if flag == 1
drop AllPart flag

////
replace StateAbbrev="CO" if StateAbbrev==""
replace StateAssignedSchID="" if StateAssignedSchID=="0000"
replace StateAssignedSchID="" if StateAssignedSchID=="0000"

tostring NCES_DistrictID, replace force
tostring NCES_SchoolID, replace force

replace AvgScaleScore="*" if AvgScaleScore=="- -"
replace StateAssignedSchID="" if DataLevel != "School"
replace SchName = "All Schools" if DataLevel != "School"
replace StateAssignedDistID="" if DataLevel=="State"
replace DistName = "All Districts" if DataLevel=="State"

replace Lev5_count="*" if Lev5_count==""
replace ProficientOrAbove_count="*" if ProficientOrAbove_count==""
replace AvgScaleScore="*" if AvgScaleScore==""

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Standardize Names
replace DistName = strproper(DistName)
replace DistName = "McClave Re-2" if NCES_DistrictID == "0805580"
replace DistName = "Weld Re-4" if NCES_DistrictID == "0807350"
replace DistName = "Elizabeth School District" if NCES_DistrictID == "0803720"

rename NCES_DistrictID NCESDistrictID
rename NCES_SchoolID NCESSchoolID

drop Prof_count Prof_percent

foreach var of varlist StudentGroup_TotalTested StudentSubGroup_TotalTested *_count *_percent {
	replace `var' = subinstr(`var', ",","",.)
	replace `var' = subinstr(`var', " ", "",.)
}

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output*
save "${Output}/CO_AssmtData_2022", replace
export delimited "${Output}/CO_AssmtData_2022", replace
* END of CO_2022.do
****************************************************
