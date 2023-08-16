clear
global base "/Users/hayden/Desktop/Research/VA"
global yrfiles "/Users/hayden/Desktop/Research/VA/2003"
global nces "/Users/hayden/Desktop/Research/NCES"
global output "/Users/hayden/Desktop/Research/VA/Output"


////	AGGREGATE DATA


import excel "/${base}/VA_OriginalData_2003-2005_all.xls", sheet("spring_pass_rate_table_03_to_05") cellrange(A3:GX1973) firstrow

//rename convention: Level_SubjectCode_Grade_Year
	//English: 1
	//Writing: 2
	//Math: 3
	//History: 4
	//Science: 5


rename Grade3English Pass_1_3_2003
rename H Pass_1_3_2004
rename I Proficient_1_3_2004
rename J Advanced_1_3_2004
rename K Pass_1_3_2005
rename L Proficient_1_3_2005
rename M Advanced_1_3_2005
rename Grade5English Pass_1_5_2003
rename O Pass_1_5_2004
rename P Proficient_1_5_2004
rename Q Advanced_1_5_2004
rename R Pass_1_5_2005
rename S Proficient_1_5_2005
rename T Advanced_1_5_2005
rename Grade5Writing Pass_2_5_2003
rename V Pass_2_5_2004
rename W Proficient_2_5_2004
rename X Advanced_2_5_2004
rename Y Pass_2_5_2005
rename Z Proficient_2_5_2005
rename AA Advanced_2_5_2005
rename Grade8English Pass_1_8_2003
rename AC Pass_1_8_2004
rename AD Proficient_1_8_2004
rename AE Advanced_1_8_2004
rename AF Pass_1_8_2005
rename AG Proficient_1_8_2005
rename AH Advanced_1_8_2005
rename Grade8Writing Pass_2_8_2003
rename AJ Pass_2_8_2004
rename AK Proficient_2_8_2004
rename AL Advanced_2_8_2004
rename AM Pass_2_8_2005
rename AN Proficient_2_8_2005
rename AO Advanced_2_8_2005
rename Grade3Math Pass_3_3_2003
rename BE Pass_3_3_2004
rename BF Proficient_3_3_2004
rename BG Advanced_3_3_2004
rename BH Pass_3_3_2005
rename BI Proficient_3_3_2005
rename BJ Advanced_3_3_2005
rename Grade5Math Pass_3_5_2003
rename BL Pass_3_5_2004
rename BM Proficient_3_5_2004
rename BN Advanced_3_5_2004
rename BO Pass_3_5_2005
rename BP Proficient_3_5_2005
rename BQ Advanced_3_5_2005
rename Grade8Math Pass_3_8_2003
rename BS Pass_3_8_2004
rename BT Proficient_3_8_2004
rename BU Advanced_3_8_2004
rename BV Pass_3_8_2005
rename BW Proficient_3_8_2005
rename BX Advanced_3_8_2005
rename Grade3HistorySS Pass_4_3_2003
rename CU Pass_4_3_2004
rename CV Proficient_4_3_2004
rename CW Advanced_4_3_2004
rename CX Pass_4_3_2005
rename CY Proficient_4_3_2005
rename CZ Advanced_4_3_2005
rename Grade5HistorySS Pass_4_5_2003
rename DB Pass_4_5_2004
rename DC Proficient_4_5_2004
rename DD Advanced_4_5_2004
rename DE Pass_4_5_2005
rename DF Proficient_4_5_2005
rename DG Advanced_4_5_2005
rename Grade8HistorySS Pass_4_8_2003
rename DI Pass_4_8_2004
rename DJ Proficient_4_8_2004
rename DK Advanced_4_8_2004
rename DL Pass_4_8_2005
rename DM Proficient_4_8_2005
rename DN Advanced_4_8_2005
rename Grade3Science Pass_5_3_2003
rename FJ Pass_5_3_2004
rename FK Proficient_5_3_2004
rename FL Advanced_5_3_2004
rename FM Pass_5_3_2005
rename FN Proficient_5_3_2005
rename FO Advanced_5_3_2005
rename Grade5Science Pass_5_5_2003
rename FQ Pass_5_5_2004
rename FR Proficient_5_5_2004
rename FS Advanced_5_5_2004
rename FT Pass_5_5_2005
rename FU Proficient_5_5_2005
rename FV Advanced_5_5_2005
rename Grade8Science Pass_5_8_2003
rename FX Pass_5_8_2004
rename FY Proficient_5_8_2004
rename FZ Advanced_5_8_2004
rename GA Pass_5_8_2005
rename GB Proficient_5_8_2005
rename GC Advanced_5_8_2005

