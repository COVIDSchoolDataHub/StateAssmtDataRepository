clear
set more off

global output "/Users/maggie/Desktop/Illinois/Output"
global NCES "/Users/maggie/Desktop/Illinois/NCES/Cleaned"

cd "/Users/maggie/Desktop/Illinois"




**** Sci

*** Sci AvgScaleScore

use "${output}/IL_AssmtData_2018_sci_AvgScaleScore_5.dta", clear
append using "${output}/IL_AssmtData_2018_sci_AvgScaleScore_8.dta"

** Dropping extra variables

drop County City

** Rename existing variables

rename RCDTS StateAssignedSchID
rename DIST StateAssignedDistID
rename SchoolorDistrictName SchName
rename Grade GradeLevel
rename StateDistrictSchool DataLevel
rename AverageScaleScore AvgScaleScore

** Generating new variables

replace GradeLevel = "G" + GradeLevel

gen StudentSubGroup = "All Students"

tostring AvgScaleScore, replace
replace AvgScaleScore = "*" if AvgScaleScore == "."

save "${output}/IL_AssmtData_2018_sci_AvgScaleScore.dta", replace



*** Sci Participation

use "${output}/IL_AssmtData_2018_sci_Participation_5.dta", clear
append using "${output}/IL_AssmtData_2018_sci_Participation_8.dta"

** Dropping extra variables

drop County City Migrant IEP NotIEP

** Rename existing variables

rename RCDTS StateAssignedSchID
rename DIST StateAssignedDistID
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

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"

replace GradeLevel = "G" + GradeLevel

destring ParticipationRate, replace
replace ParticipationRate = ParticipationRate/100
tostring ParticipationRate, replace force
replace ParticipationRate = "*" if ParticipationRate == "."

save "${output}/IL_AssmtData_2018_sci_Participation.dta", replace



*** Sci Performance Levels

use "${output}/IL_AssmtData_2018_sci_5.dta", clear
append using "${output}/IL_AssmtData_2018_sci_8.dta"

** Dropping extra variables

drop County City Migrant IEP NotIEP

** Rename existing variables

rename RCDTS StateAssignedSchID
rename DIST StateAssignedDistID
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

** Generating new variables

gen SchYear = "2017-18"

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

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"

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

merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${output}/IL_AssmtData_2018_sci_AvgScaleScore.dta"
drop _merge

replace AvgScaleScore = "--" if AvgScaleScore == ""

merge 1:1 DataLevel StateAssignedSchID GradeLevel StudentSubGroup using "${output}/IL_AssmtData_2018_sci_Participation.dta"
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

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES}/NCES_2017_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2017_School.dta"
drop if _merge == 2
drop _merge

save "${output}/IL_AssmtData_2018_sci.dta", replace




**** ELA & Math

use "${output}/IL_AssmtData_2018_all.dta", clear

** Dropping extra variables

drop County City DistrictType DistrictSize SchoolType GradesServed IEP* NonIEP* DW DX DY DZ EB EC ED EE EG EH EI EJ JK JL JM JN JO JP JQ JR JS JT JU JV JW JX JY JZ KA KB KC KD PE PF PG PH PI PJ PK PL PM PN PO PP PQ PR PS PT PU PV PW PX UY UZ VA VB VC VD VE VF VG VH VI VJ VK VL VM VN VO VP VQ VR AAS AAT AAU AAV AAW AAX AAY AAZ ABA ABB ABC ABD ABE ABF ABG ABH ABI ABJ ABK ABL AGM AGN AGO AGP AGQ AGR AGS AGT AGU AGV AGW AGX AGY AGZ AHA AHB AHC AHD AHE AHF

** Rename existing variables

rename RCDTS StateAssignedSchID
rename Type DataLevel
rename SchoolName SchName
rename District DistName

rename AllstudentsPARCCELALevel1 Lev1_percentela3All
rename AllstudentsPARCCELALevel2 Lev2_percentela3All
rename AllstudentsPARCCELALevel3 Lev3_percentela3All
rename AllstudentsPARCCELALevel4 Lev4_percentela3All
rename AllstudentsPARCCELALevel5 Lev5_percentela3All
rename AllstudentsPARCCMathematicsL Lev1_percentmath3All
rename Q Lev2_percentmath3All
rename R Lev3_percentmath3All
rename S Lev4_percentmath3All
rename T Lev5_percentmath3All

rename MalestudentsPARCCELALevel1 Lev1_percentela3male
rename MalestudentsPARCCELALevel2 Lev2_percentela3male
rename MalestudentsPARCCELALevel3 Lev3_percentela3male
rename MalestudentsPARCCELALevel4 Lev4_percentela3male
rename MalestudentsPARCCELALevel5 Lev5_percentela3male
rename MalestudentsPARCCMathematics Lev1_percentmath3male
rename AA Lev2_percentmath3male
rename AB Lev3_percentmath3male
rename AC Lev4_percentmath3male
rename AD Lev5_percentmath3male

