clear
set more off
clear
set more off
cd "/Volumes/T7/State Test Project/South Dakota"
cap log close
set trace off
log using Observe.log, replace
local Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
local Output "/Volumes/T7/State Test Project/South Dakota/Output"
local NCES_District "/Volumes/T7/State Test Project/NCES/District"
local NCES_School "/Volumes/T7/State Test Project/NCES/School"
local Stata_versions "/Volumes/T7/State Test Project/South Dakota/Stata .dta versions"

*Prepping Files**
//For this code to work, the first time it runs must be to convert all excel files to .dta format. Simply unhide the import and save commands and hide the use command.
*import excel "`Original'/SD_OriginalData_School2019.xlsx", firstrow case(preserve)
*save "`Stata_versions'/SD_OriginalData_School2019.dta", replace
clear
*import excel "`Original'/SD_OriginalData_State-District2019.xlsx", firstrow case(preserve)
*save "`Stata_versions'/SD_OriginalData_State-District2019.dta", replace
use "`Stata_versions'/SD_OriginalData_State-District2019.dta"
keep if School == "All Schools"
drop FV
foreach var of varlist _all {
	replace `var' = "--" if missing(`var')
}
//District & State Data
//Renaming in Prep for reshape
rename District DistName
rename B StateAssignedDistID
rename School SchName
drop D
drop EntitySort
drop SubgroupMeasu~e 
rename AllStudentsEn~t TotTestedAll_StudentsELA
rename H ProfCountAll_StudentsELA
rename I ProfPercAll_StudentsELA
rename AllStudentsMa~e TotTestedAll_StudentsMAT
rename K ProfCountAll_StudentsMAT
rename L ProfPercAll_StudentsMAT
rename AllStudentsSc~y TotTestedAll_StudentsSCI
rename N ProfCountAll_StudentsSCI
rename O ProfPercAll_StudentsSCI
rename EnglishLearn~ge TotTestedLearnersELA
rename Q ProfCountLearnersELA
rename R ProfPercLearnersELA
rename EnglishLearne~f TotTestedLearnersMAT
rename T ProfCountLearnersMAT
rename U ProfPercLearnersMAT
rename EnglishLearn~ie TotTestedLearnersSCI
rename W ProfCountLearnersSCI
rename X ProfPercLearnersSCI
rename EconomicallyD~s TotTestedDisadvELA
rename Z ProfCountDisadvELA
rename AA ProfPercDisadvELA
rename EconomicallyD~m TotTestedDisadvMAT
rename AC ProfCountDisadvMAT
rename AD ProfPercDisadvMAT
rename EconomicallyD~c TotTestedDisadvSCI
rename AF ProfCountDisadvSCI
rename AG ProfPercDisadvSCI
rename FemaleEnglish~f TotTestedFemELA
rename AI ProfCountFemELA
rename AJ ProfPercFemELA
rename FemaleMathema~a TotTestedFemMAT
rename AL ProfCountFemMAT
rename AM ProfPercFemMAT
rename FemaleScience~e TotTestedFemSCI
rename AO ProfCountFemSCI
rename AP ProfPercFemSCI
rename MaleEnglishLa~c TotTestedMaleELA
rename AR ProfCountMaleELA
rename AS ProfPercMaleELA
rename MaleMathemati~e TotTestedMaleMAT
rename AU ProfCountMaleMAT
rename AV ProfPercMaleMAT
rename MaleSciencePr~e TotTestedMaleSCI
rename AX ProfCountMaleSCI
rename AY ProfPercMaleSCI
rename HispanicLatin~e TotTestedLatinoELA
rename CB ProfCountLatinoELA
rename CC ProfPercLatinoELA
rename HispanicLatin~i TotTestedLatinoMAT
rename CE ProfCountLatinoMAT
rename CF ProfPercLatinoMAT
rename HispanicLatin~n TotTestedLatinoSCI
rename CH ProfCountLatinoSCI
rename CI ProfPercLatinoSCI
rename AmericanIndia~g TotTestedAmer_IndianELA
rename DL ProfCountAmer_IndianELA
rename DM ProfPercAmer_IndianELA
rename AmericanIndia~t TotTestedAmer_IndianMAT
rename DO ProfCountAmer_IndianMAT
rename DP ProfPercAmer_IndianMAT
rename AmericanIndia~i TotTestedAmer_IndianSCI
rename DR ProfCountAmer_IndianSCI
rename DS ProfPercAmer_IndianSCI
rename AsianEnglishL~i TotTestedAsianELA
rename DU ProfCountAsianELA
rename DV ProfPercAsianELA
rename AsianMathemat~t TotTestedAsianMAT
rename DX ProfCountAsianMAT
rename DY ProfPercAsianMAT
rename AsianScienceP~e TotTestedAsianSCI
rename EA ProfCountAsianSCI
rename EB ProfPercAsianSCI
rename BlackAfricanA~a TotTestedBlackELA
rename ED ProfCountBlackELA
rename EE ProfPercBlackELA
rename BlackAfricanA~c TotTestedBlackMAT
rename EG ProfCountBlackMAT
rename EH ProfPercBlackMAT
rename BlackAfricanA~r TotTestedBlackSCI
rename EJ ProfCountBlackSCI
rename EK ProfPercBlackSCI
rename NativeHawaiia~r TotTestedHawaiELA
rename EM ProfCountHawaiELA
rename EN ProfPercHawaiELA
rename EO TotTestedHawaiMAT
rename EP ProfCountHawaiMAT
rename EQ ProfPercHawaiMAT
rename ER TotTestedHawaiSCI
rename ES ProfCountHawaiSCI
rename ET ProfPercHawaiSCI
rename WhiteCaucasia~e TotTestedWhiteELA
rename EV ProfCountWhiteELA
rename EW ProfPercWhiteELA
rename WhiteCaucasia~i TotTestedWhiteMAT
rename EY ProfCountWhiteMAT
rename EZ ProfPercWhiteMAT
rename WhiteCaucasia~n TotTestedWhiteSCI
rename FB ProfCountWhiteSCI
rename FC ProfPercWhiteSCI
rename TwoorMoreRace~g TotTestedMultiELA
rename FE ProfCountMultiELA
rename FF ProfPercMultiELA
rename TwoorMoreRace~o TotTestedMultiMAT
rename FH ProfCountMultiMAT
rename FI ProfPercMultiMAT
rename TwoorMoreRace~i TotTestedMultiSCI
rename FK ProfCountMultiSCI
rename FL ProfPercMultiSCI

