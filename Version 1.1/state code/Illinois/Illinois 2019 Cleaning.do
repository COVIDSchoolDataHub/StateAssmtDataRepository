clear
set more off

global output "/Users/benjaminm/Documents/State_Repository_Research/Illinois/Output"
global NCES "/Users/benjaminm/Documents/State_Repository_Research/Illinois/NCES/Cleaned"

cd "/Users/benjaminm/Documents/State_Repository_Research/Illinois"



**** Sci

*** Sci AvgScaleScore

use "${output}/IL_AssmtData_2019_sci_AvgScaleScore_5.dta", clear
append using "${output}/IL_AssmtData_2019_sci_AvgScaleScore_8.dta"

** Dropping extra variables

drop County City

** Rename existing variables

rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename Grade GradeLevel
rename StateDistrictSchool DataLevel
rename AverageScaleScore AvgScaleScore

** Generating new variables

replace GradeLevel = "G" + GradeLevel

gen StudentSubGroup = "All Students"

tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if AvgScaleScore == " "

save "${output}/IL_AssmtData_2019_sci_AvgScaleScore.dta", replace



*** Sci Participation

use "${output}/IL_AssmtData_2019_sci_Participation_5.dta", clear
append using "${output}/IL_AssmtData_2019_sci_Participation_8.dta"

** Dropping extra variables

drop County City IEP NotIEP
// drop County City Migrant IEP NotIEP

** Rename existing variables

rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename Grade GradeLevel
rename StateDistrictSchool DataLevel
rename All ParticipationRateAll
rename Male ParticipationRateMale
rename Female ParticipationRateFemale
rename White ParticipationRateWhite
rename Black ParticipationRateBlack
rename Hispanic ParticipationRateHisp
rename Asian ParticipationRateAsian
rename HawaiianPacificIslander ParticipationRateHawaii
rename NativeAmerican ParticipationRateNative
rename TwoorMoreRaces ParticipationRateTwo
rename EL ParticipationRateLearner
rename NotEL ParticipationRateProf
rename LowIncome ParticipationRateDis
rename NotLowIncome ParticipationRateNotDis
rename Migrant ProficientOrAbove_percentMigrant

** Reshaping

reshape long ParticipationRate, i(StateAssignedSchID GradeLevel) j(StudentSubGroup) string

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaii"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hisp"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Prof"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NotDis"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"

replace GradeLevel = "G" + GradeLevel

destring ParticipationRate, replace
replace ParticipationRate = ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate = "*" if ParticipationRate == "."

save "${output}/IL_AssmtData_2019_sci_Participation.dta", replace



*** Sci Performance Levels

use "${output}/IL_AssmtData_2019_sci_5.dta", clear
append using "${output}/IL_AssmtData_2019_sci_8.dta"

** Dropping extra variables


drop County City IEP NotIEP
// drop County City Migrant IEP NotIEP

** Rename existing variables

rename RCDTS StateAssignedSchID
drop DIST
rename SchoolorDistrictName SchName
rename Grade GradeLevel
rename StateDistrictSchool DataLevel
rename All ProficientOrAbove_percentAll
rename Male ProficientOrAbove_percentMale
rename Female ProficientOrAbove_percentFemale
rename White ProficientOrAbove_percentWhite
rename Black ProficientOrAbove_percentBlack
rename Hispanic ProficientOrAbove_percentHisp
rename Asian ProficientOrAbove_percentAsian
rename HawaiianPacificIslander ProficientOrAbove_percentHawaii
rename NativeAmerican ProficientOrAbove_percentNative
rename TwoorMoreRaces ProficientOrAbove_percentTwo
rename EL ProficientOrAbove_percentLearner
rename NotEL ProficientOrAbove_percentProf
rename LowIncome ProficientOrAbove_percentDis
rename NotLowIncome ProficientOrAbove_percentNotDis
rename Migrant ProficientOrAbove_percentMigrant

** Dropping entries

drop if StateAssignedSchID == ""

** Generating new variables

gen SchYear = "2018-19"

gen AssmtName = "ISA"
gen AssmtType = "Regular"

gen Lev1_count = "--"
gen Lev2_count = "--"

local level 3 4 5

foreach a of local level {
	gen Lev`a'_count = ""
	gen Lev`a'_percent = ""
}

gen ProficientOrAbove_count = "--"

gen ProficiencyCriteria = "Level 2"

gen Subject = "sci"

** Reshaping

reshape long ProficientOrAbove_percent, i(StateAssignedSchID GradeLevel) j(StudentSubGroup) string

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaii"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hisp"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Learner"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Prof"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "NotDis"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"


gen StudentSubGroup_TotalTested = "--"
gen StudentGroup_TotalTested = "--"

replace GradeLevel = "G" + GradeLevel

destring ProficientOrAbove_percent, replace
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
gen Lev1_percent = 1 - ProficientOrAbove_percent
tostring ProficientOrAbove_percent, replace force
tostring Lev1_percent, replace force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace Lev1_percent = "*" if Lev1_percent == "."

gen Lev2_percent = ProficientOrAbove_percent

merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${output}/IL_AssmtData_2019_sci_AvgScaleScore.dta"
drop _merge


replace AvgScaleScore = "--" if AvgScaleScore == ""

merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${output}/IL_AssmtData_2019_sci_Participation.dta"
drop if _merge == 2
drop _merge

drop if ParticipationRate == "0"

replace DataLevel = "School" if DataLevel == "SCHL"
replace DataLevel = "District" if DataLevel == "DIST"
replace DataLevel = "State" if DataLevel == "STATE"

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Merging with NCES

gen leadingzero = 0
replace leadingzero = 1 if substr(StateAssignedSchID,15,1) == ""
replace StateAssignedSchID = "0" + StateAssignedSchID if leadingzero == 1
drop leadingzero

gen StateAssignedDistID = substr(StateAssignedSchID,1,11)

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES}/NCES_2018_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2018_School.dta"
drop if _merge == 2
drop _merge

save "${output}/IL_AssmtData_2019_sci.dta", replace




**** ELA & Math

use "${output}/IL_AssmtData_2019_all.dta", clear

** Dropping extra variables

drop County City DistrictType DistrictSize SchoolType GradesServed IEP* NonIEP* 

//EG EH EI EJ EQ ER ES ET  GQ GR KO KP KQ KR KS KT KU KV KW KX RW RX RY RZ SA SB SC SD SE SF ZE ZF ZG ZH ZI ZJ ZK ZL ZM ZN AGM AGN AGO AGP AGQ AGR AGS AGT AGU AGV LI LJ LK LL LM LN LO LP LQ LR LS LT LU LV LW LX LY LZ MA MB SQ SR SS ST SU SV SW SX SY SZ TA TB TC TD TE TF TG TH TI TJ ZY ZZ AAA AAB AAC AAD AAE AAF AAG AAH AAI AAJ AAK AAL AAM AAN AAO AAP AAQ AAR AHG AHH AHI AHJ AHK AHL AHM AHN AHO AHP AHQ AHR AHS AHT AHU AHV AHW AHX AHY AHZ AOO AOP AOQ AOR AOS AOT AOU AOV AOW AOX AOY AOZ APA APB APC APD APE APF APG APH  UE UF UG UH UI UJ UK UL UM UN ABM ABN ABO ABP ABQ ABR ABS ABT ABU ABV AIU AIV AIW AIX AIY AIZ AJA AJB AJC AJD NG NH NI NJ NK NL NM NN NO NP UO UP UQ UR US UT UU UV UW UX ABW ABX ABY ABZ ACA ACB ACC ACD ACE ACF AJE AJF AJG AJH AJI AJJ AJK AJL AJM AJN UY UZ VA VB VC VD VE VF VG VH ACG ACH ACI ACJ ACK ACL ACM ACN ACO ACP AJO AJP AJQ AJR AJS AJT AJU AJV AJW AJX //Children* // DH DI DJ DK DL DM DN DO DP ANU ANV ANW ANX ANY ANZ AOA AOB AOC AOD Homeless* Migrant* Military* FP FQ FR FS FU FV FW FX GE GF GG GH GJ GK GL GM GO GP MW MX MY MZ NA NB NC ND NE NF NQ NR NS NT NU NV NW NX NY NZ 