rename FemalestudentsPARCCELALevel Lev1_percentela3female
rename AF Lev2_percentela3female
rename AG Lev3_percentela3female
rename AH Lev4_percentela3female
rename AI Lev5_percentela3female
rename FemalestudentsPARCCMathematic Lev1_percentmath3female
rename AK Lev2_percentmath3female
rename AL Lev3_percentmath3female
rename AM Lev4_percentmath3female
rename AN Lev5_percentmath3female

rename WhitestudentsPARCCELALevel1 Lev1_percentela3white
rename WhitestudentsPARCCELALevel2 Lev2_percentela3white
rename WhitestudentsPARCCELALevel3 Lev3_percentela3white
rename WhitestudentsPARCCELALevel4 Lev4_percentela3white
rename WhitestudentsPARCCELALevel5 Lev5_percentela3white
rename WhitestudentsPARCCMathematics Lev1_percentmath3white
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

rename HispanicorLatinostudentsPARC Lev1_percentela3hisp
rename BJ Lev2_percentela3hisp
rename BK Lev3_percentela3hisp
rename BL Lev4_percentela3hisp
rename BM Lev5_percentela3hisp
rename BN Lev1_percentmath3hisp
rename BO Lev2_percentmath3hisp
rename BP Lev3_percentmath3hisp
rename BQ Lev4_percentmath3hisp
rename BR Lev5_percentmath3hisp

rename AsianstudentsPARCCELALevel1 Lev1_percentela3asian
rename AsianstudentsPARCCELALevel2 Lev2_percentela3asian
rename AsianstudentsPARCCELALevel3 Lev3_percentela3asian
rename AsianstudentsPARCCELALevel4 Lev4_percentela3asian
rename AsianstudentsPARCCELALevel5 Lev5_percentela3asian
rename AsianstudentsPARCCMathematics Lev1_percentmath3asian
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

rename TwoorMoreRacestudentsPARCC Lev1_percentela3two
rename CX Lev2_percentela3two
rename CY Lev3_percentela3two
rename CZ Lev4_percentela3two
rename DA Lev5_percentela3two
rename DB Lev1_percentmath3two
rename DC Lev2_percentmath3two
rename DD Lev3_percentmath3two
rename DE Lev4_percentmath3two
rename DF Lev5_percentmath3two

rename ELstudentsPARCCELALevel1 Lev1_percentela3learner
rename ELstudentsPARCCELALevel2 Lev2_percentela3learner
rename ELstudentsPARCCELALevel3 Lev3_percentela3learner
rename ELstudentsPARCCELALevel4 Lev4_percentela3learner
rename ELstudentsPARCCELALevel5 Lev5_percentela3learner
rename ELstudentsPARCCMathematicsLe Lev1_percentmath3learner
rename DM Lev2_percentmath3learner
rename DN Lev3_percentmath3learner
rename DO Lev4_percentmath3learner
rename DP Lev5_percentmath3learner

rename LowIncomestudentsPARCCELALe Lev1_percentela3dis
rename EL Lev2_percentela3dis
rename EM Lev3_percentela3dis
rename EN Lev4_percentela3dis
rename EO Lev5_percentela3dis
rename LowIncomestudentsPARCCMathem Lev1_percentmath3dis
rename EQ Lev2_percentmath3dis
rename ER Lev3_percentmath3dis
rename ES Lev4_percentmath3dis
rename ET Lev5_percentmath3dis

rename NonLowIncomestudentsPARCCEL Lev1_percentela3notdis
rename EV Lev2_percentela3notdis
rename EW Lev3_percentela3notdis
rename EX Lev4_percentela3notdis
rename EY Lev5_percentela3notdis
rename NonLowIncomestudentsPARCCMa Lev1_percentmath3notdis
rename FA Lev2_percentmath3notdis
rename FB Lev3_percentmath3notdis
rename FC Lev4_percentmath3notdis
rename FD Lev5_percentmath3notdis


rename FE Lev1_percentela4All
rename FF Lev2_percentela4All
rename FG Lev3_percentela4All
rename FH Lev4_percentela4All
rename FI Lev5_percentela4All
rename FJ Lev1_percentmath4All
rename FK Lev2_percentmath4All
rename FL Lev3_percentmath4All
rename FM Lev4_percentmath4All
rename FN Lev5_percentmath4All

