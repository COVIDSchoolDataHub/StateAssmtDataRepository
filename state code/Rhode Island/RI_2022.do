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
rename ncesschoolid NCESSchoolID
rename lea_name DistName
rename school_type SchType

** Label Variables

label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var DistCharter "Charter indicator"
label var NCESSchoolID "NCES school ID"
label var SchType "School type as defined by NCES"
label var SchVirtual "Virtual school indicator"
label var SchLevel "School level"

** Isolate Rhode Island Data

drop if StateFips != 44

** Correct School Misspellings

replace school_name = "Pleasant View Elementary School" if school_name=="Pleasant View Elementary Schoo"
replace school_name = "Providence Preparatory Charter School" if school_name=="Providence Preparatory Charter"

** Drop Excess Variables

drop year district_agency_type district_agency_type_num county_code county_name school_id school_name school_status DistEnrollment SchEnrollment dist_urban_centric_locale dist_bureau_indian_education dist_supervisory_union_number dist_agency_level dist_boundary_change_indicator dist_number_of_schools dist_spec_ed_students dist_english_language_learners dist_migrant_students dist_teachers_total_fte dist_staff_total_fte dist_other_staff_fte sch_lowest_grade_offered sch_highest_grade_offered sch_bureau_indian_education sch_charter sch_urban_centric_locale sch_lunch_program sch_free_lunch sch_reduced_price_lunch sch_free_or_reduced_price_lunch

** Fix Variable Types

decode State, gen(State2)
decode SchLevel, gen(SchLevel2)
decode SchType, gen(SchType2)
decode SchVirtual, gen(SchVirtual2)
drop State SchLevel SchType SchVirtual
rename State2 State
rename SchLevel2 SchLevel 
rename SchType2 SchType 
rename SchVirtual2 SchVirtual

save "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta", replace

** Isolate Highest and Lowest Grades Offered by Districts

tostring dist_lowest_grade_offered, generate(lowest_grade_district) force
tostring dist_highest_grade_offered, generate(highest_grade_district) force
destring lowest_grade_district, replace force
destring highest_grade_district, replace force
collapse (min) lowest_grade_district (max) highest_grade_district, by(State_leaid)
save "${path}/Semi-Processed Data Files/2021_22_NCES_District_Grades.dta", replace

** 2021-22 NCES District Data

clear
use "${path}/NCES/District/NCES_2021_District.dta"

** Rename Variables

rename ncesdistrictid NCESDistrictID
rename state_name State
rename state_leaid State_leaid
rename state_location StateAbbrev
rename county_code CountyCode
rename county_name CountyName
rename district_agency_type DistType
rename state_fips StateFips
tostring lowest_grade_offered, replace force
tostring highest_grade_offered, replace force
destring lowest_grade_offered, replace force
destring highest_grade_offered, replace force

** Drop Excess Variables

drop year lea_name urban_centric_locale bureau_indian_education supervisory_union_number agency_level boundary_change_indicator number_of_schools enrollment spec_ed_students english_language_learners migrant_students teachers_total_fte staff_total_fte other_staff_fte district_agency_type_num

** Label Variables

label var NCESDistrictID "NCES district ID"
label var State_leaid "State LEA ID"
label var CountyName "County in which the district or school is located."
label var DistCharter "Charter indicator"
label var CountyCode "County code in which the district or school is located, also referred to as the county-level FIPS code"
label var State "State name"
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
label var DistType "District type as defined by NCES"

* Isolate Rhode Island Data

drop if StateFips != 44
decode State, gen(State2)
decode DistType, gen(DistType2)
drop State DistType
rename State2 State
rename DistType2 DistType
merge m:1 State_leaid using "${path}/Semi-Processed Data Files/2021_22_NCES_District_Grades.dta"
drop _merge
save "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta", replace

