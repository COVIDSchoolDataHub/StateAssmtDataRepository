clear
set more off

global output "/Users/benjaminm/Documents/State_Repository_Research/Illinois/Output"
global NCES "/Users/benjaminm/Documents/State_Repository_Research/Illinois/NCES/Cleaned"

cd "/Users/benjaminm/Documents/State_Repository_Research/Illinois"




*** Sci

*** Sci Participation

use "${output}/IL_AssmtData_2022_sci_Participation_5.dta", clear
append using "${output}/IL_AssmtData_2022_sci_Participation_8.dta"

** Dropping extra variables

drop County City IEP NotIEP DIST
//drop County City Migrant IEP NotIEP DIST

** Rename existing variables

rename RCDTS StateAssignedSchID
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

save "${output}/IL_AssmtData_2022_sci_Participation.dta", replace



*** Sci Performance Levels

use "${output}/IL_AssmtData_2022_sci_5.dta", clear
append using "${output}/IL_AssmtData_2022_sci_8.dta"

** Dropping extra variables



drop County City IEP NotIEP DIST
// drop County City Migrant IEP NotIEP DIST

** Rename existing variables

rename RCDTS StateAssignedSchID
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
rename AverageScaleScore AvgScaleScore
rename Migrant ProficientOrAbove_percentMigrant

** Dropping entries

drop if StateAssignedSchID == ""

** Generating new variables

gen SchYear = "2021-22"

gen AssmtName = "ISA 2.0"
gen AssmtType = "Regular"

local level 1 2 3 4

foreach a of local level {
	gen Lev`a'_count = "--"
	gen Lev`a'_percent = "--"
}

gen Lev5_count = ""
gen Lev5_percent = ""

gen ProficientOrAbove_count = "--"

gen ProficiencyCriteria = "Levels 3-4"

gen Subject = "sci"

tostring AvgScaleScore, replace
replace AvgScaleScore = "--" if AvgScaleScore == " "

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
tostring ProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."

replace AvgScaleScore = "--" if StudentSubGroup != "All Students"

merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${output}/IL_AssmtData_2022_sci_Participation.dta"
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

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"
drop if _merge == 2
drop _merge

save "${output}/IL_AssmtData_2022_sci.dta", replace




**** ELA & Math

use "${output}/IL_AssmtData_2022_all.dta", clear

** Dropping extra variables

drop County City DistrictType DistrictSize SchoolType GradesServed 
// Children* IEP* NonIEP* Homeless* Youth* Migrant* Military* DH DI DJ DK DL DM DN DO DP EG EH EI EJ EL EM EN EO EQ ER ES ET FP FQ FR FS FU FV FW FX FZ GA GB GC GE GF GG GH GJ GK GL GM GO GP GQ GR GT GU GV GW GY GZ HA HB KY KZ LA LB LC LD LE LF LG LH LS LT LU LV LW LX LY LZ MA MB MC MD ME MF MG MH MI MJ MK ML NG NH NI NJ NK NL NM NN NO NP NQ NR NS NT NU NV NW NX NY NZ OA OB OC OD OE OF OG OH OI OJ OK OL OM ON OO OP OQ OR OS OT SQ SR SS ST SU SV SW SX SY SZ TK TL TM TN TO TP TQ TR TS TT TU TV TW TX TY TZ UA UB UC UD UY UZ VA VB VC VD VE VF VG VH VI VJ VK VL VM VN VO VP VQ VR VS VT VU VV VW VX VY VZ WA WB WC WD WE WF WG WH WI WJ WK WL AAI AAJ AAK AAL AAM AAN AAO AAP AAQ AAR ABC ABD ABE ABF ABG ABH ABI ABJ ABK ABL ABM ABN ABO ABP ABQ ABR ABS ABT ABU ABV ACQ ACR ACS ACT ACU ACV ACW ACX ACY ACZ ADA ADB ADC ADD ADE ADF ADG ADH ADI ADJ ADK ADL ADM ADN ADO ADP ADQ ADR ADS ADT ADU ADV ADW ADX ADY ADZ AEA AEB AEC AED AIA AIB AIC AID AIE AIF AIG AIH AII AIJ AIU AIV AIW AIX AIY AIZ AJA AJB AJC AJD AJE AJF AJG AJH AJI AJJ AJK AJL AJM AJN AKI AKJ AKK AKL AKM AKN AKO AKP AKQ AKR AKS AKT AKU AKV AKW AKX AKY AKZ ALA ALB ALC ALD ALE ALF ALG ALH ALI ALJ ALK ALL ALM ALN ALO ALP ALQ ALR ALS ALT ALU ALV APS APT APU APV APW APX APY APZ AQA AQB AQM AQN AQO AQP AQQ AQR AQS AQT AQU AQV AQW AQX AQY AQZ ARA ARB ARC ARD ARE ARF

** Rename existing variables

rename RCDTS StateAssignedSchID
rename Type DataLevel
rename SchoolName SchName
rename District DistName

rename AllstudentsIARELALevel1 Lev1_percentela3All
rename AllstudentsIARELALevel2 Lev2_percentela3All
rename AllstudentsIARELALevel3 Lev3_percentela3All
rename AllstudentsIARELALevel4 Lev4_percentela3All
rename AllstudentsIARELALevel5 Lev5_percentela3All
rename AllstudentsIARMathematicsL Lev1_percentmath3All
rename Q Lev2_percentmath3All
rename R Lev3_percentmath3All
rename S Lev4_percentmath3All
rename T Lev5_percentmath3All

rename MalestudentsIARELALevel1 Lev1_percentela3male
rename MalestudentsIARELALevel2 Lev2_percentela3male
rename MalestudentsIARELALevel3 Lev3_percentela3male
rename MalestudentsIARELALevel4 Lev4_percentela3male
rename MalestudentsIARELALevel5 Lev5_percentela3male
rename MalestudentsIARMathematics Lev1_percentmath3male
rename AA Lev2_percentmath3male
rename AB Lev3_percentmath3male
rename AC Lev4_percentmath3male
rename AD Lev5_percentmath3male