drop if HighGrade=="PK"

drop EOCEnglish AQ AR AS AT AU AV EOCWriting AX AY AZ BA BB BC Algebra1Pass BZ Algebra1Proficient Algebra1Advanced CC CD CE GeometryPass CG GeometryProficient GeometryAdvanced CJ CK CL Algebra2Pass CN Algebra2Proficient Algebra2Advanced CQ CR CS USHistory DP DQ DR DS DT DU DV DW DX DY DZ Civicsand EB EC ED EE EF VaandUSHistory EH EI EJ EK EL EM WorldHistory EO EP EQ ER ES ET WorldGeography EV EW EX EY EZ FA FB FC FD FE FF FG FH EarthScience GE GF GG GH GI GJ BiologyPass GL BiologyProficient BiologyAdvanced GO GP GQ ChemistryPass GS ChemistryProficient ChemistryAdvanced GV GW GX

gen id=_n

drop if id==1
drop if id==2

reshape long Pass_1_3_ Proficient_1_3_ Advanced_1_3_ Pass_1_5_ Proficient_1_5_ Advanced_1_5_ Pass_1_8_ Proficient_1_8_ Advanced_1_8_ Pass_2_3_ Proficient_2_3_ Advanced_2_3_ Pass_2_5_ Proficient_2_5_ Advanced_2_5_ Pass_2_8_ Proficient_2_8_ Advanced_2_8_ Pass_3_3_ Proficient_3_3_ Advanced_3_3_ Pass_3_5_ Proficient_3_5_ Advanced_3_5_ Pass_3_8_ Proficient_3_8_ Advanced_3_8_ Pass_4_3_ Proficient_4_3_ Advanced_4_3_ Pass_4_5_ Proficient_4_5_ Advanced_4_5_ Pass_4_8_ Proficient_4_8_ Advanced_4_8_ Pass_5_3_ Proficient_5_3_ Advanced_5_3_ Pass_5_5_ Proficient_5_5_ Advanced_5_5_ Pass_5_8_ Proficient_5_8_ Advanced_5_8_, i(id) j(year)

drop id

//////////////////////////////////////////////
drop if year!=2003
//////////////////////////////////////////////

gen id=_n

rename Pass_1_3_ Pass_1_3
rename Proficient_1_3_  Proficient_1_3
rename Advanced_1_3_ Advanced_1_3
rename Pass_1_5_ Pass_1_5
rename Proficient_1_5_ Proficient_1_5
rename Advanced_1_5_ Advanced_1_5
rename Pass_2_5_ Pass_2_5
rename Proficient_2_5_ Proficient_2_5
rename Advanced_2_5_ Advanced_2_5
rename Pass_1_8_ Pass_1_8
rename Proficient_1_8_ Proficient_1_8
rename Advanced_1_8_  Advanced_1_8
rename Pass_2_8_ Pass_2_8
rename Proficient_2_8_ Proficient_2_8
rename Advanced_2_8_ Advanced_2_8
rename Pass_3_3_ Pass_3_3
rename Proficient_3_3_ Proficient_3_3
rename Advanced_3_3_ Advanced_3_3
rename Pass_3_5_ Pass_3_5
rename Proficient_3_5_ Proficient_3_5
rename Advanced_3_5_ Advanced_3_5
rename Pass_3_8_ Pass_3_8 
rename Proficient_3_8_ Proficient_3_8 
rename Advanced_3_8_ Advanced_3_8
rename Pass_4_3_ Pass_4_3
rename Proficient_4_3_ Proficient_4_3
rename Advanced_4_3_ Advanced_4_3
rename Pass_4_5_ Pass_4_5
rename Proficient_4_5_ Proficient_4_5 
rename Advanced_4_5_ Advanced_4_5 
rename Pass_4_8_ Pass_4_8
rename Proficient_4_8_ Proficient_4_8
rename Advanced_4_8_ Advanced_4_8
rename Pass_5_3_ Pass_5_3
rename Proficient_5_3_ Proficient_5_3
rename Advanced_5_3_ Advanced_5_3
rename Pass_5_5_ Pass_5_5
rename Proficient_5_5_ Proficient_5_5
rename Advanced_5_5_ Advanced_5_5
rename Pass_5_8_ Pass_5_8
rename Proficient_5_8_ Proficient_5_8
rename Advanced_5_8_ Advanced_5_8
drop Pass_2_3_ 
drop Proficient_2_3_
drop Advanced_2_3_