rename FO Lev1_percentela4male
rename FP Lev2_percentela4male
rename FQ Lev3_percentela4male
rename FR Lev4_percentela4male
rename FS Lev5_percentela4male
rename FT Lev1_percentmath4male
rename FU Lev2_percentmath4male
rename FV Lev3_percentmath4male
rename FW Lev4_percentmath4male
rename FX Lev5_percentmath4male

rename FY Lev1_percentela4female
rename FZ Lev2_percentela4female
rename GA Lev3_percentela4female
rename GB Lev4_percentela4female
rename GC Lev5_percentela4female
rename GD Lev1_percentmath4female
rename GE Lev2_percentmath4female
rename GF Lev3_percentmath4female
rename GG Lev4_percentmath4female
rename GH Lev5_percentmath4female

rename GI Lev1_percentela4white
rename GJ Lev2_percentela4white
rename GK Lev3_percentela4white
rename GL Lev4_percentela4white
rename GM Lev5_percentela4white
rename GN Lev1_percentmath4white
rename GO Lev2_percentmath4white
rename GP Lev3_percentmath4white
rename GQ Lev4_percentmath4white
rename GR Lev5_percentmath4white

rename GS Lev1_percentela4black
rename GT Lev2_percentela4black
rename GU Lev3_percentela4black
rename GV Lev4_percentela4black
rename GW Lev5_percentela4black
rename GX Lev1_percentmath4black
rename GY Lev2_percentmath4black
rename GZ Lev3_percentmath4black
rename HA Lev4_percentmath4black
rename HB Lev5_percentmath4black

rename HC Lev1_percentela4hisp
rename HD Lev2_percentela4hisp
rename HE Lev3_percentela4hisp
rename HF Lev4_percentela4hisp
rename HG Lev5_percentela4hisp
rename HH Lev1_percentmath4hisp
rename HI Lev2_percentmath4hisp
rename HJ Lev3_percentmath4hisp
rename HK Lev4_percentmath4hisp
rename HL Lev5_percentmath4hisp

rename HM Lev1_percentela4asian
rename HN Lev2_percentela4asian
rename HO Lev3_percentela4asian
rename HP Lev4_percentela4asian
rename HQ Lev5_percentela4asian
rename HR Lev1_percentmath4asian
rename HS Lev2_percentmath4asian
rename HT Lev3_percentmath4asian
rename HU Lev4_percentmath4asian
rename HV Lev5_percentmath4asian

rename HW Lev1_percentela4hawaii
rename HX Lev2_percentela4hawaii
rename HY Lev3_percentela4hawaii
rename HZ Lev4_percentela4hawaii
rename IA Lev5_percentela4hawaii
rename IB Lev1_percentmath4hawaii
rename IC Lev2_percentmath4hawaii
rename ID Lev3_percentmath4hawaii
rename IE Lev4_percentmath4hawaii
rename IF Lev5_percentmath4hawaii

rename IG Lev1_percentela4native
rename IH Lev2_percentela4native
rename II Lev3_percentela4native
rename IJ Lev4_percentela4native
rename IK Lev5_percentela4native
rename IL Lev1_percentmath4native
rename IM Lev2_percentmath4native
rename IN Lev3_percentmath4native
rename IO Lev4_percentmath4native
rename IP Lev5_percentmath4native

rename IQ Lev1_percentela4two
rename IR Lev2_percentela4two
rename IS Lev3_percentela4two
rename IT Lev4_percentela4two
rename IU Lev5_percentela4two
rename IV Lev1_percentmath4two
rename IW Lev2_percentmath4two
rename IX Lev3_percentmath4two
rename IY Lev4_percentmath4two
rename IZ Lev5_percentmath4two

rename JA Lev1_percentela4learner
rename JB Lev2_percentela4learner
rename JC Lev3_percentela4learner
rename JD Lev4_percentela4learner
rename JE Lev5_percentela4learner
rename JF Lev1_percentmath4learner
rename JG Lev2_percentmath4learner
rename JH Lev3_percentmath4learner
rename JI Lev4_percentmath4learner
rename JJ Lev5_percentmath4learner

rename KE Lev1_percentela4dis
rename KF Lev2_percentela4dis
rename KG Lev3_percentela4dis
rename KH Lev4_percentela4dis
rename KI Lev5_percentela4dis
rename KJ Lev1_percentmath4dis
rename KK Lev2_percentmath4dis
rename KL Lev3_percentmath4dis
rename KM Lev4_percentmath4dis
rename KN Lev5_percentmath4dis

rename KO Lev1_percentela4notdis
rename KP Lev2_percentela4notdis
rename KQ Lev3_percentela4notdis
rename KR Lev4_percentela4notdis
rename KS Lev5_percentela4notdis
rename KT Lev1_percentmath4notdis
rename KU Lev2_percentmath4notdis
rename KV Lev3_percentmath4notdis
rename KW Lev4_percentmath4notdis
rename KX Lev5_percentmath4notdis


