clear
set more off

cap log close
log using california_cleaning.log, replace

cd "/Users/minnamgung/Desktop/SADR/California"

// File conversion loop 
// Only run this part ONCE! 

/*
global years 2010 2011 2012 2013 2015 2016 2017 2018 2019 2021 2022 2023

foreach a in $years {
	import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_`a'.txt", delimiter("^") case(preserve) clear 
	save California_Original_`a', replace
}

global years 2010 2011 2012 2013 2015 2016 2017 2018 2019 

foreach a in $years {
	import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_`a'.txt", delimiter(",") case(preserve) clear 
	save California_Original_`a', replace
}

global years 2021 2022 2023

foreach a in $years {
	import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/sb_ca`a'entities_csv.txt", delimiter("^") case(preserve) clear 
	save California_School_District_Names_`a', replace
}

global years 2013 2015 2016 2017 2018 2019 

foreach a in $years {
	import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/sb_ca`a'entities_csv.txt", delimiter(",") case(preserve) clear 
	save California_School_District_Names_`a', replace
}

global years 2010 2011 2012

foreach a in $years {
	import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/ca`a'entities_csv.txt", delimiter(",") case(preserve) clear 
	save California_School_District_Names_`a', replace
}
*/


// 2021-22 School Year 
use California_Original_2023, clear

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2023
drop _merge

drop if StudentGroupID == 250
drop if StudentGroupID == 251
drop if StudentGroupID == 252

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge


// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"


gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0


rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestID Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
gen StudentGroup_TotalTested = StudentsTested 
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = "Para Los Ninos Charter" if DistName == "Para Los Niños Charter"
replace DistName = "Para Los Ninos Middle" if DistName == "Para Los Niños Middle"
replace DistName = "Shanel Valley Academy" if DistName == "Shanél Valley Academy" 


replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

replace DistName = "Voices College-Bound Language Academy At" if DistName == "Voices College Bound Language Academy At" 

merge m:1 DistName using 1_NCES_2021_District_With_Extra_Districts, force // CHANGED
rename _merge DistMerge

drop DistName
rename DistName1 DistName

replace State_leaid = "Missing/Not Reported" if DistMerge == 1 & CountyCode != 0 //& StateAssignedSchID == 0
replace NCESDistrictID = "00" if DistMerge == 1 & CountyCode != 0 // & StateAssignedSchID == 0

drop if DistMerge == 2
// drop DistMerge

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID State_School_ID

rename State_School_ID seasch2 // NEW ADDED

merge m:m seasch2 using 1_NCES_2021_School, force // CHANGED
rename _merge SchoolMerge

drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""
// drop SchoolMerge

rename seasch2 StateAssignedSchID // CHANGED

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED

drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""


gen SchYear2 = "2022-23"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"

// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"



// NEW ADDED

// New Demographic/StudentGroup LABEL criteria (2024 update)

replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed

// Changed 2 
destring StudentsTested, replace force 
destring StudentsEnrolled, replace force
gen ParticipationRate = StudentsTested/StudentsEnrolled
// Changed 2


// drop schyear // DELETED


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED



// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode

// NEW EDITED

// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


// r3 change unique to 2022 
replace SchVirtual = "No" if SchName == "Aspen Ridge Public"
replace SchVirtual = "No" if SchName == "Audeo Valley Charter"
replace SchVirtual = "No" if SchName == "Bostonia Global"
replace SchVirtual = "No" if SchName == "Bridges Preparatory Academy"
replace SchVirtual = "No" if SchName == "KIPP Stockton Kindergarten-12 Grade"
replace SchVirtual = "No" if SchName == "New Hope Charter"
replace SchVirtual = "No" if SchName == "Shanél Valley Academy"
// r3 change unique to 2022 

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED


save CA_AssmtData_2023_Stata, replace
export delimited CA_AssmtData_2023.csv, replace 







// 2021-22 School Year 
//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/sb_ca2022_all_csv_v1 (1)/sb_ca2022_all_csv_v1.txt", delimiter("^") case(preserve) clear 
//save California_Original_2022, replace
use California_Original_2022, clear 

// import delimited sb_ca2022entities_csv.txt, delimiters("^") case(preserve) clear
// save California_School_District_Names, replace

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2022
drop _merge

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"


gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestID Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
gen StudentGroup_TotalTested = StudentsTested // r3 changed 2021 + 2022
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = "Para Los Ninos Charter" if DistName == "Para Los Niños Charter"
replace DistName = "Para Los Ninos Middle" if DistName == "Para Los Niños Middle"
replace DistName = "Shanel Valley Academy" if DistName == "Shanél Valley Academy" 



replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

merge m:m DistName using 1_NCES_2021_District_With_Extra_Districts, force // CHANGED
rename _merge DistMerge
drop if DistMerge == 2
// drop DistMerge

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID State_School_ID

rename State_School_ID seasch2 // NEW ADDED

merge m:m seasch2 using 1_NCES_2021_School, force // CHANGED
rename _merge SchoolMerge

drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""
// drop SchoolMerge

rename seasch2 StateAssignedSchID // CHANGED

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""


gen SchYear2 = "2021-22"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"



// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"



// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed

// Changed 2 
destring StudentsTested, replace force 
destring StudentsEnrolled, replace force
gen ParticipationRate = StudentsTested/StudentsEnrolled
// Changed 2


// drop schyear // DELETED


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED

// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


// r3 change unique to 2022 
replace SchVirtual = "No" if SchName == "Aspen Ridge Public"
replace SchVirtual = "No" if SchName == "Audeo Valley Charter"
replace SchVirtual = "No" if SchName == "Bostonia Global"
replace SchVirtual = "No" if SchName == "Bridges Preparatory Academy"
replace SchVirtual = "No" if SchName == "KIPP Stockton Kindergarten-12 Grade"
replace SchVirtual = "No" if SchName == "New Hope Charter"
replace SchVirtual = "No" if SchName == "Shanél Valley Academy"
// r3 change unique to 2022 

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED


save CA_AssmtData_2022_Stata, replace
export delimited CA_AssmtData_2022.csv, replace 







// 2020-21 School Year 


//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/sb_ca2021entities_csv.txt", delimiters("^") case(preserve) clear
//save California_School_District_Names_2021, replace


//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2021.txt", delimiter("^") case(preserve) clear 
//save California_Original_2021, replace
use California_Original_2021, clear

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2021
drop _merge

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"


gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestID Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
gen StudentGroup_TotalTested = StudentsTested // r3 changed 2021 + 2022
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

merge m:m DistName using 1_NCES_2020_District_With_Extra_Districts, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch2

merge m:m seasch2 using 1_NCES_2020_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != "" 

rename seasch2 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""

 

gen SchYear2 = "2020-21"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"


// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"



// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed

// Changed 2 
destring StudentsTested, replace force 
destring StudentsEnrolled, replace force
gen ParticipationRate = StudentsTested/StudentsEnrolled
// Changed 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED




// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode 
// NEW EDITED



// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed



replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED 

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup // r3 changed
//NEW ADDED

save CA_AssmtData_2021_Stata, replace
export delimited CA_AssmtData_2021.csv, replace
















// 2018-19 School Year 


// import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
// drop DemographicIDNum
// rename DemographicID SubgroupID 
// save California_Student_Group_Names_2019, replace

// import delimited sb_ca2019entities_csv.txt, delimiters(",") case(preserve) clear
// save California_School_District_Names_2019, replace

//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2019.txt", delimiter(",") case(preserve) clear
//save California_Original_2019, replace
use California_Original_2019, clear

merge m:1 DistrictCode CountyCode SchoolCode using California_School_District_Names_2019 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

merge m:m DistName using 1_NCES_2018_District_With_Extra_Districts, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID




rename StateAssignedSchID seasch2

merge m:m seasch2 using 1_NCES_2018_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

rename seasch2 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""

 

gen SchYear2 = "2018-19"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"

// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"

// NEW ADDED

// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed

// Changed 2 
destring StudentGroup_TotalTested, replace force 
destring CAASPPReportedEnrollment, replace force
gen ParticipationRate = StudentGroup_TotalTested/CAASPPReportedEnrollment 
// Changed 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED
 


// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2

// r3 change unique to 2019
replace SchVirtual = "No" if SchName == "Maya Lin"
// r3 change unique to 2019

//NEW ADDED

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

save CA_AssmtData_2019_Stata, replace
export delimited CA_AssmtData_2019.csv, replace











// 2017-18 School Year 


//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names_2018, replace

//import delimited sb_ca2018entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2018, replace


//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2018.txt", delimiter(",") case(preserve) clear
//save California_Original_2018, replace
use California_Original_2018, clear

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2018 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge


// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0


rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

merge m:m DistName using 1_NCES_2017_District_With_Extra_Districts, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch2

merge m:m seasch2 using 1_NCES_2017_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

rename seasch2 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""

 

gen SchYear2 = "2017-18"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"

// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"


// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"

//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed

// Changed 2 
destring StudentGroup_TotalTested, replace force 
destring CAASPPReportedEnrollment, replace force
gen ParticipationRate = StudentGroup_TotalTested/CAASPPReportedEnrollment 
// Changed 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED




// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED



// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2018_Stata, replace
export delimited CA_AssmtData_2018.csv, replace 











// 2016-17 School Year 


//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names_2017, replace

//import delimited sb_ca2017entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2017, replace

//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2017.txt", delimiter(",") case(preserve) clear
//save California_Original_2017, replace
use California_Original_2017, clear

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2017 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

merge m:m DistName using 1_NCES_2016_District_With_Extra_Districts_2, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch2

merge m:m seasch2 using 1_NCES_2016_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

rename seasch2 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""

 

gen SchYear2 = "2016-17"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"



// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"

// NEW ADDED

// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


// Ethnicity Group 
//replace StudentSubGroup = "" if StudentSubGroup == ""
// replace StudentSubGroup = "" if StudentSubGroup == ""

// El Status Group 

replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
// replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not Limited English Proficient"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"


// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"
//NEW ADDED


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed


destring StudentGroup_TotalTested, replace force
destring CAASPPReportedEnrollment, replace force
gen ParticipationRate = StudentGroup_TotalTested/CAASPPReportedEnrollment // Changed 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED



// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2017_Stata, replace
export delimited CA_AssmtData_2017.csv, replace











// 2015-16 School Year 


//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names_2016, replace

//import delimited sb_ca2016entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2016, replace

//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2016.txt", delimiter(",") case(preserve) clear
//save California_Original_2016, replace
use California_Original_2016, clear

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2016 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

merge m:m DistName using 1_NCES_2015_District_With_Extra_Districts_2, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch1

merge m:m seasch1 using 1_NCES_2015_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

rename seasch1 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = ""
gen Flag_CutScoreChange_soc = ""

 

gen SchYear2 = "2015-16"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"


// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"


// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed



gen ParticipationRate = StudentGroup_TotalTested/CAASPPReportedEnrollment // Changed 2



gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED

tostring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested1)
drop StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED



// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 



destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 


// r3 changed
gen total1 = Lev1_percent + Lev2_percent + Lev3_percent + Lev4_percent
replace Lev1_percent = -111111 if total1 == 0  
replace Lev2_percent = -111111 if total1 == 0  
replace Lev3_percent = -111111 if total1 == 0  
replace Lev4_percent = -111111 if total1 == 0  
drop total1
//r3 changed

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2016_Stata, replace
export delimited CA_AssmtData_2016.csv, replace















// 2014-15 School Year 


//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names_2015, replace

//import delimited sb_ca2015entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2015, replace

//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2015.txt", delimiter(",") case(preserve) clear
//save California_Original_2015, replace
use California_Original_2015, clear

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2015 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

gen DataLevel = "School"
replace DataLevel = "District" if SchoolCode == 0
replace DataLevel = "County" if DistrictCode == 0 & SchoolCode == 0
replace DataLevel = "State" if CountyCode == 0 & DistrictCode == 0 & SchoolCode == 0

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageStandardExceeded Lev4_percent
rename PercentageStandardMet Lev3_percent
rename PercentageStandardNearlyMet Lev2_percent
rename PercentageStandardNotMet Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageStandardMetandAbove ProficientOrAbove_percent

drop StudentGroupID


replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)

merge m:m DistName using 1_NCES_2014_District_With_Extra_Districts_2, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch1

merge m:m seasch1 using 1_NCES_2014_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

rename seasch1 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "Y"
gen Flag_CutScoreChange_ELA = "Y"
gen Flag_CutScoreChange_math = "Y"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = ""
 

gen SchYear2 = "2014-15"
drop SchYear
rename SchYear2 SchYear

gen AssmtName = "Smarter Balanced"
gen AssmtType = "Regular"

// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 2 
replace Subject2 = "ela" if Subject == 1
drop Subject
rename Subject2 Subject

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"

// NEW ADDED

// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"



gen ProficiencyCriteria = "Levels 3 and 4"
gen ProficientOrAbove_count = "--" 
//r3 changed


gen ParticipationRate = StudentGroup_TotalTested/CAASPPReportedEnrollment // Changed 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED


tostring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested1)
drop StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED



// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
// replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 


// r3 changed
gen total1 = Lev1_percent + Lev2_percent + Lev3_percent + Lev4_percent
replace Lev1_percent = -111111 if total1 == 0  
replace Lev2_percent = -111111 if total1 == 0  
replace Lev3_percent = -111111 if total1 == 0  
replace Lev4_percent = -111111 if total1 == 0  
drop total1
//r3 changed

// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent, replace force // r3 changed


replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"

