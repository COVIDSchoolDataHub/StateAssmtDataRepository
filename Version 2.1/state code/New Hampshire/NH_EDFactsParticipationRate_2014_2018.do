* NEW HAMPSHIRE

* File name: NH_EDFactsParticipationRate_2014_2018
* Last update: 03/07/2025

*******************************************************
* Notes 

	* This do file imports *.csv EDFacts Datasets (wide version) for 2014-2018.
	* It keeps NH only observations, reshapes it and saves it as *.dta.
	* The NH specific EDFacts participation rate files are merged with the
	* Temp output with derivations created in NH_Cleaning.do for 2014-2018.
	* The final files are exported to the Output_Files folder. 
	
*******************************************************
clear

** Converting EDFacts files to .dta Format
forvalues year = 2014/2018 {
	if `year' == 2020 continue
	foreach datatype in part {
		foreach sub in math ela {
			foreach lvl in school district {
				clear
				import delimited "${EDFacts}/`year'/edfacts`datatype'`year'`sub'`lvl'", case(lower)
				save "${EDFacts}/`year'/edfacts`datatype'`year'`sub'`lvl'", replace
			}
		}
	}
}


clear
set more off
** Preparing EDFacts files
local edyears1 14 15 16 17 18
local subject math ela
local datatype part
local datalevel school district

foreach year of local edyears1 {
    foreach sub of local subject {
        foreach type of local datatype {
            foreach lvl of local datalevel {
                local prevyear = `year' - 1
                use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
                keep if stnam == "NEW HAMPSHIRE"
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
                save "${EDFacts_NH}/edfacts`type'20`year'`sub'`lvl'NH.dta", replace
            }
        }
    }
}

foreach year of local edyears1 {
    foreach type of local datatype {
        foreach lvl of local datalevel {
            use "${EDFacts_NH}/edfacts`type'20`year'math`lvl'NH.dta", clear
            append using "${EDFacts_NH}/edfacts`type'20`year'ela`lvl'NH.dta"
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
            gen GradeLevel = "G" + substr(StudentSubGroup, -2, 2)
            replace StudentSubGroup = subinstr(StudentSubGroup, substr(StudentSubGroup, -2, 2), "", .)
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
            save "${EDFacts_NH}/edfacts`type'20`year'`lvl'NH.dta", replace
        }
    }
}

//Merging Example
forvalues year = 2014/2018 {
use "${Temp}/NH_AssmtData_`year'.dta", clear

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


//School Merge
use "`tempsch'"
duplicates report NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force
destring NCESDistrictID, replace
destring NCESSchoolID, replace
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts_NH}/edfactspart`year'schoolNH.dta", gen(SchMerge)
drop if SchMerge == 2
tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format("%18.0f")
replace NCESDistrictID = "" if NCESDistrictID == "."
replace NCESSchoolID = "" if NCESSchoolID == "."
save "`tempsch'", replace
clear

//Combining DataLevels
use "`tempall'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"

//New Participation Data
replace ParticipationRate = Participation if !missing(Participation)

//Final Cleaning
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName ///
	NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID ///
	AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested ///
	StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent ///
	Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent ///
	Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ///
	ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA ///
	Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType ///
	DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output for 2014-2018
save "${Output}/NH_AssmtData_`year'", replace
export delimited "${Output}/NH_AssmtData_`year'", replace
}
*End of NH_EDFactsParticipationRate_2014_2018.do
****************************************************
