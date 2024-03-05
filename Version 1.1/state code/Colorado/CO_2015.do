
clear all

cd "/Users/miramehta/Documents"

local path "/Users/miramehta/Documents/CO State Testing Data/2015"
global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global output "/Users/miramehta/Documents/CO State Testing Data"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science and social studies data
	

	//Imports and saves math/ela


import excel "${path}/CO_OriginalData_2015_ela&mat.xlsx", sheet("Achievement Results") cellrange(A3:Y16806) firstrow case(lower) clear

	// Rename to append sci/social studies

rename contentarea subject
rename test grade
rename numberdidnotyetmeetexpectat Lev1_count
rename percentdidnotyetmeetexpecta Lev1_percent
rename numberpartiallymetexpectation Lev2_count
rename percentpartiallymetexpectatio Lev2_percent
rename numberapproachedexpectations Lev3_count
rename percentapproachedexpectations Lev3_percent
rename numbermetexpectations Lev4_count
rename percentmetexpectations Lev4_percent
rename numberexceededexpectations Lev5_count
rename percentexceededexpecations Lev5_percent
rename numbermetorexceededexpectati ProficientOrAbove_count
rename percentmetorexceededexpectat ProficientOrAbove_percent


save "${output}/CO_OriginalData_2015_ela&mat.dta", replace


	//imports and saves sci
	
import excel "${path}/CO_OriginalData_2015_sci.xlsx", sheet("Science") firstrow case(lower) clear


	// Drop 2014 data
	
drop spring2014 h i j k l m n o p q r s t u w x changeinstrongdistinguished


	// rename variables
rename spring2015 numberofvalidscores 
rename y participationrate
rename z meanscalescore
rename aa Lev1_count
rename ab Lev1_percent
rename ac Lev2_count
rename ad Lev2_percent
rename ae Lev3_count
rename af Lev3_percent
rename ag Lev4_count
rename ah Lev4_percent
rename ai ProficientOrAbove_count
rename aj ProficientOrAbove_percent

drop if subject!="SCI"


save "${output}/CO_OriginalData_2015_sci.dta", replace



	////	Imports social studies and saves

	
import excel "${path}/CO_OriginalData_2015_soc.xlsx", sheet("Social Studies") firstrow case(lower) clear


// Drop 2014 data
	
drop spring2014 h i j k l m n o p q r s t u w x changeinstronganddistinguish


	// rename variables
rename spring2015 numberofvalidscores 
rename y participationrate
rename z meanscalescore
rename aa Lev1_count
rename ab Lev1_percent
rename ac Lev2_count
rename ad Lev2_percent
rename ae Lev3_count
rename af Lev3_percent
rename ag Lev4_count
rename ah Lev4_percent
rename ai ProficientOrAbove_count
rename aj ProficientOrAbove_percent

drop if subject!="SS"


save "${output}/CO_OriginalData_2015_soc.dta", replace



	////Combines math/ela with science and social studies scores
	
use "${output}/CO_OriginalData_2015_ela&mat.dta", clear

append using "${output}/CO_OriginalData_2015_sci.dta"
append using "${output}/CO_OriginalData_2015_soc.dta"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"


rename districtcode districtnumber_int
rename schoolcode schoolnumber_int
rename numberofvalidscores ofvalidscores
rename subject subjectarea

gen districtcodebig = .
replace districtcodebig=0 if districtnumber_int<100
replace districtcodebig=1 if districtnumber_int>=100
replace districtcodebig=2 if districtnumber_int>=1000
replace districtcodebig=3 if districtnumber_int==0

gen districtnumber = string(districtnumber_int)

replace districtnumber = "000" + districtnumber if districtcodebig==3
replace districtnumber = "00" + districtnumber if districtcodebig==0
replace districtnumber = "0" + districtnumber if districtcodebig==1
replace districtnumber = districtnumber if districtcodebig==2