** Rename existing variables

rename RCDTS StateAssignedSchID
rename Type DataLevel
rename SchoolName SchName
rename District DistName

rename AllstudentsIARELALevel1G Lev1_percentela3All
rename AllstudentsIARELALevel2G Lev2_percentela3All
rename AllstudentsIARELALevel3G Lev3_percentela3All
rename AllstudentsIARELALevel4G Lev4_percentela3All
rename AllstudentsIARELALevel5G Lev5_percentela3All
rename AllstudentsIARMathematicsLev Lev1_percentmath3All
rename Q Lev2_percentmath3All
rename R Lev3_percentmath3All
rename S Lev4_percentmath3All
rename T Lev5_percentmath3All

rename MalestudentsIARELALevel1 Lev1_percentela3male
rename MalestudentsIARELALevel2 Lev2_percentela3male
rename MalestudentsIARELALevel3 Lev3_percentela3male
rename MalestudentsIARELALevel4 Lev4_percentela3male
rename MalestudentsIARELALevel5 Lev5_percentela3male
rename MalestudentsIARMathematicsLe Lev1_percentmath3male
rename AA Lev2_percentmath3male
rename AB Lev3_percentmath3male
rename AC Lev4_percentmath3male
rename AD Lev5_percentmath3male

rename FemalestudentsIARELALevel1 Lev1_percentela3female
rename FemalestudentsIARELALevel2 Lev2_percentela3female
rename FemalestudentsIARELALevel3 Lev3_percentela3female
rename FemalestudentsIARELALevel4 Lev4_percentela3female
rename FemalestudentsIARELALevel5 Lev5_percentela3female
rename FemalestudentsIARMathematics Lev1_percentmath3female
rename AK Lev2_percentmath3female
rename AL Lev3_percentmath3female
rename AM Lev4_percentmath3female
rename AN Lev5_percentmath3female

rename WhitestudentsIARELALevel1 Lev1_percentela3white
rename WhitestudentsIARELALevel2 Lev2_percentela3white
rename WhitestudentsIARELALevel3 Lev3_percentela3white
rename WhitestudentsIARELALevel4 Lev4_percentela3white
rename WhitestudentsIARELALevel5 Lev5_percentela3white
rename WhitestudentsIARMathematicsL Lev1_percentmath3white
rename AU Lev2_percentmath3white
rename AV Lev3_percentmath3white
rename AW Lev4_percentmath3white
rename AX Lev5_percentmath3white

rename BlackorAfricanAmericanstuden Lev1_percentela3black
rename AZ Lev2_percentela3black
rename BA Lev3_percentela3black
rename BB Lev4_percentela3black
rename BC Lev5_percentela3black
rename BD Lev1_percentmath3black
rename BE Lev2_percentmath3black
rename BF Lev3_percentmath3black
rename BG Lev4_percentmath3black
rename BH Lev5_percentmath3black

rename HispanicorLatinostudentsIAR Lev1_percentela3hisp
rename BJ Lev2_percentela3hisp
rename BK Lev3_percentela3hisp
rename BL Lev4_percentela3hisp
rename BM Lev5_percentela3hisp
rename BN Lev1_percentmath3hisp
rename BO Lev2_percentmath3hisp
rename BP Lev3_percentmath3hisp
rename BQ Lev4_percentmath3hisp
rename BR Lev5_percentmath3hisp

rename AsianstudentsIARELALevel1 Lev1_percentela3asian
rename AsianstudentsIARELALevel2 Lev2_percentela3asian
rename AsianstudentsIARELALevel3 Lev3_percentela3asian
rename AsianstudentsIARELALevel4 Lev4_percentela3asian
rename AsianstudentsIARELALevel5 Lev5_percentela3asian
rename AsianstudentsIARMathematicsL Lev1_percentmath3asian
rename BY Lev2_percentmath3asian
rename BZ Lev3_percentmath3asian
rename CA Lev4_percentmath3asian
rename CB Lev5_percentmath3asian

rename NativeHawaiianorOtherPacific Lev1_percentela3hawaii
rename CD Lev2_percentela3hawaii
rename CE Lev3_percentela3hawaii
rename CF Lev4_percentela3hawaii
rename CG Lev5_percentela3hawaii
rename CH Lev1_percentmath3hawaii
rename CI Lev2_percentmath3hawaii
rename CJ Lev3_percentmath3hawaii
rename CK Lev4_percentmath3hawaii
rename CL Lev5_percentmath3hawaii

rename AmericanIndianorAlaskaNative Lev1_percentela3native
rename CN Lev2_percentela3native
rename CO Lev3_percentela3native
rename CP Lev4_percentela3native
rename CQ Lev5_percentela3native
rename CR Lev1_percentmath3native
rename CS Lev2_percentmath3native
rename CT Lev3_percentmath3native
rename CU Lev4_percentmath3native
rename CV Lev5_percentmath3native

rename TwoorMoreRacestudentsIAREL Lev1_percentela3two
rename CX Lev2_percentela3two
rename CY Lev3_percentela3two
rename CZ Lev4_percentela3two
rename DA Lev5_percentela3two
rename TwoorMoreRacestudentsIARMa Lev1_percentmath3two
rename DC Lev2_percentmath3two
rename DD Lev3_percentmath3two
rename DE Lev4_percentmath3two
rename DF Lev5_percentmath3two

rename ChildrenwithDisabilitiesstude Lev1_percentela3chi  // NEWNEWNNEW
rename DH Lev2_percentela3chi
rename DI Lev3_percentela3chi
rename DJ Lev4_percentela3chi
rename DK Lev5_percentela3chi
rename DL Lev1_percentmath3chi
rename DM Lev2_percentmath3chi
rename DN Lev3_percentmath3chi
rename DO Lev4_percentmath3chi
rename DP Lev5_percentmath3chi


rename ELstudentsIARELALevel1Gr Lev1_percentela3learner
rename ELstudentsIARELALevel2Gr Lev2_percentela3learner
rename ELstudentsIARELALevel3Gr Lev3_percentela3learner
rename ELstudentsIARELALevel4Gr Lev4_percentela3learner
rename ELstudentsIARELALevel5Gr Lev5_percentela3learner
rename ELstudentsIARMathematicsLeve Lev1_percentmath3learner
rename DW Lev2_percentmath3learner
rename DX Lev3_percentmath3learner
rename DY Lev4_percentmath3learner
rename DZ Lev5_percentmath3learner

