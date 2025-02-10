*******************************************************
* TENNESSEE

* File name: 05_TN_EDFactsParticipationRate_2014_2015_2017_2018
* Last update: 2/10/2025

*******************************************************
* Notes

	* This do file uses EDFacts participation rates for 2014-2018 (excluding 2016).
	* It merges with and REPLACES the output created in:
	* a) 03_TN_Cleaning_2010_2015 (usual output replaced, non-derived output NOT replaced)
	* b) 04_TN_Cleaning_2017_2024 (usual output replaced, non-derived output NOT replaced)
	
	* The input files for this code are:
	* a) Wide format *.csv files found in the Google Drive --> _Data Cleaning Materials --> _EDFacts--> Datasets
	* b) Convert the *.csv files to *.dta using the commented out code.
	
/////////////////////////////////////////
*** Conversion from EdFacts wide .csv to .dta format ***
/////////////////////////////////////////

	
// clear
// set more off
// global EDFacts "C:/Zelma/EDFacts/Datasets" //EDFacts Datasets (wide version) downloaded from Google Drive.
// forvalues year = 2014/2018 {
//     foreach subject in ela math {
//         foreach type in part count {
//             foreach dl in district school {
//                 import delimited "${EDFacts}/`year'/edfacts`type'`year'`subject'`dl'.csv", clear
//                 save "${EDFacts}/`year'/edfacts`type'`year'`subject'`dl'.dta", replace
//             }
//         }
//     }
// }
	
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear
set more off

** Preparing EDFacts files
local edyears1 14 15 17 18
local subject math ela
local datatype part //Only using percentages here and not counts. 
local datalevel school district

/////////////////////////////////////////
*** Cleaning ***
/////////////////////////////////////////

*This code runs on the wide format *.dta files found in the Google Drive --> _Data Cleaning Materials --> _EDFacts--> Datasets
foreach year of local edyears1 {
    foreach sub of local subject {
        foreach type of local datatype {
            foreach lvl of local datalevel {
                local prevyear = `year' - 1
                use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
                keep if stnam == "TENNESSEE"
                rename *_`prevyear'`year' *
                if ("`sub'" == "math") {
                    rename *_mth* **
                }
                if ("`sub'" == "ela") {
                    rename *_rla* **
                }
                if ("`type'" == "count") {
                    rename *numvalid Count*
                    drop *pctprof
                }
                if ("`type'" == "part") {
                    rename *pctpart Participation*
                    drop *numpart
                }
                drop *hs *00 
                if ("`lvl'" == "school") & ("`type'" == "count") {
                    reshape long Count, i(ncessch) j(StudentSubGroup) string
                    gen DataLevel = 3
                }
                if ("`lvl'" == "district") & ("`type'" == "count") {
                    reshape long Count, i(leaid) j(StudentSubGroup) string
                    gen DataLevel = 2
                }
                if ("`lvl'" == "school") & ("`type'" == "part") {
                    reshape long Participation, i(ncessch) j(StudentSubGroup) string
                    gen DataLevel = 3
                }
                if ("`lvl'" == "district") & ("`type'" == "part") {
                    reshape long Participation, i(leaid) j(StudentSubGroup) string
                    gen DataLevel = 2
                }               
                gen Subject = "`sub'"
                save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'TN.dta", replace
            }
        }
    }
}

