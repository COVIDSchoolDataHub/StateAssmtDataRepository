clear all

cd "/Users/miramehta/Documents/"
global GAdata "/Users/miramehta/Documents/GA State Testing Data"
global NCES "/Users/miramehta/Documents/NCES District and School Demographics"

import delimited "$GAdata/GA_OriginalData_2024_all.csv", clear
tostring acdmc_lvl, replace
save "$GAdata/GA_OriginalData_2024.dta", replace
import delimited "$GAdata/GA_OriginalData_2024_G38_all.csv", clear
append using "$GAdata/GA_OriginalData_2024.dta"

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
gen AssmtName = "Georgia Milestones EOG"
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

replace StateAssignedDistID = "00000" if DataLevel == "State"
replace StateAssignedSchID = "00000" if DataLevel != "School"
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup
by uniquegrp: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
by uniquegrp: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
replace StudentGroup_TotalTested = "--" if missing(StudentGroup_TotalTested)
drop if inlist(StudentSubGroup_TotalTested, "0", "*", "--") & StudentSubGroup != "All Students"
replace StateAssignedDistID = "" if DataLevel == "State"
replace StateAssignedSchID = "" if DataLevel != "School"

//Reformatting & Deriving Additional Information
destring num_tested_cnt, replace force
forvalues n = 1/4{
	replace Lev`n'_percent = Lev`n'_percent/100
	replace Lev`n'_count = "*" if Lev`n'_count == "TFS"
	replace Lev`n'_count = "--" if Lev`n'_count == ""
	gen Lev`n' = Lev`n'_p * num_tested_cnt
	replace Lev`n' = . if Lev`n' < 0
	replace Lev`n' = round(Lev`n')
	tostring Lev`n', replace
	replace Lev`n'_count = Lev`n' if inlist(Lev`n'_count, "*", "--") & Lev`n' != "."
	tostring Lev`n'_percent, replace format("%9.3g") force
	drop Lev`n'
}

//ProficientOrAbove
gen Proficient_Count = Lev3_count
gen Distinguished_Count = Lev4_count
destring Proficient_Count, replace force
destring Distinguished_Count, replace force

gen ProficiencyCriteria = "Levels 3-4"
gen ProficientOrAbove_count = Proficient_Count + Distinguished_Count if Proficient_Count !=. & Distinguished_Count !=.
drop Proficient_Count Distinguished_Count

gen ProficientOrAbove_percent = ProficientOrAbove_count/num_tested_cnt

destring Lev3_percent, gen(Proficient_Percent)
destring Lev4_percent, gen(Distinguished_Percent)
replace ProficientOrAbove_percent = Proficient_Percent + Distinguished_Percent if ProficientOrAbove_percent == . & Proficient_Percent != . & Distinguished_Percent != .

//Missing Data
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev3_count == "*"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev3_count == "--"
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "." & Lev4_count == "*"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "." & Lev4_count == "--"
tostring ProficientOrAbove_percent, replace format("%9.3g") force
replace Lev1_percent = "--" if Lev1_percent == "."
replace Lev2_percent = "--" if Lev2_percent == "."
replace Lev3_percent = "--" if Lev3_percent == "."
replace Lev4_percent = "--" if Lev4_percent == "."
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "--" & ProficientOrAbove_count == "*"

//Suppressing Level Counts for Cases where SGTT > SSGTT
gen flag = 1 if real(StudentSubGroup_TotalTested) > real(StudentGroup_TotalTested) & real(StudentSubGroup_TotalTested) != . & real(StudentGroup_TotalTested) != .
forvalues n = 1/4{
	replace Lev`n'_count = "*" if flag == 1
}
replace ProficientOrAbove_count = "*" if flag == 1
drop flag

//Grade Levels
replace GradeLevel = "G38" if GradeLevel == "ALL GRADES"
replace GradeLevel = "G0" + GradeLevel if GradeLevel != "G38"

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

//Remove Observations without Data
drop if NCESSchoolID == "130002604354"

//Standardize District & School Names
replace SchName = strproper(SchName)
replace DistName = strproper(DistName)

replace DistName = "DeKalb County" if DistName == "Dekalb County"
replace DistName = "McDuffie County" if DistName ==  "Mcduffie County"
replace DistName = "McIntosh County" if DistName == "Mcintosh County"
replace DistName = "Department of Juvenile Justice" if DistName == "Department Of Juvenile Justice"
replace DistName = "City Schools of Decatur" if DistName == "City Schools Of Decatur"
replace DistName = subinstr(DistName, "State Charter Schools Ii", "State Charter Schools II", 1)

replace SchName = subinstr(SchName, " (Virtual)", "", 1)

replace SchName = "Utopian Academy for the Arts Charter School" if SchName == "Utopian Academy For The Arts Charter School"
replace DistName = "Utopian Academy for the Arts Charter School" if DistName == "State Charter Schools- Utopian Academy For The Arts Charter School"
replace SchName = "Ivy Preparatory Academy, Inc" if SchName == "Ivy Preparatory Academy Inc"
replace DistName = "Ivy Preparatory Academy, Inc" if DistName == "Ivy Preparatory Academy Inc"
replace SchName = "Southwest Georgia S.T.E.M. Charter Academy" if SchName == "Southwest Georgia Stem Charter Acad"
replace DistName = "Southwest Georgia S.T.E.M. Charter Academy" if DistName == "Southwest Georgia Stem Charter Acad"
replace SchName = "International Charter School of Atlanta" if SchName == "International Charter School Of Atlanta"
replace DistName = "International Charter School of Atlanta" if DistName == "International Charter School Of Atl"
replace SchName = "Georgia School for Innovation and the Classics" if SchName == "Georgia School For Innovation And The Classics"
replace DistName = "Georgia School for Innovation and the Classics" if DistName == "Georgia School For Innovation And T"
replace SchName = "Genesis Innovation Academy for Boys" if SchName == "Genesis Innovation Academy For Boys"
replace DistName = "Genesis Innovation Academy for Boys" if DistName == "Genesis Innovation Academy For Boys"
replace SchName = "Genesis Innovation Academy for Girls" if SchName == "Genesis Innovation Academy For Girls"
replace DistName = "Genesis Innovation Academy for Girls" if DistName == "Genesis Innovation Academy For Girls"
replace SchName = "SAIL Charter Academy - School for Arts-Infused Learning" if SchName == "Sail Charter Academy - School For Arts-Infused Learning"
replace DistName = "SAIL Charter Academy - School for Arts-Infused Learning" if DistName == "Sail Charter Academy - School For A"
replace SchName = "International Academy of Smyrna" if SchName == "International Academy Of Smyrna"
replace DistName = "International Academy of Smyrna" if DistName == "International Academy Of Smyrna"
replace SchName = "International Charter Academy of Georgia" if SchName == "International Charter Academy Of Georgia"
replace DistName = "International Charter Academy of Georgia" if DistName == "International Charter Academy Of Ge"
replace SchName = "SLAM Academy of Atlanta" if SchName == "Slam Academy Of Atlanta"
replace DistName = "SLAM Academy of Atlanta" if DistName == "Slam Academy Of Atlanta"
replace SchName = "Statesboro STEAM Academy" if SchName == "Statesboro Steam Academy"
replace DistName = "Statesboro STEAM Academy" if DistName == "Statesboro Steam Academy"
replace SchName = "Yi Hwang Academy of Language Excellence" if SchName == "Yi Hwang Academy Of Language Excellence"
replace DistName = "Yi Hwang Academy of Language Excellence" if DistName == "Yi Hwang Academy Of Language Excellence"
replace SchName = "D.E.L.T.A. STEAM Academy" if SchName == "D.E.L.T.A. Steam Academy"
replace DistName = "D.E.L.T.A. STEAM Academy" if DistName == "D.E.L.T.A. Steam Academy"
replace SchName = "Georgia Fugees Academy Charter School" if SchName == "Georgia Fugees Academy Charter Scho"
replace DistName = "Georgia Fugees Academy Charter School" if DistName == "Georgia Fugees Academy Charter Scho"
replace SchName = "Atlanta SMART Academy" if SchName == "Atlanta Smart Academy"
replace DistName = "Atlanta SMART Academy" if DistName == "Atlanta Smart Academy"
replace SchName = "Destinations Career Academy of Georgia" if SchName == "Destinations Career Academy Of Georgia"
replace DistName = "Destinations Career Academy of Georgia" if DistName == "Destinations Career Academy Of Geor"
replace SchName = "Utopian Academy for the Arts Trilith" if SchName == "Utopian Academy For The Arts Trilith"
replace DistName = "Utopian Academy for the Arts Trilith" if DistName == "State Charter Schools- Utopian Academy For The Arts Trilith"
replace SchName = "DeKalb Brilliance Academy" if SchName == "Dekalb Brilliance Academy"
replace SchName = "Muscogee Education Transition Center" if SchName == "Muscogee Education Transition Cente"
replace DistName = "Liberation Academy" if DistName == "State Charter Schools II- Liberation Academy"
replace DistName = "Miles Ahead Charter School" if DistName == "State Charter Schools II- Miles Ahead Charter School"
replace DistName = "Peace Academy Charter School" if DistName == "State Charter Schools II- Peace Academy Charter School"
replace DistName = "Rise Preparatory Charter School" if DistName == "State Charter Schools II- Rise Preparatory Charter School"
replace DistName = "The Anchor School" if DistName == "State Charter Schools II- The Anchor School"
replace DistName = "Zest Preparatory Academy School" if DistName == "State Charter Schools II- Zest Preparatory Academy School"

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
