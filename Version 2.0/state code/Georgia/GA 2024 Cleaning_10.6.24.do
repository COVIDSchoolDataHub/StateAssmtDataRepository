clear all

cd "/Users/miramehta/Documents/"
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

//Import Data & Rename Variables
/*
tempfile temp1
save "`temp1'", replace emptyok
forvalues n = 3/8{
	import excel "$GAdata/GA_OriginalData_2024-EOG-School-Level-All-Grades_nosubgroups", clear sheet("School - Grade `n'") firstrow cellrange(A2)

	//Rename Variables
	rename SystemCode StateAssignedDistID
	rename SchoolCode StateAssignedSchID
	rename SystemName DistName
	rename SchoolName SchName
	rename EnglishLanguageArts StudentSubGroup_TotalTested1
	rename I AvgScaleScore1
	rename K Lev1_percent1
	rename L Lev2_percent1
	rename M Lev3_percent1
	rename N Lev4_percent1
	rename P ProficientOrAbove_percent1
	if `n' == 3{
		rename Mathematics StudentSubGroup_TotalTested2
		rename R AvgScaleScore2
		rename T Lev1_percent2
		rename U Lev2_percent2
		rename V Lev3_percent2
		rename W Lev4_percent2
		rename Y ProficientOrAbove_percent2
	}
	if `n' != 3{
		rename Mathematics StudentSubGroup_TotalTested2
		rename W AvgScaleScore2
		rename Y Lev1_percent2
		rename Z Lev2_percent2
		rename AA Lev3_percent2
		rename AB Lev4_percent2
		rename AD ProficientOrAbove_percent2
	}
	
	keep StateAssignedDistID StateAssignedSchID DistName SchName StudentSubGroup_TotalTested1 AvgScaleScore1  Lev1_percent1 Lev2_percent1 Lev3_percent1 Lev4_percent1 ProficientOrAbove_percent1 StudentSubGroup_TotalTested2 AvgScaleScore2 Lev1_percent2 Lev2_percent2 Lev3_percent2 Lev4_percent2 ProficientOrAbove_percent2
	
	drop if StateAssignedDistID == "" & StateAssignedSchID == ""
	drop if StateAssignedDistID == "^To achieve a reading status designation of Grade Level or Above, a student must demonstrate reading skill at the beginning of the grade-level stretch band. "
	
	//Reshape Data
	reshape long StudentSubGroup_TotalTested AvgScaleScore Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, i(StateAssignedDistID DistName StateAssignedSchID SchName) j(Subject)
	
	//Clarify Identifying Information
	tostring Subject, replace
	replace Subject = "ela" if Subject == "1"
	replace Subject = "math" if Subject == "2"
	gen GradeLevel = "G0`n'"
	gen DataLevel = "School"
	gen StudentGroup = "All Students"
	gen StudentSubGroup = "All Students"
	append using "`temp1'"
	if `n' != 8{
		save "`temp1'", replace
	}
	
	if `n' == 8{
		save "$GAdata/GA_OriginalData_2024.dta", replace
	}
}

tempfile temp2
save "`temp2'", replace emptyok
forvalues n = 3/8{
	import excel "$GAdata/GA_OriginalData_2024-EOG-District-Level-All-Grades_nosubgroups", clear sheet("System - Grade `n'") firstrow cellrange(A2)

	//Rename Variables
	rename SystemCode StateAssignedDistID
	rename SystemName DistName
	rename EnglishLanguageArts StudentSubGroup_TotalTested1
	rename G AvgScaleScore1
	rename I Lev1_percent1
	rename J Lev2_percent1
	rename K Lev3_percent1
	rename L Lev4_percent1
	rename N ProficientOrAbove_percent1
	if `n' == 3{
		rename Mathematics StudentSubGroup_TotalTested2
		rename P AvgScaleScore2
		rename R Lev1_percent2
		rename S Lev2_percent2
		rename T Lev3_percent2
		rename U Lev4_percent2
		rename W ProficientOrAbove_percent2
	}
	if `n' != 3{
		rename Mathematics StudentSubGroup_TotalTested2
		rename U AvgScaleScore2
		rename W Lev1_percent2
		rename X Lev2_percent2
		rename Y Lev3_percent2
		rename Z Lev4_percent2
		rename AB ProficientOrAbove_percent2
	}
	
	keep StateAssignedDistID DistName StudentSubGroup_TotalTested1 AvgScaleScore1  Lev1_percent1 Lev2_percent1 Lev3_percent1 Lev4_percent1 ProficientOrAbove_percent1 StudentSubGroup_TotalTested2 AvgScaleScore2 Lev1_percent2 Lev2_percent2 Lev3_percent2 Lev4_percent2 ProficientOrAbove_percent2
	
	drop if StateAssignedDistID == "" | StateAssignedDistID == "^To achieve a reading status designation of Grade Level or Above, a student must demonstrate reading skill at the beginning of the grade-level stretch band. "
	
	//Reshape Data
	reshape long StudentSubGroup_TotalTested AvgScaleScore Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, i(StateAssignedDistID DistName) j(Subject)
	
	//Clarify Identifying Information
	tostring Subject, replace
	replace Subject = "ela" if Subject == "1"
	replace Subject = "math" if Subject == "2"
	gen GradeLevel = "G0`n'"
	gen DataLevel = "District"
	gen StudentGroup = "All Students"
	gen StudentSubGroup = "All Students"
	append using "`temp2'"
	save "`temp2'", replace
	
	if `n' == 8{
		append using "$GAdata/GA_OriginalData_2024.dta"
		save "$GAdata/GA_OriginalData_2024.dta", replace
	}
}

tempfile temp3
save "`temp3'", replace emptyok
forvalues n = 3/8{
	import excel "$GAdata/GA_OriginalData_2024-EOG-State-Level-All-Grades_nosubgroups", clear sheet("State - Grade `n'") firstrow cellrange(A2)

	//Rename Variables
	rename Grade GradeLevel
	rename EnglishLanguageArts StudentSubGroup_TotalTested1
	rename F AvgScaleScore1
	rename H Lev1_percent1
	rename I Lev2_percent1
	rename J Lev3_percent1
	rename K Lev4_percent1
	rename M ProficientOrAbove_percent1
	if `n' == 3{
		rename Mathematics StudentSubGroup_TotalTested2
		rename O AvgScaleScore2
		rename Q Lev1_percent2
		rename R Lev2_percent2
		rename S Lev3_percent2
		rename T Lev4_percent2
		rename V ProficientOrAbove_percent2
	}
	if `n' != 3{
		rename Mathematics StudentSubGroup_TotalTested2
		rename T AvgScaleScore2
		rename V Lev1_percent2
		rename W Lev2_percent2
		rename X Lev3_percent2
		rename Y Lev4_percent2
		rename AA ProficientOrAbove_percent2
	}
	
	keep GradeLevel StudentSubGroup_TotalTested1 AvgScaleScore1  Lev1_percent1 Lev2_percent1 Lev3_percent1 Lev4_percent1 ProficientOrAbove_percent1 StudentSubGroup_TotalTested2 AvgScaleScore2 Lev1_percent2 Lev2_percent2 Lev3_percent2 Lev4_percent2 ProficientOrAbove_percent2
	
	drop if GradeLevel == "" | GradeLevel == "^To achieve a reading status designation of Grade Level or Above, a student must demonstrate reading skill at the beginning of the grade-level stretch band. "
	
	//Reshape Data
	reshape long StudentSubGroup_TotalTested AvgScaleScore Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, i(GradeLevel) j(Subject)
	
	//Clarify Identifying Information
	tostring Subject, replace
	replace Subject = "ela" if Subject == "1"
	replace Subject = "math" if Subject == "2"
	tostring GradeLevel, replace
	replace GradeLevel = "G" + GradeLevel
	gen DataLevel = "State"
	gen StudentGroup = "All Students"
	gen StudentSubGroup = "All Students"
	append using "`temp3'"
	save "`temp3'", replace
	
	if `n' == 8{
		append using "$GAdata/GA_OriginalData_2024.dta"
		save "$GAdata/GA_OriginalData_2024.dta", replace
	}
}
*/
use "$GAdata/GA_OriginalData_2024.dta", clear