//r3 changed 
replace Lev1_percent = "--" if Lev1_percent == "-111111"
replace Lev2_percent = "--" if Lev2_percent == "-111111" 
replace Lev3_percent = "--" if Lev3_percent == "-111111"
replace Lev4_percent = "--" if Lev4_percent == "-111111" 
//r3 changed 

replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2015_Stata, replace
export delimited CA_AssmtData_2015.csv, replace


















// 2012-13 School Year 




//
// 32 = Science (sci)
// 29 = Social Studies (soc)
// 28 = General Mathematics 
// 14 = Integrated Math 3 
// 13 = Algebra 2 
// 12 = Integrated Math 2 
// 11 = Geometry 
// 10 = Integrated Math 1
// 9 = Algebra 1
// 8 = Math (math)
// 7 = ELA (ela)



//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names, replace

//import delimited sb_ca2013entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2013, replace


//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2013.txt", delimiter(",") case(preserve) clear
// save California_Original_2013, replace
use California_Original_2013, clear

// NEW ADDED
keep if TestType =="C"
keep if Grade == 3 |  Grade == 4 |  Grade == 5 |  Grade == 6 |  Grade == 7 |  Grade == 8 
// NEW ADDED



merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2013 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge



// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"


// REPLACED
gen DataLevel = ""
replace DataLevel = "State" if TypeId == 4
replace DataLevel = "County" if TypeId == 5
replace DataLevel = "District" if TypeId == 6
replace DataLevel = "School" if TypeId == 7
replace DataLevel = "School" if TypeId == 9
replace DataLevel = "School" if TypeId == 10
// REPLACED


rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageAdvanced Lev5_percent
rename PercentageProficient Lev4_percent
rename PercentageBasic Lev3_percent
rename PercentageBelowBasic Lev2_percent 
rename PercentageFarBelowBasic Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageAtOrAboveProficient ProficientOrAbove_percent


drop StudentGroupID

replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)



merge m:m DistName using 1_NCES_2012_District_With_Extra_Districts_2, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch1


merge m:m seasch1 using 1_NCES_2012_School, force //CHANGED TO M:M CHECK
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""


rename seasch1 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED

drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

 

gen SchYear2 = "2012-13"
drop SchYear
rename SchYear2 SchYear


// CHANGED 1.5
gen AssmtName = "STAR - California Standards Tests (CSTs)" 
gen AssmtType = "Regular"



// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 8 // CHANGED
replace Subject2 = "ela" if Subject == 7 // CHANGED
replace Subject2 = "soc" if Subject == 29 // CHANGED
replace Subject2 = "sci" if Subject == 32 // CHANGED
replace Subject2 = "math" if Subject == 9 & GradeLevel == 8


drop Subject
rename Subject2 Subject

drop if Subject == ""

// CHANGED 1.5

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"



// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"



gen ProficiencyCriteria = "Levels 4 and 5"
gen ProficientOrAbove_count = "--" 
//r3 changed

 
gen ParticipationRate = StudentGroup_TotalTested/STARReportedEnrollmentCAPAEligib // CHANGED 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED



// NEW ADDED 

tostring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested1)
drop StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested

// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

//decode SchVirtual, gen (SchVirtual1)
//drop SchVirtual
//rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED



// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent  Lev5_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace Lev5_percent = Lev5_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 



// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2013_Stata, replace
export delimited CA_AssmtData_2013.csv, replace












// 2011-2012
//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names_2012, replace

//import delimited ca2012entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2012, replace

//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2012.txt", delimiter(",") case(preserve) clear
//save California_Original_2012, replace
use California_Original_2012, clear

// NEW ADDED
keep if TestType =="C"
keep if Grade == 3 |  Grade == 4 |  Grade == 5 |  Grade == 6 |  Grade == 7 |  Grade == 8 
// NEW ADDED



merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2012 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge


// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

// REPLACED
gen DataLevel = ""
replace DataLevel = "State" if TypeId == 4
replace DataLevel = "County" if TypeId == 5
replace DataLevel = "District" if TypeId == 6
replace DataLevel = "School" if TypeId == 7
replace DataLevel = "School" if TypeId == 9
replace DataLevel = "School" if TypeId == 10
// REPLACED


rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageAdvanced Lev5_percent
rename PercentageProficient Lev4_percent
rename PercentageBasic Lev3_percent
rename PercentageBelowBasic Lev2_percent 
rename PercentageFarBelowBasic Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageAtOrAboveProficient ProficientOrAbove_percent

drop StudentGroupID

replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)


merge m:m DistName using 1_NCES_2011_District_With_Extra_Districts_2, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch1

