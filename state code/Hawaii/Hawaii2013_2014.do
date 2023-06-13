clear
set more off
set trace off
global original "G:\Test Score Repository Project\Hawaii\Original Data"
global cleaned  "G:\Test Score Repository Project\Hawaii\Cleaned Data"
global nces "G:\Test Score Repository Project\Hawaii\NCES"

//loop for 2013 and 2014 school level(2012-13 and 2013-14 years)
foreach year of numlist 2013 2014 {
import excel "${original}/HI_OriginalData_`year'_all", sheet ("School Data") cellrange(a1) firstrow case(preserve)

//reshaping from wide to long
rename MathProficiency ProficientOrAbove_percentmath
rename ReadingProficiency ProficientOrAbove_percentread
rename ScienceProficiency ProficientOrAbove_percentsci

reshape long ProficientOrAbove_percent, i(SchoolID) j(Subject,string)

//merging NCES data
rename SchoolID StateAssignedSchID
tostring StateAssignedSchID, replace
local prevyear =`=`year'-1'
merge m:1 StateAssignedSchID using "G:\Test Score Repository Project\Hawaii\NCES\NCESCLEANED/NCES_`prevyear'_school.dta", force
drop if Year==.

//reformatting
decode State, gen (state1)
drop State
rename state1 State
decode SchType, gen (Schtype1)
drop SchType
rename Schtype1 SchType
decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel
decode DistType, gen (Disttype1)
drop DistType
rename Disttype1 DistType


//renaming and generating variables
drop Year
gen SchYear = "`prevyear'"+ "-" + substr("`year'",-2,2)
gen DataLevel="School"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
rename SchoolTypeforStriveHI GradeLevel
gen GradeLevel2=.
tostring GradeLevel2, replace

//data aggregated into elementary and middle school, reflected below
replace GradeLevel2="--" if GradeLevel=="Elementary"
replace GradeLevel2="--" if GradeLevel=="Middle"
drop GradeLevel
rename GradeLevel2 GradeLevel
drop if GradeLevel=="."
gen AssmtName = "Hawaii State Assessment"
gen AssmtType = "Regular"
gen StudentGroup = "All Students"
gen StudentGroup_TotalTested="--"
gen StudentSubGroup= "All Students"
gen StudentSubGroup_TotalTested="--"
gen StateAssignedDistID="HI-001"
gen Lev1_count ="--"
gen Lev1_percent="--"
gen Lev2_count="--"
gen Lev2_percent="--"
gen Lev3_count="--"
gen Lev3_percent="--"
gen Lev4_count="--"
gen Lev4_percent="--"
gen Lev5_count="--"
gen Lev5_percent="--"
gen AvgScaleScore="--"
gen ProficiencyCriteria="Level 3 or 4"
gen ProficientOrAbove_count="--"
gen ParticipationRate="--"
gen Flag_AssmtNameChange ="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read="N"
gen Flag_CutScoreChange_oth="N"

//reformatting


//formatting ProficientOrAbove_percent as decimal
gen temp_var = real(ProficientOrAbove_percent) if regexm(ProficientOrAbove_percent, "^[0-9\.]+$") & ProficientOrAbove_percent != ""
replace temp_var = round(temp_var/100, .001) if temp_var != .
tostring temp_var, format(%10.3f) gen(ProficientOrAbove_decimal) force
drop temp_var
drop ProficientOrAbove_percent
rename ProficientOrAbove_decimal ProficientOrAbove_percent
//the code above works for some reason, idk why but not questioning

//Ordering Variables and Dropping Extraneous Variables
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

//sorting
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Exporting


save "${cleaned}/HI_AssmtData_`year'.dta", replace
export delimited using "${cleaned}/HI_AssmtData_`year'.csv", replace
clear
}