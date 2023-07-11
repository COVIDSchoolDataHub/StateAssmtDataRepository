
global base "/Users/hayden/Desktop/Research/VA"
global yrfiles "/Users/hayden/Desktop/Research/VA/2001"
global nces "/Users/hayden/Desktop/Research/NCES"
global output "/Users/hayden/Desktop/Research/VA/Output"


////	AGGREGATE DATA


//Transform to long

import excel "/${base}/VA_OriginalData_1998-2002_all.xls", sheet("1998-2002 % Passing By School") cellrange(A2:EP2119) firstrow case(lower) clear

rename writing1998 fifthwriting1998
rename writing1999 fifthwriting1999
rename writing2000 fifthwriting2000
rename writing2001 fifthwriting2001
rename writing2002 fifthwriting2002

rename englishrlr1998 fifthenglish1998
rename englishrlr1999 fifthenglish1999
rename englishrlr2000 fifthenglish2000
rename englishrlr2001 fifthenglish2001
rename englishrlr2002 fifthenglish2002

rename ak fifthmath1998
rename al fifthmath1999
rename am fifthmath2000
rename an fifthmath2001
rename ao fifthmath2002

rename ap fifthhistory1998
rename aq fifthhistory1999
rename ar fifthhistory2000
rename as fifthhistory2001
rename at fifthhistory2002

rename au fifthsci1998
rename av fifthsci1999
rename science20000 fifthsci2000
rename ax fifthsci2001
rename ay fifthsci2002

rename computertechnology1998 fifthcomp1998
rename computertechnology1999 fifthcomp1999
rename computertechnology20000 fifthcomp2000
rename computertechnology2001 fifthcomp2001
rename computertechnology2002 fifthcomp2002

rename be eighthwriting1998
rename bf eighthwriting1999
rename bg eighthwriting2000
rename bh eighthwriting2001
rename bi eighthwriting2002

rename bj eighthenglish1998
rename bk eighthenglish1999
rename bl eighthenglish2000
rename bm eighthenglish2001
rename bn eighthenglish2002

rename bo eighthmath1998
rename bp eighthmath1999
rename bq eighthmath2000
rename br eighthmath2001
rename bs eighthmath2002

rename bt eighthhistory1998
rename bu eighthhistory1999
rename bv eighthhistory2000
rename bw eighthhistory2001
rename bx eighthhistory2002

rename by eighthsci1998
rename bz eighthsci1999
rename ca eighthsci2000
rename cb eighthsci2001
rename cc eighthsci2002

rename cd eighthcomp1998
rename ce eighthcomp1999
rename computertechnology2000 eighthcomp2000
rename cg eighthcomp2001
rename ch eighthcomp2002

drop ci cj ck cl cm cn co cp cq cr algebrai1998 algebrai1999 algebrai2000 algebrai2001 algebrai2002 geometry1998 geometry1999 geometry2000 geometry2001 geometry2002 algebraii1998 algebraii1999 algebraii2000 algebraii2001 algebraii2002 ushistory1998 ushistory1999 ushistory2000 ushistory2001 ushistory2002 worldhistoryi1998 worldhistoryi1999 worldhistoryi2000 worldhistoryi2001 worldhistoryi2002 worldhistoryii1998 worldhistoryii1999 worldhistoryii2000 worldhistoryii2001 worldhistoryii2002 worldgeography1998 worldgeography1999 worldgeography2000 worldgeography2001 worldgeography2002 earthscience1998 earthscience1999 earthscience2000 earthscience2001 earthscience2002 biology1998 biology1999 biology2000 biology2001 biology2002 chemistry1998 chemistry1999 chemistry2000 chemistry2001 chemistry2002

drop if divisionname==""

gen id=_n

reshape long fifthwriting fifthenglish fifthmath fifthsci fifthcomp fifthhistory eighthcomp eighthenglish eighthwriting eighthmath eighthsci eighthhistory english mathematics history science, i(id) j(year)



////	FLAG

drop if year!=2001

////



rename english english3
rename mathematics math3
rename history history3
rename science sci3
rename fifthwriting writing5
rename fifthenglish english5
rename fifthmath math5
rename fifthhistory history5
rename fifthsci sci5
rename fifthcomp comp5
rename eighthwriting writing8
rename eighthenglish english8
rename eighthmath math8
rename eighthhistory history8
rename eighthsci sci8
rename eighthcomp comp8

reshape long english writing sci math history comp, i(id) j(grade)

rename writing subject1
rename english subject2
rename math subject3
rename history subject4
rename sci subject5
rename comp subject6

drop id
gen id=_n

reshape long subject, i(id) j(testsubject)


// drop observations for writing and compsci for G03 since it was not administered

drop if grade==3 & testsubject==1
drop if grade==3 & testsubject==6


// rewrite percent as decimal
destring subject, replace
replace subject=subject/100

rename subject ProficientOrAbove_percent

// remove PK only programs and high schools
drop if highgr=="PK"
drop if highgr=="KG"
destring highgr, replace
drop if ProficientOrAbove_percent==. & highgr>8