reshape long Pass_1 Proficient_1 Advanced_1 Pass_2 Proficient_2 Advanced_2 Pass_3 Proficient_3 Advanced_3 Pass_4 Proficient_4 Advanced_4 Pass_5 Proficient_5 Advanced_5, i(id) j(grade) string

drop id
gen id=_n

reshape long Pass Proficient Advanced, i(id) j(subject) string
drop id

drop if subject=="_2" & grade=="_3"

rename subject Subject
replace Subject="ela" if Subject=="_1"
replace Subject="wri" if Subject=="_2"
replace Subject="math" if Subject=="_3"
replace Subject="soc" if Subject=="_4"
replace Subject="sci" if Subject=="_5"

rename grade GradeLevel
replace GradeLevel="G03" if GradeLevel=="_3"
replace GradeLevel="G05" if GradeLevel=="_5"
replace GradeLevel="G08" if GradeLevel=="_8"

gen DataLevel=2
replace DataLevel=0 if DivisionName=="STATE SUMMARY"
replace DataLevel=1 if SchoolName=="DIVISION SUMMARY"

gen StudentSubGroup="All Students"
gen StudentGroup="All Students"


save "/${yrfiles}/VA_2003_base.dta", replace


////	PREPARE DISAGGREGATE DATA


// Grade 3

import excel "/${base}/VA_2003-2005_disaggregate_G03.xls", sheet("spring_only_sol_by_grade") cellrange(A3:AK16) firstrow clear

gen id=_n

destring EnglishProficient2003 EnglishAdvanced2003 EnglishPassed2003 EnglishProficient2004 EnglishAdvanced2004 EnglishPassed2004 EnglishProficient2005 EnglishAdvanced2005 EnglishPassed2005 MathProficient2003 MathAdvanced2003 MathPassed2003 MathProficient2004 MathAdvanced2004 MathPassed2004 MathProficient2005 MathAdvanced2005 MathPassed2005 HistoryProficient2003 HistoryAdvanced2003 HistoryPassed2003 HistoryProficient2004 HistoryAdvanced2004 HistoryPassed2004 HistoryProficient2005 HistoryAdvanced2005 HistoryPassed2005 ScienceProficient2003 ScienceAdvanced2003 SciencePassed2003 ScienceProficient2004 ScienceAdvanced2004 SciencePassed2004 ScienceProficient2005 ScienceAdvanced2005 SciencePassed2005, replace

reshape long EnglishPassed EnglishProficient EnglishAdvanced MathPassed MathProficient MathAdvanced HistoryPassed HistoryProficient HistoryAdvanced SciencePassed ScienceProficient ScienceAdvanced, i(id) j(year)



////////////////////////////////////

drop if year!=2003

////////////////////////////////////



drop id
gen id=_n

rename EnglishProficient Proficient1
rename EnglishPassed Pass1
rename EnglishAdvanced Advanced1
rename MathProficient Proficient2
rename MathPassed Pass2
rename MathAdvanced Advanced2
rename HistoryProficient Proficient3
rename HistoryPassed Pass3
rename HistoryAdvanced Advanced3
rename ScienceProficient Proficient4
rename SciencePassed Pass4
rename ScienceAdvanced Advanced4

reshape long Proficient Pass Advanced, i(id) j(subject)

gen Subject=""
replace Subject="ela" if subject==1
replace Subject="math" if subject==2
replace Subject="soc" if subject==3
replace Subject="sci" if subject==4

drop if Category=="All Students"
drop if Category=="Students with Disabilities"
rename Category StudentSubGroup

gen StudentGroup=""
replace StudentGroup="Gender" if StudentSubGroup=="Gender Unknown"
replace StudentGroup="RaceEth" if StudentSubGroup=="Ethnicity Unknown"


replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="Am Indian/Alaskan Native"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Ethnicity Unknown"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Gender Unknown"
replace StudentSubGroup="English Learner" if StudentSubGroup=="Limited English Proficient"

replace StudentGroup="Gender" if StudentSubGroup=="Female"
replace StudentGroup="Gender" if StudentSubGroup=="Male"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="RaceEth" if StudentSubGroup=="Black or African American"
replace StudentGroup="RaceEth" if StudentSubGroup=="Hispanic or Latino"
replace StudentGroup="RaceEth" if StudentSubGroup=="White"
replace StudentGroup="RaceEth" if StudentSubGroup=="American Indian or Alaska Native"
replace StudentGroup="RaceEth" if StudentSubGroup=="Asian/Pacific Islander"
replace StudentGroup="RaceEth" if StudentSubGroup=="Native Hawaiian"

