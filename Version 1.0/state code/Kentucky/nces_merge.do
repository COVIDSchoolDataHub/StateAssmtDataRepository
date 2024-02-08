clear
set more off
global raw "C:\Users\philb\Downloads\Kentucky\raw\"
global clean "C:\Users\philb\Downloads\Kentucky\clean\"
global nces "C:\Users\philb\Downloads\NCES School Files, Fall 1997-Fall 2021\"

forvalues year = 2012/2016 {

	use "${clean}/KY_AssmtData_`year'", clear
	local ncesyear = `year'-1
		
		
	// MERGING SCHOOl FILE
	gen match_id = StateAssignedDistID + StateAssignedSchID
	replace match_id = "" if strlen(match_id) != 6
	save "${clean}/KY_AssmtData_`year'", replace
		
	import excel "${nces}NCES_`ncesyear'_School.xlsx", firstrow allstring case(preserve) clear
	drop if state_name != "Kentucky"
	gen match_id = substr(seasch, 4,6)
	drop if match_id == ""

	save "${nces}NCES_`ncesyear'_School", replace
		
	use "${clean}/KY_AssmtData_`year'", clear
	merge m:1 match_id using "${nces}NCES_`ncesyear'_School"

	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename district_agency_type DistType
	rename school_type SchType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename county_name CountyName
	rename county_code CountyCode

	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == ""
	replace State = "Kentucky"
	replace StateAbbrev = "KY"
	replace StateFips = "21"
	
	replace DistType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def DistType "-1" "Missing/not reported"
	replace SchType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchType -1 "Missing/not reported"
	replace NCESDistrictID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace State_leaid = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace DistCharter = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace SchLevel = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchLevel -1 "Missing/not reported"
	replace SchVirtual = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchVirtual -1 "Missing/not reported"
	replace CountyName = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace CountyCode = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def CountyCode -1 "Missing/not reported"

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
		
	drop if _merge != 1 & _merge != 3

	drop if StudentSubGroup_TotalTested <= 0

		keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent  Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


	save "${clean}/KY_AssmtData_`year'", replace
	export delimited "${clean}/KY_AssmtData_`year'", replace
}


	local year = 2017
	use "${clean}/KY_AssmtData_`year'", clear
	local ncesyear = `year'-1
		
		
	// MERGING SCHOOl FILE
	gen match_id = StateAssignedDistID + StateAssignedSchID
	replace match_id = "" if strlen(match_id) != 6
	save "${clean}/KY_AssmtData_`year'", replace
		
	import excel "${nces}NCES_`ncesyear'_School.xlsx", firstrow allstring case(preserve) clear
	drop if state_name != "Kentucky"
	gen match_id = substr(seasch, 14,6)
	drop if match_id == ""

	save "${nces}NCES_`ncesyear'_School", replace
		
	use "${clean}/KY_AssmtData_`year'", clear
	merge m:1 match_id using "${nces}NCES_`ncesyear'_School"

	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename district_agency_type DistType
	rename school_type SchType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename county_name CountyName
	rename county_code CountyCode

	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == ""
	replace State = "Kentucky"
	replace StateAbbrev = "KY"
	replace StateFips = "21"
	
	replace DistType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def DistType "-1" "Missing/not reported"
	replace SchType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchType -1 "Missing/not reported"
	replace NCESDistrictID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace State_leaid = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace DistCharter = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace SchLevel = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchLevel -1 "Missing/not reported"
	replace SchVirtual = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchVirtual -1 "Missing/not reported"
	replace CountyName = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace CountyCode = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def CountyCode -1 "Missing/not reported"

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
		
	drop if _merge != 1 & _merge != 3

	drop if StudentSubGroup_TotalTested <= 0

		keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent  Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


	save "${clean}/KY_AssmtData_`year'", replace
	export delimited "${clean}/KY_AssmtData_`year'", replace
	
	
	
	
	
	

	local year = 2018
	use "${clean}/KY_AssmtData_`year'", clear
	local ncesyear = `year'-1
		
		
	// MERGING SCHOOl FILE
	gen match_id = StateAssignedDistID + StateAssignedSchID
	replace match_id = "" if strlen(match_id) != 6
	save "${clean}/KY_AssmtData_`year'", replace
		
	import excel "${nces}NCES_`ncesyear'_School.xlsx", firstrow allstring case(preserve) clear
	drop if state_name != "Kentucky"
	gen match_id = substr(seasch, 14,6)
	drop if match_id == ""

	save "${nces}NCES_`ncesyear'_School", replace
		
	use "${clean}/KY_AssmtData_`year'", clear
	merge m:1 match_id using "${nces}NCES_`ncesyear'_School"

	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename school_type SchType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename county_name CountyName
	rename county_code CountyCode

	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == ""
	replace State = "Kentucky"
	replace StateAbbrev = "KY"
	replace StateFips = "21"
	