rename KY Lev1_percentela5All
rename KZ Lev2_percentela5All
rename LA Lev3_percentela5All
rename LB Lev4_percentela5All
rename LC Lev5_percentela5All
rename LD Lev1_percentmath5All
rename LE Lev2_percentmath5All
rename LF Lev3_percentmath5All
rename LG Lev4_percentmath5All
rename LH Lev5_percentmath5All

rename LI Lev1_percentela5male
rename LJ Lev2_percentela5male
rename LK Lev3_percentela5male
rename LL Lev4_percentela5male
rename LM Lev5_percentela5male
rename LN Lev1_percentmath5male
rename LO Lev2_percentmath5male
rename LP Lev3_percentmath5male
rename LQ Lev4_percentmath5male
rename LR Lev5_percentmath5male

rename LS Lev1_percentela5female
rename LT Lev2_percentela5female
rename LU Lev3_percentela5female
rename LV Lev4_percentela5female
rename LW Lev5_percentela5female
rename LX Lev1_percentmath5female
rename LY Lev2_percentmath5female
rename LZ Lev3_percentmath5female
rename MA Lev4_percentmath5female
rename MB Lev5_percentmath5female

rename MC Lev1_percentela5white
rename MD Lev2_percentela5white
rename ME Lev3_percentela5white
rename MF Lev4_percentela5white
rename MG Lev5_percentela5white
rename MH Lev1_percentmath5white
rename MI Lev2_percentmath5white
rename MJ Lev3_percentmath5white
rename MK Lev4_percentmath5white
rename ML Lev5_percentmath5white

rename MM Lev1_percentela5black
rename MN Lev2_percentela5black
rename MO Lev3_percentela5black
rename MP Lev4_percentela5black
rename MQ Lev5_percentela5black
rename MR Lev1_percentmath5black
rename MS Lev2_percentmath5black
rename MT Lev3_percentmath5black
rename MU Lev4_percentmath5black
rename MV Lev5_percentmath5black

rename MW Lev1_percentela5hisp
rename MX Lev2_percentela5hisp
rename MY Lev3_percentela5hisp
rename MZ Lev4_percentela5hisp
rename NA Lev5_percentela5hisp
rename NB Lev1_percentmath5hisp
rename NC Lev2_percentmath5hisp
rename ND Lev3_percentmath5hisp
rename NE Lev4_percentmath5hisp
rename NF Lev5_percentmath5hisp

rename NG Lev1_percentela5asian
rename NH Lev2_percentela5asian
rename NI Lev3_percentela5asian
rename NJ Lev4_percentela5asian
rename NK Lev5_percentela5asian
rename NL Lev1_percentmath5asian
rename NM Lev2_percentmath5asian
rename NN Lev3_percentmath5asian
rename NO Lev4_percentmath5asian
rename NP Lev5_percentmath5asian

rename NQ Lev1_percentela5hawaii
rename NR Lev2_percentela5hawaii
rename NS Lev3_percentela5hawaii
rename NT Lev4_percentela5hawaii
rename NU Lev5_percentela5hawaii
rename NV Lev1_percentmath5hawaii
rename NW Lev2_percentmath5hawaii
rename NX Lev3_percentmath5hawaii
rename NY Lev4_percentmath5hawaii
rename NZ Lev5_percentmath5hawaii

rename OA Lev1_percentela5native
rename OB Lev2_percentela5native
rename OC Lev3_percentela5native
rename OD Lev4_percentela5native
rename OE Lev5_percentela5native
rename OF Lev1_percentmath5native
rename OG Lev2_percentmath5native
rename OH Lev3_percentmath5native
rename OI Lev4_percentmath5native
rename OJ Lev5_percentmath5native

rename OK Lev1_percentela5two
rename OL Lev2_percentela5two
rename OM Lev3_percentela5two
rename ON Lev4_percentela5two
rename OO Lev5_percentela5two
rename OP Lev1_percentmath5two
rename OQ Lev2_percentmath5two
rename OR Lev3_percentmath5two
rename OS Lev4_percentmath5two
rename OT Lev5_percentmath5two

rename OU Lev1_percentela5learner
rename OV Lev2_percentela5learner
rename OW Lev3_percentela5learner
rename OX Lev4_percentela5learner
rename OY Lev5_percentela5learner
rename OZ Lev1_percentmath5learner
rename PA Lev2_percentmath5learner
rename PB Lev3_percentmath5learner
rename PC Lev4_percentmath5learner
rename PD Lev5_percentmath5learner