rename LowIncomestudentsIARELALe Lev1_percentela3notdis
rename EV Lev2_percentela3notdis
rename EW Lev3_percentela3notdis
rename EX Lev4_percentela3notdis
rename EY Lev5_percentela3notdis
rename LowIncomestudentsIARMathem Lev1_percentmath3notdis
rename FA Lev2_percentmath3notdis
rename FB Lev3_percentmath3notdis
rename FC Lev4_percentmath3notdis
rename FD Lev5_percentmath3notdis

rename NonLowIncomestudentsIARELA Lev1_percentela3dis
rename FF Lev2_percentela3dis
rename FG Lev3_percentela3dis
rename FH Lev4_percentela3dis
rename FI Lev5_percentela3dis
rename NonLowIncomestudentsIARMath Lev1_percentmath3dis
rename FK Lev2_percentmath3dis
rename FL Lev3_percentmath3dis
rename FM Lev4_percentmath3dis
rename FN Lev5_percentmath3dis


rename HomelessstudentsIARELALevel Lev1_percentela3home  // NEWNEWNEW
rename FP Lev2_percentela3home
rename FQ Lev3_percentela3home
rename FR Lev4_percentela3home
rename FS Lev5_percentela3home
rename HomelessstudentsIARMathematic Lev1_percentmath3home
rename FU Lev2_percentmath3home
rename FV Lev3_percentmath3home
rename FW Lev4_percentmath3home
rename FX Lev5_percentmath3home

rename MigrantstudentsIARELALevel1 Lev1_percentela3mig   // NEWNEWNEW
rename MigrantstudentsIARELALevel2 Lev2_percentela3mig
rename MigrantstudentsIARELALevel3 Lev3_percentela3mig
rename MigrantstudentsIARELALevel4 Lev4_percentela3mig
rename MigrantstudentsIARELALevel5 Lev5_percentela3mig
rename MigrantstudentsIARMathematics Lev1_percentmath3mig
rename GE Lev2_percentmath3mig
rename GF Lev3_percentmath3mig
rename GG Lev4_percentmath3mig
rename GH Lev5_percentmath3mig

rename MilitarystudentsIARELALevel Lev1_percentela3mil  // NEWNEWNEW
rename GJ Lev2_percentela3mil
rename GK Lev3_percentela3mil
rename GL Lev4_percentela3mil
rename GM Lev5_percentela3mil
rename MilitarystudentsIARMathematic Lev1_percentmath3mil
rename GO Lev2_percentmath3mil
rename GP Lev3_percentmath3mil
rename GQ Lev4_percentmath3mil
rename GR Lev5_percentmath3mil


rename GS Lev1_percentela4All
rename GT Lev2_percentela4All
rename GU Lev3_percentela4All
rename GV Lev4_percentela4All
rename GW Lev5_percentela4All
rename GX Lev1_percentmath4All
rename GY Lev2_percentmath4All
rename GZ Lev3_percentmath4All
rename HA Lev4_percentmath4All
rename HB Lev5_percentmath4All

rename HC Lev1_percentela4male
rename HD Lev2_percentela4male
rename HE Lev3_percentela4male
rename HF Lev4_percentela4male
rename HG Lev5_percentela4male
rename HH Lev1_percentmath4male
rename HI Lev2_percentmath4male
rename HJ Lev3_percentmath4male
rename HK Lev4_percentmath4male
rename HL Lev5_percentmath4male

rename HM Lev1_percentela4female
rename HN Lev2_percentela4female
rename HO Lev3_percentela4female
rename HP Lev4_percentela4female
rename HQ Lev5_percentela4female
rename HR Lev1_percentmath4female
rename HS Lev2_percentmath4female
rename HT Lev3_percentmath4female
rename HU Lev4_percentmath4female
rename HV Lev5_percentmath4female

rename HW Lev1_percentela4white
rename HX Lev2_percentela4white
rename HY Lev3_percentela4white
rename HZ Lev4_percentela4white
rename IA Lev5_percentela4white
rename IB Lev1_percentmath4white
rename IC Lev2_percentmath4white
rename ID Lev3_percentmath4white
rename IE Lev4_percentmath4white
rename IF Lev5_percentmath4white

rename IG Lev1_percentela4black
rename IH Lev2_percentela4black
rename II Lev3_percentela4black
rename IJ Lev4_percentela4black
rename IK Lev5_percentela4black
rename IL Lev1_percentmath4black
rename IM Lev2_percentmath4black
rename IN Lev3_percentmath4black
rename IO Lev4_percentmath4black
rename IP Lev5_percentmath4black

rename IQ Lev1_percentela4hisp
rename IR Lev2_percentela4hisp
rename IS Lev3_percentela4hisp
rename IT Lev4_percentela4hisp
rename IU Lev5_percentela4hisp
rename IV Lev1_percentmath4hisp
rename IW Lev2_percentmath4hisp
rename IX Lev3_percentmath4hisp
rename IY Lev4_percentmath4hisp
rename IZ Lev5_percentmath4hisp

rename JA Lev1_percentela4asian
rename JB Lev2_percentela4asian
rename JC Lev3_percentela4asian
rename JD Lev4_percentela4asian
rename JE Lev5_percentela4asian
rename JF Lev1_percentmath4asian
rename JG Lev2_percentmath4asian
rename JH Lev3_percentmath4asian
rename JI Lev4_percentmath4asian
rename JJ Lev5_percentmath4asian

rename JK Lev1_percentela4hawaii
rename JL Lev2_percentela4hawaii
rename JM Lev3_percentela4hawaii
rename JN Lev4_percentela4hawaii
rename JO Lev5_percentela4hawaii
rename JP Lev1_percentmath4hawaii
rename JQ Lev2_percentmath4hawaii
rename JR Lev3_percentmath4hawaii
rename JS Lev4_percentmath4hawaii
rename JT Lev5_percentmath4hawaii

rename JU Lev1_percentela4native
rename JV Lev2_percentela4native
rename JW Lev3_percentela4native
rename JX Lev4_percentela4native
rename JY Lev5_percentela4native
rename JZ Lev1_percentmath4native
rename KA Lev2_percentmath4native
rename KB Lev3_percentmath4native
rename KC Lev4_percentmath4native
rename KD Lev5_percentmath4native

rename KE Lev1_percentela4two
rename KF Lev2_percentela4two
rename KG Lev3_percentela4two
rename KH Lev4_percentela4two
rename KI Lev5_percentela4two
rename KJ Lev1_percentmath4two
rename KK Lev2_percentmath4two
rename KL Lev3_percentmath4two
rename KM Lev4_percentmath4two
rename KN Lev5_percentmath4two

// 
rename KO Lev1_percentela4chi // NEWNEWNNEW
rename KP Lev2_percentela4chi
rename KQ Lev3_percentela4chi
rename KR Lev4_percentela4chi
rename KS Lev5_percentela4chi
rename KT Lev1_percentmath4chi
rename KU Lev2_percentmath4chi
rename KV Lev3_percentmath4chi
rename KW Lev4_percentmath4chi
rename KX Lev5_percentmath4chi

rename KY Lev1_percentela4learner
rename KZ Lev2_percentela4learner
rename LA Lev3_percentela4learner
rename LB Lev4_percentela4learner
rename LC Lev5_percentela4learner
rename LD Lev1_percentmath4learner
rename LE Lev2_percentmath4learner
rename LF Lev3_percentmath4learner
rename LG Lev4_percentmath4learner
rename LH Lev5_percentmath4learner

