clear
global path "/Users/minnamgung/Desktop/SADR/South Carolina"
global nces "/Users/minnamgung/Desktop/SADR/NCESOld"

** Clean NCES data for SC

global ncesyears 2015 2016 2017 2018 2020 2021 2022
foreach n in $ncesyears {
	
	** NCES School Data

	use "${nces}/NCES_`n'_School.dta"

	** Rename Variables
	
	if `n' == 2022 {
		drop DistLocale
	}
	
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode
	rename ncesschoolid NCESSchoolID
	rename school_type SchType
	rename dist_urban_centric_locale DistLocale
	
	** Fix Variable Types
	
	foreach v of varlist SchLevel SchType DistType DistLocale SchVirtual {
		decode `v', generate(`v'1)
		drop `v' 
		rename `v'1 `v'
	}
	
	replace seasch = State_leaid + seasch  if `n' < 2016
	replace seasch = subinstr(seasch, "-", "", .)
	replace State_leaid = "SC-" + State_leaid if `n' < 2016

	** Isolate SC Data

	drop if StateFips != 45
	
	** Drop Excess Variables

	keep StateFips school_name NCESDistrictID State_leaid DistCharter NCESSchoolID seasch SchVirtual SchLevel SchType DistLocale DistType
	local m = `n' - 1999
	
	save "${path}/Intermediate/`n'_`m'_NCES_Cleaned_School.dta", replace

	** NCES District Data

	clear
	use "${nces}/NCES_`n'_District.dta"

	** Rename Variables
	
	if `n' == 2022 {
		drop DistLocale
	}

	rename urban_centric_locale DistLocale
	rename district_agency_type DistType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename state_fips StateFips
	
	** Fix Variable Types
	
	if `n' != 2022 {
		
		decode DistType, gen(DistType2)
		drop DistType
		rename DistType2 DistType
		
		decode DistLocale, gen(DistLocale2)
		drop DistLocale
		rename DistLocale2 DistLocale
		
	}
	
	replace State_leaid = "SC-" + State_leaid if `n' < 2016

	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter CountyCode CountyName DistType lea_name DistLocale

	* Isolate SC Data

	drop if StateFips != 45
	save "${path}/Intermediate/`n'_`m'_NCES_Cleaned_District.dta", replace
}

** Import Data

global screadyyears 2016 2017
foreach v in $screadyyears { 
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("`v' SC READY STATE") firstrow allstring clear
	gen DataLevel = "State"
	save "${path}/Intermediate/SC_OriginalData_`v'_state.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("`v' SC READY DISTRICT") firstrow allstring clear
	gen DataLevel = "District"
	save "${path}/Intermediate/SC_OriginalData_`v'_dist.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("`v' SC READY SCHOOL") firstrow allstring clear
	gen DataLevel = "School"
	append using "${path}/Intermediate/SC_OriginalData_`v'_dist.dta" "${path}/Intermediate/SC_OriginalData_`v'_state.dta"
	rename elapct1 Lev1_percentela
	rename elapct2 Lev2_percentela
	rename elapct3 Lev3_percentela
	rename elapct4 Lev4_percentela
	rename elapct34 ProficientOrAbove_percentela
	rename mathpct1 Lev1_percentmath
	rename mathpct2 Lev2_percentmath
	rename mathpct3 Lev3_percentmath
	rename mathpct4 Lev4_percentmath
	rename mathpct34 ProficientOrAbove_percentmath
	rename elaN StudentSubGroup_TotalTestedela
	rename mathN StudentSubGroup_TotalTestedmath
	rename elaMEAN AvgScaleScoreela
	rename mathMEAN AvgScaleScoremath
	save "${path}/Intermediate/SC_OriginalData_`v'_all.dta", replace
}

