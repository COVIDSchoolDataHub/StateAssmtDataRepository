*******************************************************
* ARIZONA

* File name: 02_AZ EDFacts
* Last update: 2/19/2025

*******************************************************
* Notes

	* This do file reads EDFacts files from 2010 through 2022 one by one.
	* It keeps only AZ observations and saves it in the EDFacts_AZ folder. 
	* This code will need to be updated when newer EDFacts files are released. 

*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

***Code to convert EDFacts csv files to dta***
clear
set more off

local year1 2013 2014 2015 2016 2017 2018 2019 2021
local year2 2010 2011 2012
local subject ela math
local datatype count part
local datalevel district school

** Converting to dta **

foreach yr of local year2 {
	foreach sub of local subject {
		foreach lvl of local datalevel {
			if (`yr' != 2011) | ("`lvl'" != "school") {
				import delimited "${EDFacts}/`yr'/edfactscount`yr'`sub'`lvl'.csv", case(lower) clear
				save "${EDFacts}/`yr'/edfactscount`yr'`sub'`lvl'.dta", replace
			}
		}
	}
}

foreach sub of local subject {
	foreach lvl of local datalevel {
		import delimited "${EDFacts}/2011/edfactscount2011`sub'school.csv", rowrange(3:) case(lower) clear
		save "${EDFacts}/2011/edfactscount2011`sub'school.dta", replace
	}
}

foreach yr of local year1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				import delimited "${EDFacts}/`yr'/edfacts`type'`yr'`sub'`lvl'.csv", case(lower) clear
				save "${EDFacts}/`yr'/edfacts`type'`yr'`sub'`lvl'.dta", replace
			}
		}
	}
}



** Preparing EDFacts files

local edyears1 10 11 12
local edyears2 13 14 15 16
local subject math ela
local datatype count part
local datalevel school district

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach lvl of local datalevel {
				local prevyear = `year' - 1
				use "${EDFacts}/20`year'/edfactscount20`year'`sub'`lvl'.dta", clear
				keep if stnam == "ARIZONA"
				if (`year' == 10) {
					rename *_0910 *
				}
				if (`year' != 10) {
					rename *_`prevyear'`year' *
				}
				if ("`sub'" == "math") {
					rename *_mth* **
				}
				if ("`sub'" == "ela") {
					rename *_rla* **
				}
				rename *numvalid Count*
				drop *pctprof
				drop *hs *00 
				if ("`lvl'" == "school") {
					reshape long Count, i(ncessch) j(StudentSubGroup) string
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") {
					reshape long Count, i(leaid) j(StudentSubGroup) string
					gen DataLevel = 2
				}			
				gen Subject = "`sub'"
				save "${EDFacts_AZ}/edfactscount20`year'`sub'`lvl'AZ.dta", replace
		}
	}
}

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				local prevyear = `year' - 1
				use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
				keep if stnam == "ARIZONA"
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
				save "${EDFacts_AZ}/edfacts`type'20`year'`sub'`lvl'AZ.dta", replace
			}
		}
	}
}

foreach year of local edyears1 {
	foreach lvl of local datalevel {
		use "${EDFacts_AZ}/edfactscount20`year'math`lvl'AZ.dta", clear
		append using "${EDFacts_AZ}/edfactscount20`year'ela`lvl'AZ.dta"
		if ("`lvl'" == "school"){
			rename ncessch NCESSchoolID
			recast long NCESSchoolID
			format NCESSchoolID %18.0g
			tostring NCESSchoolID, replace usedisplayformat
			replace NCESSchoolID = "0" + NCESSchoolID
		}
		rename leaid NCESDistrictID
		tostring NCESDistrictID, replace
		replace NCESDistrictID = "0" + NCESDistrictID
		drop if Count == .
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
		save "${EDFacts_AZ}/edfactscount20`year'`lvl'AZ.dta", replace
	}
}

foreach year of local edyears2 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts_AZ}/edfacts`type'20`year'math`lvl'AZ.dta", clear
			append using "${EDFacts_AZ}/edfacts`type'20`year'ela`lvl'AZ.dta"
			if ("`lvl'" == "school"){
				rename ncessch NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
				replace NCESSchoolID = "0" + NCESSchoolID
			}
			rename leaid NCESDistrictID
			tostring NCESDistrictID, replace
			replace NCESDistrictID = "0" + NCESDistrictID
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
			save "${EDFacts_AZ}/edfacts`type'20`year'`lvl'AZ.dta", replace
		}
	}
}
* END of 02_AZ EDFacts.do
****************************************************