gen schoolcodebig = .
replace schoolcodebig=0 if schoolnumber_int<100
replace schoolcodebig=1 if schoolnumber_int>=100
replace schoolcodebig=2 if schoolnumber_int>=1000
replace schoolcodebig=3 if schoolnumber_int==0

gen schoolnumber = string(schoolnumber_int)

replace schoolnumber = "000" + schoolnumber if schoolcodebig==3
replace schoolnumber = "00" + schoolnumber if schoolcodebig==0
replace schoolnumber = "0" + schoolnumber if schoolcodebig==1
replace schoolnumber = schoolnumber if schoolcodebig==2


save "${output}/CO_OriginalData_2015_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS

import excel "${path}/CO_2015_ELA_gender.xlsx", sheet("2015 CMAS ELA in Gender") cellrange(A3:H15765) firstrow case(lower) clear

rename schoolnumber schoolnumber_int
rename metorexceededexpectati ProficientOrAbove_percent

destring districtnumber, gen(districtnumber_int) ignore(",* Tabcdefghijklmnopqrstuvwxyz.")

gen districtcodebig = .
replace districtcodebig=0 if districtnumber_int<100
replace districtcodebig=1 if districtnumber_int>=100
replace districtcodebig=2 if districtnumber_int>=1000
replace districtcodebig=3 if districtnumber_int==0

replace districtnumber = "000" + districtnumber if districtcodebig==3
replace districtnumber = "00" + districtnumber if districtcodebig==0
replace districtnumber = "0" + districtnumber if districtcodebig==1
replace districtnumber = districtnumber if districtcodebig==2



gen schoolcodebig = .
replace schoolcodebig=0 if schoolnumber_int<100
replace schoolcodebig=1 if schoolnumber_int>=100
replace schoolcodebig=2 if schoolnumber_int>=1000
replace schoolcodebig=3 if schoolnumber_int==0

gen schoolnumber = string(schoolnumber_int)

replace schoolnumber = "000" + schoolnumber if schoolcodebig==3
replace schoolnumber = "00" + schoolnumber if schoolcodebig==0
replace schoolnumber = "0" + schoolnumber if schoolcodebig==1
replace schoolnumber = schoolnumber if schoolcodebig==2

rename group StudentSubGroup
gen StudentGroup = "Gender"

save "${output}/CO_2015_ELA_gender.dta", replace



import excel "${path}/CO_2015_ELA_language.xlsx", sheet("2015 CMAS ELA in LEP") cellrange(A3:H15767) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "EL Status"

save "${output}/CO_2015_ELA_language.dta", replace



import excel "${path}/CO_2015_ELA_raceEthnicity.xlsx", sheet("2015 CMAS ELA in Ethnicity") cellrange(A3:H55165) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Race"

save "${output}/CO_2015_ELA_raceEthnicity.dta", replace


import excel "${path}/CO_2015_ELA_freeReducedLunch.xlsx", sheet("2015 CMAS ELA in FRL") cellrange(A3:H15765) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Economic Status"

save "${output}/CO_2015_ELA_econstatus.dta", replace



	//// MATH


import excel "${path}/CO_2015_.mat_genderxlsx.xlsx", sheet("2015 CMAS Math in Gender") cellrange(A3:H16817) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Gender"

save "${output}/CO_2015_mat_gender.dta", replace



import excel "${path}/CO_2015_mat_language.xlsx", sheet("2015 CMAS Math in LEP") cellrange(A3:H16819) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "EL status"

save "${output}/CO_2015_mat_language.dta", replace



import excel "${path}/CO_2015_mat_raceEthnicity.xlsx", sheet("2015 CMAS Math in Ethnicity") cellrange(A3:H58847) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Race"

save "${output}/CO_2015_mat_raceEthnicity.dta", replace


import excel "${path}/CO_2015_mat_freeReducedLunch.xlsx", sheet("2015 CMAS Math in FRL") cellrange(A3:H16817) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Economic Status"

