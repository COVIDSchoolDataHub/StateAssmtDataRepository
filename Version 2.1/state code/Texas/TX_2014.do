*******************************************************
* TEXAS

* File name: TX_2014
* Last update: 2/11/2025

*******************************************************
* Notes

	* This do file cleans TX's 2014 data and merges with NCES_2013.

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear all

/////////////////////////////////////////
*** Cleaning ***
/////////////////////////////////////////
use "${original_reduced}/TX_Temp_2014_All_All.dta", clear

// Splitting Subject and Subgroups
generate Subject = substr(subject_group, 1, 1)
generate StudentGroup = substr(subject_group, 3, 3)
generate StudentSubGroup = substr(subject_group, 3, .)
drop subject_group

drop if StudentGroup == "voc"
drop *comp*

replace Subject = "math" if Subject == "m"
replace Subject = "ela" if Subject == "r"
replace Subject = "sci" if Subject == "s"
replace Subject = "soc" if Subject == "h"
replace Subject = "wri" if Subject == "w"

//StudentSubGroup & StudentGroup
replace StudentGroup = "All Students" if StudentGroup == "all"
replace StudentGroup = "RaceEth" if StudentGroup == "eth"
replace StudentGroup = "EL Status" if StudentGroup == "lep"
replace StudentGroup = "Economic Status" if StudentGroup == "eco"
replace StudentGroup = "Gender" if StudentGroup == "sex"
replace StudentGroup = "Disability Status" if StudentGroup == "spe"
replace StudentGroup = "Migrant Status" if StudentGroup == "mig"

replace StudentSubGroup = "All Students" if StudentSubGroup == "all"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "ethi"
replace StudentSubGroup = "Asian" if StudentSubGroup == "etha"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "ethb"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "ethp"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "eth2"
replace StudentSubGroup = "White" if StudentSubGroup == "ethw"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "ethh"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "ethv"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "lepc"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "lep0"
replace StudentSubGroup = "EL Monit or Recently Ex" if StudentSubGroup == "lepf"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ecoy"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "econ"
replace StudentSubGroup = "Male" if StudentSubGroup == "sexm"
replace StudentSubGroup = "Female" if StudentSubGroup == "sexf"
replace StudentSubGroup = "Unknown" if StudentSubGroup == "sexv"
replace StudentSubGroup = "SWD" if StudentSubGroup == "spey"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "spen"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "migy"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "mign"

// Renaming and Transforming Variables
rename GRADE GradeLevel
tostring GradeLevel, replace
replace GradeLevel = "G0"+GradeLevel

rename year SchYear
tostring SchYear, replace
replace SchYear = "2013-14" if SchYear == "14"

rename d_ StudentSubGroup_TotalTested
rename unsat_ph1_nm_ Lev1_count
rename satis_ph1_nm_ Lev2plus_count
rename adv_rec_nm_ Lev3_count
rename unsat_ph1_rm_ Lev1_percent
rename satis_ph1_rm_ Lev2plus_percent
rename adv_rec_rm_ Lev3_percent

rename rs_ AvgScaleScore
rename docs_n_ Submitted_count
rename docs_r_ ParticipationRate
rename abs_n_ Absent_count
rename abs_r_ Absent_percent
rename oth_n_ NoTestOth_count
rename oth_r_ NoTestOth_percent
rename CAMPUS StateAssignedSchID
rename DISTRICT StateAssignedDistID
rename DNAME DistName
rename CNAME SchName

// Relabeling Data Levels
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Assessment Information
gen AssmtName = "STAAR - English"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "N"
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 2-3"
gen state_leaid = StateAssignedDistID
replace state_leaid = "" if DataLevel == 1
gen seasch = StateAssignedSchID
replace seasch = "" if DataLevel != 3

***Calculations***
//Deriving & Formatting Level Count and Percent Information
generate Lev2_count = Lev2plus_count - Lev3_count
generate Lev2_percent = Lev2plus_percent - Lev3_percent
generate ProficientOrAbove_count = Lev2plus_count
generate ProficientOrAbove_percent = Lev2plus_percent
drop Lev2plus_count
drop Lev2plus_percent

drop Submitted_count
drop Absent_count
drop Absent_percent
drop NoTestOth_count
drop NoTestOth_percent

// Fixing Percents
foreach var of varlist Lev1_percent Lev2_percent Lev3_percent ProficientOrAbove_percent ParticipationRate {
	replace `var' = `var'/100
}

// Dealing with Suppressed/Missing
foreach var of varlist Lev1_count Lev2_count Lev3_count Lev1_percent Lev2_percent Lev3_percent AvgScaleScore ProficientOrAbove_count ProficientOrAbove_percent {
	tostring `var', replace force format("%9.3g")
	replace `var' = "--" if StudentSubGroup_TotalTested == 0
	replace `var' = "*" if `var' == "."
}

tostring ParticipationRate, replace force
replace ParticipationRate = "--" if ParticipationRate == "."

*Generating empty Level 4 and 5 counts and percentages. since TX had only 3 Levels in 2014. 
gen Lev4_count = ""
gen Lev4_percent = ""
gen Lev5_count = ""
gen Lev5_percent = ""

