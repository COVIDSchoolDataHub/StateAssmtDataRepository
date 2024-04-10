
clear all

cd "/Users/miramehta/Documents"

global path "/Users/miramehta/Documents/CO State Testing Data/2015"
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
gen StudentGroup = "RaceEth"

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
gen StudentGroup = "EL Status"

save "${output}/CO_2015_mat_language.dta", replace



import excel "${path}/CO_2015_mat_raceEthnicity.xlsx", sheet("2015 CMAS Math in Ethnicity") cellrange(A3:H58847) firstrow case(lower) clear

rename group StudentSubGroup
rename metorexceededexpectati ProficientOrAbove_percent
gen StudentGroup = "RaceEth"

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


//Reformat Grade Level and Subject Values
replace subjectarea = strtrim(subjectarea)

replace grade="G03" if strpos(subjectarea, "03") > 0 | strpos(grade, "03") > 0
replace grade="G04" if strpos(subjectarea, "04") > 0 | strpos(grade, "04") > 0
replace grade="G05" if strpos(subjectarea, "05") > 0 | strpos(grade, "05") > 0
replace grade="G06" if strpos(subjectarea, "06") > 0 | strpos(grade, "06") > 0
replace grade="G07" if strpos(subjectarea, "07") > 0 | strpos(grade, "07") > 0
replace grade="G08" if strpos(subjectarea, "08") > 0 | strpos(grade, "08") > 0

drop if subjectarea=="ELA Grade 09" | grade=="ELA Grade 09"
drop if subjectarea=="ELA Grade 10" | grade=="ELA Grade 10"
drop if subjectarea=="ELA Grade 11" | grade=="ELA Grade 11"
drop if subjectarea=="Integrated II" | grade=="Integrated II"
drop if subjectarea=="Integrated I" | grade=="Integrated I"
drop if subjectarea=="Algebra I" | grade=="Algebra I"
drop if subjectarea=="Algebra II" | grade=="Algebra II"
drop if subjectarea=="Integrated III" | grade=="Integrated III"
drop if subjectarea=="Geometry" | grade=="Geometry"

replace subjectarea = "ela" if strpos(subjectarea, "ELA") > 0
replace subjectarea = "math" if strpos(subjectarea, "Math") > 0 | strpos(subjectarea, "MATH") > 0
replace subjectarea = "sci" if strpos(subjectarea, "SCI") > 0
replace subjectarea = "soc" if strpos(subjectarea, "SS") > 0

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
rename ofvalidscores StudentSubGroup_TotalTested
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

replace CountyName = strproper(CountyName)

//Student and Performance Counts & Percents 
replace StudentSubGroup_TotalTested = strtrim(StudentSubGroup_TotalTested)
replace StudentSubGroup_TotalTested = "1-15" if StudentSubGroup_TotalTested == "n < 16"
gen Below = 0
replace Below = 1 if strpos(StudentSubGroup_TotalTested, "<") > 0
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, "<=", "", 1)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, "< ", "", 1)
replace StudentSubGroup_TotalTested = subinstr(StudentSubGroup_TotalTested, "<", "", 1)
destring StudentSubGroup_TotalTested, gen(x) force
replace x = x - 1
tostring x, replace
replace StudentSubGroup_TotalTested = "1-" + x if Below == 1 & x != "."
replace StudentSubGroup_TotalTested = "--" if inlist(StudentSubGroup_TotalTested, "", "NA")
drop Below x

local vars Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent
foreach i of local vars {
	replace `i' = strtrim(`i')
	gen `i'A = 0
	gen `i'B = 0
	replace `i' = subinstr(`i', "%", "", 1)
	replace `i'A = 1 if strpos(`i', ">") > 0
	replace `i'B = 1 if strpos(`i', "<") > 0
	replace `i' = subinstr(`i', ">=", "", 1)
	replace `i' = subinstr(`i', "> ", "", 1)
	replace `i' = subinstr(`i', ">", "", 1)
	replace `i' = subinstr(`i', "<=", "", 1)
	replace `i' = subinstr(`i', "< ", "", 1)
	replace `i' = subinstr(`i', "<", "", 1)
	destring `i', gen(`i'x) force
	replace `i'x = `i'x/100
	replace `i'x = `i'x * 100 if inlist(Subject, "ela", "math") & StudentSubGroup == "All Students"
	tostring `i'x, gen(y) format("%9.2g") force
	replace `i' = y if y != "."
	replace `i' = "0-" + `i' if `i'B == 1
	replace `i' = `i' + "-1" if `i'A == 1
	replace `i' = "--" if inlist(`i', "-", "", "NA")
	replace `i' = "*" if `i' == "--" & StudentSubGroup_TotalTested == "1-15"
	drop y
}