save "${output}/CO_2015_mat_econstatus.dta", replace

import excel "${path}/CO_2015_ELA_migrant.xlsx", sheet("2015 CMAS ELA in Migrant") cellrange(A3:H15763) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Migrant Status"

save "${output}/CO_2015_ELA_migrantstatus.dta", replace

import excel "${path}/CO_2015_mat_migrant.xlsx", sheet("2015 CMAS Math in Migrant") cellrange(A3:H16817) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Migrant Status"

save "${output}/CO_2015_mat_migrantstatus.dta", replace

import excel "${path}/CO_2015_ELA_IEP.xlsx", sheet("2015 CMAS ELA in IEP") cellrange(A3:H15763) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Disability Status"

save "${output}/CO_2015_ELA_disability.dta", replace

import excel "${path}/CO_2015_mat_IEP.xlsx", sheet("2015 CMAS Math in IEP") cellrange(A3:H16817) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "Disability Status"

save "${output}/CO_2015_mat_disability.dta", replace


///////// Section 3: Appending Disaggregate Data


use "${output}/CO_OriginalData_2015_all.dta", clear


/// some variables need to be renamed to append correctly


	//Appends subgroups
	
append using "${output}/CO_2015_ELA_gender.dta"
append using "${output}/CO_2015_mat_gender.dta"
append using "${output}/CO_2015_ELA_language.dta"
append using "${output}/CO_2015_mat_language.dta"
append using "${output}/CO_2015_ELA_raceEthnicity.dta"
append using "${output}/CO_2015_mat_raceEthnicity.dta"
append using "${output}/CO_2015_ELA_econstatus.dta"
append using "${output}/CO_2015_mat_econstatus.dta"
append using "${output}/CO_2015_ELA_migrantstatus.dta"
append using "${output}/CO_2015_mat_migrantstatus.dta"
append using "${output}/CO_2015_ELA_disability.dta"
append using "${output}/CO_2015_mat_disability.dta"

drop if districtnumber=="* The value for this field is not displayed in order to ensure student privacy."
drop if districtnumber=="** English Learners include Non English Proficient (NEP) and Limited English Proficient (LEP) students."
drop if districtnumber=="*** Non-English Learners include student identified as Fluent English Proficient (FEP), Primary or Home Language Other Than English (PHLOTE), Former ELL (FELL), Not Applicable and Unreported."
drop if districtnumber==""
drop if districtnumber=="** English Learners includes Non English Proficient (NEP) and Limited English Proficient (LEP) students."
drop if districtnumber=="*** Non-English Learners includes student identified as Fluent English Proficient (FEP), Primary or Home Language Other Than English (PHLOTE), Former ELL (FELL), Not Applicable and Unreported."
drop if districtnumber=="*** Non-English Learners include students identified as Fluent English Proficient (FEP), Primary or Home Language Other Than English (PHLOTE), Former ELL (FELL), Not Applicable and Unreported."

replace grade="G03" if subjectarea=="ELA Grade 03  "
replace grade="G04" if subjectarea=="ELA Grade 04  "
replace grade="G05" if subjectarea=="ELA Grade 05  "
replace grade="G06" if subjectarea=="ELA Grade 06  "
replace grade="G07" if subjectarea=="ELA Grade 07  "
replace grade="G08" if subjectarea=="ELA Grade 08  "
drop if subjectarea=="ELA Grade 09  "
drop if subjectarea=="ELA Grade 10  "
drop if subjectarea=="ELA Grade 11  "
replace grade="G03" if subjectarea=="Math Grade 03 "
replace grade="G04" if subjectarea=="Math Grade 04 "
replace grade="G05" if subjectarea=="Math Grade 05 "
replace grade="G06" if subjectarea=="Math Grade 06 "
replace grade="G07" if subjectarea=="Math Grade 07 "
replace grade="G08" if subjectarea=="Math Grade 08 "
drop if subjectarea=="Integrated II "
drop if subjectarea=="Integrated I  "
drop if subjectarea=="Algebra I     "
drop if subjectarea=="Algebra II    "
drop if subjectarea=="Integrated III"
drop if subjectarea=="Geometry      "