** 2021-22 ELA State Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_ela_state.xlsx", sheet("By_State_AndGrade") firstrow clear
drop AL AK AJ AI AH AG
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2022_ela_state.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_ela_state.xlsx", sheet("By_State_Subgroups") firstrow clear
drop AL AK AJ AI AH
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "State"
gen StudentGroup_TotalTested = "59399"
save "${path}/Semi-Processed Data Files/2022_ela_state_subgroups.dta", replace

** 2021-22 ELA District Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_ela_district.xlsx", sheet("By_District_AndGrade") firstrow clear
drop AL AK AJ AI
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2022_ela_district.dta", replace

** Generate Student Group District Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_ela_district.xlsx", sheet("By_District") firstrow clear
destring E, generate(StudentGroup_TotalTested)
collapse (sum) StudentGroup_TotalTested, by(AssessmentName DistrictCode)
save "${path}/Semi-Processed Data Files/2022_ela_district_group.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_ela_district.xlsx", sheet("By_District_Subgroups") firstrow clear
merge m:1 AssessmentName DistrictCode using "${path}/Semi-Processed Data Files/2022_ela_district_group.dta"
drop _merge AL AK AJ
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2022_ela_district_subgroups.dta", replace

** 2021-22 ELA School Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", sheet("By_School_AndGrade") firstrow clear
drop AL AK
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "School"
save "${path}/Semi-Processed Data Files/2022_ela_school.dta", replace

** Generate Student Group School Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", sheet("By_School") firstrow clear
destring G, generate(StudentGroup_TotalTested)
collapse (sum) StudentGroup_TotalTested, by(AssessmentName SchoolCode)
save "${path}/Semi-Processed Data Files/2022_ela_school_group.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_ela.xlsx", sheet("By_School_Subgroups") firstrow clear
merge m:1 AssessmentName SchoolCode using "${path}/Semi-Processed Data Files/2022_ela_school_group.dta"
drop _merge AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2022_ela_school.dta" "${path}/Semi-Processed Data Files/2022_ela_district.dta" "${path}/Semi-Processed Data Files/2022_ela_district_subgroups.dta" "${path}/Semi-Processed Data Files/2022_ela_state.dta" "${path}/Semi-Processed Data Files/2022_ela_state_subgroups.dta"
rename _2021_22_Percent_Not_Meeting_Exp Lev1_percent
rename _2021_22_Percent_Partially_Meeti Lev2_percent
rename _2021_22_Percent_Meeting_Expecta Lev3_percent
rename _2021_22_Percent_Exceeding_Expec Lev4_percent
rename _2021_22_Percent_Meeting_Or_Exce ProficientOrAbove_percent
save "${path}/Semi-Processed Data Files/2022_ela.dta", replace

** 2021-22 Math State Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_mat_state.xlsx", sheet("By_State_AndGrade") firstrow clear
drop AL AK AJ AI AH AG
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2022_mat_state.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_mat_state.xlsx", sheet("By_State_Subgroups") firstrow clear
drop AL AK AJ AI AH
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "State"
gen StudentGroup_TotalTested = "59741"
save "${path}/Semi-Processed Data Files/2022_mat_state_subgroups.dta", replace

** 2021-22 Math District Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_mat_district.xlsx", sheet("By_District_AndGrade") firstrow clear
drop AL AK AJ AI
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2022_mat_district.dta", replace

** Generate Student Group District Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_mat_district.xlsx", sheet("By_District") firstrow clear
destring E, generate(StudentGroup_TotalTested)
collapse (sum) StudentGroup_TotalTested, by(AssessmentName DistrictCode)
save "${path}/Semi-Processed Data Files/2022_mat_district_group.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_mat_district.xlsx", sheet("By_District_Subgroups") firstrow clear
merge m:1 AssessmentName DistrictCode using "${path}/Semi-Processed Data Files/2022_mat_district_group.dta"
drop _merge AL AK AJ
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2022_mat_district_subgroups.dta", replace

** 2021-22 Math School Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_mat.xlsx", sheet("By_School_AndGrade") firstrow clear
drop AL AK
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "School"
save "${path}/Semi-Processed Data Files/2022_mat_school.dta", replace

