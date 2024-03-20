clear all
set more off

cd "/Users/miramehta/Documents/"
global data "/Users/miramehta/Documents/NJ State Testing Data"
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"
global NCESDistrict "/Users/miramehta/Documents/NCES District and School Demographics/NCES District Files, Fall 1997-Fall 2022"
global NCESClean "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

set trace off

forvalues year = 2019/2023{
	if inlist(`year', 2020, 2021) {
		continue
	}
	local prevyear = `year' - 1
	
	//Import Excel Files and Convert to .dta Files
		forvalues n = 3/8{
			if `year' == 2022 & `n' == 3{
				import excel "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q26162) clear
			}
			else if `year' == 2023 & `n' == 4{
				import excel "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q25782) clear
			}
			else if `year' == 2023 & `n' == 5{
				import excel "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q24366) clear
			}
			else if `year' == 2023 & `n' == 6{
				import excel "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q19447) clear
			}
			else if `year' == 2023 & `n' == 7{
				import excel "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q17619) clear
			}
			else if `year' == 2023 & `n' == 8{
				import excel "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", cellrange (A3:Q17540) clear
			}
			else{
				import excel "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", clear
			}			
			gen Subject = "ela"
	
			gen GradeLevel = "G0`n'"

			drop if A == "County Code"

			rename C StateAssignedDistID
			rename D DistName
			rename E StateAssignedSchID
			rename F SchName
			rename G StudentGroup
			rename H StudentSubGroup
			rename L AvgScaleScore
			rename M Lev1_percent
			rename N Lev2_percent
			rename O Lev3_percent
			rename P Lev4_percent
			rename Q Lev5_percent

			save "${data}/`year'/NJ_OriginalData_`year'_ela_G0`n'", replace
			
			if `year' == 2023 & `n' == 4 {
				import excel "${data}/`year'/NJ_OriginalData_`year'_mat_G0`n'", cellrange (A1:Q25854) clear
			}
			else {
				import excel "${data}/`year'/NJ_OriginalData_`year'_mat_G0`n'", clear
			}
			gen Subject = "math"
	
			gen GradeLevel = "G0`n'"

			drop if A == "County Code"

			rename C StateAssignedDistID
			rename D DistName
			rename E StateAssignedSchID
			rename F SchName
			rename G StudentGroup
			rename H StudentSubGroup
			rename L AvgScaleScore
			rename M Lev1_percent
			rename N Lev2_percent
			rename O Lev3_percent
			rename P Lev4_percent
			rename Q Lev5_percent
			save "${data}/`year'/NJ_OriginalData_`year'_mat_G0`n'", replace
			
			if inlist(`n', 5, 8){
				import excel "${data}/`year'/NJ_OriginalData_`year'_sci_G0`n'", clear
				gen Subject = "sci"
	
				gen GradeLevel = "G0`n'"

				drop if A == "County Code"

				rename C StateAssignedDistID
				rename D DistName
				rename E StateAssignedSchID
				rename F SchName
				rename G StudentGroup
				rename H StudentSubGroup
				rename L AvgScaleScore
				rename M Lev1_percent
				rename N Lev2_percent
				rename O Lev3_percent
				rename P Lev4_percent
				gen Lev5_percent = ""
				save "${data}/`year'/NJ_OriginalData_`year'_sci_G0`n'", replace
			}
		}
	

	use "${data}/`year'/NJ_OriginalData_`year'_ela_G03", clear
	
	append using "${data}/`year'/NJ_OriginalData_`year'_ela_G04" "${data}/`year'/NJ_OriginalData_`year'_ela_G05" 	"${data}/`year'/NJ_OriginalData_`year'_ela_G06" "${data}/`year'/NJ_OriginalData_`year'_ela_G07" "${data}/`year'/NJ_OriginalData_`year'_ela_G08"
	
	append using "${data}/`year'/NJ_OriginalData_`year'_mat_G03" "${data}/`year'/NJ_OriginalData_`year'_mat_G04" "${data}/`year'/NJ_OriginalData_`year'_mat_G05" "${data}/`year'/NJ_OriginalData_`year'_mat_G06" "${data}/`year'/NJ_OriginalData_`year'_mat_G07" "${data}/`year'/NJ_OriginalData_`year'_mat_G08"
	append using "${data}/`year'/NJ_OriginalData_`year'_sci_G05" "${data}/`year'/NJ_OriginalData_`year'_sci_G08"
	save "${data}/`year'/NJ_OriginalData_`year'", replace

	//Clean DTA File (Pre-Merge)
	use "${data}/`year'/NJ_OriginalData_`year'", clear

	drop if StateAssignedDistID == "DFG Not Designated"
	drop if strupper(DistName) == "DISTRICT NAME"
	drop if AvgScaleScore == ""

	*Data Levels
	gen DataLevel = "School"
	replace DataLevel = "District" if SchName == "" & DistName != ""
	replace DataLevel = "District" if SchName == "District Total"
	replace DataLevel = "State" if SchName == "" & DistName == ""

	replace SchName = "All Schools" if DataLevel != "School"
	replace DistName = "All Districts" if DataLevel == "State"
	replace StateAssignedSchID = "" if DataLevel != "School"
	replace StateAssignedDistID = "" if DataLevel == "State"

	*Student Groups, SubGroups, & Counts
	drop if strupper(StudentSubGroup) == "SE ACCOMMODATION"

	replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL STUDENTS"
	replace StudentSubGroup = "American Indian or Alaska Native" if strupper(StudentSubGroup) == "AMERICAN INDIAN"
	replace StudentSubGroup = "Asian" if StudentSubGroup == "ASIAN"
	replace StudentSubGroup = "Black or African American" if strupper(StudentSubGroup) == "AFRICAN AMERICAN"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if inlist(StudentSubGroup, "NATIVE HAWAIIAN", "NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER", "Native Hawaiian")
	replace StudentSubGroup = "White" if StudentSubGroup == "WHITE"
	replace StudentSubGroup = "Hispanic or Latino" if strupper(StudentSubGroup) == "HISPANIC"
	replace StudentSubGroup = "Unknown" if strupper(StudentSubGroup) == "OTHER"
	replace StudentSubGroup = "Male" if StudentSubGroup == "MALE"
	replace StudentSubGroup = "Female" if StudentSubGroup == "FEMALE"
	replace StudentSubGroup = "SWD" if strupper(StudentSubGroup) == "STUDENTS WITH DISABILITIES" | StudentSubGroup == "STUDENTS WITH DISABLITIES"
	replace StudentSubGroup = "English Learner" if strupper(StudentSubGroup) == "CURRENT - ELL"
	replace StudentSubGroup = "Economically Disadvantaged" if strupper(StudentSubGroup) == "ECONOMICALLY DISADVANTAGED"
	replace StudentSubGroup = "Not Economically Disadvantaged" if strupper(StudentSubGroup) == "NON-ECON. DISADVANTAGED" |StudentSubGroup == "NON ECON. DISADVANTAGED"
	replace StudentSubGroup = "EL Exited" if strupper(StudentSubGroup) == "FORMER - ELL"
	replace StudentSubGroup = "Ever EL" if strupper(StudentSubGroup) == "ENGLISH LANGUAGE LEARNERS" | strupper(StudentSubGroup) == "ENGLISH LEARNERS"
	replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-Binary/Undesignated"
	
	replace StudentGroup = "RaceEth" if strupper(StudentGroup) == "RACE/ETHNICITY"
	replace StudentGroup = "Gender" if strupper(StudentGroup) == "GENDER"
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Learner", "EL Exited")
	replace StudentGroup = "Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged", "Not Economically Disadvantaged")
	replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
	replace StudentGroup = "Placeholder" if StudentSubGroup == "Ever EL"

	gen StudentSubGroup_TotalTested = K
	destring K, replace force
	replace K = -1000000000 if K == .
	bys DataLevel DistName SchName StudentGroup GradeLevel Subject: egen StudentGroup_TotalTested = total(K)
	replace StudentGroup_TotalTested =. if StudentGroup_TotalTested < 0
	tostring StudentGroup_TotalTested, replace
	replace StudentGroup_TotalTested = "*" if StudentGroup_TotalTested == "."
	replace StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentGroup == "Placeholder"
	replace StudentGroup = "EL Status" if StudentGroup == "Placeholder"

	*Generate Additional Variables
	gen SchYear = "`prevyear'-`year'"
	replace SchYear = substr(SchYear, 1, 5) + substr(SchYear, 8, 9)
	gen AssmtName = "NJSLA"
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_sci = "N"
	gen Flag_CutScoreChange_soc = ""
	gen AssmtType = "Regular"
	gen ProficiencyCriteria = "Levels 4-5"
	replace ProficiencyCriteria = "Levels 3-4" if Subject == "sci"
	gen ParticipationRate = "--"
	
	if `year' == 2019{
		replace Flag_AssmtNameChange = "Y"
	}

	*Fixing Counts and Percents
	forvalues x = 1/5{
		destring Lev`x'_percent, gen(Level`x') force
		replace Level`x' = Level`x'/100
		gen Lev`x'_count = K * Level`x'
		replace Lev`x'_count = . if Lev`x'_count < 0
		replace Lev`x'_count = . if Lev`x'_percent == "*"
	}

	gen ProficientOrAbove_percent = Level4 + Level5
	replace ProficientOrAbove_percent = Level3 + Level4 if Subject == "sci"
	gen ProficientOrAbove_count = K * ProficientOrAbove_percent
	replace ProficientOrAbove_count = . if ProficientOrAbove_count < 0
	replace ProficientOrAbove_count = . if ProficientOrAbove_percent == .

	forvalues x = 1/5{
		tostring Level`x', replace format("%10.0g") force
		replace Lev`x'_percent = Level`x' if Lev`x'_percent != "*"
		replace Lev`x'_count = round(Lev`x'_count)
		tostring Lev`x'_count, replace
		replace Lev`x'_count = "*" if Lev`x'_count == "."
		drop Level`x'
	}
	replace Lev5_percent = "" if Subject == "sci"
	replace Lev5_count = "" if Subject == "sci"

	tostring ProficientOrAbove_percent, replace format("%10.0g") force
	replace ProficientOrAbove_count = round(ProficientOrAbove_count)
	tostring ProficientOrAbove_count, replace
	replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
	replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
	drop K

	save "${data}/NJ_OriginalData_`year'", replace

	//Clean NCES Data
	if `year' < 2022{
		use "${NCESSchool}/NCES_`prevyear'_School.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 8)
		gen str StateAssignedSchID = substr(seasch, 8, 10)
		save "${NCESClean}/NCES_`prevyear'_School_NJ.dta", replace

		use "${NCESDistrict}/NCES_`prevyear'_District.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 8)
		save "${NCESClean}/NCES_`prevyear'_District_NJ.dta", replace
	}
	if `year' == 2022{
		use "${NCESSchool}/NCES_`prevyear'_School.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 10)
		gen str StateAssignedSchID = substr(seasch, 8, 11)
		save "${NCESClean}/NCES_`prevyear'_School_NJ.dta", replace

		use "${NCESDistrict}/NCES_`prevyear'_District.dta", clear
		drop if state_location != "NJ"
		gen str StateAssignedDistID = substr(state_leaid, 6, 10)
		save "${NCESClean}/NCES_`prevyear'_District_NJ.dta", replace
	}
	
	if `year' == 2023{
		import excel "${NCESSchool}/NCES_`prevyear'_School.xlsx", clear
		gen state_name = "New Jersey"
		drop if C != "NJ"
		rename C state_location
		rename D state_fips
		destring state_fips, replace force
		rename E DistName
		rename F ncesdistrictid
		gen str StateAssignedDistID = substr(G, 6, 9)
		drop G
		gen str StateAssignedSchID = substr(N, 11, 13)
		drop N
		destring StateAssignedDistID, replace force
		drop if StateAssignedDistID==.
		destring StateAssignedSchID, replace force
		drop if StateAssignedSchID==.
		rename I ncesschoolid
		rename J SchType
		rename K SchVirtual
		rename L SchLevel
		rename M SchName
		merge 1:1 ncesdistrictid ncesschoolid using "${NCESClean}/NCES_2021_School_NJ.dta", keepusing (DistLocale county_code county_name district_agency_type)
		drop if _merge == 2
		drop _merge
		save "${NCESClean}/NCES_`prevyear'_School_NJ.dta", replace
		
		import excel "$NCES/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District.xlsx", clear
		drop if C != "NJ"
		rename E DistName
		gen str StateAssignedDistID = substr(G, 6, 9)
		drop G
		destring StateAssignedDistID, replace force
		drop if StateAssignedDistID==.
		rename F ncesdistrictid
		rename H district_agency_type
		merge 1:1 ncesdistrictid using "${NCESClean}/NCES_2021_District_NJ.dta", keepusing (DistLocale county_code county_name DistCharter)
		drop if _merge == 2
		drop _merge
		save "${NCESClean}/NCES_`prevyear'_District_NJ.dta", replace
	}

	//Merge Data
	use "${data}/NJ_OriginalData_`year'", clear
	if `year' == 2023{
		destring StateAssignedDistID, replace force
		destring StateAssignedSchID, replace force
	}
	merge m:1 StateAssignedDistID using "${NCES}/Cleaned NCES Data/NCES_`prevyear'_District_NJ.dta"
	drop if _merge == 2

	merge m:1 StateAssignedSchID StateAssignedDistID using "${NCESClean}/NCES_`prevyear'_School_NJ.dta", gen (merge2)
	drop if merge2 == 2

	//Clean Merged Data
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	rename ncesdistrictid NCESDistrictID
	rename ncesschoolid NCESSchoolID
	rename district_agency_type DistType
	rename county_name CountyName
	rename county_code CountyCode

	replace State = "New Jersey"
	replace StateAbbrev = "NJ"
	replace StateFips = 34

	*Variable Types
	if `year' != 2023{
		decode SchVirtual, gen(SchVirtual_s)
		drop SchVirtual
		rename SchVirtual_s SchVirtual

		decode SchLevel, gen(SchLevel_s)
		drop SchLevel
		rename SchLevel_s SchLevel

		decode SchType, gen (SchType_s)
		drop SchType
		rename SchType_s SchType
	}
	
	//Organize Variables
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel

	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

	save "${data}/NJ_AssmtData_`year'", replace
	export delimited "${data}/NJ_AssmtData_`year'", replace
	clear
}
