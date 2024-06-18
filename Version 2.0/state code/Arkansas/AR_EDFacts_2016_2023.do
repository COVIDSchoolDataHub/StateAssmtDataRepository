clear
set more off
set trace off

	*** EDFACTS CLEANING ***

//Importing

forvalues year = 2016/2023 {
if `year' == 2020 continue
foreach data in part count {
foreach subject in ela math {
foreach dl in district school {
use "${EDFacts}/edfacts`data'`year'`subject'`dl'.dta"
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
replace StudentGroup_TotalTested = "" if StudentGroup_TotalTested == "--"
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)


tempfile temp1
save "`temp1'", replace
keep if (Subject == "eng" | Subject == "read" | Subject == "ela") & StudentSubGroup_TotalTested == ""
drop StudentGroup_TotalTested StudentSubGroup_TotalTested
tempfile tempela
save "`tempela'", replace
clear
use "`temp1'"
keep if Subject == "math" & StudentSubGroup_TotalTested == ""
drop StudentGroup_TotalTested StudentSubGroup_TotalTested
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

egen nStudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)

replace StudentSubGroup_TotalTested = string(nStudentSubGroup_TotalTested) if !missing(nStudentSubGroup_TotalTested) & (StudentSubGroup_TotalTested == "--" | StudentSubGroup_TotalTested == "*")
replace StudentGroup_TotalTested = string(nStudentGroup_TotalTested) if !missing(nStudentGroup_TotalTested)
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "0" 
replace StudentSubGroup_TotalTested = "--" if missing(nStudentSubGroup_TotalTested)
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



//Final Cleaning
drop if missing(State)
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "${Output}/AR_AssmtData_`year'", replace
export delimited "${Output}/AR_AssmtData_`year'", replace
clear

}		




