clear
set more off

cd "/Volumes/T7/State Test Project/New Mexico"

global NCESSchool "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCESDistrict "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/New Mexico/NCES"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

** Preparing EDFacts files

local edyears1 17 18
local subject math ela
local datatype count part
local datalevel school district

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				local prevyear = `year' - 1
				use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
				keep if STNAM == "NEW MEXICO"
				drop DATE_CUR
				rename *_`prevyear'`year' *
				if ("`sub'" == "math") {
					rename *_MTH* **
				}
				if ("`sub'" == "ela") {
					rename *_RLA* **
				}
				if ("`type'" == "count") {
					rename *NUMVALID Count*
					drop *PCTPROF
				}
				if ("`type'" == "part") {
					rename *PCTPART Participation*
					drop *NUMPART
				}
				drop *HS 
				if ("`lvl'" == "school") & ("`type'" == "count") {
					reshape long Count, i(NCESSCH) j(StudentSubGroup) string
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") & ("`type'" == "count") {
					reshape long Count, i(LEAID) j(StudentSubGroup) string
					gen DataLevel = 2
				}
				if ("`lvl'" == "school") & ("`type'" == "part") {
					reshape long Participation, i(NCESSCH) j(StudentSubGroup) string
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") & ("`type'" == "part") {
					reshape long Participation, i(LEAID) j(StudentSubGroup) string
					gen DataLevel = 2
				}				
				gen Subject = "`sub'"
				save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'newmexico.dta", replace
			}
		}
	}
}

foreach year of local edyears1 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts}/20`year'/edfacts`type'20`year'math`lvl'newmexico.dta", clear
			append using "${EDFacts}/20`year'/edfacts`type'20`year'ela`lvl'newmexico.dta"
			if ("`lvl'" == "school"){
				rename NCESSCH NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			rename LEAID NCESDistrictID
			tostring NCESDistrictID, replace
			if ("`type'" == "count") {
				drop if Count == .
			}
			if ("`type'" == "part") {
				drop if Participation == "" | Participation == "."
				replace Participation = "--" if Participation == "n/a"
				replace Participation = "*" if Participation == "PS"
				if (`year' == 17) {
					split Participation, parse("-")
					destring Participation1, replace force
					replace Participation1 = Participation1/100
					tostring Participation1, replace format("%9.2g") force
					destring Participation2, replace force
					replace Participation2 = Participation2/100			
					tostring Participation2, replace format("%9.2g") force
					replace Participation = Participation1 + "-" + Participation2 if Participation1 != "." & Participation2 != "."
					replace Participation = Participation1 if Participation1 != "." & Participation2 == "."
					drop Participation1 Participation2
				}
				gen Participation3 = subinstr(Participation, "GE", "", .) if strpos(Participation, "GE") > 0
				replace Participation3 = subinstr(Participation, "LT", "", .) if strpos(Participation, "LT") > 0
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.2g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0
				drop Participation3
			}
			gen GradeLevel = "G" + substr(StudentSubGroup, -2, 2)
			replace GradeLevel = "GZ" if GradeLevel == "G00"
			replace StudentSubGroup = subinstr(StudentSubGroup, substr(StudentSubGroup, -2, 2), "", .)
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
			replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
			replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"
			replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FCS"
			replace StudentSubGroup = "Military" if StudentSubGroup == "MIL"
			gen StudentGroup = "RaceEth"
			replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
			replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
			replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
			replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
			replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
			replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
			replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
			replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
			replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
			save "${EDFacts}/20`year'/edfacts`type'20`year'`lvl'newmexico.dta", replace
		}
	}
}

local edyears2 2019 2021

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'.dta", clear
				keep if STNAM == "NEW MEXICO"
				drop DATE_CUR
				if ("`type'" == "count") {
					rename NUMVALID Count
					drop PCTPROF
				}
				if ("`type'" == "part") {
					rename PCTPART Participation
					drop NUMPART
				}
				rename SUBJECT Subject
				replace Subject = "`sub'"
				if ("`lvl'" == "school") {
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") {
					gen DataLevel = 2
				}
				save "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'newmexico.dta", replace
			}
		}
	}
}

foreach year of local edyears2 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts}/`year'/edfacts`type'`year'math`lvl'newmexico.dta", clear
			append using "${EDFacts}/`year'/edfacts`type'`year'ela`lvl'newmexico.dta"
			if ("`lvl'" == "school"){
				rename NCESSCH NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			rename LEAID NCESDistrictID
			tostring NCESDistrictID, replace
			if ("`type'" == "count") {
				drop if Count == .
			}
			if ("`type'" == "part") {
				drop if Participation == "" | Participation == "."
				replace Participation = "--" if Participation == "n/a"
				replace Participation = "*" if Participation == "PS"
				gen Participation3 = subinstr(Participation, "GE", "", .) if strpos(Participation, "GE") > 0
				replace Participation3 = subinstr(Participation, "LT", "", .) if strpos(Participation, "LT") > 0
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.2g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0
				drop Participation3
			}
			drop if inlist(GRADE, "HS")
			rename GRADE GradeLevel
			replace GradeLevel = "G" + GradeLevel
			replace GradeLevel = "GZ" if GradeLevel == "G00"
			rename CATEGORY StudentSubGroup
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
			replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
			replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"
			replace StudentSubGroup = "Foster Care" if StudentSubGroup == "FCS"
			replace StudentSubGroup = "Military" if StudentSubGroup == "MIL"
			gen StudentGroup = "RaceEth"
			replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
			replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
			replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
			replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
			replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
			replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
			replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
			replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
			replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
			save "${EDFacts}/`year'/edfacts`type'`year'`lvl'newmexico.dta", replace
		}
	}
}

** Preparing NCES files

global years 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_location == "NM"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	keep State StateAbbrev StateFips NCESDistrictID State_leaid DistType CountyName CountyCode DistLocale DistCharter DistName
	
	
	save "${NCES}/NCES_`a'_District.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_location == "NM"
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType	
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName	
	rename ncesschoolid NCESSchoolID
	rename school_name SchName
	if `a' == 2022 rename school_type SchType
	if `a' == 2022 {
		foreach var of varlist SchType SchLevel SchVirtual DistType {
			decode `var', gen(temp)
			drop `var'
			rename temp `var'
		}
	} 
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName sch_lowest_grade_offered
	drop if seasch == ""

	
	save "${NCES}/NCES_`a'_School.dta", replace
	
}
