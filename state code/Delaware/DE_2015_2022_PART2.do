clear
set more off
set trace off
cap log close

log using "/Users/joshuasilverman/Desktop/observe.log", replace

//NOTE: IF YOU'RE RECREATING CLEANING PROCESS, RUN DE_2015_2022 CODE FIRST. Check all sections to set directories before running.

local data "/Volumes/T7 1/State Test Project/Delaware/Original/Combined .dta by DataLevel & Year"

foreach year in 2015 2016 2017 {
	di as error "`year'"
//State
	use "`data'/State_`year'_DCAS.dta", clear
	if `year' == 2017 {
		rename PercentProficient PercentProficiency
	}
	//Converting to Percents
		destring PL*, replace i(<>=)
		foreach n in 1 2 3 4 {
			replace PL`n' = PL`n'/100
		}
		destring ParticipationRate, replace i(<>=)
		replace ParticipationRate = ParticipationRate/100
		replace PercentProficiency = PercentProficiency/100
		
	//Fixing Grade and Subject
		gen Grade = "G0" + substr(Subject, strpos(Subject, "Grade")+6,1)
		gen Subject1 = substr(Subject, strpos(Subject, "Grade")+7,10)
		drop Subject
		rename Subject1 Subject
	//Generating empty variables
		gen District = ""
		gen SchoolName = ""
	//Variables: Group NumberTested MeanScaleScore PercentProficiency ParticipationRate PL1-4 Subject Grade District SchoolName
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile State_`year'
	save "`State_`year''"
	
	
//District 
	use "`data'/District_`year'_DCAS.dta", clear
	if `year' != 2017 {
	drop G PercentProficient I
	}
	else if `year' == 2017 {
		drop G H I
		rename PercentProficient PercentProficiency
	}
	//Fixing District for 2016 & 2017
	if `year' !=2015 {
	gen District1 = subinstr(District," Performance and Participation","", .)
	drop District
	rename District1 District
	}
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = PercentProficiency/100
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = ParticipationRate/100
	
	//Fixing Grade and Subject
	rename Data Subject
	gen Grade = "G0" + substr(Subject, strpos(Subject, "Grade")+6,1)
	gen Subject1 = substr(Subject, strpos(Subject, "Grade")+7,10)
	drop Subject
	rename Subject1 Subject
	//Generating empty variables
	foreach s in 1 2 3 4 {
		gen PL`s'=.
	}
	gen SchoolName = ""
	gen NumberTested =.
	//Variables: District Group MeanScaleScore PercentProficiency ParticipationRate PL1-4 Subject Grade SchoolName NumberTested
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile District_`year'

	
	
	
	save "`District_`year''"

//School
	use "`data'/School_`year'_DCAS.dta", clear
	if `year' != 2017 {
	drop G PercentProficient I
	}
	else if `year' == 2017 {
		drop F G H
		rename PercentProficient PercentProficiency
	}
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = PercentProficiency/100
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = ParticipationRate/100
	
	//Fixing Grade and Subject
	gen Subject1 ="" 
	replace Subject1 = substr(Subject, strpos(Subject, "-")+2,10) if strpos(Subject,"-") !=0
	replace Subject1 = Subject if strpos(Subject,"-") !=0
	drop Subject
	capture noisily rename Subject1 Subject
	capture drop if Subject = "The Wallace Wallin School"
	tostring Grade, replace
	gen Grade1 = "G0" + Grade
	drop Grade
	rename Grade1 Grade
	//Generating Empty Variables
	foreach s in 1 2 3 4 {
		gen PL`s'=.
	}
	gen District = ""
	gen NumberTested =.
	gen Group = "All Students"
	//Variables: Subject SchoolName Grade MeanScaleScore PercentProficiency ParticipationRate PL1-4 District NumberTested Group
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile School_`year'
	save "`School_`year''"
//Charter (for 2016 & 17)
	if `year' != 2015 {
	use "`data'/Charter_`year'_DCAS.dta"
	rename School SchoolName
	if `year' != 2017 {
	drop G H I
	rename PercentProficient PercentProficiency
	}
	else if `year' == 2017 {
		drop F G H
		rename PercentProficient PercentProficiency
	}
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = PercentProficiency/100
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = ParticipationRate/100
	
	//Fixing Grade and Subject
	gen Subject1 ="" 
	replace Subject1 = substr(Subject, strpos(Subject, "-")+2,10) if strpos(Subject,"-") !=0
	replace Subject1 = Subject if strpos(Subject,"-") !=0
	drop Subject
	rename Subject1 Subject
	capture drop if Subject = "The Wallace Wallin School"
	tostring Grade, replace
	gen Grade1 = "G0" + Grade
	drop Grade
	rename Grade1 Grade
	//Generating Empty Variables
	foreach s in 1 2 3 4 {
		gen PL`s'=.
	}
	gen District = ""
	gen NumberTested =.
	gen Group = "All Students"
	//Variables: Subject SchoolName Grade MeanScaleScore PercentProficiency ParticipationRate PL1-4 District NumberTested Group
	tostring MeanScaleScore, replace
	tostring NumberTested, replace
	tempfile Charter_`year'
	save "`Charter_`year''"
	clear
	}
	if `year' == 2015 {
	append using "`State_`year''" "`District_`year''" "`School_`year''"
	save "`data'/Combined_`year'", replace
	}
	else {
	append using "`State_`year''" "`District_`year''"  "`School_`year''" "`Charter_`year''"
	save "`data'/Combined_`year'", replace
	}
	
	clear
	
	
	}