local vars Lev1_count Lev2_count Lev3_count Lev4_count Lev5_count ProficientOrAbove_count
foreach i of local vars {
	replace `i' = strtrim(`i')
	gen `i'A = 0
	gen `i'B = 0
	replace `i' = subinstr(`i', "%", "", 1)
	replace `i'A = 1 if strpos(`i', ">") > 0
	replace `i'B = 1 if strpos(`i', "<") > 0
	replace `i' = subinstr(`i', ">=", "", 1)
	replace `i' = subinstr(`i', "> ", "", 1)
	replace `i' = subinstr(`i', ">", "", 1)
	replace `i' = subinstr(`i', "<=", "", 1)
	replace `i' = subinstr(`i', "< ", "", 1)
	replace `i' = subinstr(`i', "<", "", 1)
	replace `i' = "0-" + `i' if `i'B == 1
	replace `i' = `i' + "-1" if `i'A == 1
	replace `i' = "--" if inlist(`i', "-", "", "NA")
	replace `i' = "*" if `i' == "--" & StudentSubGroup_TotalTested == "1-15"
}

split StudentSubGroup_TotalTested, parse("-")
destring StudentSubGroup_TotalTested1, replace force
destring StudentSubGroup_TotalTested2, replace force

forvalues n = 1/5{
	gen Lev`n' = round(Lev`n'_percentx * StudentSubGroup_TotalTested1)
	gen Lev`n'2 = round(Lev`n'_percentx * StudentSubGroup_TotalTested2)
	tostring Lev`n', replace format("%9.2g") force
	tostring Lev`n'2, replace format("%9.2g") force
	replace Lev`n'_count = Lev`n' + "-1" if inlist(Lev`n'_count, "*", "--") & Lev`n' != "." & Lev`n'_percentA == 1
	replace Lev`n'_count = "0-" + Lev`n' if inlist(Lev`n'_count, "*", "--") & Lev`n' != "." & Lev`n'_percentB == 1
	replace Lev`n'_count = Lev`n' + "-" + Lev`n'2 if inlist(Lev`n'_count, "*", "--") & Lev`n' != "." & Lev`n'2 != "."
	replace Lev`n'_count = Lev`n' if inlist(Lev`n'_count, "*", "--") & Lev`n' != "."
	replace Lev`n'_count = "--" if StudentSubGroup != "All Students"
	replace Lev`n'_percent = "--" if StudentSubGroup != "All Students"
	replace Lev`n'_count = "*" if Lev`n'_percent == "*"
	drop Lev`n' Lev`n'2 Lev`n'_percentx Lev`n'_countA Lev`n'_countB Lev`n'_percentA Lev`n'_percentB
}

gen Prof = round(ProficientOrAbove_percentx * StudentSubGroup_TotalTested1)
gen Prof2 = round(ProficientOrAbove_percentx * StudentSubGroup_TotalTested2)
tostring Prof, replace format("%9.2g") force
tostring Prof2, replace format("%9.2g") force
replace ProficientOrAbove_count = Prof + "-1" if inlist(ProficientOrAbove_count, "*", "--") & Prof != "." & ProficientOrAbove_percentA == 1
replace ProficientOrAbove_count = "0-" + Prof if inlist(ProficientOrAbove_count, "*", "--") & Prof != "." & ProficientOrAbove_percentB == 1
replace ProficientOrAbove_count = Prof + "-" + Prof2 if inlist(ProficientOrAbove_count, "*", "--") & Prof != "." & Prof2 != "."
replace ProficientOrAbove_count = Prof if inlist(ProficientOrAbove_count, "*", "--") & Prof != "."
replace ProficientOrAbove_count = "*" if ProficientOrAbove_percent == "*"
drop Prof Prof2 ProficientOrAbove_percentx ProficientOrAbove_percentA ProficientOrAbove_percentB ProficientOrAbove_countA ProficientOrAbove_countB

replace Lev5_percent = "" if Subject == "sci" | Subject == "soc"
replace Lev5_count = "" if Subject == "sci" | Subject == "soc"

//	Create new variables


gen AssmtName="Colorado Measures of Academic Success"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="Y"
gen Flag_CutScoreChange_math="Y"
gen Flag_CutScoreChange_sci="N"
gen Flag_CutScoreChange_soc="N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3-4"
rename year SchYear
replace SchYear="2014-15"



// Relabel variable values
replace StudentSubGroup = strtrim(StudentSubGroup)

replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Hawaiian/Pacific Islander"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Pacific Islander"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Not Reported"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Unreported/ Not Applicable"
replace StudentSubGroup="White" if StudentSubGroup=="White"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="American Indian"
replace StudentSubGroup = "SWD" if StudentSubGroup == "IEP"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Non-IEP"
replace StudentSubGroup="English Learner" if StudentSubGroup=="English Learner (Not English Proficient/Limited English Proficient)**"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="Non-English Learner***"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Free/Reduced Lunch Eligible"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Free/Reduced Lunch Eligible"

replace StateAssignedDistID="0000" if StateAssignedDistID=="000"
replace StateAssignedSchID="0000" if StateAssignedSchID=="000"
replace DataLevel="District" if StateAssignedDistID!="0000" & StateAssignedSchID=="0000"
replace DataLevel="School" if StateAssignedDistID!="0000" & StateAssignedSchID!="0000"
replace DataLevel="State" if StateAssignedDistID=="0000" & StateAssignedSchID=="0000"

replace DataLevel = "School" if DataLevel == "SCH"
replace DataLevel = "District" if DataLevel == "DIST"
replace DataLevel = "State" if DataLevel == "STATE"
replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

replace StateAbbrev="CO" if StateAbbrev==""
replace State= "Colorado"

drop if SchName=="FAMILY EDUCATION NETWORK OF WELD CO"
drop if SchName == "HOTCHKISS HIGH SCHOOL"

replace ParticipationRate=strrtrim(ParticipationRate)
replace AvgScaleScore="*" if AvgScaleScore==""

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

replace DistName = strtrim(DistName)
replace SchName = strtrim(SchName)

//// Generates SubGroup totals

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

replace intStudentGroup=1 if StudentGroup=="All Students"
replace intStudentGroup=2 if StudentGroup=="Gender"
replace intStudentGroup=3 if StudentGroup=="RaceEth"
replace intStudentGroup=4 if StudentGroup=="EL Status"
replace intStudentGroup=5 if StudentGroup=="Economic Status"
replace intStudentGroup=6 if StudentGroup=="Disability Status"
replace intStudentGroup=7 if StudentGroup=="Migrant Status"


replace StudentSubGroup_TotalTested1=999999999 if StudentSubGroup_TotalTested1==.
replace StudentSubGroup_TotalTested2=999999999 if StudentSubGroup_TotalTested2==.


// Flag

save "${path}/CO_2015_base.dta", replace

collapse (sum) StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested2, by(NCESDistrictID NCESSchoolID intGrade intStudentGroup intSubject)

rename StudentSubGroup_TotalTested1 StudentGroup_TotalTested1
rename StudentSubGroup_TotalTested2 StudentGroup_TotalTested2

// Flag

save "${path}/CO_2015_studentgrouptotals.dta", replace


// Flag

use "${path}/CO_2015_base.dta", replace


// Flag

merge m:1 NCESDistrictID NCESSchoolID intGrade intSubject intStudentGroup using "${path}/CO_2015_studentgrouptotals.dta"

replace StudentGroup_TotalTested1=. if StudentGroup_TotalTested1>=10000000
replace StudentGroup_TotalTested2=. if StudentGroup_TotalTested2>=10000000
tostring StudentGroup_TotalTested1, replace
tostring StudentGroup_TotalTested2, replace
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="."
replace StudentGroup_TotalTested= StudentGroup_TotalTested + "-" + StudentGroup_TotalTested2 if StudentGroup_TotalTested2 != "."
replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen Suppressed = 0
replace Suppressed = 1 if inlist(StudentSubGroup_TotalTested, "--", "*")
egen StudentGroup_Suppressed = max(Suppressed), by(StudentGroup GradeLevel Subject DataLevel seasch StateAssignedDistID DistName SchName)
drop Suppressed
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
replace StudentGroup_TotalTested = AllStudents_Tested if StudentGroup_Suppressed == 1
replace StudentGroup_TotalTested = AllStudents_Tested if AllStudents_Tested == "1-15"
drop AllStudents_Tested StudentGroup_Suppressed
replace StudentGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "--"
replace StudentGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "*"

replace AvgScaleScore="*" if AvgScaleScore=="NA"
replace ParticipationRate="--" if ParticipationRate=="NA"

replace ProficiencyCriteria="Levels 4-5" if Subject=="math" | Subject == "ela"

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

replace DistName = "All Districts" if DataLevel == "State"
replace SchName="All Schools" if DataLevel=="State"
replace SchName="All Schools" if DataLevel=="District"

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force

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


