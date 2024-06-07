clear
set more off
set trace off
global original "/Volumes/T7/State Test Project/Hawaii/Original Data"
global cleaned  "/Volumes/T7/State Test Project/Hawaii/Output"
global nces "/Volumes/T7/State Test Project/Hawaii/NCES/NCESCLEANED/"

//loop for 2013 and 2014 school level(2012-13 and 2013-14 years)
foreach year in 2013 2014 {
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
merge m:1 StateAssignedSchID using "${nces}/NCES_`prevyear'_school.dta", force
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
replace GradeLevel2="G38" if GradeLevel=="Elementary"
replace GradeLevel2="G38" if GradeLevel=="Middle"
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
gen Lev5_count=""
gen Lev5_percent=""
gen AvgScaleScore="--"
gen ProficiencyCriteria="Levels 3-4"
gen ProficientOrAbove_count="--"
gen ParticipationRate="--"
gen Flag_AssmtNameChange ="N"
gen Flag_CutScoreChange_ELA=""
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

//Response to R2
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."

//Fixing AssmtName for HI
replace AssmtName = "Hawaii Science Assessment" if Subject == "sci"

//Replacing Subject with "ela" for reading
replace Subject = "ela" if Subject == "read"
replace Flag_CutScoreChange_ELA = Flag_CutScoreChange_read if missing(Flag_CutScoreChange_ELA) & !missing(Flag_CutScoreChange_read)
replace Flag_CutScoreChange_read = ""

//Post Launch Response to Review
gen Flag_CutScoreChange_sci = Flag_CutScoreChange_oth
gen Flag_CutScoreChange_soc = ""
*DistLocale (One District In HI)
gen DistLocale = "Suburb, large"
replace DistName = "Hawaii Department of Education"
replace CountyName = proper(CountyName)
replace Flag_CutScoreChange_soc = "Not applicable"

//Order Keep Sort
order State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode
keep State StateAbbrev StateFips SchYear DataLevel DistName SchName NCESDistrictID StateAssignedDistID NCESSchoolID StateAssignedSchID AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_sci Flag_CutScoreChange_soc DistType DistCharter DistLocale SchType SchLevel SchVirtual CountyName CountyCode  
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Exporting


save "${cleaned}/HI_AssmtData_`year'.dta", replace
export delimited using "${cleaned}/HI_AssmtData_`year'.csv", replace
clear
}
*do "/Volumes/T7/State Test Project/Hawaii/hawaii2015-2019_2021-2022.do"
