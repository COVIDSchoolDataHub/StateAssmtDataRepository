
global yrfiles "/Users/hayden/Desktop/Research/IN/2021"
global nces "/Users/hayden/Desktop/Research/NCES"
global output "/Users/hayden/Desktop/Research/IN/Output"


//////	ORGANIZING AND APPENDING DATA


//// Create state level data

//ela
import excel "/${yrfiles}/IN_OriginalData_2021_all_state.xlsx", sheet("ELA") clear

gen count=_n
drop if count==1
drop if count==2
drop count

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="ela"

gen id=_n
drop if id>=8
drop id

save "/${yrfiles}/StateELA2021", replace

//math
import excel "/${yrfiles}/IN_OriginalData_2021_all_state.xlsx", sheet("Math") clear

gen count=_n
drop if count==1
drop if count==2
drop count

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="math"

gen id=_n
drop if id>=8
drop id

save "/${yrfiles}/StateMath2021", replace

//sci
import excel "/${yrfiles}/IN_OriginalData_2021_all_state.xlsx", sheet("Science") clear

gen count=_n
drop if count==1
drop if count==2
drop count

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent
drop I
drop J

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="sci"

gen id=_n
drop if id>=4
drop id

save "/${yrfiles}/StateSci2021", replace

//soc
import excel "/${yrfiles}/IN_OriginalData_2021_all_state.xlsx", sheet("Social Studies") clear

gen count=_n
drop if count==1
drop if count==2
drop count

rename A GradeLevel
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentGroup_TotalTested
rename H ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="soc"

gen id=_n
drop if id>=3
drop id

save "/${yrfiles}/StateSoc2021", replace

// state disaggregate data (ela)
import excel "/${yrfiles}/IN_OriginalData_2021_all_state_disagg.xlsx", sheet("ELA") clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent
drop I

gen count=_n
drop if count==1
drop if count==11
drop if count==12
drop if count>=17
drop count


gen Subject="ela"

gen StudentGroup="RaceEth"
replace StudentGroup="EL Status" if StudentSubGroup=="Non-English Language Learner" | StudentSubGroup=="English Language Learner"
replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
replace StudentGroup="Economic Status" if StudentSubGroup=="Free/Reduced price meals" | StudentSubGroup=="Paid meals"

destring StudentSubGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021ELA", replace

// generate subgroup totals
collapse (sum) StudentSubGroup_TotalTested, by(Subject StudentGroup)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/StateDisaggTotals2021ELA", replace

use "/${yrfiles}/StateDisagg2021ELA", clear

merge m:1 StudentGroup Subject using "/${yrfiles}/StateDisaggTotals2021ELA.dta"

drop _merge
gen GradeLevel="G38"
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021ELA", replace




// state disaggregate data (math)
import excel "/${yrfiles}/IN_OriginalData_2021_all_state_disagg.xlsx", sheet("Math") clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent
drop I

gen count=_n
drop if count==1
drop if count==11
drop if count==12
drop if count>=17
drop count


gen Subject="mat"

gen StudentGroup="RaceEth"
replace StudentGroup="EL Status" if StudentSubGroup=="Non-English Language Learner" | StudentSubGroup=="English Language Learner"
replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
replace StudentGroup="Economic Status" if StudentSubGroup=="Free/Reduced price meals" | StudentSubGroup=="Paid meals"

destring StudentSubGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021Math", replace

// generate subgroup totals
collapse (sum) StudentSubGroup_TotalTested, by(Subject StudentGroup)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/StateDisaggTotals2021Math", replace

use "/${yrfiles}/StateDisagg2021Math", clear

merge m:1 StudentGroup Subject using "/${yrfiles}/StateDisaggTotals2021Math.dta"

drop _merge
gen GradeLevel="G38"
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021Math", replace




// state disaggregate data (sci)
import excel "/${yrfiles}/IN_OriginalData_2021_all_state_disagg.xlsx", sheet("Science") clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent
drop I

gen count=_n
drop if count==1
drop if count==11
drop if count==12
drop if count>=17
drop count


gen Subject="sci"

gen StudentGroup="RaceEth"
replace StudentGroup="EL Status" if StudentSubGroup=="Non-English Language Learner" | StudentSubGroup=="English Language Learner"
replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
replace StudentGroup="Economic Status" if StudentSubGroup=="Free/Reduced price meals" | StudentSubGroup=="Paid meals"