rename FemalestudentsIARELALevel Lev1_percentela3female
rename AF Lev2_percentela3female
rename AG Lev3_percentela3female
rename AH Lev4_percentela3female
rename AI Lev5_percentela3female
rename FemalestudentsIARMathematic Lev1_percentmath3female
rename AK Lev2_percentmath3female
rename AL Lev3_percentmath3female
rename AM Lev4_percentmath3female
rename AN Lev5_percentmath3female

rename WhitestudentsIARELALevel1 Lev1_percentela3white
rename WhitestudentsIARELALevel2 Lev2_percentela3white
rename WhitestudentsIARELALevel3 Lev3_percentela3white
rename WhitestudentsIARELALevel4 Lev4_percentela3white
rename WhitestudentsIARELALevel5 Lev5_percentela3white
rename WhitestudentsIARMathematics Lev1_percentmath3white
rename AU Lev2_percentmath3white
rename AV Lev3_percentmath3white
rename AW Lev4_percentmath3white
rename AX Lev5_percentmath3white

rename BlackorAfricanAmericanstud Lev1_percentela3black
rename AZ Lev2_percentela3black
rename BA Lev3_percentela3black
rename BB Lev4_percentela3black
rename BC Lev5_percentela3black
rename BD Lev1_percentmath3black
rename BE Lev2_percentmath3black
rename BF Lev3_percentmath3black
rename BG Lev4_percentmath3black
rename BH Lev5_percentmath3black

rename HispanicorLatinostudentsIA Lev1_percentela3hisp
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
rename AsianstudentsIARMathematics Lev1_percentmath3asian
rename BY Lev2_percentmath3asian
rename BZ Lev3_percentmath3asian
rename CA Lev4_percentmath3asian
rename CB Lev5_percentmath3asian

rename NativeHawaiianorOtherPacif Lev1_percentela3hawaii
rename CD Lev2_percentela3hawaii
rename CE Lev3_percentela3hawaii
rename CF Lev4_percentela3hawaii
rename CG Lev5_percentela3hawaii
rename CH Lev1_percentmath3hawaii
rename CI Lev2_percentmath3hawaii
rename CJ Lev3_percentmath3hawaii
rename CK Lev4_percentmath3hawaii
rename CL Lev5_percentmath3hawaii

rename AmericanIndianorAlaskaNati Lev1_percentela3native
rename CN Lev2_percentela3native
rename CO Lev3_percentela3native
rename CP Lev4_percentela3native
rename CQ Lev5_percentela3native
rename CR Lev1_percentmath3native
rename CS Lev2_percentmath3native
rename CT Lev3_percentmath3native
rename CU Lev4_percentmath3native
rename CV Lev5_percentmath3native

rename TwoorMoreRacestudentsIAR Lev1_percentela3two
rename CX Lev2_percentela3two
rename CY Lev3_percentela3two
rename CZ Lev4_percentela3two
rename DA Lev5_percentela3two
rename DB Lev1_percentmath3two
rename DC Lev2_percentmath3two
rename DD Lev3_percentmath3two
rename DE Lev4_percentmath3two
rename DF Lev5_percentmath3two

rename ChildrenwithDisabilitiesstu Lev1_percentela3chi  // NEWNEWNNEW
rename DH Lev2_percentela3chi
rename DI Lev3_percentela3chi
rename DJ Lev4_percentela3chi
rename DK Lev5_percentela3chi
rename DL Lev1_percentmath3chi
rename DM Lev2_percentmath3chi
rename DN Lev3_percentmath3chi
rename DO Lev4_percentmath3chi
rename DP Lev5_percentmath3chi

rename ELstudentsIARELALevel1 Lev1_percentela3learner
rename ELstudentsIARELALevel2 Lev2_percentela3learner
rename ELstudentsIARELALevel3 Lev3_percentela3learner
rename ELstudentsIARELALevel4 Lev4_percentela3learner
rename ELstudentsIARELALevel5 Lev5_percentela3learner
rename ELstudentsIARMathematicsLe Lev1_percentmath3learner
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

rename NonLowIncomestudentsIAREL Lev1_percentela3dis
rename FF Lev2_percentela3dis
rename FG Lev3_percentela3dis
rename FH Lev4_percentela3dis
rename FI Lev5_percentela3dis
rename NonLowIncomestudentsIARMa Lev1_percentmath3dis
rename FK Lev2_percentmath3dis
rename FL Lev3_percentmath3dis
rename FM Lev4_percentmath3dis
rename FN Lev5_percentmath3dis

rename HomelessstudentsIARELALeve Lev1_percentela3home  // NEWNEWNEW
rename FP Lev2_percentela3home
rename FQ Lev3_percentela3home
rename FR Lev4_percentela3home
rename FS Lev5_percentela3home
rename HomelessstudentsIARMathemat Lev1_percentmath3home
rename FU Lev2_percentmath3home
rename FV Lev3_percentmath3home
rename FW Lev4_percentmath3home
rename FX Lev5_percentmath3home

rename MigrantstudentsIARELALevel Lev1_percentela3mig   // NEWNEWNEW
rename GJ Lev2_percentela3mig
rename GK Lev3_percentela3mig
rename GL Lev4_percentela3mig
rename GM Lev5_percentela3mig
rename MigrantstudentsIARMathemati Lev1_percentmath3mig
rename GO Lev2_percentmath3mig
rename GP Lev3_percentmath3mig
rename GQ Lev4_percentmath3mig
rename GR Lev5_percentmath3mig

rename MilitarystudentsIARELALeve Lev1_percentela3mil  // NEWNEWNEW
rename GT Lev2_percentela3mil
rename GU Lev3_percentela3mil
rename GV Lev4_percentela3mil
rename GW Lev5_percentela3mil
rename MilitarystudentsIARMathemat Lev1_percentmath3mil
rename GY Lev2_percentmath3mil
rename GZ Lev3_percentmath3mil
rename HA Lev4_percentmath3mil
rename HB Lev5_percentmath3mil


rename HC Lev1_percentela4All
rename HD Lev2_percentela4All
rename HE Lev3_percentela4All
rename HF Lev4_percentela4All
rename HG Lev5_percentela4All
rename HH Lev1_percentmath4All
rename HI Lev2_percentmath4All
rename HJ Lev3_percentmath4All
rename HK Lev4_percentmath4All
rename HL Lev5_percentmath4All

