*******************************************************
* ARIZONA

* File name: 09_AzMERIT_clean_2016
* Last update: 2/20/2025

*******************************************************
* Notes

	* This do file cleans AZ's 2016 data and merges with NCES 2015 and EDFacts 2016.
	* Both the non-derivation and derivation outputs are created.  
	* The non-derivation output is created BEFORE the EDFacts 2016 data is merged.
		
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////
clear

************************************************************************************
* Importing data and renaming variables
************************************************************************************
** 2016 ELA and Math
//SCHOOLS
import excel "${AzMERIT}/AZ_OriginalData_2016_ela_math.xlsx", sheet("SCHOOLS") firstrow clear

** Rename existing variables
rename DistrictCharterHolderName DistName
rename DistrictCharterHolderEntityI StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName
rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel


rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

rename ContentArea Subject

drop CharterSchool

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${AzMERIT}/AZ_AssmtData_school_2016.dta", replace

************************************************************************************
//DISTRICTS
import excel "${AzMERIT}/AZ_OriginalData_2016_ela_math.xlsx", sheet("DISTRICTS_CHARTER HOLDERS") firstrow clear 

** Rename existing variables
rename DistrictCharterHolderName DistName
rename DistrictCharterHolderEntityI StateAssignedDistID

rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel

rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

rename ContentArea Subject

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${AzMERIT}/AZ_AssmtData_district_2016.dta", replace

************************************************************************************
//STATE
import excel "${AzMERIT}/AZ_OriginalData_2016_ela_math.xlsx", sheet("STATE") firstrow clear

** Rename existing variables
rename SubgroupEthnicity StudentSubGroup
rename TestLevel GradeLevel

rename NumberTested StudentSubGroup_TotalTested
rename PercentPerformanceLevel1 Lev1_percent
rename PercentPerformanceLevel2 Lev2_percent
rename PercentPerformanceLevel3 Lev3_percent
rename PercentPerformanceLevel4 Lev4_percent
rename PercentPassing ProficientOrAbove_percent

rename ContentArea Subject

** Generate grade observations from TestLevel variable
replace GradeLevel = "G03" if strpos(GradeLevel, "Grade 3")>0
replace GradeLevel = "G04" if strpos(GradeLevel, "Grade 4")>0
replace GradeLevel = "G05" if strpos(GradeLevel, "Grade 5")>0
replace GradeLevel = "G06" if strpos(GradeLevel, "Grade 6")>0
replace GradeLevel = "G07" if strpos(GradeLevel, "Grade 7")>0
replace GradeLevel = "G08" if strpos(GradeLevel, "Grade 8")>0

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08", "G38")

save "${AzMERIT}/AZ_AssmtData_state_2016.dta", replace

************************************************************************************
** 2016 Science
//SCHOOLS
import excel "${AzMERIT}/AZ_OriginalData_2016_sci.xlsx", sheet("Schools") firstrow clear

** Rename existing variables
rename LocalEducationAgencyLEANam DistName
rename LEAEntityID StateAssignedDistID
rename SchoolEntityID StateAssignedSchID
rename SchoolName SchName

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

drop CharterSchool

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedSchID, generate(seasch)
tostring StateAssignedDistID, replace
tostring StateAssignedSchID, replace

save "${AzMERIT}/AZ_AssmtData_2016_school_sci.dta", replace

************************************************************************************
//DISTRICTS
import excel "${AzMERIT}/AZ_OriginalData_2016_sci.xlsx", sheet("Districts-Charter Holders") firstrow clear

** Rename existing variables
rename LocalEducationAgencyLEANam DistName
rename LEAEntityID StateAssignedDistID

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring StateAssignedDistID, generate(State_leaid)
tostring StateAssignedDistID, replace

save "${AzMERIT}/AZ_AssmtData_2016_district_sci.dta", replace

************************************************************************************
//STATE
import excel "${AzMERIT}/AZ_OriginalData_2016_sci.xlsx", sheet("State") firstrow clear

rename GradeCohort GradeLevel

rename SciencePercentFallsFarBelow Lev1_percent
rename SciencePercentApproaches Lev2_percent
rename SciencePercentMeets Lev3_percent
rename SciencePercentExceeds Lev4_percent
rename SciencePercentPassing ProficientOrAbove_percent
rename ScienceMeanScaleScore AvgScaleScore