// Dealing with AL-HADI
drop if DistName == "AL-HADI SCHOOL"

// Saving transformed data
save "$temp_files/TX_AssmtData_2014.dta", replace

// Merging with NCES District Data

use "$NCES_District/NCES_2013_District.dta", clear

keep state_location state_fips lea_name district_agency_type ncesdistrictid state_leaid DistCharter county_name county_code DistLocale

replace state_location = "TX" if state_fips == 48

keep if state_location == "TX"
save "${NCES_State}/NCES_2013_District_TX", replace

merge 1:m state_leaid using "${temp_files}/TX_AssmtData_2014.dta", keep(match using) nogenerate
replace DistName = lea_name if DataLevel != 1 & lea_name != ""
drop lea_name

save "$temp_files/TX_AssmtData_2014.dta", replace

***Merging with NCES***
// Merging with NCES District Data
use "$NCES_School/NCES_2013_School.dta", clear

keep state_location state_fips district_agency_type SchType ncesdistrictid state_leaid ncesschoolid seasch DistCharter SchLevel SchVirtual county_name county_code DistLocale

replace state_location = "TX" if state_fips == 48

keep if state_location == "TX"
drop if seasch == ""
save "${NCES_State}/NCES_2013_School_TX", replace

merge 1:m seasch using "${temp_files}/TX_AssmtData_2014.dta", keep(match using) nogenerate

save "$temp_files/TX_AssmtData_2014.dta", replace

// Renaming NCES Variables
rename district_agency_type DistType
rename ncesschoolid NCESSchoolID
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename state_location StateAbbrev
generate State = "Texas"
rename county_code CountyCode
*rename school_type SchType
rename state_fips StateFips
rename county_name CountyName

// Fixing missing state data
replace StateAbbrev = "TX" if DataLevel == 1
replace StateFips = 48 if DataLevel == 1

// Fixing Texas Tech Univ
foreach var of varlist SchLevel SchVirtual SchType {
	decode `var', gen(temp)
	drop `var'
	rename temp `var'
}
replace NCESDistrictID = "4801480" if DistName == "TEXAS TECH UNIV"
replace NCESSchoolID = "480148014286" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace DistType = " Regular local school district" if DistName == "TEXAS TECH UNIV"
replace DistCharter = "No" if DistName == "TEXAS TECH UNIV"
replace DistLocale = "City, large" if DistName == "TEXAS TECH UNIV"
replace SchType = "Regular school" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace SchLevel = "Other" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace SchVirtual = "Missing/not reported" if DistName == "TEXAS TECH UNIV" & DataLevel == 3
replace CountyName = "Lubbock County" if DistName == "TEXAS TECH UNIV"
replace CountyCode = "48303" if DistName == "TEXAS TECH UNIV"
replace StateAbbrev = "TX" if DistName == "TEXAS TECH UNIV"
replace StateFips = 48 if DistName == "TEXAS TECH UNIV"
drop if StateAssignedSchID == "031912006" & NCESSchoolID == ""
drop if StateAssignedSchID == "101601101" & NCESSchoolID == ""
drop if StateAssignedSchID == "101917010" & NCESSchoolID == ""
drop if StateAssignedSchID == "221801002" & NCESSchoolID == ""
drop if StateAssignedSchID == "221901041" & NCESSchoolID == ""

//Other Post Launch
replace CountyName = proper(CountyName)
drop seasch
drop State_leaid
replace DistType = trim(DistType)
replace CountyName = "DeWitt County" if CountyCode== "48123"
replace CountyName = "McCulloch County" if CountyCode== "48307"
replace CountyName = "McLennan County" if CountyCode== "48309"
replace CountyName = "McMullen County" if CountyCode== "48311"
drop if SchName == "TEXAS TECH H S"
replace SchName ="TEXAS TECH UNIV" if NCESSchoolID== "480148014286"
replace StateAssignedSchID = "152504001" if NCESSchoolID == "480148014286" //Applying 2023 StateAssignedSchID to All Years

//StudentGroup_TotalTested
sort DataLevel AssmtName StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
drop if StudentSubGroup_TotalTested == 0 & StudentSubGroup != "All Students"

//Updating Two District Names for Clarity
replace DistName = "HIGHLAND PARK ISD (DALLAS)" if NCESDistrictID == "4823250"
replace DistName = "HIGHLAND PARK ISD (AMARILLO)" if NCESDistrictID == "4835560"

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// Saving and exporting transformed data
*Exporting into a separate folder Output for Stanford - without derivations* //This part of the code is commented out because we do not have any derivations in this data. 
*save "${output_ND}/TX_AssmtData_2014_NoDev", replace //If .dta format needed. 
*export delimited "${output_ND}/TX_AssmtData_2014_NoDev", replace

*Exporting into the usual output file* 
*save "${output_files}/TX_AssmtData_2014.dta", replace //If .dta format needed. 
export delimited using "${output_files}/TX_AssmtData_2014.csv", replace

* END of TX_2014.do 