destring StudentSubGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021Sci", replace

// generate subgroup totals
collapse (sum) StudentSubGroup_TotalTested, by(Subject StudentGroup)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/StateDisaggTotals2021Sci", replace

use "/${yrfiles}/StateDisagg2021Sci", clear

merge m:1 StudentGroup Subject using "/${yrfiles}/StateDisaggTotals2021Sci.dta"

drop _merge
gen GradeLevel="G38"
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021Sci", replace






// state disaggregate data (sci)
import excel "/${yrfiles}/IN_OriginalData_2021_all_state_disagg.xlsx", sheet("Social Studies") clear

rename A StudentSubGroup
rename B Lev1_count
rename C Lev2_count
rename D Lev3_count
rename E Lev4_count
rename F ProficientOrAbove_count
rename G StudentSubGroup_TotalTested
rename H ProficientOrAbove_percent
drop I

gen count=_n
drop if count==1
drop if count==11
drop if count==12
drop if count>=17
drop count


gen Subject="soc"

gen StudentGroup="RaceEth"
replace StudentGroup="EL Status" if StudentSubGroup=="Non-English Language Learner" | StudentSubGroup=="English Language Learner"
replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
replace StudentGroup="Economic Status" if StudentSubGroup=="Free/Reduced price meals" | StudentSubGroup=="Paid meals"

destring StudentSubGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021Soc", replace

// generate subgroup totals
collapse (sum) StudentSubGroup_TotalTested, by(Subject StudentGroup)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/StateDisaggTotals2021Soc", replace

use "/${yrfiles}/StateDisagg2021Soc", clear

merge m:1 StudentGroup Subject using "/${yrfiles}/StateDisaggTotals2021Soc.dta"

drop _merge
gen GradeLevel="G38"
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2021Soc", replace



//append all state-level files
use "/${yrfiles}/StateELA2021", replace
append using "/${yrfiles}/StateMath2021"
append using "/${yrfiles}/StateSci2021"
append using "/${yrfiles}/StateSoc2021"
append using "/${yrfiles}/StateDisagg2021ELA"
append using "/${yrfiles}/StateDisagg2021Math"
append using "/${yrfiles}/StateDisagg2021Sci"
append using "/${yrfiles}/StateDisagg2021Soc"

gen DataLevel=0

save "/${yrfiles}/State2021", replace


//// Create district level data

//ela
import excel "/${yrfiles}/IN_OriginalData_2021_all_dist.xlsx", sheet("ELA") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentGroup_TotalTested9
rename AY ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="ela"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/DistELA2021", replace



//math
import excel "/${yrfiles}/IN_OriginalData_2021_all_dist.xlsx", sheet("Math") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentGroup_TotalTested9
rename AY ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="math"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/DistMath2021", replace



//sci
import excel "/${yrfiles}/IN_OriginalData_2021_all_dist.xlsx", sheet("Science") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count4
rename D Lev2_count4
rename E Lev3_count4
rename F Lev4_count4
rename G ProficientOrAbove_count4
rename H StudentGroup_TotalTested4
rename I ProficientOrAbove_percent4

rename J Lev1_count6
rename K Lev2_count6
rename L Lev3_count6
rename M Lev4_count6
rename N ProficientOrAbove_count6
rename O StudentGroup_TotalTested6
rename P ProficientOrAbove_percent6

rename Q Lev1_count9
rename R Lev2_count9
rename S Lev3_count9
rename T Lev4_count9
rename U ProficientOrAbove_count9
rename V StudentGroup_TotalTested9
rename W ProficientOrAbove_percent9


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="sci"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/DistSci2021.dta", replace




//soc
import excel "/${yrfiles}/IN_OriginalData_2021_all_dist.xlsx", sheet("Social Studies") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count5
rename D Lev2_count5
rename E Lev3_count5
rename F Lev4_count5
rename G ProficientOrAbove_count5
rename H StudentGroup_TotalTested5
rename I ProficientOrAbove_percent5

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="soc"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/DistSoc2021.dta", replace



// dist disaggregate data


