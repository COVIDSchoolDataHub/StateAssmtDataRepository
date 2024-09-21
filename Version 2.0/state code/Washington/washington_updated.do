clear
set more off
set trace off

cd "/Volumes/T7/State Test Project/Washington"

global raw "/Volumes/T7/State Test Project/Washington/Original Data Files"
global output "/Volumes/T7/State Test Project/Washington/Output"
global NCESOLD "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES "/Volumes/T7/State Test Project/Washington/NCES"

* 2015 2016 2017 2018 2019 2021 2022 2023 2024
foreach year in 2024 {
	
use "${output}/WA_AssmtData_`year'_all", clear
	
local prevyear =`=`year'-1'

** Rename existing variables

if `year' == 2015 {
	
	tostring PercentMetTestedOnly, replace force
	tostring PercentNoScore, replace force
	rename SchoolYear SchYear
	rename OrganizationLevel DataLevel
	rename County CountyName
	rename DistrictCode State_leaid
	rename DistrictName DistName
	rename DistrictOrganizationId StateAssignedDistID
	rename SchoolCode seasch
	rename SchoolName SchName
	rename SchoolOrganizationid StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename StudentGroupType StudentGroup
	rename TestAdministrationgroup AssmtType
	rename TestAdministration AssmtName
	rename TestSubject Subject
	rename Countofstudentsexpectedtotestinc ExpectedCount
	rename CountMetStandard ProficientOrAbove_count
	rename PercentMetTestedOnly ProficientOrAbove_percent
// 	rename PercentLevel1 Lev1_percent
// 	rename PercentLevel2 Lev2_percent
// 	rename PercentLevel3 Lev3_percent
// 	rename PercentLevel4 Lev4_percent
	
	keep if AssmtType == "General"
}

if `year' == 2016 | `year' == 2017 {
	tostring PercentMetTestedOnly, replace force
	tostring PercentNoScore, replace force
	rename SchoolYear SchYear
	rename OrganizationLevel DataLevel
	rename County CountyName
	rename DistrictCode State_leaid
	rename DistrictName DistName
	rename DistrictOrganizationId StateAssignedDistID
	rename SchoolCode seasch
	rename SchoolName SchName
	rename SchoolOrganizationid StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename StudentGroupType StudentGroup
	rename TestAdministrationgroup AssmtType
	rename TestAdministration AssmtName
	rename TestSubject Subject
	rename Countofstudentsexpectedtotestinc ExpectedCount
	rename CountMetStandard ProficientOrAbove_count
	rename PercentMetTestedOnly ProficientOrAbove_percent
// 	rename PercentLevel1 Lev1_percent
// 	rename PercentLevel2 Lev2_percent
// 	rename PercentLevel3 Lev3_percent
// 	rename PercentLevel4 Lev4_percent
	drop CountofStudentsExpectedtoTest
	
	keep if AssmtType == "General"
}

if `year' == 2018 | `year' == 2019 {
	rename SchoolYear SchYear
	rename OrganizationLevel DataLevel
	rename County CountyName
	rename DistrictCode State_leaid
	rename DistrictName DistName
	rename DistrictOrganizationId StateAssignedDistID
	rename SchoolCode seasch
	rename SchoolName SchName
	rename SchoolOrganizationid StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename StudentGroupType StudentGroup
	rename TestAdministrationgroup AssmtType
	rename TestAdministration AssmtName
	rename TestSubject Subject
	rename Countofstudentsexpectedtotestinc ExpectedCount
	rename CountMetStandard ProficientOrAbove_count
	rename PercentMetTestedOnly ProficientOrAbove_percent
// 	rename PercentLevel1 Lev1_percent
// 	rename PercentLevel2 Lev2_percent
// 	rename PercentLevel3 Lev3_percent
// 	rename PercentLevel4 Lev4_percent
	drop CountofStudentsExpectedtoTest
	
	keep if AssmtType == "SBAC" | AssmtType == "WCAS"
}

