clear
set more off
set trace off
global original "/Volumes/T7/State Test Project/Hawaii/Original Data"
global cleaned  "/Volumes/T7/State Test Project/Hawaii/Cleaned Data"
global nces "/Volumes/T7/State Test Project/Hawaii/NCES/NCESCLEANED"

//Schools 

foreach year of numlist 2015 2016 2017 2018 2019 2021 2022 {
	
	if `year' < 2017 {
        local sheet_name = "Schools"
    }
    else {
        local sheet_name = "SCHOOLS"
    }

import excel "${original}/HI_OriginalData_`year'_all", sheet ("`sheet_name'") cellrange(a1) firstrow case(preserve)

//for 2022 ONLY to include Sci test data

if `year'==2022 {
	drop in 1/5
	replace C = C[_n-1] if missing(C)
	save "${original}/HI_OriginalData_2022_all", replace 
	clear
	import excel "${original}/HI_OriginalData_2022_sci", sheet ("SCHOOLS") cellrange(a1) firstrow case(preserve)

	drop in 1/6
	replace C = C[_n-1] if missing(C)
	rename F number_tested_sci
	rename G ProficientOrAbove_percent_sci
	gen ProficientOrAbove_count_sci=.
	gen ProficientOrAbove_percent_sci1= real(ProficientOrAbove_percent_sci)
	gen sci_number_tested1 = real(number_tested_sci)
	replace ProficientOrAbove_count_sci = round(ProficientOrAbove_percent_sci1 * sci_number_tested1) if !missing(ProficientOrAbove_percent_sci1, sci_number_tested1)
	drop ProficientOrAbove_percent_sci1 sci_number_tested1
	drop if E==""

	save "${original}/HI_OriginalData_2022_sci", replace

	use "${original}/HI_OriginalData_2022_all"
	merge m:1 C E using "${original}/HI_OriginalData_2022_sci", force
	drop _merge
	//will say many not matched in stata, but only grades 5 and 8 take science. There were 277 obs matched. there are 278 obs in grade 5 and 8 in the science data.
	 
}

//renaming and dropping
rename B Complex
rename C StateAssignedSchID
rename D SchName
rename E GradeLevel
rename F number_tested_ela
rename G ProficientOrAbove_percent_ela
rename H number_tested_math
rename I ProficientOrAbove_percent_math
drop in 1/5 //dropping empty rows
drop if GradeLevel==""
if `year' == 2015 {
    // GradeLevel is a string of numbers in 2015
    gen temp = "G0" + GradeLevel
    replace GradeLevel = temp
    drop temp
}
else {
    // GradeLevel is a string "Grade X" in other years
    destring GradeLevel, replace ignore("Grade " "High School")
    tostring GradeLevel, replace
    replace GradeLevel="G03" if GradeLevel=="3"
    replace GradeLevel="G04" if GradeLevel=="4"
    replace GradeLevel="G05" if GradeLevel=="5"
    replace GradeLevel="G06" if GradeLevel=="6"
    replace GradeLevel="G07" if GradeLevel=="7"
    replace GradeLevel="G08" if GradeLevel=="8"
	drop if GradeLevel=="11"
	drop if GradeLevel=="."
}

//defining prevyear macro

local prevyear =`=`year'-1'

//filling each row with correct SchID and SchName

replace StateAssignedSchID = StateAssignedSchID[_n-1] if missing(StateAssignedSchID)
replace SchName = SchName[_n-1] if missing(SchName)

//adding Variables including empty variables
gen DataLevel= "School"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel 
gen SchYear = "`prevyear'"+ "-" + substr("`year'",-2,2)
gen DistName = "All Schools"
gen StateAssignedDistID="HI-001"
gen AssmtName = "Smarter Balanced Assessment"
gen AssmtType = "Regular"
gen StudentGroup = "All Students"
gen StudentSubGroup= "All Students"
gen StudentSubGroup_TotalTested=""
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
gen ProficiencyCriteria= "Level 3 or 4"
gen ProficientOrAbove_count_ela=.
gen ProficientOrAbove_percent_ela1= real(ProficientOrAbove_percent_ela)
gen ela_number_tested1 = real(number_tested_ela)
replace ProficientOrAbove_count_ela = round(ProficientOrAbove_percent_ela1 * ela_number_tested1) if !missing(ProficientOrAbove_percent_ela1, ela_number_tested1)
drop ProficientOrAbove_percent_ela1 ela_number_tested1
gen ProficientOrAbove_count_math=.
gen ProficientOrAbove_percent_math1= real(ProficientOrAbove_percent_math)
gen math_number_tested1 = real(number_tested_math)
replace ProficientOrAbove_count_math = round(ProficientOrAbove_percent_math1 * math_number_tested1) if !missing(ProficientOrAbove_percent_math1, math_number_tested1)
drop ProficientOrAbove_percent_math1 math_number_tested1