merge m:m seasch1 using 1_NCES_2011_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


rename seasch1 StateAssignedSchID


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

 

gen SchYear2 = "2011-12"
drop SchYear
rename SchYear2 SchYear

// CHANGED 1.5
gen AssmtName = "STAR - California Standards Tests (CSTs)" 
gen AssmtType = "Regular"



// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 8 // CHANGED
replace Subject2 = "ela" if Subject == 7 // CHANGED
replace Subject2 = "soc" if Subject == 29 // CHANGED
replace Subject2 = "sci" if Subject == 32 // CHANGED
replace Subject2 = "math" if Subject == 9 & GradeLevel == 8

// MAY BE ADDING MORE
drop Subject
rename Subject2 Subject

drop if Subject == ""

// CHANGED 1.5

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"


// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"



gen ProficiencyCriteria = "Levels 4 and 5"
gen ProficientOrAbove_count = "--" 
//r3 changed



gen ParticipationRate = StudentGroup_TotalTested/STARReportedEnrollmentCAPAEligib // CHANGED 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED



// NEW ADDED 

tostring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested1)
drop StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested

// NEW ADDED 


// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

//decode SchVirtual, gen (SchVirtual1)
//drop SchVirtual
//rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED


// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent  Lev5_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace Lev5_percent = Lev5_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 



// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent, replace force // r3 changed



replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


//r3 changed
replace NCESSchoolID = "060256214589" if StateAssignedSchID == "0140558"
replace NCESSchoolID = "060256414577" if StateAssignedSchID == "0140798"
replace NCESSchoolID = "060255914587" if StateAssignedSchID == "0140806"
//r3 changed

//NEW ADDED

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2012_Stata, replace
export delimited CA_AssmtData_2012.csv, replace











// 2010-2011
//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names_2011, replace

//import delimited ca2011entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2011, replace

// import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2011.txt", delimiter(",") case(preserve) clear
// save California_Original_2011, replace
use California_Original_2011, clear

// NEW ADDED
keep if TestType =="C"
keep if Grade == 3 |  Grade == 4 |  Grade == 5 |  Grade == 6 |  Grade == 7 |  Grade == 8 
// NEW ADDED

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2011 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge

// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

// REPLACED
gen DataLevel = ""
replace DataLevel = "State" if TypeId == 4
replace DataLevel = "County" if TypeId == 5
replace DataLevel = "District" if TypeId == 6
replace DataLevel = "School" if TypeId == 7
replace DataLevel = "School" if TypeId == 9
replace DataLevel = "School" if TypeId == 10
// REPLACED

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageAdvanced Lev5_percent
rename PercentageProficient Lev4_percent
rename PercentageBasic Lev3_percent
rename PercentageBelowBasic Lev2_percent 
rename PercentageFarBelowBasic Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageAtOrAboveProficient ProficientOrAbove_percent

drop StudentGroupID

replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)


merge m:m DistName using 1_NCES_2010_District_With_Extra_Districts_2, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch1

merge m:m seasch1 using 1_NCES_2010_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

rename seasch1 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

 

gen SchYear2 = "2010-11"
drop SchYear
rename SchYear2 SchYear

// CHANGED 1.5
gen AssmtName = "STAR - California Standards Tests (CSTs)" 
gen AssmtType = "Regular"



// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 8 // CHANGED
replace Subject2 = "ela" if Subject == 7 // CHANGED
replace Subject2 = "soc" if Subject == 29 // CHANGED
replace Subject2 = "sci" if Subject == 32 // CHANGED
replace Subject2 = "math" if Subject == 9 & GradeLevel == 8

// MAY BE ADDING MORE
drop Subject
rename Subject2 Subject

drop if Subject == ""

// CHANGED 1.5

// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"



// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"



//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"



gen ProficiencyCriteria = "Levels 4 and 5"
gen ProficientOrAbove_count = "--" 
//r3 changed


gen ParticipationRate = StudentGroup_TotalTested/STARReportedEnrollmentCAPAEligib // CHANGED 2


gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED


// NEW ADDED 

tostring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested1)
drop StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested

// NEW ADDED 



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

// decode SchVirtual, gen (SchVirtual1)
// drop SchVirtual
// rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED


// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent  Lev5_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace Lev5_percent = Lev5_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 



// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


replace NCESSchoolID = "063543012538" if StateAssignedSchID == "0120261" //r3 changed


// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

//NEW ADDED

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2011_Stata, replace
export delimited CA_AssmtData_2011.csv, replace







