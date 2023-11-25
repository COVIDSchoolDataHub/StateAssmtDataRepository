clear
set more off

global path "/Users/willtolmie/Documents/State Repository Research/Illinois"
global NCESSchool "/Users/willtolmie/Documents/State Repository Research/NCES/School"
global NCESDistrict "/Users/willtolmie/Documents/State Repository Research/NCES/District"
global NCES "/Users/willtolmie/Documents/State Repository Research/NCES/Cleaned"
global EDFacts "/Users/willtolmie/Documents/State Repository Research/EDFacts"

local edyears1 15 16 17 18
local subject math ela
local datatype count
local datalevel school

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		keep if GRADE == "HS"
		replace GRADE = "00"
		rename NUMVALID NUMHS
		rename PCTPROF PCTPROFHS
		keep NCESSCH CATEGORY NUMHS PCTPROFHS SUBJECT GRADE
		save tmp, replace
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		merge m:1 NCESSCH SUBJECT CATEGORY GRADE using tmp.dta
		destring NUMVALID, replace
		destring NUMHS, replace
		replace NUMVALID = NUMVALID - NUMHS if NUMHS != .
		drop if GRADE == "HS"
		keep NCESSCH LEAID NUMVALID CATEGORY GRADE SUBJECT PCTPROF PCTPROFHS
		gen DataLevel = "School"
		rename NCESSCH NCESSchoolID
		rename LEAID NCESDistrictID
		rename NUMVALID StudentSubGroup_TotalTestedNEW
		rename CATEGORY StudentSubGroup
		rename GRADE GradeLevel
		rename SUBJECT Subject
		rename PCTPROF ProficientOrAbove_percentNEW
		replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
		replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
		replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
		replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
		replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
		replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
		replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
		replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
		replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
		replace StudentSubGroup = "Female" if StudentSubGroup == "F"
		replace StudentSubGroup = "Male" if StudentSubGroup == "M"
		drop if StudentSubGroup == "HOM" | StudentSubGroup == "MIG" | StudentSubGroup == "FCS" | StudentSubGroup == "MIL" | StudentSubGroup ==  "CWD"
		replace GradeLevel = "38" if GradeLevel == "00"
		replace GradeLevel = "G" + GradeLevel
		replace Subject = "`sub'"
		save tmp, replace
		
		** Generate Student Group Data
		keep if StudentSubGroup == "All Students"
		keep NCESSchoolID Subject Grade StudentSubGroup_TotalTested
		rename StudentSubGroup_TotalTested StudentGroup_TotalTestedNEW
		merge 1:m NCESSchoolID GradeLevel using tmp.dta
		drop _merge	
		save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'illinois.dta", replace
			}
		}
	}
}

local datatype part

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		keep if GRADE == "HS"
		replace GRADE = "00"
		rename PCTPART PCTPARTHS
		keep NCESSCH CATEGORY PCTPARTHS SUBJECT GRADE
		save tmp, replace
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		merge m:1 NCESSCH SUBJECT CATEGORY GRADE using tmp.dta
		drop if GRADE == "HS"
		keep NCESSCH LEAID CATEGORY GRADE SUBJECT PCTPART PCTPARTHS
		gen DataLevel = "School"
		rename NCESSCH NCESSchoolID
		rename LEAID NCESDistrictID
		rename CATEGORY StudentSubGroup
		rename GRADE GradeLevel
		rename SUBJECT Subject
		rename PCTPART ParticipationRateNEW
		replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
		replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
		replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
		replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
		replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
		replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
		replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
		replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
		replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
		replace StudentSubGroup = "Female" if StudentSubGroup == "F"
		replace StudentSubGroup = "Male" if StudentSubGroup == "M"
		drop if StudentSubGroup == "HOM" | StudentSubGroup == "MIG" | StudentSubGroup == "FCS" | StudentSubGroup == "MIL" | StudentSubGroup ==  "CWD" 
		replace GradeLevel = "38" if GradeLevel == "00"
		replace GradeLevel = "G" + GradeLevel
		replace Subject = "`sub'"
		merge 1:1 DataLevel NCESSchoolID NCESDistrictID StudentSubGroup Subject GradeLevel using "${EDFacts}/20`year'/edfactscount20`year'`sub'`lvl'illinois.dta"
		drop _merge
		save "${EDFacts}/20`year'/edfacts20`year'`sub'`lvl'illinois.dta", replace
			}
		}
	}
}