//more variables
gen Flag_AssmtNameChange ="N" 
replace Flag_AssmtNameChange = "Y" if `year'==2015
gen Flag_CutScoreChange_ELA= "N"
replace Flag_CutScoreChange_ELA = "Y" if `year'==2015
gen Flag_CutScoreChange_math= "N"
replace Flag_CutScoreChange_math = "Y" if `year'==2015
gen Flag_CutScoreChange_read=.
gen Flag_CutScoreChange_oth= "N"
replace Flag_CutScoreChange_oth = "Y" if `year'==2015
gen ParticipationRate= "--"
//Merge NCES School File
merge m:1 StateAssignedSchID using "${nces}/NCES_`prevyear'_School.dta", force
drop _merge


//dropping extra observations
drop if GradeLevel==""

//formatting DistName
tostring DistName, replace
replace DistName= "Hawaii Department of Education"

//reshaping
reshape long ProficientOrAbove_percent_ ProficientOrAbove_count_ number_tested_, i(StateAssignedSchID GradeLevel) j(Subject,string)
rename ProficientOrAbove_percent_ ProficientOrAbove_percent
rename ProficientOrAbove_count_ ProficientOrAbove_count
rename number_tested_ StudentGroup_TotalTested
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested



//misc
if `year'==2022 {
	replace SchName= "Aina Haina Elementary" if StateAssignedSchID=="100"
}
tostring ProficientOrAbove_count, replace

//ordering and dropping extra variables
drop if GradeLevel=="11" //still obs from grade 11 left idk why but dropping here
drop if StudentGroup_TotalTested==""
order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

//sorting
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Exporting
save "${cleaned}/HI_AssmtDataSchool_`year'.dta", replace
export delimited using "${cleaned}/HI_AssmtData_`year'.csv", replace
clear
}

