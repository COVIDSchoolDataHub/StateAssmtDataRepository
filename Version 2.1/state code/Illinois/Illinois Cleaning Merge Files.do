clear
set more off

cd "/Users/miramehta/Documents"

global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCES "/Users/miramehta/Documents/Illinois/NCES"
global EDFacts "/Users/miramehta/Documents/EDFacts"

** Converting EDFacts files to .dta Format, hide after first run
/*
forvalues year = 2015/2021 {
	if `year' == 2020 continue
	foreach datatype in count part {
		foreach sub in math ela {
			foreach lvl in school district {
				clear
				import delimited "${EDFacts}/`year'/edfacts`datatype'`year'`sub'`lvl'", case(preserve)
				save "${EDFacts}/`year'/edfacts`datatype'`year'`sub'`lvl'", replace
			}
		}
	}
}
*/

** Preparing EDFacts files

local edyears1 15 16 17 18
local subject math ela
local datatype count part
local datalevel school district

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				local prevyear = `year' - 1
				use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
				keep if STNAM == "ILLINOIS"
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
				drop *HS *00 
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
				save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'illinois.dta", replace
			}
		}
	}
}

foreach year of local edyears1 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts}/20`year'/edfacts`type'20`year'math`lvl'illinois.dta", clear
			append using "${EDFacts}/20`year'/edfacts`type'20`year'ela`lvl'illinois.dta"
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
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.2g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0
				drop Participation1 Participation2 Participation3
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
			
			save "${EDFacts}/20`year'/edfacts`type'20`year'`lvl'illinois.dta", replace
		}
	}
}

local edyears2 2019 2021

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'.dta", clear
				keep if STNAM == "ILLINOIS"
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
				save "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'illinois.dta", replace
			}
		}
	}
}

foreach year of local edyears2 {
	foreach type of local datatype {
		foreach lvl of local datalevel {
			use "${EDFacts}/`year'/edfacts`type'`year'math`lvl'illinois.dta", clear
			append using "${EDFacts}/`year'/edfacts`type'`year'ela`lvl'illinois.dta"
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
				destring Participation3, replace force
				replace Participation3 = Participation3/100
				tostring Participation3, replace format("%9.2g") force
				replace Participation = Participation3 + "-1" if strpos(Participation, "GE") > 0
				replace Participation = "0-" + Participation3 if strpos(Participation, "LT") > 0
				drop Participation1 Participation2 Participation3
			}
			drop if inlist(GRADE, "00", "HS")
			rename GRADE GradeLevel
			replace GradeLevel = "G" + GradeLevel
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
			save "${EDFacts}/`year'/edfacts`type'`year'`lvl'illinois.dta", replace
		}
	}
}

** 2022
clear


//Importing
import delimited "${raw}/edfactscountpartelasci2022Illinois", case(preserve) clear

save "${raw}/edfactscountpartelasci2022Illinois", replace

use "${raw}/edfactscountpartelasci2022Illinois", clear


//Keep Relevant Data
keep if strpos(DataDescription, "Performance") !=0
drop SchoolYear State DataGroup Value Numerator ProgramType Outcome DataDescription Population

//Rename Vars
rename NCESLEAID NCESDistrictID
rename LEA DistName
rename School SchName
rename NCESSCHID NCESSchoolID
rename Denominator StudentSubGroup_TotalTested
replace Subgroup = Characteristics if Characteristics == "Male" | Characteristics == "Female"
drop Characteristics
rename Subgroup StudentSubGroup 
rename AgeGrade GradeLevel
rename AcademicSubject Subject
drop SchName DistName

//DataLevel
gen DataLevel = ""
replace DataLevel = "State" if missing(NCESDistrictID) & missing(NCESSchoolID)
replace DataLevel = "District" if missing(NCESSchoolID) & !missing(NCESDistrictID)
replace DataLevel = "School" if !missing(NCESSchoolID) & !missing(NCESDistrictID)

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel

//StudentSubGroup
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian") !=0
drop if StudentSubGroup == "Asian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic) African American"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"\
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory students"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Multicultural") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Native Hawaiian") !=0
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "Caucasian") !=0

//StudentGroup
gen StudentGroup = "RaceEth"
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Disability Status" if strpos(StudentSubGroup, "SWD") !=0

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

//Subject
replace Subject = "ela" if strpos(Subject, "Reading") !=0
replace Subject = "sci" if strpos(Subject, "Science") !=0
**Using ela counts for math since math counts aren't included
expand 2 if Subject == "ela", gen(ind)
replace Subject = "math" if ind !=0
drop ind

//NCESDistrictID & NCESSchoolID
tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format("%20.9g")
replace NCESDistrictID = "" if NCESDistrictID == "."
replace NCESSchoolID = "" if NCESSchoolID == "."

rename StudentSubGroup_TotalTested StudentSubGroup_TotalTested1
save "$EDFacts/2022/IL_cleaned_EDFacts_2022_ela_sci", replace
clear

** Preparing NCES files

global years 2014 2015 2016 2017 2018 2020 2021 2022

foreach a in $years {
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 
	keep if state_location == "IL"
	
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
	keep if state_location == "IL"
	
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
	keep State StateAbbrev StateFips NCESDistrictID NCESSchoolID State_leaid DistType CountyName CountyCode DistLocale DistCharter SchName SchType SchVirtual SchLevel seasch DistName
	drop if seasch == ""
	
	
	save "${NCES}/NCES_`a'_School.dta", replace
	
}