local datalevel district

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		keep if GRADE == "HS"
		replace GRADE = "00"
		rename PCTPART PCTPARTHS
		keep LEAID CATEGORY PCTPARTHS SUBJECT GRADE
		save tmp, replace
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		merge m:1 LEAID SUBJECT CATEGORY GRADE using tmp.dta
		drop if GRADE == "HS"
		keep LEAID CATEGORY GRADE SUBJECT PCTPART PCTPARTHS
		gen DataLevel = "District"
		rename LEAID NCESDistrictID
		rename CATEGORY StudentSubGroup
		rename GRADE GradeLevel
		rename SUBJECT Subject
		rename PCTPART ParticipationRateNEW
		replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
		replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
		replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
		replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
		replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
		replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
		replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
		replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
		replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
		replace StudentSubGroup = "Female" if StudentSubGroup == "F"
		replace StudentSubGroup = "Male" if StudentSubGroup == "M"
		drop if StudentSubGroup == "HOM" | StudentSubGroup == "MIG" | StudentSubGroup == "FCS" | StudentSubGroup == "MIL" | StudentSubGroup ==  "CWD"
		replace GradeLevel = "38" if GradeLevel == "00"
		replace GradeLevel = "G" + GradeLevel
		replace Subject = "`sub'"
		save "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'illinois.dta", replace
			}
		}
	}
}

local datatype count

foreach year of local edyears1 {
	foreach sub of local subject {
		foreach type of local datatype {
			foreach lvl of local datalevel {
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		keep if GRADE == "HS"
		replace GRADE = "00"
		rename NUMVALID NUMHS
		rename PCTPROF PCTPROFHS
		keep LEAID CATEGORY NUMHS PCTPROFHS SUBJECT GRADE
		save tmp, replace
		use "${EDFacts}/20`year'/edfacts`type'20`year'`sub'`lvl'.dta", clear
		keep if STNAM == "ILLINOIS"
		merge m:1 LEAID SUBJECT CATEGORY GRADE using tmp.dta
		destring NUMVALID, replace
		destring NUMHS, replace
		replace NUMVALID = NUMVALID - NUMHS if NUMHS != .
		drop if GRADE == "HS"
		keep LEAID NUMVALID CATEGORY GRADE SUBJECT PCTPROF PCTPROFHS
		gen DataLevel = "District"
		rename LEAID NCESDistrictID
		rename NUMVALID StudentSubGroup_TotalTestedNEW
		rename CATEGORY StudentSubGroup
		rename GRADE GradeLevel
		rename SUBJECT Subject
		rename PCTPROF ProficientOrAbove_percentNEW
		replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
		replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
		replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
		replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
		replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
		replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
		replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
		replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
		replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
		replace StudentSubGroup = "Female" if StudentSubGroup == "F"
		replace StudentSubGroup = "Male" if StudentSubGroup == "M"
		drop if StudentSubGroup == "HOM" | StudentSubGroup == "MIG" | StudentSubGroup == "FCS" | StudentSubGroup == "MIL" | StudentSubGroup ==  "CWD"
		replace GradeLevel = "38" if GradeLevel == "00"
		replace GradeLevel = "G" + GradeLevel
		replace Subject = "`sub'"
		save tmp, replace
		
		** Generate Student Group Data
		keep if StudentSubGroup == "All Students"
		keep NCESDistrictID Subject Grade StudentSubGroup_TotalTested
		rename StudentSubGroup_TotalTested StudentGroup_TotalTestedNEW
		merge 1:m NCESDistrictID GradeLevel using tmp.dta
		drop _merge	
		merge 1:1 DataLevel NCESDistrictID StudentSubGroup Subject GradeLevel using "${EDFacts}/20`year'/edfactspart20`year'`sub'`lvl'illinois.dta"
		drop _merge
		save "${EDFacts}/20`year'/edfacts20`year'`sub'`lvl'illinois.dta", replace
			}
		}
	}
}

