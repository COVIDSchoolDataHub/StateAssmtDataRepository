clear all
set more off

local edyears1 15 16 17 18
local subject math ela
local datatype count part
local datalevel school district

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				import delimited "${edfacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.csv", clear
				save "${edfacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", replace
			}
		}
	}
}

*/
foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				if `year' == 18 & "`datatype'" == "part" continue
				local prevyear = `year' - 1
				use "${edfacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
				drop date_cur
				keep if stnam == "WEST VIRGINIA"
				rename *_`prevyear'`year' *
				if ("`sub'" == "math") {
					rename *_mth* **
				}
				if ("`sub'" == "ela") {
					rename *_rla* **
				}
				if ("`type'" == "count") {
					rename *numvalid Count*
					rename *pctprof PctProf*
				}
				if ("`type'" == "part") {
					rename *pctpart Participation*
					drop *numpart
				}
				drop *hs
				if ("`lvl'" == "school") & ("`type'" == "count") {
					reshape long Count PctProf, i(ncessch) j(StudentSubGroup) string
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") & ("`type'" == "count") {
					reshape long Count PctProf, i(leaid) j(StudentSubGroup) string
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
				save "${counts}/WV_edfacts`type'20`year'`sub'`lvl'.dta", replace
			}
		}
	}
}

foreach year of local edyears1 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${counts}/WV_edfacts`type'20`year'math`lvl'.dta", clear
			append using "${counts}/WV_edfacts`type'20`year'ela`lvl'.dta"
			if ("`lvl'" == "school"){
				rename ncessch NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			rename leaid NCESDistrictID
			tostring NCESDistrictID, replace
			if "`type'" == "count" {
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
			gen GradeLevel = "G" + substr(StudentSubGroup, -2, 2)
			replace GradeLevel = "G38" if GradeLevel == "G00"
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
			replace StudentSubGroup = "Migrant" if StudentSubGroup == "mig"
			replace StudentSubGroup = "Homeless" if StudentSubGroup == "hom"
			replace StudentSubGroup = "Military" if StudentSubGroup == "mil"
			replace StudentSubGroup = "Foster Care" if StudentSubGroup == "fcs"
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
			save "${counts}/WV_edfacts`type'20`year'`lvl'.dta", replace
			
		}
		
	}
}

local edyears2 2019 2021

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach lvl of local datalevel {
			import delimited "${edfacts}/`year'/edfactscount`year'`sub'`lvl'.csv", clear
			save "${edfacts}/`year'/edfactscount`year'`sub'`lvl'.dta", replace
		}
	}
}

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${edfacts}/`year'/edfactscount`year'`sub'`lvl'.dta", clear
				keep if stnam == "WEST VIRGINIA"
				drop date_cur
				rename numvalid Count
				rename pctprof PctProf
				rename subject Subject
				replace Subject = "`sub'"
				if ("`lvl'" == "school") {
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") {
					gen DataLevel = 2
				}
				save "${counts}/WV_edfactscount`year'`sub'`lvl'.dta", replace
			}
		}
	}
}

foreach year of local edyears2 {
	foreach lvl of local datalevel {
		use "${counts}/WV_edfactscount`year'math`lvl'.dta", clear
		append using "${counts}/WV_edfactscount`year'ela`lvl'.dta"
		if ("`lvl'" == "school"){
			rename ncessch NCESSchoolID
			recast long NCESSchoolID
			format NCESSchoolID %18.0g
			tostring NCESSchoolID, replace usedisplayformat
		}
		rename leaid NCESDistrictID
		tostring NCESDistrictID, replace
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
		save "${counts}/WV_edfactscount`year'`lvl'.dta", replace
	}
}

forvalues year = 2015/2017{
	use "${counts}/WV_edfactscount`year'school.dta", clear
	merge 1:1 NCESSchoolID Subject GradeLevel StudentSubGroup using "${counts}/WV_edfactspart`year'school.dta", nogen
	save "${counts}/WV_edfacts`year'school.dta", replace
	use "${counts}/WV_edfactscount`year'district.dta", clear
	merge 1:1 NCESDistrictID Subject GradeLevel StudentSubGroup using "${counts}/WV_edfactspart`year'district.dta", nogen
	append using "${counts}/WV_edfacts`year'school.dta"
	save "${counts}/WV_edfacts`year'.dta", replace
}

forvalues year = 2018/2021{
	if `year' == 2020 continue
	use "${counts}/WV_edfactscount`year'school.dta", clear
	append using "${counts}/WV_edfactscount`year'district.dta"
	save "${counts}/WV_edfacts`year'.dta", replace
}

import excel "$data/WV_SY18to24_Subgroup_Participation-Enroll_19Feb2025.xlsx", sheet ("State Subgroup Enrollment") cellrange(A2) firstrow clear

//IDs
gen DataLevel = 1
gen NCESDistrictID = ""
gen NCESSchoolID = ""
drop Dist District

//Rename Variables
rename PopulationGroup StudentGroup
rename Subgroup StudentSubGroup

rename Grade03 Grade03math
rename Grade04 Grade04math
rename Grade05 Grade05math
rename Grade06 Grade06math
rename Grade07 Grade07math
rename Grade08 Grade08math
rename Grade11 Grade11math

rename M Grade03ela
rename N Grade04ela
rename O Grade05ela
rename P Grade06ela
rename Q Grade07ela
rename R Grade08ela
rename S Grade11ela

rename T Grade05sci
rename U Grade08sci
rename V Grade11sci

rename Grade* StudentsGrade*

//Reshape Data
reshape long Students, i(Year StudentGroup StudentSubGroup) j(GradeLevel) string
replace Students = subinstr(Students, "≤", "0-", 1)

//Subject & GradeLevel
gen Subject = substr(GradeLevel, 8, 4)
replace GradeLevel = subinstr(GradeLevel, Subject, "", 1)
replace GradeLevel = subinstr(GradeLevel, "rade", "", 1)
drop if GradeLevel == "G11"

//StudentGroup & StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Direct Cert"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-racial"

replace StudentGroup = "All Students" if StudentGroup == "Total Population"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

//Separate By Year
forvalues year = 2018/2024{
	if `year' == 2020 continue
	local prevyear =`=`year'-1'
	local schyear "`prevyear'-`year'"
	preserve
	keep if Year == "`schyear'"
	drop Year
	save "$counts/WV_StateCounts_`year'", replace
	restore
}