rename PY Lev1_percentela5dis
rename PZ Lev2_percentela5dis
rename QA Lev3_percentela5dis
rename QB Lev4_percentela5dis
rename QC Lev5_percentela5dis
rename QD Lev1_percentmath5dis
rename QE Lev2_percentmath5dis
rename QF Lev3_percentmath5dis
rename QG Lev4_percentmath5dis
rename QH Lev5_percentmath5dis

rename QI Lev1_percentela5notdis
rename QJ Lev2_percentela5notdis
rename QK Lev3_percentela5notdis
rename QL Lev4_percentela5notdis
rename QM Lev5_percentela5notdis
rename QN Lev1_percentmath5notdis
rename QO Lev2_percentmath5notdis
rename QP Lev3_percentmath5notdis
rename QQ Lev4_percentmath5notdis
rename QR Lev5_percentmath5notdis


rename QS Lev1_percentela6All
rename QT Lev2_percentela6All
rename QU Lev3_percentela6All
rename QV Lev4_percentela6All
rename QW Lev5_percentela6All
rename QX Lev1_percentmath6All
rename QY Lev2_percentmath6All
rename QZ Lev3_percentmath6All
rename RA Lev4_percentmath6All
rename RB Lev5_percentmath6All

rename RC Lev1_percentela6male
rename RD Lev2_percentela6male
rename RE Lev3_percentela6male
rename RF Lev4_percentela6male
rename RG Lev5_percentela6male
rename RH Lev1_percentmath6male
rename RI Lev2_percentmath6male
rename RJ Lev3_percentmath6male
rename RK Lev4_percentmath6male
rename RL Lev5_percentmath6male

rename RM Lev1_percentela6female
rename RN Lev2_percentela6female
rename RO Lev3_percentela6female
rename RP Lev4_percentela6female
rename RQ Lev5_percentela6female
rename RR Lev1_percentmath6female
rename RS Lev2_percentmath6female
rename RT Lev3_percentmath6female
rename RU Lev4_percentmath6female
rename RV Lev5_percentmath6female

rename RW Lev1_percentela6white
rename RX Lev2_percentela6white
rename RY Lev3_percentela6white
rename RZ Lev4_percentela6white
rename SA Lev5_percentela6white
rename SB Lev1_percentmath6white
rename SC Lev2_percentmath6white
rename SD Lev3_percentmath6white
rename SE Lev4_percentmath6white
rename SF Lev5_percentmath6white

rename SG Lev1_percentela6black
rename SH Lev2_percentela6black
rename SI Lev3_percentela6black
rename SJ Lev4_percentela6black
rename SK Lev5_percentela6black
rename SL Lev1_percentmath6black
rename SM Lev2_percentmath6black
rename SN Lev3_percentmath6black
rename SO Lev4_percentmath6black
rename SP Lev5_percentmath6black

rename SQ Lev1_percentela6hisp
rename SR Lev2_percentela6hisp
rename SS Lev3_percentela6hisp
rename ST Lev4_percentela6hisp
rename SU Lev5_percentela6hisp
rename SV Lev1_percentmath6hisp
rename SW Lev2_percentmath6hisp
rename SX Lev3_percentmath6hisp
rename SY Lev4_percentmath6hisp
rename SZ Lev5_percentmath6hisp

rename TA Lev1_percentela6asian
rename TB Lev2_percentela6asian
rename TC Lev3_percentela6asian
rename TD Lev4_percentela6asian
rename TE Lev5_percentela6asian
rename TF Lev1_percentmath6asian
rename TG Lev2_percentmath6asian
rename TH Lev3_percentmath6asian
rename TI Lev4_percentmath6asian
rename TJ Lev5_percentmath6asian

rename TK Lev1_percentela6hawaii
rename TL Lev2_percentela6hawaii
rename TM Lev3_percentela6hawaii
rename TN Lev4_percentela6hawaii
rename TO Lev5_percentela6hawaii
rename TP Lev1_percentmath6hawaii
rename TQ Lev2_percentmath6hawaii
rename TR Lev3_percentmath6hawaii
rename TS Lev4_percentmath6hawaii
rename TT Lev5_percentmath6hawaii

rename TU Lev1_percentela6native
rename TV Lev2_percentela6native
rename TW Lev3_percentela6native
rename TX Lev4_percentela6native
rename TY Lev5_percentela6native
rename TZ Lev1_percentmath6native
rename UA Lev2_percentmath6native
rename UB Lev3_percentmath6native
rename UC Lev4_percentmath6native
rename UD Lev5_percentmath6native

rename UE Lev1_percentela6two
rename UF Lev2_percentela6two
rename UG Lev3_percentela6two
rename UH Lev4_percentela6two
rename UI Lev5_percentela6two
rename UJ Lev1_percentmath6two
rename UK Lev2_percentmath6two
rename UL Lev3_percentmath6two
rename UM Lev4_percentmath6two
rename UN Lev5_percentmath6two