// 2009-2010
//import delimited StudentGroups.txt, delimiters("^") case(preserve) clear
//drop DemographicIDNum
//rename DemographicID SubgroupID 
//save California_Student_Group_Names_2010, replace

//import delimited ca2010entities_csv.txt, delimiters(",") case(preserve) clear
//save California_School_District_Names_2010, replace

//import delimited "/Users/minnamgung/Desktop/SADR/California/Original Data Files/CA_OriginalData_2010.txt", delimiter(",") case(preserve) clear
// save California_Original_2010, replace
use California_Original_2010, clear

// NEW ADDED
keep if TestType =="C"
keep if Grade == 3 |  Grade == 4 |  Grade == 5 |  Grade == 6 |  Grade == 7 |  Grade == 8 
// NEW ADDED

merge m:1 CountyCode DistrictCode SchoolCode using California_School_District_Names_2010 //no countycode
drop _merge

rename SubgroupID StudentGroupID

merge m:1 StudentGroupID using California_Student_Group_Names
drop _merge


// New Demographic/StudentGroup DROP criteria (2024 update)
drop if StudentGroup == "Ethnicity for Economically Disadvantaged"
drop if StudentGroup == "Ethnicity for Not Economically Disadvantaged"
drop if StudentGroup == "Parent Education"

drop if DemographicName == "ADEL (Adult English learner)"  
drop if DemographicName == "College graduate"
drop if DemographicName == "Declined to state"
drop if DemographicName == "ELs enrolled 12 months or more"
drop if DemographicName == "ELs enrolled less than 12 months"

drop if DemographicName == "Graduate school/Post graduate"
drop if DemographicName == "High school graduate"
drop if DemographicName == "Not a high school graduate"
drop if DemographicName == "Some college (includes AA degree)"
drop if DemographicName == "IFEP (Initial fluent English proficient)"
drop if DemographicName == "TBD (To be determined)"

// REPLACED
gen DataLevel = ""
replace DataLevel = "State" if TypeId == 4
replace DataLevel = "County" if TypeId == 5
replace DataLevel = "District" if TypeId == 6
replace DataLevel = "School" if TypeId == 7
replace DataLevel = "School" if TypeId == 9
replace DataLevel = "School" if TypeId == 10
// REPLACED

rename TestYear SchYear
rename DistrictCode StateAssignedDistID

rename SchoolCode StateAssignedSchID
rename DistrictName DistName 
rename TestId Subject 
rename Grade GradeLevel
// StudentGroup already has correct name
rename DemographicName StudentSubGroup
rename StudentsTested StudentGroup_TotalTested
rename SchoolName SchName
rename PercentageAdvanced Lev5_percent
rename PercentageProficient Lev4_percent
rename PercentageBasic Lev3_percent
rename PercentageBelowBasic Lev2_percent 
rename PercentageFarBelowBasic Lev1_percent 
rename MeanScaleScore AvgScaleScore
rename PercentageAtOrAboveProficient ProficientOrAbove_percent

drop StudentGroupID

replace DistName = ustrtitle(DistName)
replace CountyName = ustrtitle(CountyName)


merge m:m DistName using 1_NCES_2009_District_With_Extra_Districts_2, force
rename _merge DistMerge
drop if DistMerge == 2

gen str7 DUMMY = string(StateAssignedSchID,"%07.0f")
drop StateAssignedSchID
rename DUMMY StateAssignedSchID

rename StateAssignedSchID seasch1

merge m:m seasch1 using 1_NCES_2009_School, force
rename _merge SchoolMerge
drop if SchoolMerge == 2
drop if SchoolMerge == 1 & SchName != ""

rename seasch1 StateAssignedSchID

//New ADDED
drop if DataLevel == "County"


label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 


replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 1
replace SchName = "All Schools" if DataLevel == 2

// NEW ADDED


drop State
drop StateAbbrev
drop StateFips
gen State = "California"
gen StateAbbrev = "CA"
gen StateFips = 6 // CHANGED

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
// gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_sci = "N"
gen Flag_CutScoreChange_soc = "N"

 

gen SchYear2 = "2009-10"
drop SchYear
rename SchYear2 SchYear



// CHANGED 1.5
gen AssmtName = "STAR - California Standards Tests (CSTs)" 
gen AssmtType = "Regular"



// Changing Subject to Correct Format
gen Subject2 = "" 
replace Subject2 = "math" if Subject == 8 // CHANGED
replace Subject2 = "ela" if Subject == 7 // CHANGED
replace Subject2 = "soc" if Subject == 29 // CHANGED
replace Subject2 = "sci" if Subject == 32 // CHANGED
replace Subject2 = "math" if Subject == 9 & GradeLevel == 8

