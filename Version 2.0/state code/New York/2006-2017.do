clear
set more off
set trace off


forvalues year = 2013/2013 {
local prevyear =`=`year'-1'
use "${original}/Combined_`year'"

//Data contains test score data from prior year in each file
drop if `year' != v3

//Mapping v[n] onto variables in crosswalk
rename v2 ENTITY_NAME
rename v3 YEAR
rename v4 StudentSubGroup
rename v5 StudentSubGroup_TotalTested
rename v6 Lev1_count
rename v7 Lev1_percent
rename v8 Lev2_count
rename v9 Lev2_percent
rename v10 Lev3_count
rename v11 Lev3_percent
rename v12 Lev4_count
rename v13 Lev4_percent
rename v14 TOTAL_SCALE_SCORES
rename v15 AvgScaleScore

//Fixing ENTITY_CD

gen ENTITY_CD = v1
drop v1
order ENTITY_CD

//creating DataLevel, StateAssignedSchID, StateAssignedDistID, based on ENTITY_CD
drop if strlen(ENTITY_CD)<12
drop if substr(ENTITY_CD,1,2)== "00"
gen DataLevel= "State" if ENTITY_CD== "111111111111"
replace DataLevel= "District" if substr(ENTITY_CD,9,4)=="0000" & substr(ENTITY_CD,7,2) !="86"
replace DataLevel= "School" if substr(ENTITY_CD,9,4) !="0000" & substr(ENTITY_CD,7,2) !="86"
replace DataLevel= "School" if substr(ENTITY_CD,7,2) =="86" //All Charter schools are their own district
replace DataLevel = "State" if ENTITY_CD== "111111111111"
gen StateAssignedSchID = ENTITY_CD if DataLevel== "School"
gen StateAssignedDistID = ENTITY_CD if DataLevel== "District"
replace StateAssignedDistID = substr(ENTITY_CD,1,8) + "0000" if DataLevel=="School" & strpos(ENTITY_NAME, "CHARTER") ==0
replace StateAssignedDistID = ENTITY_CD if strpos(ENTITY_NAME, "CHARTER") !=0 & DataLevel == "School"

//Merging and cleaning NCES Data
tempfile temp1
save "`temp1'"
clear
use "${nces_school}/NCES_`prevyear'_School.dta"
drop if state_location != "NY" & state_fips !=36
drop if seasch == ""

if `year' == 2017 {
gen StateAssignedSchID = substr(seasch, strpos(seasch, "-")+1, 12)
decode SchVirtual, gen(SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual
}

else {
	gen StateAssignedSchID = seasch
}
//Correcting StateAssignedSchID and StateAssignedDistID for certain schools
replace StateAssignedSchID = "310300860871" if school_name == "OPPORTUNITY CHARTER SCHOOL" & `year' ==2006
replace StateAssignedSchID = "310500860848" if school_name == "HARLEM VILLAGE ACADEMY CHARTER SCHOOL EHVACS" & `year' == 2006
replace StateAssignedSchID = "331700860841" if school_name == "EXPLORE CHARTER SCHOOL" & `year'==2007 & school_name == lea_name
replace StateAssignedSchID = "331300011527" if strpos(school_name, "URBAN ASSEMBLY INSTITUTE OF MATH") !=0 & `year' == 2009 //NCES cuts full name off
replace StateAssignedSchID = "581004020001" if school_name == "FISHERS ISLAND SCHOOL" & `year' == 2010
replace StateAssignedSchID = "331400860930" if school_name == "THE ETHICAL COMMUNITY CHARTER SCHOOL" & `year' == 2012
merge 1:m StateAssignedSchID using "`temp1'"

*drop if _merge !=3 & DataLevel == "School"
rename _merge _merge1 
tempfile temp2
save "`temp2'"
clear
use "${nces_district}/NCES_`prevyear'_District.dta"
drop if state_location != "NY" & state_fips !=36
if `year' == 2017 {
gen StateAssignedDistID = substr(state_leaid, strpos(state_leaid, "-")+1, 12)
}
else {
gen StateAssignedDistID = state_leaid
}
//Correcting StateAssignedDistID for certain Districts
replace StateAssignedDistID = "331700860841" if lea_name == "EXPLORE CHARTER SCHOOL" & `year' ==2007
replace StateAssignedDistID = "581004020001" if lea_name == " FISHERS ISLAND UNION FREE SCHOOL DISTRICT" & `year' == 2010 //This school and district had state_location = CT but state_name = "New York" & state_fips = 36 ????
replace StateAssignedDistID = "331400860930" if strpos(lea_name,"ETHICAL COMMUNITY CHARTER") !=0 & `year' == 2012

merge 1:m StateAssignedDistID using "`temp2'"
*drop if _merge1 !=3 & DataLevel== "School"
*drop if _merge !=3 & DataLevel == "District"
drop if DataLevel==""
rename state_location StateAbbrev
rename state_name State
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
tostring State, replace force
replace State = "New York"
replace StateAbbrev = "NY"
replace StateFips = 36
rename district_agency_type DistType
decode SchLevel, gen(SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel
rename county_name CountyName
rename county_code CountyCode
replace year = "`prevyear'"
tostring year YEAR, replace force
gen SchYear = year + "-" + substr(YEAR,-2,2)

//Fixing NCES School ID's for select schools that were broken by manually fixing StateAssignedSchID or StateAssignedDistID (broken because NCES does not classify charter schools as their own district, whereas NY does)
/*
destring NCESSchoolID, gen(tempS)
replace tempS = floor(tempS/100000)
destring NCESDistrictID, gen(tempD)
edit if tempS !=tempD
*/


//DistName
drop _merge
gen DistName =""
replace DistName = ENTITY_NAME if DataLevel== "District"
gen SchName = ""
replace SchName = ENTITY_NAME if DataLevel == "School"
replace SchName = "All Schools" if DataLevel != "School"
tempfile temp3
save "`temp3'"
drop if DataLevel != "District"
keep DistName StateAssignedDistID
duplicates drop
merge 1:m StateAssignedDistID using "`temp3'"
drop _merge
replace DistName = "All Districts" if DataLevel== "State"
replace DistName = lea_name if DistCharter == "Yes"

/*
//DistType for 2011 (idk why it didn't work for only 2011 but this should fix it)
if `year' == 2011 {
	tempfile temp4
	save "`temp4'"
	keep NCESDistrictID DistType
	drop if DistType == ""
	duplicates drop
	merge 1:m NCESDistrictID using "`temp4'"
	drop _merge
}
*/


//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//Misc cleaning and generating variables
gen AssmtName = "NYSTP"
gen AssmtType = "Regular"
rename subject Subject
rename grade GradeLevel
gen ParticipationRate="--"
gen Lev5_count = ""
gen Lev5_percent = ""
gen ProficiencyCriteria = "Levels 3-4"

//Subject
replace Subject = "ela" if Subject == "ELA"
replace Subject = "math" if Subject == "MATH"
replace Subject = "sci" if Subject == "SCIENCE"
replace Subject = "soc" if Subject == "SOC"

//StudentSubGroup
drop if strpos(StudentSubGroup, "Male") > 1 | strpos(StudentSubGroup, "Female") > 1
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian or Pacific Islander" | StudentSubGroup == "Asian or Native Hawaiian/Other Pacific Islander"
replace StudentSubGroup = "Two or More" if StudentSubGroup ==  "Multiracial"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner" | StudentSubGroup == "English Language Learners" | StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learners" | StudentSubGroup == "Non-English Language Learner"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "General Education"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "In Foster Care"
replace StudentSubGroup = "Gender X" if StudentSubGroup == "Non-Binary"
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not Homeless"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not Migrant"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not in Foster Care"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Parent Not in Armed Forces"
replace StudentSubGroup = "Military" if StudentSubGroup == "Parent in Armed Forces"
drop if strpos(StudentSubGroup, "Small Group Total") !=0
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"


*tab StudentGroup, missing

//StudentGroup_TotalTested
sort StudentGroup
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2013
gen Flag_CutScoreChange_math = "N"
replace Flag_CutScoreChange_math = "Y" if `year' == 2013
gen Flag_CutScoreChange_soc = "N"
replace Flag_CutScoreChange_soc = "Not applicable" if `year' > 2010
gen Flag_CutScoreChange_sci = "N"
replace Flag_CutScoreChange_sci = "N" if `year' == 2013
//Proficiency Counts and Percents
gen ProficientOrAbove_count = ""
gen ProficientOrAbove_percent = ""
	
	//Suppressed data
	gen SUP = "N"
	replace SUP = "s" if Lev4_count== "s"
	
destring Lev*, replace force
gen tempvar1 = Lev3_count + Lev4_count
gen tempvar2 = tempvar1/StudentSubGroup_TotalTested
tostring tempvar2, replace force format("%9.3g")
tostring tempvar1, replace force format("%9.3g")
replace ProficientOrAbove_count = tempvar1
replace ProficientOrAbove_percent = tempvar2
foreach n in 1 2 3 4 {
	replace Lev`n'_percent = Lev`n'_percent/100
}
tostring Lev*, replace force format("%9.3g")
foreach num in 1 2 3 4 {
	replace Lev`num'_count = "*" if SUP == "s"
	replace Lev`num'_percent = "*" if SUP == "s"
	
}
replace ProficientOrAbove_count = "*" if SUP == "s"
replace ProficientOrAbove_percent = "*" if SUP =="s"
replace AvgScaleScore = "*" if SUP == "s"
replace Lev5_count = ""
replace Lev5_percent = ""

//Fixing Charter Schools (In NY, Charter Schools are classified as their own district)
replace DistName = SchName if DistName == "" & (DistCharter== "Yes" | strpos(SchName, "CHARTER") !=0)
replace DistType = "Charter Agency" if DistType == "" & strpos(SchName, "CHARTER") !=0
replace StateAssignedDistID = StateAssignedSchID if DistCharter == "Yes" | strpos(SchName, "CHARTER") !=0
//"ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" Has no nces data for 2011, fixing what I can below based on future NCES data
capture replace NCESSchoolID = "360008706297" if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace NCESDistrictID = "3600087" if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace seasch = StateAssignedSchID if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace State_leaid = StateAssignedDistID if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' ==2011
capture replace DistCharter = "No" if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace SchLevel = "Missing/not reported" if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace SchVirtual = "Missing/not reported" if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace SchType = "Regular school" if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace CountyName = "BRONX COUNTY" if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011
capture replace CountyCode = 36005 if SchName == "ACADEMY FOR PERSONAL LEADERSHIP AND EXCELLENCE" & `year' == 2011

//"THE ETHICAL COMMUNITY CHARTER SCHOOL" Closed in 2011-2012 SchYear but still took test, NCES school level does not have data so replacing manually with nces 2010 data.
capture replace NCESSchoolID = "360098506136" if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace NCESDistrictID = "3600985" if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace seasch = StateAssignedSchID if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace State_leaid = StateAssignedDistID if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace DistCharter = "Yes" if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace SchLevel = "Not applicable" if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace SchVirtual = "Missing/not reported" if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace SchType = "Regular school" if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace CountyName = "KINGS COUNTY" if StateAssignedSchID == "331400860930" & `year' == 2012
capture replace CountyCode = 36047 if StateAssignedSchID == "331400860930" & `year' == 2012

//Response to R2 and some misc cleaning
replace DistType = "Regular local school district" if DistName == "NORTH COLONIE CSD"
replace DistType = "Charter agency" if DistType == "Charter Agency"

if `year'== 2016 replace SchType = 1 if SchName == "UNION SPRINGS MIDDLE SCHOOL"
if `year'== 2016 replace NCESSchoolID = "362925006575" if SchName == "UNION SPRINGS MIDDLE SCHOOL"
if `year'== 2016 replace seasch = StateAssignedSchID if SchName == "UNION SPRINGS MIDDLE SCHOOL"
if `year'== 2016 replace SchLevel = "Middle" if SchName == "UNION SPRINGS MIDDLE SCHOOL"
if `year'== 2016 replace SchVirtual = 0 if SchName == "UNION SPRINGS MIDDLE SCHOOL"

//Weird NCES County Info in 2016 for NYC District 13
replace CountyName = "Kings County" if CountyName == "Cook County"
replace CountyCode = "36047" if CountyCode == "17031"

replace Subject = "math" if Subject == "mat"

//CountyNames
replace CountyName = proper(CountyName)

//Response to post-launch review
if `year' == 2011 {
	replace SchType = 1 if NCESSchoolID == "360008706297"
	replace SchVirtual = -1 if NCESSchoolID == "360008706297"
}	
if `year' == 2012 {
	replace SchType = 1 if NCESSchoolID == "360098506136"
	replace SchLevel = "Primary" if NCESSchoolID == "360098506136"
	replace SchVirtual = -1 if NCESSchoolID == "360098506136"
}

if `year' == 2006 replace CountyCode = "36103" if CountyName == "Suffolk"

replace ParticipationRate = "--" if ParticipationRate == "." //Updated 7/23/24

//Final Cleaning and dropping extra variables

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/NY_AssmtData_`year'", replace
export delimited "${output}/NY_AssmtData_`year'", replace

		
}