rename UO Lev1_percentela6learner
rename UP Lev2_percentela6learner
rename UQ Lev3_percentela6learner
rename UR Lev4_percentela6learner
rename US Lev5_percentela6learner
rename UT Lev1_percentmath6learner
rename UU Lev2_percentmath6learner
rename UV Lev3_percentmath6learner
rename UW Lev4_percentmath6learner
rename UX Lev5_percentmath6learner

rename VS Lev1_percentela6dis
rename VT Lev2_percentela6dis
rename VU Lev3_percentela6dis
rename VV Lev4_percentela6dis
rename VW Lev5_percentela6dis
rename VX Lev1_percentmath6dis
rename VY Lev2_percentmath6dis
rename VZ Lev3_percentmath6dis
rename WA Lev4_percentmath6dis
rename WB Lev5_percentmath6dis

rename WC Lev1_percentela6notdis
rename WD Lev2_percentela6notdis
rename WE Lev3_percentela6notdis
rename WF Lev4_percentela6notdis
rename WG Lev5_percentela6notdis
rename WH Lev1_percentmath6notdis
rename WI Lev2_percentmath6notdis
rename WJ Lev3_percentmath6notdis
rename WK Lev4_percentmath6notdis
rename WL Lev5_percentmath6notdis


rename WM Lev1_percentela7All
rename WN Lev2_percentela7All
rename WO Lev3_percentela7All
rename WP Lev4_percentela7All
rename WQ Lev5_percentela7All
rename WR Lev1_percentmath7All
rename WS Lev2_percentmath7All
rename WT Lev3_percentmath7All
rename WU Lev4_percentmath7All
rename WV Lev5_percentmath7All

rename WW Lev1_percentela7male
rename WX Lev2_percentela7male
rename WY Lev3_percentela7male
rename WZ Lev4_percentela7male
rename XA Lev5_percentela7male
rename XB Lev1_percentmath7male
rename XC Lev2_percentmath7male
rename XD Lev3_percentmath7male
rename XE Lev4_percentmath7male
rename XF Lev5_percentmath7male

rename XG Lev1_percentela7female
rename XH Lev2_percentela7female
rename XI Lev3_percentela7female
rename XJ Lev4_percentela7female
rename XK Lev5_percentela7female
rename XL Lev1_percentmath7female
rename XM Lev2_percentmath7female
rename XN Lev3_percentmath7female
rename XO Lev4_percentmath7female
rename XP Lev5_percentmath7female

rename XQ Lev1_percentela7white
rename XR Lev2_percentela7white
rename XS Lev3_percentela7white
rename XT Lev4_percentela7white
rename XU Lev5_percentela7white
rename XV Lev1_percentmath7white
rename XW Lev2_percentmath7white
rename XX Lev3_percentmath7white
rename XY Lev4_percentmath7white
rename XZ Lev5_percentmath7white

rename YA Lev1_percentela7black
rename YB Lev2_percentela7black
rename YC Lev3_percentela7black
rename YD Lev4_percentela7black
rename YE Lev5_percentela7black
rename YF Lev1_percentmath7black
rename YG Lev2_percentmath7black
rename YH Lev3_percentmath7black
rename YI Lev4_percentmath7black
rename YJ Lev5_percentmath7black

rename YK Lev1_percentela7hisp
rename YL Lev2_percentela7hisp
rename YM Lev3_percentela7hisp
rename YN Lev4_percentela7hisp
rename YO Lev5_percentela7hisp
rename YP Lev1_percentmath7hisp
rename YQ Lev2_percentmath7hisp
rename YR Lev3_percentmath7hisp
rename YS Lev4_percentmath7hisp
rename YT Lev5_percentmath7hisp

rename YU Lev1_percentela7asian
rename YV Lev2_percentela7asian
rename YW Lev3_percentela7asian
rename YX Lev4_percentela7asian
rename YY Lev5_percentela7asian
rename YZ Lev1_percentmath7asian
rename ZA Lev2_percentmath7asian
rename ZB Lev3_percentmath7asian
rename ZC Lev4_percentmath7asian
rename ZD Lev5_percentmath7asian

rename ZE Lev1_percentela7hawaii
rename ZF Lev2_percentela7hawaii
rename ZG Lev3_percentela7hawaii
rename ZH Lev4_percentela7hawaii
rename ZI Lev5_percentela7hawaii
rename ZJ Lev1_percentmath7hawaii
rename ZK Lev2_percentmath7hawaii
rename ZL Lev3_percentmath7hawaii
rename ZM Lev4_percentmath7hawaii
rename ZN Lev5_percentmath7hawaii