//States (yes I know this order is extremely inefficient)
clear
foreach year of numlist 2015 2016 2017 2018 2019 2021 2022 {
	
	if `year' < 2017 {
        local sheet_name = "State"
    }
    else {
        local sheet_name = "STATE"
    }

	
import excel "${original}/HI_OriginalData_`year'_all", sheet ("`sheet_name'") clear
*import excel "G:\Test Score Repository Project\Hawaii\Original Data\HI_OriginalData_2019_all.xlsx", sheet("STATE") clear

//basic formatting and reshaping
drop in 1/5
rename A GradeLevel
rename B number_testedela
rename C ProficientOrAbove_countela
rename D ProficientOrAbove_percentela
rename E number_testedmath
rename F ProficientOrAbove_countmath
rename G ProficientOrAbove_percentmath

reshape long number_tested ProficientOrAbove_count ProficientOrAbove_percent, i(GradeLevel) j(Subject, string)
destring GradeLevel, replace ignore("Grade " "High School" "TOTAL")
    tostring GradeLevel, replace
    replace GradeLevel="G03" if GradeLevel=="3"
    replace GradeLevel="G04" if GradeLevel=="4"
    replace GradeLevel="G05" if GradeLevel=="5"
    replace GradeLevel="G06" if GradeLevel=="6"
    replace GradeLevel="G07" if GradeLevel=="7"
    replace GradeLevel="G08" if GradeLevel=="8"
//Data Level
gen DataLevel="State"
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel

//adding all state level variables
rename number_tested StudentGroup_TotalTested
gen State="Hawaii"
gen StateAbbrev="HI"
gen StateFips=15
local prevyear =`=`year'-1'
gen SchYear = "`prevyear'"+ "-" + substr("`year'",-2,2)
gen AssmtName="Smarter Balanced Assessment"
gen AssmtType="Regular"
gen StudentGroup = "All Students"
gen StudentSubGroup= "All Students"
gen StudentSubGroup_TotalTested= StudentGroup_TotalTested
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
gen ProficiencyCriteria= "Level 3 or 4"
gen Flag_AssmtNameChange ="N" 
replace Flag_AssmtNameChange = "Y" if `year'==2015
gen Flag_CutScoreChange_ELA= "N"
replace Flag_CutScoreChange_ELA = "Y" if `year'==2015
gen Flag_CutScoreChange_math= "N"
replace Flag_CutScoreChange_math = "Y" if `year'==2015
gen Flag_CutScoreChange_read=.
gen Flag_CutScoreChange_oth= "N"
gen ParticipationRate= "--"
gen DistName = "All Districts"
gen SchName = "All Schools"

//for 2022 science data only
if `year'==2022 {
	set obs 20
	
	replace GradeLevel="G05" in 19
	replace Subject="sci" in 19
	replace StudentGroup_TotalTested="12501" in 19
	replace ProficientOrAbove_count="5623" in 19
	replace ProficientOrAbove_percent = ".45" in 19
	replace State = "Hawaii" in 19
	replace StateAbbrev = "HI" in 19
	replace StateAbbrev = "HI" in 19
	replace StateFips = 15 in 19
	replace SchYear = "2021-22" in 19
	replace AssmtName = "Smarter Balanced Assessment" in 19
	replace AssmtType = "Regular" in 19
	replace StudentGroup = "All Students" in 19
	replace StudentSubGroup = "All Students" in 19
	replace ProficiencyCriteria = "Level 3 or 4" in 19
	replace Flag_AssmtNameChange = "N" in 19
	replace GradeLevel = "G08" in 20
	replace Subject = "sci" in 20
	replace StudentGroup_TotalTested = "12062" in 20
	replace ProficientOrAbove_count = "4720" in 20
	replace ProficientOrAbove_percent = ".39" in 20
	replace DataLevel = 1 in 20
	replace State = "Hawaii" in 20
	replace StateAbbrev = "HI'" in 20
	replace StateAbbrev = "HI" in 20
	replace StateFips = 15 in 20
	replace SchYear = "2021-22" in 20
	replace AssmtName = "Smarter Balanced Assessment" in 20
	replace AssmtType = "Regular" in 20
	replace StudentGroup = "All Students" in 20
	replace StudentSubGroup = "All Students" in 20
}

save "${cleaned}/HI_AssmtDataState_`year'.dta", replace
clear
}

//combining school and state data
foreach year of numlist 2015 2016 2017 2018 2019 2021 2022 {
append using "${cleaned}/HI_AssmtDataState_`year'.dta" "${cleaned}/HI_AssmtDataSchool_`year'.dta", force

//final formatting
replace State = "Hawaii"
//Converting to Correct Type
decode SchType, gen (Schtype1)
drop SchType
rename Schtype1 SchType
decode SchLevel, gen (SchLevel1)
drop SchLevel
rename SchLevel1 SchLevel
decode SchVirtual, gen (SchVirtual1)
drop SchVirtual
rename SchVirtual1 SchVirtual
decode DistType, gen (Disttype1)
drop DistType
rename Disttype1 DistType
tostring StateAssignedDistID Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_oth Flag_CutScoreChange_read ParticipationRate StudentGroup_TotalTested StudentSubGroup_TotalTested ProficientOrAbove_count, replace

//Response to R2/R3
replace ProficientOrAbove_percent = "*" if ProficientOrAbove_percent == "."
replace ProficientOrAbove_count = "*" if ProficientOrAbove_count == "."
replace StudentSubGroup_TotalTested = StudentGroup_TotalTested
foreach n in 1 2 3 4 5 {
	replace Lev`n'_count = ""
}
replace Flag_CutScoreChange_oth = "" if `year' != 2022

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth
keep if inlist(GradeLevel, "G03", "G04", "G05", "G06", "G07", "G08")
//sorting
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

//Exporting
save "${cleaned}/HI_AssmtData_`year'.dta", replace
export delimited using "${cleaned}/HI_AssmtData_`year'.csv", replace
clear
}