foreach year of local edyears1 {
    foreach type of local datatype {
        foreach lvl of local datalevel {
            use "${EDFacts}/20`year'/edfacts`type'20`year'math`lvl'TN.dta", clear
            append using "${EDFacts}/20`year'/edfacts`type'20`year'ela`lvl'TN.dta"
            if ("`lvl'" == "school"){
                rename ncessch NCESSchoolID
            }
            rename leaid NCESDistrictID
            if ("`type'" == "count") {
                drop if Count == .
            }
            if ("`type'" == "part") {
                drop if Participation == ""
                replace Participation = "--" if Participation == "n/a"
                replace Participation = "*" if Participation == "PS"
                split Participation, parse("-")
                destring Participation1, replace force
                replace Participation1 = Participation1/100
                tostring Participation1, replace format("%9.2g") force
                destring Participation2, replace force
                replace Participation2 = Participation2/100         
                tostring Participation2, replace format("%9.2g") force
                replace Participation = Participation1 + "-" + Participation2 if Participation1 != "." & Participation2 != "."
                replace Participation = Participation1 if Participation1 != "." & Participation2 == "."
                gen Participation3 = subinstr(Participation, "GE", "", .) if strpos(Participation, "GE") > 0
                replace Participation3 = subinstr(Participation, "LT", "", .) if strpos(Participation, "LT") > 0
                replace Participation3 = subinstr(Participation, "LE", "", .) if strpos(Participation, "LE") > 0
                destring Participation3, replace force
                replace Participation3 = Participation3/100
                tostring Participation3, replace format("%9.2g") force
                replace Participation = Participation3 + "-1" if strpos(Participation, "GE") > 0
                replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0 | strpos(Participation, "LE") > 0
                drop Participation1 Participation2 Participation3
            }
            gen GradeLevel = "G" + substr(StudentSubGroup, -2, 2) //This is because the data is subgroup+grade.
			replace StudentSubGroup = subinstr(StudentSubGroup, substr(StudentSubGroup, -2, 2), "", .) //This is because the data is subgroup+grade.
			replace StudentSubGroup = "All Students" if StudentSubGroup == "all"
            replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ecd"
            replace StudentSubGroup = "Female" if StudentSubGroup == "f"
            replace StudentSubGroup = "English Learner" if StudentSubGroup == "lep"
            replace StudentSubGroup = "Male" if StudentSubGroup == "m"
            replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "mam"
            replace StudentSubGroup = "Asian" if StudentSubGroup == "mas"
            replace StudentSubGroup = "Black or African American" if StudentSubGroup == "mbl"
            replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "mhi"
            replace StudentSubGroup = "Two or More" if StudentSubGroup == "mtr"
            replace StudentSubGroup = "White" if StudentSubGroup == "mwh"
            replace StudentSubGroup = "SWD" if StudentSubGroup == "cwd"
            replace StudentSubGroup = "Homeless" if StudentSubGroup == "hom"
            replace StudentSubGroup = "Migrant" if StudentSubGroup == "mig"
            gen StudentGroup = "RaceEth"
            replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
            replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
            replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
            replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
            replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
            replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
            replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant Status"
            save "${EDFacts}/20`year'/edfacts`type'20`year'`lvl'TN.dta", replace
        }
    }
}

//Merging 
foreach year in 2014 2015 2017 2018 {
import delimited "${Output}/TN_AssmtData_`year'.csv", case(preserve) clear
	
//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Merging
tempfile tempall
save "`tempall'", replace
keep if DataLevel == 2
tempfile tempdist
save "`tempdist'", replace
clear
use "`tempall'"
keep if DataLevel == 3
tempfile tempsch
save "`tempsch'", replace
clear

//District Merge
use "`tempdist'"
duplicates report NCESDistrictID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID StudentSubGroup GradeLevel Subject, force
merge 1:1 NCESDistrictID StudentSubGroup GradeLevel Subject using "${EDFacts}/`year'/edfactspart`year'districtTN.dta", gen(DistMerge)
drop if DistMerge == 2
save "`tempdist'", replace
clear

//School Merge
use "`tempsch'"
duplicates report NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts}/`year'/edfactspart`year'schoolTN.dta", gen(SchMerge)
drop if SchMerge == 2
save "`tempsch'", replace
clear

//Combining DataLevels
use "`tempall'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"

//New Participation Data
replace ParticipationRate = Participation if !missing(Participation)

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/TN_AssmtData_`year'", replace
export delimited "${Output}/TN_AssmtData_`year'", replace
}