gen Subject="sci"

** Generate grade observations from TestLevel variable
tostring GradeLevel, replace
replace GradeLevel = "G04" if GradeLevel=="4"
replace GradeLevel = "G08" if GradeLevel=="8"

keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")

tostring Lev1_percent, replace force
tostring Lev2_percent, replace force
tostring Lev3_percent, replace force
tostring Lev4_percent, replace force
tostring AvgScaleScore, replace force

tostring ProficientOrAbove_percent, replace

save "${AzMERIT}/AZ_AssmtData_2016_state_sci.dta", replace

************************************************************************************
*Appending and merging with NCES data
************************************************************************************
//SCHOOLS - ELA and Math, Sci

use "${AzMERIT}/AZ_AssmtData_school_2016.dta", clear
append using "${AzMERIT}/AZ_AssmtData_2016_school_sci.dta"

sort StateAssignedSchID GradeLevel Subject
tostring StateAssignedDistID, replace

merge m:1 State_leaid using "${NCES_AZ}/NCES_2015_District_AZ.dta", force
drop if _merge == 2
drop _merge

merge m:1 seasch NCESDistrictID using "${NCES_AZ}/NCES_2015_School_AZ.dta", force
drop if _merge == 2
drop _merge

sort NCESSchoolID GradeLevel Subject
gen DataLevel="School"

save "${Temp}/AZ_AssmtData_school_2016.dta", replace

//DISTRICTS - ELA and Math, Sci
use "${AzMERIT}/AZ_AssmtData_district_2016.dta", clear
append using "${AzMERIT}/AZ_AssmtData_2016_district_sci.dta"

merge m:1 State_leaid using "${NCES_AZ}/NCES_2015_District_AZ.dta"
drop if _merge == 2
drop _merge

sort NCESDistrictID GradeLevel Subject
gen DataLevel="District"

save "${Temp}/AZ_AssmtData_district_2016.dta", replace
 
//STATE - ELA and Math, Sci - Appending only 
use "${AzMERIT}/AZ_AssmtData_state_2016.dta", clear

append using "${AzMERIT}/AZ_AssmtData_2016_state_sci.dta"

keep if inlist(SchoolType, "All", "")
drop SchoolType
sort GradeLevel Subject

gen DataLevel="State"

save "${Temp}/AZ_AssmtData_state_2016.dta", replace

** Append all files 
append using "${Temp}/AZ_AssmtData_school_2016.dta" "${Temp}/AZ_AssmtData_district_2016.dta"

gen SchYear="2015-16"

gen StudentGroup=""
drop State
gen State="Arizona"
drop StateAbbrev
gen StateAbbrev = "AZ"
drop StateFips
gen StateFips = 4

save "${Temp}/AZ_AssmtData_2016.dta", replace

** Generating missing variables
gen AssmtName="AzMERIT"
gen Flag_AssmtNameChange="N"
gen AssmtType="Regular and alt"

gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_soc="Not applicable"
gen Flag_CutScoreChange_sci = "N"

gen Lev5_percent=""

gen ProficiencyCriteria="Levels 3-4"
gen ParticipationRate="--"

//District wide
replace SchName = "All Schools" if DataLevel == "District" | DataLevel == "State"
replace DistName = "All Districts" if DataLevel == "State"
replace SchName = strtrim(SchName)
replace SchName = stritrim(SchName)
replace DistName = strtrim(DistName)
replace DistName = stritrim(DistName)

//Fixing types
tostring StateAssignedSchID, replace
replace StateAssignedSchID = "" if StateAssignedSchID == "."
decode SchLevel, generate(new)
drop SchLevel
rename new SchLevel
decode SchType, generate(new)
drop SchType
rename new SchType
decode SchVirtual, generate(new)
drop SchVirtual
rename new SchVirtual

** Replace missing values

foreach v of varlist StudentSubGroup_TotalTested AvgScaleScore ParticipationRate {
	tostring `v', replace
	replace `v' = "--" if `v' == "" | `v' == "."
}
	
foreach u of varlist Lev1_percent Lev2_percent Lev3_percent Lev4_percent ProficientOrAbove_percent {
	destring `u', replace force
	replace `u' = `u' / 100
	tostring `u', replace format("%9.2g") force
	replace `u' = "*" if `u' == "."
}