rename MC Lev1_percentela4dis
rename MD Lev2_percentela4dis
rename ME Lev3_percentela4dis
rename MF Lev4_percentela4dis
rename MG Lev5_percentela4dis
rename MH Lev1_percentmath4dis
rename MI Lev2_percentmath4dis
rename MJ Lev3_percentmath4dis
rename MK Lev4_percentmath4dis
rename ML Lev5_percentmath4dis

rename MM Lev1_percentela4notdis
rename MN Lev2_percentela4notdis
rename MO Lev3_percentela4notdis
rename MP Lev4_percentela4notdis
rename MQ Lev5_percentela4notdis
rename MR Lev1_percentmath4notdis
rename MS Lev2_percentmath4notdis
rename MT Lev3_percentmath4notdis
rename MU Lev4_percentmath4notdis
rename MV Lev5_percentmath4notdis

rename MW Lev1_percentela4home // NEWNEWNEW
rename MX Lev2_percentela4home
rename MY Lev3_percentela4home
rename MZ Lev4_percentela4home
rename NA Lev5_percentela4home
rename NB Lev1_percentmath4home
rename NC Lev2_percentmath4home
rename ND Lev3_percentmath4home
rename NE Lev4_percentmath4home
rename NF Lev5_percentmath4home

rename NG Lev1_percentela4mig // NEWNEWNEW
rename NH Lev2_percentela4mig
rename NI Lev3_percentela4mig
rename NJ Lev4_percentela4mig
rename NK Lev5_percentela4mig
rename NL Lev1_percentmath4mig
rename NM Lev2_percentmath4mig
rename NN Lev3_percentmath4mig
rename NO Lev4_percentmath4mig
rename NP Lev5_percentmath4mig

rename NQ Lev1_percentela4mil // NEWNEWNEW
rename NR Lev2_percentela4mil
rename NS Lev3_percentela4mil
rename NT Lev4_percentela4mil
rename NU Lev5_percentela4mil
rename NV Lev1_percentmath4mil
rename NW Lev2_percentmath4mil
rename NX Lev3_percentmath4mil
rename NY Lev4_percentmath4mil
rename NZ Lev5_percentmath4mil


rename OA Lev1_percentela5All
rename OB Lev2_percentela5All
rename OC Lev3_percentela5All
rename OD Lev4_percentela5All
rename OE Lev5_percentela5All
rename OF Lev1_percentmath5All
rename OG Lev2_percentmath5All
rename OH Lev3_percentmath5All
rename OI Lev4_percentmath5All
rename OJ Lev5_percentmath5All

rename OK Lev1_percentela5male
rename OL Lev2_percentela5male
rename OM Lev3_percentela5male
rename ON Lev4_percentela5male
rename OO Lev5_percentela5male
rename OP Lev1_percentmath5male
rename OQ Lev2_percentmath5male
rename OR Lev3_percentmath5male
rename OS Lev4_percentmath5male
rename OT Lev5_percentmath5male

rename OU Lev1_percentela5female
rename OV Lev2_percentela5female
rename OW Lev3_percentela5female
rename OX Lev4_percentela5female
rename OY Lev5_percentela5female
rename OZ Lev1_percentmath5female
rename PA Lev2_percentmath5female
rename PB Lev3_percentmath5female
rename PC Lev4_percentmath5female
rename PD Lev5_percentmath5female

rename PE Lev1_percentela5white
rename PF Lev2_percentela5white
rename PG Lev3_percentela5white
rename PH Lev4_percentela5white
rename PI Lev5_percentela5white
rename PJ Lev1_percentmath5white
rename PK Lev2_percentmath5white
rename PL Lev3_percentmath5white
rename PM Lev4_percentmath5white
rename PN Lev5_percentmath5white

rename PO Lev1_percentela5black
rename PP Lev2_percentela5black
rename PQ Lev3_percentela5black
rename PR Lev4_percentela5black
rename PS Lev5_percentela5black
rename PT Lev1_percentmath5black
rename PU Lev2_percentmath5black
rename PV Lev3_percentmath5black
rename PW Lev4_percentmath5black
rename PX Lev5_percentmath5black

rename PY Lev1_percentela5hisp
rename PZ Lev2_percentela5hisp
rename QA Lev3_percentela5hisp
rename QB Lev4_percentela5hisp
rename QC Lev5_percentela5hisp
rename QD Lev1_percentmath5hisp
rename QE Lev2_percentmath5hisp
rename QF Lev3_percentmath5hisp
rename QG Lev4_percentmath5hisp
rename QH Lev5_percentmath5hisp

rename QI Lev1_percentela5asian
rename QJ Lev2_percentela5asian
rename QK Lev3_percentela5asian
rename QL Lev4_percentela5asian
rename QM Lev5_percentela5asian
rename QN Lev1_percentmath5asian
rename QO Lev2_percentmath5asian
rename QP Lev3_percentmath5asian
rename QQ Lev4_percentmath5asian
rename QR Lev5_percentmath5asian

rename QS Lev1_percentela5hawaii
rename QT Lev2_percentela5hawaii
rename QU Lev3_percentela5hawaii
rename QV Lev4_percentela5hawaii
rename QW Lev5_percentela5hawaii
rename QX Lev1_percentmath5hawaii
rename QY Lev2_percentmath5hawaii
rename QZ Lev3_percentmath5hawaii
rename RA Lev4_percentmath5hawaii
rename RB Lev5_percentmath5hawaii

rename RC Lev1_percentela5native
rename RD Lev2_percentela5native
rename RE Lev3_percentela5native
rename RF Lev4_percentela5native
rename RG Lev5_percentela5native
rename RH Lev1_percentmath5native
rename RI Lev2_percentmath5native
rename RJ Lev3_percentmath5native
rename RK Lev4_percentmath5native
rename RL Lev5_percentmath5native

rename RM Lev1_percentela5two
rename RN Lev2_percentela5two
rename RO Lev3_percentela5two
rename RP Lev4_percentela5two
rename RQ Lev5_percentela5two
rename RR Lev1_percentmath5two
rename RS Lev2_percentmath5two
rename RT Lev3_percentmath5two
rename RU Lev4_percentmath5two
rename RV Lev5_percentmath5two

rename RW Lev1_percentela5chi // NEWNEWNNEW
rename RX Lev2_percentela5chi
rename RY Lev3_percentela5chi
rename RZ Lev4_percentela5chi
rename SA Lev5_percentela5chi
rename SB Lev1_percentmath5chi
rename SC Lev2_percentmath5chi
rename SD Lev3_percentmath5chi
rename SE Lev4_percentmath5chi
rename SF Lev5_percentmath5chi

rename SG Lev1_percentela5learner
rename SH Lev2_percentela5learner
rename SI Lev3_percentela5learner
rename SJ Lev4_percentela5learner
rename SK Lev5_percentela5learner
rename SL Lev1_percentmath5learner
rename SM Lev2_percentmath5learner
rename SN Lev3_percentmath5learner
rename SO Lev4_percentmath5learner
rename SP Lev5_percentmath5learner