rename HM Lev1_percentela4male
rename HN Lev2_percentela4male
rename HO Lev3_percentela4male
rename HP Lev4_percentela4male
rename HQ Lev5_percentela4male
rename HR Lev1_percentmath4male
rename HS Lev2_percentmath4male
rename HT Lev3_percentmath4male
rename HU Lev4_percentmath4male
rename HV Lev5_percentmath4male

rename HW Lev1_percentela4female
rename HX Lev2_percentela4female
rename HY Lev3_percentela4female
rename HZ Lev4_percentela4female
rename IA Lev5_percentela4female
rename IB Lev1_percentmath4female
rename IC Lev2_percentmath4female
rename ID Lev3_percentmath4female
rename IE Lev4_percentmath4female
rename IF Lev5_percentmath4female

rename IG Lev1_percentela4white
rename IH Lev2_percentela4white
rename II Lev3_percentela4white
rename IJ Lev4_percentela4white
rename IK Lev5_percentela4white
rename IL Lev1_percentmath4white
rename IM Lev2_percentmath4white
rename IN Lev3_percentmath4white
rename IO Lev4_percentmath4white
rename IP Lev5_percentmath4white

rename IQ Lev1_percentela4black
rename IR Lev2_percentela4black
rename IS Lev3_percentela4black
rename IT Lev4_percentela4black
rename IU Lev5_percentela4black
rename IV Lev1_percentmath4black
rename IW Lev2_percentmath4black
rename IX Lev3_percentmath4black
rename IY Lev4_percentmath4black
rename IZ Lev5_percentmath4black

rename JA Lev1_percentela4hisp
rename JB Lev2_percentela4hisp
rename JC Lev3_percentela4hisp
rename JD Lev4_percentela4hisp
rename JE Lev5_percentela4hisp
rename JF Lev1_percentmath4hisp
rename JG Lev2_percentmath4hisp
rename JH Lev3_percentmath4hisp
rename JI Lev4_percentmath4hisp
rename JJ Lev5_percentmath4hisp

rename JK Lev1_percentela4asian
rename JL Lev2_percentela4asian
rename JM Lev3_percentela4asian
rename JN Lev4_percentela4asian
rename JO Lev5_percentela4asian
rename JP Lev1_percentmath4asian
rename JQ Lev2_percentmath4asian
rename JR Lev3_percentmath4asian
rename JS Lev4_percentmath4asian
rename JT Lev5_percentmath4asian

rename JU Lev1_percentela4hawaii
rename JV Lev2_percentela4hawaii
rename JW Lev3_percentela4hawaii
rename JX Lev4_percentela4hawaii
rename JY Lev5_percentela4hawaii
rename JZ Lev1_percentmath4hawaii
rename KA Lev2_percentmath4hawaii
rename KB Lev3_percentmath4hawaii
rename KC Lev4_percentmath4hawaii
rename KD Lev5_percentmath4hawaii

rename KE Lev1_percentela4native
rename KF Lev2_percentela4native
rename KG Lev3_percentela4native
rename KH Lev4_percentela4native
rename KI Lev5_percentela4native
rename KJ Lev1_percentmath4native
rename KK Lev2_percentmath4native
rename KL Lev3_percentmath4native
rename KM Lev4_percentmath4native
rename KN Lev5_percentmath4native

rename KO Lev1_percentela4two
rename KP Lev2_percentela4two
rename KQ Lev3_percentela4two
rename KR Lev4_percentela4two
rename KS Lev5_percentela4two
rename KT Lev1_percentmath4two
rename KU Lev2_percentmath4two
rename KV Lev3_percentmath4two
rename KW Lev4_percentmath4two
rename KX Lev5_percentmath4two

rename KY Lev1_percentela4chi // NEWNEWNNEW
rename KZ Lev2_percentela4chi
rename LA Lev3_percentela4chi
rename LB Lev4_percentela4chi
rename LC Lev5_percentela4chi
rename LD Lev1_percentmath4chi
rename LE Lev2_percentmath4chi
rename LF Lev3_percentmath4chi
rename LG Lev4_percentmath4chi
rename LH Lev5_percentmath4chi

rename LI Lev1_percentela4learner
rename LJ Lev2_percentela4learner
rename LK Lev3_percentela4learner
rename LL Lev4_percentela4learner
rename LM Lev5_percentela4learner
rename LN Lev1_percentmath4learner
rename LO Lev2_percentmath4learner
rename LP Lev3_percentmath4learner
rename LQ Lev4_percentmath4learner
rename LR Lev5_percentmath4learner

rename MM Lev1_percentela4dis
rename MN Lev2_percentela4dis
rename MO Lev3_percentela4dis
rename MP Lev4_percentela4dis
rename MQ Lev5_percentela4dis
rename MR Lev1_percentmath4dis
rename MS Lev2_percentmath4dis
rename MT Lev3_percentmath4dis
rename MU Lev4_percentmath4dis
rename MV Lev5_percentmath4dis

rename MW Lev1_percentela4notdis
rename MX Lev2_percentela4notdis
rename MY Lev3_percentela4notdis
rename MZ Lev4_percentela4notdis
rename NA Lev5_percentela4notdis
rename NB Lev1_percentmath4notdis
rename NC Lev2_percentmath4notdis
rename ND Lev3_percentmath4notdis
rename NE Lev4_percentmath4notdis
rename NF Lev5_percentmath4notdis


rename NQ Lev1_percentela4home // NEWNEWNEW
rename NR Lev2_percentela4home
rename NS Lev3_percentela4home
rename NT Lev4_percentela4home
rename NU Lev5_percentela4home
rename NV Lev1_percentmath4home
rename NW Lev2_percentmath4home
rename NX Lev3_percentmath4home
rename NY Lev4_percentmath4home
rename NZ Lev5_percentmath4home

rename OA Lev1_percentela4mig // NEWNEWNEW
rename OB Lev2_percentela4mig
rename OC Lev3_percentela4mig
rename OD Lev4_percentela4mig
rename OE Lev5_percentela4mig
rename OF Lev1_percentmath4mig
rename OG Lev2_percentmath4mig
rename OH Lev3_percentmath4mig
rename OI Lev4_percentmath4mig
rename OJ Lev5_percentmath4mig