drop highgr lowgr id

gen Subject=""
replace Subject="wri" if testsubject==1
replace Subject="eng" if testsubject==2
replace Subject="math" if testsubject==3
replace Subject="soc" if testsubject==4
replace Subject="sci" if testsubject==5
replace Subject="stem" if testsubject==6

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"

save "/${yrfiles}/VA_2001_base.dta", replace




//// PREPARE DISAGGREGATE TOTALS FOR APPENDING


// Gender

import excel "/${base}/VA_1998-2002_gender.xls", sheet("shading (2)") cellrange(B3:L41) firstrow clear

gen gradebreakup=_n
drop if gradebreakup>=23

gen grade=.
replace grade=3 if gradebreakup<=6
replace grade=5 if gradebreakup>=9
replace grade=8 if gradebreakup>=17



//	FLAG

drop Female Male E F G H K L
rename I gender1
rename J gender2

//


drop if gradebreakup==1
drop if gradebreakup==2
drop if gradebreakup==7
drop if gradebreakup==8
drop if gradebreakup==15
drop if gradebreakup==16
drop gradebreakup

gen id=_n

reshape long gender, i(id) j(genderindicator)

gen StudentGroup="Gender"
gen StudentSubGroup=""
replace StudentSubGroup="Female" if genderindicator==1
replace StudentSubGroup="Male" if genderindicator==2
drop genderindicator id

rename gender ProficientOrAbove_percent
rename SOLTest Subject

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100


save "/${yrfiles}/VA_2001_gender.dta", replace


// Race & Ethnicity, grade 3

import excel "/${base}/VA_1998-2002_raceeth.xls", sheet("Sheet1 (2)") cellrange(A5:AE14) clear


//FLAG

keep A E J O T
rename A StudentSubGroup
rename E ProficientOrAbove_percent1	//Eng
rename J ProficientOrAbove_percent2	//math
rename O ProficientOrAbove_percent3	//Hist
rename T ProficientOrAbove_percent4	//Sci

//

gen grade=3

gen id=_n
drop if id<=4

reshape long ProficientOrAbove_percent, i(id) j(subjectindicator)
destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100

gen Subject=""
replace Subject="eng" if subjectindicator==1
replace Subject="math" if subjectindicator==2
replace Subject="soc" if subjectindicator==3
replace Subject="sci" if subjectindicator==4
drop subjectindicator id

gen StudentGroup="RaceEth"

save "/${yrfiles}/VA_2001_race3.dta", replace


// Race & Ethnicity, grade 5

import excel "/${base}/VA_1998-2002_raceeth.xls", sheet("Sheet1 (2)") cellrange(A18:AE40) clear


//FLAG

keep A E J O T Y AD
rename A StudentSubGroup
rename E ProficientOrAbove_percent1	//Eng
rename J ProficientOrAbove_percent2	//wri
rename O ProficientOrAbove_percent3	//mat
rename T ProficientOrAbove_percent4	//soc
rename Y ProficientOrAbove_percent5	//sci
rename AD ProficientOrAbove_percent6	//stem

//

gen id=_n
gen grade=.
replace grade=5 if id<12
replace grade=8 if id>12
drop if id<=4
drop if id>10 & id<18

reshape long ProficientOrAbove_percent, i(id) j(subjectindicator)
destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100

gen Subject=""
replace Subject="eng" if subjectindicator==1
replace Subject="wri" if subjectindicator==2
replace Subject="math" if subjectindicator==3
replace Subject="soc" if subjectindicator==4
replace Subject="sci" if subjectindicator==5
replace Subject="stem" if subjectindicator==6

drop subjectindicator id

gen StudentGroup="RaceEth"

save "/${yrfiles}/VA_2001_race58.dta", replace


//	EL Status

import excel "/${base}/VA_2000-2002_elstatus.xls", sheet("Sheet1") cellrange(B2:H24) firstrow clear

gen gradebreakup=_n

gen grade=.
replace grade=3 if gradebreakup<=6
replace grade=5 if gradebreakup>=9
replace grade=8 if gradebreakup>=17


//	FLAG	//
drop NonLEP LEP G H
rename E elstatus1
rename F elstatus2
//



drop if gradebreakup==1
drop if gradebreakup==2
drop if gradebreakup==7
drop if gradebreakup==8
drop if gradebreakup==15
drop if gradebreakup==16


gen id=_n

reshape long elstatus, i(id) j(elstatusindicator)

gen StudentGroup="EL Status"
gen StudentSubGroup=""
replace StudentSubGroup="English Proficient" if elstatusindicator==1
replace StudentSubGroup="English Learner" if elstatusindicator==2
drop elstatusindicator id

rename elstatus ProficientOrAbove_percent
rename SOLTEST Subject

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent=ProficientOrAbove_percent/100


save "/${yrfiles}/VA_2001_elstatus.dta", replace




////	APPEND AGGREGATE AND DISAGGREGATE DATA

use "/${yrfiles}/VA_2001_base.dta", clear