rename TK Lev1_percentela5dis
rename TL Lev2_percentela5dis
rename TM Lev3_percentela5dis
rename TN Lev4_percentela5dis
rename TO Lev5_percentela5dis
rename TP Lev1_percentmath5dis
rename TQ Lev2_percentmath5dis
rename TR Lev3_percentmath5dis
rename TS Lev4_percentmath5dis
rename TT Lev5_percentmath5dis

rename TU Lev1_percentela5notdis
rename TV Lev2_percentela5notdis
rename TW Lev3_percentela5notdis
rename TX Lev4_percentela5notdis
rename TY Lev5_percentela5notdis
rename TZ Lev1_percentmath5notdis
rename UA Lev2_percentmath5notdis
rename UB Lev3_percentmath5notdis
rename UC Lev4_percentmath5notdis
rename UD Lev5_percentmath5notdis


rename UE Lev1_percentela5home // NEWNEWNEW
rename UF Lev2_percentela5home
rename UG Lev3_percentela5home
rename UH Lev4_percentela5home
rename UI Lev5_percentela5home
rename UJ Lev1_percentmath5home
rename UK Lev2_percentmath5home
rename UL Lev3_percentmath5home
rename UM Lev4_percentmath5home
rename UN Lev5_percentmath5home

rename UO Lev1_percentela5mig // NEWNEWNEW
rename UP Lev2_percentela5mig
rename UQ Lev3_percentela5mig
rename UR Lev4_percentela5mig
rename US Lev5_percentela5mig
rename UT Lev1_percentmath5mig
rename UU Lev2_percentmath5mig
rename UV Lev3_percentmath5mig
rename UW Lev4_percentmath5mig
rename UX Lev5_percentmath5mig

rename UY Lev1_percentela5mil // NEWNEWNEW
rename UZ Lev2_percentela5mil
rename VA Lev3_percentela5mil
rename VB Lev4_percentela5mil
rename VC Lev5_percentela5mil
rename VD Lev1_percentmath5mil
rename VE Lev2_percentmath5mil
rename VF Lev3_percentmath5mil
rename VG Lev4_percentmath5mil
rename VH Lev5_percentmath5mil

rename VI Lev1_percentela6All
rename VJ Lev2_percentela6All
rename VK Lev3_percentela6All
rename VL Lev4_percentela6All
rename VM Lev5_percentela6All
rename VN Lev1_percentmath6All
rename VO Lev2_percentmath6All
rename VP Lev3_percentmath6All
rename VQ Lev4_percentmath6All
rename VR Lev5_percentmath6All

rename VS Lev1_percentela6male
rename VT Lev2_percentela6male
rename VU Lev3_percentela6male
rename VV Lev4_percentela6male
rename VW Lev5_percentela6male
rename VX Lev1_percentmath6male
rename VY Lev2_percentmath6male
rename VZ Lev3_percentmath6male
rename WA Lev4_percentmath6male
rename WB Lev5_percentmath6male

rename WC Lev1_percentela6female
rename WD Lev2_percentela6female
rename WE Lev3_percentela6female
rename WF Lev4_percentela6female
rename WG Lev5_percentela6female
rename WH Lev1_percentmath6female
rename WI Lev2_percentmath6female
rename WJ Lev3_percentmath6female
rename WK Lev4_percentmath6female
rename WL Lev5_percentmath6female

rename WM Lev1_percentela6white
rename WN Lev2_percentela6white
rename WO Lev3_percentela6white
rename WP Lev4_percentela6white
rename WQ Lev5_percentela6white
rename WR Lev1_percentmath6white
rename WS Lev2_percentmath6white
rename WT Lev3_percentmath6white
rename WU Lev4_percentmath6white
rename WV Lev5_percentmath6white

rename WW Lev1_percentela6black
rename WX Lev2_percentela6black
rename WY Lev3_percentela6black
rename WZ Lev4_percentela6black
rename XA Lev5_percentela6black
rename XB Lev1_percentmath6black
rename XC Lev2_percentmath6black
rename XD Lev3_percentmath6black
rename XE Lev4_percentmath6black
rename XF Lev5_percentmath6black

rename XG Lev1_percentela6hisp
rename XH Lev2_percentela6hisp
rename XI Lev3_percentela6hisp
rename XJ Lev4_percentela6hisp
rename XK Lev5_percentela6hisp
rename XL Lev1_percentmath6hisp
rename XM Lev2_percentmath6hisp
rename XN Lev3_percentmath6hisp
rename XO Lev4_percentmath6hisp
rename XP Lev5_percentmath6hisp

rename XQ Lev1_percentela6asian
rename XR Lev2_percentela6asian
rename XS Lev3_percentela6asian
rename XT Lev4_percentela6asian
rename XU Lev5_percentela6asian
rename XV Lev1_percentmath6asian
rename XW Lev2_percentmath6asian
rename XX Lev3_percentmath6asian
rename XY Lev4_percentmath6asian
rename XZ Lev5_percentmath6asian

rename YA Lev1_percentela6hawaii
rename YB Lev2_percentela6hawaii
rename YC Lev3_percentela6hawaii
rename YD Lev4_percentela6hawaii
rename YE Lev5_percentela6hawaii
rename YF Lev1_percentmath6hawaii
rename YG Lev2_percentmath6hawaii
rename YH Lev3_percentmath6hawaii
rename YI Lev4_percentmath6hawaii
rename YJ Lev5_percentmath6hawaii

rename YK Lev1_percentela6native
rename YL Lev2_percentela6native
rename YM Lev3_percentela6native
rename YN Lev4_percentela6native
rename YO Lev5_percentela6native
rename YP Lev1_percentmath6native
rename YQ Lev2_percentmath6native
rename YR Lev3_percentmath6native
rename YS Lev4_percentmath6native
rename YT Lev5_percentmath6native

rename YU Lev1_percentela6two
rename YV Lev2_percentela6two
rename YW Lev3_percentela6two
rename YX Lev4_percentela6two
rename YY Lev5_percentela6two
rename YZ Lev1_percentmath6two
rename ZA Lev2_percentmath6two
rename ZB Lev3_percentmath6two
rename ZC Lev4_percentmath6two
rename ZD Lev5_percentmath6two

rename ZE Lev1_percentela6chi // NEWNEWNNEW
rename ZF Lev2_percentela6chi
rename ZG Lev3_percentela6chi
rename ZH Lev4_percentela6chi
rename ZI Lev5_percentela6chi
rename ZJ Lev1_percentmath6chi
rename ZK Lev2_percentmath6chi
rename ZL Lev3_percentmath6chi
rename ZM Lev4_percentmath6chi
rename ZN Lev5_percentmath6chi



rename ZO Lev1_percentela6learner
rename ZP Lev2_percentela6learner
rename ZQ Lev3_percentela6learner
rename ZR Lev4_percentela6learner
rename ZS Lev5_percentela6learner
rename ZT Lev1_percentmath6learner
rename ZU Lev2_percentmath6learner
rename ZV Lev3_percentmath6learner
rename ZW Lev4_percentmath6learner
rename ZX Lev5_percentmath6learner

rename AAS Lev1_percentela6dis
rename AAT Lev2_percentela6dis
rename AAU Lev3_percentela6dis
rename AAV Lev4_percentela6dis
rename AAW Lev5_percentela6dis
rename AAX Lev1_percentmath6dis
rename AAY Lev2_percentmath6dis
rename AAZ Lev3_percentmath6dis
rename ABA Lev4_percentmath6dis
rename ABB Lev5_percentmath6dis