replace StudentSubGroup="Asian" if StudentSubGroup=="Asian/Pacific Islander"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian"

gen GradeLevel="G03"
gen DataLevel=0

drop id

save "/${yrfiles}/VA_2003_G03.dta", replace




//	Grade 5

import excel "/${base}/VA_2003-2005_disaggregate_G05.xls", sheet("spring_only_sol_by_grade") cellrange(A3:AK16) firstrow clear

gen id=_n

destring EnglishProficient2003 EnglishAdvanced2003 EnglishPassed2003 EnglishProficient2004 EnglishAdvanced2004 EnglishPassed2004 EnglishProficient2005 EnglishAdvanced2005 EnglishPassed2005 MathProficient2003 MathAdvanced2003 MathPassed2003 MathProficient2004 MathAdvanced2004 MathPassed2004 MathProficient2005 MathAdvanced2005 MathPassed2005 HistoryProficient2003 HistoryAdvanced2003 HistoryPassed2003 HistoryProficient2004 HistoryAdvanced2004 HistoryPassed2004 HistoryProficient2005 HistoryAdvanced2005 HistoryPassed2005 ScienceProficient2003 ScienceAdvanced2003 SciencePassed2003 ScienceProficient2004 ScienceAdvanced2004 SciencePassed2004 ScienceProficient2005 ScienceAdvanced2005 SciencePassed2005, replace

reshape long EnglishPassed EnglishProficient EnglishAdvanced MathPassed MathProficient MathAdvanced HistoryPassed HistoryProficient HistoryAdvanced SciencePassed ScienceProficient ScienceAdvanced, i(id) j(year)



////////////////////////////////////

drop if year!=2003

////////////////////////////////////



drop id
gen id=_n

rename EnglishProficient Proficient1
rename EnglishPassed Pass1
rename EnglishAdvanced Advanced1
rename MathProficient Proficient2
rename MathPassed Pass2
rename MathAdvanced Advanced2
rename HistoryProficient Proficient3
rename HistoryPassed Pass3
rename HistoryAdvanced Advanced3
rename ScienceProficient Proficient4
rename SciencePassed Pass4
rename ScienceAdvanced Advanced4

reshape long Proficient Pass Advanced, i(id) j(subject)

gen Subject=""
replace Subject="ela" if subject==1
replace Subject="math" if subject==2
replace Subject="soc" if subject==3
replace Subject="sci" if subject==4

drop if Category=="All Students"
drop if Category=="Students with Disabilities"
rename Category StudentSubGroup

gen StudentGroup=""
replace StudentGroup="Gender" if StudentSubGroup=="Gender Unknown"
replace StudentGroup="RaceEth" if StudentSubGroup=="Ethnicity Unknown"


replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="Am Indian/Alaskan Native"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Ethnicity Unknown"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Gender Unknown"
replace StudentSubGroup="English Learner" if StudentSubGroup=="Limited English Proficient"

replace StudentGroup="Gender" if StudentSubGroup=="Female"
replace StudentGroup="Gender" if StudentSubGroup=="Male"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="RaceEth" if StudentSubGroup=="Black or African American"
replace StudentGroup="RaceEth" if StudentSubGroup=="Hispanic or Latino"
replace StudentGroup="RaceEth" if StudentSubGroup=="White"
replace StudentGroup="RaceEth" if StudentSubGroup=="American Indian or Alaska Native"
replace StudentGroup="RaceEth" if StudentSubGroup=="Asian/Pacific Islander"
replace StudentGroup="RaceEth" if StudentSubGroup=="Native Hawaiian"

replace StudentSubGroup="Asian" if StudentSubGroup=="Asian/Pacific Islander"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian"

gen GradeLevel="G05"
gen DataLevel=0

drop id

save "/${yrfiles}/VA_2003_G05.dta", replace



//	Grade 8

import excel "/${base}/VA_2003-2005_disaggregate_G08.xls", sheet("spring_only_sol_by_grade") cellrange(A3:AK16) firstrow clear

gen id=_n