rename OK Lev1_percentela4mil // NEWNEWNEW
rename OL Lev2_percentela4mil
rename OM Lev3_percentela4mil
rename ON Lev4_percentela4mil
rename OO Lev5_percentela4mil
rename OP Lev1_percentmath4mil
rename OQ Lev2_percentmath4mil
rename OR Lev3_percentmath4mil
rename OS Lev4_percentmath4mil
rename OT Lev5_percentmath4mil


rename OU Lev1_percentela5All
rename OV Lev2_percentela5All
rename OW Lev3_percentela5All
rename OX Lev4_percentela5All
rename OY Lev5_percentela5All
rename OZ Lev1_percentmath5All
rename PA Lev2_percentmath5All
rename PB Lev3_percentmath5All
rename PC Lev4_percentmath5All
rename PD Lev5_percentmath5All

rename PE Lev1_percentela5male
rename PF Lev2_percentela5male
rename PG Lev3_percentela5male
rename PH Lev4_percentela5male
rename PI Lev5_percentela5male
rename PJ Lev1_percentmath5male
rename PK Lev2_percentmath5male
rename PL Lev3_percentmath5male
rename PM Lev4_percentmath5male
rename PN Lev5_percentmath5male

rename PO Lev1_percentela5female
rename PP Lev2_percentela5female
rename PQ Lev3_percentela5female
rename PR Lev4_percentela5female
rename PS Lev5_percentela5female
rename PT Lev1_percentmath5female
rename PU Lev2_percentmath5female
rename PV Lev3_percentmath5female
rename PW Lev4_percentmath5female
rename PX Lev5_percentmath5female

rename PY Lev1_percentela5white
rename PZ Lev2_percentela5white
rename QA Lev3_percentela5white
rename QB Lev4_percentela5white
rename QC Lev5_percentela5white
rename QD Lev1_percentmath5white
rename QE Lev2_percentmath5white
rename QF Lev3_percentmath5white
rename QG Lev4_percentmath5white
rename QH Lev5_percentmath5white

rename QI Lev1_percentela5black
rename QJ Lev2_percentela5black
rename QK Lev3_percentela5black
rename QL Lev4_percentela5black
rename QM Lev5_percentela5black
rename QN Lev1_percentmath5black
rename QO Lev2_percentmath5black
rename QP Lev3_percentmath5black
rename QQ Lev4_percentmath5black
rename QR Lev5_percentmath5black

rename QS Lev1_percentela5hisp
rename QT Lev2_percentela5hisp
rename QU Lev3_percentela5hisp
rename QV Lev4_percentela5hisp
rename QW Lev5_percentela5hisp
rename QX Lev1_percentmath5hisp
rename QY Lev2_percentmath5hisp
rename QZ Lev3_percentmath5hisp
rename RA Lev4_percentmath5hisp
rename RB Lev5_percentmath5hisp

rename RC Lev1_percentela5asian
rename RD Lev2_percentela5asian
rename RE Lev3_percentela5asian
rename RF Lev4_percentela5asian
rename RG Lev5_percentela5asian
rename RH Lev1_percentmath5asian
rename RI Lev2_percentmath5asian
rename RJ Lev3_percentmath5asian
rename RK Lev4_percentmath5asian
rename RL Lev5_percentmath5asian

rename RM Lev1_percentela5hawaii
rename RN Lev2_percentela5hawaii
rename RO Lev3_percentela5hawaii
rename RP Lev4_percentela5hawaii
rename RQ Lev5_percentela5hawaii
rename RR Lev1_percentmath5hawaii
rename RS Lev2_percentmath5hawaii
rename RT Lev3_percentmath5hawaii
rename RU Lev4_percentmath5hawaii
rename RV Lev5_percentmath5hawaii

rename RW Lev1_percentela5native
rename RX Lev2_percentela5native
rename RY Lev3_percentela5native
rename RZ Lev4_percentela5native
rename SA Lev5_percentela5native
rename SB Lev1_percentmath5native
rename SC Lev2_percentmath5native
rename SD Lev3_percentmath5native
rename SE Lev4_percentmath5native
rename SF Lev5_percentmath5native

rename SG Lev1_percentela5two
rename SH Lev2_percentela5two
rename SI Lev3_percentela5two
rename SJ Lev4_percentela5two
rename SK Lev5_percentela5two
rename SL Lev1_percentmath5two
rename SM Lev2_percentmath5two
rename SN Lev3_percentmath5two
rename SO Lev4_percentmath5two
rename SP Lev5_percentmath5two

rename SQ Lev1_percentela5chi // NEWNEWNNEW
rename SR Lev2_percentela5chi
rename SS Lev3_percentela5chi
rename ST Lev4_percentela5chi
rename SU Lev5_percentela5chi
rename SV Lev1_percentmath5chi
rename SW Lev2_percentmath5chi
rename SX Lev3_percentmath5chi
rename SY Lev4_percentmath5chi
rename SZ Lev5_percentmath5chi

rename TA Lev1_percentela5learner
rename TB Lev2_percentela5learner
rename TC Lev3_percentela5learner
rename TD Lev4_percentela5learner
rename TE Lev5_percentela5learner
rename TF Lev1_percentmath5learner
rename TG Lev2_percentmath5learner
rename TH Lev3_percentmath5learner
rename TI Lev4_percentmath5learner
rename TJ Lev5_percentmath5learner

rename UE Lev1_percentela5dis
rename UF Lev2_percentela5dis
rename UG Lev3_percentela5dis
rename UH Lev4_percentela5dis
rename UI Lev5_percentela5dis
rename UJ Lev1_percentmath5dis
rename UK Lev2_percentmath5dis
rename UL Lev3_percentmath5dis
rename UM Lev4_percentmath5dis
rename UN Lev5_percentmath5dis

rename UO Lev1_percentela5notdis
rename UP Lev2_percentela5notdis
rename UQ Lev3_percentela5notdis
rename UR Lev4_percentela5notdis
rename US Lev5_percentela5notdis
rename UT Lev1_percentmath5notdis
rename UU Lev2_percentmath5notdis
rename UV Lev3_percentmath5notdis
rename UW Lev4_percentmath5notdis
rename UX Lev5_percentmath5notdis



