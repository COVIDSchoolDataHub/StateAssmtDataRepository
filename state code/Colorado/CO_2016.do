

global path "/Users/hayden/Desktop/Research/CO/2016"
global nces "/Users/hayden/Desktop/Research/NCES"
global disagg "/Users/hayden/Desktop/Research/CO/Disaggregate/2016"
global output "/Users/hayden/Desktop/Research/CO/Output"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela


import excel "${path}/CO_OriginalData_2016_ela&mat.xlsx", sheet("ELA") cellrange(A5:AB6776) firstrow case(lower) clear


	//dropping mean scale score from the previous year because it does not append properly, will be included in the 2016 data. 
	
drop y
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


save "${path}/CO_OriginalData_2016_ela&mat.dta", replace


	//imports and saves sci
	
import excel "${path}/CO_OriginalData_2016_sci.xlsx", sheet("District and School Detail_1") cellrange(A5:Z2652) firstrow case(lower) clear

rename numberpartiallymetexpectation Lev1_count
rename partiallymetexpectations Lev1_percent
rename numberapproachedexpectations Lev2_count
rename approachedexpectations Lev2_percent
rename numbermetexpectations Lev3_count
rename metexpectations Lev3_percent
rename numberexceededexpectations Lev4_count
rename exceededexpectations Lev4_percent
drop w 


save "${path}/CO_OriginalData_2016_sci.dta", replace



	////Combines math/ela with science scores
	
use "${path}/CO_OriginalData_2016_ela&mat.dta", clear

append using "${path}/CO_OriginalData_2016_sci.dta"

gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

rename numbermetorexceededexpectati ProficientOrAbove_count
rename metorexceededexpectations ProficientOrAbove_percent


save "${path}/CO_OriginalData_2016_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS

import excel "${disagg}/CO_2016_ELA_gender.xlsx", sheet("Sheet 1") cellrange(A4:X13433) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count


rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2016_ELA_gender.dta", replace



import excel "${disagg}/CO_2016_ELA_language.xlsx", sheet("Sheet1 1") cellrange(A4:X18852) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"

save "${path}/CO_2016_ELA_language.dta", replace


import excel "${disagg}/CO_2016_ELA_raceEthnicity.xlsx", sheet("Sheet1 1") cellrange(A4:X28167) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"

save "${path}/CO_2016_ELA_raceEthnicity.dta", replace


import excel "${disagg}/CO_2016_ELA_FreeReducedLunch.xlsx", sheet("Sheet 1") cellrange(A4:X13241) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${path}/CO_2016_ELA_econstatus.dta", replace


	//// MATH


import excel "${disagg}/CO_2016_mat_gender.xlsx", sheet("Sheet 1") cellrange(A4:X1048576) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2016_mat_gender.dta", replace



import excel "${disagg}/CO_2016_mat_language.xlsx", sheet("Sheet 1") cellrange(A4:X20891) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"

save "${path}/CO_2016_mat_language.dta", replace


import excel "${disagg}/CO_2016_mat_raceEthnicity.xlsx", sheet("Sheet 1") cellrange(A4:X31416) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"

save "${path}/CO_2016_mat_raceEthnicity.dta", replace


import excel "${disagg}/CO_2016_mat_FreeReducedLunch.xlsx", sheet("Sheet 1") cellrange(A4:X15210) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename v Lev5_percent
rename x ProficientOrAbove_percent
rename metorexceededexpectations ProficientOrAbove_count
rename didnotyetmeetexpectations Lev1_count
rename partiallymetexpectations Lev2_count
rename approachedexpectations Lev3_count
rename metexpectations Lev4_count
rename exceededexpectations Lev5_count
rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${path}/CO_2016_mat_econstatus.dta", replace


	//// SCIENCE
	
	
import excel "${disagg}/CO_2016_sci_gender.xlsx", sheet("Sheet 1") cellrange(A4:V5252) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename metorexceededexpectations ProficientOrAbove_count
rename v ProficientOrAbove_percent

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${path}/CO_2016_sci_gender.dta", replace



import excel "${disagg}/CO_2016_sci_language.xlsx", sheet("Sheet 1") cellrange(A4:V7326) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename metorexceededexpectations ProficientOrAbove_count
rename v ProficientOrAbove_percent
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"

save "${path}/CO_2016_sci_language.dta", replace



import excel "${disagg}/CO_2016_sci_raceEthnicity.xlsx", sheet("Sheet 1") cellrange(A4:V10962) firstrow case(lower) clear

rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename metorexceededexpectations ProficientOrAbove_count
rename v ProficientOrAbove_percent
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"

save "${path}/CO_2016_sci_raceEthnicity.dta", replace


import excel "${disagg}/CO_2016_sci_FreeReducedLunch.xlsx", sheet("Sheet 1") cellrange(A4:V1048576) firstrow case(lower) clear