replace StudentGroup="All Students" if StudentSubGroup=="All Students"
replace StudentGroup="RaceEth" if inlist(StudentSubGroup, "American Indian/Alaska Native","Asian", "Native Hawaiian/Other Pacific", "Two or More Races", "White", "African American", "Hispanic/Latino")
replace StudentGroup="EL Status" if inlist(StudentSubGroup, "Limited English Proficient")
replace StudentGroup="Economic Status" if inlist(StudentSubGroup, "Economically Disadvantaged")
replace StudentGroup="Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup="Disability Status" if StudentSubGroup == "Students with Disabilities"
replace StudentGroup="Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup="Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "All Students" if Subject == "sci"
replace StudentSubGroup = "All Students" if Subject == "sci"
drop if StudentGroup == "" & StudentSubGroup != ""

replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian/Other Pacific"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Limited English Proficient"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Students with Disabilities"

replace Subject="ela" if Subject=="English Language Arts"
replace Subject="math" if Subject=="Math"
replace Subject="sci" if Subject=="Science"
replace AssmtName = "AIMS Science and AIMS A" if Subject=="sci"

replace CountyName = strproper(CountyName)

//sort
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
drop DataLevel 
rename DataLevel_n DataLevel 
replace SchVirtual = "Missing/not reported" if SchVirtual == "" & DataLevel == 3
replace SchLevel = "Missing/not reported" if SchLevel == "" & DataLevel == 3

save "${Temp}/AZ_AssmtData_2016.dta", replace //This file is used for derived output. 

************************************************************************************
*Calculations*
************************************************************************************
foreach x of numlist 1/4 {
    destring Lev`x'_percent, gen(Lev`x'_percent2) force
}

replace Lev1_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) if missing(real(Lev1_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev2_percent))
replace Lev2_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) if missing(real(Lev2_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent))
replace Lev3_percent2 = real(ProficientOrAbove_percent) - real(Lev4_percent) if missing(real(Lev3_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev4_percent))
replace Lev4_percent2 = real(ProficientOrAbove_percent) - real(Lev3_percent) if missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent))