rename ZO Lev1_percentela7native
rename ZP Lev2_percentela7native
rename ZQ Lev3_percentela7native
rename ZR Lev4_percentela7native
rename ZS Lev5_percentela7native
rename ZT Lev1_percentmath7native
rename ZU Lev2_percentmath7native
rename ZV Lev3_percentmath7native
rename ZW Lev4_percentmath7native
rename ZX Lev5_percentmath7native

rename ZY Lev1_percentela7two
rename ZZ Lev2_percentela7two
rename AAA Lev3_percentela7two
rename AAB Lev4_percentela7two
rename AAC Lev5_percentela7two
rename AAD Lev1_percentmath7two
rename AAE Lev2_percentmath7two
rename AAF Lev3_percentmath7two
rename AAG Lev4_percentmath7two
rename AAH Lev5_percentmath7two

rename AAI Lev1_percentela7learner
rename AAJ Lev2_percentela7learner
rename AAK Lev3_percentela7learner
rename AAL Lev4_percentela7learner
rename AAM Lev5_percentela7learner
rename AAN Lev1_percentmath7learner
rename AAO Lev2_percentmath7learner
rename AAP Lev3_percentmath7learner
rename AAQ Lev4_percentmath7learner
rename AAR Lev5_percentmath7learner

rename ABM Lev1_percentela7dis
rename ABN Lev2_percentela7dis
rename ABO Lev3_percentela7dis
rename ABP Lev4_percentela7dis
rename ABQ Lev5_percentela7dis
rename ABR Lev1_percentmath7dis
rename ABS Lev2_percentmath7dis
rename ABT Lev3_percentmath7dis
rename ABU Lev4_percentmath7dis
rename ABV Lev5_percentmath7dis

rename ABW Lev1_percentela7notdis
rename ABX Lev2_percentela7notdis
rename ABY Lev3_percentela7notdis
rename ABZ Lev4_percentela7notdis
rename ACA Lev5_percentela7notdis
rename ACB Lev1_percentmath7notdis
rename ACC Lev2_percentmath7notdis
rename ACD Lev3_percentmath7notdis
rename ACE Lev4_percentmath7notdis
rename ACF Lev5_percentmath7notdis


rename ACG Lev1_percentela8All
rename ACH Lev2_percentela8All
rename ACI Lev3_percentela8All
rename ACJ Lev4_percentela8All
rename ACK Lev5_percentela8All
rename ACL Lev1_percentmath8All
rename ACM Lev2_percentmath8All
rename ACN Lev3_percentmath8All
rename ACO Lev4_percentmath8All
rename ACP Lev5_percentmath8All

rename ACQ Lev1_percentela8male
rename ACR Lev2_percentela8male
rename ACS Lev3_percentela8male
rename ACT Lev4_percentela8male
rename ACU Lev5_percentela8male
rename ACV Lev1_percentmath8male
rename ACW Lev2_percentmath8male
rename ACX Lev3_percentmath8male
rename ACY Lev4_percentmath8male
rename ACZ Lev5_percentmath8male

rename ADA Lev1_percentela8female
rename ADB Lev2_percentela8female
rename ADC Lev3_percentela8female
rename ADD Lev4_percentela8female
rename ADE Lev5_percentela8female
rename ADF Lev1_percentmath8female
rename ADG Lev2_percentmath8female
rename ADH Lev3_percentmath8female
rename ADI Lev4_percentmath8female
rename ADJ Lev5_percentmath8female

rename ADK Lev1_percentela8white
rename ADL Lev2_percentela8white
rename ADM Lev3_percentela8white
rename ADN Lev4_percentela8white
rename ADO Lev5_percentela8white
rename ADP Lev1_percentmath8white
rename ADQ Lev2_percentmath8white
rename ADR Lev3_percentmath8white
rename ADS Lev4_percentmath8white
rename ADT Lev5_percentmath8white

rename ADU Lev1_percentela8black
rename ADV Lev2_percentela8black
rename ADW Lev3_percentela8black
rename ADX Lev4_percentela8black
rename ADY Lev5_percentela8black
rename ADZ Lev1_percentmath8black
rename AEA Lev2_percentmath8black
rename AEB Lev3_percentmath8black
rename AEC Lev4_percentmath8black
rename AED Lev5_percentmath8black

rename AEE Lev1_percentela8hisp
rename AEF Lev2_percentela8hisp
rename AEG Lev3_percentela8hisp
rename AEH Lev4_percentela8hisp
rename AEI Lev5_percentela8hisp
rename AEJ Lev1_percentmath8hisp
rename AEK Lev2_percentmath8hisp
rename AEL Lev3_percentmath8hisp
rename AEM Lev4_percentmath8hisp
rename AEN Lev5_percentmath8hisp