if `year' == 2021 {
	rename SchoolYear SchYear
	rename OrganizationLevel DataLevel
	rename County CountyName
	rename DistrictCode State_leaid
	rename DistrictName DistName
	rename DistrictOrganizationId StateAssignedDistID
	rename SchoolCode seasch
	rename SchoolName SchName
	rename SchoolOrganizationid StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename StudentGroupType StudentGroup
	rename TestAdministration AssmtName
	rename TestSubject Subject
	rename DenominatorIncludingPPSuppressed ExpectedCount
	rename NumeratorSuppressed ProficientOrAbove_count
	rename PercentMetTestedOnly ProficientOrAbove_percent
// 	rename PercentLevel1 Lev1_percent
// 	rename PercentLevel2 Lev2_percent
// 	rename PercentLevel3 Lev3_percent
// 	rename PercentLevel4 Lev4_percent
	
	gen AssmtType=""
	
	keep if AssmtName == "SBAC" | AssmtName == "WCAS"
}

if `year' == 2022 {
	rename SchoolYear SchYear
	rename OrganizationLevel DataLevel
	rename County CountyName
	rename DistrictCode State_leaid
	rename DistrictName DistName
	rename DistrictOrganizationId StateAssignedDistID
	rename SchoolCode seasch
	rename SchoolName SchName
	rename SchoolOrganizationId StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename StudentGroupType StudentGroup
	rename TestAdministration AssmtName
	rename TestSubject Subject
	rename Countofstudentsexpectedtotestinc ExpectedCount
	rename CountMetStandard ProficientOrAbove_count
	rename PercentMetTestedOnly ProficientOrAbove_percent
// 	rename PercentLevel1 Lev1_percent
// 	rename PercentLevel2 Lev2_percent
// 	rename PercentLevel3 Lev3_percent
// 	rename PercentLevel4 Lev4_percent
	
	gen AssmtType=""
	
	keep if AssmtName == "SBAC" | AssmtName == "WCAS"
}

if `year' == 2023 {
	rename SchoolYear SchYear
	rename OrganizationLevel DataLevel
	rename County CountyName
	rename DistrictCode State_leaid
	rename DistrictName DistName
	rename DistrictOrganizationId StateAssignedDistID
	rename SchoolCode seasch
	rename SchoolName SchName
	rename SchoolOrganizationId StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename StudentGroupType StudentGroup
	rename TestAdministration AssmtName
	rename TestSubject Subject
	rename CountofStudentsExpectedtoTestinc ExpectedCount
	rename CountMetStandard ProficientOrAbove_count
	rename PercentMetTestedOnly ProficientOrAbove_percent
// 	rename PercentLevel1 Lev1_percent
// 	rename PercentLevel2 Lev2_percent
// 	rename PercentLevel3 Lev3_percent
// 	rename PercentLevel4 Lev4_percent
	rename PercentParticipation ParticipationRate
	drop CountofStudentsExpectedtoTest
	
	gen AssmtType=""
	
	rename DAT Suppression
	
	keep if AssmtName == "SBAC" | AssmtName == "WCAS"
}

if `year' == 2024 {
	rename SchoolYear SchYear
	rename OrganizationLevel DataLevel
	rename County CountyName
	rename DistrictCode State_leaid
	rename DistrictName DistName
	rename DistrictOrganizationId StateAssignedDistID
	rename SchoolCode seasch
	rename SchoolName SchName
	rename SchoolOrganizationid StateAssignedSchID
	rename StudentGroup StudentSubGroup
	rename StudentGroupType StudentGroup
	rename TestAdministration AssmtName
	rename TestSubject Subject
	rename CountofStudentsExpectedtoTestinc ExpectedCount
	rename PercentMetTestedOnly ProficientOrAbove_percent
// 	rename PercentLevel1 Lev1_percent
// 	rename PercentLevel2 Lev2_percent
// 	rename PercentLevel3 Lev3_percent
// 	rename PercentLevel4 Lev4_percent
	rename PercentParticipation ParticipationRate
	rename DAT Suppression
	drop CountofStudentsExpectedtoTest CountConsistentGradeLevelKnowled CountFoundationalGradeLevelKnowl CurrentSchoolType DataAsOf ESDOrganizationID ESDName PercentConsistentGradeLevelKnowl PercentFoundationalGradeLevelKno TestAdministrationgroup
	gen PercentMetStandard = ""
	keep if AssmtName == "SBAC" | AssmtName == "WCAS"
	gen AssmtType = ""
}