foreach x of numlist 1/4 {
	replace Lev`x'_percent2 = 0 if Lev`x'_percent2 < 0 & Lev`x'_percent2 != .
	replace Lev`x'_percent = string(Lev`x'_percent2, "%9.2g") if missing(real(Lev`x'_percent)) & Lev`x'_percent2 != .
	replace Lev`x'_percent = "0" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") == 0
	replace Lev`x'_percent = "0-0.02" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") > 0
}

************************************************************************************
*Creating variables for non-derivation output*
************************************************************************************
gen Lev5_count = ""
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen StudentGroup_TotalTested = "--"
gen  ProficientOrAbove_count = "--"

//Final Cleaning
replace DistName = "Fowler Elementary District" if NCESDistrictID == "403060"

duplicates drop

foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

// *Exporting into a separate folder Output for Stanford - without derivations*
save "${Output_ND}/AZ_AssmtData2016_NoDev", replace //If .dta format needed.
export delimited "${Output_ND}/AZ_AssmtData2016_NoDev", replace 

***********************************************
*File splits here for derivations/ EDFacts data
***********************************************
** Merging with EDFacts Datasets
use "${Temp}/AZ_AssmtData_2016.dta", clear

merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_AZ}/edfactscount2015districtAZ.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop stnam-_merge

destring NCESDistrictID, replace
merge m:1 DataLevel NCESDistrictID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_AZ}/edfactspart2015districtAZ.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop stnam-_merge

tostring NCESDistrictID, replace 
merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_AZ}/edfactscount2015schoolAZ.dta"
tostring Count, replace
replace StudentSubGroup_TotalTested = Count if Count != "."
drop if _merge == 2
drop stnam-_merge

destring NCESDistrictID, replace
destring NCESSchoolID, replace
merge m:1 DataLevel NCESSchoolID StudentGroup StudentSubGroup GradeLevel Subject using "${EDFacts_AZ}/edfactspart2015schoolAZ.dta"
replace ParticipationRate = Participation if Participation != ""
drop if _merge == 2
drop stnam-_merge
tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format("%18.0f")
replace NCESDistrictID = "" if NCESDistrictID == "."
replace NCESSchoolID = "" if NCESSchoolID == "."

sort DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel StudentGroup StudentSubGroup
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID AssmtName Subject GradeLevel)
gen flag = 1 if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup_TotalTested[_n-1] != "*" & StudentSubGroup == StudentSubGroup[_n-1] & uniquegrp == uniquegrp[_n-1]
replace flag = 1 if StudentSubGroup_TotalTested == "*" & ProficientOrAbove_percent == "*" & StudentSubGroup_TotalTested[_n+1] != "*" & StudentSubGroup == StudentSubGroup[_n+1] & uniquegrp == uniquegrp[_n+1]
drop if flag == 1
gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested) & StudentSubGroup != "All Students"
drop uniquegrp flag

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) i(*-)
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = sum(StudentSubGroup_TotalTested2) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = sum(StudentSubGroup_TotalTested2) if StudentGroup == "Gender"

gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

gen x = 1 if missing(real(StudentSubGroup_TotalTested))
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject StudentGroup: egen flag = sum(x)

replace StudentSubGroup_TotalTested2 = max - RaceEth if StudentGroup == "RaceEth" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag <= 1
replace StudentSubGroup_TotalTested2 = max - Gender if StudentGroup == "Gender" & max != 0 & missing(real(StudentSubGroup_TotalTested)) & flag <= 1

replace StudentSubGroup_TotalTested = string(StudentSubGroup_TotalTested2) if missing(real(StudentSubGroup_TotalTested)) & StudentSubGroup_TotalTested2 != . & inlist(StudentGroup, "RaceEth", "Gender")
drop if inlist(StudentSubGroup_TotalTested, "", "0") & StudentSubGroup != "All Students"
drop StudentSubGroup_TotalTested2

**

destring StudentSubGroup_TotalTested, gen(StudentSubGroup_TotalTested2) force
destring ProficientOrAbove_percent, gen(ProficientOrAbove_percent2) force

gen ProficientOrAbove_count = round(ProficientOrAbove_percent2 * StudentSubGroup_TotalTested2)
tostring ProficientOrAbove_count, replace force
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace ProficientOrAbove_count = "--" if StudentSubGroup_TotalTested == "--"

foreach x of numlist 1/4 {
    destring Lev`x'_percent, gen(Lev`x'_percent2) force
}

replace Lev1_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev2_percent) if missing(real(Lev1_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev2_percent))
replace Lev2_percent2 = 1 - real(ProficientOrAbove_percent) - real(Lev1_percent) if missing(real(Lev2_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev1_percent))
replace Lev3_percent2 = real(ProficientOrAbove_percent) - real(Lev4_percent) if missing(real(Lev3_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev4_percent))
replace Lev4_percent2 = real(ProficientOrAbove_percent) - real(Lev3_percent) if missing(real(Lev4_percent)) & !missing(real(ProficientOrAbove_percent)) & !missing(real(Lev3_percent))

foreach x of numlist 1/4 {
	replace Lev`x'_percent2 = 0 if Lev`x'_percent2 < 0 & Lev`x'_percent2 != .
	replace Lev`x'_percent = string(Lev`x'_percent2, "%9.2g") if missing(real(Lev`x'_percent)) & Lev`x'_percent2 != .
	replace Lev`x'_percent = "0" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") == 0
	replace Lev`x'_percent = "0-0.02" if strpos(Lev`x'_percent, "e") > 0 & strpos(Lev`x'_percent, "-0.02") > 0
	gen Lev`x'_count = round(Lev`x'_percent2 * StudentSubGroup_TotalTested2)
	tostring Lev`x'_count, replace force
	replace Lev`x'_count = "*" if Lev`x'_count == "."
}

gen Lev5_count = ""

replace DistName = "Fowler Elementary District" if NCESDistrictID == "403060"
	
duplicates drop

//Final Cleaning
foreach var of varlist DistName SchName {
	replace `var' = stritrim(`var')
	replace `var' = strtrim(`var')
}

//Keeping, ordering and sorting variables
keep `vars'
order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting Output with derivations*
save "${Output}/AZ_AssmtData_2016.dta", replace //Not final output, EDFacts participation rates added in at the end.
export delimited using "${Output}/AZ_AssmtData_2016.csv", replace //Not final output, EDFacts participation rates added in at the end.
* END of 09_AzMERIT_clean_2016.do
****************************************************