///////// Section 4: Merging NCES Variables


gen state_leaid = districtnumber

gen seasch = schoolnumber


save "${output}/CO_OriginalData_2015_all.dta", replace



	// Merges district variables from NCES

use "${nces}/NCES District Files, Fall 1997-Fall 2022/NCES_2014_District.dta", clear
drop if state_fips != 8
save "${nces}/Cleaned NCES Data/CO_NCES_2015_District.dta", replace


use "${output}/CO_OriginalData_2015_all.dta", clear

merge m:1 state_leaid using "${nces}/Cleaned NCES Data/CO_NCES_2015_District.dta"

rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8


save "${output}/CO_OriginalData_2015_all.dta", replace
	// Merges school variables from NCES

use "${nces}/NCES School Files, Fall 1997-Fall 2022/NCES_2014_School.dta", clear
drop if state_fips != 8
save "${nces}/Cleaned NCES Data/CO_NCES_2015_School.dta", replace


use "${output}/CO_OriginalData_2015_all.dta", clear	
	
	
merge m:1 seasch state_fips using "${nces}/Cleaned NCES Data/CO_NCES_2015_School.dta"
drop if state_fips != 8


///////// Section 5: Reformatting


	// Renames variables 
	
rename level DataLevel
rename districtnumber StateAssignedDistID
rename districtname DistName
rename schoolnumber StateAssignedSchID
rename schoolname SchName
rename subjectarea Subject
rename grade GradeLevel
rename ofvalidscores StudentGroup_TotalTested
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

replace Lev1_count = "*" if strpos(Lev1_count, "<")>0
replace Lev1_count = "*" if strpos(Lev1_count, ">")>0
replace Lev2_count = "*" if strpos(Lev2_count, "<")>0
replace Lev2_count = "*" if strpos(Lev2_count, ">")>0
replace Lev3_count = "*" if strpos(Lev3_count, "<")>0
replace Lev3_count = "*" if strpos(Lev3_count, ">")>0
replace Lev4_count = "*" if strpos(Lev4_count, "<")>0
replace Lev4_count = "*" if strpos(Lev4_count, ">")>0
replace Lev5_count = "*" if strpos(Lev5_count, "<")>0
replace Lev5_count = "*" if strpos(Lev5_count, ">")>0
replace ProficientOrAbove_count = "*" if strpos(ProficientOrAbove_count, "<")>0
replace ProficientOrAbove_count = "*" if strpos(ProficientOrAbove_count, ">")>0
replace Lev1_percent = "*" if strpos(Lev1_percent, "<")>0
replace Lev1_percent = "*" if strpos(Lev1_percent, ">")>0
replace Lev2_percent = "*" if strpos(Lev2_percent, "<")>0
replace Lev2_percent = "*" if strpos(Lev2_percent, ">")>0
replace Lev3_percent = "*" if strpos(Lev3_percent, "<")>0
replace Lev3_percent = "*" if strpos(Lev3_percent, ">")>0
replace Lev4_percent = "*" if strpos(Lev4_percent, "<")>0
replace Lev4_percent = "*" if strpos(Lev4_percent, ">")>0
replace Lev5_percent = "*" if strpos(Lev5_percent, "<")>0
replace Lev5_percent = "*" if strpos(Lev5_percent, ">")>0
replace ProficientOrAbove_percent = "*" if strpos(ProficientOrAbove_percent, "<")>0
replace ProficientOrAbove_percent = "*" if strpos(ProficientOrAbove_percent, ">")>0

destring Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent, replace ignore(",* %NA<>=-")


replace Lev5_percent=Lev5_percent/100
replace Lev1_percent=Lev1_percent/100
replace Lev2_percent=Lev2_percent/100
replace Lev3_percent=Lev3_percent/100
replace Lev4_percent=Lev4_percent/100

 
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

