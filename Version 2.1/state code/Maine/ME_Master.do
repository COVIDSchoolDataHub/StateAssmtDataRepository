clear
set more off
set trace off
global Original "/Users/kaitlynlucas/Desktop/maine/original"
global Output "/Users/kaitlynlucas/Desktop/maine/output"
global NCES_School "/Users/kaitlynlucas/Desktop/maine/nces clean"
global NCES_District "/Users/kaitlynlucas/Desktop/maine/nces clean"


//Running Do files and Combining Original and Data Request Data
local dofiles ME_Cleaning_2015.do ME_Cleaning_2016-2019.do ME_Cleaning_2021-2022.do ME_Cleaning_2023.do

foreach file of local dofiles {
	do `file'
}

do ME_DataRequest_2015_2023
*/
forvalues year = 2016/2023 {
	if 	`year' == 2020 continue
	use "$Output/ME_WebsiteData_`year'"
	gen WebsiteData = 1
	append using "$Output/ME_DataRequest_`year'"
	save "$Output/ME_AssmtData_`year'", replace
}



forvalues year = 2015/2023 {
	if `year' == 2020 continue
//Getting rid of private schools
use "${Output}/ME_AssmtData_`year'"
drop if (missing(NCESDistrictID) & DataLevel== 2 | (missing(NCESSchoolID) & DataLevel == 3 | missing(NCESDistrictID) & DataLevel == 3)) & (!inlist(SchName, "Beatrice Rafferty School", "Indian Island School", "Indian Township School", "MDOE School", "Ashley Bryan School", "Governor Baxter School for the Deaf") & !inlist(SchName, "Hudson Elementary School", "Jay Elementary School", "Livermore Elementary School", "Lura Libby School", "Morison Memorial School", "Oceanside High School East", "Oceanside High School West") & !inlist(SchName, "Rockland District Middle School", "SAD 70 Hodgdon High School") & !inlist(DistName, "ME Educational Ctr for the Deaf & Hard of Hearing"))

//Replacing missing NCES with Missing/not reported
label def virtualdf 16 "Missing/not reported", add
if `year' == 2015 {
	drop if SchName == "MDOE School" //All values suppressed/missing, not in NCES
}

if `year' == 2016 {
	replace DistType = "State-operated agency" if SchName == "Governor Baxter School for the Deaf"
	replace SchType = 2 if SchName == "Governor Baxter School for the Deaf"
	replace SchLevel = -2  if SchName == "Governor Baxter School for the Deaf"
	replace NCESDistrictID = "2300051" if SchName == "Governor Baxter School for the Deaf"
	replace NCESSchoolID = "230005100381" if SchName == "Governor Baxter School for the Deaf"
	replace DistCharter = "No" if SchName == "Governor Baxter School for the Deaf"
	replace CountyName = "Cumberland County" if SchName == "Governor Baxter School for the Deaf"
	replace CountyCode = "23005" if SchName == "Governor Baxter School for the Deaf"
	replace SchVirtual = 0 if SchName == "Governor Baxter School for the Deaf"
	replace DistLocale = "Rural, fringe" if SchName == "Governor Baxter School for the Deaf"
	
}




//Merging Unmerged for 2016
if `year' == 2016 {
gen StateAssignedSchID1 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'"

tempfile temp2
drop if (missing(NCESSchoolID) & DataLevel ==3) | (missing(NCESDistrictID) & DataLevel==2)
save "`temp2'"
clear


//Districts
use "`temp1'"
keep if DataLevel ==2
keep if (missing(NCESSchoolID) & DataLevel ==3) | (missing(NCESDistrictID) & DataLevel==2)
tempfile tempdist
save "`tempdist'", replace
clear
use "${NCES_District}/NCES_2016_District"
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedDistID = subinstr(state_leaid,"ME-","",.)
replace StateAssignedDistID = "1071" if ncesdistrictid == "2300051"
merge 1:m StateAssignedDistID using "`tempdist'"
drop if _merge !=3
replace DistType = district_agency_type
replace NCESDistrictID = ncesdistrictid
replace CountyName = county_name 
replace CountyCode = county_code 
replace StateFips = 23
replace StateAbbrev = "ME"
save "`tempdist'", replace
clear