foreach v in $screadyyears { 
	import excel "${path}/Original Data Files/SC_OriginalData_`v'_soc_sci.xlsx", sheet("`v' SCPASS STATE") firstrow allstring clear
	gen DataLevel = "State"
	save "${path}/Intermediate/SC_OriginalData_`v'_state_soc_sci.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'_soc_sci.xlsx", sheet("`v' SCPASS DISTRICT") firstrow allstring clear
	gen DataLevel = "District"
	save "${path}/Intermediate/SC_OriginalData_`v'_dist_soc_sci.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'_soc_sci.xlsx", sheet("`v' SCPASS SCHOOL") firstrow allstring clear
	gen DataLevel = "School"
	append using "${path}/Intermediate/SC_OriginalData_`v'_dist_soc_sci.dta" "${path}/Intermediate/SC_OriginalData_`v'_state_soc_sci.dta"
	
	drop if missing(schoolname)
	
	rename scipct1 Lev1_percentsci
	rename scipct2 Lev2_percentsci
	rename scipct3 Lev3_percentsci
	
	if `v' == 2017 {
		rename scipct4 Lev4_percentsci
	}
	
	rename socpct1 Lev1_percentsoc
	rename socpct2 Lev2_percentsoc
	rename socpct3 Lev3_percentsoc
	
	foreach y of varlist Lev*_percent* {
		destring `y', replace 
	}
	
	if `v' == 2017 {
		gen ProficientOrAbove_percentsci = Lev3_percentsci + Lev4_percentsci
	}
	
	if `v' == 2016 {
		gen ProficientOrAbove_percentsci = Lev2_percentsci + Lev3_percentsci
	}
	
	
	destring Lev2_percentsoc, replace
	destring Lev3_percentsoc, replace
	gen ProficientOrAbove_percentsoc = Lev2_percentsoc + Lev3_percentsoc
	
	rename sciN StudentSubGroup_TotalTestedsci
	rename socN StudentSubGroup_TotalTestedsoc
	rename sciMEAN AvgScaleScoresci
	rename socMEAN AvgScaleScoresoc
	
	foreach v of varlist Lev*_percent* ProficientOrAbove_percent* {
		tostring `v', replace force
	}
	
	save "${path}/Intermediate/SC_OriginalData_`v'_soc_sci.dta", replace
}

global lateryears 2018 2019 2021 2022 2023
foreach v in $lateryears { 
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("State") firstrow allstring clear
	gen DataLevel = "State"
	save "${path}/Intermediate/SC_OriginalData_`v'_state.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("District") firstrow allstring clear
	gen DataLevel = "District"
	save "${path}/Intermediate/SC_OriginalData_`v'_dist.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("School") firstrow allstring clear
	gen DataLevel = "School"
	append using "${path}/Intermediate/SC_OriginalData_`v'_dist.dta" "${path}/Intermediate/SC_OriginalData_`v'_state.dta"
	rename ELApct1 Lev1_percentela
	rename ELApct2 Lev2_percentela
	rename ELApct3 Lev3_percentela
	rename ELApct4 Lev4_percentela
	rename ELApct34 ProficientOrAbove_percentela
	rename Mathpct1 Lev1_percentmath
	rename Mathpct2 Lev2_percentmath
	rename Mathpct3 Lev3_percentmath
	rename Mathpct4 Lev4_percentmath
	rename Mathpct34 ProficientOrAbove_percentmath 
	rename ELAN StudentSubGroup_TotalTestedela
	rename MathN StudentSubGroup_TotalTestedmath
	rename ELAMEAN AvgScaleScoreela
	rename MathMEAN AvgScaleScoremath
	save "${path}/Intermediate/SC_OriginalData_`v'_all.dta", replace
}

global latersciyears 2018 2019 2021 2022
foreach v in $latersciyears {
	
	import excel "${path}/Original Data Files/SC_OriginalData_`v'_soc_sci.xlsx", sheet("State") firstrow allstring clear
	gen DataLevel = "State"
	save "${path}/Intermediate/SC_OriginalData_`v'_state_soc_sci.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'_soc_sci.xlsx", sheet("District") firstrow allstring clear
	gen DataLevel = "District"
	save "${path}/Intermediate/SC_OriginalData_`v'_dist_soc_sci.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'_soc_sci.xlsx", sheet("School") firstrow allstring clear
	gen DataLevel = "School"
	append using "${path}/Intermediate/SC_OriginalData_`v'_dist_soc_sci.dta" "${path}/Intermediate/SC_OriginalData_`v'_state_soc_sci.dta"
	
	rename SciN StudentSubGroup_TotalTestedsci
	rename SocN StudentSubGroup_TotalTestedsoc
	rename SciMEAN AvgScaleScoresci
	rename SocMEAN AvgScaleScoresoc

	rename Scipct1 Lev1_percentsci
	rename Scipct2 Lev2_percentsci
	rename Scipct3 Lev3_percentsci
	rename Scipct4 Lev4_percentsci
	rename Scipct34 ProficientOrAbove_percentsci
	rename Socpct1 Lev1_percentsoc
	rename Socpct2 Lev2_percentsoc
	rename Socpct3 Lev3_percentsoc
	rename Socpct23 ProficientOrAbove_percentsoc
	
	save "${path}/Intermediate/SC_OriginalData_`v'_soc_sci.dta", replace
	
}