destring EnglishProficient2003 EnglishAdvanced2003 EnglishPassed2003 EnglishProficient2004 EnglishAdvanced2004 EnglishPassed2004 EnglishProficient2005 EnglishAdvanced2005 EnglishPassed2005 MathProficient2003 MathAdvanced2003 MathPassed2003 MathProficient2004 MathAdvanced2004 MathPassed2004 MathProficient2005 MathAdvanced2005 MathPassed2005 HistoryProficient2003 HistoryAdvanced2003 HistoryPassed2003 HistoryProficient2004 HistoryAdvanced2004 HistoryPassed2004 HistoryProficient2005 HistoryAdvanced2005 HistoryPassed2005 ScienceProficient2003 ScienceAdvanced2003 SciencePassed2003 ScienceProficient2004 ScienceAdvanced2004 SciencePassed2004 ScienceProficient2005 ScienceAdvanced2005 SciencePassed2005, replace

reshape long EnglishPassed EnglishProficient EnglishAdvanced MathPassed MathProficient MathAdvanced HistoryPassed HistoryProficient HistoryAdvanced SciencePassed ScienceProficient ScienceAdvanced, i(id) j(year)



////////////////////////////////////

drop if year!=2003

////////////////////////////////////



drop id
gen id=_n

rename EnglishProficient Proficient1
rename EnglishPassed Pass1
rename EnglishAdvanced Advanced1
rename MathProficient Proficient2
rename MathPassed Pass2
rename MathAdvanced Advanced2
rename HistoryProficient Proficient3
rename HistoryPassed Pass3
rename HistoryAdvanced Advanced3
rename ScienceProficient Proficient4
rename SciencePassed Pass4
rename ScienceAdvanced Advanced4

reshape long Proficient Pass Advanced, i(id) j(subject)

gen Subject=""
replace Subject="ela" if subject==1
replace Subject="math" if subject==2
replace Subject="soc" if subject==3
replace Subject="sci" if subject==4

drop if Category=="All Students"
drop if Category=="Students with Disabilities"
rename Category StudentSubGroup

gen StudentGroup=""
replace StudentGroup="Gender" if StudentSubGroup=="Gender Unknown"
replace StudentGroup="RaceEth" if StudentSubGroup=="Ethnicity Unknown"


replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="Am Indian/Alaskan Native"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Ethnicity Unknown"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Gender Unknown"
replace StudentSubGroup="English Learner" if StudentSubGroup=="Limited English Proficient"

replace StudentGroup="Gender" if StudentSubGroup=="Female"
replace StudentGroup="Gender" if StudentSubGroup=="Male"
replace StudentGroup="EL Status" if StudentSubGroup=="English Learner"
replace StudentGroup="RaceEth" if StudentSubGroup=="Black or African American"
replace StudentGroup="RaceEth" if StudentSubGroup=="Hispanic or Latino"
replace StudentGroup="RaceEth" if StudentSubGroup=="White"
replace StudentGroup="RaceEth" if StudentSubGroup=="American Indian or Alaska Native"
replace StudentGroup="RaceEth" if StudentSubGroup=="Asian/Pacific Islander"
replace StudentGroup="RaceEth" if StudentSubGroup=="Native Hawaiian"

replace StudentSubGroup="Asian" if StudentSubGroup=="Asian/Pacific Islander"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian"

gen GradeLevel="G08"
gen DataLevel=0

drop id

save "/${yrfiles}/VA_2003_G08.dta", replace



//	Append aggregate and subgroup data together

use "/${yrfiles}/VA_2003_base.dta", clear

destring Pass Proficient Advanced, replace

append using "/${yrfiles}/VA_2003_G03.dta"
append using "/${yrfiles}/VA_2003_G05.dta"
append using "/${yrfiles}/VA_2003_G08.dta"


//	Prepare for NCES merge

destring DivNo, gen(StateAssignedDistID)
destring SchNo, gen(StateAssignedSchID)

replace DivNo="00" + DivNo if StateAssignedDistID<=9
replace DivNo="0" + DivNo if StateAssignedDistID<=99 & StateAssignedDistID>=10

replace SchNo=DivNo + "000" + SchNo if StateAssignedSchID<=9
replace SchNo=DivNo + "00" + SchNo if StateAssignedSchID<=99 & StateAssignedSchID>=10
replace SchNo=DivNo + "0" + SchNo if StateAssignedSchID<=999 & StateAssignedSchID>=100
replace SchNo=DivNo + SchNo if StateAssignedSchID>=1000

rename DivNo state_leaid
rename SchNo seasch

save "/${yrfiles}/VA_2003_all.dta", replace


		// Prepare dist data
		
use "/${nces}/NCES_2002_District.dta", clear

drop if state_fips!=51

