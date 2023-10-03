clear
global path "/Users/willtolmie/Documents/State Repository Research/South Carolina"
global nces "/Users/willtolmie/Documents/State Repository Research/NCES"

global ncesyears 2015 2016 2017 2018 2020 2021
foreach n in $ncesyears {
	
	** NCES School Data

	use "${nces}/School/NCES_`n'_School.dta"

	** Rename Variables

	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename lea_name DistName
	rename school_type SchType
	
	** Fix Variable Types
	
	decode SchLevel, gen(SchLevel2)
	decode SchType, gen(SchType2)
	decode SchVirtual, gen(SchVirtual2)
	drop SchLevel SchType SchVirtual
	rename SchLevel2 SchLevel 
	rename SchType2 SchType 
	rename SchVirtual2 SchVirtual
	replace seasch = State_leaid + seasch  if `n' < 2016
	replace seasch = subinstr(seasch, "-", "", .)
	replace State_leaid = "SC-" + State_leaid if `n' < 2016

	** Isolate Tennessee Data

	drop if StateFips != 45
	
	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter NCESSchoolID seasch SchVirtual SchLevel SchType
	local m = `n' - 1999
	
	save "${path}/Semi-Processed Data Files/`n'_`m'_NCES_Cleaned_School.dta", replace

	** NCES District Data

	clear
	use "${nces}/District/NCES_`n'_District.dta"

	** Rename Variables

	rename district_agency_type DistType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename county_code CountyCode
	rename county_name CountyName
	rename state_fips StateFips
	
	** Fix Variable Types
	
	decode DistType, gen(DistType2)
	drop DistType
	rename DistType2 DistType
	replace State_leaid = "SC-" + State_leaid if `n' < 2016

	** Drop Excess Variables

	keep StateFips NCESDistrictID State_leaid DistCharter CountyCode CountyName DistType

	* Isolate Rhode Island Data

	drop if StateFips != 45
	save "${path}/Semi-Processed Data Files/`n'_`m'_NCES_Cleaned_District.dta", replace
}

** Import Data

global screadyyears 2016 2017
foreach v in $screadyyears { 
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("`v' SC READY STATE") firstrow allstring clear
	gen DataLevel = "State"
	save "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_state.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("`v' SC READY DISTRICT") firstrow allstring clear
	gen DataLevel = "District"
	save "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_dist.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("`v' SC READY SCHOOL") firstrow allstring clear
	gen DataLevel = "School"
	append using "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_dist.dta" "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_state.dta"
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
	save "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_all.dta", replace
}

global lateryears 2018 2019 2021 2022 2023
foreach v in $lateryears { 
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("State") firstrow allstring clear
	gen DataLevel = "State"
	save "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_state.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("District") firstrow allstring clear
	gen DataLevel = "District"
	save "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_dist.dta", replace
	import excel "${path}/Original Data Files/SC_OriginalData_`v'.xlsx", sheet("School") firstrow allstring clear
	gen DataLevel = "School"
	append using "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_dist.dta" "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_state.dta"
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
	save "${path}/Semi-Processed Data Files/SC_OriginalData_`v'_all.dta", replace
}

use "${path}/Semi-Processed Data Files/SC_OriginalData_2023_all.dta"
rename Scipct1 Lev1_percentsci
rename Scipct2 Lev2_percentsci
rename Scipct3 Lev3_percentsci
rename Scipct4 Lev4_percentsci
rename Scipct34 ProficientOrAbove_percentsci
rename SciN StudentSubGroup_TotalTestedsci
save "${path}/Semi-Processed Data Files/SC_OriginalData_2023_all.dta", replace

