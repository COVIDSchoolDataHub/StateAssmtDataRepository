clear
set more off
set trace off

	*** EDFACTS CLEANING ***
global Original "/Users/miramehta/Documents/AR State Testing Data/Original Data"
global Output "/Users/miramehta/Documents/AR State Testing Data/Output"
global NCES "//Users/miramehta/Documents/NCES District and School Demographics"
global Temp "/Users/miramehta/Documents/AR State Testing Data/Temp"
global EDFacts "/Users/miramehta/Documents/AR State Testing Data/EDFacts"

//Combining separate data files for 2016-2023
forvalues year = 2016/2023 {
if `year' == 2020 continue
use "${Temp}/AR_AssmtData_`year'_AllStudents"
append using "${Temp}/AR_AssmtData_`year'_nocountsSG"
if `year' >= 2019 append using "${Temp}/AR_AssmtData_`year'_StateSG"
replace SchName = proper(SchName)
replace DistName = proper(DistName)
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Dropping Blank Rows
drop if Lev1_percent == "--" & Lev3_percent == "--" & Lev4_percent== "--" & ProficientOrAbove_percent == "--"
drop if missing(State)

	** Post Launch Review **
//NCESSchoolID for 2019
if `year' == 2019 replace NCESSchoolID = "050042401683" if StateAssignedSchID == "6061702" 

//Deriving ProficientOrAbove_percent where possible
replace ProficientOrAbove_percent = string(1-(real(Lev1_percent) + real(Lev2_percent)), "%9.3g") if regexm(Lev1_percent, "[0-9]") !=0 & regexm(Lev2_percent, "[0-9]") !=0 & regexm(ProficientOrAbove_percent, "[0-9]") ==0

//Updating Flags
if `year' == 2016 replace Flag_CutScoreChange_sci = "Y"
if `year' == 2018 replace Flag_CutScoreChange_sci = "N"
replace Flag_CutScoreChange_soc = "Not applicable"

replace StateAssignedDistID = "3201000" if StateAssignedSchID == "3201042" //flagged ID mismatches

drop StudentGroup_TotalTested
replace StateAssignedDistID = "00000" if DataLevel == 1
replace StateAssignedSchID = "00000" if DataLevel != 3
egen uniquegrp = group(DataLevel StateAssignedDistID StateAssignedSchID Subject GradeLevel)
sort uniquegrp StudentGroup StudentSubGroup
by uniquegrp: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
order Subject GradeLevel StudentGroup_TotalTested StudentGroup StudentSubGroup_TotalTested StudentSubGroup
by uniquegrp: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
replace StudentGroup_TotalTested = "--" if missing(StudentGroup_TotalTested)
replace StateAssignedDistID = "" if DataLevel == 1
replace StateAssignedSchID = "" if DataLevel != 3

order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AR_AssmtData_`year'", replace

}

//Importing EDFacts Data 2016-2021