//	Create new variables


gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_sci="N"
gen Flag_CutScoreChange_soc="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
rename year SchYear
replace SchYear="2014-15"



// Relabel variable values

tab Subject
replace Subject="math" if Subject=="Mathematics"
replace Subject="math" if Subject=="Math"
replace Subject="math" if Subject=="MATH"
replace Subject="ela" if Subject=="English Language Arts"
replace Subject="ela" if Subject=="ELA"
replace Subject="sci" if Subject=="Science"
replace Subject="sci" if Subject=="SCI"
replace Subject="soc" if Subject=="SS"
replace Subject="sci" if Subject=="Science             "
replace Subject="math" if Subject=="Mathematics         "
replace Subject="ela" if Subject=="English Lanuage Arts"
replace Subject="ela" if Subject=="ELA Grade 03  "
replace Subject="ela" if Subject=="ELA Grade 04  "
replace Subject="ela" if Subject=="ELA Grade 05  "
replace Subject="ela" if Subject=="ELA Grade 06  "
replace Subject="ela" if Subject=="ELA Grade 07  "
replace Subject="ela" if Subject=="ELA Grade 08  "
replace Subject="math" if Subject=="Math Grade 03 "
replace Subject="math" if Subject=="Math Grade 04 "
replace Subject="math" if Subject=="Math Grade 05 "
replace Subject="math" if Subject=="Math Grade 06 "
replace Subject="math" if Subject=="Math Grade 07 "
replace Subject="math" if Subject=="Math Grade 08 "

tab StudentSubGroup
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Pacific Islander"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Not Reported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"
replace StudentSubGroup="White" if StudentSubGroup=="White           "
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="American Indian "
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black           "
replace StudentSubGroup="Two or More" if StudentSubGroup=="Multiracial     "
replace StudentSubGroup="Asian" if StudentSubGroup=="Asian           "
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic        "
replace StudentSubGroup="Male" if StudentSubGroup=="Male  "
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant    "
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP   "
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-IEP"
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
replace State= "Colorado"



replace SchYear="2014-15"

replace SchName="All Schools" if SchName=="ALL SCHOOLS                                       "

	//	Reformat grade level indicators

tab GradeLevel

replace GradeLevel="G38" if GradeLevel=="All Grades"
replace GradeLevel="G03" if GradeLevel=="ELA Grade 03"
replace GradeLevel="G04" if GradeLevel=="ELA Grade 04"
replace GradeLevel="G05" if GradeLevel=="ELA Grade 05"
replace GradeLevel="G06" if GradeLevel=="ELA Grade 06"
replace GradeLevel="G07" if GradeLevel=="ELA Grade 07"
replace GradeLevel="G08" if GradeLevel=="ELA Grade 08"
drop if GradeLevel=="ELA Grade 09"
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
drop if GradeLevel=="Integrated I"
drop if GradeLevel=="Integrated II"
drop if GradeLevel=="Integrated III"
drop if GradeLevel=="Algebra I"
drop if GradeLevel=="Geometry"
drop if GradeLevel=="Algebra II"
replace GradeLevel="G05" if GradeLevel=="Science Grade 05"
replace GradeLevel="G08" if GradeLevel=="Science Grade 08"
drop if GradeLevel=="Science HS      "
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"
drop if GradeLevel=="ELA Grade 10"
drop if GradeLevel=="ELA Grade 11"

replace DataLevel="District" if DataLevel=="DIST"
replace DataLevel="School" if DataLevel=="SCH"

replace SchName="All schools" if SchName=="ALL SCHOOLS"
replace SchName="All schools" if SchName=="DISTRICT"
drop if SchName=="PIKES PEAK BOCES"
drop if SchName=="FAMILY EDUCATION NETWORK OF WELD CO"