use "${path}/Intermediate/SC_OriginalData_2023_all.dta"
rename Scipct1 Lev1_percentsci
rename Scipct2 Lev2_percentsci
rename Scipct3 Lev3_percentsci
rename Scipct4 Lev4_percentsci
rename Scipct34 ProficientOrAbove_percentsci
rename SciN StudentSubGroup_TotalTestedsci
rename SciMean AvgScaleScoresci
save "${path}/Intermediate/SC_OriginalData_2023_all.dta", replace

** Merge subject files together

global years 2016 2017 2018 2019 2021 2022 
foreach y in $years { 
	
	use "${path}/Intermediate/SC_OriginalData_`y'_all.dta", clear
	
	merge m:1 districtname schoolname DataLevel demoID testgrade using "${path}/Intermediate/SC_OriginalData_`y'_soc_sci.dta"
	
	drop _merge
	
	save "${path}/Intermediate/SC_OriginalData_`y'_all.dta", replace

}


** Data cleaning process

global years 2016 2017 2018 2019 2021 2022 2023
foreach y in $years { 
	use "${path}/Intermediate/SC_OriginalData_`y'_all.dta", clear
	
	** Reshape Wide to Long
	
	generate id = _n
	reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent StudentSubGroup_TotalTested ProficientOrAbove_percent AvgScaleScore, i(id) j(Subject, string)
	drop id
	
	** Rename Variables
	
	rename distcode StateAssignedDistID
	rename districtname DistName
	rename schoolid StateAssignedSchID
	rename schoolname SchName
	rename demoID StudentSubGroup
	rename testgrade GradeLevel 
	
	** Generate StudentGroup_TotalTested Data
	
	save "${path}/Intermediate/SC_`y'_nogroup.dta", replace
	keep if StudentSubGroup=="01ALL"
	keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
	rename StudentSubGroup_TotalTested StudentGroup_TotalTested
	save "${path}/Intermediate/SC_`y'_group.dta", replace
	clear
	use "${path}/Intermediate/SC_`y'_nogroup.dta"
	merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "${path}/Intermediate/SC_`y'_group.dta"
	tab _merge
	drop _merge
	drop if StudentSubGroup_TotalTested == "0" | StudentSubGroup_TotalTested == ""
	save "${path}/Intermediate/SC_`y'_all.dta", replace
	
	** Standardize StudentSubGroup Data
	
	replace StudentSubGroup = "All Students" if StudentSubGroup == "01ALL"
	replace StudentSubGroup = "Male" if StudentSubGroup == "02M"
	replace StudentSubGroup = "Female" if StudentSubGroup == "03F"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "04H"
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "05I"
	replace StudentSubGroup = "Asian" if StudentSubGroup == "06A"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "07B"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "08P"
	replace StudentSubGroup = "White" if StudentSubGroup == "09W"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "10M"
	
	replace StudentSubGroup = "SWD" if StudentSubGroup == "11SWD"
	replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "12NSWD"
	
	replace StudentSubGroup = "Migrant" if StudentSubGroup == "13MIG"
	replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "14NMIG"
	
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "15LEP"
	replace StudentSubGroup = "English Proficient" if StudentSubGroup == "16NLEP"
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "17SIP" | StudentSubGroup == "17PIP"
	replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "18NSIP" | StudentSubGroup == "18NPIP"
	
	replace StudentSubGroup = "Homeless" if StudentSubGroup == "24Hl" | StudentSubGroup == "Homeless"
	replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "25NHl" | StudentSubGroup == "NHomeless"
	
	replace StudentSubGroup = "Foster Care" if StudentSubGroup == "26F" | StudentSubGroup == "Foster"
	replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "27NF" | StudentSubGroup == "NFoster"
	
	replace StudentSubGroup = "Military" if StudentSubGroup == "28Mil" | StudentSubGroup == "Military"
	replace StudentSubGroup = "Non-Military" if StudentSubGroup == "29NMil" | StudentSubGroup == "NMilitary"
	
	
	gen StudentGroup = ""
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup="RaceEth" if StudentSubGroup== "Black or African American" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Asian" | StudentSubGroup=="Hispanic or Latino" | StudentSubGroup=="White" | StudentSubGroup=="American Indian or Alaska Native" |  StudentSubGroup=="Two or More"
	replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
	replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
	replace StudentGroup="EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup=="English Proficient" | StudentSubGroup=="Other"
	replace StudentGroup="Homeless Enrolled Status" if StudentSubGroup=="Homeless" | StudentSubGroup=="Non-Homeless" 
	replace StudentGroup="Disability Status" if StudentSubGroup=="SWD" | StudentSubGroup=="Non-SWD"
	replace StudentGroup="Foster Care Status" if StudentSubGroup=="Foster Care" | StudentSubGroup=="Non-Foster Care"
	replace StudentGroup="Migrant Status" if StudentSubGroup=="Migrant" | StudentSubGroup=="Non-Migrant"
	replace StudentGroup="Military Connected Status" if StudentSubGroup=="Military" | StudentSubGroup=="Non-Military"
	
	keep if StudentGroup=="Military Connected Status" | StudentGroup=="All Students" | StudentGroup=="Disability Status" | StudentGroup=="EL Status" | StudentGroup=="Economic Status" | StudentGroup=="Foster Care Status" | StudentGroup=="Gender" | StudentGroup=="Homeless Enrolled Status" | StudentGroup=="Migrant Status" | StudentGroup=="RaceEth"
	
	** Generate Flags

	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_ELA = "Y" if `y' == 2017
	gen Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_math = "Y" if `y' == 2017
	
	gen Flag_CutScoreChange_soc = "N"
	gen Flag_CutScoreChange_sci = "N"
	replace Flag_CutScoreChange_soc = "Not applicable" if `y' >= 2018
	
	** Generate Other Variables
	
	local z = `y' - 1
	local x = `y' - 2000
	gen SchYear = "`z'-`x'"
	gen AssmtName = "SC Ready"
	gen AssmtType = "Regular"
	gen ProficiencyCriteria = "Levels 3-4"
	
	** Convert Proficiency Data into Percentages

	foreach v of varlist Lev*_percent {
		destring `v', g(n`v') i(* -) force
		replace n`v' = n`v' / 100 if n`v' != .
		tostring n`v', replace force
		replace `v' = n`v' if `v' != "*"
	}
	
	destring ProficientOrAbove_percent, generate(nProficientOrAbove_percent) force
	replace nProficientOrAbove_percent = nProficientOrAbove_percent / 100 if nProficientOrAbove_percent != .
	tostring nProficientOrAbove_percent, replace force
	replace ProficientOrAbove_percent = nProficientOrAbove_percent
	drop nProficientOrAbove_percent
	replace Lev1_percent = "*" if Lev1_percent=="."
	replace Lev2_percent = "*" if Lev2_percent=="."
	replace Lev3_percent = "*" if Lev3_percent=="."
	replace Lev4_percent = "*" if Lev4_percent=="."
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent=="."
	replace AvgScaleScore = "*" if AvgScaleScore==""
	
	** Generate Empty Variables

	gen Lev1_count = "--"
	gen Lev2_count = "--"
	gen Lev3_count = "--"
	gen Lev4_count = "--"
	gen Lev5_count = ""
	gen Lev5_percent = ""
	gen ProficientOrAbove_count = "--"
	gen ParticipationRate = "--"

	** Merging NCES Variables

	gen State_leaid = "SC-" + StateAssignedDistID if DataLevel != "State" 
	gen seasch = StateAssignedSchID if DataLevel == "School"
	replace State_leaid = "SC-0" + StateAssignedDistID if strlen(StateAssignedDistID)==3  & `y' < 2018
	replace seasch = "0" + StateAssignedSchID if strlen(StateAssignedSchID)==6  & `y' < 2018
	replace seasch = "5208003" if SchName == "Detention Center School"
	save "${path}/Intermediate/SC_`y'_unmerged.dta", replace
}

** NCES merging

global oldyears 2016 2017 2018 2019 2021 2022 2023
foreach y in $oldyears { 
	clear
	local z = `y' - 1
	local x = `y' - 2000
	use "${path}/Intermediate/SC_`y'_unmerged.dta"
	merge m:1 State_leaid using "${path}/Intermediate/`z'_`x'_NCES_Cleaned_District.dta"
	rename _merge district_merge
	merge m:1 State_leaid seasch using "${path}/Intermediate/`z'_`x'_NCES_Cleaned_School.dta"
	rename _merge school_merge
	tab DistName if district_merge == 1 & DataLevel != "State"
	tab SchName if school_merge == 1 & DataLevel == "School" & district_merge == 3
	drop if district_merge != 3 & DataLevel != "State" | school_merge !=3 & DataLevel == "School"
	save "${path}/Intermediate/SC_`y'_merged.dta", replace
}

foreach y in $years { 
	clear
	use "${path}/Intermediate/SC_`y'_merged.dta"
	
	if `y' == 2023 {
		destring CountyCode, replace
	}
	
	** Standardize Non-School Level Data

	replace SchName = "All Schools" if DataLevel == "State"
	replace SchName = "All Schools" if DataLevel == "District"
	replace DistName = "All Districts" if DataLevel == "State"
	replace StateAssignedDistID = "" if DataLevel == "State"
	replace StateAssignedSchID = "" if DataLevel == "State" | DataLevel == "District"
	replace State_leaid = "" if DataLevel == "State"
	replace SchLevel = ""  if DataLevel == "State" | DataLevel == "District"
	replace SchVirtual = ""  if DataLevel == "State" | DataLevel == "District"
	replace DistType = "" if DataLevel == "State"
	replace DistCharter = "" if DataLevel == "State"
	replace seasch = "" if DataLevel == "State" | DataLevel == "District"

	** Fix AssmtName & Proficiency Criteria 
	
	replace AssmtName = "SC PASS" if (Subject=="sci" & `y' < 2023) | (Subject=="soc" & `y' < 2023)
	
	replace ProficiencyCriteria = "Levels 2-3" if Subject=="sci" & `y' == 2016
	replace ProficiencyCriteria = "Levels 2-3" if Subject=="soc" 
	
	** Relabel GradeLevel Values

	tostring GradeLevel, replace
	replace GradeLevel = "G0" + GradeLevel if `y' < 2018
	replace GradeLevel = "G" + GradeLevel if `y' >= 2018

	** Fix Variable Types

	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel 
	recast int CountyCode
	drop StateFips
	gen State = "South Carolina"
	gen StateAbbrev = "SC"
	gen int StateFips = 45

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
	label var DistLocale "District locale as defined by NCES"
	label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
	label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
	label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
	label var Flag_CutScoreChange_soc "Flag denoting a change in scoring determinations in math from the prior year only."
	label var Flag_CutScoreChange_sci "Flag denoting a change in scoring determinations in math from the prior year only."
	

	** Fix Variable Order 

	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	** Export Assessment Data

	save "${path}/Intermediate/SC_AssmtData_`y'.dta", replace
	export delimited using "${path}/Output/SC_AssmtData_`y'.csv", replace
}


