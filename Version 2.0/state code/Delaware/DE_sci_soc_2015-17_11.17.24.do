clear
set more off
cap log close
set trace off

global Original "/Users/miramehta/Documents/DE State Testing Data/Original Data Files"
global Output "/Users/miramehta/Documents/DE State Testing Data/Output"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics/Cleaned NCES Data"
global NCESSchool "/Users/miramehta/Documents/NCES District and School Demographics/NCES School Files, Fall 1997-Fall 2022"

//Do NOT Run this file until you have run the 2015, 2016, and 2017 files.

foreach year in 2015 2016 2017 {
	di as error "`year'"
//State
	if `year' != 2017{
		import excel "$Original/DE_OriginalData_`year'_State_DCAS_sci_soc.xlsx", sheet("Sheet1") firstrow clear
	}
	if `year' == 2017 {
		import excel "$Original/DE_OriginalData_`year'_State_DCAS_sci.xlsx", sheet("Sheet1") firstrow clear
		rename PercentProficient PercentProficiency
	}
	//Converting to Percents
	
		foreach n in 1 2 3 4 {
			gen rangeind`n'= "" //RESPONSE TO R2
			cap replace rangeind`n' = substr(PL`n',strpos(PL`n',"<"),1)
			destring PL`n', replace i(<)
			replace PL`n' = round(PL`n'/100,0.001)
		}
		gen range_part = ""
		replace range_part = substr(ParticipationRate,strpos(ParticipationRate,">"),1)
		destring ParticipationRate, replace i(>)
		replace ParticipationRate = round(ParticipationRate/100, 0.001)
		replace PercentProficiency = round(PercentProficiency/100, 0.001)
		
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
	if `year' != 2017 {
	import excel "$Original/DE_OriginalData_`year'_District_DCAS_sci_soc.xlsx", sheet("Sheet1") firstrow clear
	drop G PercentProficient I
	}
	else if `year' == 2017 {
		import excel "$Original/DE_OriginalData_`year'_District_DCAS_sci.xlsx", sheet("Sheet1") firstrow clear
		drop G H I
		rename PercentProficient PercentProficiency
	}
	gen range_part = ""
	replace range_part = substr(ParticipationRate,strpos(ParticipationRate,">"),1)
	//Fixing District for 2016 & 2017
	if `year' !=2015 {
	gen District1 = subinstr(District," Performance and Participation","", .)
	drop District
	rename District1 District
	}
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = round(PercentProficiency/100,0.001)
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = round(ParticipationRate/100,0.001)
	
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
	if `year' != 2017 {
	import excel "$Original/DE_OriginalData_`year'_School_DCAS_sci_soc.xlsx", sheet("Sheet1") firstrow clear
	drop G PercentProficient I
	}
	else if `year' == 2017 {
		import excel "$Original/DE_OriginalData_`year'_School_DCAS_sci.xlsx", sheet("Sheet1") firstrow clear
		drop F G H
		rename PercentProficient PercentProficiency
	}
	gen range_part = ""
	replace range_part = substr(ParticipationRate,strpos(ParticipationRate,">"),1)
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = round(PercentProficiency/100,0.001)
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = round(ParticipationRate/100,0.001)
	
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
		if `year' == 2016 {
		import excel "$Original/DE_OriginalData_`year'_Charter_DCAS_sci_soc.xlsx", sheet("Sheet1") firstrow clear
		}
		if `year' == 2017{
		import excel "$Original/DE_OriginalData_`year'_Charter_DCAS_sci.xlsx", sheet("Sheet1") firstrow clear
		}
	rename School SchoolName
	if `year' != 2017 {
	drop G H I
	rename PercentProficient PercentProficiency
	}
	else if `year' == 2017 {
		drop F G H
		rename PercentProficient PercentProficiency
	}
	gen range_part = ""
	replace range_part = substr(ParticipationRate,strpos(ParticipationRate,">"),1)
	//Converting to Percents
	destring PercentProficiency, replace i(<>=%*)
	replace PercentProficiency = round(PercentProficiency/100, 0.001)
	destring ParticipationRate, replace i(<>%*)
	replace ParticipationRate = round(ParticipationRate/100, 0.001)
	
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
	save "${Output}/Combined_`year'", replace
	}
	else {
	append using "`State_`year''" "`District_`year''"  "`School_`year''" "`Charter_`year''"
	save "${Output}/Combined_`year'", replace
	}
	
	clear
	
	
	}
	
	
	
	