replace DataLevel="District" if StateAssignedDistID!="0000" & StateAssignedSchID=="0000"
replace DataLevel="School" if StateAssignedDistID!="0000" & StateAssignedSchID!="0000"
replace DataLevel="State" if StateAssignedDistID=="0000" & StateAssignedSchID=="0000"

replace StudentSubGroup="English Learner" if StudentSubGroup=="English Learner (Not English Proficient/Limited English Proficient)**"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="Non-English Learner***    "
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible   "
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Free/Reduced Lunch Eligible"

tab GradeLevel
	
replace StudentGroup=strrtrim(StudentGroup)
replace StudentSubGroup=strrtrim(StudentSubGroup)
replace SchName=strrtrim(SchName)
replace DistName=strrtrim(DistName)
replace AvgScaleScore=strrtrim(AvgScaleScore)
replace ProficientOrAbove_count=strrtrim(ProficientOrAbove_count)
replace ProficientOrAbove_percent=strrtrim(ProficientOrAbove_percent)
replace ParticipationRate=strrtrim(ParticipationRate)
replace AvgScaleScore="*" if AvgScaleScore==""
replace ProficientOrAbove_count="*" if ProficientOrAbove_count==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent==""
replace ParticipationRate="*" if ParticipationRate==""

	// Drops observations that aren't K-12 schools (none report test scores)
	
	//Colorado Virtual Academy
drop if NCESSchoolID=="080270001944"

	//Colorado Springs Youth Services Center
drop if NCESSchoolID=="080453006342"


drop if district_merge==2
drop if _merge==2
drop _merge
drop district_merge

drop numberoftotalrecords numberofnoscores lea_name

replace StudentGroup_TotalTested="0-16" if StudentGroup_TotalTested=="n < 16"
replace StudentGroup_TotalTested="0-16" if StudentGroup_TotalTested=="<16"
destring StudentGroup_TotalTested ProficientOrAbove_percent, replace ignore(",* %NA=-")


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, replace ignore(",* %NA<>=-")

replace ProficientOrAbove_percent=ProficientOrAbove_percent/100 if ProficientOrAbove_percent>=1

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

save "${path}/CO_2015_base.dta", replace



collapse (sum) StudentSubGroup_TotalTested, by(NCESDistrictID NCESSchoolID intGrade intStudentGroup intSubject)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested


// Flag

save "${path}/CO_2015_studentgrouptotals.dta", replace


// Flag

use "${path}/CO_2015_base.dta", replace


// Flag

merge m:1 NCESDistrictID NCESSchoolID intGrade intSubject intStudentGroup using "${path}/CO_2015_studentgrouptotals.dta"

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="999999999"

replace StudentGroup_TotalTested=999999999 if StudentGroup_TotalTested>=10000000
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="999999999"


replace AvgScaleScore="*" if AvgScaleScore=="NA"
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="NA"

replace ProficiencyCriteria="Levels 4-5" if Subject=="math"
replace ProficiencyCriteria="Levels 4-5" if Subject=="ela"


////
replace StateAssignedDistID="" if StateAssignedDistID=="0000"
replace StateAssignedSchID="" if StateAssignedSchID=="0000"

replace StudentGroup="All Students" if StudentGroup=="All students"
replace StudentGroup="EL Status" if StudentGroup=="EL status"
replace StudentGroup="RaceEth" if StudentGroup=="Race"

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

replace DistName = "All Districts" if DataLevel == "State"
replace SchName="All Schools" if DataLevel=="State"
replace SchName="All Schools" if DataLevel=="District"

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

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
replace ParticipationRate="*" if ParticipationRate=="NA"
replace ParticipationRate="*" if ParticipationRate=="--"
replace AvgScaleScore="*" if AvgScaleScore=="--"
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="--"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="--"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="NA"
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="NA"

drop if StateAssignedDistID=="* The values for this field is not displayed in order to ensure student privacy."

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2015.dta", replace
export delimited using "${output}/CO_AssmtData_2015.csv", replace


