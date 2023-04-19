clear

global path "/Users/willtolmie/Documents/State Repository Research/Rhode Island"

** 2021-22 NCES School Data

use "${path}/NCES/School/NCES_2021_School.dta"

** Rename Variables

rename state_name State
rename state_location StateAbbrev
rename state_fips StateFips
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename charter_text Charter
rename ncesschoolid NCESSchoolID
rename virtual Virtual 
rename school_level SchoolLevel
rename lea_name DistName
rename school_type SchoolType

** Label Variables

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var Charter "Charter indicator"
label var NCESSchoolID "NCES school ID"
label var SchoolType "School type as defined by NCES"
label var Virtual "Virtual school indicator"
label var SchoolLevel "School level"

** Isolate Rhode Island Data

drop if StateFips != 44

** Generate seasch Variable

gen seaschnumber=. 
gen seasch = string(seaschnumber)
replace seasch = subinstr(st_schid,"RI-", "", 1)

** Correct School Misspellings
replace school_name = "Pleasant View Elementary School" if school_name=="Pleasant View Elementary Schoo"
replace school_name = "Providence Preparatory Charter School" if school_name=="Providence Preparatory Charter"

** Drop Excess Variables

drop year urban_centric_locale bureau_indian_education lunch_program free_lunch reduced_price_lunch free_or_reduced_price_lunch enrollment school_status st_schid schid seaschnumber county_name county_code school_name
save "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta", replace

** Isolate New Districts from 2021-22 NCES District Data

import delimited "/Users/willtolmie/Desktop/NCES_2021_District.csv", case(preserve) clear 
drop if StateFips != 44
drop if updated_status_text != "New"
replace Charter = "Yes" if Charter == "LEA for federal programs"
drop CountyName CountyCode updated_status_text effective_date
gen CountyName = "Providence County"
gen CountyCode = 44007
save "${path}/Semi-Processed Data Files/2021_22_NCES_District_New.dta", replace

** 2020-21 NCES District Data

clear
use "${path}/NCES/District/NCES_2020_District.dta"

** Rename Variables

rename ncesdistrictid NCESDistrictID
rename state_name State
rename state_leaid State_leaid
rename state_location StateAbbrev
rename county_code CountyCode
rename county_name CountyName
rename district_agency_type DistrictType
rename state_fips StateFips

** Drop Excess Variables

drop year lea_name

** Label Variables

label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistrictType "District type as defined by NCES"

* Isolate Rhode Island Data and Combine 2020-21 and 2021-22 NCES District Data

drop if StateFips != 44
decode State, gen(State2)
decode DistrictType, gen(DistrictType2)
drop State DistrictType
rename State2 State
rename DistrictType2 DistrictType
destring NCESDistrictID, replace
append using "${path}/Semi-Processed Data Files/2021_22_NCES_District_New.dta"
save "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta", replace

** 2021-22 ELA Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", sheet("By_School_AndGrade") firstrow clear

** Standardize Variable Names in Grade Data

rename H StudentSubGroup_TotalTested
rename I ParticipationRate
rename J Lev1_percent
rename K Lev2_percent
rename L Lev3_percent
rename M Lev4_percent
rename N ProficientOrAbove_percent
rename O AvgScaleScore
rename P AverageStudentGrowthPercentile
rename Q PercentLowGrowth
rename R PercentTypicalGrowth
rename S PercentHighGrowth
rename T StandardError

** Drop Excess Variables

drop U V W X Y Z AA AB AC AD AE AF AG
save "${path}/Semi-Processed Data Files/2022_ela_grade_unmerged.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", sheet("By_School_Subgroups") firstrow clear

** Standardize Variable Names in Subgroup Data

rename I StudentSubGroup_TotalTested
rename J ParticipationRate
rename K Lev1_percent
rename L Lev2_percent
rename M Lev3_percent
rename N Lev4_percent
rename O ProficientOrAbove_percent
rename P AvgScaleScore
rename Q AverageStudentGrowthPercentile
rename R PercentLowGrowth
rename S PercentTypicalGrowth
rename T PercentHighGrowth
rename U StandardError

** Drop Excess Variables

drop V W X Y Z AA AB AC AD AE AF AG AH
save "${path}/Semi-Processed Data Files/2022_ela_subgroups.dta", replace

** Generate Student Group Data

drop if Group != "Gender"
destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(AssessmentName SchoolCode)
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "${path}/Semi-Processed Data Files/2022_ela_groups.dta", replace
clear
use "${path}/Semi-Processed Data Files/2022_ela_subgroups.dta"
merge m:1 AssessmentName SchoolCode using "/Users/willtolmie/Documents/State Repository Research/Rhode Island/Semi-Processed Data Files/2022_ela_groups.dta"
drop if _merge != 3
drop _merge

