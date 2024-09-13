clear
set more off

global MS "/Volumes/T7/State Test Project/Mississippi"
global NCESSchool "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCESDistrict "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/Mississippi/NCES"
global EDFacts "/Volumes/T7/State Test Project/EDFACTS"

** Preparing district/school name standardization file

import excel "${MS}/ms_full-dist-sch-stable-list_through2024.xlsx", firstrow clear
tostring NCESDistrictID, replace
recast long NCESSchoolID
format NCESSchoolID %18.0g
tostring NCESSchoolID, replace usedisplayformat
foreach var of varlist NCES* {
			replace `var' = "" if `var' == "."
			}
drop DataLevel
gen DataLevel = 3
duplicates drop NCESDistrictID NCESSchoolID, force
keep NCESDistrictID newdistname olddistname NCESSchoolID newschname oldschname DataLevel
save "${MS}/standardschnames.dta", replace

import excel "${MS}/ms_full-dist-sch-stable-list_through2024.xlsx", firstrow clear
tostring NCESDistrictID, replace
foreach var of varlist NCESDistrictID {
			replace `var' = "" if `var' == "."
			}
drop DataLevel
gen DataLevel = 2
duplicates drop NCESDistrictID, force
keep NCESDistrictID newdistname olddistname DataLevel
save "${MS}/standarddistnames.dta", replace


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
				keep if stnam == "MISSISSIPPI"
                rename *_`prevyear'`year' *
                if ("`sub'" == "math") {
                    rename *_mth* **
                }
                if ("`sub'" == "ela") {
                    rename *_rla* **
                }
                if ("`type'" == "count") {
                    rename *numvalid Count*
                    rename *pctprof Proficient*
                }
                if ("`type'" == "part") {
                    rename *pctpart Participation*
                    drop *numpart
                }
                drop *hs *00 
                if ("`lvl'" == "school") & ("`type'" == "count") {
                    reshape long Count Proficient, i(ncessch) j(StudentSubGroup) string
                    gen DataLevel = 3
                }
                if ("`lvl'" == "district") & ("`type'" == "count") {
                    reshape long Count Proficient, i(leaid) j(StudentSubGroup) string
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
            if ("`lvl'" == "school"){
                rename ncessch NCESSchoolID
            }
            rename leaid NCESDistrictID
			tostring NCESDistrictID, replace
			
			if "`lvl'" == "school" {
			format NCESSchoolID %18.0g
			tostring NCESSchoolID, usedisplayformat replace
			}
			foreach var of varlist NCES* {
			replace `var' = "" if `var' == "."
			}
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
                replace Proficient3 = subinstr(Proficient, "LT", "", .) if strpos(Proficient, "LT") > 0
                replace Proficient3 = subinstr(Proficient, "LE", "", .) if strpos(Proficient, "LE") > 0
                destring Proficient3, replace force
                replace Proficient3 = Proficient3/100
                tostring Proficient3, replace format("%9.2g") force
                replace Proficient = Proficient3 + "-1" if strpos(Proficient, "GE") > 0
                replace Proficient = "0-" + Proficient3 if strpos(Proficient, "LT") > 0 | strpos(Proficient, "LE") > 0
                drop Proficient1 Proficient2 Proficient3
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
            replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
			
			
			
			rename leanm DistName
			if "`lvl'" == "school" rename schnam SchName
			
			save "${EDFacts}/20`year'/edfacts`type'20`year'`lvl'mississippi.dta", replace
			clear
        }
    }
}

local edyears2 2019 2021

foreach year of local edyears2 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
				use "${EDFacts}/`year'/edfacts`type'`year'`sub'`lvl'.dta", clear
				keep if stnam == "MISSISSIPPI"
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
if ("`lvl'" == "school"){
				rename ncessch NCESSchoolID
				format NCESSchoolID %18.0g
				tostring NCESSchoolID, replace usedisplayformat
			}
			rename leaid NCESDistrictID
			tostring NCESDistrictID, replace
			foreach var of varlist NCES* {
			replace `var' = "" if `var' == "."
			}
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
			save "${EDFacts}/`year'/edfacts`type'`year'`lvl'mississippi.dta", replace
		}
	}
}

//Create MS_EFParticipation_2022 if needed!
foreach s in ela math sci {
	import delimited "${MS}/MS_EFParticipation_2022_`s'.csv", case(preserve) clear
	save "${MS}/MS_EFParticipation_2022_`s'.dta", replace
}

use "${MS}/MS_EFParticipation_2022_ela.dta"
append using "${MS}/MS_EFParticipation_2022_math.dta" "${MS}/MS_EFParticipation_2022_sci.dta"


//Rename and Drop Vars
drop SchoolYear State
rename NCESLEAID NCESDistrictID
tostring NCESDistrictID, replace
drop LEA School
rename NCESSCHID NCESSchoolID
format NCESSchoolID %18.0g
tostring NCESSchool, replace usedisplayformat
foreach var of varlist NCES* {
	replace `var' = "" if `var' == "."
}
rename Value Participation
drop DataGroup DataDescription Denominator Numerator Population
rename Subgroup StudentSubGroup
replace StudentSubGroup = Characteristics if missing(StudentSubGroup) & !missing(Characteristics)
rename AgeGrade GradeLevel
rename AcademicSubject Subject
drop ProgramType Outcome Characteristics

//Clean ParticipationRate
foreach var of varlist Participation {
replace `var' = "*" if `var' == "S"	
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
replace `var' = subinstr(`var', "=","",.)
destring `var', gen(n`var') i(*%<>-)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--"
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
drop n`var'
drop range`var'
}

//StudentSubGroup
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") !=0
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
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"


//Subject
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

duplicates drop NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup, force

//Saving EDFacts Output
save "${MS}/MS_EFParticipation_2022", replace


** Preparing NCES files

local ncesyears 2013 2014 2015 2016 2017 2018 2020 2021 2022
use "${NCESDistrict}/NCES_2013_District.dta", clear

foreach a of local ncesyears {
	
	use "${NCESSchool}/NCES_`a'_School.dta", clear

	keep if state_fips == 28
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	rename lea_name DistName
	rename district_agency_type DistType
	rename school_name SchName
	rename county_name CountyName
	
	if(`a' == 2022){
		rename school_type SchType
	}
	
	
	keep State StateFips NCESDistrictID State_leaid StateAbbrev DistName DistType NCESSchoolID SchName seasch CountyName CountyCode DistCharter SchLevel SchVirtual SchType DistLocale
			
	if(`a' == 2021){
		drop if NCESDistrictID == "2800960"
	}
		
	if(`a' > 2019){
		sort DistName SchName
		quietly by DistName SchName: gen dup = cond(_N == 1, 0,_n)
		drop if dup > 0
		drop dup
	}
	
	save "${NCES}/NCES_`a'_School.dta", replace
	
	use "${NCESDistrict}/NCES_`a'_District.dta", clear 

	keep if state_fips == 28
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename *agency_type DistType
	rename county_code CountyCode
	rename lea_name DistName
	rename county_name CountyName
	
	if(`a' == 2022){
		labmask district_agency_type_num, values(DistType)
		drop DistType
		rename district_agency_type_num DistType
	}
	
	keep State StateFips NCESDistrictID State_leaid DistName DistType DistCharter DistLocale CountyCode CountyName StateAbbrev
	
	if(`a' == 2021){
		drop if NCESDistrictID == "2800960"
	}
	
	save "${NCES}/NCES_`a'_District.dta", replace
}