** 2024 review updates 

global years 2016 2017 2018 2019 2021 2022 2023
foreach y in $years {
	
	use "${path}/Intermediate/SC_AssmtData_`y'.dta", clear
	
	** generate Lev*_counts

destring StudentSubGroup_TotalTested, gen(total_count) ignore("*" "--")

global a 1 2 3 4
	foreach a in $a {
		destring Lev`a'_percent, gen(n`a'_percent) ignore("*" "--")
		gen n`a'_count = total_count*n`a'_percent
		replace n`a'_count = trunc(n`a'_count)
		tostring n`a'_count, replace
		replace Lev`a'_count = n`a'_count
	
		replace Lev`a'_count = "*" if Lev`a'_percent == "*"
	}
	
gen n_profabove = . 
gen subject_flag = 0

if `y' >= 2017 {
	
	replace subject_flag = 1 if Subject == "ela" | Subject == "math" | Subject == "sci"
}

if `y' == 2016 {
	
	replace subject_flag = 1 if Subject == "ela" | Subject == "math" 
	
}

replace n_profabove = n3_percent + n4_percent if Lev3_percent != "*" & Lev4_percent != "*" & subject_flag == 1
	
replace n_profabove = 1-(n1_percent + n2_percent) if Lev3_percent == "*" & subject_flag == 1
replace n_profabove = 1-(n1_percent + n2_percent) if Lev4_percent == "*" & subject_flag == 1

