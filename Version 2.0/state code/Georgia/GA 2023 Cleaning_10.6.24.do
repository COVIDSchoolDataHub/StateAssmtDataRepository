clear all

cd "/Users/miramehta/Documents/"
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

import delimited "$GAdata/GA_OriginalData_2023_all.csv", clear

//Rename Variables
rename long_school_year SchYear
rename school_dstrct_nm DistName
rename school_distrct_cd StateAssignedDistID
rename instn_name SchName
rename instn_number StateAssignedSchID
rename test_cmpnt_typ_nm Subject
rename acdmc_lvl GradeLevel
rename subgroup_name StudentSubGroup
rename begin_cnt Lev1_count
rename begin_pct Lev1_percent
rename developing_cnt Lev2_count
rename developing_pct Lev2_percent
rename proficient_cnt Lev3_count
rename proficient_pct Lev3_percent
rename distinguished_cnt Lev4_count
rename distinguished_pct Lev4_percent

//Generate Other Variables
gen AssmtName = "Georgia Milestones"
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_soc = "N"
gen Flag_CutScoreChange_sci = "N"
gen AssmtType = "Regular"
gen AvgScaleScore = "--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ParticipationRate = "--"

//Data Levels
gen DataLevel = "School"
replace DataLevel = "District" if StateAssignedSchID == "ALL"
replace DataLevel = "State" if StateAssignedDistID == "ALL"

replace SchName = "All Schools" if DataLevel != "School"
replace DistName = "All Districts" if DataLevel == "State"

//Groups & SubGroups
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaskan Native"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Connected"

gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Asian"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Black or African American"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "RaceEth" if StudentSubGroup == "White"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Two or More"

//StudentGroup_TotalTested
gen StudentSubGroup_TotalTested = num_tested_cnt
replace StudentSubGroup_TotalTested = "*" if StudentSubGroup_TotalTested == "TFS"
replace StudentSubGroup_TotalTested = "--" if inlist(StudentSubGroup_TotalTested, "", ".")
replace DistName = stritrim(DistName)
replace SchName = stritrim(SchName)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
gen AllStudents_Tested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
replace AllStudents_Tested = AllStudents_Tested[_n-1] if missing(AllStudents_Tested)
gen StudentGroup_TotalTested = AllStudents_Tested
drop AllStudents_Tested

//Missing & Suppressed Data
replace Lev1_count = "--" if Lev1_count == ""
replace Lev1_count = "*" if Lev1_count == "TFS"
replace Lev2_count = "--" if Lev2_count == ""
replace Lev2_count = "*" if Lev2_count == "TFS"
replace Lev3_count = "--" if Lev3_count == ""
replace Lev3_count = "*" if Lev3_count == "TFS"
replace Lev4_count = "--" if Lev4_count == ""
replace Lev4_count = "*" if Lev4_count == "TFS"

//Passing Rates
gen Proficient_Count = Lev3_count
gen Distinguished_Count = Lev4_count
destring Proficient_Count, replace force
destring Distinguished_Count, replace force

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count =.
replace ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count

destring Lev1_percent, replace force
destring Lev2_percent, replace force
destring Lev3_percent, replace force
destring Lev4_percent, replace force

destring num_tested_cnt, replace force
gen ProficientOrAbove_percent = ProficientOrAbove_count/num_tested_cnt

replace Lev1_percent = Lev1_percent/100
replace Lev2_percent = Lev2_percent/100
replace Lev3_percent = Lev3_percent/100
replace Lev4_percent = Lev4_percent/100