// MAY BE ADDING MORE
drop Subject
rename Subject2 Subject

drop if Subject == ""

// CHANGED 1.5



// Changing GradeLevel to correct format
gen GradeLevel2 = ""
replace GradeLevel2 = "G03" if GradeLevel == 3
replace GradeLevel2 = "G04" if GradeLevel == 4
replace GradeLevel2 = "G05" if GradeLevel == 5
replace GradeLevel2 = "G06" if GradeLevel == 6
replace GradeLevel2 = "G07" if GradeLevel == 7
replace GradeLevel2 = "G08" if GradeLevel == 8
replace GradeLevel2 = "G10" if GradeLevel == 10
replace GradeLevel2 = "G11" if GradeLevel == 11
replace GradeLevel2 = "ALL" if GradeLevel == 13
drop GradeLevel
rename GradeLevel2 GradeLevel

drop if GradeLevel == "ALL"
drop if GradeLevel == "G10"
drop if GradeLevel == "G11"


// New Demographic/StudentGroup LABEL criteria (2024 update)
replace StudentGroup = "All Students" if StudentGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentGroup == "Race and Ethnicity"
// replace StudentGroup = "Ethnicity" if StudentGroup == "Ethnicity"
replace StudentGroup = "EL Status" if StudentGroup == "English-Language Fluency"
replace StudentGroup = "Economic Status" if StudentGroup == "Economic Status"
replace StudentGroup = "Gender" if StudentGroup == "Gender"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless Status"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military Status"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster Status"

// keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "EL Status" | StudentGroup == "Economic Status" | StudentGroup == "Gender"  // StudentGroup == "Ethnicity"

// StudentSubGroup Correct Labels 

// All Students Group
replace StudentSubGroup = "All Students" if StudentSubGroup == "All Students"

// RaceEth Group 
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian or Alaska Native"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black or African American"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentSubGroup = "White" if StudentSubGroup == "White"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic or Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or more races"

// Economic Status
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Economically disadvantaged"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not economically disadvantaged"

// Gender Group 
replace StudentSubGroup = "Male" if StudentSubGroup == "Male"
replace StudentSubGroup = "Female" if StudentSubGroup == "Female"

// El Status Group 
replace StudentSubGroup = "English Learner" if StudentSubGroup == "EL (English learner)"
replace StudentSubGroup = "Never EL" if StudentSubGroup == "EO (English only)"
replace StudentSubGroup = "Ever EL" if StudentSubGroup == "Ever–EL"
replace StudentSubGroup = "EL Exited" if StudentSubGroup == "RFEP (Reclassified fluent English proficient)"
replace StudentSubGroup = "Eng Proficient" if StudentSubGroup == "IFEP, RFEP, and EO (Fluent English proficient and English only)"

// Disability Status 
replace StudentSubGroup = "SWD" if StudentSubGroup == "Reported disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "No reported disabilities"

// Migrant Status
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migrant education"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Not migrant education"

// Homeless Status
replace StudentSubGroup = "Non-Homeless" if StudentSubGroup == "Not homeless"

// Foster Care 
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster youth"
replace StudentSubGroup = "Non-Foster Care" if StudentSubGroup == "Not foster youth"

// Military
replace StudentSubGroup = "Military" if StudentSubGroup == "Armed forces family member"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Not armed forces family member"


//r3 changed
// Generate Extra Level Variables 
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"



gen ProficiencyCriteria = "Levels 4 and 5"
gen ProficientOrAbove_count = "--" 
//r3 changed



gen ParticipationRate = StudentGroup_TotalTested/STARReportedEnrollmentCAPAEligib // CHANGED 2



gen seasch = StateAssignedSchID // CHANGED 2


// ENDED HERE
gen StudentSubGroup_TotalTested = StudentGroup_TotalTested
destring StudentGroup_TotalTested, replace force ignore(",")
replace StudentGroup_TotalTested = -1000000 if StudentGroup_TotalTested == . // CHANGED 2 
bys StudentGroup Subject GradeLevel DistName SchName: egen StudentGroup_TotalTested1 = total(StudentGroup_TotalTested)
replace StudentGroup_TotalTested1 =. if StudentGroup_TotalTested1 < 0
tostring StudentGroup_TotalTested1, replace
replace StudentGroup_TotalTested1 = "*" if StudentGroup_TotalTested1 == "."
drop StudentGroup_TotalTested
rename StudentGroup_TotalTested1 StudentGroup_TotalTested
// CHANGED


// NEW ADDED 

tostring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested1)
drop StudentSubGroup_TotalTested
rename StudentSubGroup_TotalTested1 StudentSubGroup_TotalTested