** Generate Student Group School Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_mat.xlsx", sheet("By_School") firstrow clear
destring G, generate(StudentGroup_TotalTested)
collapse (sum) StudentGroup_TotalTested, by(AssessmentName SchoolCode)
save "${path}/Semi-Processed Data Files/2022_mat_school_group.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_mat.xlsx", sheet("By_School_Subgroups") firstrow clear
merge m:1 AssessmentName SchoolCode using "${path}/Semi-Processed Data Files/2022_mat_school_group.dta"
drop _merge AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2022_mat_school.dta" "${path}/Semi-Processed Data Files/2022_mat_district.dta" "${path}/Semi-Processed Data Files/2022_mat_district_subgroups.dta" "${path}/Semi-Processed Data Files/2022_mat_state.dta" "${path}/Semi-Processed Data Files/2022_mat_state_subgroups.dta"
rename _2021_22_Percent_Not_Meeting_Exp Lev1_percent
rename _2021_22_Percent_Partially_Meeti Lev2_percent
rename _2021_22_Percent_Meeting_Expecta Lev3_percent
rename _2021_22_Percent_Exceeding_Expec Lev4_percent
rename _2021_22_Percent_Meeting_Or_Exce ProficientOrAbove_percent
save "${path}/Semi-Processed Data Files/2022_mat.dta", replace

** 2021-22 Science State Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_sci_state.xlsx", sheet("By_State_AndGrade") firstrow clear
drop Y Z AA AB AC AD AE AF AG AH AI AJ AK AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "State"
save "${path}/Semi-Processed Data Files/2022_sci_state.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_sci_state.xlsx", sheet("By_State_Subgroups") firstrow clear
drop Z AA AB AC AD AE AF AG AH AI AJ AK AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "State"
gen StudentGroup_TotalTested = "20253"
save "${path}/Semi-Processed Data Files/2022_sci_state_subgroups.dta", replace

** 2021-22 Science District Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_sci_district.xlsx", sheet("By_District_AndGrade") firstrow clear
drop AA AB AC AD AE AF AG AH AI AJ AK AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2022_sci_district.dta", replace

** Generate Student Group District Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_sci_district.xlsx", sheet("By_District") firstrow clear
destring E, generate(StudentGroup_TotalTested)
collapse (sum) StudentGroup_TotalTested, by(AssessmentName DistrictCode)
save "${path}/Semi-Processed Data Files/2022_sci_district_group.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_sci_district.xlsx", sheet("By_District_Subgroups") firstrow clear
merge m:1 AssessmentName DistrictCode using "${path}/Semi-Processed Data Files/2022_sci_district_group.dta"
drop _merge AB AC AD AE AF AG AH AI AJ AK AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "District"
save "${path}/Semi-Processed Data Files/2022_sci_district_subgroups.dta", replace

** 2021-22 Science School Data

import excel "${path}/Original Data Files/RI_OriginalData_2022_sci.xlsx", sheet("By_School") firstrow clear
drop AB AC AD AE AF AG AH AI AJ AK AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "School"
save "${path}/Semi-Processed Data Files/2022_sci_school.dta", replace

** Generate Student Group School Data

destring _2021_22_Number_Tested, generate(StudentGroup_TotalTested)
collapse (sum) StudentGroup_TotalTested, by(AssessmentName SchoolCode)
save "${path}/Semi-Processed Data Files/2022_sci_school_group.dta", replace
import excel "${path}/Original Data Files/RI_OriginalData_2022_sci.xlsx", sheet("By_School_Subgroups") firstrow clear
merge m:1 AssessmentName SchoolCode using "${path}/Semi-Processed Data Files/2022_sci_school_group.dta"
drop _merge AD AE AF AG AH AI AJ AK AL
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
gen DataLevel = "School"
append using "${path}/Semi-Processed Data Files/2022_sci_school.dta" "${path}/Semi-Processed Data Files/2022_sci_district.dta" "${path}/Semi-Processed Data Files/2022_sci_district_subgroups.dta" "${path}/Semi-Processed Data Files/2022_sci_state.dta" "${path}/Semi-Processed Data Files/2022_sci_state_subgroups.dta"
rename _2021_22_Percent_Beginning_To_Me Lev1_percent
rename _2021_22_Percent_Approaching_Exp Lev2_percent
rename _2021_22_Percent_Meeting_Expecta Lev3_percent
rename _2021_22_Percent_Exceeds_Expecta Lev4_percent
rename _2021_22_Percent_Meeting_Or_Exce ProficientOrAbove_percent
save "${path}/Semi-Processed Data Files/2022_sci.dta", replace

