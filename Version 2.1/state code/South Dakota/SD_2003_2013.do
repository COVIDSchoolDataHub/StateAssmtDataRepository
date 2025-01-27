clear
set more off
cd "/Volumes/T7/State Test Project/South Dakota"
cap log close
set trace off

global Original "/Volumes/T7/State Test Project/South Dakota/Original Data"
global Output "/Volumes/T7/State Test Project/South Dakota/Output"
global NCES_District "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_School "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global Stata_versions "/Volumes/T7/State Test Project/South Dakota/Stata .dta versions"

local years 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 
local subjects ela math sci
local DataLevels State District School



**Prepping Files**
//For this code to work, the first time it runs must be to convert all excel files to .dta format. Simply unhide the import and save commands and hide the use command.
foreach year of local years {
di "~~~~~~~~~~~~"
display( "`year'" )
di "~~~~~~~~~~~~"	

	local prevyear =`=`year'-1'
	tempfile temp_`year'
	clear
	save "`temp_`year''", emptyok
	foreach subject of local subjects {
			if "`subject'" == "sci" & (`year' == 2003 | `year' == 2004 | `year' == 2005 | `year' == 2006) {
			continue
			}
			if "`subject'" == "math" & `year' == 2005 {
			continue
			}
		foreach DataLevel of local DataLevels {
			*import excel "$Original/`subject'_`prevyear'-`year'.xlsx", case(preserve) sheet("`DataLevel'")
			*save "$Stata_versions/`year'_`subject'_`DataLevel'", replace
			use "$Stata_versions/`year'_`subject'_`DataLevel'"
				
				
		