rename ABC Lev1_percentela6notdis
rename ABD Lev2_percentela6notdis
rename ABE Lev3_percentela6notdis
rename ABF Lev4_percentela6notdis
rename ABG Lev5_percentela6notdis
rename ABH Lev1_percentmath6notdis
rename ABI Lev2_percentmath6notdis
rename ABJ Lev3_percentmath6notdis
rename ABK Lev4_percentmath6notdis
rename ABL Lev5_percentmath6notdis


rename ABM Lev1_percentela6home // NEWNEWNEW
rename ABN Lev2_percentela6home
rename ABO Lev3_percentela6home
rename ABP Lev4_percentela6home
rename ABQ Lev5_percentela6home
rename ABR Lev1_percentmath6home
rename ABS Lev2_percentmath6home
rename ABT Lev3_percentmath6home
rename ABU Lev4_percentmath6home
rename ABV Lev5_percentmath6home

rename ABW Lev1_percentela6mig // NEWNEWNEW
rename ABX Lev2_percentela6mig
rename ABY Lev3_percentela6mig
rename ABZ Lev4_percentela6mig
rename ACA Lev5_percentela6mig
rename ACB Lev1_percentmath6mig
rename ACC Lev2_percentmath6mig
rename ACD Lev3_percentmath6mig
rename ACE Lev4_percentmath6mig
rename ACF Lev5_percentmath6mig

rename ACG Lev1_percentela6mil // NEWNEWNEW
rename ACH Lev2_percentela6mil
rename ACI Lev3_percentela6mil
rename ACJ Lev4_percentela6mil
rename ACK Lev5_percentela6mil
rename ACL Lev1_percentmath6mil
rename ACM Lev2_percentmath6mil
rename ACN Lev3_percentmath6mil
rename ACO Lev4_percentmath6mil
rename ACP Lev5_percentmath6mil


rename ACQ Lev1_percentela7All
rename ACR Lev2_percentela7All
rename ACS Lev3_percentela7All
rename ACT Lev4_percentela7All
rename ACU Lev5_percentela7All
rename ACV Lev1_percentmath7All
rename ACW Lev2_percentmath7All
rename ACX Lev3_percentmath7All
rename ACY Lev4_percentmath7All
rename ACZ Lev5_percentmath7All

rename ADA Lev1_percentela7male
rename ADB Lev2_percentela7male
rename ADC Lev3_percentela7male
rename ADD Lev4_percentela7male
rename ADE Lev5_percentela7male
rename ADF Lev1_percentmath7male
rename ADG Lev2_percentmath7male
rename ADH Lev3_percentmath7male
rename ADI Lev4_percentmath7male
rename ADJ Lev5_percentmath7male

rename ADK Lev1_percentela7female
rename ADL Lev2_percentela7female
rename ADM Lev3_percentela7female
rename ADN Lev4_percentela7female
rename ADO Lev5_percentela7female
rename ADP Lev1_percentmath7female
rename ADQ Lev2_percentmath7female
rename ADR Lev3_percentmath7female
rename ADS Lev4_percentmath7female
rename ADT Lev5_percentmath7female

rename ADU Lev1_percentela7white
rename ADV Lev2_percentela7white
rename ADW Lev3_percentela7white
rename ADX Lev4_percentela7white
rename ADY Lev5_percentela7white
rename ADZ Lev1_percentmath7white
rename AEA Lev2_percentmath7white
rename AEB Lev3_percentmath7white
rename AEC Lev4_percentmath7white
rename AED Lev5_percentmath7white

rename AEE Lev1_percentela7black
rename AEF Lev2_percentela7black
rename AEG Lev3_percentela7black
rename AEH Lev4_percentela7black
rename AEI Lev5_percentela7black
rename AEJ Lev1_percentmath7black
rename AEK Lev2_percentmath7black
rename AEL Lev3_percentmath7black
rename AEM Lev4_percentmath7black
rename AEN Lev5_percentmath7black

rename AEO Lev1_percentela7hisp
rename AEP Lev2_percentela7hisp
rename AEQ Lev3_percentela7hisp
rename AER Lev4_percentela7hisp
rename AES Lev5_percentela7hisp
rename AET Lev1_percentmath7hisp
rename AEU Lev2_percentmath7hisp
rename AEV Lev3_percentmath7hisp
rename AEW Lev4_percentmath7hisp
rename AEX Lev5_percentmath7hisp

rename AEY Lev1_percentela7asian
rename AEZ Lev2_percentela7asian
rename AFA Lev3_percentela7asian
rename AFB Lev4_percentela7asian
rename AFC Lev5_percentela7asian
rename AFD Lev1_percentmath7asian
rename AFE Lev2_percentmath7asian
rename AFF Lev3_percentmath7asian
rename AFG Lev4_percentmath7asian
rename AFH Lev5_percentmath7asian

rename AFI Lev1_percentela7hawaii
rename AFJ Lev2_percentela7hawaii
rename AFK Lev3_percentela7hawaii
rename AFL Lev4_percentela7hawaii
rename AFM Lev5_percentela7hawaii
rename AFN Lev1_percentmath7hawaii
rename AFO Lev2_percentmath7hawaii
rename AFP Lev3_percentmath7hawaii
rename AFQ Lev4_percentmath7hawaii
rename AFR Lev5_percentmath7hawaii

rename AFS Lev1_percentela7native
rename AFT Lev2_percentela7native
rename AFU Lev3_percentela7native
rename AFV Lev4_percentela7native
rename AFW Lev5_percentela7native
rename AFX Lev1_percentmath7native
rename AFY Lev2_percentmath7native
rename AFZ Lev3_percentmath7native
rename AGA Lev4_percentmath7native
rename AGB Lev5_percentmath7native

rename AGC Lev1_percentela7two
rename AGD Lev2_percentela7two
rename AGE Lev3_percentela7two
rename AGF Lev4_percentela7two
rename AGG Lev5_percentela7two
rename AGH Lev1_percentmath7two
rename AGI Lev2_percentmath7two
rename AGJ Lev3_percentmath7two
rename AGK Lev4_percentmath7two
rename AGL Lev5_percentmath7two

rename AGM Lev1_percentela7chi // NEWNEWNNEW
rename AGN Lev2_percentela7chi
rename AGO Lev3_percentela7chi
rename AGP Lev4_percentela7chi
rename AGQ Lev5_percentela7chi
rename AGR Lev1_percentmath7chi
rename AGS Lev2_percentmath7chi
rename AGT Lev3_percentmath7chi
rename AGU Lev4_percentmath7chi
rename AGV Lev5_percentmath7chi

rename AGW Lev1_percentela7learner
rename AGX Lev2_percentela7learner
rename AGY Lev3_percentela7learner
rename AGZ Lev4_percentela7learner
rename AHA Lev5_percentela7learner
rename AHB Lev1_percentmath7learner
rename AHC Lev2_percentmath7learner
rename AHD Lev3_percentmath7learner
rename AHE Lev4_percentmath7learner
rename AHF Lev5_percentmath7learner

rename AIA Lev1_percentela7dis
rename AIB Lev2_percentela7dis
rename AIC Lev3_percentela7dis
rename AID Lev4_percentela7dis
rename AIE Lev5_percentela7dis
rename AIF Lev1_percentmath7dis
rename AIG Lev2_percentmath7dis
rename AIH Lev3_percentmath7dis
rename AII Lev4_percentmath7dis
rename AIJ Lev5_percentmath7dis

