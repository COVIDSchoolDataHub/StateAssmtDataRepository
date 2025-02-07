*******************************************************
* TENNESSEE

* File name: 05_TN_EDFactsParticipationRate_2014_2015_2017_2018
* Last update: 2/7/2025

*******************************************************
* Notes

	* This do file uses EDFacts participation rates for 2014-2018 (excluding 2016) and merges it with Output created in Version 1.1.
	* The merged V1.1 output for 2014-2018 (excluding 2016) REPLACES the output created in: 
	* a) 03_TN_Cleaning_2010_2015 (usual output replaced, non-derived output NOT replaced)
	* b) 04_TN_Cleaning_2017_2024 (usual output replaced, non-derived output NOT replaced)
	
	* The input files for this code are:
	* a) Long DTA Versions *.dta files found in the Google Drive --> _Data Cleaning Materials --> _EDFacts--> Long DTA Versions
	* b) V1.1 Output *.csv files found in the Google Drive --> Tennessee --> Output - Version 1.1

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear
set more off

/////////////////////////////////////////
*** Cleaning ***
/////////////////////////////////////////

** Preparing EDFacts files
local edyears1 14 15 17 18
local subject math ela
local datatype part //Only using percentages here and not counts. 
local datalevel school district

*This code runs on the Long DTA Versions *.dta files found in the Google Drive --> _Data Cleaning Materials --> _EDFacts--> Long DTA Versions
foreach year of local edyears1 {
    foreach sub of local subject {
        foreach type of local datatype {
            foreach lvl of local datalevel {
                local prevyear = `year' - 1
             
				use "${EDFacts}/edfacts`type'20`year'`sub'`lvl'.dta", clear

				//Filtering only TN data.
				keep if STNAM == "TENNESSEE"

                if ("`type'" == "count") {
                    rename NUMVALID COUNT
                    drop PCTPROF
                }
                if ("`type'" == "part") {
                    rename PCTPART Participation
                    drop NUMPART
                }
                save "${EDFacts}/edfacts`type'20`year'`sub'`lvl'TN.dta", replace
            }
        }
    }
}

foreach year of local edyears1 {
    foreach type of local datatype {
        foreach lvl of local datalevel {			
			// Using Math data for that year and appending the ELA data to it.
			use "${EDFacts}/edfacts`type'20`year'math`lvl'TN.dta", clear
            append using "${EDFacts}/edfacts`type'20`year'ela`lvl'TN.dta"
			
			//Renaming
			rename LEAID NCESDistrictID
			rename SUBJECT Subject
			rename GRADE GradeLevel
			rename CATEGORY StudentSubGroup
			
			//Subject
			replace Subject = "ela" if Subject == "RLA"
			replace Subject = "math" if Subject == "MTH"

			if ("`lvl'" == "district"){
				destring NCESDistrictID, replace force
				format NCESDistrictID %07.0f
            }
			
			if ("`lvl'" == "school"){
                rename NCESSCH NCESSchoolID
				destring NCESDistrictID, replace force
				destring NCESSchoolID, replace force
				format NCESDistrictID %07.0f
				format NCESSchoolID %012.0f
            }
          
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
			
			//GradeLevel
			replace GradeLevel = "G" + GradeLevel
			keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08", "G00")
			replace GradeLevel = "G38" if GradeLevel == "G00"
			
			//StudentSubGroup
  			replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
            replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
            replace StudentSubGroup = "Female" if StudentSubGroup == "F"
			replace StudentSubGroup = "Male" if StudentSubGroup == "M"
            replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
            replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
			replace StudentSubGroup = "SWD" if StudentSubGroup == "CWD"
			replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FCS"
			replace StudentSubGroup = "Migrant Status" if StudentSubGroup == "MIG"
			replace StudentSubGroup = "Military" if StudentSubGroup == "MIL"
			
			replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
			replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
			replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
			replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
			replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
			replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"

			gen StudentGroup = "RaceEth"
            replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
            replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
            replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
            replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
            replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
            replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
            replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant Status"
			
            save "${EDFacts}/edfacts`type'20`year'`lvl'TN.dta", replace
        }
    }
}

//Merging 
foreach year in 2014 2015 2017 2018 {
import delimited "${V1_1_Output}/TN_AssmtData_`year'.csv", case(preserve) clear
	
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

destring NCESDistrictID, replace force
format NCESDistrictID %07.0f

merge 1:1 NCESDistrictID StudentSubGroup GradeLevel Subject using "${EDFacts}/edfactspart`year'districtTN.dta", gen(DistMerge)
drop if DistMerge == 2
save "`tempdist'", replace
clear

//School Merge
use "`tempsch'"
duplicates report NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force

destring NCESDistrictID, replace force
destring NCESSchoolID, replace force
format NCESDistrictID %07.0f
format NCESSchoolID %012.0f

merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts}/edfactspart`year'schoolTN.dta", gen(SchMerge)
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
*export delimited "${Output}/TN_AssmtData_`year'", replace //Commented out because it's not a final version final.
}