** Dropping entries
	
drop if DataLevel == "ESD"
drop if strpos(GradeLevel, "All") | strpos(GradeLevel, "11") | strpos(GradeLevel, "10") | GradeLevel == "G011"

if `year' == 2015 {
	drop if SchName == "Lummi Nation School" | SchName == "Paschal Sherman" | SchName == "Wa He Lut Indian School(Closed)" | SchName == "Chief Leschi Schools(Closed)" | SchName == "Muckleshoot Tribal School" | SchName == "Quileute Tribal School(Closed)" | SchName == "WSD - Yakama Nation(Closed)"
}

if `year' == 2016 {
	drop if SchName == "Lummi Nation School" | SchName == "Paschal Sherman" | SchName == "Wa He Lut Indian School(Closed)" | SchName == "Chief Leschi Schools(Closed)" | SchName == "Muckleshoot Tribal School" | SchName == "Quileute Tribal School(Closed)"
}

if `year' == 2017 {
	drop if SchName == "Paschal Sherman" | SchName == "Chief Leschi Schools(Closed)" | SchName == "Wa He Lut Indian School(Closed)" | SchName == "Lummi Nation School" | SchName == "Quileute Tribal School" | SchName == "Muckleshoot Tribal School" 
}

if `year' == 2018 {
	drop if SchName == "Paschal Sherman (Closed after 2020-2021 school year)" | SchName == "Chief Leschi Schools(Closed) (Closed after 2020-2021 school year)" | SchName == "Wa He Lut Indian School (Closed after 2020-2021 school year)" | SchName == "Lummi Nation School (Closed after 2020-2021 school year)" | SchName == "Quileute Tribal School (Closed after 2020-2021 school year)" | SchName == "Muckleshoot Tribal School (Closed after 2020-2021 school year)"
}

if `year' == 2019 {
	drop if SchName == "Chief Leschi Schools (Closed after 2020-2021 school year)" | SchName == "Paschal Sherman (Closed after 2020-2021 school year)" | SchName == "Wa He Lut Indian School (Closed after 2020-2021 school year)" | SchName == "Lummi Nation School (Closed after 2020-2021 school year)" | SchName == "Quileute Tribal School (Closed after 2020-2021 school year)" | SchName == "Muckleshoot Tribal School (Closed after 2020-2021 school year)"
}

if `year' >= 2021 {
	drop if SchName == "Chief Leschi Schools" | SchName == "Paschal Sherman" | SchName == "Wa He Lut Indian School" | SchName == "Lummi Nation School" | SchName == "Quileute Tribal School" | SchName == "Muckleshoot Tribal School" | SchName == "Paschal Sherman(Closed)"
}

drop if Suppression == "No Students" // StudentSubGroup_TotalTested == 0

** Changing DataLevel

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

** Replacing variables

replace SchName = "All Schools" if DataLevel != 3
replace DistName = "All Districts" if DataLevel == 1
replace CountyName = "" if DataLevel == 1

replace Subject = "ela" if Subject == "English Language Arts" | Subject == "ELA" 
replace Subject = "math" if Subject == "Math" 
replace Subject = "sci" if Subject == "Science"

if `year' == 2021 {
	destring GradeLevel, replace
	replace GradeLevel = GradeLevel - 1
	tostring GradeLevel, replace

	replace GradeLevel = "G0" + GradeLevel 
}

if `year' == 2018 | `year' == 2019 | `year' == 2022 | `year' == 2023 | `year' == 2024 {
	replace GradeLevel = "G" + GradeLevel 
}

