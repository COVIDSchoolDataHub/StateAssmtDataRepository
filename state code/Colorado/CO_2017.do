
global path "/Users/hayden/Desktop/Research/CO/2017"
global nces "/Users/hayden/Desktop/Research/NCES"
global disagg "/Users/hayden/Desktop/Research/CO/Disaggregate/2017"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela


import excel "${path}/CO_OriginalData_2017_ela&mat.xlsx", sheet("District and School Detail_1") cellrange(A5:AB14761) firstrow case(lower) clear


	//dropping mean scale score from the previous year because it does not append properly, will be included in the 2016 data. 
	
drop y

save "${path}/CO_OriginalData_2017_ela&mat.dta", replace


	//imports and saves sci
	
import excel "${path}/CO_OriginalData_2017_sci.xlsx", sheet("District and School Detail_1") cellrange(A4:Z2691) firstrow case(lower) clear

drop w 


save "${path}/CO_OriginalData_2017_sci.dta", replace



	////Combines math/ela with science scores
	
use "${path}/CO_OriginalData_2017_ela&mat.dta", clear

append using "${path}/CO_OriginalData_2017_sci.dta"

gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

save "${path}/CO_OriginalData_2017_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS

import excel "${disagg}/CO_2017_ELA_gender.xlsx", sheet("Sheet1_1") cellrange(A4:X13528) firstrow case(lower) clear

rename n percentdidnotyetmeetexpectations
rename p percentpartiallymetexpectations
rename r percentapproachedexpectations
rename t percentmetexpectations
rename v percentexceededexpectations
rename x percentmetorexceededexpectations
rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2017_ELA_gender.dta", replace



import excel "${disagg}/CO_2017_ELA_language.xlsx", sheet("Sheet1_1") cellrange(A4:X18814) firstrow case(lower) clear

rename n percentdidnotyetmeetexpectations
rename p percentpartiallymetexpectations
rename r percentapproachedexpectations
rename t percentmetexpectations
rename v percentexceededexpectations
rename x percentmetorexceededexpectations
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"

save "${path}/CO_2017_ELA_language.dta", replace


import excel "${disagg}/CO_2017_ELA_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:X28482) firstrow case(lower) clear

rename n percentdidnotyetmeetexpectations
rename p percentpartiallymetexpectations
rename r percentapproachedexpectations
rename t percentmetexpectations
rename v percentexceededexpectations
rename x percentmetorexceededexpectations
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"

save "${path}/CO_2017_ELA_raceEthnicity.dta", replace




	//// MATH


import excel "${disagg}/CO_2017_mat_gender.xlsx", sheet("Sheet1_1") cellrange(A4:X15544) firstrow case(lower) clear

rename n percentdidnotyetmeetexpectations
rename p percentpartiallymetexpectations
rename r percentapproachedexpectations
rename t percentmetexpectations
rename v percentexceededexpectations
rename x percentmetorexceededexpectations
rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2017_mat_gender.dta", replace



import excel "${disagg}/CO_2017_mat_language.xlsx", sheet("Sheet1_1") cellrange(A4:X20788) firstrow case(lower) clear

rename n percentdidnotyetmeetexpectations
rename p percentpartiallymetexpectations
rename r percentapproachedexpectations
rename t percentmetexpectations
rename v percentexceededexpectations
rename x percentmetorexceededexpectations
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"

save "${path}/CO_2017_mat_language.dta", replace



import excel "${disagg}/CO_2017_mat_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:X31642) firstrow case(lower) clear

rename n percentdidnotyetmeetexpectations
rename p percentpartiallymetexpectations
rename r percentapproachedexpectations
rename t percentmetexpectations
rename v percentexceededexpectations
rename x percentmetorexceededexpectations
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"

save "${path}/CO_2017_mat_raceEthnicity.dta", replace


	//// SCIENCE
	
	

import excel "${disagg}/CO_2017_sci_gender.xlsx", sheet("Sheet1_1") cellrange(A4:V5319) firstrow case(lower) clear
	
rename n percentpartiallymetexpectations
rename p percentapproachedexpectations
rename r percentmetexpectations
rename t percentexceededexpectations
rename v percentmetorexceededexpectations
rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2017_sci_gender.dta", replace



import excel "${disagg}/CO_2017_sci_language.xlsx", sheet("Sheet1_1") cellrange(A4:V7396) firstrow case(lower) clear

rename n percentpartiallymetexpectations
rename p percentapproachedexpectations
rename r percentmetexpectations
rename t percentexceededexpectations
rename v percentmetorexceededexpectations
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"

save "${path}/CO_2017_sci_language.dta", replace



import excel "${disagg}/CO_2017_sci_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A4:V11185) firstrow case(lower) clear

rename n percentpartiallymetexpectations
rename p percentapproachedexpectations
rename r percentmetexpectations
rename t percentexceededexpectations
rename v percentmetorexceededexpectations
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"

save "${path}/CO_2017_sci_raceEthnicity.dta", replace


