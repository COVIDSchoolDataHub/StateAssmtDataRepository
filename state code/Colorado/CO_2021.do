

global path "/Users/hayden/Desktop/Research/CO/2021"
global nces "/Users/hayden/Desktop/Research/NCES"
global disagg "/Users/hayden/Desktop/Research/CO/Disaggregate/2021"

///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela

	
import excel "${path}/CO_OriginalData_2021_ela&mat.xlsx", sheet("CMAS ELA and Math") cellrange(A28:Y6477) firstrow case(lower) clear



save "${path}/CO_OriginalData_2021_ela&mat.dta", replace

	//imports and saves sci
	
import excel "${path}/CO_OriginalData_2021_sci.xlsx", sheet("CMAS Science") cellrange(A28:V831) firstrow case(lower) clear

gen content="sci"


save "${path}/CO_OriginalData_2021_sci.dta", replace


	////Combines math/ela with science scores
	
use "${path}/CO_OriginalData_2021_ela&mat.dta", clear



append using "${path}/CO_OriginalData_2021_sci.dta"


gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

save "${path}/CO_OriginalData_2021_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS
	
	
import excel "${disagg}/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Gender") cellrange(A28:Y6745) firstrow case(lower) clear


rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="ela"

save "${path}/CO_2021_ELA_gender.dta", replace



import excel "${disagg}/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Language Proficiency") cellrange(A28:Y20176) firstrow case(lower) clear


rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"
gen subject="ela"

save "${path}/CO_2021_ELA_language.dta", replace



import excel "${disagg}/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Race Ethnicity") cellrange(A28:Y23582) firstrow case(lower) clear


rename raceethnicity StudentSubGroup
gen StudentGroup = "Race"
gen subject="ela"

save "${path}/CO_2021_ELA_raceEthnicity.dta", replace



	//// MATH


import excel "${disagg}/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Gender") cellrange(A28:Y5909) firstrow case(lower) clear


rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="math"

save "${path}/CO_2021_mat_gender.dta", replace



import excel "${disagg}/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Language Proficiency") cellrange(A28:Y17667) firstrow case(lower) clear


rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"
gen subject="math"

save "${path}/CO_2021_mat_language.dta", replace



import excel "${disagg}/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Race Ethnicity") cellrange(A28:Y20645) firstrow case(lower) clear


rename raceethnicity StudentSubGroup
gen StudentGroup = "Race"
gen subject="math"

save "${path}/CO_2021_mat_raceEthnicity.dta", replace



	//// SCIENCE
	
	
import excel "${disagg}/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Gender") cellrange(A28:W1633) firstrow case(lower) clear


rename gender StudentSubGroup
gen StudentGroup = "Gender"
gen subject="sci"

save "${path}/CO_2021_sci_gender.dta", replace



import excel "${disagg}/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Language Proficiency") cellrange(A28:W4841) firstrow case(lower) clear


rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"
gen subject="sci"

save "${path}/CO_2021_sci_language.dta", replace



import excel "${disagg}/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Race Ethnicity") cellrange(A28:W5654) firstrow case(lower) clear


rename raceethnicity StudentSubGroup
gen StudentGroup = "Race"
gen subject="sci"


save "${path}/CO_2021_sci_raceEthnicity.dta", replace


///////// Section 3: Appending Disaggregate Data


use "${path}/CO_OriginalData_2021_all.dta", clear


/// some variables need to be renamed to append correctly

rename content subject


	//Appends subgroups
	
append using "${path}/CO_2021_ELA_gender.dta"
append using "${path}/CO_2021_mat_gender.dta"
append using "${path}/CO_2021_sci_gender.dta"
append using "${path}/CO_2021_ELA_language.dta"
append using "${path}/CO_2021_mat_language.dta"
append using "${path}/CO_2021_sci_language.dta"
append using "${path}/CO_2021_ELA_raceEthnicity.dta"
append using "${path}/CO_2021_mat_raceEthnicity.dta"
append using "${path}/CO_2021_sci_raceEthnicity.dta"