//Additional Cleaning- SET ADDITIONAL FILE DIRECTORIES

	foreach year in 2015 2016 2017{
		use "${Output}/Combined_`year'", clear
		
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
		replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disability"
		drop if StudentSubGroup == "Student Gap Group" 
		
		//StudentGroup
		gen StudentGroup = ""
		replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Two or More" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
		replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
		replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
		replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
		replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
		*count if StudentGroup == "" & School != "All Schools"
		
		//Misc
		replace SchName = "Delaware Day Treatment Center (6-14) Dover" if SchName == "Delaware Day Treatment Center (6- 14) Dover"

		tempfile CombinedSCISOC_`year'
		save "`CombinedSCISOC_`year''"
		
		clear
		
		//Using already cleaned ELA and Math data to get data for each scool and district
		use "${Output}/DE_AssmtData_`year'.dta"
		drop if DataLevel !=3
		keep NCESDistrictID DistType  StateAssignedDistID NCESSchoolID StateAssignedSchID SchLevel SchVirtual CountyName CountyCode SchName DistName SchType DistLocale DistCharter
		duplicates drop
		duplicates drop SchName, force
		merge 1:m SchName using "`CombinedSCISOC_`year''"
		drop if _merge ==1 & DataLevel == "" //Checked manually, dropped schools are not found in Sci / Soc data
		rename _merge _merge1
		drop if DataLevel != "School"
		tempfile School
		save "`School'"
		clear
		use "${Output}/DE_AssmtData_`year'.dta"
		drop if DataLevel !=2
		keep NCESDistrictID StateAssignedDistID DistType CountyName CountyCode DistName DistLocale DistCharter
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
		use "${NCESSchool}/NCES_`prevyear'_School.dta", clear
		drop if state_fips != 10
		rename ncesschoolid NCESSchoolID
		rename ncesdistrictid NCESDistrictID
		rename school_name SchName
		gen StateAssignedSchID = seasch
		rename lea_name DistName
		gen StateAssignedDistID = state_leaid
		rename state_leaid State_leaid
		rename county_code CountyCode
		rename county_name CountyName
		rename district_agency_type DistType
		replace CountyName = strproper(CountyName)
		keep NCESSchoolID SchName NCESDistrictID StateAssignedSchID DistName StateAssignedDistID SchType CountyCode CountyName DistType DistCharter DistLocale SchType seasch SchLevel SchVirtual State_leaid

		keep if SchName == "Carver (G.W.) Educational Center" | SchName == "Central School (The)" | SchName == "Douglass School" | SchName == "First State School" | SchName == "Kent County Secondary ILC" | SchName == "Penn (William) High School" | SchName == "Delaware School for the Deaf"| SchName == "Delaware School for the Deaf School (DSD)" | SchName == "Sussex Consortium" | SchName == "Richardson Park Learning Center" | SchName == "Family Foundations Academy" | SchName == "Sussex Academy of Arts and Sciences"
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
		replace SchType = 2 if SchName == "Kent Elementary Intensive Learning Center"
		replace DistLocale = "Suburb, midsize" if SchName == "Kent Elementary Intensive Learning Center"
		replace DistType = "Regular local school district" if SchName == "Kent Elementary Intensive Learning Center"
		replace SchLevel = 1 if SchName == "Kent Elementary Intensive Learning Center"
		replace SchVirtual = -1 if SchName == "Kent Elementary Intensive Learning Center"
		replace CountyName = "Kent County" if SchName == "Kent Elementary Intensive Learning Center"
		replace CountyCode = "10001" if CountyName == "Kent County"
		replace DistCharter = "No" if SchName == "Kent Elementary Intensive Learning Center"
		//Wallace Wallin (which always seems to be a problem lol)
		
		replace NCESSchoolID = "100023000378" if SchName == "The Wallace Wallin School"
		replace StateAssignedSchID = "522" if SchName == "The Wallace Wallin School"
		replace DistName = "Colonial School District" if SchName == "The Wallace Wallin School"
		replace NCESDistrictID = "1000230" if SchName == "The Wallace Wallin School"
		replace StateAssignedDistID = "34" if SchName == "The Wallace Wallin School"
		replace SchType = 2 if SchName == "The Wallace Wallin School"
		replace DistLocale = "Suburb, large" if SchName == "The Wallace Wallin School"
		replace DistType = "Regular local school district" if SchName == "The Wallace Wallin School"
		replace SchLevel = -1 if SchName == "The Wallace Wallin School"
		replace SchVirtual = -1 if SchName == "The Wallace Wallin School"
		replace CountyName = "New Castle County" if SchName == "The Wallace Wallin School"
		replace CountyCode = "10003" if SchName == "The Wallace Wallin School"
		replace DistCharter = "No" if SchName == "The Wallace Wallin School"
		
		//Fixing Polytech School District
		replace NCESDistrictID = "1000750" if DistName == "POLYTECH School District"
		replace StateAssignedDistID = "39" if DistName == "POLYTECH School District"
		replace DistType = "Regular local school district" if DistName == "POLYTECH School District"
		replace DistCharter = "No" if DistName == "POLYTECH School District"
		replace DistLocale = "Rural, fringe" if DistName == "POLYTECH School District"
		replace CountyName = "Kent County" if DistName == "POLYTECH School District"
		replace CountyCode = "10001" if DistName == "POLYTECH School District"
		
		if `year' == 2017 {
			if strpos(seasch, "-") !=0 {
				replace StateAssignedSchID = substr(StateAssignedSchID, strpos(StateAssignedSchID, "-")+1,3)
				replace StateAssignedDistID = subinstr(StateAssignedDistID, "DE-", "", 1)
			}
		}
		
		//DataLevel
		label def DataLevel 1 "State" 2 "District" 3 "School"
		encode DataLevel, gen(DataLevel_n) label(DataLevel)
		sort DataLevel_n 
		drop DataLevel
		
		//StudentGroup_TotalTested & StudentSubGroup_TotalTested
		rename DataLevel_n DataLevel
		replace StudentSubGroup_TotalTested = "0-15" if StudentSubGroup_TotalTested == "<= 15"
		sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
		gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
		order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
		replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
		gen flag = 1 if missing(real(StudentSubGroup_TotalTested))
		bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup: egen group_missing = total(flag)
		bysort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel: egen RaceEth = total(real(StudentSubGroup_TotalTested)) if StudentGroup == "RaceEth"
		replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested) - RaceEth) if missing(real(StudentSubGroup_TotalTested)) & group_missing == 1 & StudentGroup == "RaceEth"	
		drop flag group_missing RaceEth
		drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
		
		//Lev counts for State level data:
		destring StudentSubGroup_TotalTested, i(<>=*~-) gen(count)
		foreach n in 1 2 3 4 {
			replace Lev`n'_count = floor(Lev`n'_percent * count) if DataLevel == 1
		}
		
		//Last steps before appending
		foreach n in 1 2 3 4 5{
			gen Lev`n'_string = string(Lev`n'_percent, "%9.2f")
			drop Lev`n'_percent
			rename Lev`n'_string Lev`n'_percent
			tostring Lev`n'_count, replace
		}
		gen ProficientOrAbove_count = floor(ProficientOrAbove_percent * count) if DataLevel == 1
		tostring(ProficientOrAbove_count), replace
		replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "."
		gen ProficientOrAbove_string = string(ProficientOrAbove_percent, "%9.2f")
		drop ProficientOrAbove_percent
		rename ProficientOrAbove_string ProficientOrAbove_percent
		gen ParticipationRate_string = string(ParticipationRate, "%9.2f")
		drop ParticipationRate
		rename ParticipationRate_string ParticipationRate
		replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
		*tostring StudentGroup_TotalTested, replace
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
		gen ProficiencyCriteria = "Levels 3-4"
		*gen ProficientOrAbove_count = "--"
		gen Flag_AssmtNameChange = "N"
		gen Flag_CutScoreChange_ELA = "N"
		replace Flag_CutScoreChange_ELA = "Y" if `year' == 2015
		gen Flag_CutScoreChange_math = "N"
		replace Flag_CutScoreChange_math = "Y" if `year' == 2015
		gen Flag_CutScoreChange_sci = "N"
		gen Flag_CutScoreChange_soc = "N"
		if `year' == 2017 replace Flag_CutScoreChange_soc = "Not applicable"
		replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested== "~"
		if `year' == 2017 {
	replace StateAssignedDistID = "9606" if NCESSchoolID == "100005400362"
	replace StateAssignedSchID = "4050" if NCESSchoolID == "100005400362"
	*replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if NCESSchoolID == "100005400362"
	replace StateAssignedDistID = "9612" if NCESSchoolID == "100005900372"
	replace StateAssignedSchID = "4080" if NCESSchoolID == "100005900372"
	*replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if NCESSchoolID == "100005900372"
}
		tempfile final_`year'
		save "`final_`year''"
		clear

		use "${Output}/DE_AssmtData_`year'.dta"
		drop if Subject == "sci" | Subject == "soc"
		
		

	
		//Finally Appending
		append using "`final_`year''"
		
//Misc stuff partially in reponse to R1
replace StateAssignedSchID = "" if DataLevel !=3

//Range inclusion in response to R2:
foreach n in 1 2 3 4 {
	replace Lev`n'_percent = rangeind`n' + Lev`n'_percent
	replace Lev`n'_percent = subinstr(Lev`n'_percent, "<", "0-", 1)
	replace Lev`n'_count = "0-" + Lev`n'_count if strpos(Lev`n'_percent, "0-") > 0
}
replace ParticipationRate = range_part + ParticipationRate
replace ParticipationRate = "0.95-1" if ParticipationRate == ">0.95"
replace ParticipationRate = "0.99-1" if ParticipationRate == ">0.99"

		
		//Cleaning and Sorting:
		duplicates drop
		
		drop if NCESSchoolID == "" & DataLevel == 3 //Checked manually & confirmed no meaningful data in these observations + no NCES info available
		
		keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
		save "$Output/DE_AssmtData_`year'.dta", replace
		export delimited using "$Output/DE_AssmtData_`year'.csv", replace
		
		
		clear

		
	}
	