// 	replace DistType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def DistType "-1" "Missing/not reported"
	replace SchType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchType -1 "Missing/not reported"
	replace NCESDistrictID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace State_leaid = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
// 	replace DistCharter = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace SchLevel = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchLevel -1 "Missing/not reported"
	replace SchVirtual = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchVirtual -1 "Missing/not reported"
	replace CountyName = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace CountyCode = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def CountyCode -1 "Missing/not reported"

	order State StateAbbrev StateFips SchYear DataLevel DistName SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
		
	drop if _merge != 1 & _merge != 3

	drop if StudentSubGroup_TotalTested <= 0

		keep State StateAbbrev StateFips SchYear DataLevel DistName SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent  Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


	save "${clean}/KY_AssmtData_`year'", replace
	export delimited "${clean}/KY_AssmtData_`year'", replace
	
	
	
	
	
	local year = 2019
	use "${clean}/KY_AssmtData_`year'", clear
	local ncesyear = `year'-1
		
		
	// MERGING SCHOOl FILE
	gen match_id = StateAssignedDistID + StateAssignedSchID
	replace match_id = "" if strlen(match_id) != 6
	save "${clean}/KY_AssmtData_`year'", replace
		
	import excel "${nces}NCES_`ncesyear'_School.xlsx", firstrow allstring case(preserve) clear
	drop if state_name != "Kentucky"
	gen match_id = substr(seasch, 14,6)
	drop if match_id == ""

	save "${nces}NCES_`ncesyear'_School", replace
		
	use "${clean}/KY_AssmtData_`year'", clear
	merge m:1 match_id using "${nces}NCES_`ncesyear'_School"

	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename district_agency_type DistType
	rename school_type SchType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename county_name CountyName
	rename county_code CountyCode

	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == ""
	replace State = "Kentucky"
	replace StateAbbrev = "KY"
	replace StateFips = "21"
	
	replace DistType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def DistType "-1" "Missing/not reported"
	replace SchType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchType -1 "Missing/not reported"
	replace NCESDistrictID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace State_leaid = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace DistCharter = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace SchLevel = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchLevel -1 "Missing/not reported"
	replace SchVirtual = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchVirtual -1 "Missing/not reported"
	replace CountyName = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace CountyCode = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def CountyCode -1 "Missing/not reported"

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
		
	drop if _merge != 1 & _merge != 3

	drop if StudentSubGroup_TotalTested <= 0

		keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent  Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


	save "${clean}/KY_AssmtData_`year'", replace
	export delimited "${clean}/KY_AssmtData_`year'", replace


forvalues year = 2021/2022 {
	use "${clean}/KY_AssmtData_`year'", clear
	local ncesyear = `year'-1
		
		
	// MERGING SCHOOl FILE
	gen match_id = StateAssignedDistID + StateAssignedSchID
	replace match_id = "" if strlen(match_id) != 6
	save "${clean}/KY_AssmtData_`year'", replace
		
	import excel "${nces}NCES_`ncesyear'_School.xlsx", firstrow allstring case(preserve) clear
	drop if state_name != "Kentucky"
	gen match_id = substr(seasch, 14,6)
	drop if match_id == ""

	save "${nces}NCES_`ncesyear'_School", replace
		
	use "${clean}/KY_AssmtData_`year'", clear
	merge m:1 match_id using "${nces}NCES_`ncesyear'_School"

	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename district_agency_type DistType
	rename school_type SchType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename county_name CountyName
	rename county_code CountyCode

	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == ""
	replace State = "Kentucky"
	replace StateAbbrev = "KY"
	replace StateFips = "21"
	
	replace DistType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def DistType "-1" "Missing/not reported"
	replace SchType = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchType -1 "Missing/not reported"
	replace NCESDistrictID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace State_leaid = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace NCESSchoolID = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace DistCharter = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace SchLevel = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchLevel -1 "Missing/not reported"
	replace SchVirtual = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def SchVirtual -1 "Missing/not reported"
	replace CountyName = "Missing/not reported" if NCESSchoolID == "Missing/not reported"
	replace CountyCode = "-1" if NCESSchoolID == "Missing/not reported"
// 	label def CountyCode -1 "Missing/not reported"

	order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
		
	drop if _merge != 1 & _merge != 3

	drop if StudentSubGroup_TotalTested <= 0

		keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_percent Lev2_percent  Lev3_percent Lev4_percent ProficiencyCriteria ProficientOrAbove_percent Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


	save "${clean}/KY_AssmtData_`year'", replace
	export delimited "${clean}/KY_AssmtData_`year'", replace
}