drop if level=="* The value for this field is not displayed in order to protect student privacy."
drop if level==""
drop if level=="* The value for this field is not displayed in order to ensure student privacy."


///////// Section 4: Merging NCES Variables


gen state_leaidnumber =.
gen state_leaid = string(state_leaidnumber)
replace state_leaid = "CO-" + districtcode

gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = districtcode + "-" + schoolcode


save "${path}/CO_OriginalData_2021_all.dta", replace

	// Merges district variables from NCES

import delimited "${nces}/NCES_2020-2021_District_Demographics_opt.csv", clear 
drop if state_fips != 8
save "${path}/CO_NCES_2021_District.dta", replace


use "${path}/CO_OriginalData_2021_all.dta", clear

merge m:1 state_leaid using "${path}/CO_NCES_2021_District.dta"


rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${path}/CO_OriginalData_2021_all.dta", replace


	// Merges school variables from NCES
import delimited "${nces}/NCES_2020-2021_School_Demographics_opt.csv", clear 
drop if state_fips != 8
save "${path}/CO_NCES_2021_School.dta", replace

use "${path}/CO_OriginalData_2021_all.dta", clear

merge m:1 seasch state_fips using "${path}/CO_NCES_2021_School.dta"
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
rename numberoftotalrecords StudentGroup_TotalTested
rename participationrate ParticipationRate
rename meanscalescore AvgScaleScore
rename state_name State
rename state_fips StateFips
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename district_agency_type DistrictType
rename charter Charter
rename state_location StateAbbrev
rename county_name CountyName
rename county_code CountyCode
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel


//Rename proficiency levels
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


//Combines ELA/Math proficiency levels 1 and 2 for consistancy with science assessments

destring numberdidnotyetmeetexpectat percentdidnotyetmeetexpecta Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent, replace ignore(",*-")

gen NewLev1_count=.
gen NewLev1_percent=.
replace NewLev1_count=numberdidnotyetmeetexpectat+Lev1_count
replace NewLev1_percent=percentdidnotyetmeetexpecta+Lev1_percent
replace NewLev1_count=numberdidnotyetmeetexpectat if Lev1_count==.
replace NewLev1_percent=percentdidnotyetmeetexpecta if Lev1_percent==.
replace NewLev1_count=Lev1_count if numberdidnotyetmeetexpectat==.
replace NewLev1_percent=Lev1_percent if percentdidnotyetmeetexpecta==.


drop Lev1_count Lev1_percent numberdidnotyetmeetexpectat percentdidnotyetmeetexpecta
rename NewLev1_count Lev1_count
rename NewLev1_percent Lev1_percent

tostring Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent, replace force
replace Lev1_count="*" if Lev1_count=="."
replace Lev2_count="*" if Lev2_count=="."
replace Lev3_count="*" if Lev3_count=="."
replace Lev4_count="*" if Lev4_count=="."
replace Lev1_percent="*" if Lev1_percent=="."
replace Lev2_percent="*" if Lev2_percent=="."
replace Lev3_percent="*" if Lev3_percent=="."
replace Lev4_percent="*" if Lev4_percent=="."

//	Create new variables

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Lev3 or Lev 4"
gen Lev5_count ="*" 
gen Lev5_percent="*"
gen SchYear = string(year)
replace SchYear="2020-21" if SchYear=="2021"
drop year



//	Reorder variables

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate



//	Drop unneccesary variables

drop numberofvalidscores numberofnoscores standarddeviation state_leaidnumber seaschnumber lea_name


// Relabel variable values

tab Subject
replace Subject="math" if Subject=="Mathematics"
replace Subject="math" if Subject=="Math"
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="ela" if Subject=="ELA"
replace Subject="sci" if Subject=="Science"

tab StudentSubGroup
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Not Reported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"
replace DataLevel="District" if DataLevel=="DISTRICT"
replace DataLevel="School" if DataLevel=="SCHOOL"
replace DataLevel="State" if DataLevel=="STATE"
replace seasch="0000-0000" if seasch=="000-000"
replace State_leaid="CO-0000" if State_leaid=="CO-000"
replace StateAssignedDistID="0000" if StateAssignedDistID=="000"
replace StateAssignedSchID="0000" if StateAssignedSchID=="000"
replace StateAbbrev="CO" if StateAbbrev==""


