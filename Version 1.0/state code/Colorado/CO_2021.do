
global path "/Users/hayden/Desktop/Research/CO/2021"
global nces "/Users/hayden/Desktop/Research/NCES"
global disagg "/Users/hayden/Desktop/Research/CO/Disaggregate/2021"
global output "/Users/hayden/Desktop/Research/CO/Output"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela

	
import excel "${path}/CO_OriginalData_2021_ela&mat.xlsx", sheet("CMAS ELA and Math") cellrange(A28:Y6477) firstrow case(lower) clear

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

save "${path}/CO_OriginalData_2021_ela&mat.dta", replace

	//imports and saves sci
	
import excel "${path}/CO_OriginalData_2021_sci.xlsx", sheet("CMAS Science") cellrange(A28:V831) firstrow case(lower) clear

rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
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

save "${path}/CO_2021_ELA_gender.dta", replace



import excel "${disagg}/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Language Proficiency") cellrange(A28:Y20176) firstrow case(lower) clear

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
gen StudentGroup = "EL status"
gen subject="ela"

save "${path}/CO_2021_ELA_language.dta", replace



import excel "${disagg}/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Race Ethnicity") cellrange(A28:Y23582) firstrow case(lower) clear

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
gen StudentGroup = "Race"
gen subject="ela"

save "${path}/CO_2021_ELA_raceEthnicity.dta", replace


import excel "${disagg}/2021 CMAS ELA District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Free Reduced Lunch") cellrange(A30:Y6747) firstrow case(lower) clear

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

save "${path}/CO_2021_ELA_econstatus.dta", replace


	//// MATH


import excel "${disagg}/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Gender") cellrange(A28:Y5909) firstrow case(lower) clear

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

save "${path}/CO_2021_mat_gender.dta", replace



import excel "${disagg}/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Language Proficiency") cellrange(A28:Y17667) firstrow case(lower) clear

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
gen StudentGroup = "EL status"
gen subject="math"

save "${path}/CO_2021_mat_language.dta", replace



import excel "${disagg}/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Race Ethnicity") cellrange(A28:Y20645) firstrow case(lower) clear

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
gen StudentGroup = "Race"
gen subject="math"

save "${path}/CO_2021_mat_raceEthnicity.dta", replace


import excel "${disagg}/2021 CMAS Math District and School Achievement Results Disaggregated by Subgroups - Required Tests.xlsx", sheet("Free Reduced Lunch") cellrange(A30:Y5911) firstrow case(lower) clear

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

save "${path}/CO_2021_mat_econstatus.dta", replace



	//// SCIENCE
	
	
import excel "${disagg}/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Gender") cellrange(A28:W1633) firstrow case(lower) clear

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


save "${path}/CO_2021_sci_gender.dta", replace



import excel "${disagg}/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Language Proficiency") cellrange(A28:W4841) firstrow case(lower) clear

rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"
gen subject="sci"

save "${path}/CO_2021_sci_language.dta", replace



import excel "${disagg}/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Race Ethnicity") cellrange(A28:W5654) firstrow case(lower) clear

rename numberpartiallymetexpectation Lev1_count
rename percentpartiallymetexpectatio Lev1_percent
rename numberapproachedexpectations Lev2_count
rename percentapproachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename percentmetexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename percentexceededexpectations Lev4_percent
rename raceethnicity StudentSubGroup
gen StudentGroup = "Race"
gen subject="sci"


save "${path}/CO_2021_sci_raceEthnicity.dta", replace


import excel "${disagg}/2021 CMAS Science District and School Achievement Results Disaggregated by Subgroups.xlsx", sheet("Free Reduced Lunch") cellrange(A30:W1635) firstrow case(lower) clear

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

save "${path}/CO_2021_sci_econstatus.dta", replace



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
append using "${path}/CO_2021_ELA_econstatus.dta"
append using "${path}/CO_2021_mat_econstatus.dta"
append using "${path}/CO_2021_sci_econstatus.dta"


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
	
use "${nces}/NCES_2020_District.dta"
drop if state_fips != 8
save "${path}/CO_NCES_2020_District.dta", replace


use "${path}/CO_OriginalData_2021_all.dta"
merge m:1 state_leaid using "${path}/CO_NCES_2020_District.dta"

rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${path}/CO_OriginalData_2021_all.dta", replace


	// Merges school variables from NCES
	
use "${nces}/NCES_2020_School.dta"
drop if state_fips != 8
save "${path}/CO_NCES_2020_School.dta", replace


use "${path}/CO_OriginalData_2021_all.dta"
	
merge m:1 seasch state_fips using "${path}/CO_NCES_2020_School.dta"
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
rename district_agency_type DistType
rename state_location StateAbbrev
rename county_name CountyName
rename county_code CountyCode
rename school_type SchType


rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent


//	Create new variables

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Lev3 or Lev4"
gen SchYear = string(year)
replace SchYear="2020-21" if SchYear=="2021"
drop year


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

replace GradeLevel="G03" if GradeLevel=="03"
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G06" if GradeLevel=="06"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"
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