rename VI Lev1_percentela5home // NEWNEWNEW
rename VJ Lev2_percentela5home
rename VK Lev3_percentela5home
rename VL Lev4_percentela5home
rename VM Lev5_percentela5home
rename VN Lev1_percentmath5home
rename VO Lev2_percentmath5home
rename VP Lev3_percentmath5home
rename VQ Lev4_percentmath5home
rename VR Lev5_percentmath5home

rename VS Lev1_percentela5mig // NEWNEWNEW
rename VT Lev2_percentela5mig
rename VU Lev3_percentela5mig
rename VV Lev4_percentela5mig
rename VW Lev5_percentela5mig
rename VX Lev1_percentmath5mig
rename VY Lev2_percentmath5mig
rename VZ Lev3_percentmath5mig
rename WA Lev4_percentmath5mig
rename WB Lev5_percentmath5mig

rename WC Lev1_percentela5mil // NEWNEWNEW
rename WD Lev2_percentela5mil
rename WE Lev3_percentela5mil
rename WF Lev4_percentela5mil
rename WG Lev5_percentela5mil
rename WH Lev1_percentmath5mil
rename WI Lev2_percentmath5mil
rename WJ Lev3_percentmath5mil
rename WK Lev4_percentmath5mil
rename WL Lev5_percentmath5mil



rename WM Lev1_percentela6All
rename WN Lev2_percentela6All
rename WO Lev3_percentela6All
rename WP Lev4_percentela6All
rename WQ Lev5_percentela6All
rename WR Lev1_percentmath6All
rename WS Lev2_percentmath6All
rename WT Lev3_percentmath6All
rename WU Lev4_percentmath6All
rename WV Lev5_percentmath6All

rename WW Lev1_percentela6male
rename WX Lev2_percentela6male
rename WY Lev3_percentela6male
rename WZ Lev4_percentela6male
rename XA Lev5_percentela6male
rename XB Lev1_percentmath6male
rename XC Lev2_percentmath6male
rename XD Lev3_percentmath6male
rename XE Lev4_percentmath6male
rename XF Lev5_percentmath6male

rename XG Lev1_percentela6female
rename XH Lev2_percentela6female
rename XI Lev3_percentela6female
rename XJ Lev4_percentela6female
rename XK Lev5_percentela6female
rename XL Lev1_percentmath6female
rename XM Lev2_percentmath6female
rename XN Lev3_percentmath6female
rename XO Lev4_percentmath6female
rename XP Lev5_percentmath6female

rename XQ Lev1_percentela6white
rename XR Lev2_percentela6white
rename XS Lev3_percentela6white
rename XT Lev4_percentela6white
rename XU Lev5_percentela6white
rename XV Lev1_percentmath6white
rename XW Lev2_percentmath6white
rename XX Lev3_percentmath6white
rename XY Lev4_percentmath6white
rename XZ Lev5_percentmath6white

rename YA Lev1_percentela6black
rename YB Lev2_percentela6black
rename YC Lev3_percentela6black
rename YD Lev4_percentela6black
rename YE Lev5_percentela6black
rename YF Lev1_percentmath6black
rename YG Lev2_percentmath6black
rename YH Lev3_percentmath6black
rename YI Lev4_percentmath6black
rename YJ Lev5_percentmath6black

rename YK Lev1_percentela6hisp
rename YL Lev2_percentela6hisp
rename YM Lev3_percentela6hisp
rename YN Lev4_percentela6hisp
rename YO Lev5_percentela6hisp
rename YP Lev1_percentmath6hisp
rename YQ Lev2_percentmath6hisp
rename YR Lev3_percentmath6hisp
rename YS Lev4_percentmath6hisp
rename YT Lev5_percentmath6hisp

rename YU Lev1_percentela6asian
rename YV Lev2_percentela6asian
rename YW Lev3_percentela6asian
rename YX Lev4_percentela6asian
rename YY Lev5_percentela6asian
rename YZ Lev1_percentmath6asian
rename ZA Lev2_percentmath6asian
rename ZB Lev3_percentmath6asian
rename ZC Lev4_percentmath6asian
rename ZD Lev5_percentmath6asian

rename ZE Lev1_percentela6hawaii
rename ZF Lev2_percentela6hawaii
rename ZG Lev3_percentela6hawaii
rename ZH Lev4_percentela6hawaii
rename ZI Lev5_percentela6hawaii
rename ZJ Lev1_percentmath6hawaii
rename ZK Lev2_percentmath6hawaii
rename ZL Lev3_percentmath6hawaii
rename ZM Lev4_percentmath6hawaii
rename ZN Lev5_percentmath6hawaii

rename ZO Lev1_percentela6native
rename ZP Lev2_percentela6native
rename ZQ Lev3_percentela6native
rename ZR Lev4_percentela6native
rename ZS Lev5_percentela6native
rename ZT Lev1_percentmath6native
rename ZU Lev2_percentmath6native
rename ZV Lev3_percentmath6native
rename ZW Lev4_percentmath6native
rename ZX Lev5_percentmath6native

rename ZY Lev1_percentela6two
rename ZZ Lev2_percentela6two
rename AAA Lev3_percentela6two
rename AAB Lev4_percentela6two
rename AAC Lev5_percentela6two
rename AAD Lev1_percentmath6two
rename AAE Lev2_percentmath6two
rename AAF Lev3_percentmath6two
rename AAG Lev4_percentmath6two
rename AAH Lev5_percentmath6two


rename AAI Lev1_percentela6chi // NEWNEWNNEW
rename AAJ Lev2_percentela6chi
rename AAK Lev3_percentela6chi
rename AAL Lev4_percentela6chi
rename AAM Lev5_percentela6chi
rename AAN Lev1_percentmath6chi
rename AAO Lev2_percentmath6chi
rename AAP Lev3_percentmath6chi
rename AAQ Lev4_percentmath6chi
rename AAR Lev5_percentmath6chi

rename AAS Lev1_percentela6learner
rename AAT Lev2_percentela6learner
rename AAU Lev3_percentela6learner
rename AAV Lev4_percentela6learner
rename AAW Lev5_percentela6learner
rename AAX Lev1_percentmath6learner
rename AAY Lev2_percentmath6learner
rename AAZ Lev3_percentmath6learner
rename ABA Lev4_percentmath6learner
rename ABB Lev5_percentmath6learner

