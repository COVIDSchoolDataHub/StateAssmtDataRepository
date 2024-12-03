clear
set more off

cd "/Volumes/T7/State Test Project/South Dakota"
global Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
global Output "/Volumes/T7/State Test Project/South Dakota/Output"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Stata_versions "/Volumes/T7/State Test Project/South Dakota/Stata .dta versions"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

** Preparing EDFacts files
local edyears1 15 16 17 18
local subject math ela
local datatype part count
local datalevel school district

foreach year of local edyears1 {
    foreach sub of local subject {
        foreach type of local datatype {
            foreach lvl of local datalevel {
                local prevyear = `year' - 1
                use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
                keep if stnam == "SOUTH DAKOTA"
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
                save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'southdakota.dta", replace
            }
        }
    }
}

foreach year of local edyears1 {
    foreach type of local datatype {
        foreach lvl of local datalevel {
            use "${EDFacts}/20`year'/edfacts`type'20`year'math`lvl'southdakota.dta", clear
            append using "${EDFacts}/20`year'/edfacts`type'20`year'ela`lvl'southdakota.dta"
			if ("`lvl'" == "school") {
                rename ncessch NCESSchoolID
				format NCESSchoolID %14.0g
			}
				rename leaid NCESDistrictID
				
			tostring NCES*, replace usedisplayformat
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
            save "${EDFacts}/20`year'/edfacts`type'20`year'`lvl'southdakota.dta", replace
			
        }
    }
}

//Merging
forvalues year = 2015/2018 {
if `year' == 2020 continue
use "${Output}/SD_AssmtData_`year'", clear

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

//Merging Count & Participation

foreach type in count part {
//District Merge
use "`tempdist'"
duplicates report NCESDistrictID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID StudentSubGroup GradeLevel Subject, force
merge 1:1 NCESDistrictID StudentSubGroup GradeLevel Subject using "${EDFacts}/`year'/edfacts`type'`year'districtsouthdakota.dta", gen(DistMerge`type')
drop if DistMerge`type' == 2
save "`tempdist'", replace
clear

//School Merge
use "`tempsch'"
duplicates report NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts}/`year'/edfacts`type'`year'schoolsouthdakota.dta", gen(SchMerge`type')
drop if SchMerge`type' == 2
save "`tempsch'", replace
clear

}
//Combining DataLevels
use "`tempall'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"

//New Data
replace ParticipationRate = Participation if !missing(Participation) & missing(real(ParticipationRate))
replace StudentSubGroup_TotalTested = string(Count) if missing(real(StudentSubGroup_TotalTested)) & !missing(Count) & Count < real(StudentGroup_TotalTested)

//New Counts
foreach percent of varlist Lev*_percent {
	local count = subinstr("`percent'", "percent", "count",.)
	replace `count' = string(round(real(`percent')*real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
	replace `count' = "*" if `percent' == "*"
	replace `count' = "--" if missing(`count') & "`count'" != "Lev5_count"
}
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count)) & missing(real(ProficientOrAbove_count))

//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

gen Derivable = 1 if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if Derivable == 1

drop Unsuppressed* missing_* Derivable

//Level percent (and corresponding count) derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.4g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

foreach percent of varlist Lev*_percent {
	replace `percent' = "0" if real(`percent') <  0.005 & !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent)) & missing(real(ProficientOrAbove_percent))

foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(`count'))
	replace `percent' = string(real(`percent'), "%9.4g") if !missing(real(`percent'))
}

//Derive ProficientOrAbove_count/percent based on non proficient levels
replace ProficientOrAbove_count = string(real(StudentSubGroup_TotalTested)-real(Lev1_count)-real(Lev2_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & missing(real(ProficientOrAbove_count))
replace ProficientOrAbove_percent = string(1-real(Lev1_percent)-real(Lev2_percent), "%9.4g") if !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_percent = "0" if 1-real(Lev1_percent)-real(Lev2_percent) < 0.005


//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/SD_AssmtData_`year'", replace
export delimited "${Output}/SD_AssmtData_`year'", replace
}