//Reshaping from wide to long
reshape long TotTested ProfCount ProfPerc, i(StateAssignedDistID) j(StudentSubGroup, string)

//Too Many variables
keep StateAssignedDistID StudentSubGroup DistName SchName TotTested ProfCount ProfPerc

//Merging NCES data
tempfile temp1
save "`temp1'", replace
clear
use "`NCES_District'/NCES_2018_District.dta"
keep if state_fips == 46
gen StateAssignedDistID = substr(state_leaid, strpos(state_leaid,"-")+1,6)
merge 1:m StateAssignedDistID using "`temp1'"
drop if _merge == 1

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if DistName == "All Districts"
replace DataLevel = "District" if DistName != "All Districts"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace StateAssignedDistID = "" if DataLevel ==1
//Subject
gen Subject = ""
replace Subject = "ela" if strpos(StudentSubGroup, "ELA") !=0
replace Subject = "math" if strpos(StudentSubGroup, "MAT") !=0
replace Subject = "sci" if strpos(StudentSubGroup, "SCI") !=0

//StudentSubGroup
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All_Students") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Amer_Indian") !=0
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "Disadv") !=0
replace StudentSubGroup = "Female" if strpos(StudentSubGroup, "Fem") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawai") !=0
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Latino") !=0
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "Learners") !=0
replace StudentSubGroup = "Male" if strpos(StudentSubGroup, "Male") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Multi") !=0
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "White") !=0

//renaming
rename TotTested StudentSubGroup_TotalTested
//GradeLevel
gen GradeLevel = "--"

