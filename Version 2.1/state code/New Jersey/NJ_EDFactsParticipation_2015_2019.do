* NEW JERSEY

* File name: NJ_EDFactsParticipation_2015_2021
* Last update: 03/10/2025

*******************************************************
* Notes 

	* This do file imports *.csv EDFacts Datasets (wide version) for 2015-2021.
	* It keeps NJ only observations, reshapes it and saves it as *.dta.
	* The NJ specific EDFacts participation rate files are merged with the
	* Temp output with derivations created in
	* a) NJ Cleaning 2015_2018
	* b) NJ Cleaning 2019_2023
	* The final files are exported to the Output_Files folder. 
	
*******************************************************
/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

***Code to convert EDFacts csv files to dta***
local edyears1 14 15 16 17 18
local edyears2 2019 2021
local subject math ela
local datatype part
local datalevel school district

** Converting to dta **
foreach yr of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				if (`yr' != 2011) | ("`lvl'" != "school") {
					import delimited "${EDFacts}/`yr'/edfacts`type'`yr'`sub'`lvl'.csv", case(lower) clear
					save "${EDFacts}/`yr'/edfacts`type'`yr'`sub'`lvl'.dta", replace
				}
			}
		}
	}
}

foreach yr of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				import delimited "${EDFacts}/20`yr'/edfacts`type'20`yr'`sub'`lvl'.csv", case(lower) clear
				save "${EDFacts}/20`yr'/edfacts`type'20`yr'`sub'`lvl'.dta", replace
			}
		}
	}
}

** Preparing EDFacts files
local edyears1 14 15 16 17 18
local edyears2 2019 2021
local subject math ela
local datatype part
local datalevel school district

foreach year of local edyears1 {
    foreach sub of local subject {
        foreach type of local datatype {
            foreach lvl of local datalevel {
                local prevyear = `year' - 1
                use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
                keep if stnam == "NEW JERSEY"
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
                save "${EDFacts_NJ}/edfacts`type'20`year'`sub'`lvl'NJ.dta", replace
            }
        }
    }
}

foreach year of local edyears1 {
    foreach type of local datatype {
        foreach lvl of local datalevel {
            use "${EDFacts_NJ}/edfacts`type'20`year'math`lvl'NJ.dta", clear
            append using "${EDFacts_NJ}/edfacts`type'20`year'ela`lvl'NJ.dta"
			if ("`lvl'" == "school") {
                rename ncessch NCESSchoolID
			}
				rename leaid NCESDistrictID
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
            save "${EDFacts_NJ}/edfacts`type'20`year'`lvl'NJ.dta", replace
        }
    }
}

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'.dta", clear
				keep if stnam == "NEW JERSEY"
				drop date_cur
				if ("`type'" == "count") {
					rename numvalid Count
					rename pctprof PctProf
				}
				if ("`type'" == "part") {
					rename pctpart Participation
					drop numpart
				}
				rename subject Subject
				replace Subject = "`sub'"
				if ("`lvl'" == "school") {
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") {
					gen DataLevel = 2
				}
				save "${EDFacts_NJ}/edfacts`type'`year'`sub'`lvl'NJ.dta", replace
			}
		}
	}
}