** Merge 2021-22 Assessments

append using "${path}/Semi-Processed Data Files/2022_ela.dta" "${path}/Semi-Processed Data Files/2022_mat.dta"

** Rename Variables

rename AssessmentName AssmtName
rename DistrictCode StateAssignedDistID
rename DistrictName DistName
rename SchoolCode StateAssignedSchID
rename SchoolName SchName
rename Grade GradeLevel
rename Group StudentGroup
rename GroupName StudentSubGroup
rename _2021_22_Number_Tested StudentSubGroup_TotalTested
rename _2021_22_Average_Scale_Score AvgScaleScore
rename _2021_22_Percent_Tested ParticipationRate

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

** Generate Other Variables

gen Subject = "ela"
replace Subject = "math" if AssmtName == "RICAS - Mathematics"
replace Subject = "sci" if AssmtName == "NGSA - Science"
tostring _sum__StudentGroup_TotalTested, replace
replace StudentGroup_TotalTested = _sum__StudentGroup_TotalTested if StudentGroup_TotalTested == ""
gen AssmtType = "Regular"
gen ProficiencyCriteria = "Levels 3 and 4"

** Generate Empty Variables

gen ProficientOrAbove_count = "--"
gen Lev1_count = "--"
gen Lev2_count = "--"
gen Lev3_count = "--"
gen Lev4_count = "--"
gen Lev5_count = "--"
gen Lev5_percent = "--"

** Drop Excess Variables

drop _sum__StudentGroup_TotalTested _2021_22_Standard_Error _2021_22_Percent_Typical_Growth _2021_22_Percent_Low_Growth _2021_22_Percent_High_Growth _2021_22_Average_Student_Growth_ _2020_21_Standard_Error _2020_21_Percent_Typical_Growth _2020_21_Percent_Tested _2020_21_Percent_Partially_Meeti _2020_21_Percent_Not_Meeting_Exp _2020_21_Percent_Meeting_Or_Exce _2020_21_Percent_Meeting_Expecta _2020_21_Percent_Low_Growth _2020_21_Percent_High_Growth _2020_21_Percent_Exceeds_Expecta _2020_21_Percent_Exceeding_Expec _2020_21_Percent_Beginning_To_Me _2020_21_Percent_Approaching_Exp _2020_21_Number_Tested _2020_21_Average_Student_Growth_ _2020_21_Average_Scale_Score Change_in_Percent_Meeting_Or_Exc Percent_Tested_Change Statistically_Significant_

** Merge NCES District Data

gen state_leaidnumber =.
gen State_leaid = string(state_leaidnumber)
drop state_leaidnumber
replace State_leaid = "RI-" + StateAssignedDistID if DataLevel != "State"
label var State_leaid "State LEA ID"
gen seaschnumber=.
gen seasch = string(seaschnumber)
drop seaschnumber
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if DataLevel == "School"
merge  m:1 State_leaid using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_District.dta"
rename _merge district_merge

** Merge NCES School Data

destring StateFips, replace
merge m:1 seasch StateFips using "${path}/Semi-Processed Data Files/2021_22_NCES_Cleaned_School.dta"

** Drop Unmerged NCES Observations

drop if district_merge != 3 & _merge !=3 & DataLevel != "State"
keep if SchYear == "2021-22"
drop district_merge _merge

** Standardize Non-School Level Data