//Additional Cleaning- SET ADDITIONAL FILE DIRECTORIES

local data "/Volumes/T7 1/State Test Project/Delaware/Original/Combined .dta by DataLevel & Year"
local cleaned "/Volumes/T7 1/State Test Project/Delaware/Cleaned"
	foreach year in 2015 2016 2017 {
		use "`data'/Combined_`year'"
		
		//getting rid of extra grades
		keep if Grade == "G04" | Grade == "G05" | Grade == "G07" | Grade == "G08"
		replace Subject = "sci" if Grade== "G05" | Grade == "G08"
		replace Subject = "soc" if Grade== "G04" | Grade == "G07"
		
		
		
		//renaming vars
		rename Group StudentSubGroup
		rename NumberTested StudentSubGroup_TotalTested
		rename MeanScaleScore AvgScaleScore
		rename PercentProficiency ProficientOrAbove_percent
		rename PL1 Lev1_percent
		rename PL2 Lev2_percent
		rename PL3 Lev3_percent
		rename PL4 Lev4_percent
		rename Grade GradeLevel
		replace District = "All Districts" if !missing(Lev1_percent) | !missing(Lev3_percent)
		rename District DistName
		gen DataLevel = ""
		replace DataLevel = "State" if !missing(Lev1_percent) | !missing(Lev3_percent)
		replace DataLevel = "District" if strpos(DistName, "District") !=0 & DataLevel != "State"
		capture replace SchName = School if missing(SchName)
		replace DataLevel = "School" if !missing(SchoolName)
		replace SchoolName = "All Schools" if DataLevel == "State" | DataLevel == "District"
		
		
		//fixing school
		rename SchoolName SchName
		replace SchName = SchName[_n-1] if missing(SchName)
		replace DataLevel = "School" if missing(DataLevel)
		
		//levels
		foreach n in 1 2 3 4 5 {
			gen Lev`n'_count=.
		}
		gen Lev5_percent=.
		
		//StudentSubGroup
		replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
		replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian"
		replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Hawaiian/Pacific Islander"
		replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian American"
		replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
		replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
		replace StudentSubGroup = "English Learner" if StudentSubGroup == "ELL"
		replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low-Income"
		drop if StudentSubGroup == "Student Gap Group" | StudentSubGroup == "Students with Disability"
		
		//StudentGroup
		gen StudentGroup = ""
		replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Two or More" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
		replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
		replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
		replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
		*count if StudentGroup == "" & School != "All Schools"
		
		//Misc
		replace SchName = "Delaware Day Treatment Center (6-14) Dover" if SchName == "Delaware Day Treatment Center (6- 14) Dover"

		tempfile CombinedSCISOC_`year'
		save "`CombinedSCISOC_`year''"
		clear
		
		//Using already cleaned ELA and Math data to get data for each scool and district
		use "`cleaned'/DE_AssmtData_`year'.dta"
		drop if DataLevel !=3
		keep NCESDistrictID DistType State_leaid StateAssignedDistID NCESSchoolID StateAssignedSchID seasch SchLevel SchVirtual CountyName CountyCode SchName DistName SchType DistCharter
		duplicates drop
		duplicates drop SchName, force
		merge 1:m SchName using "`CombinedSCISOC_`year''"
		drop if _merge ==1 & DataLevel == "" //Checked manually, dropped schools are not found in Sci / Soc data
		rename _merge _merge1
		drop if DataLevel != "School"
		tempfile School
		save "`School'"
		clear
		use "`cleaned'/DE_AssmtData_`year'.dta"
		drop if DataLevel !=2
		keep NCESDistrictID StateAssignedDistID DistType State_leaid CountyName CountyCode DistName DistCharter
		duplicates drop DistName, force
		merge 1:m DistName using "`CombinedSCISOC_`year''"
		drop if DistName == "Dept. of Svs. for Children Youth & Their Families" //Not in Sci / Soc data
		drop if DataLevel == "School"
		rename _merge _merge2
		append using "`School'"

		
		//Trying to merge unmerged schools from NCES Data
		tempfile idk
		save "`idk'"
//Change Directory for NCES School data below
		local prevyear =`=`year'-1'
		local NCES "/Volumes/T7 1/State Test Project/NCES/School/"
		use "`NCES'NCES_`prevyear'_School.dta", clear
		rename school_name SchName
		drop if state_fips != 10
		rename ncesschoolid NCESSchoolID
		rename ncesdistrictid NCESDistrictID
		gen StateAssignedSchID = seasch
		rename lea_name DistName
		gen StateAssignedDistID = state_leaid
		rename state_leaid State_leaid
		rename school_type SchType
		rename county_code CountyCode
		rename county_name CountyName
		rename district_agency_type DistType
		decode DistType, gen(temp)
		drop DistType
		rename temp DistType
		decode SchLevel, gen(temp)
		drop SchLevel
		rename temp SchLevel
		decode SchVirtual, gen(temp)
		drop SchVirtual
		rename temp SchVirtual
		decode SchType, gen(temp)
		drop SchType
		rename temp SchType
		keep NCESSchoolID SchName NCESDistrictID StateAssignedSchID DistName StateAssignedDistID SchType CountyCode CountyName DistType DistCharter SchType seasch SchLevel SchVirtual State_leaid
		keep if SchName == "Carver (G.W.) Educational Center" | SchName == "Central School (The)" | SchName == "Douglass School" | SchName == "First State School" | SchName == "Kent County Secondary ILC" | SchName == "Penn (William) High School" | SchName == "Delaware School for the Deaf" | SchName == "Sussex Consortium" | SchName == "Richardson Park Learning Center" | SchName == "Family Foundations Academy" | SchName == "Sussex Academy of Arts and Sciences"
		replace SchName = "Delaware School for the Deaf School (DSD)" if SchName == "Delaware School for the Deaf" 
		merge 1:m SchName using "`idk'"
		rename _merge _merge3
		drop if _merge3 ==1

		
		
		//Leftover Schools still not merged: Kent Elementary Intensive Learning Center and The Wallace Wallin School, neither of which were found in correct NCES data but can be found online
		
		//Kent Instensive:
		replace NCESSchoolID = "100018000018" if SchName == "Kent Elementary Intensive Learning Center"
		replace StateAssignedSchID = "615" if SchName == "Kent Elementary Intensive Learning Center"
		replace DistName = "Caesar Rodney School District" if SchName == "Kent Elementary Intensive Learning Center"
		replace NCESDistrictID = "1000180" if SchName == "Kent Elementary Intensive Learning Center"
		replace StateAssignedDistID = "10" if SchName == "Kent Elementary Intensive Learning Center"
		replace SchType = "Special education school" if SchName == "Kent Elementary Intensive Learning Center"
		replace DistType = "Regular local school district" if SchName == "Kent Elementary Intensive Learning Center"
		replace SchLevel = "Primary" if SchName == "Kent Elementary Intensive Learning Center"
		replace SchVirtual = "Missing/not reported" if SchName == "Kent Elementary Intensive Learning Center"
		replace seasch = "615" if SchName == "Kent Elementary Intensive Learning Center"
		replace CountyName = "KENT COUNTY" if SchName == "Kent Elementary Intensive Learning Center"
		replace CountyCode = 10001 if CountyName == "KENT COUNTY"
		replace State_leaid = StateAssignedDistID if SchName == "Kent Elementary Intensive Learning Center"
		replace DistCharter = "No" if SchName == "Kent Elementary Intensive Learning Center"
		//Wallace Wallin (which always seems to be a problem lol)
		
		replace NCESSchoolID = "100023000378" if SchName == "The Wallace Wallin School"
		replace StateAssignedSchID = "522" if SchName == "The Wallace Wallin School"
		replace DistName = "Colonial School District" if SchName == "The Wallace Wallin School"
		replace NCESDistrictID = "1000230" if SchName == "The Wallace Wallin School"
		replace StateAssignedDistID = "34" if SchName == "The Wallace Wallin School"
		replace SchType = "Special education school" if SchName == "The Wallace Wallin School"
		replace DistType = "Colonial School District" if SchName == "The Wallace Wallin School"
		replace SchLevel = "Missing/not reported" if SchName == "The Wallace Wallin School"
		replace SchVirtual = "Missing/not reported" if SchName == "The Wallace Wallin School"
		replace seasch = "522" if SchName == "The Wallace Wallin School"
		replace CountyName = "NEW CASTLE COUNTY" if SchName == "The Wallace Wallin School"
		replace CountyCode = 10003 if SchName == "The Wallace Wallin School"
		replace State_leaid = "34" if SchName == "The Wallace Wallin School"
		replace DistCharter = "No" if SchName == "The Wallace Wallin School"
		
		//Fixing Polytech School District
		replace NCESDistrictID = "1000750" if DistName == "POLYTECH School District"
		replace StateAssignedDistID = "39" if DistName == "POLYTECH School District"
		replace State_leaid = "39" if DistName == "POLYTECH School District"
		replace DistType = "Regular local school district" if DistName == "POLYTECH School District"
		replace DistCharter = "No" if DistName == "POLYTECH School District"
		replace CountyName = "KENT COUNTY" if DistName == "POLYTECH School District"
		replace CountyCode = 10001 if DistName == "POLYTECH School District"
		
		if `year' == 2017 {
			if strpos(seasch, "-") !=0 {
				replace seasch = substr(seasch, strpos(seasch, "-")+1,3)
				replace StateAssignedSchID = seasch
				replace StateAssignedDistID = substr(StateAssignedDistID, strpos(StateAssignedDistID, "-")+1,2)
			}
		}
		
		//DataLevel
		label def DataLevel 1 "State" 2 "District" 3 "School"
		encode DataLevel, gen(DataLevel_n) label(DataLevel)
		sort DataLevel_n 
		drop DataLevel
		
		//Lev counts for State level data:
		destring StudentSubGroup_TotalTested, i(<>=*~-) gen(count)
		foreach n in 1 2 3 4 {
			replace Lev`n'_count = floor(Lev`n'_percent * count) if DataLevel == 1
		}
		
		//Last steps before appending
		rename DataLevel_n DataLevel
		destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested1) i(<>=*~-)
		duplicates drop
		egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested1), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
		tostring Lev*, replace force
		tostring ProficientOrAbove_percent, replace force
		tostring ParticipationRate, replace force
		replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
		tostring StudentGroup_TotalTested, replace
		replace StudentGroup_TotalTested = "--" if DataLevel !=1
		replace ProficientOrAbove_percent = "*" if AvgScaleScore == "*"
		replace ParticipationRate = "*" if AvgScaleScore == "*"
		foreach n in 1 2 3 4 5 {
			replace Lev`n'_percent = "--" if Lev`n'_percent == "."
			replace Lev`n'_count = "--" if Lev`n'_count == "."
			replace Lev`n'_percent = "" if `n'==5
			replace Lev`n'_count = "" if `n'==5
		}
		gen State = "Delaware"
		gen StateAbbrev = "DE"
		gen StateFips = 10
		gen SchYear = "`prevyear'"+ "-" + substr("`year'",-2,2)
		gen AssmtName = "DCAS Assessment"
		gen AssmtType = "Regular"
		gen ProficiencyCriteria = "Level 3 or 4"
		gen ProficientOrAbove_count = "--"
		gen Flag_AssmtNameChange = "N"
		gen Flag_CutScoreChange_ELA = "N"
		gen Flag_CutScoreChange_math = "N"
		gen Flag_CutScoreChange_oth = "N"
		replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested== "~"
		if `year' == 2017 {
	replace StateAssignedDistID = "9606" if NCESSchoolID == "100005400362"
	replace StateAssignedSchID = "4050" if NCESSchoolID == "100005400362"
	replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if NCESSchoolID == "100005400362"
	replace StateAssignedDistID = "9612" if NCESSchoolID == "100005900372"
	replace StateAssignedSchID = "4080" if NCESSchoolID == "100005900372"
	replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if NCESSchoolID == "100005900372"
}
		tempfile final_`year'
		save "`final_`year''"
		clear

		use "`cleaned'/DE_AssmtData_`year'.dta"
		drop if Subject == "sci" | Subject == "soc"
		
		

	
		//Finally Appending
		append using "`final_`year''"
		
//Misc stuff partially in reponse to R1
replace StateAssignedSchID = "" if DataLevel !=3


		
		//Cleaning and Sorting:
		order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
duplicates report State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentSubGroup, force
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
		save "`cleaned'/DE_AssmtData_`year'.dta", replace
		export delimited using "`cleaned'/DE_AssmtData_`year'.csv", replace
		
		
		clear
		
		

		
	}
	log close
	