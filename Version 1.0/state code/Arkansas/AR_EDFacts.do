clear
set more off
local Cleaned "/Volumes/T7/State Test Project/Arkansas/Output"
local Output "/Volumes/T7/State Test Project/Arkansas/Output"
local EDFacts "/Volumes/T7/State Test Project/EDFACTS"
local Temp "/Volumes/T7/State Test Project/Arkansas/Temp"

	*** EDFACTS CLEANING ***

//Importing

foreach year in 2019 2021 2022 {
foreach data in part count {
foreach subject in ela math {
foreach dl in district school {
use "/Volumes/T7/State Test Project/EDFACTS/edfacts`data'`year'`subject'`dl'.dta"
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
drop if StudentSubGroup == "CWD"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "ECD"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "LEP"
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

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


if "`dl'" == "district" keep SCHOOL_YEAR STNAM NCESDistrictID ST_LEAID LEANM GradeLevel StudentSubGroup NUMPART ParticipationRate
if "`dl'" == "school" keep SCHOOL_YEAR STNAM NCESDistrictID NCESSchoolID SCHNAM ST_LEAID LEANM GradeLevel StudentSubGroup NUMPART ParticipationRate
save "`Temp'/`year'_`subject'_`data'_`dl'", replace
clear

}

if "`data'" == "count" {
destring StudentSubGroup_TotalTested, replace
sort Subject GradeLevel StudentSubGroup
egen StateStudentSubGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentSubGroup GradeLevel)
keep Subject StudentSubGroup GradeLevel StateStudentSubGroup_TotalTested
rename StateStudentSubGroup_TotalTested nStudentSubGroup_TotalTested

duplicates drop Subject StudentSubGroup GradeLevel, force
drop Subject
save "`Temp'/`year'_`subject'_`data'_`dl'", replace
clear
}
}
}
}

//Combining ParticipationRate for each DataLevel
use "`Temp'/`year'_ela_part_district"
append using "`Temp'/`year'_ela_part_school"
save "`Temp'/`year'_ela_part", replace
clear
use "`Temp'/`year'_math_part_district"
append using "`Temp'/`year'_math_part_school"
save "`Temp'/`year'_math_part", replace


	*** EDFACTS MERGING ***


//Merging StudentSubGroup_TotalTested with Cleaned Data

use "`Cleaned'/AR_AssmtData_`year'"
replace StudentSubGroup_TotalTested = "" if DataLevel == 1 & StudentSubGroup_TotalTested == "--"
replace StudentGroup_TotalTested = "" if DataLevel == 1 & StudentGroup_TotalTested == "--"
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)


tempfile temp1
save "`temp1'", replace
keep if DataLevel == 1 & (Subject == "eng" | Subject == "read")
drop StudentGroup_TotalTested StudentSubGroup_TotalTested
tempfile tempela
save "`tempela'", replace
clear
use "`temp1'"
keep if DataLevel == 1 & Subject == "math"
drop StudentGroup_TotalTested StudentSubGroup_TotalTested
tempfile tempmath
save "`tempmath'", replace
clear

use "`Temp'/`year'_ela_count_district.dta"
merge 1:m GradeLevel StudentSubGroup using "`tempela'", update
drop if _merge == 1
save "`tempela'", replace
clear
use "`Temp'/`year'_math_count_district.dta"
merge 1:m GradeLevel StudentSubGroup using "`tempmath'", update
drop if _merge ==1
save "`tempmath'", replace

use "`temp1'"
drop if DataLevel == 1 & (Subject == "eng" | Subject == "read" | Subject == "math")
append using "`tempela'" "`tempmath'"

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

sort StudentGroup
egen nStudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel SchName DistName)

replace StudentSubGroup_TotalTested = string(nStudentSubGroup_TotalTested) if !missing(nStudentSubGroup_TotalTested)
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

use "`Temp'/`year'_ela_part"

merge 1:m NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "`tempela'", update
drop if _merge == 1
save "`tempela'", replace
clear

use "`Temp'/`year'_math_part"

merge 1:m NCESDistrictID NCESSchoolID GradeLevel StudentSubGroup using "`tempmath'", update
drop if _merge == 1 
save "`tempmath'", replace
clear

use "`temp1'"
drop if Subject == "ela" | Subject == "math" | Subject == "eng" | Subject == "read"
append using "`tempela'" "`tempmath'"

replace ParticipationRate = "--" if missing(ParticipationRate)



//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/AR_AssmtData_`year'", replace
export delimited "`Output'/AR_AssmtData_`year'", replace
clear









}		