replace SchName = "All Schools" if DataLevel == "State"
replace SchName = "All Schools" if DataLevel == "District"
replace DistName = "All Districts" if DataLevel == "State"
replace StateAssignedDistID = "" if DataLevel == "State"
replace State_leaid = "" if DataLevel == "State"
replace seasch = "" if DataLevel == "State"

** Fix Variable Types

label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 
recast int CountyCode
drop State StateAbbrev StateFips
gen State = "Rhode Island"
gen StateAbbrev = "RI"
gen StateFips = 44
recast int StateFips

** Standardize State Data

replace State = "Rhode Island"
replace StateAbbrev = "RI"
replace StateFips = 44

** Relabel GradeLevel Values 

replace GradeLevel="G03" if GradeLevel=="03"
replace GradeLevel="G04" if GradeLevel=="04"
replace GradeLevel="G05" if GradeLevel=="05"
replace GradeLevel="G06" if GradeLevel=="06"
replace GradeLevel="G07" if GradeLevel=="07"
replace GradeLevel="G08" if GradeLevel=="08"
replace GradeLevel="G38" if DistName=="All Districts" & GradeLevel==""
replace GradeLevel="G38" if GradeLevel=="STATE"

** Relabel GradeLevel Values for School Data

replace GradeLevel="G08" if SchLevel=="Middle" & Subject=="sci"
replace GradeLevel="G05" if SchLevel=="Primary" & Subject=="sci"
replace lowest_grade_offered=-1 if lowest_grade_offered==.
replace highest_grade_offered=12 if highest_grade_offered==.
replace lowest_grade_offered=3 if lowest_grade_offered==-1 | lowest_grade_offered==0 | lowest_grade_offered==1 | lowest_grade_offered==2
tostring lowest_grade_offered, replace force
tostring highest_grade_offered, replace force
gen lowgrade = "0" + lowest_grade_offered
gen highgrade = "0" + highest_grade_offered
replace highgrade="08" if highgrade=="09" | highgrade=="010" | highgrade=="011" | highgrade=="012"
replace GradeLevel = "G" + lowgrade if lowgrade == highgrade & lowgrade !="" & highgrade !=""
replace GradeLevel = "G" + subinstr(lowgrade,"0", "", 1) + subinstr(highgrade,"0", "", 2) if GradeLevel=="" & Subject!="sci" & lowgrade !="" & highgrade !=""
replace GradeLevel= "G" + subinstr(lowest_grade_offered,"0", "", 1) + subinstr(highest_grade_offered,"0", "", 2) if GradeLevel=="" & lowest_grade_offered !="0" & highest_grade_offered !=""
drop dist_highest_grade_offered dist_lowest_grade_offered lowgrade highgrade

** Relabel GradeLevel Values for District Data

replace lowest_grade_district = 3 if lowest_grade_district <3
tostring lowest_grade_district, generate(str_lowest_grade_district)
tostring highest_grade_district, generate(str_highest_grade_district)
replace GradeLevel="G" + str_lowest_grade_district + str_highest_grade_district if GradeLevel=="" & highest_grade_district < 9 | GradeLevel=="" & Subject == "sci"
replace GradeLevel="G" + str_lowest_grade_district + "8" if GradeLevel=="" & highest_grade_district > 8 & highest_grade_district < 12 
replace GradeLevel="G" + str_lowest_grade_district + "8" if GradeLevel=="" & highest_grade_district == 12 & Subject != "sci" & lowest_grade_district != 8
replace GradeLevel="G08" if GradeLevel=="" & highest_grade_district == 12 & Subject != "sci" & lowest_grade_district == 8
drop str_lowest_grade_district str_highest_grade_district lowest_grade_district highest_grade_district lowest_grade_offered highest_grade_offered

** Relabel GradeLevel Values for Science Assessment Data