//Levels and Proficiency
rename ProfCount ProficientOrAbove_count
rename ProfPerc ProficientOrAbove_percent
foreach n in 1 2 3 4 {
	gen Lev`n'_percent = "--"
	gen Lev`n'_count = "--"
}
gen Lev5_percent = ""
gen Lev5_count = ""

//Moving on to School Data
erase "`temp1'"
tempfile tempStateDistrict
save "`tempStateDistrict'", replace
clear

//School Data
use "`Stata_versions'/SD_OriginalData_School2019.dta"
drop in 1/2
//renaming in prep for reshape
rename District DistName
rename B StateAssignedDistID
rename School SchName
rename D StateAssignedSchID
rename GradeLevels GradeLevel
drop SubgroupMetrics
rename AllStudentsA~st TotTestedAll_Students
rename K PartAll_Students
rename AllStudentsAl~e Lev1_countAll_Students
rename M Lev1_percentAll_Students
rename N Lev2_countAll_Students
rename O Lev2_percentAll_Students
rename P Lev3_countAll_Students
rename Q Lev3_percentAll_Students
rename R Lev4_countAll_Students
rename S Lev4_percentAll_Students
rename Y TotTestedDisadv
rename Z PartDisadv
rename AA Lev1_countDisadv
rename AB Lev1_percentDisadv
rename AC Lev2_countDisadv
rename AD Lev2_percentDisadv
rename AE Lev3_countDisadv
rename AF Lev3_percentDisadv
rename AG Lev4_countDisadv
rename AH Lev4_percentDisadv
rename FemaleAllStud~s TotTestedFemale
rename FemaleAllStude~P PartFemale
foreach n in 1 2 3 4 {
	rename FemaleAllStud~`n' Lev`n'_countFemale
}
rename AQ Lev1_percentFemale
rename AS Lev2_percentFemale
rename AU Lev3_percentFemale
rename AW Lev4_percentFemale
rename MaleAllStuden~m TotTestedMale
rename MaleAllStuden~r PartMale
foreach n in 1 2 3 4 {
	rename MaleAllStud~`n'Nu Lev`n'_countMale
	rename MaleAllStud~`n'Pe Lev`n'_percentMale
}
rename HispanicLatin~T TotTestedLatino
rename CW PartLatino
rename HispanicLatin~L Lev1_countLatino
rename CY Lev1_percentLatino
rename CZ Lev2_countLatino
rename DA Lev2_percentLatino
rename DB Lev3_countLatino
rename DC Lev3_percentLatino
rename DD Lev4_countLatino
rename DE Lev4_percentLatino
rename FD TotTestedAmer_Indian
rename FE PartAmer_Indian
rename FF Lev1_countAmer_Indian
rename FG Lev1_percentAmer_Indian
rename FH Lev2_countAmer_Indian
rename FI Lev2_percentAmer_Indian
rename FJ Lev3_countAmer_Indian
rename FK Lev3_percentAmer_Indian
rename FL Lev4_countAmer_Indian
rename FM Lev4_percentAmer_Indian
rename AsianAllStude~u TotTestedAsian
rename AsianAllStude~e PartAsian
foreach n in 1 2 3 4 {
	rename AsianAllStud~`n'N Lev`n'_countAsian
	rename AsianAllStud~`n'P Lev`n'_percentAsian
}
rename GH TotTestedBlack 
rename GI PartBlack
rename GJ Lev1_countBlack
rename GK Lev1_percentBlack
rename GL Lev2_countBlack
rename GM Lev2_percentBlack
rename GN Lev3_countBlack
rename GO Lev3_percentBlack
rename GP Lev4_countBlack
rename GQ Lev4_percentBlack
rename GW TotTestedHawai
rename GX PartHawai
rename GY Lev1_countHawai
rename GZ Lev1_percentHawai
rename HA Lev2_countHawai
rename HB Lev2_percentHawai
rename HC Lev3_countHawai
rename HD Lev3_percentHawai
rename HE Lev4_countHawai
rename HF Lev4_percentHawai
rename WhiteCaucasia~T TotTestedWhite
rename HM PartWhite
rename WhiteCaucasia~L Lev1_countWhite
rename HO Lev1_percentWhite
rename HP Lev2_countWhite
rename HQ Lev2_percentWhite
rename HR Lev3_countWhite
rename HS Lev3_percentWhite
rename HT Lev4_countWhite
rename HU Lev4_percentWhite
rename IA TotTestedMulti 
rename IB PartMulti
rename IC Lev1_countMulti
rename ID Lev1_percentMulti
rename IE Lev2_countMulti
rename IF Lev2_percentMulti
rename IG Lev3_countMulti
rename IH Lev3_percentMulti
rename II Lev4_countMulti
rename IJ Lev4_percentMulti

