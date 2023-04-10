


global path "/Users/hayden/Desktop/Research/CO/2018"
global nces "/Users/hayden/Desktop/Research/NCES"
global disagg "/Users/hayden/Desktop/Research/CO/Disaggregate/2018"


///////// Section 1: Appending Aggregate Data


	////Combines math/ela data with science data


	//Imports and saves math/ela

import excel "${path}/CO_OriginalData_2018_ela&mat.xlsx", sheet("District and School Detail_1") cellrange(A7:AB16188) firstrow case(lower) clear


	//some variables need to be renamed after importing because stata generates generic names for variables with the same name. 
	
rename n percentdidnotyetmeetexpectations
rename p percentpartiallymetexpectations
rename r percentapproachedexpectations
rename t percentmetexpectations
rename v percentexceededexpectations
rename x percentmetorexceededexpectations
rename y meanscalescorelastyear
rename aa percentproficientlastyear

save "${path}/CO_OriginalData_2018_ela&mat.dta", replace


	//imports and saves sci

import excel "${path}/CO_OriginalData_2018_sci.xlsx", sheet("District and School Detail_1") cellrange(A5:Y4662) firstrow case(lower) clear

rename m percentpartiallymetexpectations
rename o percentapproachedexpectations
rename q percentmetexpectations
rename s percentexceededexpectations
rename u percentmetorexceededexpectations
rename v meanscalescorelastyear
rename x percentproficientlastyear
gen content = "sci"

save "${path}/CO_OriginalData_2018_sci.dta", replace


	////Combines math/ela with science scores
	
use "${path}/CO_OriginalData_2018_ela&mat.dta", clear

append using "${path}/CO_OriginalData_2018_sci.dta"

gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

save "${path}/CO_OriginalData_2018_all.dta", replace



///////// Section 2: Preparing Disaggregate Data


	//// ENGLISH/LANGUAGE ARTS
	
import excel "${disagg}/CO_2018_ELA_gender.xlsx", sheet("Sheet1_1") cellrange(A3:W15651) firstrow case(lower) clear

rename m percentdidnotyetmeetexpectations
rename o percentpartiallymetexpectations
rename q percentapproachedexpectations
rename s percentmetexpectations
rename u percentexceededexpectations
rename w percentmetorexceededexpectations
rename gender StudentSubGroup
gen StudentGroup = "Gender"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "ela"

save "${path}/CO_2018_ELA_gender.dta", replace



import excel "${disagg}/CO_2018_ELA_language.xlsx", sheet("Sheet1_1") cellrange(A3:W22802) firstrow case(lower) clear

rename m percentdidnotyetmeetexpectations
rename o percentpartiallymetexpectations
rename q percentapproachedexpectations
rename s percentmetexpectations
rename u percentexceededexpectations
rename w percentmetorexceededexpectations
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "ela"


save "${path}/CO_2018_ELA_language.dta", replace



import excel "${disagg}/CO_2018_ELA_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A3:W34711) firstrow case(lower) clear

rename m percentdidnotyetmeetexpectations
rename o percentpartiallymetexpectations
rename q percentapproachedexpectations
rename s percentmetexpectations
rename u percentexceededexpectations
rename w percentmetorexceededexpectations
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "ela"

save "${path}/CO_2018_ELA_raceEthnicity.dta", replace


	//// MATH


import excel "${disagg}/CO_2018_mat_gender.xlsx", sheet("Sheet1_1") cellrange(A3:W16403) firstrow case(lower) clear

rename m percentdidnotyetmeetexpectations
rename o percentpartiallymetexpectations
rename q percentapproachedexpectations
rename s percentmetexpectations
rename u percentexceededexpectations
rename w percentmetorexceededexpectations
rename gender StudentSubGroup
gen StudentGroup = "Gender"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "math"

save "${path}/CO_2018_mat_gender.dta", replace


import excel "${disagg}/CO_2018_mat_language.xlsx", sheet("Sheet1_1") cellrange(A3:W23483) firstrow case(lower) clear

rename m percentdidnotyetmeetexpectations
rename o percentpartiallymetexpectations
rename q percentapproachedexpectations
rename s percentmetexpectations
rename u percentexceededexpectations
rename w percentmetorexceededexpectations
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "math"

save "${path}/CO_2018_mat_language.dta", replace


import excel "${disagg}/CO_2018_mat_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A3:W35940) firstrow case(lower) clear

rename m percentdidnotyetmeetexpectations
rename o percentpartiallymetexpectations
rename q percentapproachedexpectations
rename s percentmetexpectations
rename u percentexceededexpectations
rename w percentmetorexceededexpectations
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "math"

save "${path}/CO_2018_mat_raceEthnicity.dta", replace


	//// SCIENCE
	
	
import excel "${disagg}/CO_2018_sci_gender.xlsx", sheet("Sheet1_1") cellrange(A3:U9251) firstrow case(lower) clear
	
	
rename m percentpartiallymetexpectations
rename o percentapproachedexpectations
rename q percentmetexpectations
rename s percentexceededexpectations
rename u percentmetorexceededexpectations
rename gender StudentSubGroup
gen StudentGroup = "Gender"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "sci"

save "${path}/CO_2018_sci_gender.dta", replace


import excel "${disagg}/CO_2018_sci_language.xlsx", sheet("Sheet1_1") cellrange(A3:U13177) firstrow case(lower) clear

