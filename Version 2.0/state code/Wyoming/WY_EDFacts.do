clear
global Original "/Users/kaitlynlucas/Desktop/Wyoming/Original"
global Output "/Users/kaitlynlucas/Desktop/Wyoming/Output"
global NCES "/Users/kaitlynlucas/Desktop/Wyoming/NCES"
global EDFacts "/Users/kaitlynlucas/Desktop/EDFacts Drive Data"
global New_Output "/Users/kaitlynlucas/Desktop/Wyoming/V2.0+"

** Preparing EDFacts files
local edyears1 14 15 16 17 18
local edyears2 2019 2021
local subject math ela
local datatype part count
local datalevel school district

foreach year of local edyears1 {
    foreach sub of local subject {
        foreach type of local datatype {
            foreach lvl of local datalevel {
                local prevyear = `year' - 1
                use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
                keep if stnam == "WYOMING"
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
                save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'wyoming.dta", replace
            }
        }
    }
}

foreach year of local edyears1 {
    foreach type of local datatype {
        foreach lvl of local datalevel {
            use "${EDFacts}/20`year'/edfacts`type'20`year'math`lvl'wyoming.dta", clear
            append using "${EDFacts}/20`year'/edfacts`type'20`year'ela`lvl'wyoming.dta"
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
			//Using ELA for eng and read
			tempfile temp1
			save "`temp1'", replace
			keep if Subject == "ela"
			expand 3, gen(exp)
			drop if exp == 0
			gen row = _n
			replace Subject = "eng" if mod(row,2) == 0
			replace Subject = "read" if mod(row,2) !=0
			drop exp row
			append using "`temp1'"
			save "${EDFacts}/20`year'/edfacts`type'20`year'`lvl'wyoming.dta", replace
			clear
        }
    }
}

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'.dta", clear
				keep if stnam == "WYOMING"
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
				save "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'wyoming.dta", replace
			}
		}
	}
}

foreach year of local edyears2 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts}/`year'/edfacts`type'`year'math`lvl'wyoming.dta", clear
			append using "${EDFacts}/`year'/edfacts`type'`year'ela`lvl'wyoming.dta"
			if ("`lvl'" == "school"){
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
			//Using ELA for eng and read
			tempfile temp1
			save "`temp1'", replace
			keep if Subject == "ela"
			expand 3, gen(exp)
			drop if exp == 0
			gen row = _n
			replace Subject = "eng" if mod(row,2) == 0
			replace Subject = "read" if mod(row,2) !=0
			drop exp row
			append using "`temp1'"
			save "${EDFacts}/`year'/edfacts`type'`year'`lvl'wyoming.dta", replace
		}
	}
}

//Change AssmtType label
forvalues year = 2014/2024 {
	if `year' == 2020 continue
	
	import delimited "${Output}/WY_AssmtData_`year'", case(preserve) clear
	replace AssmtType = "Regular and alt"
	export delimited "WY_AssmtData_`year'", replace
	


}

//Conversion to DTA
forvalues year = 2014/2021 {
if `year' == 2020 continue
import delimited "WY_AssmtData_`year'", case(preserve) clear

	
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
merge 1:1 NCESDistrictID StudentSubGroup GradeLevel Subject using "${EDFacts}/`year'/edfactspart`year'districtwyoming.dta", gen(DistMerge)
drop if DistMerge == 2
save "`tempdist'", replace
clear

//School Merge
use "`tempsch'"
duplicates report NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject
duplicates drop NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject, force
merge 1:1 NCESDistrictID NCESSchoolID StudentSubGroup GradeLevel Subject using "${EDFacts}/`year'/edfactspart`year'schoolwyoming.dta", gen(SchMerge)
drop if SchMerge == 2
save "`tempsch'", replace
clear

//Combining DataLevels
use "`tempall'"
keep if DataLevel == 1
append using "`tempdist'" "`tempsch'"

//Adding "AllStudents" Count
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudentsTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudentsTested = AllStudentsTested[_n-1] if missing(AllStudentsTested)
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup GradeLevel Subject DistName SchName)
replace StudentSubGroup_TotalTested = string(real(AllStudentsTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & !missing(real(AllStudentsTested)) & real(AllStudentsTested) - UnsuppressedSG >=0 & UnsuppressedSG > 0 & StudentGroup != "RaceEth" & StudentSubGroup != "EL Exited" & StudentSubGroup != "All Students"
drop Unsuppressed* AllStudentsTested


//New Participation Data
replace ParticipationRate = Participation if !missing(Participation)

{
replace StateAssignedDistID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 1 // State
replace StateAssignedSchID = "000000" if DataLevel== 2 // District
egen uniquegrp = group(SchYear DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup 
by uniquegrp: gen AllStudents = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by uniquegrp: replace AllStudents = AllStudents[_n-1] if missing(AllStudents)
drop StudentGroup_TotalTested
rename AllStudents StudentGroup_TotalTested
replace StateAssignedDistID = "" if DataLevel ==1
replace StateAssignedSchID = "" if DataLevel != 3
}

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${New_Output}/WY_AssmtData_`year'", replace
export delimited "${New_Output}/WY_AssmtData_`year'", replace
}