destring StudentGroup_TotalTested ParticipationRate, replace ignore(",* %NA<>=-")
replace ParticipationRate=ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate="*" if ParticipationRate=="."



//// ADJUST PERCENTS

destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent, replace ignore(",* %NA<>=-")

replace Lev1_percent=Lev1_percent/100
replace Lev2_percent=Lev2_percent/100
replace Lev3_percent=Lev3_percent/100
replace Lev4_percent=Lev4_percent/100
replace Lev5_percent=Lev5_percent/100
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100

 
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent, replace force

replace Lev1_percent="*" if Lev1_percent=="."
replace Lev2_percent="*" if Lev2_percent=="."
replace Lev3_percent="*" if Lev3_percent=="."
replace Lev4_percent="*" if Lev4_percent=="."
replace Lev5_percent="*" if Lev5_percent=="."
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="."



//// Generates SubGroup totals

rename StudentGroup_TotalTested StudentSubGroup_TotalTested

gen intGrade=.
gen intStudentGroup=.
gen intSubject=. 

replace intGrade=3 if GradeLevel=="G03"
replace intGrade=4 if GradeLevel=="G04"
replace intGrade=5 if GradeLevel=="G05"
replace intGrade=6 if GradeLevel=="G06"
replace intGrade=7 if GradeLevel=="G07"
replace intGrade=8 if GradeLevel=="G08"
replace intGrade=9 if GradeLevel=="G38"

replace intSubject=1 if Subject=="math"
replace intSubject=2 if Subject=="ela"
replace intSubject=3 if Subject=="soc"
replace intSubject=4 if Subject=="sci"

replace intStudentGroup=1 if StudentGroup=="All students"
replace intStudentGroup=2 if StudentGroup=="Gender"
replace intStudentGroup=3 if StudentGroup=="Race"
replace intStudentGroup=4 if StudentGroup=="EL status"


replace StudentSubGroup_TotalTested=999999999 if StudentSubGroup_TotalTested==.


// Flag

save "${path}/CO_2021_base.dta", replace



collapse (sum) StudentSubGroup_TotalTested, by(NCESDistrictID NCESSchoolID intGrade intStudentGroup intSubject)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested


// Flag

save "${path}/CO_2021_studentgrouptotals.dta", replace


// Flag

use "${path}/CO_2021_base.dta", replace


// Flag

merge m:1 NCESDistrictID NCESSchoolID intGrade intSubject intStudentGroup using "${path}/CO_2021_studentgrouptotals.dta"

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="999999999"

replace StudentGroup_TotalTested=999999999 if StudentGroup_TotalTested>=10000000
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="999999999"



////
replace ProficiencyCriteria="Lev4 or Lev5" if Subject=="math"
replace ProficiencyCriteria="Lev4 or Lev5" if Subject=="ela"

replace StateAssignedSchID="" if StateAssignedSchID=="0000"
replace State=8

replace StateAssignedSchID="" if StateAssignedSchID=="0000"
replace StudentSubGroup="All Students" if StudentSubGroup=="All students"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="English Learner" if StudentSubGroup=="English learner"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="English proficient"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"

replace StudentGroup="All Students" if StudentGroup=="All students"
replace StudentGroup="EL Status" if StudentGroup=="EL status"
replace StudentGroup="RaceEth" if StudentGroup=="Race"



keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

replace SchName="All Schools" if DataLevel=="State"
replace SchName="All Schools" if DataLevel=="District"


replace DataLevel="0" if DataLevel=="State"
replace DataLevel="1" if DataLevel=="District"
replace DataLevel="2" if DataLevel=="School"

destring DataLevel, replace force

label define LevelIndicator 0 "State" 1 "District" 2 "School"
label values DataLevel LevelIndicator

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="Free/Reduced Lunch Eligible"
replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="Not Free/Reduced Lunch Eligible"


replace Lev1_count="*" if Lev1_count=="- -"
replace Lev2_count="*" if Lev2_count=="- -"
replace Lev3_count="*" if Lev3_count=="- -"
replace Lev4_count="*" if Lev4_count=="- -"
replace Lev5_count="*" if Lev5_count=="- -"
replace Lev1_percent="*" if Lev1_percent=="- -"
replace Lev2_percent="*" if Lev2_percent=="- -"
replace Lev3_percent="*" if Lev3_percent=="- -"
replace Lev4_percent="*" if Lev4_percent=="- -"
replace Lev5_percent="*" if Lev5_percent=="- -"
replace AvgScaleScore="*" if AvgScaleScore=="- -"
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="- -"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="- -"
replace ParticipationRate="*" if ParticipationRate=="- -"

replace StudentSubGroup="Other" if StudentGroup=="EL Status" & StudentSubGroup=="Unknown"


replace seasch="" if DataLevel==0
replace State_leaid="" if DataLevel==0
replace StateAssignedDistID="" if DataLevel==0

replace Lev5_count="*" if Lev5_count==""
replace ProficientOrAbove_count="*" if ProficientOrAbove_count==""


export delimited using "${output}/CO_AssmtData_2021.csv", replace