** Merge Grade and Subgroup Data

append using "${path}/Semi-Processed Data Files/2022_ela_grade_unmerged.dta"
save "${path}/Semi-Processed Data Files/2022_ela_unmerged.dta", replace

** 2021-22 Math Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_mat.xlsx", sheet("By_School_AndGrade") firstrow clear

** Standardize Variable Names in Grade Data

rename H StudentSubGroup_TotalTested
rename I ParticipationRate
rename J Lev1_percent
rename K Lev2_percent
rename L Lev3_percent
rename M Lev4_percent
rename N ProficientOrAbove_percent
rename O AvgScaleScore
rename P AverageStudentGrowthPercentile
rename Q PercentLowGrowth
rename R PercentTypicalGrowth
rename S PercentHighGrowth
rename T StandardError

** Drop Excess Variables

drop U V W X Y Z AA AB AC AD AE AF AG
save "${path}/Semi-Processed Data Files/2022_math_grade_unmerged.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_mat.xlsx", sheet("By_School_Subgroups") firstrow clear

** Standardize Variable Names in Subgroup Data

rename I StudentSubGroup_TotalTested
rename J ParticipationRate
rename K Lev1_percent
rename L Lev2_percent
rename M Lev3_percent
rename N Lev4_percent
rename O ProficientOrAbove_percent
rename P AvgScaleScore
rename Q AverageStudentGrowthPercentile
rename R PercentLowGrowth
rename S PercentTypicalGrowth
rename T PercentHighGrowth
rename U StandardError

** Drop Excess Variables

drop V W X Y Z AA AB AC AD AE AF AG AH
save "${path}/Semi-Processed Data Files/2022_math_subgroups.dta", replace

** Generate Student Group Data

drop if Group != "Gender"
destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(AssessmentName SchoolCode)
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "${path}/Semi-Processed Data Files/2022_math_groups.dta", replace
clear
use "${path}/Semi-Processed Data Files/2022_math_subgroups.dta"
merge m:1 AssessmentName SchoolCode using "/Users/willtolmie/Documents/State Repository Research/Rhode Island/Semi-Processed Data Files/2022_math_groups.dta"
drop if _merge != 3
drop _merge

** Merge Grade and Subgroup Data

append using "${path}/Semi-Processed Data Files/2022_math_grade_unmerged.dta"
save "${path}/Semi-Processed Data Files/2022_math_unmerged.dta", replace

** 2021-22 Science Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_sci.xlsx", sheet("By_School") firstrow clear

** Standardize Variable Names in All Students Data

rename G StudentSubGroup_TotalTested
rename H ParticipationRate
rename I Lev1_percent
rename J Lev2_percent
rename K Lev3_percent
rename L Lev4_percent
rename M ProficientOrAbove_percent
rename N AvgScaleScore
rename O StandardError

** Drop Excess Variables

drop P Q R S T U V W X
save "${path}/Semi-Processed Data Files/2022_sci_all_unmerged.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_sci.xlsx", sheet("By_School_Subgroups") firstrow clear

** Standardize Variable Names in Subgroup Data

rename I StudentSubGroup_TotalTested
rename J ParticipationRate
rename K Lev1_percent
rename L Lev2_percent
rename M Lev3_percent
rename N Lev4_percent
rename O ProficientOrAbove_percent
rename P AvgScaleScore
rename Q StandardError

** Drop Excess Variables

drop R S T U V W X Y Z
save "${path}/Semi-Processed Data Files/2022_sci_subgroups.dta", replace

** Generate Student Group Data
drop if Group != "Gender"
destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(AssessmentName SchoolCode)
rename StudentSubGroup_TotalTested StudentGroup_TotalTested
save "${path}/Semi-Processed Data Files/2022_sci_groups.dta", replace
clear
use "${path}/Semi-Processed Data Files/2022_sci_all_unmerged.dta"
merge m:1 AssessmentName SchoolCode using "/Users/willtolmie/Documents/State Repository Research/Rhode Island/Semi-Processed Data Files/2022_sci_groups.dta"
drop if _merge != 3
drop _merge

** Merge All Students and Subgroup Data

append using "${path}/Semi-Processed Data Files/2022_sci_subgroups.dta"

** Merge 2021-22 Assessments

append using "${path}/Semi-Processed Data Files/2022_ela_unmerged.dta" "${path}/Semi-Processed Data Files/2022_math_unmerged.dta"

** Rename Variables

