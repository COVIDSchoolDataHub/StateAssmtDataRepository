clear
set more off

cd "/Users/maggie/Desktop/Mississippi"

global NCESSchool "/Users/maggie/Desktop/Mississippi/NCES/School"
global NCESDistrict "/Users/maggie/Desktop/Mississippi/NCES/District"
global NCES "/Users/maggie/Desktop/Mississippi/NCES/Cleaned"
global EDFacts "/Users/maggie/Desktop/EDFacts/Datasets"

** Preparing EDFacts files

local edyears1 14 15 16 17 18
local subject math ela
local datatype count part
local datalevel school district

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				local prevyear = `year' - 1
				use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
				keep if STNAM == "MISSISSIPPI"
				drop ALL*
				if ("`year'" != "14") {
					drop DATE_CUR
				}
				drop CWD* HOM* MIG*
				rename *_`prevyear'`year' *
				if ("`sub'" == "math") {
					rename *_MTH* **
				}
				if ("`sub'" == "ela") {
					rename *_RLA* **
				}
				if ("`type'" == "count") {
					rename *NUMVALID Count*
					rename *PCTPROF Proficient*
				}
				if ("`type'" == "part") {
					rename *PCTPART Participation*
					drop *NUMPART
				}
				drop *HS *00 
				if ("`lvl'" == "school") & ("`type'" == "count") {
					reshape long Count Proficient, i(NCESSCH) j(StudentSubGroup) string
					gen DataLevel = 3
				}
				if ("`lvl'" == "district") & ("`type'" == "count") {
					reshape long Count Proficient, i(LEAID) j(StudentSubGroup) string
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
				save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'mississippi.dta", replace
			}
		}
	}
}

foreach year of local edyears1 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts}/20`year'/edfacts`type'20`year'math`lvl'mississippi.dta", clear
			append using "${EDFacts}/20`year'/edfacts`type'20`year'ela`lvl'mississippi.dta"
			drop STNAM FIPST
			if ("`lvl'" == "school"){
				rename SCHNAM SchName
				rename NCESSCH NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			rename LEAID NCESDistrictID
			rename LEANM DistName
			tostring NCESDistrictID, replace
			if ("`type'" == "count") {
				drop if Count == .
				drop if Proficient == ""
				replace Proficient = "--" if Proficient == "n/a"
				replace Proficient = "*" if Proficient == "PS"
				split Proficient, parse("-")
				destring Proficient1, replace force
				replace Proficient1 = Proficient1/100
				tostring Proficient1, replace format("%9.2g") force
				destring Proficient2, replace force
				replace Proficient2 = Proficient2/100			
				tostring Proficient2, replace format("%9.2g") force
				replace Proficient = Proficient1 + "-" + Proficient2 if Proficient1 != "." & Proficient2 != "."
				replace Proficient = Proficient1 if Proficient1 != "." & Proficient2 == "."
				gen Proficient3 = subinstr(Proficient, "GE", "", .) if strpos(Proficient, "GE") > 0
				replace Proficient3 = subinstr(Proficient, "GT", "", .) if strpos(Proficient, "GT") > 0
				replace Proficient3 = subinstr(Proficient, "LE", "", .) if strpos(Proficient, "LE") > 0
				replace Proficient3 = subinstr(Proficient, "LT", "", .) if strpos(Proficient, "LT") > 0
				destring Proficient3, replace force
				replace Proficient3 = Proficient3/100
				tostring Proficient3, replace format("%9.2g") force
				replace Proficient = Proficient3 + "-1" if strpos(Proficient, "GE") | strpos(Proficient, "GT") > 0
				replace Proficient = "0-" + Proficient3 if strpos(Proficient, "LE") | strpos(Proficient, "LT") > 0
				drop Proficient1 Proficient2 Proficient3
				rename Count StudentSubGroup_TotalTested
				tostring StudentSubGroup_TotalTested, replace force
				rename Proficient ProficientOrAbove_percent
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
				replace Participation3 = subinstr(Participation, "GT", "", .) if strpos(Participation, "GT") > 0
				replace Participation3 = subinstr(Participation, "LE", "", .) if strpos(Participation, "LE") > 0
				replace Participation3 = subinstr(Participation, "LT", "", .) if strpos(Participation, "LT") > 0
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.2g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") | strpos(Participation, "GT") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LE") | strpos(Participation, "LT") > 0
				drop Participation1 Participation2 Participation3
				rename Participation ParticipationRate
			}
			gen GradeLevel = "G" + substr(StudentSubGroup, -2, 2)
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
			gen StudentGroup = "RaceEth"
			replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
			replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
			replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
			replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
			save "${EDFacts}/20`year'/edfacts`type'20`year'`lvl'mississippi.dta", replace
		}
	}
}