global years 2016 2017 2018 2019 2021 2022 2023
foreach y in $years { 
	use "${path}/Semi-Processed Data Files/SC_OriginalData_`y'_all.dta"
	
	** Reshape Wide to Long
	
	generate id = _n
	reshape long N Lev1_percent Lev2_percent Lev3_percent Lev4_percent StudentSubGroup_TotalTested ProficientOrAbove_percent, i(id) j(Subject, string)
	drop id
	
	** Rename Variables
	
	rename distcode StateAssignedDistID
	rename districtname DistName
	rename schoolid StateAssignedSchID
	rename schoolname SchName
	rename demoID StudentSubGroup
	rename testgrade GradeLevel 
	
	** Generate StudentGroup_TotalTested Data
	
	save "${path}/Semi-Processed Data Files/SC_`y'_nogroup.dta", replace
	keep if StudentSubGroup=="01ALL"
	keep DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentSubGroup_TotalTested
	rename StudentSubGroup_TotalTested StudentGroup_TotalTested
	save "${path}/Semi-Processed Data Files/SC_`y'_group.dta", replace
	clear
	use "${path}/Semi-Processed Data Files/SC_`y'_nogroup.dta"
	merge m:1 DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel using "${path}/Semi-Processed Data Files/SC_`y'_group.dta"
	tab _merge
	drop _merge
	save "${path}/Semi-Processed Data Files/SC_`y'_all.dta", replace
	
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
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "15LEP"
	replace StudentSubGroup = "English Proficient" if StudentSubGroup == "16NLEP"
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "17SIP" | StudentSubGroup == "17PIP"
	replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "18NSIP" | StudentSubGroup == "18NPIP"
	gen StudentGroup = ""
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup="RaceEth" if StudentSubGroup== "Black or African American" | StudentSubGroup=="Native Hawaiian or Pacific Islander" | StudentSubGroup=="Asian" | StudentSubGroup=="Hispanic or Latino" | StudentSubGroup=="White" | StudentSubGroup=="American Indian or Alaska Native" |  StudentSubGroup=="Two or More"
	replace StudentGroup="Economic Status" if StudentSubGroup=="Economically Disadvantaged" | StudentSubGroup=="Not Economically Disadvantaged"
	replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
	replace StudentGroup="EL Status" if StudentSubGroup=="English Learner" | StudentSubGroup=="English Proficient" | StudentSubGroup=="Other"
	keep if StudentGroup == "All Students" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender" | StudentGroup == "RaceEth"
	
	** Generate Flags

	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_ELA = "Y" if `y' == 2017
	gen Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_math = "Y" if `y' == 2017
	gen Flag_CutScoreChange_read = ""
	gen Flag_CutScoreChange_oth = ""
	replace Flag_CutScoreChange_oth = "N" if `y' == 2023
	
	** Generate Other Variables
	
	local z = `y' - 1
	local x = `y' - 2000
	gen SchYear = "`z'-`x'"
	gen AssmtName = "SC Ready"
	gen AssmtType = "Regular"
	gen ProficiencyCriteria = "Levels 3 and 4"
	
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
	
	** Generate Empty Variables

	gen Lev1_count = "--"
	gen Lev2_count = "--"
	gen Lev3_count = "--"
	gen Lev4_count = "--"
	gen Lev5_count = ""
	gen Lev5_percent = ""
	gen AvgScaleScore = "--"
	gen ProficientOrAbove_count = "--"
	gen ParticipationRate = "--"

	** Merging NCES Variables

	gen State_leaid = "SC-" + StateAssignedDistID if DataLevel != "State" 
	gen seasch = StateAssignedSchID if DataLevel == "School"
	save "${path}/Semi-Processed Data Files/SC_`y'_unmerged.dta", replace
}
	
clear
use "${path}/Semi-Processed Data Files/SC_2023_unmerged.dta"
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta"
rename _merge district_merge
merge m:1 State_leaid seasch using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta"
rename _merge school_merge
tab DistName if district_merge == 1 & DataLevel != "State"
tab SchName if school_merge == 1 & DataLevel == "School" & district_merge == 3
drop if district_merge != 3 & DataLevel != "State" | school_merge !=3 & DataLevel == "School"
save "${path}/Semi-Processed Data Files/SC_2023_merged.dta", replace

global oldyears 2016 2017 2018 2019 2021 2022
foreach y in $oldyears { 
	clear
	local z = `y' - 1
	local x = `y' - 2000
	use "${path}/Semi-Processed Data Files/SC_`y'_unmerged.dta"
	merge m:1 State_leaid using "${path}/Semi-Processed Data Files/`z'_`x'_NCES_Cleaned_District.dta"
	rename _merge district_merge
	merge m:1 State_leaid seasch using "${path}/Semi-Processed Data Files/`z'_`x'_NCES_Cleaned_School.dta"
	rename _merge school_merge
	tab DistName if district_merge == 1 & DataLevel != "State"
	tab SchName if school_merge == 1 & DataLevel == "School" & district_merge == 3
	drop if district_merge != 3 & DataLevel != "State" | school_merge !=3 & DataLevel == "School"
	save "${path}/Semi-Processed Data Files/SC_`y'_merged.dta", replace
}

foreach y in $years { 
	clear
	use "${path}/Semi-Processed Data Files/SC_`y'_merged.dta"
	
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

	** Relabel GradeLevel Values

	tostring GradeLevel, replace
	replace GradeLevel = "G0" + GradeLevel if `y' < 2018
	replace GradeLevel = "G0" + GradeLevel if `y' >= 2018

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
	label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
	label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
	label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
	label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."

	** Fix Variable Order 

	keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	** Export Assessment Data

	save "${path}/Semi-Processed Data Files/SC_AssmtData_`y'.dta", replace
	export delimited using "${path}/Output/SC_AssmtData_`y'.csv", replace
}