replace n_profabove = n3_percent + n2_percent if Lev2_percent != "*" & Lev3_percent != "*" & subject_flag == 0
replace n_profabove = 1-(n1_percent) if Lev2_percent == "*" & subject_flag == 0
replace n_profabove = 1-(n1_percent) if Lev3_percent == "*" & subject_flag == 0

replace Lev4_percent = "" if ProficiencyCriteria == "Levels 2-3"
replace Lev4_count = "" if ProficiencyCriteria == "Levels 2-3"

gen nprof_count = total_count*n_profabove
		
replace nprof_count = trunc(nprof_count)
tostring nprof_count, replace
replace ProficientOrAbove_count = nprof_count
		
replace n_profabove = 1 if n_profabove > 1
tostring n_profabove, replace force
replace ProficientOrAbove_percent = n_profabove
		
drop n_profabove 
		
replace ProficientOrAbove_count = "*" if Lev1_percent == "*" & Lev2_percent == "*" & Lev3_percent == "*" & Lev4_percent == "*" & ProficiencyCriteria == "Levels 3-4"
replace ProficientOrAbove_count = "*" if Lev1_percent == "*" & Lev2_percent == "*" & Lev3_percent == "*" & ProficiencyCriteria == "Levels 2-3"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_count == "*"
	
	** fix assmtname
	replace AssmtName="SC Pass" if `y' == 2023 & Subject =="sci"
	
	** flag issues
	replace Flag_CutScoreChange_ELA="N" if `y' == 2017
	replace Flag_CutScoreChange_math="N" if `y' == 2017
	replace Flag_CutScoreChange_sci="Y" if `y' == 2017
	replace Flag_CutScoreChange_soc="Not applicable" if `y' == 2017 | `y' == 2016
	
	** standardize district names
	
	destring NCESDistrictID, replace
	