local edyears2 2019 2021

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'.dta", clear
				keep if STNAM == "MISSISSIPPI"
				drop DATE_CUR
				drop if CATEGORY == "ALL"
				if ("`type'" == "count") {
					rename NUMVALID Count
					rename PCTPROF Proficient
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
				save "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'mississippi.dta", replace
			}
		}
	}
}

foreach year of local edyears2 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts}/`year'/edfacts`type'`year'math`lvl'mississippi.dta", clear
			append using "${EDFacts}/`year'/edfacts`type'`year'ela`lvl'mississippi.dta"
			drop STNAM FIPST
			if ("`lvl'" == "district"){
				rename ST_LEAID State_leaid
			}
			if ("`lvl'" == "school"){
				rename SCHNAM SchName
				rename NCESSCH NCESSchoolID
				recast long NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			rename LEAID NCESDistrictID
			rename LEANM DistName
			tostring NCESDistrictID, replace
			if ("`type'" == "count") {
				drop if Count == .
				drop if Proficient == ""
				replace Proficient = "--" if Proficient == "n/a"
				replace Proficient = "*" if Proficient == "PS"
				split Proficient, parse("-")
				destring Proficient1, replace force
				replace Proficient1 = Proficient1/100
				tostring Proficient1, replace format("%9.2g") force
				destring Proficient2, replace force
				replace Proficient2 = Proficient2/100			
				tostring Proficient2, replace format("%9.2g") force
				replace Proficient = Proficient1 + "-" + Proficient2 if Proficient1 != "." & Proficient2 != "."
				replace Proficient = Proficient1 if Proficient1 != "." & Proficient2 == "."
				gen Proficient3 = subinstr(Proficient, "GE", "", .) if strpos(Proficient, "GE") > 0
				replace Proficient3 = subinstr(Proficient, "GE", "", .) if strpos(Proficient, "GT") > 0
				replace Proficient3 = subinstr(Proficient, "LT", "", .) if strpos(Proficient, "LE") > 0
				replace Proficient3 = subinstr(Proficient, "LT", "", .) if strpos(Proficient, "LT") > 0
				destring Proficient3, replace force
				replace Proficient3 = Proficient3/100
				tostring Proficient3, replace format("%9.2g") force
				replace Proficient = Proficient3 + "-1" if strpos(Proficient, "GE") | strpos(Proficient, "GT") > 0
				replace Proficient = "0-" + Proficient3 if strpos(Proficient, "LE") | strpos(Proficient, "LT") > 0
				drop Proficient1 Proficient2 Proficient3
				rename Count StudentSubGroup_TotalTested
				tostring StudentSubGroup_TotalTested, replace force
				rename Proficient ProficientOrAbove_percent
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
				replace Participation3 = subinstr(Participation, "GT", "", .) if strpos(Participation, "GT") > 0
				replace Participation3 = subinstr(Participation, "LE", "", .) if strpos(Participation, "LE") > 0
				replace Participation3 = subinstr(Participation, "LT", "", .) if strpos(Participation, "LT") > 0
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.2g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") | strpos(Participation, "GT") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LE") | strpos(Participation, "LT") > 0
				drop Participation1 Participation2 Participation3
				rename Participation ParticipationRate
			}
			drop if inlist(GRADE, "00", "HS")
			rename GRADE GradeLevel
			replace GradeLevel = "G" + GradeLevel
			drop if inlist(CATEGORY, "CWD", "FCS", "HOM", "MIG", "MIL")
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
			gen StudentGroup = "RaceEth"
			replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
			replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
			replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Female", "Male")
			replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
			save "${EDFacts}/`year'/edfacts`type'`year'`lvl'mississippi.dta", replace
		}
	}
}

** Preparing NCES files

global years 2013 2014 2015 2016 2017 2018 2020 2021

foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_fips == 28
	
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename lea_name DistName
	drop year district_agency_type_num urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator lowest_grade_offered highest_grade_offered number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte
	
	if(`a' == 2021){
		drop if NCESDistrictID == "2800960"
	}
	
	if(`a' != 2021){
                 drop agency_charter_indicator
				}
	
	save "${NCES}/NCES_`a'_District.dta", replace
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear
	keep if state_fips == 28
	
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
	rename school_type SchType
	drop year district_agency_type_num school_id school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_lowest_grade_offered dist_highest_grade_offered dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch
	
	if(`a' == 2021){
		drop if NCESDistrictID == "2800960"
	}
	
	if(`a' > 2019){
		sort DistName SchName
		quietly by DistName SchName: gen dup = cond(_N == 1, 0,_n)
		drop if dup > 0
		drop dup
	}
	
	if(`a' != 2021){
                 drop dist_agency_charter_indicator
              }
	
	save "${NCES}/NCES_`a'_School.dta", replace
	
}