//reshaping from wide to long
keep if inlist(GradeLevel,"03","04","05","06","07","08")
reshape long TotTested Part Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent, i(DistName SchName GradeLevel Subject) j(StudentSubGroup, string)

//Too many variables again
keep DistName SchName GradeLevel Subject StudentSubGroup StateAssignedDistID StateAssignedSchID TotTested Part TestTaken Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent

//Fixing Missing values
foreach var of varlist _all {
	replace `var' = "--" if missing(`var')
}

//GradeLevel
replace GradeLevel = "G" + GradeLevel

//DataLevel
gen DataLevel = "School"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Subject
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

//StudentSubGroup
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All_Students") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "Amer_Indian") !=0
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") !=0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "Black") !=0
replace StudentSubGroup = "Economically Disadvantaged" if strpos(StudentSubGroup, "Disadv") !=0
replace StudentSubGroup = "Female" if strpos(StudentSubGroup, "Fem") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawai") !=0
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Latino") !=0
replace StudentSubGroup = "English Learner" if strpos(StudentSubGroup, "Learners") !=0
replace StudentSubGroup = "Male" if strpos(StudentSubGroup, "Male") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Multi") !=0
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "White") !=0

//Merging NCES
tempfile temp1
save "`temp1'", replace
use "`NCES_School'/NCES_2018_School.dta"
keep if state_fips == 46
gen StateAssignedSchID = seasch
merge 1:m StateAssignedSchID using "`temp1'"
drop if _merge == 1

//renaming
rename Part ParticipationRate
rename TotTested StudentSubGroup_TotalTested
rename TestTaken AssmtName

//Profcounts and percents
foreach n in 1 2 3 4 {
	destring Lev`n'_count, gen(Lev`n'_num) i("-")
	destring Lev`n'_percent, gen(Lev`n'_dec) i("-")
}
gen ProficientOrAbove_count = Lev3_num + Lev4_num
tostring ProficientOrAbove_count, replace
gen ProficientOrAbove_percent1 = Lev3_dec + Lev4_dec
gen ProficientOrAbove_percent = string(ProficientOrAbove_percent1, "%9.2f")
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
gen Lev5_percent = ""
gen Lev5_count = ""

//Appending State & District Data

append using "`tempStateDistrict'"

//Misc Variables
drop year
gen SchYear = "2018-19"
decode state_name, gen(State)
replace State = "South Dakota"
rename state_location StateAbbrev
replace StateAbbrev = "SD"
rename state_fips StateFips
rename district_agency_type DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename school_type SchType
rename ncesschoolid NCESSchoolID
rename county_code CountyCode
rename county_name CountyName 
gen AssmtType = "Regular"
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3 and 4"
//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Two or More"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StateFips = 46

//AssmtName
replace AssmtName = "SBAC and MSAA" if Subject != "sci"
replace AssmtName = "SDSA and SDSA-Alt" if Subject == "sci"

//ParticipationRate
replace ParticipationRate = "--" if missing(ParticipationRate)

//StudentGroup_Total Tested
destring StudentSubGroup_TotalTested, gen(Tested) i("-")
egen StudentGroup_TotalTested = total(Tested), by(StudentGroup GradeLevel Subject DistName SchName DataLevel)
tostring StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = "--" if missing(StudentGroup_TotalTested) | StudentGroup_TotalTested == "0"
drop Tested

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

//Final cleaning and dropping extra variables
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Saving
save "`Output'/SD_AssmtData_2019", replace

clear