rename ABW Lev1_percentela6dis
rename ABX Lev2_percentela6dis
rename ABY Lev3_percentela6dis
rename ABZ Lev4_percentela6dis
rename ACA Lev5_percentela6dis
rename ACB Lev1_percentmath6dis
rename ACC Lev2_percentmath6dis
rename ACD Lev3_percentmath6dis
rename ACE Lev4_percentmath6dis
rename ACF Lev5_percentmath6dis

rename ACG Lev1_percentela6notdis
rename ACH Lev2_percentela6notdis
rename ACI Lev3_percentela6notdis
rename ACJ Lev4_percentela6notdis
rename ACK Lev5_percentela6notdis
rename ACL Lev1_percentmath6notdis
rename ACM Lev2_percentmath6notdis
rename ACN Lev3_percentmath6notdis
rename ACO Lev4_percentmath6notdis
rename ACP Lev5_percentmath6notdis



rename ADA Lev1_percentela6home // NEWNEWNEW
rename ADB Lev2_percentela6home
rename ADC Lev3_percentela6home
rename ADD Lev4_percentela6home
rename ADE Lev5_percentela6home
rename ADF Lev1_percentmath6home
rename ADG Lev2_percentmath6home
rename ADH Lev3_percentmath6home
rename ADI Lev4_percentmath6home
rename ADJ Lev5_percentmath6home

rename ADK Lev1_percentela6mig // NEWNEWNEW
rename ADL Lev2_percentela6mig
rename ADM Lev3_percentela6mig
rename ADN Lev4_percentela6mig
rename ADO Lev5_percentela6mig
rename ADP Lev1_percentmath6mig
rename ADQ Lev2_percentmath6mig
rename ADR Lev3_percentmath6mig
rename ADS Lev4_percentmath6mig
rename ADT Lev5_percentmath6mig

rename ADU Lev1_percentela6mil // NEWNEWNEW
rename ADV Lev2_percentela6mil
rename ADW Lev3_percentela6mil
rename ADX Lev4_percentela6mil
rename ADY Lev5_percentela6mil
rename ADZ Lev1_percentmath6mil
rename AEA Lev2_percentmath6mil
rename AEB Lev3_percentmath6mil
rename AEC Lev4_percentmath6mil
rename AED Lev5_percentmath6mil



rename AEE Lev1_percentela7All
rename AEF Lev2_percentela7All
rename AEG Lev3_percentela7All
rename AEH Lev4_percentela7All
rename AEI Lev5_percentela7All
rename AEJ Lev1_percentmath7All
rename AEK Lev2_percentmath7All
rename AEL Lev3_percentmath7All
rename AEM Lev4_percentmath7All
rename AEN Lev5_percentmath7All

rename AEO Lev1_percentela7male
rename AEP Lev2_percentela7male
rename AEQ Lev3_percentela7male
rename AER Lev4_percentela7male
rename AES Lev5_percentela7male
rename AET Lev1_percentmath7male
rename AEU Lev2_percentmath7male
rename AEV Lev3_percentmath7male
rename AEW Lev4_percentmath7male
rename AEX Lev5_percentmath7male

rename AEY Lev1_percentela7female
rename AEZ Lev2_percentela7female
rename AFA Lev3_percentela7female
rename AFB Lev4_percentela7female
rename AFC Lev5_percentela7female
rename AFD Lev1_percentmath7female
rename AFE Lev2_percentmath7female
rename AFF Lev3_percentmath7female
rename AFG Lev4_percentmath7female
rename AFH Lev5_percentmath7female

rename AFI Lev1_percentela7white
rename AFJ Lev2_percentela7white
rename AFK Lev3_percentela7white
rename AFL Lev4_percentela7white
rename AFM Lev5_percentela7white
rename AFN Lev1_percentmath7white
rename AFO Lev2_percentmath7white
rename AFP Lev3_percentmath7white
rename AFQ Lev4_percentmath7white
rename AFR Lev5_percentmath7white

rename AFS Lev1_percentela7black
rename AFT Lev2_percentela7black
rename AFU Lev3_percentela7black
rename AFV Lev4_percentela7black
rename AFW Lev5_percentela7black
rename AFX Lev1_percentmath7black
rename AFY Lev2_percentmath7black
rename AFZ Lev3_percentmath7black
rename AGA Lev4_percentmath7black
rename AGB Lev5_percentmath7black

rename AGC Lev1_percentela7hisp
rename AGD Lev2_percentela7hisp
rename AGE Lev3_percentela7hisp
rename AGF Lev4_percentela7hisp
rename AGG Lev5_percentela7hisp
rename AGH Lev1_percentmath7hisp
rename AGI Lev2_percentmath7hisp
rename AGJ Lev3_percentmath7hisp
rename AGK Lev4_percentmath7hisp
rename AGL Lev5_percentmath7hisp

rename AGM Lev1_percentela7asian
rename AGN Lev2_percentela7asian
rename AGO Lev3_percentela7asian
rename AGP Lev4_percentela7asian
rename AGQ Lev5_percentela7asian
rename AGR Lev1_percentmath7asian
rename AGS Lev2_percentmath7asian
rename AGT Lev3_percentmath7asian
rename AGU Lev4_percentmath7asian
rename AGV Lev5_percentmath7asian

rename AGW Lev1_percentela7hawaii
rename AGX Lev2_percentela7hawaii
rename AGY Lev3_percentela7hawaii
rename AGZ Lev4_percentela7hawaii
rename AHA Lev5_percentela7hawaii
rename AHB Lev1_percentmath7hawaii
rename AHC Lev2_percentmath7hawaii
rename AHD Lev3_percentmath7hawaii
rename AHE Lev4_percentmath7hawaii
rename AHF Lev5_percentmath7hawaii

rename AHG Lev1_percentela7native
rename AHH Lev2_percentela7native
rename AHI Lev3_percentela7native
rename AHJ Lev4_percentela7native
rename AHK Lev5_percentela7native
rename AHL Lev1_percentmath7native
rename AHM Lev2_percentmath7native
rename AHN Lev3_percentmath7native
rename AHO Lev4_percentmath7native
rename AHP Lev5_percentmath7native

