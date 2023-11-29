clear
set more off
set trace off
local Cleaned "/Volumes/T7/State Test Project/Hawaii/Cleaned Data"
local Output "/Volumes/T7/State Test Project/Hawaii/Cleaned Data"
local EDFacts "/Volumes/T7/State Test Project/EDFACTS"
local Temp "/Volumes/T7/State Test Project/Hawaii/Temp"

//Importing

forvalues year = 2015/2023 {
if `year' == 2020 continue
foreach data in part count {
foreach subject in ela math {
foreach dl in district school {
clear
use "/Volumes/T7/State Test Project/EDFACTS/edfacts`data'`year'`subject'`dl'.dta"
keep if STNAM == "HAWAII"

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
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08", "G00")
replace GradeLevel = "G38" if GradeLevel == "G00"

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


if "`dl'" == "district" keep STNAM Subject NCESDistrictID GradeLevel StudentSubGroup NUMPART ParticipationRate
if "`dl'" == "school" keep STNAM Subject NCESDistrictID NCESSchoolID SCHNAM GradeLevel StudentSubGroup NUMPART ParticipationRate
save "`Temp'/`year'_`subject'_`data'_`dl'", replace
clear

}

if "`data'" == "count" {
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested)
sort Subject GradeLevel StudentSubGroup
egen StateStudentSubGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentSubGroup GradeLevel)
save "`Temp'/`year'_`subject'_`data'_`dl'", replace
clear
}
}
}
}
tempfile temp_`year'_count
save "`temp_`year'_count'", replace emptyok
foreach dl in district school {
	foreach subject in ela math {
	use "`Temp'/`year'_`subject'_count_`dl'"
	append using "`temp_`year'_count'"
	save "`temp_`year'_count'", replace
	save "`Temp'/_`year'_count", replace
	clear	
	}
}
tempfile temp_`year'_part
save "`temp_`year'_part'", replace emptyok
foreach dl in district school {
	foreach subject in ela math {
	use "`Temp'/`year'_`subject'_part_`dl'"
	append using "`temp_`year'_part'"
	save "`temp_`year'_part'", replace
	save "`Temp'/_`year'_part", replace
	clear	
	}
}
	** EDFACTS Merging **
use "`Cleaned'/HI_AssmtData_`year'"
replace StudentSubGroup_TotalTested = "" if StudentSubGroup_TotalTested == "--"
replace StudentGroup_TotalTested = "" if StudentGroup_TotalTested == "--"
replace ParticipationRate = ""
destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i(*-)
merge m:m NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "`Temp'/_`year'_count", update
drop if _merge == 2
rename _merge _merge1
merge m:m NCESDistrictID NCESSchoolID GradeLevel Subject StudentSubGroup using "`Temp'/_`year'_part", update
drop if _merge ==2
rename _merge _merge2
tempfile temp1
save "`temp1'", replace
keep if DataLevel == 1
tempfile tempstate
save "`tempstate'", replace
clear
use "`Temp'/_`year'_count"
duplicates drop StudentSubGroup GradeLevel Subject, force
tempfile temp2
save "`temp2'", replace
merge 1:1 StudentSubGroup GradeLevel Subject using "`tempstate'"
drop if _merge == 1
replace StudentSubGroup_TotalTested = string(StateStudentSubGroup_TotalTested)
save "`tempstate'", replace
use "`temp1'"
keep if DataLevel !=1
append using "`tempstate'"
sort DataLevel
replace NCESSchoolID = "" if DataLevel == 1
replace NCESDistrictID = "" if DataLevel == 1
sort StudentGroup
drop StudentGroup_TotalTested
egen StudentGroup_TotalTested = total(nStudentSubGroup_TotalTested), by(StudentGroup GradeLevel Subject DataLevel StateAssignedSchID StateAssignedDistID)
replace StudentSubGroup_TotalTested = string(nStudentSubGroup_TotalTested) if !missing(nStudentSubGroup_TotalTested)
tostring StudentGroup_TotalTested, replace
*replace StudentSubGroup_TotalTested = "--" if Subject == "sci"
*replace StudentSubGroup_TotalTested = "--" if StudentSubGroup == "Filipino" | StudentSubGroup == "Native Hawaiian" | StudentSubGroup == "Pacific Islander"
replace StudentGroup_TotalTested = "--" if StudentGroup_TotalTested == "0"
replace StudentSubGroup_TotalTested = "--" if missing(StudentSubGroup_TotalTested) | StudentSubGroup_TotalTested == "0"
replace ParticipationRate = "--" if missing(ParticipationRate)

//Dropping if StudentSubGroup_TotalTested ==0
drop if StudentSubGroup_TotalTested == "0"


order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

save "`Output'/HI_AssmtData_`year'", replace
export delimited "`Output'/HI_AssmtData_`year'", replace
clear
}




