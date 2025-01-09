****************************************************************
** Preparing EDFacts
****************************************************************

clear

global raw "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Raw"
global temp "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\temp"
global NCESDistrict "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES District Files, Fall 1997-Fall 2022"
global NCESSchool "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\NCES School Files, Fall 1997-Fall 2022"
global EDFacts "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\EdFacts"
global output "C:\Users\Clare\Desktop\Zelma V2.0\Kansas\Output"

****************************************************************
** Cleaning 2015-2018
****************************************************************

local edyears1 15 16 17 18
local edyears2 2019 2021
local subject math ela
local datatype count part
local datalevel school district

{
foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				local prevyear = `year' - 1
				import delimited "${EDFacts}/edfacts`type'20`year'`sub'`lvl'.csv", clear
				keep if stnam == "KANSAS"
				drop date_cur
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
				drop *hs *00 
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
				save "${EDFacts}/edfacts`type'20`year'`sub'`lvl'kansas.dta", replace
				export delimited "${EDFacts}/edfacts`type'20`year'`sub'`lvl'kansas.csv", replace
			}
		}
	}
}

// Appending math and ela files for 2015-2018

foreach year of local edyears1 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			
			use "${EDFacts}/edfacts`type'20`year'math`lvl'kansas.dta", clear
			
			append using "${EDFacts}/edfacts`type'20`year'ela`lvl'kansas.dta"
			
			if ("`lvl'" == "school"){
				rename ncessch NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			
			rename leaid NCESDistrictID
			tostring NCESDistrictID, replace
			if ("`type'" == "count") {
				drop if Count == .
				drop if PctProf == ""
				replace PctProf = "--" if PctProf == "n/a"
				replace PctProf = "*" if PctProf == "PS"
				split PctProf, parse("-")
				destring PctProf1, replace force
				replace PctProf1 = PctProf1/100
				tostring PctProf1, replace format("%9.4g") force
				destring PctProf2, replace force
				replace PctProf2 = PctProf2/100			
				tostring PctProf2, replace format("%9.4g") force
				replace PctProf = PctProf1 + "-" + PctProf2 if PctProf1 != "." & PctProf2 != "."
				replace PctProf = PctProf1 if PctProf1 != "." & PctProf2 == "."
				gen PctProf3 = subinstr(PctProf, "GE", "", .) if strpos(PctProf, "GE") > 0
				replace PctProf3 = subinstr(PctProf, "LT", "", .) if strpos(PctProf, "LT") > 0
				replace PctProf3 = subinstr(PctProf, "LE", "", .) if strpos(PctProf, "LE") > 0
				destring PctProf3, replace force
				replace PctProf3 = PctProf3/100
				tostring PctProf3, replace format("%9.4g") force
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
				tostring Participation1, replace format("%9.4g") force
				destring Participation2, replace force
				replace Participation2 = Participation2/100			
				tostring Participation2, replace format("%9.4g") force
				replace Participation = Participation1 + "-" + Participation2 if Participation1 != "." & Participation2 != "."
				replace Participation = Participation1 if Participation1 != "." & Participation2 == "."
				gen Participation3 = subinstr(Participation, "GE", "", .) if strpos(Participation, "GE") > 0
				replace Participation3 = subinstr(Participation, "LT", "", .) if strpos(Participation, "LT") > 0
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.4g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0
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
			save "${EDFacts}/_edfacts`type'20`year'`lvl'kansas.dta", replace
			}
		}
	}
}

****************************************************************
** Cleaning 2019, 2021
****************************************************************
{
foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				
				import delimited "${EDFacts}/edfacts`type'`year'`sub'`lvl'.csv", clear
				
				keep if stnam == "KANSAS"
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
				save "${EDFacts}/edfacts`type'`year'`sub'`lvl'kansas.dta", replace
			}
		}
	}
}

// Appending math and ela files for 2019, 2021

foreach year of local edyears2 {
	
	foreach type of local datatype {
		
		foreach lvl of local datalevel {
			
			use "${EDFacts}/edfacts`type'`year'math`lvl'kansas.dta", clear
			
			append using "${EDFacts}/edfacts`type'`year'ela`lvl'kansas.dta"
			
			if ("`lvl'" == "school"){
				rename ncessch NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			rename leaid NCESDistrictID
			tostring NCESDistrictID, replace
			if ("`type'" == "count") {
				drop if Count == .
				drop if PctProf == ""
				replace PctProf = "--" if PctProf == "n/a"
				replace PctProf = "*" if PctProf == "PS"
				split PctProf, parse("-")
				destring PctProf1, replace force
				replace PctProf1 = PctProf1/100
				tostring PctProf1, replace format("%9.4g") force
				destring PctProf2, replace force
				replace PctProf2 = PctProf2/100			
				tostring PctProf2, replace format("%9.4g") force
				replace PctProf = PctProf1 + "-" + PctProf2 if PctProf1 != "." & PctProf2 != "."
				replace PctProf = PctProf1 if PctProf1 != "." & PctProf2 == "."
				gen PctProf3 = subinstr(PctProf, "GE", "", .) if strpos(PctProf, "GE") > 0
				replace PctProf3 = subinstr(PctProf, "LT", "", .) if strpos(PctProf, "LT") > 0
				replace PctProf3 = subinstr(PctProf, "LE", "", .) if strpos(PctProf, "LE") > 0
				destring PctProf3, replace force
				replace PctProf3 = PctProf3/100
				tostring PctProf3, replace format("%9.4g") force
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
				tostring Participation1, replace format("%9.4g") force
				destring Participation2, replace force
				replace Participation2 = Participation2/100			
				tostring Participation2, replace format("%9.4g") force
				replace Participation = Participation1 + "-" + Participation2 if Participation1 != "." & Participation2 != "."
				replace Participation = Participation1 if Participation1 != "." & Participation2 == "."
				gen Participation3 = subinstr(Participation, "GE", "", .) if strpos(Participation, "GE") > 0
				replace Participation3 = subinstr(Participation, "LT", "", .) if strpos(Participation, "LT") > 0
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.4g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0
				drop Participation1 Participation2 Participation3
			}
			drop if inlist(grade, "00", "HS")
			rename grade GradeLevel
			replace GradeLevel = "G" + GradeLevel
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
			
			save "${EDFacts}/_edfacts`type'`year'`lvl'kansas.dta", replace
			}
		}
	}
}