//Deriving Additional Proficiency Information
forvalues n = 1/4{
	gen Lev`n' = Lev`n'_percent * num_tested_cnt
	replace Lev`n' = . if Lev`n' < 0
	replace Lev`n' = round(Lev`n')
	tostring Lev`n', replace
	replace Lev`n'_count = Lev`n' if inlist(Lev`n'_count, "*", "--") & Lev`n' != "."
	drop Lev`n'
}

drop num_tested_cnt

//Missing Data (Part II)
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_count == "--"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_count == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
tostring Lev1_percent, replace format("%10.0g") force
tostring Lev2_percent, replace format("%10.0g") force
tostring Lev3_percent, replace format("%10.0g") force
tostring Lev4_percent, replace format("%10.0g") force
tostring ProficientOrAbove_percent, replace format("%10.0g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "--" & ProficientOrAbove_count == "*"

//Grade Levels
tostring GradeLevel, replace
replace GradeLevel = "G0" + GradeLevel

//Subject Areas
replace Subject = "ela" if Subject == "English Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"
replace Subject = "soc" if Subject == "Social Studies"
drop if Subject == "Physical Science"
drop if Subject == "sci" & GradeLevel == "G03"
drop if Subject == "sci" & GradeLevel == "G04"
drop if Subject == "sci" & GradeLevel == "G06"
drop if Subject == "sci" & GradeLevel == "G07"
drop if Subject == "soc" & GradeLevel != "G08"

save "$GAdata/GA_AssmtData_2023.dta", replace

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
save "$NCES/Cleaned NCES Data/NCES_2023_School_GA.dta", replace
		
use "$NCES/NCES District Files, Fall 1997-Fall 2022/NCES_2022_District.dta", clear
drop if state_location != "GA"
rename lea_name DistName
rename state_leaid State_leaid
gen str StateAssignedDistID = substr(State_leaid, 4, 7)
destring StateAssignedDistID, replace force
drop if StateAssignedDistID == .
drop year
save "$NCES/Cleaned NCES Data/NCES_2023_District_GA.dta", replace

//Merge Data
use "$GAdata/GA_AssmtData_2023.dta", clear
destring StateAssignedSchID, replace force
destring StateAssignedDistID, replace force
merge m:1 StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2023_District_GA.dta"
drop if _merge == 2

merge m:1 StateAssignedSchID StateAssignedDistID using "$NCES/Cleaned NCES Data/NCES_2023_School_GA.dta", gen(merge2)
drop if merge2 == 2

//Clean Merged Data
rename ncesdistrictid NCESDistrictID
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
rename district_agency_type DistType

replace DistLocale = "Missing/not reported" if DistLocale == "" & DataLevel != "State"

replace State = "Georgia"
replace StateAbbrev = "GA"
replace StateFips = 13
tostring StateAssignedSchID, replace
tostring StateAssignedDistID, replace
replace StateAssignedSchID = "" if DataLevel != "School"
replace StateAssignedDistID = "" if DataLevel == "State"

//Unmerged Schools
replace NCESSchoolID = "130002303482" if SchName == "Odyssey Charter School"
replace SchLevel = 1 if SchName == "Odyssey Charter School"
replace SchType = 1 if SchName == "Odyssey Charter School"
replace SchVirtual = 0 if SchName == "Odyssey Charter School"
replace NCESSchoolID = "130023204148" if SchName == "Georgia Cyber Academy (Virtual)"
replace SchLevel = 4 if SchName == "Georgia Cyber Academy (Virtual)"
replace SchType = 1 if SchName == "Georgia Cyber Academy (Virtual)"
replace SchVirtual = 1 if SchName == "Georgia Cyber Academy (Virtual)"
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
replace NCESSchoolID = "130022704031" if SchName == "Georgia Connections Academy (Virtual)"
replace SchLevel = 4 if SchName == "Georgia Connections Academy (Virtual)"
replace SchType = 1 if SchName == "Georgia Connections Academy (Virtual)"
replace SchVirtual = 1 if SchName == "Georgia Connections Academy (Virtual)"
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
replace NCESSchoolID = "130585304460" if SchName == "Destinations Career Academy of Georgia (Virtual)"
replace SchLevel = 2 if SchName == "Destinations Career Academy of Georgia (Virtual)"
replace SchType = 1 if SchName == "Destinations Career Academy of Georgia (Virtual)"
replace SchVirtual = 1 if SchName == "Destinations Career Academy of Georgia (Virtual)"
replace NCESSchoolID = "130585204434" if SchName == "Resurgence Hall Middle Academy"
replace SchLevel = 2 if SchName == "Resurgence Hall Middle Academy"
replace SchType = 1 if SchName == "Resurgence Hall Middle Academy"
replace SchVirtual = 0 if SchName == "Resurgence Hall Middle Academy"


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

save "$GAdata/GA_AssmtData_2023.dta", replace
export delimited "$GAdata/GA_AssmtData_2023.csv", replace