//Generate Other Variables
gen SchYear = "2023-24"
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "Not applicable" //update when more data are obtained
gen Flag_CutScoreChange_sci = "Not applicable" //update when more data are obtained
gen AssmtType = "Regular"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficiencyCriteria = "Levels 3-4"
gen ParticipationRate = "--"

//Data Levels
replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"
drop if DistName == ""

//StudentGroup_TotalTested
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == ""
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
drop AllStudents_Tested

//Reformatting Level Percents
forvalues n = 1/4{
	replace Lev`n'_percent = "--" if Lev`n'_percent == ""
	destring Lev`n'_percent, gen(nLev`n'_percent) force
	replace nLev`n'_percent = nLev`n'_percent/100
	replace Lev`n'_percent = string(nLev`n'_percent, "%9.4g") if Lev`n'_percent != "--"
}

replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == ""
destring ProficientOrAbove_percent, gen(nProf_percent) force
replace nProf_percent = nProf_percent/100
replace ProficientOrAbove_percent = string(nProf_percent, "%9.4g") if ProficientOrAbove_percent != "--"

//Generating Counts
forvalues n = 1/4{
	gen Lev`n'_count = string(round(nLev`n'_percent * real(StudentSubGroup_TotalTested))) if Lev`n'_percent != "--" & StudentSubGroup_TotalTested != "--"
	replace Lev`n'_count = "--" if Lev`n'_percent == "--"
	replace Lev`n'_count = "--" if StudentSubGroup_TotalTested == "--"
}

gen ProficientOrAbove_count = string(round(nProf_percent * real(StudentSubGroup_TotalTested))) if ProficientOrAbove_percent != "--" & StudentSubGroup_TotalTested != "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_percent == "--"
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

save "$GAdata/GA_AssmtData_2024.dta", replace

//Clean NCES Data
use "$NCES/NCES School Files, Fall 1997-Fall 2022/NCES_2022_School.dta", clear
rename state_name State
rename state_location StateAbbrev
rename state_fips_id StateFips
drop if StateAbbrev != "GA"
rename lea_name DistName
rename school_type SchType
rename school_name SchName
decode district_agency_type, gen (DistType)
drop district_agency_type
rename DistType district_agency_type
rename state_leaid State_leaid
gen str StateAssignedDistID = substr(State_leaid, 4, 7)
gen str StateAssignedSchID = substr(seasch, 5, 8)
destring StateAssignedDistID, replace force
drop if StateAssignedDistID==.
destring StateAssignedSchID, replace force
drop if StateAssignedSchID==.
keep State StateAbbrev StateFips ncesdistrictid ncesschoolid StateAssignedDistID StateAssignedSchID district_agency_type DistLocale county_code county_name DistCharter SchType SchLevel SchVirtual
save "$NCES/Cleaned NCES Data/NCES_2024_School_GA.dta", replace
		
use "$NCES/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid State_leaid
gen str StateAssignedDistID = substr(State_leaid, 4, 7)
destring StateAssignedDistID, replace force
drop if StateAssignedDistID == .
drop year
save "$NCES/Cleaned NCES Data/NCES_2024_District_GA.dta", replace

//Merge Data
use "$GAdata/GA_AssmtData_2024.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2024_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2024_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
rename district_agency_type DistType

replace DistLocale = "Missing/not reported" if DistLocale == "" & DataLevel != "State"

*drop A B D I J K H O P _merge merge2 district_agency_type

replace State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

//Standardize District & School Names
replace SchName = strproper(SchName)
replace DistName = strproper(DistName)
replace SchName = "Utopian Academy for the Arts Charter School" if SchName == "Utopian Academy For The Arts Charte"
replace DistName = "Utopian Academy for the Arts Charter School" if SchName == "Utopian Academy For The Arts Charte"
replace SchName = "Ivy Preparatory Academy, Inc" if SchName == "Ivy Preparatory Academy Inc"
replace DistName = "Ivy Preparatory Academy, Inc" if DistName == "Ivy Preparatory Academy Inc"
replace SchName = "Southwest Georgia S.T.E.M. Charter Academy" if SchName == "Southwest Georgia Stem Charter Acad"
replace DistName = "Southwest Georgia S.T.E.M. Charter Academy" if DistName == "Southwest Georgia Stem Charter Acad"
replace SchName = "International Charter School of Atlanta" if SchName == "International Charter School Of Atl"
replace DistName = "International Charter School of Atlanta" if DistName == "International Charter School Of Atl"
replace SchName = "Georgia School for Innovation and the Classics" if SchName == "Georgia School For Innovation And T"
replace DistName = "Georgia School for Innovation and the Classics" if DistName == "Georgia School For Innovation And T"
replace SchName = "Genesis Innovation Academy for Boys" if SchName == "Genesis Innovation Academy For Boys"
replace DistName = "Genesis Innovation Academy for Boys" if DistName == "Genesis Innovation Academy For Boys"
replace SchName = "Genesis Innovation Academy for Girls" if SchName == "Genesis Innovation Academy For Girl"
replace DistName = "Genesis Innovation Academy for Girls" if DistName == "Genesis Innovation Academy For Girl"
replace SchName = "SAIL Charter Academy - School for Arts-Infused Learning" if SchName == "Sail Charter Academy - School For A"
replace DistName = "SAIL Charter Academy - School for Arts-Infused Learning" if DistName == "Sail Charter Academy - School For A"
replace SchName = "International Academy of Smyrna" if SchName == "International Academy Of Smyrna"
replace DistName = "International Academy of Smyrna" if DistName == "International Academy Of Smyrna"
replace SchName = "International Charter Academy of Georgia" if SchName == "International Charter Academy Of Ge"
replace DistName = "International Charter Academy of Georgia" if DistName == "International Charter Academy Of Ge"
replace SchName = "SLAM Academy of Atlanta" if SchName == "Slam Academy Of Atlanta"
replace DistName = "SLAM Academy of Atlanta" if DistName == "Slam Academy Of Atlanta"
replace SchName = "Statesboro STEAM Academy" if SchName == "Statesboro Steam Academy"
replace DistName = "Statesboro STEAM Academy" if DistName == "Statesboro Steam Academy"
replace SchName = "Yi Hwang Academy of Language Excellence" if SchName == "Yi Hwang Academy Of Language Excell"
replace DistName = "Yi Hwang Academy of Language Excellence" if DistName == "Yi Hwang Academy Of Language Excell"
replace SchName = "D.E.L.T.A. STEAM Academy" if SchName == "Delta Steam Academy"
replace DistName = "D.E.L.T.A. STEAM Academy" if DistName == "Delta Steam Academy"
replace SchName = "Georgia Fugees Academy Charter School" if SchName == "Georgia Fugees Academy Charter Scho"
replace DistName = "Georgia Fugees Academy Charter School" if DistName == "Georgia Fugees Academy Charter Scho"
replace SchName = "Atlanta SMART Academy" if SchName == "Atlanta Smart Academy"
replace DistName = "Atlanta SMART Academy" if DistName == "Atlanta Smart Academy"
replace SchName = "Destinations Career Academy of Georgia" if SchName == "Destinations Career Academy Of Geor"
replace DistName = "Destinations Career Academy of Georgia" if DistName == "Destinations Career Academy Of Geor"
replace SchName = "Utopian Academy for the Arts Trilith" if SchName == "Utopian Academy For The Arts Trilit"
replace DistName = "Utopian Academy for the Arts Trilith" if DistName == "Utopian Academy For The Arts Trilit"
replace SchName = "DeKalb Brilliance Academy" if SchName == "Dekalb Brilliance Academy"
replace SchName = "Muscogee Education Transition Center" if SchName == "Muscogee Education Transition Cente"

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey Charter School"
replace SchLevel = 1 if SchName == "Odyssey Charter School"
replace SchType = 1 if SchName == "Odyssey Charter School"
replace SchVirtual = 0 if SchName == "Odyssey Charter School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy"
replace SchLevel = 4 if SchName == "Georgia Cyber Academy"
replace SchType = 1 if SchName == "Georgia Cyber Academy"
replace SchVirtual = 1 if SchName == "Georgia Cyber Academy"
replace NCESSchoolID = "130023304164" if SchName == "Utopian Academy for the Arts Charter School"
replace SchLevel = 2 if SchName == "Utopian Academy for the Arts Charter School"
replace SchType = 1 if SchName == "Utopian Academy for the Arts Charter School"
replace SchVirtual = 0 if SchName == "Utopian Academy for the Arts Charter School"
replace NCESSchoolID = "130021803964" if SchName == "Pataula Charter Academy"
replace SchLevel = 4 if SchName == "Pataula Charter Academy"
replace SchType = 1 if SchName == "Pataula Charter Academy"
replace SchVirtual = 0 if SchName == "Pataula Charter Academy"
replace NCESSchoolID = "130023004051" if SchName == "Cherokee Charter Academy"
replace SchLevel = 1 if SchName == "Cherokee Charter Academy"
replace SchType = 1 if SchName == "Cherokee Charter Academy"
replace SchVirtual = 0 if SchName == "Cherokee Charter Academy"
replace NCESSchoolID = "130021703961" if SchName == "Fulton Leadership Academy"
replace SchLevel = 4 if SchName == "Fulton Leadership Academy"
replace SchType = 1 if SchName == "Fulton Leadership Academy"
replace SchVirtual = 0 if SchName == "Fulton Leadership Academy"
replace NCESSchoolID = "130022104021" if SchName == "Atlanta Heights Charter School"
replace SchLevel = 1 if SchName == "Atlanta Heights Charter School"
replace SchType = 1 if SchName == "Atlanta Heights Charter School"
replace SchVirtual = 0 if SchName == "Atlanta Heights Charter School"
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy"
replace SchLevel = 4 if SchName == "Georgia Connections Academy"
replace SchType = 1 if SchName == "Georgia Connections Academy"
replace SchVirtual = 1 if SchName == "Georgia Connections Academy"
replace NCESSchoolID = "130022204007" if SchName == "Coweta Charter Academy"
replace SchLevel = 1 if SchName == "Coweta Charter Academy"
replace SchType = 1 if SchName == "Coweta Charter Academy"
replace SchVirtual = 0 if SchName == "Coweta Charter Academy"
replace NCESSchoolID = "130023904226" if SchName == "Cirrus Charter Academy"
replace SchLevel = 1 if SchName == "Cirrus Charter Academy"
replace SchType = 1 if SchName == "Cirrus Charter Academy"
replace SchVirtual = 0 if SchName == "Cirrus Charter Academy"
replace NCESSchoolID = "130022604023" if SchName == "Ivy Preparatory Academy, Inc"
replace SchLevel = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace SchType = 1 if SchName == "Ivy Preparatory Academy, Inc"
replace SchVirtual = 0 if SchName == "Ivy Preparatory Academy, Inc"
replace NCESSchoolID = "130024304253" if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchLevel = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchVirtual = 0 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace SchType = 1 if SchName == "Southwest Georgia S.T.E.M. Charter Academy"
replace NCESSchoolID = "130024204249" if SchName == "Brookhaven Innovation Academy"
replace SchLevel = 1 if SchName == "Brookhaven Innovation Academy"
replace SchType = 1 if SchName == "Brookhaven Innovation Academy"
replace SchVirtual = 0 if SchName == "Brookhaven Innovation Academy"
replace NCESSchoolID = "130023404179" if SchName == "International Charter School of Atlanta"
replace SchLevel = 1 if SchName == "International Charter School of Atlanta"
replace SchType = 1 if SchName == "International Charter School of Atlanta"
replace SchVirtual = 0 if SchName == "International Charter School of Atlanta"
replace NCESSchoolID = "130024104229" if SchName == "Liberty Tech Charter Academy"
replace SchLevel = 1 if SchName == "Liberty Tech Charter Academy"
replace SchType = 1 if SchName == "Liberty Tech Charter Academy"
replace SchVirtual = 0 if SchName == "Liberty Tech Charter Academy"
replace NCESSchoolID = "130023604192" if SchName == "Scintilla Charter Academy"
replace SchLevel = 1 if SchName == "Scintilla Charter Academy"
replace SchType = 1 if SchName == "Scintilla Charter Academy"
replace SchVirtual = 0 if SchName == "Scintilla Charter Academy"
replace NCESSchoolID = "130023804205" if SchName == "Georgia School for Innovation and the Classics"
replace SchLevel = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchType = 1 if SchName == "Georgia School for Innovation and the Classics"
replace SchVirtual = 0 if SchName == "Georgia School for Innovation and the Classics"
replace NCESSchoolID = "130023704193" if SchName == "Dubois Integrity Academy"
replace SchLevel = 1 if SchName == "Dubois Integrity Academy"
replace SchType = 1 if SchName == "Dubois Integrity Academy"
replace SchVirtual = 0 if SchName == "Dubois Integrity Academy"
replace NCESSchoolID = "130024804288" if SchName == "Genesis Innovation Academy for Boys"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Boys"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Boys"
replace NCESSchoolID = "130024404272" if SchName == "Genesis Innovation Academy for Girls"
replace SchLevel = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchType = 1 if SchName == "Genesis Innovation Academy for Girls"
replace SchVirtual = 0 if SchName == "Genesis Innovation Academy for Girls"
replace NCESSchoolID = "130024704283" if SchName == "Resurgence Hall Charter School"
replace SchLevel = 1 if SchName == "Resurgence Hall Charter School"
replace SchType = 1 if SchName == "Resurgence Hall Charter School"
replace SchVirtual = 0 if SchName == "Resurgence Hall Charter School"
replace NCESSchoolID = "130024504293" if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchLevel = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchType = 1 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace SchVirtual = 0 if SchName == "SAIL Charter Academy - School for Arts-Infused Learning"
replace NCESSchoolID = "130024904273" if SchName == "International Academy of Smyrna"
replace SchLevel = 1 if SchName == "International Academy of Smyrna"
replace SchType = 1 if SchName == "International Academy of Smyrna"
replace SchVirtual = 0 if SchName == "International Academy of Smyrna"
replace NCESSchoolID = "130025004325" if SchName == "International Charter Academy of Georgia"
replace SchLevel = 1 if SchName == "International Charter Academy of Georgia"
replace SchType = 1 if SchName == "International Charter Academy of Georgia"
replace SchVirtual = 0 if SchName == "International Charter Academy of Georgia"
replace NCESSchoolID = "130025104306" if SchName == "SLAM Academy of Atlanta"
replace SchLevel = 1 if SchName == "SLAM Academy of Atlanta"
replace SchType = 1 if SchName == "SLAM Academy of Atlanta"
replace SchVirtual = 0 if SchName == "SLAM Academy of Atlanta"
replace NCESSchoolID = "130000502626" if SchName == "Statesboro STEAM Academy"
replace SchLevel = 3 if SchName == "Statesboro STEAM Academy"
replace SchType = 1 if SchName == "Statesboro STEAM Academy"
replace SchVirtual = 0 if SchName == "Statesboro STEAM Academy"
replace NCESSchoolID = "130025204345" if SchName == "Academy For Classical Education"
replace SchLevel = 4 if SchName == "Academy For Classical Education"
replace SchType = 1 if SchName == "Academy For Classical Education"
replace SchVirtual = 0 if SchName == "Academy For Classical Education"
replace NCESSchoolID = "130025304349" if SchName == "Spring Creek Charter Academy"
replace SchLevel = 1 if SchName == "Spring Creek Charter Academy"
replace SchType = 1 if SchName == "Spring Creek Charter Academy"
replace SchVirtual = 0 if SchName == "Spring Creek Charter Academy"
replace NCESSchoolID = "130025704372" if SchName == "Yi Hwang Academy of Language Excellence"
replace SchLevel = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace SchType = 1 if SchName == "Yi Hwang Academy of Language Excellence"
replace SchVirtual = 0 if SchName == "Yi Hwang Academy of Language Excellence"
replace NCESSchoolID = "130025804373" if SchName == "Furlow Charter School"
replace SchLevel = 4 if SchName == "Furlow Charter School"
replace SchType = 1 if SchName == "Furlow Charter School"
replace SchVirtual = 0 if SchName == "Furlow Charter School"
replace NCESSchoolID = "130025504332" if SchName == "Ethos Classical Charter School"
replace SchLevel = 1 if SchName == "Ethos Classical Charter School"
replace SchType = 1 if SchName == "Ethos Classical Charter School"
replace SchVirtual = 0 if SchName == "Ethos Classical Charter School"
replace NCESSchoolID = "130025604363" if SchName == "Baconton Community Charter School"
replace SchLevel = 4 if SchName == "Baconton Community Charter School"
replace SchType = 1 if SchName == "Baconton Community Charter School"
replace SchVirtual = 0 if SchName == "Baconton Community Charter School"
replace NCESSchoolID = "130026104376" if SchName == "Atlanta Unbound Academy"
replace SchLevel = 1 if SchName == "Atlanta Unbound Academy"
replace SchType = 1 if SchName == "Atlanta Unbound Academy"
replace SchVirtual = 0 if SchName == "Atlanta Unbound Academy"
replace NCESSchoolID = "130026204377" if SchName == "D.E.L.T.A. STEAM Academy"
replace SchLevel = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace SchType = 1 if SchName == "D.E.L.T.A. STEAM Academy"
replace SchVirtual = 0 if SchName == "D.E.L.T.A. STEAM Academy"
replace NCESSchoolID = "130026304378" if SchName == "Georgia Fugees Academy Charter School"
replace SchLevel = 3 if SchName == "Georgia Fugees Academy Charter School"
replace SchType = 1 if SchName == "Georgia Fugees Academy Charter School"
replace SchVirtual = 0 if SchName == "Georgia Fugees Academy Charter School"
replace NCESSchoolID = "130025904374" if SchName == "Atlanta SMART Academy"
replace SchLevel = 2 if SchName == "Atlanta SMART Academy"
replace SchType = 1 if SchName == "Atlanta SMART Academy"
replace SchVirtual = 0 if SchName == "Atlanta SMART Academy"
replace NCESSchoolID = "130026404424" if SchName == "Northwest Classical Academy"
replace SchLevel = 1 if SchName == "Northwest Classical Academy"
replace SchType = 1 if SchName == "Northwest Classical Academy"
replace SchVirtual = 0 if SchName == "Northwest Classical Academy"
replace NCESSchoolID = "130026504428" if SchName == "Amana Academy West Atlanta"
replace SchLevel = 1 if SchName == "Amana Academy West Atlanta"
replace SchType = 1 if SchName == "Amana Academy West Atlanta"
replace SchVirtual = 0 if SchName == "Amana Academy West Atlanta"
replace NCESSchoolID = "130585304460" if SchName == "Destinations Career Academy of Georgia"
replace SchLevel = 2 if SchName == "Destinations Career Academy of Georgia"
replace SchType = 1 if SchName == "Destinations Career Academy of Georgia"
replace SchVirtual = 1 if SchName == "Destinations Career Academy of Georgia"
replace NCESSchoolID = "130585204434" if SchName == "Resurgence Hall Middle Academy"
replace SchLevel = 2 if SchName == "Resurgence Hall Middle Academy"
replace SchType = 1 if SchName == "Resurgence Hall Middle Academy"
replace SchVirtual = 0 if SchName == "Resurgence Hall Middle Academy"
replace NCESSchoolID = "130029004665" if SchName == "Austin Road Elementary School" & DistName == "Barrow County"
replace SchLevel = 1 if SchName == "Austin Road Elementary School" & DistName == "Barrow County"
replace SchType = 1 if SchName == "Austin Road Elementary School" & DistName == "Barrow County"
replace SchVirtual = 0 if SchName == "Austin Road Elementary School" & DistName == "Barrow County"
replace NCESSchoolID = "130585104459" if SchName == "DeKalb Brilliance Academy"
replace SchLevel = 1 if SchName == "DeKalb Brilliance Academy"
replace SchType = 1 if SchName == "DeKalb Brilliance Academy"
replace SchVirtual = 0 if SchName == "DeKalb Brilliance Academy"
replace NCESSchoolID = "130002604669" if SchName == "Department Of Juvenile Justice Bibb"
replace SchLevel = 4 if SchName == "Department Of Juvenile Justice Bibb"
replace SchType = 2 if SchName == "Department Of Juvenile Justice Bibb"
replace SchVirtual = 0 if SchName == "Department Of Juvenile Justice Bibb"
replace NCESSchoolID = "130002604668" if SchName == "Djj Chatham Multi Service Center"
replace SchLevel = 4 if SchName == "Djj Chatham Multi Service Center"
replace SchType = 2 if SchName == "Djj Chatham Multi Service Center"
replace SchVirtual = 0 if SchName == "Djj Chatham Multi Service Center"
replace NCESSchoolID = "130002604670" if SchName == "Muscogee Education Transition Center"
replace SchLevel = 4 if SchName == "Muscogee Education Transition Center"
replace SchType = 2 if SchName == "Muscogee Education Transition Center"
replace SchVirtual = 0 if SchName == "Muscogee Education Transition Center"
replace NCESSchoolID = "130177004658" if SchName == "Dodge County Elementary School"
replace SchLevel = 1 if SchName == "Dodge County Elementary School"
replace SchType = 1 if SchName == "Dodge County Elementary School"
replace SchVirtual = 0 if SchName == "Dodge County Elementary School"
replace NCESSchoolID = "130294004657" if SchName == "Legacy Knoll Middle School"
replace SchLevel = 2 if SchName == "Legacy Knoll Middle School"
replace SchType = 1 if SchName == "Legacy Knoll Middle School"
replace SchVirtual = 0 if SchName == "Legacy Knoll Middle School"
replace NCESSchoolID = "130585704666" if SchName == "Liberation Academy"
replace SchLevel = 2 if SchName == "Liberation Academy"
replace SchType = 1 if SchName == "Liberation Academy"
replace SchVirtual = 0 if SchName == "Liberation Academy"
replace NCESSchoolID = "130585604675" if SchName == "Miles Ahead Charter School"
replace SchLevel = 1 if SchName == "Miles Ahead Charter School"
replace SchType = 1 if SchName == "Miles Ahead Charter School"
replace SchVirtual = 0 if SchName == "Miles Ahead Charter School"
replace NCESSchoolID = "130396004681" if SchName == "Dove Creek Middle School"
replace SchLevel = 2 if SchName == "Dove Creek Middle School"
replace SchType = 1 if SchName == "Dove Creek Middle School"
replace SchVirtual = 0 if SchName == "Dove Creek Middle School"
replace NCESSchoolID = "130585504674" if SchName == "Peace Academy Charter School"
replace SchLevel = 1 if SchName == "Peace Academy Charter School"
replace SchType = 1 if SchName == "Peace Academy Charter School"
replace SchVirtual = 0 if SchName == "Peace Academy Charter School"
replace NCESSchoolID = "130405004682" if SchName == "Peach County Achievement Academy"
replace SchLevel = 4 if SchName == "Peach County Achievement Academy"
replace SchType = 1 if SchName == "Peach County Achievement Academy"
replace SchVirtual = 0 if SchName == "Peach County Achievement Academy"
replace NCESSchoolID = "130586104678" if SchName == "Rise Preparatory Charter School"
replace SchLevel = 1 if SchName == "Rise Preparatory Charter School"
replace SchType = 1 if SchName == "Rise Preparatory Charter School"
replace SchVirtual = 0 if SchName == "Rise Preparatory Charter School"
replace NCESSchoolID = "130585804676" if SchName == "The Anchor School"
replace SchLevel = 4 if SchName == "The Anchor School"
replace SchType = 1 if SchName == "The Anchor School"
replace SchVirtual = 0 if SchName == "The Anchor School"
replace NCESSchoolID = "130585404662" if SchName == "Utopian Academy for the Arts Trilith"
replace SchLevel = 2 if SchName == "Utopian Academy for the Arts Trilith"
replace SchType = 1 if SchName == "Utopian Academy for the Arts Trilith"
replace SchVirtual = 0 if SchName == "Utopian Academy for the Arts Trilith"
replace NCESSchoolID = "130585904667" if SchName == "Zest Preparatory Academy School"
replace SchLevel = 1 if SchName == "Zest Preparatory Academy School"
replace SchType = 1 if SchName == "Zest Preparatory Academy School"
replace SchVirtual = 0 if SchName == "Zest Preparatory Academy School"
replace SchLevel = 1 if NCESSchoolID == "130012004656"
replace SchType = 1 if NCESSchoolID == "130012004656"
replace SchVirtual = 0 if NCESSchoolID == "130012004656"

replace NCESDistrictID = "1305857" if DistName == "Liberation Academy"
replace DistType = "Charter agency" if DistName == "Liberation Academy"
replace DistCharter = "Yes" if DistName == "Liberation Academy"
replace DistLocale = "Suburb, large" if DistName == "Liberation Academy"
replace CountyName = "Fulton County" if DistName == "Liberation Academy"
replace CountyCode = "13121" if DistName == "Liberation Academy"
replace NCESDistrictID = "1305856" if DistName == "Miles Ahead Charter School"
replace DistType = "Charter agency" if DistName == "Miles Ahead Charter School"
replace DistCharter = "Yes" if DistName == "Miles Ahead Charter School"
replace DistLocale = "Suburb, large" if DistName == "Miles Ahead Charter School"
replace CountyName = "Cobb County" if DistName == "Miles Ahead Charter School"
replace CountyCode = "13067" if DistName == "Miles Ahead Charter School"
replace NCESDistrictID = "1305855" if DistName == "Peace Academy Charter School"
replace DistType = "Charter agency" if DistName == "Peace Academy Charter School"
replace DistCharter = "Yes" if DistName == "Peace Academy Charter School"
replace DistLocale = "Suburb, large" if DistName == "Peace Academy Charter School"
replace CountyName = "Fulton County" if DistName == "Peace Academy Charter School"
replace CountyCode = "13121" if DistName == "Peace Academy Charter School"
replace NCESDistrictID = "1305861" if DistName == "Rise Preparatory Charter School"
replace DistType = "Charter agency" if DistName == "Rise Preparatory Charter School"
replace DistCharter = "Yes" if DistName == "Rise Preparatory Charter School"
replace DistLocale = "Suburb, large" if DistName == "Rise Preparatory Charter School"
replace CountyName = "Fulton County" if DistName == "Rise Preparatory Charter School"
replace CountyCode = "13121" if DistName == "Rise Preparatory Charter School"
replace NCESDistrictID = "1305858" if DistName == "The Anchor School"
replace DistType = "Charter agency" if DistName == "The Anchor School"
replace DistCharter = "Yes" if DistName == "The Anchor School"
replace DistLocale = "Suburb, large" if DistName == "The Anchor School"
replace CountyName = "DeKalb County" if DistName == "The Anchor School"
replace CountyCode = "13089" if DistName == "The Anchor School"
replace NCESDistrictID = "1305854" if DistName == "Utopian Academy for the Arts Trilith"
replace DistType = "Charter agency" if DistName == "Utopian Academy for the Arts Trilith"
replace DistCharter = "Yes" if DistName == "Utopian Academy for the Arts Trilith"
replace DistLocale = "Suburb, large" if DistName == "Utopian Academy for the Arts Trilith"
replace CountyName = "Fayette County" if DistName == "Utopian Academy for the Arts Trilith"
replace CountyCode = "13113" if DistName == "Utopian Academy for the Arts Trilith"
replace NCESDistrictID = "1305859" if DistName == "Zest Preparatory Academy School"
replace DistType = "Charter agency" if DistName == "Zest Preparatory Academy School"
replace DistCharter = "Yes" if DistName == "Zest Preparatory Academy School"
replace DistLocale = "Suburb, large" if DistName == "Zest Preparatory Academy School"
replace CountyName = "Douglas County" if DistName == "Zest Preparatory Academy School"
replace CountyCode = "13097" if DistName == "Zest Preparatory Academy School"

//Label & Organize Variables
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var DistType "District type as defined by NCES"
label var DistCharter "Charter indicator"
label var CountyName "County in which the district or school is located"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"
label var SchYear "School year in which the data were reported"
label var AssmtName "Name of state assessment"
label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only"
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only"
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested"
label var StudentGroup "Student demographic group"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested"
label var StudentSubGroup "Student demographic subgroup"
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested"
label var Lev1_count "Count of students within subgroup performing at Level 1"
label var Lev1_percent "Percent of students within subgroup performing at Level 1"
label var Lev2_count "Count of students within subgroup performing at Level 2"
label var Lev2_percent "Percent of students within subgroup performing at Level 2"
label var Lev3_count "Count of students within subgroup performing at Level 3"
label var Lev3_percent "Percent of students within subgroup performing at Level 3"
label var Lev4_count "Count of students within subgroup performing at Level 4"
label var Lev4_percent "Percent of students within subgroup performing at Level 4"
label var Lev5_count "Count of students within subgroup performing at Level 5"
label var Lev5_percent "Percent of students within subgroup performing at Level 5"
label var AvgScaleScore "Avg scale score within subgroup"
label var ProficiencyCriteria "Levels included in determining proficiency status"
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment"
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment"
label var ParticipationRate "Participation rate"

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "$GAdata/GA_AssmtData_2024.dta", replace
export delimited "$GAdata/GA_AssmtData_2024.csv", replace