forvalues year = 2016/2021 {
if `year' == 2020 continue
foreach data in part count {
foreach subject in ela math {
foreach dl in district school {
	if `year' < 2022 use "${EDFacts}/edfacts`data'`year'`subject'`dl'.dta"
	if `year' >= 2022 use "${EDFacts}/edfacts`data'2021`subject'`dl'.dta"
keep if STNAM == "ARKANSAS"

//Renaming
rename LEAID NCESDistrictID
cap rename NCESSCH NCESSchoolID
rename SUBJECT Subject
rename GRADE GradeLevel
rename CATEGORY StudentSubGroup
cap rename PCTPART ParticipationRate
cap rename NUMVALID StudentSubGroup_TotalTested

//Subject
replace Subject = "ela" if Subject == "RLA"
replace Subject = "math" if Subject == "MTH"

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "ALL"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "MAM"
replace StudentSubGroup = "Asian" if StudentSubGroup == "MAS"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "MHI"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "MBL"
replace StudentSubGroup = "White" if StudentSubGroup == "MWH"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "MTR"
replace StudentSubGroup = "SWD" if StudentSubGroup == "CWD"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"
replace StudentSubGroup = "Homeless" if StudentSubGroup == "HOM"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "MIG"

if "`data'" == "part" {

//ParticipationRate
replace ParticipationRate = subinstr(ParticipationRate, "GE",">",.)
replace ParticipationRate = subinstr(ParticipationRate, "LE","<",.)
replace ParticipationRate = subinstr(ParticipationRate, "GT",">",.)
replace ParticipationRate = subinstr(ParticipationRate, "LT","<",.)
replace ParticipationRate = "*" if ParticipationRate == "PS"

foreach var of varlist ParticipationRate {
gen range`var' = substr(`var',1,1) if regexm(`var',"[<>]") !=0
gen low`var' = substr(`var', 1, strpos(`var',"-")-1) if strpos(`var',"-") !=0
gen high`var' = substr(`var', strpos(`var',"-")+1, 2) if strpos(`var',"-") !=0
destring low`var', gen(nlow`var')
destring high`var', gen(nhigh`var')
replace low`var' = string((nlow`var'/100),"%9.3g")
replace high`var' = string((nhigh`var'/100),"%9.3g")
replace `var' = "R" if strpos(`var',"-") !=0
destring `var', gen(n`var') i(R*%<>-.n/a)
replace `var' = range`var' + string(n`var'/100, "%9.3g") if `var' != "*" & `var' != "--" & `var' != "R"
replace `var' = low`var' + "-" + high`var' if `var' == "R"
replace `var' = subinstr(`var', "=","",.)
replace `var' = subinstr(`var',">","",.) + "-1" if strpos(`var', ">") !=0
replace `var' = subinstr(`var', "<","0-",.) if strpos(`var', "<") !=0
replace `var' = "--" if `var' == "n/a" | `var' == "."
}

drop Subject
save "${Temp}/`year'_`subject'_`data'_`dl'", replace
clear

}

//Generating StudentSubGroup_TotalTested and State Level Aggregation
if "`data'" == "count" {
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested)
sort Subject GradeLevel StudentSubGroup
if "`dl'" == "district" egen StateStudentSubGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentSubGroup GradeLevel)
drop Subject

save "${Temp}/`year'_`subject'_`data'_`dl'", replace
clear
}
}
}
}

//Combining ParticipationRate for each DataLevel
use "${Temp}/`year'_ela_part_district"
append using "${Temp}/`year'_ela_part_school"
save "${Temp}/`year'_ela_part", replace
clear
use "${Temp}/`year'_math_part_district"
append using "${Temp}/`year'_math_part_school"
save "${Temp}/`year'_math_part", replace

//Combining StudentSubGroup_TotalTested for each DataLevel
use "${Temp}/`year'_ela_count_district"
append using "${Temp}/`year'_ela_count_school"
save "${Temp}/`year'_ela_count", replace
clear
use "${Temp}/`year'_math_count_district"
append using "${Temp}/`year'_math_count_school"
save "${Temp}/`year'_math_count", replace



	*** EDFACTS MERGING ***


//Merging StudentSubGroup_TotalTested with Cleaned Data

use "${Output}/AR_AssmtData_`year'"
replace StudentSubGroup_TotalTested = "" if StudentSubGroup_TotalTested == "--"
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)


tempfile temp1
save "`temp1'", replace
keep if (Subject == "eng" | Subject == "read" | Subject == "ela") & StudentSubGroup_TotalTested == ""
drop StudentSubGroup_TotalTested
tempfile tempela
save "`tempela'", replace
clear
use "`temp1'"
keep if Subject == "math" & StudentSubGroup_TotalTested == ""
drop StudentSubGroup_TotalTested
tempfile tempmath
save "`tempmath'", replace
clear

use "${Temp}/`year'_ela_count.dta"
merge m:m NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "`tempela'", update
drop if _merge == 1
save "`tempela'", replace
clear
use "${Temp}/`year'_math_count.dta"
merge m:m NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "`tempmath'", update
drop if _merge ==1
save "`tempmath'", replace