foreach year of local edyears2 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts_NJ}/edfacts`type'`year'math`lvl'NJ.dta", clear
			append using "${EDFacts_NJ}/edfacts`type'`year'ela`lvl'NJ.dta"
			if "`lvl'" == "school" {
				rename ncessch NCESSchoolID
			}
				rename leaid NCESDistrictID
			if ("`type'" == "count") {
				drop if Count == .
				drop if PctProf == ""
				replace PctProf = "--" if PctProf == "n/a"
				replace PctProf = "*" if PctProf == "PS"
				split PctProf, parse("-")
				destring PctProf1, replace force
				replace PctProf1 = PctProf1/100
				tostring PctProf1, replace format("%9.2g") force
				destring PctProf2, replace force
				replace PctProf2 = PctProf2/100			
				tostring PctProf2, replace format("%9.2g") force
				replace PctProf = PctProf1 + "-" + PctProf2 if PctProf1 != "." & PctProf2 != "."
				replace PctProf = PctProf1 if PctProf1 != "." & PctProf2 == "."
				gen PctProf3 = subinstr(PctProf, "GE", "", .) if strpos(PctProf, "GE") > 0
				replace PctProf3 = subinstr(PctProf, "LT", "", .) if strpos(PctProf, "LT") > 0
				replace PctProf3 = subinstr(PctProf, "LE", "", .) if strpos(PctProf, "LE") > 0
				destring PctProf3, replace force
				replace PctProf3 = PctProf3/100
				tostring PctProf3, replace format("%9.2g") force
				replace PctProf = PctProf3 + "-1" if strpos(PctProf, "GE") > 0
				replace PctProf = "0-" + PctProf3 if strpos(PctProf, "LT") > 0
				replace PctProf = "0-" + PctProf3 if strpos(PctProf, "LE") > 0
				drop PctProf1 PctProf2 PctProf3
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
				replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LE") > 0
				drop Participation1 Participation2 Participation3
			}
			drop if grade == "HS"
			rename grade GradeLevel
			replace GradeLevel = "G" + GradeLevel
			replace GradeLevel = "G38" if GradeLevel == "G00"
			rename category StudentSubGroup
			replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
			replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
			replace StudentSubGroup = "Female" if StudentSubGroup == "F"
			replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
			replace StudentSubGroup = "Male" if StudentSubGroup == "M"
			replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
			replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
			replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
			replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
			replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
			replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
			replace StudentSubGroup = "SWD" if StudentSubGroup == "CWD"
			replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"
			replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
			replace StudentSubGroup = "Military" if StudentSubGroup == "MIL"
			replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FCS"
			gen StudentGroup = "RaceEth"
			replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
			replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
			replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
			replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
			replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
			replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
			replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
			replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
			replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
			save "${EDFacts_NJ}/edfacts`type'`year'`lvl'NJ.dta", replace
		}
	}
}

//Errors in code
forvalues year = 2015/2019 {

use "$EDFacts_NJ/edfactspart`year'districtNJ.dta", clear
append using "$EDFacts_NJ/edfactspart`year'schoolNJ.dta"
rename Participation ParticipationRate1

destring NCESDistrictID NCESSchoolID, replace force
keep NCESDistrictID ParticipationRate1 StudentSubGroup GradeLevel Subject NCESSchoolID
save "$EDFacts_NJ/edfactspart_`year'NJ", replace
clear

use "$Temp/NJ_AssmtData_`year'", clear
destring NCESDistrictID NCESSchoolID, replace force

if SchYear == "2017-18" {
	duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force
}
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "$EDFacts_NJ/edfactspart_`year'NJ", nogen keep(match master) 
replace ParticipationRate = ParticipationRate1 if !missing(ParticipationRate1)
replace ParticipationRate = "--" if ParticipationRate == "."

//Final Cleaning
local vars State StateAbbrev StateFips SchYear DataLevel DistName SchName 	///
    NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID		///
    AssmtName AssmtType Subject GradeLevel	StudentGroup 					///
    StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested    ///
    Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent	///
    Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore			///
    ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent	///
    ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA 			///
    Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc ///
    DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	keep `vars' State_leaid
	order `vars' State_leaid
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output for 2015-2019
replace State_leaid = "" if DataLevel == 1
save "${Output_HMH}/NJ_AssmtData_`year'_HMH", replace
export delimited "${Output_HMH}/NJ_AssmtData_`year'_HMH", replace
forvalues n = 1/3 {
		preserve
		keep if DataLevel == `n'
		if `n' == 1{
			export excel "${Output_HMH}/NJ_AssmtData_`year'_HMH.xlsx", sheet("State") sheetreplace firstrow(variables)
		}
		if `n' == 2{
			export excel "${Output_HMH}/NJ_AssmtData_`year'_HMH.xlsx", sheet("District") sheetreplace firstrow(variables)
		}
		if `n' == 3{
			export excel "${Output_HMH}/NJ_AssmtData_`year'_HMH.xlsx", sheet("School") sheetreplace firstrow(variables)
		}
		restore
	}
drop State_leaid //remove alternate ID for non-HMH output
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "$Output/NJ_AssmtData_`year'", replace
export delimited "$Output/NJ_AssmtData_`year'", replace
clear
}
*End of NJ_EDFactsParticipation_2015_2019.do
****************************************************