rename AEO Lev1_percentela8asian
rename AEP Lev2_percentela8asian
rename AEQ Lev3_percentela8asian
rename AER Lev4_percentela8asian
rename AES Lev5_percentela8asian
rename AET Lev1_percentmath8asian
rename AEU Lev2_percentmath8asian
rename AEV Lev3_percentmath8asian
rename AEW Lev4_percentmath8asian
rename AEX Lev5_percentmath8asian

rename AEY Lev1_percentela8hawaii
rename AEZ Lev2_percentela8hawaii
rename AFA Lev3_percentela8hawaii
rename AFB Lev4_percentela8hawaii
rename AFC Lev5_percentela8hawaii
rename AFD Lev1_percentmath8hawaii
rename AFE Lev2_percentmath8hawaii
rename AFF Lev3_percentmath8hawaii
rename AFG Lev4_percentmath8hawaii
rename AFH Lev5_percentmath8hawaii

rename AFI Lev1_percentela8native
rename AFJ Lev2_percentela8native
rename AFK Lev3_percentela8native
rename AFL Lev4_percentela8native
rename AFM Lev5_percentela8native
rename AFN Lev1_percentmath8native
rename AFO Lev2_percentmath8native
rename AFP Lev3_percentmath8native
rename AFQ Lev4_percentmath8native
rename AFR Lev5_percentmath8native

rename AFS Lev1_percentela8two
rename AFT Lev2_percentela8two
rename AFU Lev3_percentela8two
rename AFV Lev4_percentela8two
rename AFW Lev5_percentela8two
rename AFX Lev1_percentmath8two
rename AFY Lev2_percentmath8two
rename AFZ Lev3_percentmath8two
rename AGA Lev4_percentmath8two
rename AGB Lev5_percentmath8two

rename AGC Lev1_percentela8learner
rename AGD Lev2_percentela8learner
rename AGE Lev3_percentela8learner
rename AGF Lev4_percentela8learner
rename AGG Lev5_percentela8learner
rename AGH Lev1_percentmath8learner
rename AGI Lev2_percentmath8learner
rename AGJ Lev3_percentmath8learner
rename AGK Lev4_percentmath8learner
rename AGL Lev5_percentmath8learner

rename AHG Lev1_percentela8dis
rename AHH Lev2_percentela8dis
rename AHI Lev3_percentela8dis
rename AHJ Lev4_percentela8dis
rename AHK Lev5_percentela8dis
rename AHL Lev1_percentmath8dis
rename AHM Lev2_percentmath8dis
rename AHN Lev3_percentmath8dis
rename AHO Lev4_percentmath8dis
rename AHP Lev5_percentmath8dis

rename AHQ Lev1_percentela8notdis
rename AHR Lev2_percentela8notdis
rename AHS Lev3_percentela8notdis
rename AHT Lev4_percentela8notdis
rename AHU Lev5_percentela8notdis
rename AHV Lev1_percentmath8notdis
rename AHW Lev2_percentmath8notdis
rename AHX Lev3_percentmath8notdis
rename AHY Lev4_percentmath8notdis
rename AHZ Lev5_percentmath8notdis

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
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "two"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "hisp"
replace StudentSubGroup = "Female" if StudentSubGroup == "female"
replace StudentSubGroup = "Male" if StudentSubGroup == "male"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "notdis"

gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"

** Generating new variables

gen SchYear = "2017-18"

gen AssmtName = "PARCC"
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

gen StateAssignedDistID = substr(StateAssignedSchID,6,3)

gen State_leaid = StateAssignedSchID
replace State_leaid = substr(State_leaid,1,11)
replace State_leaid = "IL-" + substr(State_leaid,1,2) + "-" + substr(State_leaid,3,3) + "-" + substr(State_leaid,6,4) + "-" + substr(State_leaid,10,2)
replace StateAssignedSchID = "" if DataLevel != 3

gen seasch = StateAssignedSchID
replace seasch = subinstr(seasch,"IL-","",.)
replace seasch = substr(seasch,1,9) + substr(seasch,12,4)
replace seasch = "" if DataLevel != 3

merge m:1 State_leaid using "${NCES}/NCES_2017_District.dta"
drop if _merge == 2
drop _merge

merge m:1 seasch using "${NCES}/NCES_2017_School.dta"
drop if _merge == 2
drop _merge




**** Appending

append using "${output}/IL_AssmtData_2018_sci.dta"

replace StateAbbrev = "IL" if DataLevel == 1
replace State = 17 if DataLevel == 1
replace StateFips = 17 if DataLevel == 1
replace State_leaid = "" if DataLevel == 1

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1

** Generating new variables

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/IL_AssmtData_2018.dta", replace

export delimited using "${output}/csv/IL_AssmtData_2018.csv", replace