use "`temp1'"
drop if (Subject == "eng" | Subject == "read" | Subject == "math" | Subject == "ela") & StudentSubGroup_TotalTested == ""
append using "`tempela'" "`tempmath'"

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(nStudentSubGroup_TotalTested)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = total(nStudentSubGroup_TotalTested) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = total(nStudentSubGroup_TotalTested) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen EL = total(nStudentSubGroup_TotalTested) if StudentGroup == "EL Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = total(nStudentSubGroup_TotalTested) if StudentGroup == "Gender"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Migrant = total(nStudentSubGroup_TotalTested) if StudentGroup == "Migrant Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Homeless = total(nStudentSubGroup_TotalTested) if StudentGroup == "Homeless Enrolled Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Military = total(nStudentSubGroup_TotalTested) if StudentGroup == "Military Connected Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Foster = total(nStudentSubGroup_TotalTested) if StudentGroup == "Foster Care Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = total(nStudentSubGroup_TotalTested) if StudentGroup == "Disability Status"

replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & max != 0 & nStudentSubGroup_TotalTested == . & RaceEth != 0
replace StudentSubGroup_TotalTested = string(max - Econ) if StudentGroup == "Economic Status" & max != 0 & nStudentSubGroup_TotalTested == . & Econ != 0
replace StudentSubGroup_TotalTested = string(max - EL) if StudentSubGroup == "English Proficient" & max != 0 & nStudentSubGroup_TotalTested == . & EL != 0
replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & nStudentSubGroup_TotalTested == . & Gender != 0
replace StudentSubGroup_TotalTested = string(max - Migrant) if StudentGroup == "Migrant Status" & max != 0 & nStudentSubGroup_TotalTested == . & Migrant != 0
replace StudentSubGroup_TotalTested = string(max - Homeless) if StudentGroup == "Homeless Enrolled Status" & max != 0 & nStudentSubGroup_TotalTested == . & Homeless != 0
replace StudentSubGroup_TotalTested = string(max - Military) if StudentGroup == "Military Connected Status" & max != 0 & nStudentSubGroup_TotalTested == . & Military != 0
replace StudentSubGroup_TotalTested = string(max - Foster) if StudentGroup == "Foster Care Status" & max != 0 & nStudentSubGroup_TotalTested == . & Foster != 0
replace StudentSubGroup_TotalTested = string(max - Disability) if StudentGroup == "Disability Status" & max != 0 & nStudentSubGroup_TotalTested == . & Disability != 0
drop RaceEth Econ EL Gender Migrant Homeless Military Foster Disability nStudentSubGroup_TotalTested

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == ""

drop _merge


//Merging ParticipationRate with Cleaned Data 
replace ParticipationRate = ""
tempfile temp1
save "`temp1'", replace
keep if Subject == "ela" | Subject == "read" | Subject == "eng"
tempfile tempela
save "`tempela'", replace
clear
use "`temp1'"
keep if Subject == "math"
tempfile tempmath
save "`tempmath'", replace
clear

use "${Temp}/`year'_ela_part"

merge m:m NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "`tempela'", update
drop if _merge == 1
save "`tempela'", replace
clear

use "${Temp}/`year'_math_part"

merge m:m NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "`tempmath'", update
drop if _merge == 1 
save "`tempmath'", replace
clear

use "`temp1'"
drop if Subject == "ela" | Subject == "math" | Subject == "eng" | Subject == "read"
append using "`tempela'" "`tempmath'"

replace ParticipationRate = "--" if missing(ParticipationRate)

save "${Temp}/Testing", replace

//Aggregating StudentSubGroup_TotalTested and StudentGroup_TotalTested to State Level
tempfile temp3
save "`temp3'", replace
drop if DataLevel !=2
keep if !missing(StateStudentSubGroup_TotalTested)
duplicates drop StudentSubGroup GradeLevel Subject, force
egen StateStudentGroup_TotalTested = total(StateStudentSubGroup_TotalTested), by(StudentGroup Subject GradeLevel)
keep StateStudentSubGroup_TotalTested StateStudentGroup_TotalTested StudentSubGroup GradeLevel Subject
tempfile temp4
save "`temp4'", replace
clear
use "`temp3'"
keep if DataLevel ==1
cap drop _merge
merge 1:1 StudentSubGroup GradeLevel Subject using "`temp4'", update 
save "`temp4'", replace
use "`temp3'"
drop if DataLevel ==1
append using "`temp4'"
replace StudentSubGroup_TotalTested = string(StateStudentSubGroup_TotalTested) if !missing(StateStudentSubGroup_TotalTested) & StudentSubGroup_TotalTested == "--" & DataLevel ==1
replace StudentGroup_TotalTested = string(StateStudentGroup_TotalTested) if !missing(StateStudentGroup_TotalTested) & StudentGroup_TotalTested == "--" & DataLevel ==1