rename AHQ Lev1_percentela7two
rename AHR Lev2_percentela7two
rename AHS Lev3_percentela7two
rename AHT Lev4_percentela7two
rename AHU Lev5_percentela7two
rename AHV Lev1_percentmath7two
rename AHW Lev2_percentmath7two
rename AHX Lev3_percentmath7two
rename AHY Lev4_percentmath7two
rename AHZ Lev5_percentmath7two

rename AIA Lev1_percentela7chi // NEWNEWNNEW
rename AIB Lev2_percentela7chi
rename AIC Lev3_percentela7chi
rename AID Lev4_percentela7chi
rename AIE Lev5_percentela7chi
rename AIF Lev1_percentmath7chi
rename AIG Lev2_percentmath7chi
rename AIH Lev3_percentmath7chi
rename AII Lev4_percentmath7chi
rename AIJ Lev5_percentmath7chi

rename AIK Lev1_percentela7learner
rename AIL Lev2_percentela7learner
rename AIM Lev3_percentela7learner
rename AIN Lev4_percentela7learner
rename AIO Lev5_percentela7learner
rename AIP Lev1_percentmath7learner
rename AIQ Lev2_percentmath7learner
rename AIR Lev3_percentmath7learner
rename AIS Lev4_percentmath7learner
rename AIT Lev5_percentmath7learner

rename AJO Lev1_percentela7dis
rename AJP Lev2_percentela7dis
rename AJQ Lev3_percentela7dis
rename AJR Lev4_percentela7dis
rename AJS Lev5_percentela7dis
rename AJT Lev1_percentmath7dis
rename AJU Lev2_percentmath7dis
rename AJV Lev3_percentmath7dis
rename AJW Lev4_percentmath7dis
rename AJX Lev5_percentmath7dis

rename AJY Lev1_percentela7notdis
rename AJZ Lev2_percentela7notdis
rename AKA Lev3_percentela7notdis
rename AKB Lev4_percentela7notdis
rename AKC Lev5_percentela7notdis
rename AKD Lev1_percentmath7notdis
rename AKE Lev2_percentmath7notdis
rename AKF Lev3_percentmath7notdis
rename AKG Lev4_percentmath7notdis
rename AKH Lev5_percentmath7notdis

rename AKS Lev1_percentela7home // NEWNEWNEW
rename AKT Lev2_percentela7home
rename AKU Lev3_percentela7home
rename AKV Lev4_percentela7home
rename AKW Lev5_percentela7home
rename AKX Lev1_percentmath7home
rename AKY Lev2_percentmath7home
rename AKZ Lev3_percentmath7home
rename ALA Lev4_percentmath7home
rename ALB Lev5_percentmath7home

rename ALC Lev1_percentela7mig // NEWNEWNEW
rename ALD Lev2_percentela7mig
rename ALE Lev3_percentela7mig
rename ALF Lev4_percentela7mig
rename ALG Lev5_percentela7mig
rename ALH Lev1_percentmath7mig
rename ALI Lev2_percentmath7mig
rename ALJ Lev3_percentmath7mig
rename ALK Lev4_percentmath7mig
rename ALL Lev5_percentmath7mig

rename ALM Lev1_percentela7mil // NEWNEWNEW
rename ALN Lev2_percentela7mil
rename ALO Lev3_percentela7mil
rename ALP Lev4_percentela7mil
rename ALQ Lev5_percentela7mil
rename ALR Lev1_percentmath7mil
rename ALS Lev2_percentmath7mil
rename ALT Lev3_percentmath7mil
rename ALU Lev4_percentmath7mil
rename ALV Lev5_percentmath7mil


rename ALW Lev1_percentela8All
rename ALX Lev2_percentela8All
rename ALY Lev3_percentela8All
rename ALZ Lev4_percentela8All
rename AMA Lev5_percentela8All
rename AMB Lev1_percentmath8All
rename AMC Lev2_percentmath8All
rename AMD Lev3_percentmath8All
rename AME Lev4_percentmath8All
rename AMF Lev5_percentmath8All

rename AMG Lev1_percentela8male
rename AMH Lev2_percentela8male
rename AMI Lev3_percentela8male
rename AMJ Lev4_percentela8male
rename AMK Lev5_percentela8male
rename AML Lev1_percentmath8male
rename AMM Lev2_percentmath8male
rename AMN Lev3_percentmath8male
rename AMO Lev4_percentmath8male
rename AMP Lev5_percentmath8male

rename AMQ Lev1_percentela8female
rename AMR Lev2_percentela8female
rename AMS Lev3_percentela8female
rename AMT Lev4_percentela8female
rename AMU Lev5_percentela8female
rename AMV Lev1_percentmath8female
rename AMW Lev2_percentmath8female
rename AMX Lev3_percentmath8female
rename AMY Lev4_percentmath8female
rename AMZ Lev5_percentmath8female

rename ANA Lev1_percentela8white
rename ANB Lev2_percentela8white
rename ANC Lev3_percentela8white
rename AND Lev4_percentela8white
rename ANE Lev5_percentela8white
rename ANF Lev1_percentmath8white
rename ANG Lev2_percentmath8white
rename ANH Lev3_percentmath8white
rename ANI Lev4_percentmath8white
rename ANJ Lev5_percentmath8white

rename ANK Lev1_percentela8black
rename ANL Lev2_percentela8black
rename ANM Lev3_percentela8black
rename ANN Lev4_percentela8black
rename ANO Lev5_percentela8black
rename ANP Lev1_percentmath8black
rename ANQ Lev2_percentmath8black
rename ANR Lev3_percentmath8black
rename ANS Lev4_percentmath8black
rename ANT Lev5_percentmath8black

rename ANU Lev1_percentela8hisp
rename ANV Lev2_percentela8hisp
rename ANW Lev3_percentela8hisp
rename ANX Lev4_percentela8hisp
rename ANY Lev5_percentela8hisp
rename ANZ Lev1_percentmath8hisp
rename AOA Lev2_percentmath8hisp
rename AOB Lev3_percentmath8hisp
rename AOC Lev4_percentmath8hisp
rename AOD Lev5_percentmath8hisp

rename AOE Lev1_percentela8asian
rename AOF Lev2_percentela8asian
rename AOG Lev3_percentela8asian
rename AOH Lev4_percentela8asian
rename AOI Lev5_percentela8asian
rename AOJ Lev1_percentmath8asian
rename AOK Lev2_percentmath8asian
rename AOL Lev3_percentmath8asian
rename AOM Lev4_percentmath8asian
rename AON Lev5_percentmath8asian

