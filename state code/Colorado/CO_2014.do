

global path "/Users/hayden/Desktop/Research/CO/2014"
global nces "/Users/hayden/Desktop/Research/NCES"


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


save "${path}/CO_OriginalData_2014_sci.dta", replace


	//imports and saves soc
	

import excel "${path}/CO_OriginalData_2014_soc.xlsx", sheet("Social Studies") firstrow case(lower) clear


save "${path}/CO_OriginalData_2014_soc.dta", replace



	////Combines math/ela with science scores
	
use "${path}/CO_OriginalData_2014_sci.dta", clear

append using "${path}/CO_OriginalData_2014_soc.dta"

gen StudentGroup = "All students"
gen StudentSubGroup = "All students"
drop if grade==""


save "${path}/CO_OriginalData_2014_all.dta", replace




///////// Section 4: Merging NCES Variables


gen state_leaidnumber =.
gen state_leaid = string(state_leaidnumber)
replace state_leaid = districtnumber

gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = schoolnumber



save "${path}/CO_OriginalData_2014_all.dta", replace

	// Merges district variables from NCES

use "${nces}/NCES_2013_District.dta"
drop if state_fips != 8
save "${path}/CO_NCES_2013_District.dta", replace


use "${path}/CO_OriginalData_2014_all.dta", clear

merge m:1 state_leaid using "${path}/CO_NCES_2013_District.dta"


rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8

save "${path}/CO_OriginalData_2014_all.dta", replace
	// Merges school variables from NCES

use "${nces}/NCES_2013_School.dta"
drop if state_fips != 8
save "${path}/CO_NCES_2013_School.dta", replace


use "${path}/CO_OriginalData_2014_all.dta", clear	
	
	
merge m:1 seasch state_fips using "${path}/CO_NCES_2013_School.dta"
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
rename district_agency_type DistrictType
rename charter Charter
rename state_location StateAbbrev
rename county_name CountyName
rename county_code CountyCode
rename school_type SchoolType
rename virtual Virtual
rename school_level SchoolLevel


//Rename proficiency levels
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
replace SchYear="2013-14" if SchYear=="2014"
drop year

replace Lev1_count="*" if Lev1_count=="-"
replace Lev2_count="*" if Lev2_count=="-"
replace Lev3_count="*" if Lev3_count=="-"
replace Lev4_count="*" if Lev4_count=="-"
replace Lev1_percent="*" if Lev1_percent=="-"
replace Lev2_percent="*" if Lev2_percent=="-"
replace Lev3_percent="*" if Lev3_percent=="-"
replace Lev4_percent="*" if Lev4_percent=="-"


//	Reorder variables

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate



//	Drop unneccesary variables

drop districtnumber_int schoolnumber_int districtcodebig schoolcodebig districtcode schoolcode state_leaidnumber seaschnumber


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
replace Subject="sci" if Subject=="SCI"
replace Subject="soc" if Subject=="SS"


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

replace SchYear="2013-14"


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
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"

tab GradeLevel
	


export delimited using "${path}/CO_2014_Data_Unmerged.csv", replace

replace district_merge=999 if DataLevel=="State"
replace _merge=999 if DataLevel=="State"
replace _merge=999 if district_merge==3
drop if district_merge==2
drop if _merge==2
drop if district_merge==1
drop if _merge==1
drop _merge
drop district_merge

export delimited using "${path}/CO_2014_Data.csv", replace