//Response to Post-Launch review
if `year' == 2019 replace NCESDistrictID = "0500424" if StateAssignedDistID == "6061700"
replace StateAssignedDistID = StateAssignedDistID[_n-1] if missing(StateAssignedDistID) & DataLevel == 3

//Deriving Counts
foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`var'","percent","count",.)
replace `count' = string(round(real(`var')*real(StudentSubGroup_TotalTested))) if regexm(`var', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0	
}

replace Lev5_count = "" if ProficiencyCriteria == "Levels 3-4"
replace Lev5_percent = "" if ProficiencyCriteria == "Levels 3-4"

//Final Cleaning
drop if missing(State)
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AR_AssmtData_`year'", replace
export delimited "${Output}/AR_AssmtData_`year'", replace
clear

}		

//Importing EDFacts 2022 Data
import delimited "${Original}/edfacts2022_AR_count1.csv", clear
save "${Original}/edfacts2022.dta", replace
import delimited "${Original}/edfacts2022_AR_count2.csv", clear
append using "${Original}/edfacts2022.dta"
tostring characteristics, replace
save "${Original}/edfacts2022.dta", replace
import delimited "${Original}/edfacts2022_AR_count3.csv", clear
tostring subgroup, replace
append using "${Original}/edfacts2022.dta"

* DataLevel & IDs
rename lea DistName
rename school SchName
rename ncesleaid NCESDistrictID
rename ncesschid NCESSchoolID

tostring NCESDistrictID, replace
tostring NCESSchoolID, replace format ("%18.0f")
replace NCESDistrictID = "" if NCESDistrictID == "."
replace NCESSchoolID = "" if NCESSchoolID == "."
gen DataLevel = 3
replace DataLevel = 2 if NCESSchoolID == ""
replace DataLevel = 1 if NCESDistrictID == ""

* Subject & GradeLevel
rename academicsubject Subject
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "sci" if Subject == "Science"

rename agegrade GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0", 1)

* StudentSubGroup
rename subgroup StudentSubGroup
replace StudentSubGroup = characteristics if characteristics != "."
drop characteristics population
replace StudentSubGroup = "American Indian or Alaska Native" if strpos(StudentSubGroup, "American Indian") > 0
replace StudentSubGroup = "Asian" if strpos(StudentSubGroup, "Asian") > 0
replace StudentSubGroup = "Black or African American" if strpos(StudentSubGroup, "Black") > 0
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Migrant" if StudentSubGroup == "Migratory students"
replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "White") > 0

gen StudentGroup = "RaceEth" if inlist(StudentSubGroup, "American Indian or Alaska Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Pacific Islander", "White")
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Gender" if inlist(StudentSubGroup, "Male", "Female")
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"
drop programtype outcome datagroup

* Values
gen nStudentSubGroup_TotalTested = .
replace nStudentSubGroup_TotalTested = denominator if strpos(datadescription, "Performance") > 0
replace nStudentSubGroup_TotalTested = numerator if strpos(datadescription, "Participation") > 0
drop numerator denominator value datadescription schoolyear state
duplicates drop

save "${Temp}/edfacts2022.dta", replace

//Apply 2022 Counts to 2022-2024

forvalues year = 2022/2024 {
use "${Output}/AR_AssmtData_`year'", clear

replace NCESDistrictID = subinstr(NCESDistrictID, "0", "", 1) if strpos(NCESDistrictID, "0") == 1
replace NCESSchoolID = subinstr(NCESSchoolID, "0", "", 1) if strpos(NCESSchoolID, "0") == 1

replace StudentSubGroup_TotalTested = "" if StudentSubGroup_TotalTested == "--"
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)