//Schools
use "`temp1'"
keep if DataLevel ==3
keep if (missing(NCESSchoolID) & DataLevel ==3) | (missing(NCESDistrictID) & DataLevel==2)
tempfile tempschool
save "`tempschool'"
clear
use "${NCES_School}/NCES_2016_School"
rename SchType school_type
keep if state_name == "Maine" | state_location == "ME"
gen StateAssignedSchID1 = seasch
replace StateAssignedSchID1 = "139-141" if strpos(school_name , "Ashley") !=0
replace StateAssignedSchID1 = "1071-1072" if ncesschoolid == "231484323197"
replace StateAssignedSchID1 = "936-941" if ncesschoolid == "231444000944"
replace StateAssignedSchID1 = "1498-233" if ncesschoolid == "231480500172"
replace StateAssignedSchID1 = "1498-750" if ncesschoolid == "231480500456"
replace StateAssignedSchID1 = "1452-836" if ncesschoolid == "231478700709"
replace StateAssignedSchID1 = "936-938" if ncesschoolid == "231444000718"
replace StateAssignedSchID1 = "1452-1454" if ncesschoolid == "231478723128"
replace StateAssignedSchID1 = "1452-1453" if ncesschoolid == "231478723127"
replace StateAssignedSchID1 = "1452-585" if ncesschoolid == "231478700414"
replace StateAssignedSchID1 = "957-959" if ncesschoolid == "231476200795"
merge 1:m StateAssignedSchID1 using "`tempschool'"
drop if _merge !=3
replace DistType = district_agency_type
replace SchType = school_type 
replace NCESDistrictID = ncesdistrictid
replace NCESSchoolID = ncesschoolid 
replace CountyName = county_name 
replace CountyCode = county_code 
replace StateFips = 23
replace StateAbbrev = "ME"
save "`tempschool'", replace
clear

//Appending to Merged data
use "`temp2'"
append using "`tempdist'" "`tempschool'"	
}


replace ProficientOrAbove_percent = ">0.95" if ProficientOrAbove_percent == ">95%"

//Fixing missing values for all years
foreach var of varlist Lev* Proficient* ParticipationRate StudentSubGroup_TotalTested {
	cap replace `var' = "*" if `var' == ""
}
cap replace SchVirtual = 16 if missing(SchVirtual) & DataLevel ==3

//Fixing Ranges
foreach var of varlist Lev*_percent ParticipationRate ProficientOrAbove_percent {
	cap replace `var' = subinstr(`var', "=","",.)
	cap replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
	cap replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
}





//DATA DECISION: GradeLevel == "GZ" because high school data is currently included
if `year' > 2015 replace GradeLevel = "GZ" if WebsiteData == 1

//DATA DECISIONS SCI 2021/ 2022
if `year' == 2021 {
	drop if Subject == "sci"
	replace Flag_CutScoreChange_sci = "Not applicable"
}

//Post Launch Review Response
drop if DistName == "Indian Island" //NCESDistrictID == 5900160
drop if DistName == "Indian Township" // NCESDistrictID == 5900042
drop if SchName == "Beatrice Rafferty School" //NCESSchoolID == 590013700042