replace SchYear="2020-21"

tab GradeLevel

replace GradeLevel="G38" if GradeLevel=="All Grades"
replace GradeLevel="G03" if GradeLevel=="ELA Grade 03"
replace GradeLevel="G04" if GradeLevel=="ELA Grade 04"
replace GradeLevel="G05" if GradeLevel=="ELA Grade 05"
replace GradeLevel="G06" if GradeLevel=="ELA Grade 06"
replace GradeLevel="G07" if GradeLevel=="ELA Grade 07"
replace GradeLevel="G08" if GradeLevel=="ELA Grade 08"
replace GradeLevel="G09" if GradeLevel=="ELA Grade 09"
replace GradeLevel="G03" if GradeLevel=="English Language Arts Grade 03"
replace GradeLevel="G04" if GradeLevel=="English Language Arts Grade 04"
replace GradeLevel="G05" if GradeLevel=="English Language Arts Grade 05"
replace GradeLevel="G06" if GradeLevel=="English Language Arts Grade 06"
replace GradeLevel="G07" if GradeLevel=="English Language Arts Grade 07"
replace GradeLevel="G08" if GradeLevel=="English Language Arts Grade 08"
replace GradeLevel="G03" if GradeLevel=="Mathematics Grade 03"
replace GradeLevel="G04" if GradeLevel=="Mathematics Grade 04"
replace GradeLevel="G05" if GradeLevel=="Mathematics Grade 05"
replace GradeLevel="G06" if GradeLevel=="Mathematics Grade 06"
replace GradeLevel="G07" if GradeLevel=="Mathematics Grade 07"
replace GradeLevel="G08" if GradeLevel=="Mathematics Grade 08"
replace GradeLevel="G03" if GradeLevel=="Math Grade 03"
replace GradeLevel="G04" if GradeLevel=="Math Grade 04"
replace GradeLevel="G05" if GradeLevel=="Math Grade 05"
replace GradeLevel="G06" if GradeLevel=="Math Grade 06"
replace GradeLevel="G07" if GradeLevel=="Math Grade 07"
replace GradeLevel="G08" if GradeLevel=="Math Grade 08"
replace GradeLevel="G09" if GradeLevel=="Integrated I"
replace GradeLevel="G10" if GradeLevel=="Integrated II"
replace GradeLevel="G11" if GradeLevel=="Integrated III"
replace GradeLevel="G09" if GradeLevel=="Algebra I"
replace GradeLevel="G10" if GradeLevel=="Geometry"
replace GradeLevel="G11" if GradeLevel=="Algebra II"
replace GradeLevel="G05" if GradeLevel=="Science Grade 05"
replace GradeLevel="G08" if GradeLevel=="Science Grade 08"
replace GradeLevel="G10" if GradeLevel=="Science HS"
replace GradeLevel="G10" if GradeLevel=="HS"
replace StudentSubGroup="English proficient" if StudentSubGroup=="Not English Learner (Not EL)"
replace StudentSubGroup="English learner" if StudentSubGroup=="English Learner (EL)"
drop if StudentSubGroup=="EL: LEP (Limited English Proficient)"
drop if StudentSubGroup=="Not EL: FEP (Fluent English Proficient), FELL (Former English Language Learner)"
drop if StudentSubGroup=="Not EL: PHLOTE, NA, Not Reported"
drop if StudentSubGroup=="EL: NEP (Not English Proficient)"

tab GradeLevel



	// Drops observations that aren't grades 3 through 8
	
drop if GradeLevel=="G09"
drop if GradeLevel=="G10"
drop if GradeLevel=="G11"
drop if Subject=="Spanish Language Arts"


export delimited using "${path}/CO_2021_Data_Unmerged.csv", replace

drop if district_merge==2
drop if _merge==2
drop _merge
drop district_merge

destring StudentGroup_TotalTested, replace ignore(",* %NA<>=-")

export delimited using "${output}/CO_AssmtData_2021.csv", replace