// NEW ADDED 



// NEW ADDED 

decode SchType, gen (SchType1)
drop SchType
rename SchType1 SchType

tostring StateAssignedDistID, gen (StateAssignedDistID1)
drop StateAssignedDistID
rename StateAssignedDistID1 StateAssignedDistID

decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel

// decode SchVirtual, gen (SchVirtual1)
// drop SchVirtual
// rename SchVirtual1 SchVirtual

// NEW ADDED


// NEW EDITED
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
// NEW EDITED


// New ADDED 2 
replace Lev1_percent = "-99999999" if Lev1_percent == "*"
replace Lev2_percent = "-99999999" if Lev2_percent == "*"
replace Lev3_percent = "-99999999" if Lev3_percent == "*"
replace Lev4_percent = "-99999999" if Lev4_percent == "*"
replace Lev5_percent = "-99999999" if Lev5_percent == "*"
//replace ProficientOrAbove_count = "-99999999" if ProficientOrAbove_count == "*"
replace ProficientOrAbove_percent = "-99999999" if ProficientOrAbove_percent == "*"
// replace ParticipationRate = "-99999999" if ParticipationRate == "*"
// New ADDED 2 


destring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent ParticipationRate, replace //r3 changed


// converting to decimal form from percentage form 
replace Lev1_percent = Lev1_percent/100 
replace Lev2_percent = Lev2_percent/100 
replace Lev3_percent = Lev3_percent/100 
replace Lev4_percent = Lev4_percent/100 
replace Lev5_percent = Lev5_percent/100 
replace ProficientOrAbove_percent = ProficientOrAbove_percent/100
// replace ParticipationRate = ParticipationRate/100 CHANGED 2 


// NEW ADDED 2
tostring Lev1_percent Lev2_percent Lev3_percent Lev4_percent Lev5_percent ProficientOrAbove_percent, replace force // r3 changed

replace Lev1_percent = "*" if Lev1_percent == "-999999.99"
replace Lev2_percent = "*" if Lev2_percent == "-999999.99"
replace Lev3_percent = "*" if Lev3_percent == "-999999.99"
replace Lev4_percent = "*" if Lev4_percent == "-999999.99"
replace Lev5_percent = "*" if Lev5_percent == "-999999.99"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "-999999.99"



replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel == 2

replace CountyName = "" if DataLevel == 1
replace CountyCode =.  if DataLevel == 1

replace NCESDistrictID = subinstr(NCESDistrictID, "6", "06", 1)
replace NCESDistrictID = subinstr(NCESDistrictID, "006", "06", 1)
// NEW ADDED 2


replace NCESSchoolID = "060964001019" if StateAssignedSchID == "6055974" //r3 changed

//NEW ADDED

// r3 change
replace NCESDistrictID = "0691006" if NCESDistrictID == "069106"
replace NCESDistrictID = "0602006" if NCESDistrictID == "060206"
replace NCESDistrictID = "0600006" if NCESDistrictID == "060006"
replace NCESDistrictID = "0600063" if NCESDistrictID == "060063"
replace NCESDistrictID = "0600064" if NCESDistrictID == "060064"
replace NCESDistrictID = "0600065" if NCESDistrictID == "060065"
// r3 change

replace NCESSchoolID = substr(NCESDistrictID, 1, 7) + substr(NCESSchoolID, 8, .) if NCESDistrictID != "00" & DataLevel == 3 //r3 changed

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
//NEW ADDED

drop if SchName=="" & DataLevel==3
save CA_AssmtData_2010_Stata, replace
export delimited CA_AssmtData_2010.csv, replace



// 2024 New feature loop 
global years 2010 2011 2012 2013 2015 2016 2017 2018 2019 2021 2022 2023

foreach a in $years {
	use CA_AssmtData_`a'_Stata, clear
	
	drop if StudentGroup==""
	
	decode DataLevel, gen(DataLevel1) 
	drop DataLevel
	rename DataLevel1 DataLevel
	
	gen ProficiencyCriteria1 = subinstr(ProficiencyCriteria," and ","-",.)
	drop ProficiencyCriteria
	rename ProficiencyCriteria1 ProficiencyCriteria
	
	keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
	
	sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
	
	save CA_AssmtData_`a'_Stata, replace
	export delimited CA_AssmtData_`a'.csv, replace
}

// 2024 New feature loop 
global years 2010 2011 2012 2013 

foreach a in $years {
	use CA_AssmtData_`a'_Stata, clear
	
	replace Flag_CutScoreChange_soc="N"
	
	save CA_AssmtData_`a'_Stata, replace
	export delimited CA_AssmtData_`a'.csv, replace
}