replace DistName="Abbeville 60" if NCESDistrictID==4500690
replace DistName="Aiken 01" if NCESDistrictID==4500720
replace DistName="Allendale 01" if NCESDistrictID==4500750

replace DistName="Anderson 01" if NCESDistrictID==4500780
replace DistName="Anderson 02" if NCESDistrictID==4500810
replace DistName="Anderson 03" if NCESDistrictID==4500840
replace DistName="Anderson 04" if NCESDistrictID==4500870
replace DistName="Anderson 05" if NCESDistrictID==4500900

replace DistName="Bamberg 01" if NCESDistrictID==4500930
replace DistName="Bamberg 02" if NCESDistrictID==4500960

replace DistName="Beaufort 01" if NCESDistrictID==4501110
replace DistName="Berkeley 01" if NCESDistrictID==4501170
replace DistName="Calhoun 01" if NCESDistrictID==4501250
replace DistName="Charleston 01" if NCESDistrictID==4501440
replace DistName="Cherokee 01" if NCESDistrictID==4501500
replace DistName="Chester 01" if NCESDistrictID==4501530
replace DistName="Chesterfield 01" if NCESDistrictID==4501560
replace DistName="Clarendon 01" if NCESDistrictID==4501740
replace DistName="Clarendon 02" if NCESDistrictID==4501770
replace DistName="Clarendon 03" if NCESDistrictID==4501800