drop if level==""
rename n Lev1_percent
rename p Lev2_percent
rename r Lev3_percent
rename t Lev4_percent
rename partiallymetexpectations Lev1_count
rename approachedexpectations Lev2_count
rename metexpectations Lev3_count
rename exceededexpectations Lev4_count
rename metorexceededexpectations ProficientOrAbove_count
rename v ProficientOrAbove_percent
rename freeandreducedlunch StudentSubGroup
gen StudentGroup = "Economic Status"

save "${path}/CO_2016_sci_econstatus.dta", replace


///////// Section 3: Appending Disaggregate Data


use "${path}/CO_OriginalData_2016_all.dta", clear


/// some variables need to be renamed to append correctly


rename numberoftotalrecords oftotalrecords
rename numberofvalidscores ofvalidscores
rename districtcode districtnumber
rename schoolcode schoolnumber


	//Appends subgroups
	
append using "${path}/CO_2016_ELA_gender.dta"
append using "${path}/CO_2016_mat_gender.dta"
append using "${path}/CO_2016_sci_gender.dta"
append using "${path}/CO_2016_ELA_language.dta"
append using "${path}/CO_2016_mat_language.dta"
append using "${path}/CO_2016_sci_language.dta"
append using "${path}/CO_2016_ELA_raceEthnicity.dta"
append using "${path}/CO_2016_mat_raceEthnicity.dta"
append using "${path}/CO_2016_sci_raceEthnicity.dta"
append using "${path}/CO_2016_ELA_econstatus.dta"
append using "${path}/CO_2016_mat_econstatus.dta"
append using "${path}/CO_2016_sci_econstatus.dta"


drop if level=="* The value for this field is not displayed in order to protect student privacy."
drop if level==""
drop if level=="* The value for this field is not displayed in order to ensure student privacy."


///////// Section 4: Merging NCES Variables


rename districtnumber state_leaid
rename schoolnumber seasch

save "${path}/CO_OriginalData_2016_all.dta", replace

	// Merges district variables from NCES

use "${nces}/NCES_2015_District.dta"
drop if state_fips != 8
save "${path}/CO_NCES_2015_District.dta", replace


use "${path}/CO_OriginalData_2016_all.dta", clear

merge m:1 state_leaid using "${path}/CO_NCES_2015_District.dta"


rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${path}/CO_OriginalData_2016_all.dta", replace
	// Merges school variables from NCES

use "${nces}/NCES_2015_School.dta"
drop if state_fips != 8
save "${path}/CO_NCES_2015_School.dta", replace


use "${path}/CO_OriginalData_2016_all.dta", clear	
	
	
merge m:1 seasch state_fips using "${path}/CO_NCES_2015_School.dta"
drop if state_fips != 8
drop if level == "13oct2016"


///////// Section 5: Reformatting

	// Renames variables 
	
rename level DataLevel
rename districtname DistName
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
rename district_agency_type DistType
rename state_location StateAbbrev
rename county_name CountyName
rename county_code CountyCode
rename school_type SchType


//Combines ELA/Math proficiency levels 1 and 2 for consistancy with science assessments

destring Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent, replace ignore(",*")


//	Create new variables

gen StateAssignedDistID=State_leaid
gen StateAssignedSchID=seasch

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Lev3 or Lev4"
gen SchYear = string(year)
replace SchYear="2015-16" if SchYear=="2016"
drop year


tostring Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent, replace force
replace Lev1_count="*" if Lev1_count=="."
replace Lev2_count="*" if Lev2_count=="."
replace Lev3_count="*" if Lev3_count=="."
replace Lev4_count="*" if Lev4_count=="."
replace Lev5_count="*" if Lev5_count=="."
replace Lev1_percent="*" if Lev1_percent=="."
replace Lev2_percent="*" if Lev2_percent=="."
replace Lev3_percent="*" if Lev3_percent=="."
replace Lev4_percent="*" if Lev4_percent=="."
replace Lev5_percent="*" if Lev5_percent=="."




// Relabel variable values

tab Subject
replace Subject="math" if Subject=="Mathematics"
replace Subject="math" if Subject=="Math"
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="ela" if Subject=="ELA"
replace Subject="sci" if Subject=="Science"
replace Subject="sci" if Subject=="Science             "
replace Subject="math" if Subject=="Mathematics         "
replace Subject="ela" if Subject=="English Lanuage Arts"


tab StudentSubGroup
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Not Reported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"
replace DataLevel="School" if DataLevel=="SCHOOL"
replace DataLevel="State" if DataLevel=="STATE"
replace DataLevel="District" if DataLevel=="DISTRICT"
replace DataLevel="School" if DataLevel=="School  "
replace DataLevel="State" if DataLevel=="State   "
replace seasch="0000-0000" if seasch=="000-000"
replace State_leaid="CO-0000" if State_leaid=="CO-000"
replace StateAssignedDistID="0000" if StateAssignedDistID=="000"
replace StateAssignedSchID="0000" if StateAssignedSchID=="000"
replace StateAbbrev="CO" if StateAbbrev==""
replace State=StateFips