append using "/${yrfiles}/VA_2001_gender.dta"
append using "/${yrfiles}/VA_2001_race3.dta"
append using "/${yrfiles}/VA_2001_race58.dta"
append using "/${yrfiles}/VA_2001_elstatus.dta"


////	PREPARE FOR NCES MERGE

gen StateAssignedDistId=div

destring div, gen(divindex)
replace div="00" + div if divindex<10
replace div="0" + div if divindex>=10 & divindex<100


gen StateAssignedSchID=sch
tostring sch, replace
destring sch, gen(schindex)
replace sch=div+"000"+sch if schindex<10
replace sch=div+"00"+sch if schindex>=10 & schindex<100
replace sch=div+"0"+sch if schindex>=100 & schindex<1000
replace sch=div+sch if schindex>=1000

rename div state_leaid
rename sch seasch
tostring StateAssignedSchID, replace
replace seasch="" if schoolname=="DIVISION SUMMARY"
replace StateAssignedSchID="" if schoolname=="DIVISION SUMMARY"
replace seasch="" if schoolname=="STATE SUMMARY"
replace StateAssignedSchID="" if schoolname=="STATE SUMMARY"

save "/${yrfiles}/VA_2001_all.dta", replace

////	MERGE NCES VARIABLES


use "/${nces}/NCES_2002_District.dta", clear
keep if state_fips==51
save "/${yrfiles}/Virginia_2002_NCESDistrict.dta", replace

use "/${nces}/NCES_2002_School.dta", clear
keep if state_fips==51
save "/${yrfiles}/Virginia_2002_NCESSchool.dta", replace

use "/${yrfiles}/VA_2001_all.dta", clear

replace state_leaid="003" if state_leaid=="099"

merge m:1 state_leaid using "/${yrfiles}/Virginia_2002_NCESDistrict.dta"
drop if _merge==2
rename _merge district_merge

merge m:1 seasch using "/${yrfiles}/Virginia_2002_NCESSchool.dta"
drop if _merge==2


////	FINISH CLEANING DATA

gen Lev1_count="*"
gen Lev2_count="*"
gen Lev3_count="*"
gen Lev4_count="*"
gen Lev5_count="*"
gen Lev1_percent="*"
gen Lev2_percent="*"
gen Lev3_percent="*"
gen Lev4_percent="*"
gen Lev5_percent="*"

replace Subject="stem" if Subject=="Computer/Technology"
replace Subject="eng" if Subject=="English"
replace Subject="read" if Subject=="English: Reading Literature & Research"
replace Subject="read" if Subject=="English: Reading, Literature & Research"
replace Subject="wri" if Subject=="English: Writing"
replace Subject="wri" if Subject=="English:Writing"
replace Subject="soc" if Subject=="History"
replace Subject="math" if Subject=="Mathematics"
replace Subject="sci" if Subject=="Science"
replace Subject="stem" if Subject=="COMPUTER/TECHNOLOGY"
replace Subject="eng" if Subject=="ENGLISH"
replace Subject="read" if Subject=="ENGLISH: READING"
replace Subject="wri" if Subject=="ENGLISH: WRITING"
replace Subject="soc" if Subject=="HISTORY & SOCIAL SCIENCE"
replace Subject="math" if Subject=="MATHEMATICS"
replace Subject="sci" if Subject=="SCIENCE"

gen DataLevel=2
replace DataLevel=0 if StudentGroup=="RaceEth"
replace DataLevel=0 if StudentGroup=="Gender"
replace DataLevel=0 if schoolname=="STATE SUMMARY"
replace DataLevel=1 if schoolname=="DIVISION SUMMARY"

label define LevelIndicator 0 "State" 1 "District" 2 "School"
label values DataLevel LevelIndicator

tostring grade, replace
rename grade GradeLevel
replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G08" if GradeLevel=="8"

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = "N"
gen Flag_CutScoreChange_oth = "N"
gen AssmtName="Standards of Learning"
gen AssmtType="Regular"



//	FLAG //
gen SchYear="2000-01"
//		//



gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested="*"
gen AvgScaleScore="*"
gen ProficiencyCriteria="Pass Proficient or Pass Advanced"
gen ProficientOrAbove_count=.
gen ParticipationRate=.

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename lea_name DistName
rename district_agency_type DistType
rename school_name SchName
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
rename StateAssignedDistId StateAssignedDistID

replace StudentSubGroup="Black or African American" if StudentSubGroup=="African American"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="Am Indian/Alaskan Native"
replace StudentSubGroup="White" if StudentSubGroup=="Caucasian"
replace StudentSubGroup="Asian" if StudentSubGroup=="Asian/Pacific Islander"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Ethnicity Unknown"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"


keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

tostring NCESDistrictID, replace force
tostring NCESSchoolID, replace force


replace State=51 if State==.
replace StateAbbrev="VA" if StateAbbrev==""
replace StateFips=51 if StateFips==.
replace DistName="All Districts" if DataLevel==0
replace SchName="All Schools" if DataLevel!=2
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="."



export delimited using "${output}/VA_AssmtData_2001.csv", replace