rename AssessmentName AssmtName
rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Group StudentGroup
rename GroupName StudentSubGroup

** Generate Flags

gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_read = ""
gen Flag_CutScoreChange_oth = "N"

** Label Flags

label var Flag_AssmtNameChange "Flag denoting a change in the assessment's name from the prior year only."
label var Flag_CutScoreChange_ELA "Flag denoting a change in scoring determinations in ELA from the prior year only."
label var Flag_CutScoreChange_math "Flag denoting a change in scoring determinations in math from the prior year only."
label var Flag_CutScoreChange_read "Flag denoting a change in scoring determinations in reading from the prior year only."
label var Flag_CutScoreChange_oth "Flag denoting a change in scoring determinations in subjects other than ELA, math, or reading from the prior year only (e.g., writing, STEM)."

** Generate Other Variables

gen Subject = "ela"
replace Subject = "math" if AssmtName == "RICAS - Mathematics"
replace Subject = "sci" if AssmtName == "NGSA - Science"
gen AssmtType = "Regular"
gen DataLevel = "School"
gen ProficiencyCriteria = "Levels 3 and 4"

** Generate Empty Variables

gen ProficientOrAbove_count = .
gen Lev1_count = .
gen Lev2_count = .
gen Lev3_count = .
gen Lev4_count = .
gen Lev5_percent = .
gen Lev5_count = .

** Label Variables

label var SchYear "School year in which the data were reported. (e.g., 2021-22)"
label var AssmtName "Name of state assessment"
label var AssmtType "Assessment type"
label var DataLevel "Level at which the data are reported"
label var DistName "District name"
label var StateAssignedDistID "State-assigned district ID"
label var SchName "School name"
label var StateAssignedSchID "State-assigned school ID"
label var Subject "Assessment subject area"
label var GradeLevel "Grade tested (Individual grade levels, Gr3-8, all grades)"
label var StudentGroup "Student demographic group"
label var StudentSubGroup "Student demographic subgroup"
label var StudentGroup_TotalTested "Number of students in the designated StudentGroup who were tested."
label var StudentSubGroup_TotalTested "Number of students in the designated Student Sub-Group who were tested."
label var Lev1_count "Count of students within subgroup performing at Level 1."
label var Lev1_percent "Percent of students within subgroup performing at Level 1."
label var Lev2_count "Count of students within subgroup performing at Level 2."
label var Lev2_percent "Percent of students within subgroup performing at Level 2."
label var Lev3_count "Count of students within subgroup performing at Level 3."
label var Lev3_percent "Percent of students within subgroup performing at Level 3 ."
label var Lev4_count "Count of students within subgroup performing at Level 4."
label var Lev4_percent "Percent of students within subgroup performing at Level 4."
label var Lev5_count "Count of students within subgroup performing at Level 5."
label var Lev5_percent "Percent of students within subgroup performing at Level 5."
label var AvgScaleScore "Avg scale score within subgroup."
label var ProficiencyCriteria "Levels included in determining proficiency status."
label var ProficientOrAbove_count "Count of students achieving proficiency or above on the state assessment."
label var ProficientOrAbove_percent "Percent of students achieving proficiency or above on the state assessment."
label var ParticipationRate "Participation rate."

** Drop Excess Variables

drop StandardError PercentTestedChange ChangeinPercentMeetingOrExc StatisticallySignificant AverageStudentGrowthPercentile PercentLowGrowth PercentTypicalGrowth PercentHighGrowth AB AC AD AE AF AG AH AI AJ AK AL

** Merge NCES District Data

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
drop state_leaidnumber
replace State_leaid = "RI-" + StateAssignedDistID 
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
drop seaschnumber
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID
merge  m:1 State_leaid using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta"
rename _merge district_merge

** Merge NCES School Data

destring StateFips, replace
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta"

** Drop Unmerged NCES Observations

drop if district_merge != 3
drop district_merge _merge 

** Standardize Variable Types

destring StudentGroup_TotalTested, replace
destring StudentSubGroup_TotalTested, replace
destring Lev1_count, replace
destring Lev1_percent, replace
destring Lev2_count, replace
destring Lev2_percent, replace
destring Lev3_count, replace
destring Lev3_percent, replace
destring Lev4_count, replace
destring Lev4_percent, replace
destring Lev5_count, replace
destring Lev5_percent, replace
destring AvgScaleScore, replace
destring ProficientOrAbove_count, replace
destring ProficientOrAbove_percent, replace
destring ParticipationRate, replace
destring NCESDistrictID, replace
destring CountyCode, replace
destring NCESSchoolID, replace