rename AIK Lev1_percentela7notdis
rename AIL Lev2_percentela7notdis
rename AIM Lev3_percentela7notdis
rename AIN Lev4_percentela7notdis
rename AIO Lev5_percentela7notdis
rename AIP Lev1_percentmath7notdis
rename AIQ Lev2_percentmath7notdis
rename AIR Lev3_percentmath7notdis
rename AIS Lev4_percentmath7notdis
rename AIT Lev5_percentmath7notdis


rename AIU Lev1_percentela7home // NEWNEWNEW
rename AIV Lev2_percentela7home
rename AIW Lev3_percentela7home
rename AIX Lev4_percentela7home
rename AIY Lev5_percentela7home
rename AIZ Lev1_percentmath7home
rename AJA Lev2_percentmath7home
rename AJB Lev3_percentmath7home
rename AJC Lev4_percentmath7home
rename AJD Lev5_percentmath7home

rename AJE Lev1_percentela7mig // NEWNEWNEW
rename AJF Lev2_percentela7mig
rename AJG Lev3_percentela7mig
rename AJH Lev4_percentela7mig
rename AJI Lev5_percentela7mig
rename AJJ Lev1_percentmath7mig
rename AJK Lev2_percentmath7mig
rename AJL Lev3_percentmath7mig
rename AJM Lev4_percentmath7mig
rename AJN Lev5_percentmath7mig

rename AJO Lev1_percentela7mil // NEWNEWNEW
rename AJP Lev2_percentela7mil
rename AJQ Lev3_percentela7mil
rename AJR Lev4_percentela7mil
rename AJS Lev5_percentela7mil
rename AJT Lev1_percentmath7mil
rename AJU Lev2_percentmath7mil
rename AJV Lev3_percentmath7mil
rename AJW Lev4_percentmath7mil
rename AJX Lev5_percentmath7mil

rename AJY Lev1_percentela8All
rename AJZ Lev2_percentela8All
rename AKA Lev3_percentela8All
rename AKB Lev4_percentela8All
rename AKC Lev5_percentela8All
rename AKD Lev1_percentmath8All
rename AKE Lev2_percentmath8All
rename AKF Lev3_percentmath8All
rename AKG Lev4_percentmath8All
rename AKH Lev5_percentmath8All

rename AKI Lev1_percentela8male
rename AKJ Lev2_percentela8male
rename AKK Lev3_percentela8male
rename AKL Lev4_percentela8male
rename AKM Lev5_percentela8male
rename AKN Lev1_percentmath8male
rename AKO Lev2_percentmath8male
rename AKP Lev3_percentmath8male
rename AKQ Lev4_percentmath8male
rename AKR Lev5_percentmath8male

rename AKS Lev1_percentela8female
rename AKT Lev2_percentela8female
rename AKU Lev3_percentela8female
rename AKV Lev4_percentela8female
rename AKW Lev5_percentela8female
rename AKX Lev1_percentmath8female
rename AKY Lev2_percentmath8female
rename AKZ Lev3_percentmath8female
rename ALA Lev4_percentmath8female
rename ALB Lev5_percentmath8female

rename ALC Lev1_percentela8white
rename ALD Lev2_percentela8white
rename ALE Lev3_percentela8white
rename ALF Lev4_percentela8white
rename ALG Lev5_percentela8white
rename ALH Lev1_percentmath8white
rename ALI Lev2_percentmath8white
rename ALJ Lev3_percentmath8white
rename ALK Lev4_percentmath8white
rename ALL Lev5_percentmath8white

rename ALM Lev1_percentela8black
rename ALN Lev2_percentela8black
rename ALO Lev3_percentela8black
rename ALP Lev4_percentela8black
rename ALQ Lev5_percentela8black
rename ALR Lev1_percentmath8black
rename ALS Lev2_percentmath8black
rename ALT Lev3_percentmath8black
rename ALU Lev4_percentmath8black
rename ALV Lev5_percentmath8black

rename ALW Lev1_percentela8hisp
rename ALX Lev2_percentela8hisp
rename ALY Lev3_percentela8hisp
rename ALZ Lev4_percentela8hisp
rename AMA Lev5_percentela8hisp
rename AMB Lev1_percentmath8hisp
rename AMC Lev2_percentmath8hisp
rename AMD Lev3_percentmath8hisp
rename AME Lev4_percentmath8hisp
rename AMF Lev5_percentmath8hisp

rename AMG Lev1_percentela8asian
rename AMH Lev2_percentela8asian
rename AMI Lev3_percentela8asian
rename AMJ Lev4_percentela8asian
rename AMK Lev5_percentela8asian
rename AML Lev1_percentmath8asian
rename AMM Lev2_percentmath8asian
rename AMN Lev3_percentmath8asian
rename AMO Lev4_percentmath8asian
rename AMP Lev5_percentmath8asian

rename AMQ Lev1_percentela8hawaii
rename AMR Lev2_percentela8hawaii
rename AMS Lev3_percentela8hawaii
rename AMT Lev4_percentela8hawaii
rename AMU Lev5_percentela8hawaii
rename AMV Lev1_percentmath8hawaii
rename AMW Lev2_percentmath8hawaii
rename AMX Lev3_percentmath8hawaii
rename AMY Lev4_percentmath8hawaii
rename AMZ Lev5_percentmath8hawaii

rename ANA Lev1_percentela8native
rename ANB Lev2_percentela8native
rename ANC Lev3_percentela8native
rename AND Lev4_percentela8native
rename ANE Lev5_percentela8native
rename ANF Lev1_percentmath8native
rename ANG Lev2_percentmath8native
rename ANH Lev3_percentmath8native
rename ANI Lev4_percentmath8native
rename ANJ Lev5_percentmath8native

rename ANK Lev1_percentela8two
rename ANL Lev2_percentela8two
rename ANM Lev3_percentela8two
rename ANN Lev4_percentela8two
rename ANO Lev5_percentela8two
rename ANP Lev1_percentmath8two
rename ANQ Lev2_percentmath8two
rename ANR Lev3_percentmath8two
rename ANS Lev4_percentmath8two
rename ANT Lev5_percentmath8two

rename ANU Lev1_percentela8chi // NEWNEWNNEW
rename ANV Lev2_percentela8chi
rename ANW Lev3_percentela8chi
rename ANX Lev4_percentela8chi
rename ANY Lev5_percentela8chi
rename ANZ Lev1_percentmath8chi
rename AOA Lev2_percentmath8chi
rename AOB Lev3_percentmath8chi
rename AOC Lev4_percentmath8chi
rename AOD Lev5_percentmath8chi

rename AOE Lev1_percentela8learner
rename AOF Lev2_percentela8learner
rename AOG Lev3_percentela8learner
rename AOH Lev4_percentela8learner
rename AOI Lev5_percentela8learner
rename AOJ Lev1_percentmath8learner
rename AOK Lev2_percentmath8learner
rename AOL Lev3_percentmath8learner
rename AOM Lev4_percentmath8learner
rename AON Lev5_percentmath8learner

