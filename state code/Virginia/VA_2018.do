
global base "/Users/hayden/Desktop/Research/VA"
global yrfiles "/Users/hayden/Desktop/Research/VA/2018"
global nces "/Users/hayden/Desktop/Research/NCES"
global output "/Users/hayden/Desktop/Research/VA/Output"



////	Import aggregate data from 2006-2022

import delimited "/${base}/VA_OriginalData_2006-2022_all.csv", varnames(1) clear 

drop if schoolyear != "2017-2018"

gen StudentGroup = "All students"
gen StudentSubGroup = "All students"

save "${yrfiles}/VA_2018_base.dta", replace



////	Import disaggregate gender data

import delimited "/${yrfiles}/VA_OriginalData_2018_all_gender.csv", varnames(1) clear 

rename gender StudentSubGroup
gen StudentGroup = "Gender"

save "${yrfiles}/VA_2018_gender.dta", replace



////	Import disaggregate language proficiency data

import delimited "/${yrfiles}/VA_OriginalData_2018_all_language.csv", varnames(1) clear 

rename englishlearners StudentSubGroup
gen StudentGroup = "EL status"

save "${yrfiles}/VA_2018_language.dta", replace



////	Import disaggregate race data

import delimited "/${yrfiles}/VA_OriginalData_2018_all_race.csv", varnames(1) clear 

rename race StudentSubGroup
gen StudentGroup = "Race"

save "${yrfiles}/VA_2018_race.dta", replace



////	Append aggregate and disaggregate 

use "${yrfiles}/VA_2018_base.dta", clear

append using "${yrfiles}/VA_2018_gender.dta"
append using "${yrfiles}/VA_2018_language.dta"
append using "${yrfiles}/VA_2018_race.dta"



////	Double check data

tab schoolyear
tab testlevel
tab testsource
tab StudentGroup
tab StudentSubGroup


save "${yrfiles}/VA_2018_base.dta", replace

////	Prepare for NCES merge



	// District merge
	

use "${nces}/NCES_2017_District.dta", clear


keep if state_fips==51

save "${yrfiles}/VA_2017_nces_districts.dta", replace



use "${yrfiles}/VA_2018_base.dta", clear

destring divisionnumber, replace

gen districtcodebig=.
	replace districtcodebig=1 if divisionnumber<=99
	replace districtcodebig=0 if divisionnumber<=9
	replace districtcodebig=2 if divisionnumber>=100


	tostring divisionnumber, replace
	
	replace divisionnumber="00" + divisionnumber if districtcodebig==0
	replace divisionnumber="0" + divisionnumber if districtcodebig==1

	gen state_leaid=""
	
	replace state_leaid="VA-"+divisionnumber

merge m:1 state_leaid using "${yrfiles}/VA_2017_nces_districts.dta"

drop if _merge==2

save "${yrfiles}/VA_2018_base.dta", replace



	// School merge

use "/${nces}/NCES_2017_School.dta", clear

keep if state_fips==51

save "${yrfiles}/VA_2017_nces_schools.dta", replace



use "${yrfiles}/VA_2018_base.dta", clear

destring schoolnumber, replace


gen schoolcodebig=.
	replace schoolcodebig=3 if schoolnumber>=1000
	replace schoolcodebig=2 if schoolnumber<=999
	replace schoolcodebig=1 if schoolnumber<=99
	replace schoolcodebig=0 if schoolnumber<=9
	
tostring schoolnumber, replace

replace schoolnumber="000" + schoolnumber if schoolcodebig==0
replace schoolnumber="00" + schoolnumber if schoolcodebig==1
replace schoolnumber="0" + schoolnumber if schoolcodebig==2

gen seasch=""

	replace seasch=divisionnumber + "-" + divisionnumber + schoolnumber
	
rename _merge districtmerge

merge m:1 seasch using "/${yrfiles}/VA_2017_nces_schools.dta"

drop if _merge==2



////  Rename, reorganize, standardize data

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename district_agency_type DistricType
rename county_name CountyName
rename county_code CountyCode
rename ncesschoolid NCESSchoolID
rename school_type SchoolType
rename year SchYear
rename testsource AssmtName

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtType="Regular"

rename level DataLevel
rename lea_name DistName
rename divisionnumber StateAssignedDistID
rename schoolname SchName
rename schoolnumber StateAssignedSchID
rename subject Subject
rename testlevel GradeLevel
rename totalcount StudentSubGroup_TotalTested

rename failcount Lev1_count
rename failrate Lev1_percent
rename passproficientcount Lev2_count
rename passproficientrate Lev2_percent
rename passadvancedcount Lev3_count
rename passadvancedrate Lev3_percent
gen Lev4_count="*"
gen Lev4_percent="*"
gen Lev5_count="*"
gen Lev5_percent="*"
rename averagesolscaledscore AvgScaleScore
gen ProficiencyCriteria="Lev2 + Lev3"
rename passcount ProficientOrAbove_count
rename passrate ProficientOrAbove_percent
gen ParticipationRate="*"


replace State=51
replace StateAbbrev="VA"
replace StateFips=51