** Relabel GradeLevel Values

drop if SchoolLevel=="High"
replace GradeLevel="G03" if GradeLevel=="03"
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G06" if GradeLevel=="06"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"
replace GradeLevel="G08" if SchoolLevel=="Middle" & AssmtName=="NGSA - Science"
replace GradeLevel="G05" if SchoolLevel=="Primary" & AssmtName=="NGSA - Science"
replace lowest_grade_offered="03" if lowest_grade_offered=="PK"
replace lowest_grade_offered="03" if lowest_grade_offered=="KG"
replace lowest_grade_offered="03" if lowest_grade_offered=="01"
replace lowest_grade_offered="03" if lowest_grade_offered=="02"
replace highest_grade_offered="08" if highest_grade_offered=="09"
replace highest_grade_offered="08" if highest_grade_offered=="10"
replace highest_grade_offered="08" if highest_grade_offered=="11"
replace highest_grade_offered="08" if highest_grade_offered=="12"
gen graderangenumber=.
gen graderange = string(graderangenumber)
replace graderange = "G" + lowest_grade_offered + highest_grade_offered
replace GradeLevel="G03" if graderange=="G0303"
replace GradeLevel="G04" if graderange=="G0404"
replace GradeLevel="G05" if graderange=="G0505"
replace GradeLevel="G06" if graderange=="G0606"
replace GradeLevel="G07" if graderange=="G0707"
replace GradeLevel="G08" if graderange=="G0808"
replace GradeLevel = subinstr(graderange,"0", "", 2) if GradeLevel=="" & Subject!="sci"
replace GradeLevel="G05" if graderange=="G0305" & Subject=="sci"
replace GradeLevel="G05" if graderange=="G0306" & Subject=="sci" 
replace GradeLevel="G05" if graderange=="G0307" & Subject=="sci"
replace GradeLevel="G05, G08" if graderange=="G0308" & Subject=="sci"
replace GradeLevel="G05" if graderange=="G0405" & Subject=="sci"
replace GradeLevel="G05" if graderange=="G0506" & Subject=="sci" 
replace GradeLevel="G05" if graderange=="G0507" & Subject=="sci"
replace GradeLevel="G05, G08" if graderange=="G0508" & Subject=="sci"
replace GradeLevel="G08" if graderange=="G0608" & Subject=="sci"
replace GradeLevel="G08" if graderange=="G0708" & Subject=="sci" 
drop lowest_grade_offered highest_grade_offered graderangenumber graderange

** Relabel Charter Values
replace Charter="Yes" if DistrictType=="Charter agency"
replace Charter="No" if DistrictType !="Charter agency"

** Standardize Assessment Names

replace AssmtName="RICAS" if AssmtName=="RICAS - Mathematics" | AssmtName=="RICAS - English Language Arts/Literacy" 
replace AssmtName="NGSA" if AssmtName=="NGSA - Science"

** Standardize Subgroup Data

replace StudentGroup="Race" if StudentGroup=="Race/Ethnicity"
replace StudentGroup="EL status" if StudentGroup=="English Learner"
drop if StudentGroup=="Homeless"
drop if StudentGroup=="Special Education"
drop if StudentGroup=="Accommodations"
drop if StudentGroup=="Migrant"
drop if StudentGroup=="Active Military Parent"
drop if StudentGroup=="Foster Care"
drop if StudentGroup=="Economically Disadvantaged"
replace StudentGroup="All students" if StudentGroup==""
replace StudentSubGroup="All students" if StudentGroup=="All students"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
replace StudentSubGroup="English learner" if StudentSubGroup=="Current English Learners"
replace StudentSubGroup="English proficient" if StudentSubGroup=="Not English Learners"
replace StudentSubGroup="Other" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"
replace StudentGroup="All students" if StudentGroup==""
replace StudentSubGroup="All students" if StudentSubGroup==""
replace StudentGroup_TotalTested=StudentSubGroup_TotalTested if StudentGroup=="All students"
save "${path}/Semi-Processed Data Files/2022_missing_studentgroup_totaltested.dta", replace

* Fix Variable Order 

order State StateAbbrev StateFips NCESDistrictID State_leaid DistrictType Charter CountyName CountyCode NCESSchoolID SchoolType Virtual seasch SchoolLevel SchYear AssmtName Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth AssmtType DataLevel DistName StateAssignedDistID SchName StateAssignedSchID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate

** Export 2021-22 Assessment Data

save "${path}/Semi-Processed Data Files/RI_AssmtData_2022.dta", replace
export delimited using "${path}/Output/RI_AssmtData_2022.csv", replace