// ela race

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("ELA Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="ela"


save "/${yrfiles}/DistDisaggRaceEth2021_ELA.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggRaceEthTotals2021_ELA.dta", replace

use "/${yrfiles}/DistDisaggRaceEth2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggRaceEthTotals2021_ELA.dta"
drop _merge

save "/${yrfiles}/DistDisaggRaceEth2021_ELA.dta", replace



// math race

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("Math Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="math"


save "/${yrfiles}/DistDisaggRaceEth2021_Math.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggRaceEthTotals2021_Math.dta", replace

use "/${yrfiles}/DistDisaggRaceEth2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggRaceEthTotals2021_Math.dta"
drop _merge

save "/${yrfiles}/DistDisaggRaceEth2021_Math.dta", replace



// sci race

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("Science Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="sci"


save "/${yrfiles}/DistDisaggRaceEth2021_sci.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggRaceEthTotals2021_sci.dta", replace

use "/${yrfiles}/DistDisaggRaceEth2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggRaceEthTotals2021_sci.dta"
drop _merge

save "/${yrfiles}/DistDisaggRaceEth2021_sci.dta", replace





// soc race

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("Social Studies Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4

rename Q Lev1_count5
rename R Lev2_count5
rename S Lev3_count5
rename T Lev4_count5
rename U ProficientOrAbove_count5
rename V StudentSubGroup_TotalTested5
rename W ProficientOrAbove_percent5

rename X Lev1_count6
rename Y Lev2_count6
rename Z Lev3_count6
rename AA Lev4_count6
rename AB ProficientOrAbove_count6
rename AC StudentSubGroup_TotalTested6
rename AD ProficientOrAbove_percent6

rename AE Lev1_count7
rename AF Lev2_count7
rename AG Lev3_count7
rename AH Lev4_count7
rename AI ProficientOrAbove_count7
rename AJ StudentSubGroup_TotalTested7
rename AK ProficientOrAbove_percent7

rename AL Lev1_count8
rename AM Lev2_count8
rename AN Lev3_count8
rename AO Lev4_count8
rename AP ProficientOrAbove_count8
rename AQ StudentSubGroup_TotalTested8
rename AR ProficientOrAbove_percent8

rename AS Lev1_count9
rename AT Lev2_count9
rename AU Lev3_count9
rename AV Lev4_count9
rename AW ProficientOrAbove_count9
rename AX StudentSubGroup_TotalTested9
rename AY ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="soc"


save "/${yrfiles}/DistDisaggRaceEth2021_soc.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggRaceEthTotals2021_soc.dta", replace

use "/${yrfiles}/DistDisaggRaceEth2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggRaceEthTotals2021_soc.dta"
drop _merge

save "/${yrfiles}/DistDisaggRaceEth2021_soc.dta", replace



// gender


// math gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("Math Gender") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"

gen StudentGroup="Gender"
gen Subject="math"


save "/${yrfiles}/DistDisaggGender2021_Math.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggGenderTotals2021_Math.dta", replace

use "/${yrfiles}/DistDisaggGender2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggGenderTotals2021_Math.dta"
drop _merge

save "/${yrfiles}/DistDisaggGender2021_Math.dta", replace




// ela gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("ELA Gender") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"

gen StudentGroup="Gender"
gen Subject="ela"


save "/${yrfiles}/DistDisaggGender2021_ELA.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggGenderTotals2021_ELA", replace

use "/${yrfiles}/DistDisaggGender2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggGenderTotals2021_ELA.dta"
drop _merge

save "/${yrfiles}/DistDisaggGender2021_ELA.dta", replace



// sci gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("Science Gender") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"

gen StudentGroup="Gender"
gen Subject="sci"


save "/${yrfiles}/DistDisaggGender2021_sci.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggGenderTotals2021_sci.dta", replace

use "/${yrfiles}/DistDisaggGender2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggGenderTotals2021_sci.dta"
drop _merge

save "/${yrfiles}/DistDisaggGender2021_sci.dta", replace




// soc gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_race&gender.xlsx", sheet("Social Studies Gender") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"

gen StudentGroup="Gender"
gen Subject="soc"


save "/${yrfiles}/DistDisaggGender2021_soc.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggGenderTotals2021_soc.dta", replace

use "/${yrfiles}/DistDisaggGender2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggGenderTotals2021_soc.dta"
drop _merge

save "/${yrfiles}/DistDisaggGender2021_soc.dta", replace



//	english learners



// ela el status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("ELA English Learners") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="ela"


save "/${yrfiles}/DistDisaggELStatus2021_ELA.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggELStatusTotals2021_ELA.dta", replace

use "/${yrfiles}/DistDisaggELStatus2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggELStatusTotals2021_ELA.dta"
drop _merge

save "/${yrfiles}/DistDisaggELStatus2021_ELA.dta", replace



// math el status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("Math English Learners") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="math"


save "/${yrfiles}/DistDisaggELStatus2021_Math.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggELStatusTotals2021_Math.dta", replace

use "/${yrfiles}/DistDisaggELStatus2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggELStatusTotals2021_Math.dta"
drop _merge

save "/${yrfiles}/DistDisaggELStatus2021_Math.dta", replace



// science el status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("Science English Learners") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="sci"


save "/${yrfiles}/DistDisaggELStatus2021_sci.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggELStatusTotals2021_sci.dta", replace

use "/${yrfiles}/DistDisaggELStatus2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggELStatusTotals2021_sci.dta"
drop _merge

save "/${yrfiles}/DistDisaggELStatus2021_sci.dta", replace



// soc el status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("Social Studies English Learners") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="soc"


save "/${yrfiles}/DistDisaggELStatus2021_soc", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggELStatusTotals2021_soc.dta", replace

use "/${yrfiles}/DistDisaggELStatus2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggELStatusTotals2021_soc.dta"
drop _merge

save "/${yrfiles}/DistDisaggELStatus2021_soc.dta", replace



// ela econ status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("ELA Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="ela"


save "/${yrfiles}/DistDisaggEconStatus2021_ELA.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggEconStatusTotals2021_ELA.dta", replace

use "/${yrfiles}/DistDisaggEconStatus2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggEconStatusTotals2021_ELA.dta"
drop _merge

save "/${yrfiles}/DistDisaggEconStatus2021_ELA.dta", replace



// math econ status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("Math Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="math"


save "/${yrfiles}/DistDisaggEconStatus2021_Math.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggEconStatusTotals2021_Math.dta", replace

use "/${yrfiles}/DistDisaggEconStatus2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggEconStatusTotals2021_Math.dta"
drop _merge

save "/${yrfiles}/DistDisaggEconStatus2021_Math.dta", replace



// science econ status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("Science Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="sci"


save "/${yrfiles}/DistDisaggEconStatus2021_sci.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggEconStatusTotals2021_sci.dta", replace

use "/${yrfiles}/DistDisaggEconStatus2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggEconStatusTotals2021_sci.dta"
drop _merge

save "/${yrfiles}/DistDisaggEconStatus2021_sci.dta", replace



// soc econ status

import excel "/${yrfiles}/IN_OriginalData_2021_all_dist_disagg.xlsx", sheet("Social Studies Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C Lev1_count3
rename D Lev2_count3
rename E Lev3_count3
rename F Lev4_count3
rename G ProficientOrAbove_count3
rename H StudentSubGroup_TotalTested3
rename I ProficientOrAbove_percent3

rename J Lev1_count4
rename K Lev2_count4
rename L Lev3_count4
rename M Lev4_count4
rename N ProficientOrAbove_count4
rename O StudentSubGroup_TotalTested4
rename P ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentSubGroup_TotalTested, i(id) j(StudentSubGroup)

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"

gen StudentGroup="EL Status"
gen Subject="soc"


save "/${yrfiles}/DistDisaggEconStatus2021_soc.dta", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggEconStatusTotals2021_soc.dta", replace

use "/${yrfiles}/DistDisaggEconStatus2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggEconStatusTotals2021_soc.dta"
drop _merge

save "/${yrfiles}/DistDisaggEconStatus2021_soc.dta", replace




// append at district level data

use "/${yrfiles}/DistELA2021.dta"
append using "/${yrfiles}/DistMath2021.dta"
append using "/${yrfiles}/DistSci2021.dta"
append using "/${yrfiles}/DistSoc2021.dta"
append using "/${yrfiles}/DistDisaggEconStatus2021_ELA"
append using "/${yrfiles}/DistDisaggELStatus2021_ELA"
append using "/${yrfiles}/DistDisaggRaceEth2021_ELA"
append using "/${yrfiles}/DistDisaggGender2021_ELA"
append using "/${yrfiles}/DistDisaggEconStatus2021_Math"
append using "/${yrfiles}/DistDisaggELStatus2021_Math"
append using "/${yrfiles}/DistDisaggRaceEth2021_Math"
append using "/${yrfiles}/DistDisaggGender2021_Math"
append using "/${yrfiles}/DistDisaggEconStatus2021_sci"
append using "/${yrfiles}/DistDisaggELStatus2021_sci"
append using "/${yrfiles}/DistDisaggRaceEth2021_sci"
append using "/${yrfiles}/DistDisaggGender2021_sci"
append using "/${yrfiles}/DistDisaggEconStatus2021_soc"
append using "/${yrfiles}/DistDisaggELStatus2021_soc"
append using "/${yrfiles}/DistDisaggRaceEth2021_soc"
append using "/${yrfiles}/DistDisaggGender2021_soc"

gen DataLevel=1

save "/${yrfiles}/Dist2021", replace





///////// school level data




//ela
import excel "/${yrfiles}/IN_OriginalData_2021_all_sch.xlsx", sheet("ELA") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentGroup_TotalTested9
rename BA ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="ela"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/SchELA2021", replace



//math
import excel "/${yrfiles}/IN_OriginalData_2021_all_sch.xlsx", sheet("Math") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentGroup_TotalTested9
rename BA ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="math"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/SchMath2021", replace


//sci
import excel "/${yrfiles}/IN_OriginalData_2021_all_sch.xlsx", sheet("Science") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

rename E Lev1_count4
rename F Lev2_count4
rename G Lev3_count4
rename H Lev4_count4
rename I ProficientOrAbove_count4
rename J StudentGroup_TotalTested4
rename K ProficientOrAbove_percent4

rename L Lev1_count6
rename M Lev2_count6
rename N Lev3_count6
rename O Lev4_count6
rename P ProficientOrAbove_count6
rename Q StudentGroup_TotalTested6
rename R ProficientOrAbove_percent6

rename S Lev1_count9
rename T Lev2_count9
rename U Lev3_count9
rename V Lev4_count9
rename W ProficientOrAbove_count9
rename X StudentGroup_TotalTested9
rename Y ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="sci"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/SchSci2021", replace



//soc
import excel "/${yrfiles}/IN_OriginalData_2021_all_sch.xlsx", sheet("Social Studies") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData


rename E Lev1_count5
rename F Lev2_count5
rename G Lev3_count5
rename H Lev4_count5
rename I ProficientOrAbove_count5
rename J StudentGroup_TotalTested5
rename K ProficientOrAbove_percent5

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(GradeLevel)

drop id
gen id=_n


gen Subject="soc"


tostring GradeLevel, replace

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/SchSoc2021", replace


/////// disaggregate school files



// ela race

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("ELA Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentGroup_TotalTested9
rename BA ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="ela"


save "/${yrfiles}/SchDisaggRaceEth2021_ELA.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggRaceEthTotals2021_ELA.dta", replace

use "/${yrfiles}/SchDisaggRaceEth2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggRaceEthTotals2021_ELA.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggRaceEth2021_ELA.dta", replace



// math race

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("Math Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentGroup_TotalTested9
rename BA ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="math"


save "/${yrfiles}/SchDisaggRaceEth2021_Math.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggRaceEthTotals2021_Math.dta", replace

use "/${yrfiles}/SchDisaggRaceEth2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggRaceEthTotals2021_Math.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggRaceEth2021_Math.dta", replace



// sci race

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("Science Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentGroup_TotalTested9
rename BA ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="sci"


save "/${yrfiles}/SchDisaggRaceEth2021_sci.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggRaceEthTotals2021_sci.dta", replace

use "/${yrfiles}/SchDisaggRaceEth2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggRaceEthTotals2021_sci.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggRaceEth2021_sci.dta", replace




// soc race

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("Social Studies Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4

rename S Lev1_count5
rename T Lev2_count5
rename U Lev3_count5
rename V Lev4_count5
rename W ProficientOrAbove_count5
rename X StudentGroup_TotalTested5
rename Y ProficientOrAbove_percent5

rename Z Lev1_count6
rename AA Lev2_count6
rename AB Lev3_count6
rename AC Lev4_count6
rename AD ProficientOrAbove_count6
rename AE StudentGroup_TotalTested6
rename AF ProficientOrAbove_percent6

rename AG Lev1_count7
rename AH Lev2_count7
rename AI Lev3_count7
rename AJ Lev4_count7
rename AK ProficientOrAbove_count7
rename AL StudentGroup_TotalTested7
rename AM ProficientOrAbove_percent7

rename AN Lev1_count8
rename AO Lev2_count8
rename AP Lev3_count8
rename AQ Lev4_count8
rename AR ProficientOrAbove_count8
rename AS StudentGroup_TotalTested8
rename AT ProficientOrAbove_percent8

rename AU Lev1_count9
rename AV Lev2_count9
rename AW Lev3_count9
rename AX Lev4_count9
rename AY ProficientOrAbove_count9
rename AZ StudentGroup_TotalTested9
rename BA ProficientOrAbove_percent9

gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"



gen StudentGroup="Race/Eth"
gen Subject="soc"


save "/${yrfiles}/SchDisaggRaceEth2021_soc.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggRaceEthTotals2021_soc.dta", replace

use "/${yrfiles}/SchDisaggRaceEth2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggRaceEthTotals2021_soc.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggRaceEth2021_soc.dta", replace


// gender


// ela gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("ELA Gender") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"


gen StudentGroup="Gender"
gen Subject="ela"


save "/${yrfiles}/SchDisaggGender2021_ELA.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggGenderTotals2021_ELA.dta", replace

use "/${yrfiles}/SchDisaggGender2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggGenderTotals2021_ELA.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggGender2021_ELA.dta", replace




// math gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("Math Gender") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"


gen StudentGroup="Gender"
gen Subject="math"


save "/${yrfiles}/SchDisaggGender2021_Math.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggGenderTotals2021_Math.dta", replace

use "/${yrfiles}/SchDisaggGender2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggGenderTotals2021_Math.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggGender2021_Math.dta", replace




// sci gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("Science Gender") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"


gen StudentGroup="Gender"
gen Subject="sci"


save "/${yrfiles}/SchDisaggGender2021_sci.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggGenderTotals2021_sci.dta", replace

use "/${yrfiles}/SchDisaggGender2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggGenderTotals2021_sci.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggGender2021_sci.dta", replace




// soc gender

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_race&gender.xlsx", sheet("Social Studies Gender") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Female" if StudentSubGroup=="3"
replace StudentSubGroup="Male" if StudentSubGroup=="4"


gen StudentGroup="Gender"
gen Subject="soc"


save "/${yrfiles}/SchDisaggGender2021_soc.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggGenderTotals2021_soc.dta", replace

use "/${yrfiles}/SchDisaggGender2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggGenderTotals2021_soc.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force

save "/${yrfiles}/SchDisaggGender2021_soc.dta", replace


// ela ELStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("ELA English Learners") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="ela"


save "/${yrfiles}/SchDisaggELStatus2021_ELA.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggELStatusTotals2021_ELA.dta", replace

use "/${yrfiles}/SchDisaggELStatus2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggELStatusTotals2021_ELA.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggELStatus2021_ELA.dta", replace




// math ELStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("Math English Learners") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="math"


save "/${yrfiles}/SchDisaggELStatus2021_Math.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggELStatusTotals2021_Math.dta", replace

use "/${yrfiles}/SchDisaggELStatus2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggELStatusTotals2021_Math.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggELStatus2021_Math.dta", replace




// sci ELStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("Science English Learners") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="sci"


save "/${yrfiles}/SchDisaggELStatus2021_sci.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggELStatusTotals2021_sci.dta", replace

use "/${yrfiles}/SchDisaggELStatus2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggELStatusTotals2021_sci.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggELStatus2021_sci.dta", replace




// soc ELStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("Social Studies English Learners") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="English Proficient" if StudentSubGroup=="3"
replace StudentSubGroup="English Learner" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="soc"


save "/${yrfiles}/SchDisaggELStatus2021_soc.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggELStatusTotals2021_soc.dta", replace

use "/${yrfiles}/SchDisaggELStatus2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggELStatusTotals2021_soc.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggELStatus2021_soc.dta", replace




// ela EconStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("ELA Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="ela"


save "/${yrfiles}/SchDisaggEconStatus2021_ELA.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggEconStatusTotals2021_ELA.dta", replace

use "/${yrfiles}/SchDisaggEconStatus2021_ELA.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggEconStatusTotals2021_ELA.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggEconStatus2021_ELA.dta", replace




// math EconStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("Math Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="math"


save "/${yrfiles}/SchDisaggEconStatus2021_Math.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggEconStatusTotals2021_Math.dta", replace

use "/${yrfiles}/SchDisaggEconStatus2021_Math.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggEconStatusTotals2021_Math.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggEconStatus2021_Math.dta", replace




// sci EconStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("Science Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="sci"


save "/${yrfiles}/SchDisaggEconStatus2021_sci.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggEconStatusTotals2021_sci.dta", replace

use "/${yrfiles}/SchDisaggEconStatus2021_sci.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggEconStatusTotals2021_sci.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggEconStatus2021_sci.dta", replace




// soc EconStatus

import excel "/${yrfiles}/IN_OriginalData_2021_all_sch_disagg.xlsx", sheet("Social Studies Socio Economic") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E Lev1_count3
rename F Lev2_count3
rename G Lev3_count3
rename H Lev4_count3
rename I ProficientOrAbove_count3
rename J StudentGroup_TotalTested3
rename K ProficientOrAbove_percent3

rename L Lev1_count4
rename M Lev2_count4
rename N Lev3_count4
rename O Lev4_count4
rename P ProficientOrAbove_count4
rename Q StudentGroup_TotalTested4
rename R ProficientOrAbove_percent4


gen id=_n
drop if id<=6

reshape long Lev1_count Lev2_count Lev3_count Lev4_count ProficientOrAbove_count ProficientOrAbove_percent StudentGroup_TotalTested, i(id) j(StudentSubGroup)
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

drop id
gen id=_n


gen GradeLevel="G38"
tostring StudentSubGroup, replace

replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="3"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="4"


gen StudentGroup="EL Status"
gen Subject="soc"


save "/${yrfiles}/SchDisaggEconStatus2021_soc.dta", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggEconStatusTotals2021_soc.dta", replace

use "/${yrfiles}/SchDisaggEconStatus2021_soc.dta", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/SchDisaggEconStatusTotals2021_soc.dta"
drop _merge

tostring StudentSubGroup_TotalTested, replace force
save "/${yrfiles}/SchDisaggEconStatus2021_soc.dta", replace




//append state level data
use "/${yrfiles}/SchELA2021.dta", clear
append using "/${yrfiles}/SchMath2021.dta"
append using "/${yrfiles}/SchSci2021.dta"
append using "/${yrfiles}/SchSoc2021.dta"
append using "/${yrfiles}/SchDisaggEconStatus2021_ELA.dta"
append using "/${yrfiles}/SchDisaggELStatus2021_ELA.dta"
append using "/${yrfiles}/SchDisaggRaceEth2021_ELA.dta"
append using "/${yrfiles}/SchDisaggGender2021_ELA.dta"
append using "/${yrfiles}/SchDisaggEconStatus2021_Math.dta"
append using "/${yrfiles}/SchDisaggELStatus2021_Math.dta"
append using "/${yrfiles}/SchDisaggRaceEth2021_Math.dta"
append using "/${yrfiles}/SchDisaggGender2021_Math.dta"
append using "/${yrfiles}/SchDisaggEconStatus2021_sci.dta"
append using "/${yrfiles}/SchDisaggELStatus2021_sci.dta"
append using "/${yrfiles}/SchDisaggRaceEth2021_sci.dta"
append using "/${yrfiles}/SchDisaggGender2021_sci.dta"
append using "/${yrfiles}/SchDisaggEconStatus2021_soc.dta"
append using "/${yrfiles}/SchDisaggELStatus2021_soc.dta"
append using "/${yrfiles}/SchDisaggRaceEth2021_soc.dta"
append using "/${yrfiles}/SchDisaggGender2021_soc.dta"

gen DataLevel=2

save "/${yrfiles}/School2021", replace

//append all data
append using "/${yrfiles}/Dist2021.dta"
append using "/${yrfiles}/State2021.dta"

save "/${yrfiles}/IN_2021_appended.dta", replace


////	MERGE NCES

use "/${nces}/NCES_2020_District.dta", clear
drop if state_fips!=18
save "/${yrfiles}/IN_2020_District.dta", replace


use "/${yrfiles}/IN_2021_appended.dta", replace

gen state_leaid="IN-"+StateAssignedDistID
drop if CorpName=="Independent Non-Public Schools"
drop if StateAssignedDistID=="9200"
drop if StateAssignedDistID=="9205"
drop if StateAssignedDistID=="9210"
drop if StateAssignedDistID=="9215"
drop if StateAssignedDistID=="9220"
drop if StateAssignedDistID=="9230"
drop if StateAssignedDistID=="9240"

merge m:1 state_leaid using "/${yrfiles}/IN_2020_District.dta"
drop if _merge==2
drop _merge

gen seasch=StateAssignedDistID+"-"+StateAssignedSchID

save "/${yrfiles}/IN_2021.dta", replace

use "/${nces}/NCES_2020_School.dta", clear
drop if state_fips!=18
save "/${yrfiles}/IN_2020_School.dta", replace


use "/${yrfiles}/IN_2021.dta", replace

merge m:1 seasch using "/${yrfiles}/IN_2020_School.dta"
drop if _merge==2
drop _merge



/////	FINISH CLEANING

rename state_name State
replace State=18
rename state_location StateAbbrev
replace StateAbbrev="IN"
rename state_fips StateFips
replace StateFips=18
gen SchYear="2020-21"
rename lea_name DistName
rename district_agency_type DistType
rename school_name SchName
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen AssmtName="ILEARN"
gen AssmtType="Regular"
gen Lev5_count="*"
gen Lev1_percent="*"
gen Lev2_percent="*"
gen Lev3_percent="*"
gen Lev4_percent="*"
gen Lev5_percent="*"
gen AvgScaleScore="*"
gen ProficiencyCriteria="Lev 3 & Lev 4"
gen ParticipationRate="*"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"

label define LevelIndicator 0 "State" 1 "District" 2 "School"
label values DataLevel LevelIndicator

replace SchName="All Schools" if DataLevel<2
replace DistName="All Districts" if DataLevel==0
replace seasch="" if DataLevel<2
replace State_leaid="" if DataLevel==0

replace StudentGroup="RaceEth" if StudentGroup=="Race/Eth"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="American Indian"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="Black"
replace StudentSubGroup="English Learner" if StudentSubGroup=="English Language Learner"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="Free/Reduced price meals"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="Hispanic"
replace StudentSubGroup="Two or More" if StudentSubGroup=="Multiracial"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="Non-English Language Learner"
replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="Paid meals"

replace Subject="math" if Subject=="mat"

replace GradeLevel="G03" if GradeLevel=="3"
replace GradeLevel="G04" if GradeLevel=="4"
replace GradeLevel="G05" if GradeLevel=="5"
replace GradeLevel="G06" if GradeLevel=="6"
replace GradeLevel="G07" if GradeLevel=="7"
replace GradeLevel="G08" if GradeLevel=="8"
replace GradeLevel="G38" if GradeLevel=="9"
replace GradeLevel="G38" if GradeLevel=="38"
replace GradeLevel="G03" if GradeLevel=="Grade 3"
replace GradeLevel="G04" if GradeLevel=="Grade 4"
replace GradeLevel="G05" if GradeLevel=="Grade 5"
replace GradeLevel="G06" if GradeLevel=="Grade 6"
replace GradeLevel="G07" if GradeLevel=="Grade 7"
replace GradeLevel="G08" if GradeLevel=="Grade 8"
replace GradeLevel="G38" if GradeLevel=="Grand Total"
replace GradeLevel="G38" if StudentGroup!="All Students"

replace ProficientOrAbove_count="*" if ProficientOrAbove_count==""
replace ProficientOrAbove_count="*" if ProficientOrAbove_count=="***"
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent==""
replace ProficientOrAbove_percent="*" if ProficientOrAbove_percent=="***"
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested==""
replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="***"
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="***"

keep State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

order State StateAbbrev StateFips SchYear DataLevel DistName DistType SchName SchType NCESDistrictID StateAssignedDistID State_leaid NCESSchoolID StateAssignedSchID seasch DistCharter SchLevel SchVirtual CountyName CountyCode AssmtName AssmtType Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math Flag_CutScoreChange_read Flag_CutScoreChange_oth

sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup


replace StudentGroup="RaceEth" if StudentGroup=="Race/Eth"
replace GradeLevel="G38" if StudentGroup=="RaceEth"
replace GradeLevel="G38" if StudentGroup=="EL Status"
replace GradeLevel="G38" if StudentGroup=="Gender"
replace GradeLevel="G38" if StudentGroup=="Economic Status"
drop if StateAssignedDistID=="***Due to federal privacy laws, student performance data may not be displayed for any group of less than 10 students."
drop if StateAssignedDistID=="" & (DataLevel==1 | DataLevel==2)


save "/${yrfiles}/IN_2021.dta", replace

export delimited using "/${output}/IN_AssmtData_2021.csv", replace