rename m percentpartiallymetexpectations
rename o percentapproachedexpectations
rename q percentmetexpectations
rename s percentexceededexpectations
rename u percentmetorexceededexpectations
rename languageproficiency StudentSubGroup
gen StudentGroup = "EL status"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "sci"

save "${path}/CO_2018_sci_language.dta", replace

import excel "${disagg}/CO_2018_sci_raceEthnicity.xlsx", sheet("Sheet1_1") cellrange(A3:U20330) firstrow case(lower) clear

rename m percentpartiallymetexpectations
rename o percentapproachedexpectations
rename q percentmetexpectations
rename s percentexceededexpectations
rename u percentmetorexceededexpectations
rename ethnicity StudentSubGroup
gen StudentGroup = "Race"
rename districtnumber districtcode
rename schoolnumber schoolcode
gen content = "sci"

save "${path}/CO_2018_sci_raceEthnicity.dta", replace




///////// Section 3: Appending Disaggregate Data



use "${path}/CO_OriginalData_2018_all.dta", clear


	//Appends subgroups
	
append using "/Users/hayden/Desktop/Research/CO/2018/CO_2018_ELA_gender.dta"
append using "/Users/hayden/Desktop/Research/CO/2018/CO_2018_mat_gender.dta"
append using "/Users/hayden/Desktop/Research/CO/2018/CO_2018_ELA_language.dta"
append using "/Users/hayden/Desktop/Research/CO/2018/CO_2018_mat_language.dta"
append using "/Users/hayden/Desktop/Research/CO/2018/CO_2018_ELA_raceEthnicity.dta"
append using "/Users/hayden/Desktop/Research/CO/2018/CO_2018_mat_raceEthnicity.dta"

drop if level=="* The value for this field is not displayed in order to protect student privacy."
drop if level==""
drop if level=="Aug 24, 2018"



///////// Section 4: Merging NCES Variables


gen state_leaidnumber =.
gen state_leaid = string(state_leaidnumber)
replace state_leaid = "CO-" + districtcode

gen seaschnumber=.
gen seasch = string(seaschnumber)
replace seasch = districtcode + "-" + schoolcode



	// Merges district variables from NCES

merge m:1 state_leaid using "${nces}/NCES_2017_District.dta"

rename _merge district_merge

replace state_fips=8 if state_fips==.
drop if state_fips != 8
drop if level == "Aug 24, 2018"


	// Merges school variables from NCES

merge m:1 seasch state_fips using "${nces}/NCES_2017_School.dta"
drop if state_fips != 8



///////// Section 5: Reformatting


	// Renames variables 
	
rename level DataLevel
rename districtcode StateAssignedDistID
rename districtname DistName
rename schoolcode StateAssignedSchID
rename schoolname SchName
rename content Subject
rename testgrade GradeLevel
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

//	Create new variables

gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Lev3 or Lev 4"
gen Lev5_count =. 
gen Lev5_percent=.
gen SchYear = string(year)
replace SchYear="2017-18" if SchYear=="2018"
drop year



//	Reorder variables

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate


//	Drop unneccesary variables

drop ofvalidscores ofnoscores meanscalescorelastyear metorexceededexpectati percentproficientlastyear changeinmetorexceededexpe state_leaidnumber seaschnumber lea_name


// Relabel variable values

tab Subject
replace Subject="math" if Subject=="Mathematics"
replace Subject="ela" if Subject=="English Language Arts"

tab StudentSubGroup
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Not Reported"
replace DataLevel="District" if DataLevel=="DISTRICT"
replace DataLevel="School" if DataLevel=="SCHOOL"
replace State=StateFips


replace SchYear="2017-18"

tab GradeLevel
replace GradeLevel="G38" if GradeLevel=="All Grades"
replace GradeLevel="G03" if GradeLevel=="ELA Grade 03"
replace GradeLevel="G04" if GradeLevel=="ELA Grade 04"
replace GradeLevel="G05" if GradeLevel=="ELA Grade 05"
replace GradeLevel="G06" if GradeLevel=="ELA Grade 06"
replace GradeLevel="G07" if GradeLevel=="ELA Grade 07"
replace GradeLevel="G08" if GradeLevel=="ELA Grade 08"
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
replace GradeLevel="G09" if GradeLevel=="Integrated I"
replace GradeLevel="G10" if GradeLevel=="Integrated II"
replace GradeLevel="G09" if GradeLevel=="Algebra I"
replace GradeLevel="G10" if GradeLevel=="Geometry"
replace GradeLevel="G05" if GradeLevel=="Science Grade 05"
replace GradeLevel="G08" if GradeLevel=="Science Grade 08"
replace GradeLevel="G10" if GradeLevel=="Science HS"
replace StudentSubGroup="English learner" if StudentSubGroup=="NEP - Non English Proficient"
replace StudentSubGroup="English proficient" if StudentSubGroup=="FEP - Fluent English Proficient"
replace StudentSubGroup="Other" if StudentSubGroup=="PHLOTE/FELL/NA"
drop if StudentSubGroup=="LEP - Limited English Proficient"

tab GradeLevel


	// Drops observations that aren't grades 3 through 8
	
drop if GradeLevel=="G09"
drop if GradeLevel=="G10"


export delimited using "${path}/CO_2018_Data_Unmerged.csv", replace

drop if district_merge==2
drop if _merge==2
drop _merge
drop district_merge

destring StudentGroup_TotalTested, replace ignore(",* %NA<>=-")

export delimited using "${output}/CO_AssmtData_2018.csv", replace