** Cleaning **
//Varnames in prep for reshape
drop in 1/6
if "`DataLevel'" == "State" {
	drop A
	rename B GradeLevel
	rename C Total_Tested
	rename D Lev4_percentAll_Students
	rename E Lev3_percentAll_Students
	rename F Lev2_percentAll_Students
	rename G Lev1_percentAll_Students
	rename H Lev4_percentWhite
	rename I Lev3_percentWhite
	rename J Lev2_percentWhite
	rename K Lev1_percentWhite
	rename L Lev4_percentBlack
	rename M Lev3_percentBlack
	rename N Lev2_percentBlack
	rename O Lev1_percentBlack
	rename P Lev4_percentAsian
	rename Q Lev3_percentAsian
	rename R Lev2_percentAsian
	rename S Lev1_percentAsian
	rename T Lev4_percentNative_American
	rename U Lev3_percentNative_American
	rename V Lev2_percentNative_American
	rename W Lev1_percentNative_American
	rename X Lev4_percentHispanic
	rename Y Lev3_percentHispanic
	rename Z Lev2_percentHispanic
	rename AA Lev1_percentHispanic
	rename AB Lev4_percentPacific_Islander
	rename AC Lev3_percentPacific_Islander
	rename AD Lev2_percentPacific_Islander
	rename AE Lev1_percentPacific_Islander
	rename AF Lev4_percentTwo_Or_More
	rename AG Lev3_percentTwo_Or_More
	rename AH Lev2_percentTwo_Or_More
	rename AI Lev1_percentTwo_Or_More
	rename AJ Lev4_percentDisadv
	rename AK Lev3_percentDisadv
	rename AL Lev2_percentDisadv
	rename AM Lev1_percentDisadv
	rename AN Lev4_percentEnglish_Learner
	rename AO Lev3_percentEnglish_Learner
	rename AP Lev2_percentEnglish_Learner
	rename AQ Lev1_percentEnglish_Learner
	rename AR Lev4_percentMale
	rename AS Lev3_percentMale
	rename AT Lev2_percentMale
	rename AU Lev1_percentMale
	rename AV Lev4_percentFemale
	rename AW Lev3_percentFemale
	rename AX Lev2_percentFemale
	rename AY Lev1_percentFemale
	rename AZ Lev4_percentSWD
	rename BA Lev3_percentSWD
	rename BB Lev2_percentSWD
	rename BC Lev1_percentSWD
	rename BD Lev4_percentMigrant
	rename BE Lev3_percentMigrant
	rename BF Lev2_percentMigrant
	rename BG Lev1_percentMigrant

	drop BH BI BJ BK BL BM BN BO // AZ BA BB BC BD BE BF BG // dropping gap and non gap
	drop in 1/2
	}
	if "`DataLevel'" == "District" & (`year' == 2003 | `year' == 2004 | `year' ==2005 | `year' == 2006 | `year' == 2007 | `year' == 2008 | `year' == 2009 | `year' == 2010)  {
	rename A StateAssignedDistID
	rename B DistName
	rename C GradeLevel
	rename D Total_Tested
	rename E Lev4_percentAll_Students
	rename F Lev3_percentAll_Students
	rename G Lev2_percentAll_Students
	rename H Lev1_percentAll_Students
	rename I Lev4_percentWhite
	rename J Lev3_percentWhite
	rename K Lev2_percentWhite
	rename L Lev1_percentWhite
	rename M Lev4_percentBlack
	rename N Lev3_percentBlack
	rename O Lev2_percentBlack
	rename P Lev1_percentBlack
	rename Q Lev4_percentAsian
	rename R Lev3_percentAsian
	rename S Lev2_percentAsian
	rename T Lev1_percentAsian
	rename U Lev4_percentNative_American
	rename V Lev3_percentNative_American
	rename W Lev2_percentNative_American
	rename X Lev1_percentNative_American
	rename Y Lev4_percentHispanic
	rename Z Lev3_percentHispanic
	rename AA Lev2_percentHispanic
	rename AB Lev1_percentHispanic
	rename AC Lev4_percentDisadv
	rename AD Lev3_percentDisadv
	rename AE Lev2_percentDisadv
	rename AF Lev1_percentDisadv
	rename AG Lev4_percentEnglish_Learner
	rename AH Lev3_percentEnglish_Learner
	rename AI Lev2_percentEnglish_Learner
	rename AJ Lev1_percentEnglish_Learner
	rename AK Lev4_percentMale
	rename AL Lev3_percentMale
	rename AM Lev2_percentMale
	rename AN Lev1_percentMale
	rename AO Lev4_percentFemale
	rename AP Lev3_percentFemale
	rename AQ Lev2_percentFemale
	rename AR Lev1_percentFemale
	rename AS Lev4_percentSWD
	rename AT Lev3_percentSWD
	rename AU Lev2_percentSWD
	rename AV Lev1_percentSWD
	drop in 1/2
	}

	if "`DataLevel'" == "District" & (`year' == 2011 | `year' == 2012 | `year' == 2013) {
	rename A StateAssignedDistID
	rename B DistName 
	rename C GradeLevel
	rename D Total_Tested
	rename E Lev4_percentAll_Students
	rename F Lev3_percentAll_Students
	rename G Lev2_percentAll_Students
	rename H Lev1_percentAll_Students
	rename I Lev4_percentWhite
	rename J Lev3_percentWhite
	rename K Lev2_percentWhite
	rename L Lev1_percentWhite
	rename M Lev4_percentBlack
	rename N Lev3_percentBlack
	rename O Lev2_percentBlack
	rename P Lev1_percentBlack
	rename Q Lev4_percentAsian
	rename R Lev3_percentAsian
	rename S Lev2_percentAsian
	rename T Lev1_percentAsian
	rename U Lev4_percentNative_American
	rename V Lev3_percentNative_American
	rename W Lev2_percentNative_American
	rename X Lev1_percentNative_American
	rename Y Lev4_percentHispanic
	rename Z Lev3_percentHispanic
	rename AA Lev2_percentHispanic
	rename AB Lev1_percentHispanic
	rename AC Lev4_percentPacific_Islander
	rename AD Lev3_percentPacific_Islander
	rename AE Lev2_percentPacific_Islander
	rename AF Lev1_percentPacific_Islander
	rename AG Lev4_percentTwo_Or_More
	rename AH Lev3_percentTwo_Or_More
	rename AI Lev2_percentTwo_Or_More
	rename AJ Lev1_percentTwo_Or_More
	rename AK Lev4_percentDisadv
	rename AL Lev3_percentDisadv
	rename AM Lev2_percentDisadv
	rename AN Lev1_percentDisadv
	rename AO Lev4_percentEnglish_Learner
	rename AP Lev3_percentEnglish_Learner
	rename AQ Lev2_percentEnglish_Learner
	rename AR Lev1_percentEnglish_Learner
	rename AS Lev4_percentMale
	rename AT Lev3_percentMale
	rename AU Lev2_percentMale
	rename AV Lev1_percentMale
	rename AW Lev4_percentFemale
	rename AX Lev3_percentFemale
	rename AY Lev2_percentFemale
	rename AZ Lev1_percentFemale
	rename BA Lev4_percentSWD
	rename BB Lev3_percentSWD
	rename BC Lev2_percentSWD
	rename BD Lev1_percentSWD
	
		if "`DataLevel'" == "School" & (`year' == 2012 | `year' == 2013) {
	
 rename BE Lev4_percentMigrant
	rename BF Lev3_percentMigrant
	rename BG Lev2_percentMigrant
	rename BH Lev1_percentMigrant
	}
	
	
	drop in 1/2

	}

	if "`DataLevel'" == "School" & (`year' == 2003 | `year' == 2004 | `year' ==2005 | `year' == 2006 | `year' == 2007 | `year' == 2008 | `year' == 2009 | `year' == 2010) {
	rename A StateAssignedDistID
	rename B DistName
	rename C SchName
	rename D StateAssignedSchID
	rename E GradeLevel
	rename F Total_Tested
	rename G Lev4_percentAll_Students
	rename H Lev3_percentAll_Students
	rename I Lev2_percentAll_Students
	rename J Lev1_percentAll_Students
	rename K Lev4_percentWhite
	rename L Lev3_percentWhite
	rename M Lev2_percentWhite
	rename N Lev1_percentWhite
	rename O Lev4_percentBlack
	rename P Lev3_percentBlack
	rename Q Lev2_percentBlack
	rename R Lev1_percentBlack
	rename S Lev4_percentAsian
	rename T Lev3_percentAsian
	rename U Lev2_percentAsian
	rename V Lev1_percentAsian
	rename W Lev4_percentNative_American
	rename X Lev3_percentNative_American
	rename Y Lev2_percentNative_American
	rename Z Lev1_percentNative_American
	rename AA Lev4_percentHispanic
	rename AB Lev3_percentHispanic
	rename AC Lev2_percentHispanic
	rename AD Lev1_percentHispanic
	rename AE Lev4_percentDisadv
	rename AF Lev3_percentDisadv
	rename AG Lev2_percentDisadv
	rename AH Lev1_percentDisadv
	rename AI Lev4_percentEnglish_Learner
	rename AJ Lev3_percentEnglish_Learner
	rename AK Lev2_percentEnglish_Learner
	rename AL Lev1_percentEnglish_Learner
	rename AM Lev4_percentMale
	rename AN Lev3_percentMale
	rename AO Lev2_percentMale
	rename AP Lev1_percentMale
	rename AQ Lev4_percentFemale
	rename AR Lev3_percentFemale
	rename AS Lev2_percentFemale
	rename AT Lev1_percentFemale
	rename AU Lev4_percentSWD
	rename AV Lev3_percentSWD
	rename AW Lev2_percentSWD
	rename AX Lev1_percentSWD
	
	
	drop in 1/2
	}

	if "`DataLevel'" == "School" & (`year' == 2011 | `year' == 2012 | `year' == 2013) {
	rename A StateAssignedDistID
	rename B DistName
	rename C SchName
	rename D StateAssignedSchID
	rename E GradeLevel
	rename F Total_Tested
	rename G Lev4_percentAll_Students
	rename H Lev3_percentAll_Students
	rename I Lev2_percentAll_Students
	rename J Lev1_percentAll_Students
	rename K Lev4_percentWhite
	rename L Lev3_percentWhite
	rename M Lev2_percentWhite
	rename N Lev1_percentWhite
	rename O Lev4_percentBlack
	rename P Lev3_percentBlack
	rename Q Lev2_percentBlack
	rename R Lev1_percentBlack
	rename S Lev4_percentAsian
	rename T Lev3_percentAsian
	rename U Lev2_percentAsian
	rename V Lev1_percentAsian
	rename W Lev4_percentNative_American
	rename X Lev3_percentNative_American
	rename Y Lev2_percentNative_American
	rename Z Lev1_percentNative_American
	rename AA Lev4_percentHispanic
	rename AB Lev3_percentHispanic
	rename AC Lev2_percentHispanic
	rename AD Lev1_percentHispanic
	rename AE Lev4_percentPacific_Islander
	rename AF Lev3_percentPacific_Islander
	rename AG Lev2_percentPacific_Islander
	rename AH Lev1_percentPacific_Islander
	rename AI Lev4_percentTwo_Or_More
	rename AJ Lev3_percentTwo_Or_More
	rename AK Lev2_percentTwo_Or_More
	rename AL Lev1_percentTwo_Or_More
	rename AM Lev4_percentDisadv
	rename AN Lev3_percentDisadv
	rename AO Lev2_percentDisadv
	rename AP Lev1_percentDisadv
	rename AQ Lev4_percentEnglish_Learner
	rename AR Lev3_percentEnglish_Learner
	rename AS Lev2_percentEnglish_Learner
	rename AT Lev1_percentEnglish_Learner
	rename AU Lev4_percentMale
	rename AV Lev3_percentMale
	rename AW Lev2_percentMale
	rename AX Lev1_percentMale
	rename AY Lev4_percentFemale
	rename AZ Lev3_percentFemale
	rename BA Lev2_percentFemale
	rename BB Lev1_percentFemale
	rename BC Lev4_percentSWD
	rename BD Lev3_percentSWD
	rename BE Lev2_percentSWD
	rename BF Lev1_percentSWD
	
	if "`DataLevel'" == "School" & (`year' == 2012 | `year' == 2013) {
	
 rename BG Lev4_percentMigrant
	rename BH Lev3_percentMigrant
	rename BI Lev2_percentMigrant
	rename BJ Lev1_percentMigrant
	}
	

	drop in 1/2
	}	
	//Reshaping from Wide to Long
	keep if GradeLevel == "3" | GradeLevel == "4" | GradeLevel == "5" | GradeLevel == "6" | GradeLevel == "7" | GradeLevel == "8"		

	if "`DataLevel'" == "State" {
	reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent, i(GradeLevel) j(StudentSubGroup, string)
	gen StateAssignedDistID = ""
	gen StateAssignedSchID = ""			
	}

	if "`DataLevel'" == "District" {
	reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent, i(DistName GradeLevel) j(StudentSubGroup, string)
	gen StateAssignedSchID = ""
	}


	if "`DataLevel'" == "School" {
	reshape long Lev1_percent Lev2_percent Lev3_percent Lev4_percent, i(DistName SchName GradeLevel) j(StudentSubGroup, string)
	}		





	//Merging NCES Data
	gen UniqueDistID = ""
	replace UniqueDistID = StateAssignedDistID if strlen(StateAssignedDistID) == 5
	replace UniqueDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
	if "`DataLevel'" == "District" {
	tempfile temp1
	save "`temp1'"
	clear

	use "$NCES_District/NCES_`prevyear'_District.dta"
	replace state_fips = 46 if state_location == "SD"
	keep if state_fips == 46

	// drop if state_name == 59
	gen UniqueDistID = state_leaid
	replace UniqueDistID = "32001" if strpos(lea_name, upper("Highmore")) !=0 & `year'==2009
	duplicates drop UniqueDistID, force
	merge 1:m UniqueDistID using "`temp1'"
	drop if _merge==1
	//drop if _merge == 2 // changed 6/3/24 hidden 11/15/24
	if _rc !=0 {
	di as error "Problem with DistID, check `year'_`subject'_`DataLevel'"
	}


	}
	if "`DataLevel'" == "School" {
	gen StateAssignedSchID1 = ""
	replace StateAssignedSchID1 = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 1
	replace StateAssignedSchID1 = StateAssignedSchID if strlen(StateAssignedSchID) ==2
	gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
	drop UniqueDistID StateAssignedSchID1
	tempfile temp1
	save "`temp1'"
	clear
	use "$NCES_School/NCES_`prevyear'_School.dta"

	replace state_fips = 46 if state_location == "SD"
	keep if state_fips == 46
	// drop if state_name == 59

	gen UniqueDistID = state_leaid
	gen StateAssignedSchID1 = ""
	replace UniqueDistID = "32001" if strpos(lea_name, upper("Highmore")) !=0 & `year' == 2009
	replace seasch = "3" if ncesschoolid == "461032001016" & `year' == 2004
	replace seasch = "4" if ncesschoolid == "462439000207" & (`year' ==2004 | `year' == 2005)
	replace seasch = "8" if ncesschoolid == "460264000018" & `year' ==2010
	replace seasch = "8" if ncesschoolid == "461413000786" & `year' == 2010

	replace StateAssignedSchID1 = "0" + seasch if strlen(seasch) == 1
	replace StateAssignedSchID1 = seasch if strlen(seasch) ==2
	gen UniqueSchID = UniqueDistID + "-" + StateAssignedSchID1
	duplicates drop UniqueSchID, force
	drop UniqueDistID StateAssignedSchID1
	replace seasch = "05" if ncesschoolid == "461032001016" & `year' == 2004
	replace seasch = "08" if ncesschoolid == "462439000207" & (`year' == 2004 |`year' == 2005)
	replace seasch = "02" if ncesschoolid == "460264000018" & `year' ==2010
	replace seasch = "04" if ncesschoolid == "461413000786" & `year' ==2010
	if `year' == 2012 {
	drop if school_name == "CREEKSIDE ELEMENTARY"
	}


	// drop _merge
	merge 1:m UniqueSchID using "`temp1'"
	display("BBBBBBB")
	drop if _merge==1
	//drop if _merge == 2 // changed 6/3/24 hidden 11/15/24
	if _rc !=0 {
	di as error "Problem with SchID, check `year'_`subject'_`DataLevel'"
	}
	replace school_id = "MISSING" if _merge ==2
	}

	//Combining DataLevel and subject
	gen Subject = "`subject'"
	gen DataLevel = "`DataLevel'"
	tempfile `subject'_`DataLevel'
	save "``subject'_`DataLevel''"
	clear
	use "``subject'_`DataLevel''"
	append using "`temp_`year''"
	save "`temp_`year''", replace
	clear



			}
		}
	use "`temp_`year''"

	//Correcting Variables
	rename state_name State
	rename state_location StateAbbrev
	rename state_fips StateFips
	gen SchYear = "`prevyear'"+ "-" + substr("`year'",3, 2)
	label def DataLevel 1 "State" 2 "District" 3 "School"
	encode DataLevel, gen(DataLevel_n) label(DataLevel)
	sort DataLevel_n 
	drop DataLevel 
	rename DataLevel_n DataLevel

	// if `year' == 2011 {
	rename district_agency_type DistType
	// }

	// if `year' != 2011 {
	// rename agency_type DistType
	// }


	// if `year' == 2011 {
	// replace DistType = district_agency_type if DataLevel ==2
	// }


	// rename school_type SchType
	rename ncesdistrictid NCESDistrictID
	rename state_leaid State_leaid
	rename ncesschoolid NCESSchoolID
	rename county_name CountyName
	rename county_code CountyCode
	gen AssmtName = "DSTEP"
	gen AssmtType = "Regular"

	//StudentSubGroup
	replace StudentSubGroup = "All Students" if StudentSubGroup == "All_Students"
	replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black"
	replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific_Islander"
	replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Disadv"
	replace StudentSubGroup = "English Learner" if StudentSubGroup == "English_Learner"
	replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
	replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native_American"
	replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two_Or_More"




	//StudentGroup
	gen StudentGroup = ""
	replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
	replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "Two or More"
	replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
	replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
	replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
	replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" 
	replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" 


	//StudentSubGroup_TotalTested
	gen StudentSubGroup_TotalTested = "" 
	replace StudentSubGroup_TotalTested = Total_Tested if StudentSubGroup == "All Students"
	replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested)
	
	
	//Level Counts and Percents
	foreach n in 1 2 3 4 {
		gen Lev`n'_count = "--"
		destring Lev`n'_percent, replace i(".")
		replace Lev`n'_percent = round(Lev`n'_percent/100, .01)
		// format Lev`n'_percent %9.2f
	}
	//Proficiency
	gen ProficiencyCriteria = "Levels 3-4"
	gen ProficientOrAbove_count = "--"
	gen ProficientOrAbove_percent = Lev3_percent + Lev4_percent
	//Final Variables

	gen ParticipationRate = "--"

	gen Flag_AssmtNameChange = "N"
	gen Flag_CutScoreChange_ELA = "N"
	gen Flag_CutScoreChange_math = "N"
	gen Flag_CutScoreChange_sci = "Not applicable" 
	
	if `year' >= 2007 {
	replace Flag_CutScoreChange_sci = "N" 
	}
	
	gen Flag_CutScoreChange_soc = "Not applicable" 

	//Converting to Correct Types and Misc Cleaning
	foreach n in 1 2 3 4 {
	gen Lev`n'_string = string(Lev`n'_percent, "%9.2f")
	drop Lev`n'_percent
	rename Lev`n'_string Lev`n'_percent
	replace Lev`n'_percent = "--" if missing(Lev`n'_percent) | Lev`n'_percent == "."	
	}
	gen ProficientOrAbove_string = string(ProficientOrAbove_percent, "%9.2f")
	drop ProficientOrAbove_percent
	rename ProficientOrAbove_string ProficientOrAbove_percent
	replace ProficientOrAbove_percent = "--" if missing(ProficientOrAbove_percent) | ProficientOrAbove_percent == "."
	*save "/Volumes/T7/State Test Project/South Dakota/test/`year'", replace
	//Empty Variables
	gen Lev5_count = ""
	gen Lev5_percent = ""
	gen AvgScaleScore = "--"

	//GradeLevel
	replace GradeLevel = "G0" + GradeLevel
	
	//Fixing State Level Data
	drop State 
	gen State = "South Dakota"
	replace StateAbbrev = "SD"
	replace StateFips = 46

	//DistName and SchName
	replace DistName = "All Districts" if DataLevel==1
	replace SchName = "All Schools" if DataLevel ==1
	replace SchName = "All Schools" if DataLevel ==2

		
	// generating counts 5/31/24
	destring StudentSubGroup_TotalTested, replace ignore("--")

	local a  "1 2 3 4 5" 
	foreach b in `a' {


	destring Lev`b'_percent, replace ignore("--")
	destring Lev`b'_count, replace ignore("--")



	replace Lev`b'_count = Lev`b'_percent * StudentSubGroup_TotalTested if Lev`b'_count == . & Lev`b'_percent != . & StudentSubGroup_TotalTested != .
	replace Lev`b'_count = round(Lev`b'_count, 1)


	tostring Lev`b'_percent, replace force 
	tostring Lev`b'_count, replace force

	replace Lev`b'_percent = "--" if  Lev`b'_percent == "." 
	replace Lev`b'_count = "--" if  Lev`b'_count == "." 


	}



	replace Lev5_percent = "" if  Lev5_percent == "--" 
	replace Lev5_count = "" if  Lev5_count == "--" 

	destring ProficientOrAbove_percent, replace ignore("--")
	destring ProficientOrAbove_count, replace ignore("--")

	replace ProficientOrAbove_count = ProficientOrAbove_percent * StudentSubGroup_TotalTested if ProficientOrAbove_count == . &  ProficientOrAbove_percent != . & StudentSubGroup_TotalTested != .
	replace ProficientOrAbove_count = round(ProficientOrAbove_count, 1)

	tostring ProficientOrAbove_percent, replace force
	tostring ProficientOrAbove_count, replace force

	replace ProficientOrAbove_percent = "--" if  ProficientOrAbove_percent == "." 
	replace ProficientOrAbove_count = "--" if  ProficientOrAbove_count == "." 

	tostring StudentSubGroup_TotalTested, replace force
	replace StudentSubGroup_TotalTested = "--" if  StudentSubGroup_TotalTested == "." 


	replace CountyName = proper(CountyName) // added 6/3/24


	replace Subject = "ela" if Subject == "read" 
	
	drop if NCESDistrictID == "MISSING"
	drop if NCESSchoolID == "MISSING"
	
	
    replace StateAssignedDistID = "0" + StateAssignedDistID if strlen(StateAssignedDistID) == 4
    replace StateAssignedSchID = "0" + StateAssignedSchID if strlen(StateAssignedSchID) == 1
	
	replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel ==3
	

	//Final cleaning and dropping extra variables
	
	replace DistName=strtrim(DistName) // adjusted district spacing
	replace SchName =strtrim(SchName) // adjusted school spacing
	
	drop State_leaid seasch
	
	
	
	