rename API Lev1_percentela8dis
rename APJ Lev2_percentela8dis
rename APK Lev3_percentela8dis
rename APL Lev4_percentela8dis
rename APM Lev5_percentela8dis
rename APN Lev1_percentmath8dis
rename APO Lev2_percentmath8dis
rename APP Lev3_percentmath8dis
rename APQ Lev4_percentmath8dis
rename APR Lev5_percentmath8dis

rename APS Lev1_percentela8notdis
rename APT Lev2_percentela8notdis
rename APU Lev3_percentela8notdis
rename APV Lev4_percentela8notdis
rename APW Lev5_percentela8notdis
rename APX Lev1_percentmath8notdis
rename APY Lev2_percentmath8notdis
rename APZ Lev3_percentmath8notdis
rename AQA Lev4_percentmath8notdis
rename AQB Lev5_percentmath8notdis

rename AQC Lev1_percentela8home // NEWNEWNEW
rename AQD Lev2_percentela8home
rename AQE Lev3_percentela8home
rename AQF Lev4_percentela8home
rename AQG Lev5_percentela8home
rename AQH Lev1_percentmath8home
rename AQI Lev2_percentmath8home
rename AQJ Lev3_percentmath8home
rename AQK Lev4_percentmath8home
rename AQL Lev5_percentmath8home

rename AQM Lev1_percentela8mig // NEWNEWNEW
rename AQN Lev2_percentela8mig
rename AQO Lev3_percentela8mig
rename AQP Lev4_percentela8mig
rename AQQ Lev5_percentela8mig
rename AQR Lev1_percentmath8mig
rename AQS Lev2_percentmath8mig
rename AQT Lev3_percentmath8mig
rename AQU Lev4_percentmath8mig
rename AQV Lev5_percentmath8mig

rename AQW Lev1_percentela8mil // NEWNEWNEW
rename AQX Lev2_percentela8mil
rename AQY Lev3_percentela8mil
rename AQZ Lev4_percentela8mil
rename ARA Lev5_percentela8mil
rename ARB Lev1_percentmath8mil
rename ARC Lev2_percentmath8mil
rename ARD Lev3_percentmath8mil
rename ARE Lev4_percentmath8mil
rename ARF Lev5_percentmath8mil

** Changing DataLevel

replace DataLevel = "State" if DataLevel == "Statewide"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Reshaping

reshape long Lev1_percentela3 Lev2_percentela3 Lev3_percentela3 Lev4_percentela3 Lev5_percentela3 Lev1_percentmath3 Lev2_percentmath3 Lev3_percentmath3 Lev4_percentmath3 Lev5_percentmath3 Lev1_percentela4 Lev2_percentela4 Lev3_percentela4 Lev4_percentela4 Lev5_percentela4 Lev1_percentmath4 Lev2_percentmath4 Lev3_percentmath4 Lev4_percentmath4 Lev5_percentmath4 Lev1_percentela5 Lev2_percentela5 Lev3_percentela5 Lev4_percentela5 Lev5_percentela5 Lev1_percentmath5 Lev2_percentmath5 Lev3_percentmath5 Lev4_percentmath5 Lev5_percentmath5 Lev1_percentela6 Lev2_percentela6 Lev3_percentela6 Lev4_percentela6 Lev5_percentela6 Lev1_percentmath6 Lev2_percentmath6 Lev3_percentmath6 Lev4_percentmath6 Lev5_percentmath6 Lev1_percentela7 Lev2_percentela7 Lev3_percentela7 Lev4_percentela7 Lev5_percentela7 Lev1_percentmath7 Lev2_percentmath7 Lev3_percentmath7 Lev4_percentmath7 Lev5_percentmath7 Lev1_percentela8 Lev2_percentela8 Lev3_percentela8 Lev4_percentela8 Lev5_percentela8 Lev1_percentmath8 Lev2_percentmath8 Lev3_percentmath8 Lev4_percentmath8 Lev5_percentmath8, i(StateAssignedSchID) j(StudentSubGroup) string

reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent, i(StateAssignedSchID StudentSubGroup) j(Subject) string

drop if Lev1_percent == .

gen GradeLevel = Subject
replace GradeLevel = subinstr(GradeLevel,"ela","",.)
replace GradeLevel = subinstr(GradeLevel,"math","",.)
replace GradeLevel = "G0" + GradeLevel

replace Subject = "ela" if strpos(Subject,"ela") > 0
replace Subject = "math" if strpos(Subject,"math") > 0

** Replacing variables

replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "black"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "hawaii"
replace StudentSubGroup = "White" if StudentSubGroup == "white"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "hisp"
replace StudentSubGroup = "Female" if StudentSubGroup == "female"
replace StudentSubGroup = "Male" if StudentSubGroup == "male"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "notdis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "notdis"
replace StudentSubGroup = "SWD" if StudentSubGroup == "chi"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "mig"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "home"
replace StudentSubGroup = "Military" if StudentSubGroup == "mil"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"



** Generating new variables

gen SchYear = "2018-19"

gen AssmtName = "IAR"
gen AssmtType = "Regular"

gen StudentGroup_TotalTested = "--"
gen StudentSubGroup_TotalTested = "--"

local level 1 2 3 4 5

foreach a of local level {
	gen Lev`a'_count = "--"
	replace Lev`a'_percent = Lev`a'_percent/100
}

gen ProficientOrAbove_count = "--"

gen ProficientOrAbove_percent = Lev4_percent + Lev5_percent
tostring ProficientOrAbove_percent, replace force

foreach a of local level {
	tostring Lev`a'_percent, replace force
}

gen AvgScaleScore = "--"

gen ProficiencyCriteria = "Levels 4-5"

gen ParticipationRate = "--"

** Merging with NCES

gen StateAssignedDistID = substr(StateAssignedSchID,1,11)

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES}/NCES_2018_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2018_School.dta"
drop if _merge == 2
drop _merge




**** Appending

append using "${output}/IL_AssmtData_2019_sci.dta"

replace StateAbbrev = "IL" if DataLevel == 1
replace State = 17 if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

** Generating new variables



gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = ""

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

// gen Flag_AssmtNameChange = "Y"
// gen Flag_CutScoreChange_ELA = "Y"
// gen Flag_CutScoreChange_math = "Y"
// gen Flag_CutScoreChange_read = ""
// gen Flag_CutScoreChange_oth = "N"

// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2019_1.dta", replace

export delimited using "${output}/csv/IL_AssmtData_2019_1.csv", replace


////////// EDFACTS ADDENDUM


use "${output}/IL_AssmtData_2019_1.dta", clear

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactscount2019districtillinois.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019districtillinois.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactscount2019schoolillinois.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2019/edfactspart2019schoolillinois.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "IL_AssmtData_2019_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "IL_AssmtData_2019_State.dta"
tostring StudentSubGroup_TotalTested2, replace
replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTested2 if StudentSubGroup_TotalTested2 != "0" & StudentSubGroup_TotalTested2 != "."
drop StudentSubGroup_TotalTested2
drop if _merge == 2
drop _merge


destring ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = round(ProficientOrAbove_percent*StudentSubGroup_TotalTested, 1)
tostring ProficientOrAbove_percent StudentSubGroup_TotalTested ProficientOrAbove_count, replace force
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."


drop StudentGroup_TotalTested
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested 
destring StudentGroup_TotalTested, replace force ignore(",")
// replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == .
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "0"


order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2019.dta", replace

export delimited using "${output}/csv/IL_AssmtData_2019.csv", replace