///////// Section 3: Appending Disaggregate Data


use "${path}/CO_OriginalData_2017_all.dta", clear


/// some variables need to be renamed to append correctly


rename numberoftotalrecords oftotalrecords
rename numberofvalidscores ofvalidscores
rename districtcode districtnumber
rename schoolcode schoolnumber
rename numberdidnotyetmeetexpect didnotyetmeetexpectations
rename didnotyetmeetexpectation percentdidnotyetmeetexpectations
rename partiallymetexpectations percentpartiallymetexpectations
rename numberpartiallymetexpectati partiallymetexpectations
rename approachedexpectations percentapproachedexpectations
rename numberapproachedexpectations approachedexpectations
rename metexpectations percentmetexpectations
rename numbermetexpectations metexpectations
rename exceededexpectations percentexceededexpectations
rename numberexceededexpectations exceededexpectations
rename metorexceededexpectations percentmetorexceededexpectations
rename numbermetorexceededexpecta metorexceededexpectations


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


drop if level=="* The value for this field is not displayed in order to protect student privacy."
drop if level=="09aug2017"
drop if level==""
drop if level=="* The value for this field is not displayed in order to ensure student privacy."


///////// Section 4: Merging NCES Variables


gen state_leaidnumber =.
gen state_leaid = string(state_leaidnumber)
replace state_leaid = "CO-" + districtnumber

gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = districtnumber + "-" + schoolnumber


save "${path}/CO_OriginalData_2017_all.dta", replace



	// Merges district variables from NCES

use "${nces}/NCES_2016_District.dta"
drop if state_fips != 8
save "${path}/CO_NCES_2016_District.dta", replace


use "${path}/CO_OriginalData_2017_all.dta", clear

merge m:1 state_leaid using "${path}/CO_NCES_2016_District.dta"


rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8


	// Merges school variables from NCES

merge m:1 seasch state_fips using "${nces}/NCES_2016_School.dta"
drop if state_fips != 8



///////// Section 5: Reformatting


	// Renames variables 
	
rename level DataLevel
rename districtnumber StateAssignedDistID
rename districtname DistName
rename schoolnumber StateAssignedSchID
rename schoolname SchName
rename content Subject
rename test GradeLevel
rename oftotalrecords StudentGroup_TotalTested
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
rename partiallymetexpectations Lev1_count
rename percentpartiallymetexpectations Lev1_percent
rename approachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename metexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename exceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename metorexceededexpectations ProficientOrAbove_count
rename percentmetorexceededexpectations ProficientOrAbove_percent


//Combines ELA/Math proficiency levels 1 and 2 for consistancy with science assessments

destring didnotyetmeetexpectations percentdidnotyetmeetexpectations Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent, replace ignore(",*")

gen NewLev1_count=.
gen NewLev1_percent=.
replace NewLev1_count=didnotyetmeetexpectations+Lev1_count
replace NewLev1_percent=percentdidnotyetmeetexpectations+Lev1_percent
replace NewLev1_count=didnotyetmeetexpectations if Lev1_count==.
replace NewLev1_percent=percentdidnotyetmeetexpectations if Lev1_percent==.
replace NewLev1_count=Lev1_count if didnotyetmeetexpectations==.
replace NewLev1_percent=Lev1_percent if percentdidnotyetmeetexpectations==.


drop Lev1_count Lev1_percent didnotyetmeetexpectations percentdidnotyetmeetexpectations
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
replace SchYear="2016-17" if SchYear=="2017"
drop year



//	Reorder variables

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate



//	Drop unneccesary variables

drop ofvalidscores numberofnoscores numbermetorexceededex metorexceededexpecta changeinmetorexceededex numbermetorexceededexp metorexceededexpectat changeinmetorexceededexp state_leaidnumber seaschnumber lea_name


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
replace State=StateFips


replace SchYear="2016-17"

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
replace StudentSubGroup="English learner" if StudentSubGroup=="NEP - Non English Proficient"
replace StudentSubGroup="English proficient" if StudentSubGroup=="FEP - Fluent English Proficient"
replace StudentSubGroup="Other" if StudentSubGroup=="PHLOTE/FELL/NA"
drop if StudentSubGroup=="LEP - Limited English Proficient"

tab GradeLevel

replace DataLevel="District" if StateAssignedDistID!="0000" & StateAssignedSchID=="0000"
replace DataLevel="School" if StateAssignedDistID!="0000" & StateAssignedSchID!="0000"
replace DataLevel="State" if StateAssignedDistID=="0000" & StateAssignedSchID=="0000"

	// Drops observations that aren't grades 3 through 8
	
drop if GradeLevel=="G09"
drop if GradeLevel=="G10"


export delimited using "${path}/CO_2017_Data_Unmerged.csv", replace

drop if district_merge==2
drop if _merge==2
drop _merge
drop district_merge

destring StudentGroup_TotalTested, replace ignore(",* %NA<>=-")


export delimited using "${output}/CO_AssmtData_2017.csv", replace