replace DataLevel="District" if DataLevel=="Division"
replace State_leaid="" if DataLevel=="State"
replace seasch="" if DataLevel=="State"
replace seasch="" if DataLevel=="District"

//Important
tostring SchYear, replace force
replace SchYear="2017-18"

replace Subject="math" if Subject=="Mathematics"
replace Subject="wri" if Subject=="English:Writing"
replace Subject="read" if Subject=="English:Reading"
replace Subject="sci" if Subject=="Science"

replace GradeLevel="G03" if GradeLevel=="Grade 3"
replace GradeLevel="G04" if GradeLevel=="Grade 4"
replace GradeLevel="G05" if GradeLevel=="Grade 5"
replace GradeLevel="G06" if GradeLevel=="Grade 6"
replace GradeLevel="G07" if GradeLevel=="Grade 7"
replace GradeLevel="G08" if GradeLevel=="Grade 8"

replace StudentSubGroup="Male" if StudentSubGroup=="M"
replace StudentSubGroup="Female" if StudentSubGroup=="F"
replace StudentSubGroup="English learner" if StudentSubGroup=="Y"
replace StudentSubGroup="English proficient" if StudentSubGroup=="N"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black, not of Hispanic origin"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Non-Hispanic, two or more races"
replace StudentSubGroup="White" if StudentSubGroup=="White, not of Hispanic origin"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"

replace Lev1_percent="9999" if Lev1_percent=="<50"
replace Lev1_percent="1111" if Lev1_percent==">50"

destring Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent, replace ignore(",<>")

replace Lev1_percent=Lev1_percent/100
replace Lev2_percent=Lev2_percent/100
replace Lev3_percent=Lev3_percent/100

tostring Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent, replace force

replace Lev1_percent="<0.5" if Lev1_percent=="99.99"
replace Lev1_percent=">0.5" if Lev1_percent=="11.11"

replace Lev1_count="*" if Lev1_count=="."
replace Lev2_count="*" if Lev2_count=="."
replace Lev2_percent="*" if Lev2_percent=="."
replace Lev3_count="*" if Lev3_count=="."
replace Lev3_percent="*" if Lev3_percent=="."

replace AvgScaleScore="*" if AvgScaleScore==" "

drop schoolyear divisionname districtcodebig districtmerge schoolcodebig _merge


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
replace intSubject=2 if Subject=="read"
replace intSubject=3 if Subject=="wri"
replace intSubject=4 if Subject=="sci"

replace intStudentGroup=1 if StudentGroup=="All students"
replace intStudentGroup=2 if StudentGroup=="Gender"
replace intStudentGroup=3 if StudentGroup=="Race"
replace intStudentGroup=4 if StudentGroup=="EL status"


replace StudentSubGroup_TotalTested="999999999" if StudentSubGroup_TotalTested=="<"
destring StudentSubGroup_TotalTested, replace ignore(",<>")


// Flag

save "${yrfiles}/VA_2018_base.dta", replace



collapse (sum) StudentSubGroup_TotalTested, by(NCESDistrictID NCESSchoolID intGrade intStudentGroup intSubject)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested


// Flag

save "${yrfiles}/VA_2018_studentgrouptotals.dta", replace


// Flag

use "${yrfiles}/VA_2018_base.dta", replace


// Flag

merge m:1 NCESDistrictID NCESSchoolID intGrade intSubject intStudentGroup using "${yrfiles}/VA_2018_studentgrouptotals.dta"

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="999999999"

replace StudentGroup_TotalTested=999999999 if StudentGroup_TotalTested>=10000000
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="999999999"


drop intSubject intGrade intStudentGroup _merge



//	Review one

rename DistricType DistrictType

replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian  or Pacific Islander"

replace StudentSubGroup="Unknown" if StudentSubGroup=="Unknown - Race/Ethnicity not provided"

replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="<"

replace ProficientOrAbove_percent="-1" if ProficientOrAbove_percent=="<50"
replace ProficientOrAbove_percent="-2" if ProficientOrAbove_percent==">50"

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100
tostring ProficientOrAbove_percent, replace force

replace ProficientOrAbove_percent="<50" if ProficientOrAbove_percent=="-.01"
replace ProficientOrAbove_percent=">50" if ProficientOrAbove_percent=="-.02"

//


rename DistrictType DistType
rename SchoolType SchType

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

replace DistName="All Districts" if DataLevel=="State"
replace SchName="All Schools" if DataLevel=="State"
replace SchName="All Schools" if DataLevel=="District"

replace AssmtName="Standards of Learning"

replace DataLevel="0" if DataLevel=="State"
replace DataLevel="1" if DataLevel=="District"
replace DataLevel="2" if DataLevel=="School"

destring DataLevel, replace force

label define LevelIndicator 0 "State" 1 "District" 2 "School"
label values DataLevel LevelIndicator

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

replace seasch="" if DataLevel==0
replace State_leaid="" if DataLevel==0
replace StateAssignedDistID="" if DataLevel==0

// Flag

save "${yrfiles}/VA_2018_base.dta", replace


// Flag

export delimited using "${output}/VA_AssmtData_2018.csv", replace

