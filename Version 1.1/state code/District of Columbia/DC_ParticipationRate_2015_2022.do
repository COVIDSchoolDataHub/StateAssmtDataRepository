clear
set more off

global Output "/Users/benjaminm/Documents/State_Repository_Research/DC/Output"
global NCES "/Users/benjaminm/Documents/State_Repository_Research/DC/NCES"
global Original "/Users/benjaminm/Documents/State_Repository_Research/DC/Original"
cd "/Users/benjaminm/Documents/State_Repository_Research/DC"

forvalues year = 2015/2019 {
local prevyear =`=`year'-1'
	
//Importing
tempfile temp1
save "`temp1'", replace emptyok
if `year' == 2015 | `year' == 2016 {
	import excel "${Original}/DC_OriginalData_2016_part", sheet(State) firstrow case(preserve)
	
} 
else {
	import excel "${Original}/DC_OriginalData_`year'_part", sheet(State) firstrow case(preserve)
}

keep if SchoolYear == "`prevyear'" + "-" + substr("`year'",3,2)
append using "`temp1'"
save "`temp1'", replace
clear
if `year' < 2017 {
import excel "${Original}/DC_OriginalData_2016_part", sheet(District) firstrow case(preserve) allstring
}

else {
import excel "${Original}/DC_OriginalData_`year'_part", sheet(District) firstrow case(preserve) allstring
}

keep if SchoolYear == "`prevyear'" + "-" + substr("`year'",3,2)
append using "`temp1'"
save "`temp1'", replace
clear
if `year' < 2017 {
import excel "${Original}/DC_OriginalData_2016_part", sheet(School) firstrow case(preserve) allstring
}

else {
import excel "${Original}/DC_OriginalData_`year'_part", sheet(School) firstrow case(preserve) allstring
}

keep if SchoolYear == "`prevyear'" + "-" + substr("`year'",3,2)
append using "`temp1'"
save "`temp1'", replace
if `year' == 2019 {
clear
import excel "${Original}/DC_OriginalData_`year'_sci_part", sheet(State) firstrow case(preserve) allstring
gen S = "sci"
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_`year'_sci_part", sheet(District) firstrow case(preserve) allstring
gen S = "sci"
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_`year'_sci_part", sheet(School) firstrow case(preserve) allstring
gen S = "sci"
append using "`temp1'"
}
keep if SchoolYear == "`prevyear'" + "-" + substr("`year'",3,2)
save "`temp1'", replace
*save "/Volumes/T7/State Test Project/District of Columbia/Testing/`year'", replace



//Reshaping
drop ALL HS O V K R
rename G0E5 G05E
replace Subgroup = subgroup if missing(Subgroup)
if `year' == 2018 drop if SchoolCode == "3033"
if `year' != 2019 reshape long G, i(LEAName SchoolName Subgroup) j(GradeLevel, string)
if `year' == 2019 reshape long G, i(LEAName SchoolName Subgroup S) j(GradeLevel, string)
rename G ParticipationRate
*save "/Volumes/T7/State Test Project/District of Columbia/Testing/`year'_part"
//Subject and GradeLevel
gen Subject = substr(GradeLevel,-1,1)
replace GradeLevel = "G" + substr(GradeLevel, 1,2)
replace Subject = "ela" if Subject == "E"
replace Subject = "math" if Subject == "M"
replace Subject = "sci" if Subject == "S"


**Prepping for merge
rename SchoolCode StateAssignedSchID
rename LEACode StateAssignedDistID

rename Subgroup StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "Active or Monitored English Learner"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander or Native Hawaiian"
replace StudentSubGroup = subinstr(StudentSubGroup, "Alaskan", "Alaska",.)
replace StudentSubGroup = "White" if strpos(StudentSubGroup, "White") !=0
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multiracial"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"