if `year' <= 2017 {
	replace GradeLevel = "G03" if GradeLevel == "3rd Grade"
	replace GradeLevel = "G04" if GradeLevel == "4th Grade"
	replace GradeLevel = "G05" if GradeLevel == "5th Grade"
	replace GradeLevel = "G06" if GradeLevel == "6th Grade"
	replace GradeLevel = "G07" if GradeLevel == "7th Grade"
	replace GradeLevel = "G08" if GradeLevel == "8th Grade"
}

if `year' >= 2018 {
	replace StudentGroup = "All Students" if StudentGroup == "All"
	replace StudentGroup = "EL Status" if StudentGroup == "ELL"
	replace StudentGroup = "Economic Status" if StudentGroup == "FRL"
	replace StudentGroup = "RaceEth" if StudentGroup == "Race"
	replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster"
	replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
	replace StudentGroup = "Disability Status" if StudentGroup == "SWD"
	replace StudentGroup = "Military Connected Status" if StudentGroup == "Military"
	replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "homeless"
}

replace StudentGroup = "All Students" if StudentGroup == "All"
replace StudentGroup = "EL Status" if StudentGroup == "English Language Learners"
replace StudentGroup = "Economic Status" if StudentGroup == "Low Income"
replace StudentGroup = "RaceEth" if StudentGroup == "Race"
replace StudentGroup = "Foster Care Status" if StudentGroup == "Foster"
replace StudentGroup = "Migrant Status" if StudentGroup == "Migrant"
replace StudentGroup = "Disability Status" if StudentGroup == "Students with Disabilities"
replace StudentGroup = "Military Connected Status" if StudentGroup == "Military"
replace StudentGroup = "Homeless Enrolled Status" if StudentGroup == "Homeless"

drop if StudentGroup == "Section 504" | StudentGroup == "s504"

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/ Alaskan Native"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black/ African American"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learners"
replace StudentSubGroup = "Gender X" if StudentSubGroup == "Gender X"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/ Latino of any race(s)"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Low-Income"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/ Other Pacific Islander"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Non-English Language Learners"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Non-Low Income"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races" | StudentSubGroup == "TwoorMoreRaces" | StudentSubGroup == "Two Or More Races"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"
replace StudentSubGroup = "Non-SWD" if StudentSubGroup == "Students without Disabilities"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military Parent"
replace StudentSubGroup = "Non-Military" if StudentSubGroup == "Non Military Parent"
replace StudentSubGroup = "Non-Migrant" if StudentSubGroup == "Non Migrant"


** Reformatting the percentage signs

if `year' <= 2017 {
	
	foreach v of varlist PercentLevel* PercentNoScore {
	replace `v' = subinstr(`v', "%", "",.) 
	replace `v' = "*" if `v' == "NULL"
	destring `v', replace ignore("*")
	replace `v' = `v' / 100
	tostring `v', replace force
	replace `v' = "*" if `v' == "."
}

tostring PercentNoScore, replace force

}


** make participationrate (ONLY FOR PRE-2023)

if `year' < 2023 {
	replace PercentNoScore = "*" if PercentNoScore == "NULL"
	destring PercentNoScore, replace ignore(*)
	gen ParticipationRate = 1 - PercentNoScore
	tostring ParticipationRate, replace force format("%9.3g")
	replace ParticipationRate = "*" if ParticipationRate == "."
}
replace ParticipationRate = "*" if ParticipationRate == "NULL"
replace ParticipationRate = string(real(ParticipationRate), "%9.3g") if !missing(real(ParticipationRate))

replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_percent = string(real(ProficientOrAbove_percent), "%9.3g") if !missing(real(ProficientOrAbove_percent))


//Deriving Level Counts & Percents based on ParticipationRate
//Note: Currently Level percents are based on the ExpectedCount (basically enrollment), rather than the number of students tested. Process for deriving level counts & percents is as follows:

// 1. Derive Level Counts as PercentLevel * Expected Count
// 2. Derive StudentSubGroup_TotalTested as ParticipationRate * ExpectedCount
// 3. Derive Lev*_percent as Lev*_count/StudentSubGroup_TotalTested

destring ExpectedCount, replace force

//1. Deriving Level Counts
forvalues n = 1/4 {
	gen Lev`n'_count = string(round(real(PercentLevel`n')*ExpectedCount)) if !missing(real(PercentLevel`n')) & !missing(ExpectedCount)
	replace Lev`n'_count = "*" if missing(Lev`n'_count)
}