foreach year of local edyears1 {
	use "${EDFacts}/20`year'/edfacts20`year'eladistrictillinois.dta"
	append using "${EDFacts}/20`year'/edfacts20`year'mathdistrictillinois.dta" 
	collapse (sum) StudentSubGroup_TotalTestedNEW, by(Subject GradeLevel StudentSubGroup)
	gen DataLevel = "State"
	save tmp.dta, replace
	keep if StudentSubGroup == "All Students"
	drop StudentSubGroup
	rename StudentSubGroup_TotalTestedNEW StudentGroup_TotalTestedSTATE
	save tmp2.dta, replace
	use tmp.dta
	append using "${EDFacts}/20`year'/edfacts20`year'eladistrictillinois.dta" "${EDFacts}/20`year'/edfacts20`year'mathdistrictillinois.dta"  "${EDFacts}/20`year'/edfacts20`year'elaschoolillinois.dta" "${EDFacts}/20`year'/edfacts20`year'mathschoolillinois.dta" 
	gen StudentGroup="RaceEth" if StudentSubGroup== "Black or African American" | StudentSubGroup=="Two or More" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Asian" | StudentSubGroup=="Hispanic or Latino" | StudentSubGroup=="White" | StudentSubGroup=="American Indian or Alaska Native"
	replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
	replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
	replace StudentGroup="EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup=="English Proficient" | StudentSubGroup=="Other"
	replace StudentGroup="All Students" if StudentSubGroup=="All Students"
	expand 2 if StudentSubGroup=="Economically Disadvantaged", gen(dupindicator)
	replace StudentSubGroup="Not Economically Disadvantaged" if dupindicator == 1
	expand 2 if StudentSubGroup=="English Learner", gen(dupindicator2)
	replace StudentSubGroup="English Proficient" if dupindicator2 == 1
	replace StudentSubGroup_TotalTestedNEW = (StudentGroup_TotalTestedNEW - StudentSubGroup_TotalTestedNEW) if dupindicator == 1 | dupindicator2 == 1
	save "${EDFacts}/20`year'/edfacts20`year'illinois.dta", replace
	import delimited "${path}/Output/IL_AssmtData_20`year'.csv", stringcols(10, 13) case (preserve) clear
	merge m:1 DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup using "${EDFacts}/20`year'/edfacts20`year'illinois.dta"
	drop if _merge != 3 & DataLevel != "State"
	drop _merge
	merge m:1 DataLevel Subject GradeLevel using tmp2.dta
	drop _merge
	replace StudentGroup_TotalTestedNEW = StudentGroup_TotalTestedSTATE if StudentGroup_TotalTestedSTATE != .
	tostring StudentGroup_TotalTestedNEW, replace
	tostring StudentSubGroup_TotalTestedNEW, replace
	replace StudentGroup_TotalTested = StudentGroup_TotalTestedNEW if StudentGroup_TotalTested == "--" && StudentGroup_TotalTestedNEW != "."
	replace StudentSubGroup_TotalTested = StudentSubGroup_TotalTestedNEW if StudentSubGroup_TotalTested == "--" && StudentSubGroup_TotalTestedNEW != "."
	replace ParticipationRateNEW = "." + ParticipationRateNEW
	replace ParticipationRateNEW = subinstr(ParticipationRateNEW, "-", "-.", .)
	replace ParticipationRateNEW = subinstr(ParticipationRateNEW, ".GE", "≥.", .)
	replace ParticipationRateNEW = subinstr(ParticipationRateNEW, ".LE", "≤.", .)
	replace ParticipationRateNEW = subinstr(ParticipationRateNEW, ".LT", "<.", .)
	replace ParticipationRateNEW = subinstr(ParticipationRateNEW, ".PS", "*", . )
	replace ParticipationRate = ParticipationRateNEW if ParticipationRate == "--" && ParticipationRateNEW != "."
	save tmp.dta, replace
	destring StudentSubGroup_TotalTested, replace force
	collapse (sum) StudentSubGroup_TotalTested, by(DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup_TotalTested StudentSubGroup)
	keep if StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="English Learner"
	destring StudentGroup_TotalTested, replace force
	replace StudentSubGroup_TotalTested = (StudentGroup_TotalTested - StudentSubGroup_TotalTested)
	replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="Economically Disadvantaged"
	replace StudentSubGroup="English Proficient" if StudentSubGroup=="English Learner"
	tostring StudentGroup_TotalTested, replace
	tostring StudentSubGroup_TotalTested, replace
	rename StudentSubGroup_TotalTested StudentSubGroupComplement
	save tmp2.dta, replace
	use tmp.dta
	merge 1:1 DataLevel NCESDistrictID NCESSchoolID Subject GradeLevel StudentGroup_TotalTested StudentSubGroup using tmp2.dta
	replace StudentSubGroup_TotalTested = StudentSubGroupComplement if StudentSubGroup_TotalTested == "--" && StudentSubGroupComplement != ""
	keep if StudentSubGroup_TotalTested != ""

	** Label Variables

	label var StateAbbrev "State abbreviation"
	label var StateFips "State FIPS Id"
	label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
	label var AssmtName "Name of state assessment"
	label var AssmtType "Assessment type"
	label var DataLevel "Level at which the data are reported"
	label var DistName "District name"
	label var DistCharter "Charter indicator - district"
	label var StateAssignedDistID "State-assigned district ID"
	label var SchName "School name"
	label var StateAssignedSchID "State-assigned school ID"
	label var Subject "Assessment subject area"
	label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
	label var StudentGroup "Student demographic group"
	label var StudentSubGroup "Student demographic subgroup"
	label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
	label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
	label var Lev1_count "Count of students within subgroup performing at Level 1."
	label var Lev1_percent "Percent of students within subgroup performing at Level 1."
	label var Lev2_count "Count of students within subgroup performing at Level 2."
	label var Lev2_percent "Percent of students within subgroup performing at Level 2."
	label var Lev3_count "Count of students within subgroup performing at Level 3."
	label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
	label var Lev4_count "Count of students within subgroup performing at Level 4."
	label var Lev4_percent "Percent of students within subgroup performing at Level 4."
	label var Lev5_count "Count of students within subgroup performing at Level 5."
	label var Lev5_percent "Percent of students within subgroup performing at Level 5."
	label var AvgScaleScore "Avg scale score within subgroup."
	label var ProficiencyCriteria "Levels included in determining proficiency status."
	label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
	label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
	label var ParticipationRate "Participation rate."
	label var NCESDistrictID "NCES district ID"
	label var State_leaid "State LEA ID"
	label var CountyName "County in which the district or school is located."
	label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
	label var State "State name"
	label var StateAbbrev "State abbreviation"
	label var StateFips "State FIPS Id"
	label var DistType "District type as defined by NCES"
	label var NCESDistrictID "NCES district ID"
	label var NCESSchoolID "NCES school ID"
	label var SchType "School type as defined by NCES"
	label var SchVirtual "Virtual school indicator"
	label var SchLevel "School level"
	label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
	label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
	label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
	label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."

	** Fix Variable Order 
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel 

	keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	** Export Assessment Data

	save "${path}/EDFacts Output/IL_AssmtData_20`year'.dta", replace
	export delimited using "${path}/EDFacts Output/IL_AssmtData_20`year'.csv", replace
}