replace SchYear="2015-16"


	//	Reformat grade level indicators

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
replace GradeLevel="G10" if GradeLevel=="Science HS      "
replace StudentSubGroup="English learner" if StudentSubGroup=="NEP - Non English Proficient    "
replace StudentSubGroup="English learner" if StudentSubGroup=="NEP - Non English Proficient"
replace StudentSubGroup="English proficient" if StudentSubGroup=="FEP - Fluent English Proficient "
replace StudentSubGroup="English proficient" if StudentSubGroup=="FEP - Fluent English Proficient"
replace StudentSubGroup="Other" if StudentSubGroup=="PHLOTE/FELL/NA                  "
replace StudentSubGroup="Other" if StudentSubGroup=="PHLOTE/FELL/NA"
drop if StudentSubGroup=="LEP - Limited English Proficient"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"


tab GradeLevel


replace StudentGroup=strrtrim(StudentGroup)
replace StudentSubGroup=strrtrim(StudentSubGroup)
replace SchName=strrtrim(SchName)
replace DistName=strrtrim(DistName)
replace AvgScaleScore=strrtrim(AvgScaleScore)
replace ProficientOrAbove_count=strrtrim(ProficientOrAbove_count)
replace ProficientOrAbove_percent=strrtrim(ProficientOrAbove_percent)
replace ParticipationRate=strrtrim(ParticipationRate)
	
	
	// Drops observations that aren't grades 3 through 8	
	
drop if GradeLevel=="G09"
drop if GradeLevel=="G10"
drop if GradeLevel=="G11"
drop if GradeLevel=="Science HS"



export delimited using "${path}/CO_2016_Data_Unmerged.csv", replace

drop if district_merge==2
drop if _merge==2
drop _merge
drop district_merge

destring StudentGroup_TotalTested ParticipationRate ProficientOrAbove_percent, replace ignore(",* %NA<>=-")

replace ParticipationRate=ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate="*" if ParticipationRate=="."

replace ProficientOrAbove_percent=ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="."



//// ADJUST PERCENTS

destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent, replace ignore(",* %NA<>=-")

replace Lev1_percent=Lev1_percent/100
replace Lev2_percent=Lev2_percent/100
replace Lev3_percent=Lev3_percent/100
replace Lev4_percent=Lev4_percent/100
replace Lev5_percent=Lev5_percent/100


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

save "${path}/CO_2016_base.dta", replace



collapse (sum) StudentSubGroup_TotalTested, by(NCESDistrictID NCESSchoolID intGrade intStudentGroup intSubject)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested


// Flag

save "${path}/CO_2016_studentgrouptotals.dta", replace


// Flag

use "${path}/CO_2016_base.dta", replace


// Flag

merge m:1 NCESDistrictID NCESSchoolID intGrade intSubject intStudentGroup using "${path}/CO_2016_studentgrouptotals.dta"

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="999999999"

replace StudentGroup_TotalTested=999999999 if StudentGroup_TotalTested>=10000000
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="999999999"


replace ProficiencyCriteria="Lev4 or Lev5" if Subject=="math"
replace ProficiencyCriteria="Lev4 or Lev5" if Subject=="ela"


////
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

replace SchName="PUEBLO YOUTH SERVICE CENTER" if NCESSchoolID=="080612006350"
replace SchName="MOUNTVIEW YOUTH SERVICE CENTER" if NCESSchoolID=="080480006347"
replace SchName="ADAMS YOUTH SERVICE CENTER" if NCESSchoolID=="080258006343"
replace SchName="SPRING CREEK YOUTH SERVICES CENTER" if NCESSchoolID=="080453006342"
replace SchName="PLATTE VALLEY YOUTH SERVICES CENTER" if NCESSchoolID=="080441006355"

replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="Free/Reduced Lunch Eligible"
replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="Not Free/Reduced Lunch Eligible"

replace Lev1_count="*" if Lev1_count=="-"
replace Lev2_count="*" if Lev2_count=="-"
replace Lev3_count="*" if Lev3_count=="-"
replace Lev4_count="*" if Lev4_count=="-"
replace Lev5_count="*" if Lev5_count=="-"
replace Lev1_percent="*" if Lev1_percent=="-"
replace Lev2_percent="*" if Lev2_percent=="-"
replace Lev3_percent="*" if Lev3_percent=="-"
replace Lev4_percent="*" if Lev4_percent=="-"
replace Lev5_percent="*" if Lev5_percent=="-"
replace AvgScaleScore="*" if AvgScaleScore=="-"
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="-"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="-"
replace ParticipationRate="*" if ParticipationRate=="-"

replace seasch="" if DataLevel==0
replace State_leaid="" if DataLevel==0
replace StateAssignedDistID="" if DataLevel==0

replace StudentSubGroup="Other" if StudentGroup=="EL Status" & StudentSubGroup=="Unknown"


export delimited using "${output}/CO_AssmtData_2016.csv", replace