//2. Derive StudentSubGroup_TotalTested
gen StudentSubGroup_TotalTested = string(round(real(ParticipationRate) * ExpectedCount)) if !missing(real(ParticipationRate)) & !missing(ExpectedCount)
replace StudentSubGroup_TotalTested = "*" if missing(StudentSubGroup_TotalTested)

//3. Deriving Level Percents
foreach count of varlist Lev*_count {
	local percent = subinstr("`count'", "count", "percent",.)
	gen `percent' = string(real(`count')/real(StudentSubGroup_TotalTested), "%9.3g") if !missing(real(`count')) & !missing(real(StudentSubGroup_TotalTested))
	replace `percent' = "*" if missing(`percent')
}

//Dropping Extra Variables
drop PercentLevel* PercentMetStandard

//Generating ProficientOrAbove_count for 2024
if `year' == 2024 {
	gen ProficientOrAbove_count = string(real(Lev3_count) + real(Lev4_count)) if !missing(real(Lev3_count)) & !missing(real(Lev4_count))
	replace ProficientOrAbove_count = "*" if missing(ProficientOrAbove_count)
}


//Converting ProficientOrAbove_count to string
tostring ProficientOrAbove_count, replace
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."



** Merging with NCES

if `year' == 2015 | `year' == 2016 {
	gen leadingzero = 1 if State_leaid < 10000
	tostring State_leaid, replace
	replace State_leaid = "0" + State_leaid if leadingzero == 1
	drop leadingzero

	merge m:1 State_leaid using "${NCES}/NCES_`prevyear'_District.dta"

	drop if _merge == 2
	drop _merge

	tostring seasch, replace

	merge m:1 seasch using "${NCES}/NCES_`prevyear'_School.dta"

	drop if _merge == 2
	drop _merge
}

if `year' == 2017 | `year' == 2018 | `year' == 2019 | `year' == 2022 | `year' == 2023 {
	gen leadingzero = 1 if State_leaid < 10000
	tostring State_leaid, replace
	replace State_leaid = "0" + State_leaid if leadingzero == 1
	drop leadingzero
	replace State_leaid = "WA-" + State_leaid if DataLevel != 1

	merge m:1 State_leaid using "${NCES}/NCES_`prevyear'_District.dta"

	drop if _merge == 2
	drop _merge

	tostring seasch, replace
	replace seasch = State_leaid + "-" + seasch if DataLevel == 3
	replace seasch = subinstr(seasch,"WA-","",.) if DataLevel == 3
	

	merge m:1 seasch using "${NCES}/NCES_`prevyear'_School.dta", keepusing(SchLevel SchVirtual NCESSchoolID SchType)
	replace SchVirtual = "Missing/not reported" if NCESSchoolID == "530285003625" & `year' == 2017
}

if `year' == 2024 {
	gen leadingzero = 1 if real(State_leaid) < 10000 & !missing(real(State_leaid))
	tostring State_leaid, replace
	replace State_leaid = "0" + State_leaid if leadingzero == 1
	drop leadingzero
	replace State_leaid = "WA-" + State_leaid if DataLevel != 1

	merge m:1 State_leaid using "${NCES}/NCES_2022_District.dta"

	drop if _merge == 2
	drop _merge

	tostring seasch, replace
	replace seasch = State_leaid + "-" + seasch if DataLevel == 3
	replace seasch = subinstr(seasch,"WA-","",.) if DataLevel == 3
	

	merge m:1 seasch using "${NCES}/NCES_2022_School.dta", keepusing(SchLevel SchVirtual NCESSchoolID SchType)
	replace SchVirtual = "Missing/not reported" if NCESSchoolID == "530285003625" & `year' == 2017
	
	merge m:1 SchName using "WA_Unmerged_2024", update nogen
}

if `year' == 2021 {
	gen leadingzero = 1 if State_leaid < 10000
	tostring State_leaid, replace
	replace State_leaid = "0" + State_leaid if leadingzero == 1
	drop leadingzero
	replace State_leaid = "WA-" + State_leaid if DataLevel != 1

	merge m:1 State_leaid using "${NCES}/NCES_2021_District.dta"

	drop if _merge == 2
	drop _merge

	tostring seasch, replace
	replace seasch = State_leaid + "-" + seasch if DataLevel == 3
	replace seasch = subinstr(seasch,"WA-","",.) if DataLevel == 3
	

	merge m:1 seasch using "${NCES}/NCES_2021_School.dta", keepusing(SchLevel SchVirtual NCESSchoolID SchType)
	replace SchVirtual = "Missing/not reported" if NCESSchoolID == "530285003625" & `year' == 2017
}

replace StateAbbrev = "WA" 
replace State = "Washington"
replace StateFips = 53 
replace State_leaid = "" if DataLevel == 1
replace seasch = "" if DataLevel != 3

** Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
gen Flag_CutScoreChange_soc = "Not applicable"

replace Flag_CutScoreChange_sci = "N" if `year' >= 2018

