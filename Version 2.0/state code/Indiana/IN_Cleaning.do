clear
set more off

global Original "/Users/miramehta/Documents/IN State Testing Data/Original Data Files"
global temp "/Users/miramehta/Documents/IN State Testing Data/Temp"
global Output "/Users/miramehta/Documents/IN State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"

forvalues year = 2014/2024 {
	if `year' == 2020 continue
	
	use "${temp}/IN_`year'", clear
	local prevyear = `year' - 1
	gen SchYear = "`prevyear'-" + substr("`year'",-2,2)
	
	//Rename Variables
	rename corporation_name DistName
	rename school_name SchName
	rename idoe_corporation_id StateAssignedDistID
	rename idoe_school_id StateAssignedSchID
	replace DistName = strtrim(DistName)
	replace DistName = stritrim(DistName)
	replace SchName = strtrim(SchName)
	replace SchName = stritrim(SchName)
	
	replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 3
	replace StateAssignedDistID = "00" + StateAssignedDistID if strlen(StateAssignedDistID) == 2
	replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 3
	replace StateAssignedSchID = "00" + StateAssignedSchID if strlen(StateAssignedSchID) == 2
	
	//Standardize DistName
	replace DistName = "Clinton Central School Corporation" if StateAssignedDistID == "1150"
	replace DistName = "Clinton Prairie School Corporation" if StateAssignedDistID == "1160"
	replace DistName = "East Chicago Urban Enterprise Academy" if StateAssignedDistID == "9555"
	replace DistName = "East Noble School Corporation" if StateAssignedDistID == "6060"
	replace DistName = "Eastern Howard School Corporation" if StateAssignedDistID == "3480"
	replace DistName = "Fayette County School Corporation" if StateAssignedDistID == "2395"
	replace DistName = "Garrett-Keyser-Butler Com Sch Corp" if StateAssignedDistID == "1820"
	replace DistName = "Indiana Department of Correction" if StateAssignedDistID == "9100"
	replace DistName = "Jay School Corporation" if StateAssignedDistID == "3945"
	replace DistName = "Lake Central School Corporation" if StateAssignedDistID == "4615"
	replace DistName = "Linton-Stockton School Corporation" if StateAssignedDistID == "2950"
	replace DistName = "Merrillville Community School Corp" if StateAssignedDistID == "4600"
	replace DistName = "Nettle Creek School Corporation" if StateAssignedDistID == "8305"
	replace DistName = "North Gibson School Corporation" if StateAssignedDistID == "2735"
	replace DistName = "South Gibson School Corporation" if StateAssignedDistID == "2765"
	replace DistName = "Southwest School Corporation" if StateAssignedDistID == "7715"
	replace DistName = "Tri-County School Corporation" if StateAssignedDistID == "8535"
	replace DistName = "Victory College Prep Academy" if StateAssignedDistID == "9575"
	replace DistName = "Western School Corporation" if StateAssignedDistID == "3490"

	//GradeLevel & Subject
	replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0", 1)
	drop if inlist(GradeLevel, "", "G09", "G011", "G012")
	
	replace Subject = "ela" if Subject == "ELA"
	replace Subject = "math" if inlist(Subject, "MATH", "Math")
	replace Subject = "sci" if inlist(Subject, "Science", "SCIENCE")
	replace Subject = "soc" if strpos(Subject, "Social") > 0
	replace Subject = "soc" if Subject == "SS"
	
	//DataLevel
	replace DataLevel = "District" if inlist(DataLevel, "LEA", "CORP", "Corp")
	replace DataLevel = "School" if DataLevel == "SCH"
	
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(nDataLevel) label(DataLevel)
	drop DataLevel
	rename nDataLevel DataLevel
	sort DataLevel

	replace DistName = "All Districts" if DataLevel == 1
	replace SchName = "All Schools" if DataLevel !=3
	replace StateAssignedDistID = "" if DataLevel == 1
	replace StateAssignedSchID = "" if DataLevel != 3
	
	* Adjust misaligned 2015 info
	if `year' == 2015{
		replace DistName = "Edpower Arlington" if StateAssignedSchID == "5465"
		replace StateAssignedDistID = "8830" if StateAssignedSchID == "5465"
	}
	
	* Adjust misaligned 2019 info
	if `year' == 2019{
		replace DistName = "Avondale Meadows Middle School" if StateAssignedSchID == "7094"
		replace StateAssignedDistID = "9040" if StateAssignedSchID == "7094"
		replace DistName = "Enlace Academy" if StateAssignedSchID == "5667"
		replace StateAssignedDistID = "9365" if StateAssignedSchID == "5667"
		replace DistName = "Global Preparatory Academy" if StateAssignedSchID == "1112"
		replace StateAssignedDistID = "9975" if StateAssignedSchID == "1112"
		replace DistName = "Ignite Achievement Academy" if StateAssignedSchID == "1806"
		replace StateAssignedDistID = "9010" if StateAssignedSchID == "1806"
		replace DistName = "KIPP Indy College Prep Middle" if StateAssignedSchID == "5860"
		replace StateAssignedDistID = "9400" if StateAssignedSchID == "5860"
		replace DistName = "KIPP Indy Unite Elementary" if StateAssignedSchID == "5741"
		replace StateAssignedDistID = "9410" if StateAssignedSchID == "5741"
		replace DistName = "Kindezi Academy" if StateAssignedSchID == "1118"
		replace StateAssignedDistID = "9115" if StateAssignedSchID == "1118"
		replace DistName = "Matchbook Learning" if StateAssignedSchID == "1041"
		replace StateAssignedDistID = "9090" if StateAssignedSchID == "1041"
		replace DistName = "Urban ACT Academy" if StateAssignedSchID == "9094"
		replace StateAssignedDistID = "9095" if StateAssignedSchID == "9094"
	}
	
	//Missing & Suppressed Data
	if `year' < 2019 replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "0"
	if `year' < 2019 replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "0"
	foreach var of varlist *_count StudentSubGroup_TotalTested ProficientOrAbove_percent {
	replace `var' = "--" if missing(`var')
	replace `var' = "--" if `var' == "NA"
	replace `var' = "*" if strpos(`var', "*") !=0
	}
	
	//StudentSubGroup & StudentGroup
	replace StudentSubGroup = proper(StudentSubGroup)
	replace StudentSubGroup = subinstr(StudentSubGroup, "_", "", .)
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Ai" | StudentSubGroup == "American Indian"
	replace StudentSubGroup = "Military" if inlist(StudentSubGroup, "Active Duty Parent", "Parent In Military")
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner" | StudentSubGroup == "Ell"
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Frp" | StudentSubGroup == "Free/Reduced Price Meals"
	replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster Student"
	replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Ge" | StudentSubGroup == "General Education"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Mr" | StudentSubGroup == "Multiracial"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Nh" | StudentSubGroup == "Native Hawaiian Or Other Pacific Islander"
	replace StudentSubGroup = "Non-Military" if StudentSubGroup == "No Active Duty Parent"
	replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learner" | StudentSubGroup == "Nonell"
	replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Non-Foster Student"
	replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
	replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Paid Meals" | StudentSubGroup == "Paidmeals"
	replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education" | StudentSubGroup == "Swd"
	drop if StudentSubGroup == "Unknown" //Values for Tested Count make no sense
	
	gen StudentGroup = ""
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "White", "Two or More", "Native Hawaiian or Pacific Islander")
	replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
	replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female", "Gender X")
	replace StudentGroup = "EL Status" if inlist(StudentSubGroup, "English Proficient", "English Learner", "EL Monit or Recently Ex")
	replace StudentGroup = "Disability Status" if inlist(StudentSubGroup, "SWD", "Non-SWD")
	replace StudentGroup = "Migrant Status" if inlist(StudentSubGroup, "Migrant", "Non-Migrant")
	replace StudentGroup = "Homeless Enrolled Status" if inlist(StudentSubGroup, "Homeless", "Non-Homeless")
	replace StudentGroup = "Foster Care Status" if inlist(StudentSubGroup, "Foster Care", "Non-Foster Care")
	replace StudentGroup = "Military Connected Status" if inlist(StudentSubGroup, "Military", "Non-Military")
	
	//Remove Nonsense Observations
	drop if inlist(DistName, "Corp Name", "School Name")
	gen flag = 0
	if `year' < 2019 replace flag = 1 if Lev1_count == "--" & Lev2_count == "--" & Lev3_count == "--"
	if `year' > 2018 replace flag = 1 if Lev1_count == "--" & Lev2_count == "--" & Lev3_count == "--" & Lev4_count == "--"
	sort DataLevel StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentSubGroup flag
	gen flag2 = 1 if StateAssignedDistID[_n-1] == StateAssignedDistID & StateAssignedSchID[_n-1] == StateAssignedSchID & GradeLevel[_n-1] == GradeLevel & Subject[_n-1] == Subject & StudentSubGroup[_n-1] == StudentSubGroup
	drop if flag == 1 & flag2 == 1
	drop flag flag2
	drop if StateAssignedDistID == "-999" //private schools
	
	//Deriving StudentSubGroup_TotalTested
	if `year' < 2019 {
		replace StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count)) if inlist(StudentSubGroup_TotalTested, "*", "--") & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count))
		replace StudentSubGroup_TotalTested = string(real(Lev1_count) + real(ProficientOrAbove_count)) if inlist(StudentSubGroup_TotalTested, "*", "--") & !missing(real(Lev1_count)) & !missing(real(ProficientOrAbove_count))
	}
	if `year' > 2018 {
		replace StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if inlist(StudentSubGroup_TotalTested, "*", "--") & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count))
		replace StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(ProficientOrAbove_count)) if inlist(StudentSubGroup_TotalTested, "*", "--") & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(ProficientOrAbove_count))
	}
	replace StudentSubGroup_TotalTested = string(round(real(ProficientOrAbove_count)/real(ProficientOrAbove_percent))) if !missing(real(ProficientOrAbove_count)) & !missing(real(ProficientOrAbove_percent)) & inlist(StudentSubGroup_TotalTested, "*", "--")
	replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."

	//StudentGroup_TotalTested
	replace StateAssignedDistID = "00000" if DataLevel == 1
	replace StateAssignedSchID = "00000" if DataLevel != 3
	egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
	sort uniquegrp StudentGroup StudentSubGroup
	by uniquegrp: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
	order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
	by uniquegrp: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
	replace StudentGroup_TotalTested = "--" if missing(StudentGroup_TotalTested)
	drop if inlist(StudentSubGroup_TotalTested, "0", "*", "--") & StudentSubGroup != "All Students"
	replace StateAssignedDistID = "" if DataLevel == 1
	replace StateAssignedSchID = "" if DataLevel != 3
	
	//Deriving StudentSubGroup_TotalTested from Counterparts
	gen max = real(StudentGroup_TotalTested)
	replace max = 0 if max == .
	
	bysort uniquegrp: egen RaceEth = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "RaceEth"
	bysort uniquegrp: egen Gender = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "Gender"
	bysort uniquegrp: egen Disability = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "Disability Status"
	bysort uniquegrp: egen Econ = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "Economic Status"
	bysort uniquegrp: egen ELStatus = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "EL Status"
	bysort uniquegrp: egen Homeless = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "Homeless Enrolled Status"
	bysort uniquegrp: egen Foster = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "Foster Care Status"
	bysort uniquegrp: egen Military = sum(real(StudentSubGroup_TotalTested)) if StudentGroup == "Military Connected Status"

	gen x = 1 if missing(real(StudentSubGroup_TotalTested))
	bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentGroup: egen flag = sum(x)

	replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
	replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Disability) if StudentGroup == "Disability Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Econ) if StudentGroup == "Economic Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - ELStatus) if StudentGroup == "EL Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Homeless) if StudentGroup == "Homeless Enrolled Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Foster) if StudentGroup == "Foster Care Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		replace StudentSubGroup_TotalTested = string(max - Military) if StudentGroup == "Military Connected Status" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag == 1
		drop uniquegrp x flag RaceEth Gender Disability Econ ELStatus Homeless Foster Military
	
	//Deriving Performance Information
	if `year' < 2019{
		replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(ProficientOrAbove_count)) if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(ProficientOrAbove_count)) & Lev1_count == "--"
	}
	
	foreach var of varlist *_count {
		if "`var'" == "ProficientOrAbove_count" continue
		local a = subinstr("`var'", "count", "percent", 1)
		gen `a' = real(`var')/real(StudentSubGroup_TotalTested) if !inlist(`var', "*", "--") & !inlist(StudentSubGroup_TotalTested, "*", "--")
	}
	
	if `year' < 2019{
		replace ProficientOrAbove_count = string(real(Lev2_count) + real(Lev3_count)) if inlist(ProficientOrAbove_count, "*", "--") & !inlist(Lev2_count, "*", "--") & !inlist(Lev3_count, "*", "--")	
		replace ProficientOrAbove_percent = string(Lev2_percent + Lev3_percent, "%10.0g") if inlist(ProficientOrAbove_percent, "*", "--") & Lev2_percent != . & Lev3_percent != .
	}
	if `year' > 2018{
		replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if inlist(ProficientOrAbove_count, "*", "--") & !inlist(Lev3_count, "*", "--") & !inlist(Lev4_count, "*", "--")	
		replace ProficientOrAbove_percent = string(Lev3_percent + Lev4_percent, "%10.0g") if inlist(ProficientOrAbove_percent, "*", "--") & Lev3_percent != . & Lev4_percent != .
	}
	
	foreach var of varlist *_percent {
		if "`var'" == "ProficientOrAbove_percent" continue
		local a = subinstr("`var'", "percent", "count", 1)
		tostring `var', replace format("%10.0g") force
		replace `var' = "*" if `a' == "*"
		replace `var' = "--" if `var' == "."
	}
	
	if `year' < 2019{
		gen Lev4_count = ""
		gen Lev4_percent = ""
	}
	
	gen Lev5_count = ""
	gen Lev5_percent = ""
	gen AvgScaleScore = "--"
	gen ParticipationRate = "--"
	
	//Assessment Information
	if `year' < 2019 gen AssmtName = "ISTEP"
	if `year' > 2018 gen AssmtName = "ILEARN"
	gen AssmtType = "Regular"
	if `year' < 2019 gen ProficiencyCriteria = "Levels 2-3"
	if `year' > 2018 gen ProficiencyCriteria = "Levels 3-4"
	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_sci = "N"
	gen Flag_CutScoreChange_soc = "N"
	if `year' == 2015{
		replace Flag_CutScoreChange_ELA = "Y"
		replace Flag_CutScoreChange_math = "Y"
	}
	if `year' == 2019 {
		replace Flag_AssmtNameChange = "Y"
		replace Flag_CutScoreChange_ELA = "Y"
		replace Flag_CutScoreChange_math = "Y"
		replace Flag_CutScoreChange_sci = "Y"
		replace Flag_CutScoreChange_soc = "Y"	
	}
	if `year' == 2024 {
		replace Flag_CutScoreChange_sci = "Y"
	}
	
	//Merge with NCES
	gen State_leaid = StateAssignedDistID
	gen seasch = StateAssignedSchID
	
	if `year' != 2024{
		merge m:1 State_leaid using "$NCES/NCES_`prevyear'_District_IN.dta", update replace //pulling in NCES district names because some names are listed differently in ela/math and sci/soc files
		drop if _merge == 2
		drop if _merge == 1 & DataLevel != 1 //These are private schools not in NCES and should be dropped for our purposes
		drop _merge
	
		merge m:1 State_leaid seasch using "$NCES/NCES_`prevyear'_School_IN.dta", update replace //pulling in NCES school names because some names are listed differently in ela/math and sci/soc files
		drop if _merge == 2
		*replace seasch = "0" + seasch if _merge == 1 & DataLevel == 3
		*replace StateAssignedSchID = seasch if StateAssignedSchID != seasch //Update stae ID for consistency across years
		drop _merge
		*merge m:1 State_leaid seasch using "$NCES/NCES_`prevyear'_School_IN.dta", update replace
		*drop if _merge == 2
		*drop _merge
	}
	
	if `year' == 2024{
		merge m:1 State_leaid using "$NCES/NCES_2022_District_IN.dta", update replace //pulling in NCES district names because some names are listed differently in ela/math and sci/soc files
		drop if _merge == 2
		drop if _merge == 1 & DataLevel != 1 & !inlist(StateAssignedDistID, "9027", "9022", "9004", "9043") //These are private schools not in NCES and should be dropped for our purposes
		drop _merge
	
		merge m:1 State_leaid seasch using "$NCES/NCES_2022_School_IN.dta", update replace //pulling in NCES school names because some names are listed differently in ela/math and sci/soc files
		drop if _merge == 2
		drop _merge
		
		//2024 New Districts & Schools
		replace NCESDistrictID = "1813237" if StateAssignedDistID == "9027"
		replace DistType = "Charter agency" if NCESDistrictID == "1813237"
		replace DistCharter = "Yes" if NCESDistrictID == "1813237"
		replace DistLocale = "City, midsize" if NCESDistrictID == "1813237"
		replace CountyName = "St. Joseph County" if NCESDistrictID == "1813237"
		replace CountyCode = "18141" if NCESDistrictID == "1813237"
		replace NCESDistrictID = "1813236" if StateAssignedDistID == "9022"
		replace DistType = "Charter agency" if NCESDistrictID == "1813236"
		replace DistCharter = "Yes" if NCESDistrictID == "1813236"
		replace DistLocale = "City, small" if NCESDistrictID == "1813236"
		replace CountyName = "Tippecanoe County" if NCESDistrictID == "1813236"
		replace CountyCode = "18157" if NCESDistrictID == "1813236"
		replace NCESDistrictID = "1813235" if StateAssignedDistID == "9004"
		replace DistType = "Charter agency" if NCESDistrictID == "1813235"
		replace DistCharter = "Yes" if NCESDistrictID == "1813235"
		replace DistLocale = "City, midsize" if NCESDistrictID == "1813235"
		replace CountyName = "St. Joseph County" if NCESDistrictID == "1813235"
		replace CountyCode = "18141" if NCESDistrictID == "1813235"
		replace NCESDistrictID = "1813239" if StateAssignedDistID == "9043"
		replace DistType = "Charter agency" if NCESDistrictID == "1813239"
		replace DistCharter = "Yes" if NCESDistrictID == "1813239"
		replace DistLocale = "City, small" if NCESDistrictID == "1813239"
		replace CountyName = "Elkhart County" if NCESDistrictID == "1813239"
		replace CountyCode = "18039" if NCESDistrictID == "1813239"
		
		replace NCESSchoolID = "181323702774" if StateAssignedSchID == "1132" & StateAssignedDistID == "9027"
		replace SchType = "Regular school" if NCESSchoolID == "181323702774"
		replace SchLevel = "Primary" if NCESSchoolID == "181323702774"
		replace SchVirtual = "No" if NCESSchoolID == "181323702774"
		replace NCESSchoolID = "181323602773" if StateAssignedSchID == "9016" & StateAssignedDistID == "9022"
		replace SchType = "Regular school" if NCESSchoolID == "181323602773"
		replace SchLevel = "Primary" if NCESSchoolID == "181323602773"
		replace SchVirtual = "No" if NCESSchoolID == "181323602773"
		replace NCESSchoolID = "181323502772" if StateAssignedSchID == "9008" &  StateAssignedDistID == "9004"
		replace SchType = "Regular school" if NCESSchoolID == "181323502772"
		replace SchLevel = "Primary" if NCESSchoolID == "181323502772"
		replace SchVirtual = "No" if NCESSchoolID == "181323502772"
		replace NCESSchoolID = "181323902776" if StateAssignedSchID == "9042" & StateAssignedDistID == "9043"
		replace SchType = "Regular school" if NCESSchoolID == "181323902776"
		replace SchLevel = "Primary" if NCESSchoolID == "181323902776"
		replace SchVirtual = "No" if NCESSchoolID == "181323902776"
		replace NCESSchoolID = "180102002760" if StateAssignedSchID == "2722" & StateAssignedDistID == "3305"
		replace SchType = "Regular school" if NCESSchoolID == "180102002760"
		replace SchLevel = "Primary" if NCESSchoolID == "180102002760" 
		replace SchVirtual = "No" if NCESSchoolID == "180102002760" 
		replace NCESSchoolID = "180264002765" if StateAssignedSchID == "5180" & StateAssignedDistID == "5300"
		replace SchType = "Regular school" if NCESSchoolID == "180264002765"
		replace SchLevel = "Primary" if NCESSchoolID == "180264002765"
		replace SchVirtual = "No" if NCESSchoolID == "180264002765"
		replace NCESSchoolID = "180001402779" if StateAssignedSchID == "1531" & StateAssignedDistID == "9330"
		replace SchType = "Regular school" if NCESSchoolID == "180001402779"
		replace SchLevel = "Primary" if NCESSchoolID == "180001402779"
		replace SchVirtual = "No" if NCESSchoolID == "180001402779"
		replace NCESSchoolID = "180001402780" if StateAssignedSchID == "1532" & StateAssignedDistID == "9330"
		replace SchType = "Regular school" if NCESSchoolID == "180001402780"
		replace SchLevel = "Middle" if NCESSchoolID == "180001402780"
		replace SchVirtual = "No" if NCESSchoolID == "180001402780"
		replace NCESSchoolID = "180537000952" if StateAssignedSchID == "2981" & StateAssignedDistID == "3500"
		replace SchType = "Regular school" if NCESSchoolID == "180537000952"
		replace SchLevel = "Primary" if NCESSchoolID == "180537000952"
		replace SchVirtual = "No" if NCESSchoolID == "180537000952"
		replace NCESSchoolID = "181008002762" if StateAssignedSchID == "3678" & StateAssignedDistID == "3675"
		replace SchType = "Regular school" if NCESSchoolID == "181008002762"
		replace SchLevel = "Middle" if NCESSchoolID == "181008002762"
		replace SchVirtual = "No" if NCESSchoolID == "181008002762"
		replace NCESSchoolID = "180477000897" if StateAssignedSchID == "5514" & StateAssignedDistID == "5385"
		replace SchType = "Regular school" if NCESSchoolID == "180477000897"
		replace SchLevel = "Primary" if NCESSchoolID == "180477000897"
		replace SchVirtual = "No" if NCESSchoolID == "180477000897"
		replace NCESSchoolID = "181191002770" if StateAssignedSchID == "7602" & StateAssignedDistID == "7215"
		replace SchType = "Regular school" if NCESSchoolID == "181191002770"
		replace SchLevel = "High" if NCESSchoolID == "181191002770"
		replace SchVirtual = "Yes" if NCESSchoolID == "181191002770"
	}
	
	//Fixing Unmerged Schools
	replace NCESSchoolID = "181281002041" if SchName == "Sanders School" & missing(NCESSchoolID)
	replace SchType = "Special education school" if SchName == "Sanders School" & missing(SchType)
	replace SchLevel = "Other" if SchName == "Sanders School" & missing(SchLevel)
	replace SchVirtual = "No" if SchName == "Sanders School" & missing(SchVirtual)
	
	//Cleaning up from NCES
	replace State = "Indiana"
	replace StateAbbrev = "IN"
	replace StateFips = 18
	
	replace CountyName = strproper(CountyName)
	replace CountyName = "DeKalb County" if CountyName == "Dekalb County"
	replace CountyName = "LaGrange County" if CountyName == "Lagrange County"
	replace CountyName = "LaPorte County" if CountyName == "Laporte County"
	
//Final Cleaning
duplicates drop

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/IN_AssmtData_`year'", replace
export delimited "${Output}/IN_AssmtData_`year'", replace
}