****************************************************************
** Cleaning 2022
****************************************************************

local lev "state district school"

foreach v of local lev{
	
	import delimited "${EDFacts}/edfacts2022`v'.csv", clear

	gen DataLevel = "`v'"
	rename ncesschid NCESSchoolID
	rename ncesleaid NCESDistrictID

	rename agegrade GradeLevel
	drop if inlist(GradeLevel, "High School", "All Grades")
	replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0", .)

	rename academicsubject Subject
	replace Subject = "ela" if Subject == "Reading/Language Arts"
	replace Subject = "math" if Subject == "Mathematics"
	replace Subject = "sci" if Subject == "Science"

	drop if characteristics == "Missing"
	replace subgroup = characteristics if characteristics != ""
	drop population characteristics
	rename subgroup StudentSubGroup

	replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students in SEA"
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native/Native American"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic) African American"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multicultural/Multiethnic/Multiracial/other"
	replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian (not Hispanic)"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
	replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory students"
	replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
	replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"

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

	replace datadescription = "Participation" if strpos(datadescription, "Participation") > 0
	replace datadescription = "Performance" if strpos(datadescription, "Performance") > 0
	rename denominator Count
	drop numerator outcome datagroup programtype
	reshape wide value Count, i(state NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup) j(datadescription) str
	
	drop CountParticipation
	
	rename valueParticipation Participation
	rename valuePerformance PctProf
	
	local vars "Participation PctProf"
	foreach var of local vars{
		replace `var' = subinstr(`var', "%", "", .)
		gen Above = 0
		replace Above = 1 if strpos(`var', ">=") > 0 | strpos(`var', ">") > 0
		replace `var' = subinstr(`var', ">=", "", .) if Above == 1
		replace `var' = subinstr(`var', ">", "", .) if Above == 1
		gen Below = 0
		replace Below = 1 if strpos(`var', "<=") > 0 | strpos(`var', "<") > 0
		replace `var' = subinstr(`var', "<=", "", .) if Below == 1
		replace `var' = subinstr(`var', "<", "", .) if Below == 1
		split `var', parse("-")
		replace `var'1 = "-1" if `var' == "S"
		destring `var'1, replace
		replace `var'1 = `var'1/100
		replace `var'1 = . if `var'1 < 0
		tostring `var'1, replace format("%9.4g") force
		
		if DataLevel == "school"{
			destring `var'2, replace
			replace `var'2 = `var'2/100
			replace `var'2 = . if `var'2 < 0
			tostring `var'2, replace format("%9.4g") force
			replace `var' = `var'1 + "-" + `var'2 if `var'2 != "."
			drop `var'2
		}
		
		replace `var' = `var'1
		replace `var' = "*" if `var'1 == "."
		replace `var' = `var'1 + "-1" if Above == 1
		replace `var' = "0-" + `var'1 if Below == 1
		drop Above Below `var'1
	}
	
	if DataLevel == "state"{
		tostring lea, replace
	}
	
	if DataLevel != "school"{
		tostring school, replace
	}
	
	* for KS specifically
	drop if state != "KANSAS"
	drop if StudentSubGroup == "Asian/Pacific Islander" // this is an aggregate of Asian and "Native Hawaiian or Other Pacific Islander". We have these as separate categories, so we do not need this aggregate
	
	replace DataLevel = "State" if DataLevel == "state"
	replace DataLevel = "District" if DataLevel == "district"
	replace DataLevel = "School" if DataLevel == "school"
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel
	
	rename CountPerformance Count
	
	save "${EDFacts}/_edfacts2022`v'kansas.dta", replace
}


// Appending 2022 files 
{
use "${EDFacts}/_edfacts2022statekansas.dta", clear

	append using "${EDFacts}/_edfacts2022districtkansas.dta" "${EDFacts}/_edfacts2022schoolkansas.dta"
		
	save "${EDFacts}/_edfacts2022kansas.dta", replace

}