if `year' == 2015 {
	replace Flag_AssmtNameChange = "Y"
	replace Flag_CutScoreChange_ELA = "Y"
	replace Flag_CutScoreChange_math = "Y"
}

if `year' == 2018 {
	replace Flag_AssmtNameChange = "N" if Subject == "math"
	replace Flag_AssmtNameChange = "N" if Subject == "ela"
	replace Flag_AssmtNameChange = "Y" if Subject == "sci"
	replace Flag_CutScoreChange_ELA = "N"
	replace Flag_CutScoreChange_math = "N"
	replace Flag_CutScoreChange_sci = "Y"
}

replace SchYear = "`prevyear'"+ "-" + substr("`year'",-2,2)


** Unmerged data
replace DistType = "Charter agency" if DistName == "Why Not You Academy"
replace NCESDistrictID = "5300349" if DistName == "Why Not You Academy"
replace DistLocale = "Suburb, large" if DistName == "Why Not You Academy"
replace DistCharter = "Yes" if DistName == "Why Not You Academy"
replace CountyCode = "53033" if DistName == "Why Not You Academy"

replace DistType = "Charter agency" if DistName == "Pinnacles Prep Charter School"
replace NCESDistrictID = "5300352" if DistName == "Pinnacles Prep Charter School"
replace DistLocale = "City, small" if DistName == "Pinnacles Prep Charter School"
replace DistCharter = "Yes" if DistName == "Pinnacles Prep Charter School"
replace CountyCode = "53007" if DistName == "Pinnacles Prep Charter School"

replace DistType = "Charter agency" if DistName == "Pullman Community Montessori"
replace NCESDistrictID = "5300355" if DistName == "Pullman Community Montessori"
replace DistLocale = "Town, distant" if DistName == "Pullman Community Montessori"
replace DistCharter = "Yes" if DistName == "Pullman Community Montessori"
replace CountyCode = "53075" if DistName == "Pullman Community Montessori"

replace SchType = "Regular school" if SchName == "Cascade Public Schools"
replace NCESSchoolID = "530034903783" if SchName == "Cascade Public Schools"
replace SchLevel = "High" if SchName == "Cascade Public Schools"
replace SchVirtual = "No" if SchName == "Cascade Public Schools"

replace SchType = "Regular school" if SchName == "Pinnacles Prep Charter School"
replace NCESSchoolID = "530035203807" if SchName == "Pinnacles Prep Charter School"
replace SchLevel = "Middle" if SchName == "Pinnacles Prep Charter School"
replace SchVirtual = "No" if SchName == "Pinnacles Prep Charter School"

replace SchType = "Regular school" if SchName == "Pullman Community Montessori"
replace NCESSchoolID = "530035503780" if SchName == "Pullman Community Montessori"
replace SchLevel = "Other" if SchName == "Pullman Community Montessori"
replace SchVirtual = "No" if SchName == "Pullman Community Montessori"

replace SchType = "Regular school" if SchName == "Bellevue Digital Discovery"
replace NCESSchoolID = "530039003883" if SchName == "Bellevue Digital Discovery"

replace SchType = "Regular school" if SchName == "Desert Sky Elementary"
replace NCESSchoolID = "530732003901" if SchName == "Desert Sky Elementary"

replace SchType = "Regular school" if SchName == "Eagle Virtual Sky Academy"
replace NCESSchoolID = "530249003884" if SchName == "Eagle Virtual Sky Academy"