if `year' == 2003 | `year' == 2004 | `year' == 2005 | `year' == 2006 | `year' == 2007 | `year' == 2008  {
replace CountyName = strtrim(CountyName) + " County" if DataLevel == 2 | DataLevel == 3
}
	
replace CountyName = "McCook County" if CountyName == "Mccook County"
replace CountyName = "McPherson County" if CountyName == "Mcpherson County"

//Misc Updates
if `year' == 2010 drop if SchName == "Wood Elementary" & NCESSchoolID == "461413000140"

//Unmerged Schools/Districts with no data or are private
if `year' > 2008 & `year' < 2014 drop if (missing(NCESDistrictID) & DataLevel !=1) | (missing(NCESSchoolID) & DataLevel == 3) // Unmerged are private schools
if `year' == 2003 drop if SchName == "E.A.G.L.E. Center" & missing(NCESSchoolID)
if `year' == 2005 drop if DistName == "DSS Auxiliary Placements" & missing(NCESDistrictID)
if `year' == 2008 drop if DistName == "St Lawrence School" & missing(NCESDistrictID)


//StudentGroup_TotalTested
cap drop StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving StudentSubGroup_TotalTested where possible
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*

//Level percent (and corresponding count) derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

foreach percent of varlist Lev*_percent {
	replace `percent' = "0" if real(`percent') < 0.005 & !missing(real(`percent'))
}

replace ProficientOrAbove_percent = string(real(Lev3_percent) + real(Lev4_percent)) if !missing(real(Lev3_percent)) & !missing(real(Lev4_percent)) & missing(real(ProficientOrAbove_percent))

foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	replace `count' = string(round(real(`percent') * real(StudentSubGroup_TotalTested))) if !missing(real(`percent')) & !missing(real(StudentSubGroup_TotalTested))
}

//Misc Fixes
replace ProficientOrAbove_percent = "1" if real(ProficientOrAbove_percent) > 1 & !missing(real(ProficientOrAbove_percent))
replace ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup



//Saving
save "$Output/SD_AssmtData_`year'.dta" , replace
export delimited "$Output/SD_AssmtData_`year'", replace	
clear
erase "`temp_`year''"

}

	
	