replace GradeLevel="G05" if GradeLevel=="G35" & Subject=="sci" | GradeLevel=="G36" & Subject=="sci" | GradeLevel=="G37" & Subject=="sci" | GradeLevel=="G38" & Subject=="sci" | GradeLevel=="G45" & Subject=="sci" | GradeLevel=="G56" & Subject=="sci"
replace GradeLevel="G05, G08" if GradeLevel=="G39" 
replace GradeLevel="G05, G08, G11" if GradeLevel=="G312" & Subject=="sci"
replace GradeLevel="G08" if GradeLevel=="G78" & Subject=="sci"
replace GradeLevel="G08, G11" if GradeLevel=="G612" | GradeLevel=="G712" | GradeLevel=="G812"
replace GradeLevel="G11" if GradeLevel=="11" | GradeLevel=="G912"

** Relabel Charter Values

replace DistCharter="Yes" if DistType=="Charter agency"
replace DistCharter="No" if DistType !="Charter agency"

** Standardize Assessment Names

replace AssmtName="RICAS" if AssmtName=="RICAS - Mathematics" | AssmtName=="RICAS - English Language Arts/Literacy" 
replace AssmtName="NGSA" if AssmtName=="NGSA - Science"

** Standardize Subgroup Data

replace StudentGroup="RaceEth" if StudentGroup=="Race/Ethnicity"
replace StudentGroup="EL Status" if StudentGroup=="English Learner"
replace StudentGroup="Economic Status" if StudentGroup=="Economically Disadvantaged"
drop if StudentGroup=="Homeless"
drop if StudentGroup=="Special Education"
drop if StudentGroup=="Accommodations"
drop if StudentGroup=="Migrant"
drop if StudentGroup=="Active Military Parent"
drop if StudentGroup=="Foster Care"
replace StudentGroup="All Students" if StudentGroup==""
replace StudentSubGroup="All Students" if StudentGroup=="All Students"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Two or More Races"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup="Unknown" if StudentSubGroup=="Other"
replace StudentSubGroup="English Learner" if StudentSubGroup=="Current English Learners"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="Not English Learners"
replace StudentSubGroup="Other" if StudentSubGroup=="Recently (3 yrs) Exited English Learners"
replace StudentGroup="All Students" if StudentGroup==""
replace StudentSubGroup="All Students" if StudentSubGroup==""
replace StudentGroup_TotalTested=StudentSubGroup_TotalTested if StudentGroup=="All Students"

** Standardize Suppressed Proficiency Data

replace Lev1_percent="*" if Lev1_percent=="**" | Lev1_percent=="***"
replace Lev2_percent="*" if Lev2_percent=="**" | Lev2_percent=="***"
replace Lev3_percent="*" if Lev3_percent=="**" | Lev3_percent=="***"
replace Lev4_percent="*" if Lev4_percent=="**" | Lev4_percent=="***"

** Convert Proficiency Data into Percentages

foreach v of varlist Lev* {
	destring `v', g(n`v') i(* -)
	replace n`v' = n`v' / 100 if n`v' != .
	tostring n`v', replace force
	replace `v' = n`v' if `v' != "*"
	drop n`v'
}

destring ProficientOrAbove_percent, generate(nProficientOrAbove_percent) force
replace nProficientOrAbove_percent = nProficientOrAbove_percent / 100 if nProficientOrAbove_percent != .
tostring nProficientOrAbove_percent, replace force
replace ProficientOrAbove_percent = nProficientOrAbove_percent if ProficientOrAbove_percent != "*"
drop nProficientOrAbove_percent
destring ParticipationRate, generate(nParticipationRate) force
replace nParticipationRate = nParticipationRate / 100 if nParticipationRate != .
tostring nParticipationRate, replace force
replace ParticipationRate = nParticipationRate if ParticipationRate != "*"
drop nParticipationRate

** Label Variables

rename State StateName
label var StateName "State name"
rename StateName State
label var StateAbbrev "State abbreviation"
label var StateFips "State FIPS Id"
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

** Fix Variable Order 

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

** Drop 11th Grade Science Assessment Data

drop if GradeLevel == "G11"

** Export 2021-22 Assessment Data

save "${path}/Semi-Processed Data Files/RI_AssmtData_2022.dta", replace
export delimited using "${path}/Output/RI_AssmtData_2022.csv", replace
