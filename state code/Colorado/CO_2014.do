
clear all

cd "/Users/miramehta/Documents"
global path "/Users/miramehta/Documents/CO State Testing Data/CMAS Aggregate Data"
global nces "/Users/miramehta/Documents/NCES District and School Demographics"
global output "/Users/miramehta/Documents/CO State Testing Data"


///////// Section 1: Appending Aggregate Data


	////Combines sci and soc data



import excel "${path}/CO_OriginalData_2014_sci.xlsx", sheet("Science") firstrow case(lower) clear

rename districtcode districtnumber_int
rename schoolcode schoolnumber_int

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

rename performancelevels Lev1_count
rename i Lev1_percent
rename j Lev2_count
rename k Lev2_percent
rename l Lev3_count
rename m Lev3_percent
rename n Lev4_count
rename o Lev4_percent
rename p ProficientOrAbove_count
rename q ProficientOrAbove_percent



save "${output}/CO_OriginalData_2014_sci.dta", replace


	//imports and saves soc
	

import excel "${path}/CO_OriginalData_2014_soc.xlsx", sheet("Social Studies") firstrow case(lower) clear

replace schoolcode = "0000" if schoolcode=="0"

rename performancelevels Lev1_count
rename i Lev1_percent
rename j Lev2_count
rename k Lev2_percent
rename l Lev3_count
rename m Lev3_percent
rename n Lev4_count
rename o Lev4_percent
rename p ProficientOrAbove_count
rename q ProficientOrAbove_percent
rename schoolcode schoolnumber
rename districtcode districtnumber


save "${output}/CO_OriginalData_2014_soc.dta", replace



	////Combines math/ela with science scores
	
use "${output}/CO_OriginalData_2014_sci.dta", clear

append using "${output}/CO_OriginalData_2014_soc.dta"

gen StudentGroup = "All Students"
gen StudentSubGroup = "All Students"
drop if grade==""


save "${output}/CO_OriginalData_2014_all.dta", replace




///////// Section 4: Merging NCES Variables

gen state_leaid = districtnumber
gen seasch = schoolnumber

save "${output}/CO_OriginalData_2014_all.dta", replace


	// Merges district variables from NCES

use "${nces}/NCES District Files, Fall 1997-Fall 2021/NCES_2013_District.dta"
drop if state_fips != 8
save "${nces}/Cleaned NCES Data/CO_NCES_2014_District.dta", replace


use "${output}/CO_OriginalData_2014_all.dta", clear

merge m:1 state_leaid using "${nces}/Cleaned NCES Data/CO_NCES_2014_District.dta"


rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${output}/CO_OriginalData_2014_all.dta", replace
	// Merges school variables from NCES

use "${nces}/NCES School Files, Fall 1997-Fall 2021/NCES_2013_School.dta"
drop if state_fips != 8
save "${nces}/Cleaned NCES Data/CO_NCES_2014_School.dta", replace


use "${output}/CO_OriginalData_2014_all.dta", clear	
	
	
merge m:1 seasch state_fips using "${nces}/Cleaned NCES Data/CO_NCES_2014_School.dta"


drop if state_fips != 8


///////// Section 5: Reformatting


	// Renames variables 
gen DataLevel="School"
replace DataLevel="District" if schoolnumber=="0000"
replace DataLevel="State" if districtnumber=="0000"

rename districtnumber StateAssignedDistID
rename lea_name DistName
rename schoolnumber StateAssignedSchID
rename districtorschoolname SchName
rename content Subject
rename grade GradeLevel
rename totalstudentswithscores StudentGroup_TotalTested
gen ParticipationRate="*"
rename averagescalescore AvgScaleScore
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


//	Create new variables

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA=""
gen Flag_CutScoreChange_math=""
gen Flag_CutScoreChange_sci="N"
gen Flag_CutScoreChange_soc="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
gen Lev5_count = "--" 
gen Lev5_percent= "--"
gen SchYear = string(year)
replace SchYear="2013-14" if SchYear=="2014"
drop year

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested

replace Lev1_count="*" if Lev1_count=="-"
replace Lev2_count="*" if Lev2_count=="-"
replace Lev3_count="*" if Lev3_count=="-"
replace Lev4_count="*" if Lev4_count=="-"
replace Lev1_percent="*" if Lev1_percent=="-"
replace Lev2_percent="*" if Lev2_percent=="-"
replace Lev3_percent="*" if Lev3_percent=="-"
replace Lev4_percent="*" if Lev4_percent=="-"




// Relabel variable values

tab Subject
replace Subject="sci" if Subject=="SCI"
replace Subject="soc" if Subject=="SS"

replace SchName = "All Schools" if DataLevel == "District"
replace DistName = "All Districts" if DataLevel == "State"

replace seasch="0000-0000" if seasch=="000-000"
replace State_leaid="CO-0000" if State_leaid=="CO-000"
replace StateAssignedDistID="0000" if StateAssignedDistID=="000"
replace StateAssignedSchID="0000" if StateAssignedSchID=="000"
replace StateAbbrev="CO" if StateAbbrev==""
replace State=StateFips

replace SchYear="2013-14"

drop if district_merge==2
drop if _merge==2

// Drop school level entries that are not schools
drop if SchName=="FAMILY EDUCATION NETWORK OF WELD CO"
drop if SchName=="CHERRY CREEK EXPULSION SCHOOL"


drop _merge
drop district_merge

replace StudentGroup_TotalTested= "0-16" if StudentGroup_TotalTested=="< 16"
replace StudentGroup_TotalTested= "0-16" if StudentGroup_TotalTested=="<16"
replace StudentSubGroup_TotalTested= "0-16" if StudentSubGroup_TotalTested=="< 16"
replace StudentSubGroup_TotalTested= "0-16" if StudentSubGroup_TotalTested=="<16"
destring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace ignore("-,* %NA-")

replace StudentSubGroup_TotalTested=StudentGroup_TotalTested


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace ignore(",* %NA<>=-")

replace Lev1_percent=Lev1_percent/100
replace Lev2_percent=Lev2_percent/100
replace Lev3_percent=Lev3_percent/100
replace Lev4_percent=Lev4_percent/100
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100


tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force

replace Lev1_percent="*" if Lev1_percent=="."
replace Lev2_percent="*" if Lev2_percent=="."
replace Lev3_percent="*" if Lev3_percent=="."
replace Lev4_percent="*" if Lev4_percent=="."
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="."

replace StateAssignedSchID="" if StateAssignedSchID=="0000"

//// Reorder and drop variables

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace AvgScaleScore="*" if AvgScaleScore=="-"
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="-"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="-"
replace ParticipationRate="*" if ParticipationRate=="-"

tostring StudentGroup_TotalTested StudentSubGroup_TotalTested, replace force
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="."

replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode


sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/CO_AssmtData_2014.dta", replace
export delimited using "${output}/CO_AssmtData_2014.csv", replace