replace SchType = "Regular school" if SchName == "Ida Nason Aronica Elementary"
replace NCESSchoolID = "530246003887" if SchName == "Ida Nason Aronica Elementary"

replace SchType = "Other/alternative school" if SchName == "Kent Virtual Academy"
replace NCESSchoolID = "530396003898" if SchName == "Kent Virtual Academy"

replace SchType = "Regular school" if SchName == "Kiona-Benton City Elementary"
replace NCESSchoolID = "530402003888" if SchName == "Kiona-Benton City Elementary"

replace SchType = "Regular school" if SchName == "Tacoma Online Elementary School"
replace NCESSchoolID = "530870003889" if SchName == "Tacoma Online Elementary School"

replace SchType = "Regular school" if SchName == "Tacoma Online Middle School"
replace NCESSchoolID = "530870003890" if SchName == "Tacoma Online Middle School"

replace SchType = "Special education school" if SchName == "Vancouver Intensive Communications Center"
replace NCESSchoolID = "530927003885" if SchName == "Vancouver Intensive Communications Center"

replace SchType = "Other/alternative school" if SchName == "Vancouver Success Academy"
replace NCESSchoolID = "530927003882" if SchName == "Vancouver Success Academy"

replace SchType = "Regular school" if SchName == "Wapato Online Academy 6-8"
replace NCESSchoolID = "530948003893" if SchName == "Wapato Online Academy 6-8"

replace SchType = "Regular school" if SchName == "Willow Crest Elementary"
replace NCESSchoolID = "530030003886" if SchName == "Willow Crest Elementary"

if `year' == 2015 | `year' == 2016 | `year' == 2017 {
		replace DistName = "Nespelem School District" if NCESDistrictID=="5305550"
		replace DistName = "Seattle School District No. 1" if NCESDistrictID=="5307710"
		replace DistName = "WA State Center for Childhood Deafness and Hearing Loss" if NCESDistrictID=="5300015"
	}
	
	replace DistName = "Cashmere School District" if NCESDistrictID=="5300960"
	
	replace AssmtType = "Regular"
	
	drop if StudentGroup == "" & missing(DataLevel)
	
if `year' == 2022 | `year' == 2023 {
replace StateAssignedDistID = "" if StateAssignedDistID == "NULL" & DataLevel == 1
replace StateAssignedSchID = "" if StateAssignedSchID == "NULL" & DataLevel != 3
}

** County name edits


replace CountyName = "Clark" if CountyCode == "53011"
replace CountyName = "Douglas" if CountyCode == "53017"
replace CountyName = "Franklin" if CountyCode == "53021"
replace CountyName = "Island" if CountyCode == "53029"
replace CountyName = "Kitsap" if CountyCode == "53035"
replace CountyName = "Snohomish" if CountyCode == "53061"

if `year' == 2018 {
	replace SchVirtual = "No" if NCESSchoolID == "530285003625"
}


** Final drops

if `year' == 2021 {
	drop if GradeLevel == "G011"
}

//Missing & Indicator Variables
gen Lev5_count = ""
gen Lev5_percent = ""
gen AvgScaleScore = "--"
gen ProficiencyCriteria = "Levels 3-4"

//Fixing Some Variables
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "NULL"
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "NULL"

//StudentGroup_TotalTested
tostring StateAssigned*, replace
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel !=3
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == 1
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel !=3
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//Deriving ProficientOrAbove_count if possible
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent)*real(StudentSubGroup_TotalTested))) if !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested)) & missing(real(ProficientOrAbove_count))

//Response to Review

if `year' >= 2018 drop if SchLevel == "Prekindergarten"

//Replacing ProficientOrAbove_count with ProficientOrAbove_percent*StudentSubGroup_TotalTested
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested)))
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

//ParticipationRate
replace ParticipationRate = "--" if missing(ParticipationRate)

//AssmtType
replace AssmtType = "Regular"

//Final Cleaning

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
	
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${output}/WA_AssmtData_`year'.dta", replace

export delimited using "${output}/csv/WA_AssmtData_`year'.csv", replace
}