//Getting rid of State & District Level GZ data in 2023
if `year' == 2023 drop if GradeLevel == "GZ" & DataLevel !=3

//Converting StateAssignedSchID to StateAssignedDistID - StateAssignedSchID so that School ID's are unique
replace StateAssignedSchID = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == 3

//fixing odd Flag_cutscore thing
replace Flag_CutScoreChange_ELA = "Y" if `year' == 2016
replace Flag_CutScoreChange_math = "Y" if `year' == 2016
replace Flag_CutScoreChange_soc = "Not applicable"

//Deriving additional ssg_tt
gen UnsuppressedSSG = real(StudentSubGroup_TotalTested)
egen UnsuppressedSG = total(UnsuppressedSSG), by(StudentGroup DistName SchName GradeLevel Subject)
gen missing_SSG = 1 if missing(real(StudentSubGroup_TotalTested))
egen missing_multiple = total(missing_SSG), by(StudentGroup DistName SchName GradeLevel Subject)

order StudentGroup_TotalTested UnsuppressedSG StudentSubGroup_TotalTested UnsuppressedSSG missing_multiple

replace StudentSubGroup_TotalTested = string(real(StudentGroup_TotalTested)-UnsuppressedSG) if missing(real(StudentSubGroup_TotalTested)) & UnsuppressedSG > 0 & (missing_multiple <2 | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient") & real(StudentGroup_TotalTested)-UnsuppressedSG > 0 & !missing(real(StudentGroup_TotalTested)-UnsuppressedSG) & StudentSubGroup != "All Students"

drop Unsuppressed* missing_*
replace Lev5_count = ""


//Level percent derivations if we have all other percents
replace Lev1_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev1_percent))

replace Lev2_percent = string(1-real(Lev4_percent)-real(Lev3_percent)-real(Lev1_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev1_percent)) & missing(real(Lev2_percent))

replace Lev3_percent = string(1-real(Lev4_percent)-real(Lev1_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev4_percent)) & !missing(real(Lev1_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev3_percent))

replace Lev4_percent = string(1-real(Lev1_percent)-real(Lev3_percent)-real(Lev2_percent), "%9.3g") if !missing(1) & !missing(real(Lev1_percent)) & !missing(real(Lev3_percent)) & !missing(real(Lev2_percent)) & missing(real(Lev4_percent))

replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(Lev2_count) - real(Lev3_count) - real(Lev4_count), "%9.3g") if !missing(StudentSubGroup_TotalTested) & !missing(real(Lev4_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & missing(real(Lev1_count))
replace Lev2_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev3_count) - real(Lev4_count), "%9.3g") ///
    if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count)) & missing(real(Lev2_count))
replace Lev3_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev4_count), "%9.3g") ///
    if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev4_count)) & missing(real(Lev3_count))
replace Lev4_count = string(real(StudentSubGroup_TotalTested) - real(Lev1_count) - real(Lev2_count) - real(Lev3_count), "%9.3g") ///
    if !missing(real(StudentSubGroup_TotalTested)) & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & missing(real(Lev4_count))
	
//fixing specifically 2022 and 2023 cases
replace Lev4_count = string(real(ProficientOrAbove_count) - real(Lev3_count), "%9.3g") ///
    if !missing(real(ProficientOrAbove_count)) & !missing(real(Lev3_count)) & Lev4_count == "*"
	
replace Lev4_percent = string(real(ProficientOrAbove_percent) - real(Lev3_percent), "%9.3g") ///
    if !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent)) & Lev4_percent == "*"
	
replace Lev1_count = string(real(StudentSubGroup_TotalTested) - real(Lev2_count) - real(Lev3_count) - real(Lev4_count), "%9.3g") if !missing(StudentSubGroup_TotalTested) & !missing(real(Lev4_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & Lev1_count == "*"

replace Lev1_percent = string(1 - real(Lev2_percent) - real(Lev3_percent) - real(Lev4_percent), "%9.3g") if !missing(real(Lev4_percent)) & !missing(real(Lev2_percent)) & !missing(real(Lev3_percent)) & Lev1_percent == "*"

if `year' == 2023{
	replace Lev1_count = "--" if Lev1_count == "."
}

//fixing "e" issue in level percents
replace Lev1_percent = "0" if strpos(Lev1_percent, "e") > 0
replace Lev4_percent = "0" if strpos(Lev4_percent, "e") > 0

replace Lev5_percent = ""
replace Lev5_count = ""




//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/ME_AssmtData_`year'", replace	
export delimited "${Output}/ME_AssmtData_`year'", replace 
	
clear	
}

do ME_2024_DataRequest_01.16.25.do