rename AOO Lev1_percentela8hawaii
rename AOP Lev2_percentela8hawaii
rename AOQ Lev3_percentela8hawaii
rename AOR Lev4_percentela8hawaii
rename AOS Lev5_percentela8hawaii
rename AOT Lev1_percentmath8hawaii
rename AOU Lev2_percentmath8hawaii
rename AOV Lev3_percentmath8hawaii
rename AOW Lev4_percentmath8hawaii
rename AOX Lev5_percentmath8hawaii

rename AOY Lev1_percentela8native
rename AOZ Lev2_percentela8native
rename APA Lev3_percentela8native
rename APB Lev4_percentela8native
rename APC Lev5_percentela8native
rename APD Lev1_percentmath8native
rename APE Lev2_percentmath8native
rename APF Lev3_percentmath8native
rename APG Lev4_percentmath8native
rename APH Lev5_percentmath8native

rename API Lev1_percentela8two
rename APJ Lev2_percentela8two
rename APK Lev3_percentela8two
rename APL Lev4_percentela8two
rename APM Lev5_percentela8two
rename APN Lev1_percentmath8two
rename APO Lev2_percentmath8two
rename APP Lev3_percentmath8two
rename APQ Lev4_percentmath8two
rename APR Lev5_percentmath8two

rename APS Lev1_percentela8chi // NEWNEWNNEW
rename APT Lev2_percentela8chi
rename APU Lev3_percentela8chi
rename APV Lev4_percentela8chi
rename APW Lev5_percentela8chi
rename APX Lev1_percentmath8chi
rename APY Lev2_percentmath8chi
rename APZ Lev3_percentmath8chi
rename AQA Lev4_percentmath8chi
rename AQB Lev5_percentmath8chi

rename AQC Lev1_percentela8learner
rename AQD Lev2_percentela8learner
rename AQE Lev3_percentela8learner
rename AQF Lev4_percentela8learner
rename AQG Lev5_percentela8learner
rename AQH Lev1_percentmath8learner
rename AQI Lev2_percentmath8learner
rename AQJ Lev3_percentmath8learner
rename AQK Lev4_percentmath8learner
rename AQL Lev5_percentmath8learner

rename ARG Lev1_percentela8dis
rename ARH Lev2_percentela8dis
rename ARI Lev3_percentela8dis
rename ARJ Lev4_percentela8dis
rename ARK Lev5_percentela8dis
rename ARL Lev1_percentmath8dis
rename ARM Lev2_percentmath8dis
rename ARN Lev3_percentmath8dis
rename ARO Lev4_percentmath8dis
rename ARP Lev5_percentmath8dis

rename ARQ Lev1_percentela8notdis
rename ARR Lev2_percentela8notdis
rename ARS Lev3_percentela8notdis
rename ART Lev4_percentela8notdis
rename ARU Lev5_percentela8notdis
rename ARV Lev1_percentmath8notdis
rename ARW Lev2_percentmath8notdis
rename ARX Lev3_percentmath8notdis
rename ARY Lev4_percentmath8notdis
rename ARZ Lev5_percentmath8notdis

rename ASA Lev1_percentela8home // NEWNEWNEW
rename ASB Lev2_percentela8home
rename ASC Lev3_percentela8home
rename ASD Lev4_percentela8home
rename ASE Lev5_percentela8home
rename ASF Lev1_percentmath8home
rename ASG Lev2_percentmath8home
rename ASH Lev3_percentmath8home
rename ASI Lev4_percentmath8home
rename ASJ Lev5_percentmath8home

rename ASK Lev1_percentela8mig // NEWNEWNEW
rename ASL Lev2_percentela8mig
rename ASM Lev3_percentela8mig
rename ASN Lev4_percentela8mig
rename ASO Lev5_percentela8mig
rename ASP Lev1_percentmath8mig
rename ASQ Lev2_percentmath8mig
rename ASR Lev3_percentmath8mig
rename ASS Lev4_percentmath8mig
rename AST Lev5_percentmath8mig

rename ASU Lev1_percentela8mil // NEWNEWNEW
rename ASV Lev2_percentela8mil
rename ASW Lev3_percentela8mil
rename ASX Lev4_percentela8mil
rename ASY Lev5_percentela8mil
rename ASZ Lev1_percentmath8mil
rename ATA Lev2_percentmath8mil
rename ATB Lev3_percentmath8mil
rename ATC Lev4_percentmath8mil
rename ATD Lev5_percentmath8mil



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

gen SchYear = "2021-22"

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

merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2021_School.dta"
drop if _merge == 2
drop _merge




**** Appending

append using "${output}/IL_AssmtData_2022_sci.dta"

replace StateAbbrev = "IL" if DataLevel == 1
replace State = 17 if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1
replace StateAssignedDistID = "" if DataLevel == 1

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Y"
gen Flag_CutScoreChange_soc = ""

drop State_leaid seasch

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

// gen Flag_AssmtNameChange = "N"
// gen Flag_CutScoreChange_ELA = "N"
// gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
// gen Flag_CutScoreChange_oth = "Y"
// order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
//

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2022_1.dta", replace

export delimited using "${output}/csv/IL_AssmtData_2022_1.csv", replace


////////// EDFACTS ADDENDUM


use "${output}/IL_AssmtData_2022_1.dta", clear

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2021/edfactscount2021districtillinois.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2021/edfactspart2021districtillinois.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2021/edfactscount2021schoolillinois.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop STNAM-_merge

merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts}/2021/edfactspart2021schoolillinois.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop STNAM-_merge

preserve
keep if DataLevel == 2
destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
collapse (sum) StudentSubGroup_TotalTested2, by(StudentSubGroup GradeLevel Subject)
gen DataLevel = 1
save "IL_AssmtData_2022_State.dta", replace
restore

merge m:1 DataLevel StudentSubGroup GradeLevel Subject using "IL_AssmtData_2022_State.dta"
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

save "${output}/IL_AssmtData_2022.dta", replace

export delimited using "${output}/csv/IL_AssmtData_2022.csv", replace