replace DistName="Colleton 01" if NCESDistrictID==4501830
replace DistName="Darlington 01" if NCESDistrictID==4501860
replace DistName="Dept Of Juvenile Justice" if NCESDistrictID==4503420
replace DistName="Dillon 03" if NCESDistrictID==4501950
replace DistName="Dillon 04" if NCESDistrictID==4501920
replace DistName="Dorchester 02" if NCESDistrictID==4502010
replace DistName="Dorchester 04" if NCESDistrictID==4500002

replace DistName="Edgefield 01" if NCESDistrictID==4502070
replace DistName="Fairfield 01" if NCESDistrictID==4502100
replace DistName="Florence 01" if NCESDistrictID==4502130
replace DistName="Florence 02" if NCESDistrictID==4502160
replace DistName="Florence 03" if NCESDistrictID==4502190
replace DistName="Florence 04" if NCESDistrictID==4502220
replace DistName="Florence 05" if NCESDistrictID==4502250
replace DistName="Georgetown 01" if NCESDistrictID==4502280
replace DistName="Greenville 01" if NCESDistrictID==4502310

replace DistName="Hampton 01" if NCESDistrictID==4502430
replace DistName="Hampton 02" if NCESDistrictID==4502460
replace DistName="Hampton" if NCESDistrictID==4503912
replace DistName="Horry 01" if NCESDistrictID==4502490
replace DistName="Jasper 01" if NCESDistrictID==4502520
replace DistName="Kershaw 01" if NCESDistrictID==4502550
replace DistName="Lancaster 01" if NCESDistrictID==4502580
replace DistName="Lee 01" if NCESDistrictID==4502670

replace DistName="Lexington 01" if NCESDistrictID==4502700
replace DistName="Lexington 02" if NCESDistrictID==4502730
replace DistName="Lexington 03" if NCESDistrictID==4502760
replace DistName="Lexington 04" if NCESDistrictID==4502790
replace DistName="Lexington 05" if NCESDistrictID==4502820

replace DistName="Marlboro 01" if NCESDistrictID==4502970
replace DistName="McCormick 01" if NCESDistrictID==4503000
replace DistName="Newberry 01" if NCESDistrictID==4503030
replace DistName="Oconee 01" if NCESDistrictID==4503060
replace DistName="Orangeburg 03" if NCESDistrictID==4503150
replace DistName="Orangeburg 04" if NCESDistrictID==4503180
replace DistName="Orangeburg 05" if NCESDistrictID==4503210

replace DistName="Pickens 01" if NCESDistrictID==4503330
replace DistName="Richland 01" if NCESDistrictID==4503360
replace DistName="Richland 02" if NCESDistrictID==4503390

replace DistName="Saluda 01" if NCESDistrictID==4503460
replace DistName="Spartanburg 01" if NCESDistrictID==4503480
replace DistName="Spartanburg 02" if NCESDistrictID==4503510
replace DistName="Spartanburg 03" if NCESDistrictID==4503540
replace DistName="Spartanburg 04" if NCESDistrictID==4503570
replace DistName="Spartanburg 05" if NCESDistrictID==4503600
replace DistName="Spartanburg 06" if NCESDistrictID==4503630
replace DistName="Spartanburg 07" if NCESDistrictID==4503660
replace DistName="Sumter 01" if NCESDistrictID==4503902
replace DistName="Union 01" if NCESDistrictID==4503750
replace DistName="Williamsburg 01" if NCESDistrictID==4503780
replace DistName="York 01" if NCESDistrictID==4503810
replace DistName="York 02" if NCESDistrictID==4503840
replace DistName="York 03" if NCESDistrictID==4503870
replace DistName="York 04" if NCESDistrictID==4503900
replace DistName="SC School for Deaf and Blind" if NCESDistrictID==4500004

tostring NCESDistrictID, replace

** Fix Variable Order 

	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	** Export Assessment Data

	save "${path}/Output/SC_AssmtData_`y'.dta", replace
	export delimited using "${path}/Output/SC_AssmtData_`y'.csv", replace
	
}