//Merging
if `year' == 2016 tostring StateAssignedSchID, replace
if `year' == 2016 replace StateAssignedSchID = "" if StateAssignedSchID == "."
*save "/Volumes/T7/State Test Project/District of Columbia/Testing/`year'_part", replace
if `year' != 2019 merge 1:1 StateAssignedSchID StateAssignedDistID StudentSubGroup GradeLevel Subject using "${Output}/DC_AssmtData_`year'", update
if `year' == 2019 { 
rename S subject1
tempfile temp2 
save "`temp2'", replace
clear
use "${Output}/DC_AssmtData_2019"
gen subject1 = "sci" if Subject == "sci"
save "${Output}/DC_AssmtData_2019", replace
use "`temp2'"
merge 1:1 StateAssignedSchID StateAssignedDistID StudentSubGroup GradeLevel Subject subject1 using "${Output}/DC_AssmtData_`year'", update
}
drop if _merge ==1
replace ParticipationRate = "--" if _merge ==2 & Subject != "sci"

//Missing/Suppressed
replace ParticipationRate = "*" if ParticipationRate == "n<40" | ParticipationRate == "n<25" | ParticipationRate == "n<10" | ParticipationRate == "DS"

//Converting to decimal for 2017 & 2018
if `year' >=2017 {
	destring ParticipationRate, gen(nParticipationRate) i(%*-)
	replace ParticipationRate = string(nParticipationRate/100, "%9.4g") if ParticipationRate != "*" & ParticipationRate != "--"
}

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode


sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${Output}/DC_AssmtData_`year'", replace
export delimited "${Output}/DC_AssmtData_`year'", replace

clear

}

//2022

//Importing and appending
clear

tempfile temp1
save "`temp1'", replace emptyok
import excel "${Original}/DC_OriginalData_2022_part", firstrow case(preserve) sheet(State)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2022_part", firstrow case(preserve) sheet(District)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2022_part", firstrow case(preserve) sheet(School)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2022_sci_part", firstrow case(preserve) sheet(State)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2022_sci_part", firstrow case(preserve) sheet(District)
append using "`temp1'"
save "`temp1'", replace
clear
import excel "${Original}/DC_OriginalData_2022_sci_part", firstrow case(preserve) sheet(School)
append using "`temp1'"
*save "/Volumes/T7/State Test Project/District of Columbia/Testing/2022", replace

//Renaming
rename SchoolCode StateAssignedSchID
rename LEACode StateAssignedDistID
rename GradeofEnrollment GradeLevel
rename SubgroupValue StudentSubGroup
rename Percent ParticipationRate

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ","",.)
replace GradeLevel = "G0" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//StudentSubGroup
replace StudentSubGroup = subinstr(StudentSubGroup, "/", " or ",.)
replace StudentSubGroup = "All Students" if StudentSubGroup == "All"
replace StudentSubGroup = "English Proficient" if StudentSubGroup == "Not an English Learner"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Econ Dis"
replace StudentSubGroup = "Not Economically Disadvantaged" if StudentSubGroup == "Not Econ Dis"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander or Native Hawaiian"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Two or More Races"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian"
keep if StudentSubGroup == "All Students" | StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Native Hawaiian or Pacific Islander" | StudentSubGroup == "White" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "English Learner" | StudentSubGroup == "English Proficient" | StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged" | StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Two or More"

//Subject
replace Subject = "math" if strpos(Subject, "Math") !=0
replace Subject = "ela" if strpos(Subject, "ELA") !=0
replace Subject = "sci" if strpos(Subject, "Science") !=0

//StateAssignedSchID
replace StateAssignedSchID = "" if AggregationLevel == "State"


//Merging
merge 1:1 StateAssignedSchID StateAssignedDistID Subject GradeLevel StudentSubGroup using "${Output}/DC_AssmtData_2022", update
drop if _merge ==1
replace ParticipationRate = "--" if _merge ==2

//Missing/Suppressed
replace ParticipationRate = "*" if ParticipationRate == "n<40" | ParticipationRate == "n<25" | ParticipationRate == "n<10" | ParticipationRate == "DS"

//Converting to decimal
gen range = substr(ParticipationRate,1,1) if regexm(ParticipationRate, "[<>]") !=0
replace range = substr(ParticipationRate,1,2) if regexm(ParticipationRate,"=") !=0
destring ParticipationRate, gen(nParticipationRate) i(*-<>=%)
replace ParticipationRate = range + string(nParticipationRate/100, "%9.4g") if regexm(ParticipationRate, "[-*]") ==0

//Final Cleaning
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
 
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter SchType SchLevel SchVirtual CountyName CountyCode
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "${Output}/DC_AssmtData_2022", replace
export delimited "${Output}/DC_AssmtData_2022", replace

clear
	
	