merge 1:1 NCESDistrictID NCESSchoolID Subject GradeLevel StudentSubGroup using "${Temp}/edfacts2022.dta"
drop if _merge == 2
drop _merge

bysort StateAssignedDistID StateAssignedSchID StudentGroup GradeLevel Subject: egen test = min(nStudentSubGroup_TotalTested)
gen max = real(StudentGroup_TotalTested)
replace max = 0 if max == .

bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen RaceEth = total(nStudentSubGroup_TotalTested) if StudentGroup == "RaceEth"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Econ = total(nStudentSubGroup_TotalTested) if StudentGroup == "Economic Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen EL = total(nStudentSubGroup_TotalTested) if StudentGroup == "EL Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Gender = total(nStudentSubGroup_TotalTested) if StudentGroup == "Gender"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Migrant = total(nStudentSubGroup_TotalTested) if StudentGroup == "Migrant Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Homeless = total(nStudentSubGroup_TotalTested) if StudentGroup == "Homeless Enrolled Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Military = total(nStudentSubGroup_TotalTested) if StudentGroup == "Military Connected Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Foster = total(nStudentSubGroup_TotalTested) if StudentGroup == "Foster Care Status"
bysort StateAssignedDistID StateAssignedSchID GradeLevel Subject: egen Disability = total(nStudentSubGroup_TotalTested) if StudentGroup == "Disability Status"

replace StudentSubGroup_TotalTested = string(max - RaceEth) if StudentGroup == "RaceEth" & max != 0 & nStudentSubGroup_TotalTested == . & RaceEth != 0
replace StudentSubGroup_TotalTested = string(max - Econ) if StudentGroup == "Economic Status" & max != 0 & nStudentSubGroup_TotalTested == . & Econ != 0
replace StudentSubGroup_TotalTested = string(max - EL) if StudentSubGroup == "English Proficient" & max != 0 & nStudentSubGroup_TotalTested == . & EL != 0
replace StudentSubGroup_TotalTested = string(max - Gender) if StudentGroup == "Gender" & max != 0 & nStudentSubGroup_TotalTested == . & Gender != 0
replace StudentSubGroup_TotalTested = string(max - Migrant) if StudentGroup == "Migrant Status" & max != 0 & nStudentSubGroup_TotalTested == . & Migrant != 0
replace StudentSubGroup_TotalTested = string(max - Homeless) if StudentGroup == "Homeless Enrolled Status" & max != 0 & nStudentSubGroup_TotalTested == . & Homeless != 0
replace StudentSubGroup_TotalTested = string(max - Military) if StudentGroup == "Military Connected Status" & max != 0 & nStudentSubGroup_TotalTested == . & Military != 0
replace StudentSubGroup_TotalTested = string(max - Foster) if StudentGroup == "Foster Care Status" & max != 0 & nStudentSubGroup_TotalTested == . & Foster != 0
replace StudentSubGroup_TotalTested = string(max - Disability) if StudentGroup == "Disability Status" & max != 0 & nStudentSubGroup_TotalTested == . & Disability != 0
drop RaceEth Econ EL Gender Migrant Homeless Military Foster Disability nStudentSubGroup_TotalTested

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == "."
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "."
drop if StudentSubGroup_TotalTested == "0" & StudentSubGroup != "All Students"
replace StudentSubGroup_TotalTested = "--" if StudentSubGroup_TotalTested == ""

//Deriving Counts
foreach var of varlist Lev*_percent ProficientOrAbove_percent {
	local count = subinstr("`var'","percent","count",.)
replace `count' = string(round(real(`var')*real(StudentSubGroup_TotalTested))) if regexm(`var', "[0-9]") !=0 & regexm(StudentSubGroup_TotalTested, "[0-9]") !=0	
}

replace Lev5_count = "" if ProficiencyCriteria == "Levels 3-4"
replace Lev5_percent = "" if ProficiencyCriteria == "Levels 3-4"

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

replace StateAssignedDistID = StateAssignedDistID[_n-1] if missing(StateAssignedDistID) & DataLevel == 3

save "${Output}/AR_AssmtData_`year'", replace
export delimited "${Output}/AR_AssmtData_`year'", replace
clear

}