save "/${yrfiles}/VA_2002_NCESDistricts.dta", replace

		// Prepare school data
		
use "/${nces}/NCES_2002_School.dta", clear

drop if state_fips!=51

save "/${yrfiles}/VA_2002_NCESSchools.dta", replace


use "/${yrfiles}/VA_2003_all.dta", clear

merge m:1 state_leaid using "/${yrfiles}/VA_2002_NCESDistricts.dta"
drop if _merge==2
rename _merge dist_merge


	// drop closed schools
	
drop if seasch=="0010704"
drop if seasch=="0010703"
drop if seasch=="0070622"
drop if seasch=="1360950"
drop if seasch=="1081377"
drop if seasch=="0300854"
drop if seasch=="1350561"
drop if seasch=="0430260"
drop if seasch=="0430100"
drop if seasch=="0430240"
drop if seasch=="0480221"
drop if seasch=="0530940"
drop if seasch=="0530300"
drop if seasch=="0530890"
drop if seasch=="0530031"
drop if seasch=="0530091"
drop if seasch=="0530320"
drop if seasch=="0530980"
drop if seasch=="0530090"
drop if seasch=="1171407"
drop if seasch=="1182119"
drop if seasch=="0711853"
drop if seasch=="0750290"
drop if seasch=="0750300"
drop if seasch=="0750220"
drop if seasch=="0750240"
drop if seasch=="0750270"
drop if seasch=="0770230"
drop if seasch=="0880509"
drop if seasch=="0880510"
drop if seasch=="0890428"
drop if seasch=="0890429"
drop if seasch=="1270395"
replace seasch="0380070" if seasch=="0380910"
replace seasch="1210280" if seasch=="1211766"
replace seasch="0720130" if seasch=="0720232"
replace seasch="0750943" if seasch=="0750945"


merge m:1 seasch using "/${yrfiles}/VA_2002_NCESSchools.dta"
drop if _merge==2
rename _merge sch_merge

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename state_leaid State_leaid
rename Pass ProficientOrAbove_percent
rename Proficient Lev3_percent
rename Advanced Lev4_percent
rename lea_name DistName
rename district_agency_type DistType
rename school_name SchName
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode

replace ProficientOrAbove_percent=ProficientOrAbove_percent/100
replace Lev3_percent=Lev3_percent/100
replace Lev4_percent=Lev4_percent/100

tostring ProficientOrAbove_percent Lev3_percent Lev4_percent, replace force

replace Lev3_percent="*" if Lev3_percent=="" | Lev3_percent=="."
replace Lev4_percent="*" if Lev4_percent=="" | Lev4_percent=="."
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="" | ProficientOrAbove_percent=="."

gen Lev1_count="*"
gen Lev1_percent="*"
gen Lev2_count="*"
gen Lev2_percent="*"
gen Lev3_count="*"
gen Lev4_count="*"
gen Lev5_percent="*"
gen Lev5_count="*"
gen ProficientOrAbove_count="*"
gen ProficiencyCriteria="Pass Proficent or Pass Advanced (Lev 3 or Lev 4)"
gen AvgScaleScore="*"
gen ParticipationRate="*"
gen AssmtName="Standards of Learning"
gen AssmtType="Regular"
gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested="*"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"


///////

gen SchYear="2002-03"

///////



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

label define LevelIndicator 0 "State" 1 "District" 2 "School"
label values DataLevel LevelIndicator


tostring StateAssignedSchID, replace
replace StateAssignedSchID="" if (DataLevel==0 & StateAssignedSchID==".")
replace StateAssignedSchID="" if (DataLevel==1 & StateAssignedSchID==".")
replace seasch="" if (DataLevel==0 & seasch==".")
replace seasch="" if (DataLevel==1 & seasch==".")
replace StateAssignedSchID="" if (DataLevel==0)
replace StateAssignedSchID="" if (DataLevel==1)
replace seasch="" if (DataLevel==0)
replace seasch="" if (DataLevel==1)

replace StateAssignedSchID="70" if StateAssignedSchID=="910" & SchName=="FRIES MIDDLE"
replace StateAssignedSchID="280" if StateAssignedSchID=="1766" & SchName=="BRIGHTON ELEM."
replace StateAssignedSchID="130" if StateAssignedSchID=="232" & SchName=="POCAHONTAS MIDDLE"
replace StateAssignedSchID="943" if StateAssignedSchID=="945" & SchName=="PENNINGTON SCHOOL"


export delimited using "${output}/VA_AssmtData_2003.csv", replace
