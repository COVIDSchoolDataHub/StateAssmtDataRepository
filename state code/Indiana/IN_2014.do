
global source "/Users/hayden/Desktop/Research/IN/Pre 2014"
global yrfiles "/Users/hayden/Desktop/Research/IN/2014"
global nces "/Users/hayden/Desktop/Research/NCES"
global output "/Users/hayden/Desktop/Research/IN/Output"


//////	ORGANIZING AND APPENDING DATA


//// Create state level data

//ela
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_state.xlsx", sheet("ELA") clear

drop D E F G H I

gen count=_n
drop if count==1
drop if count==2
drop if count>=10
drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="ela"

save "/${yrfiles}/StateELA2014", replace

//math
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_state.xlsx", sheet("Math") clear

drop D E F G H I

gen count=_n
drop if count==1
drop if count==2
drop if count>=10
drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="math"

save "/${yrfiles}/StateMath2014", replace


//sci
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_state.xlsx", sheet("Science") clear

drop D E F G H I

gen count=_n
drop if count==1
drop if count==2
drop if count>=6
drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="sci"

save "/${yrfiles}/StateSci2014", replace



// social studies
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_state.xlsx", sheet("Social Studies") clear

drop D E F G H I

gen count=_n
drop if count==1
drop if count==2
drop if count>=6
drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="sci"

save "/${yrfiles}/StateSoc2014", replace


// state disaggregate data (math and ela)
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_state_disagg.xlsx", sheet("Sheet1") firstrow clear

drop BothELAandMathPassN BothELAandMathTestN BothELAandMathPass

gen count=_n
drop if count==10
drop if count==11
drop if count>=16
drop count

rename StudentDemographic StudentSubGroup

//prepare to transform from wide to long (ela=1, math=2)
rename ELAPassN ProficientOrAbove_count1
rename ELATestN StudentSubGroup_TotalTested1
rename ELAPass ProficientOrAbove_percent1
rename MathPassN ProficientOrAbove_count2
rename MathTestN StudentSubGroup_TotalTested2
rename MathPass ProficientOrAbove_percent2

gen id=_n

reshape long ProficientOrAbove_count StudentSubGroup_TotalTested ProficientOrAbove_percent, i(id) j (Subject)

tostring Subject, replace
replace Subject="ela" if Subject=="1"
replace Subject="mat" if Subject=="2"
drop id

gen StudentGroup="RaceEth"
replace StudentGroup="EL Status" if StudentSubGroup=="Non-English Language Learner" | StudentSubGroup=="English Language Learner"
replace StudentGroup="Gender" if StudentSubGroup=="Male" | StudentSubGroup=="Female"
replace StudentGroup="Economic Status" if StudentSubGroup=="Free/Reduced price meals" | StudentSubGroup=="Paid meals"

destring StudentSubGroup_TotalTested, replace force

save "/${yrfiles}/StateDisagg2014", replace

// generate subgroup totals
collapse (sum) StudentSubGroup_TotalTested, by(Subject StudentGroup)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/StateDisaggTotals2014", replace

use "/${yrfiles}/StateDisagg2014", clear

merge m:1 StudentGroup Subject using "/${yrfiles}/StateDisaggTotals2014.dta"

drop _merge
gen GradeLevel="G38"
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2014", replace

//append all state-level files
use "/${yrfiles}/StateELA2014", replace
append using "/${yrfiles}/StateMath2014"
append using "/${yrfiles}/StateSci2014"
append using "/${yrfiles}/StateSoc2014"
append using "/${yrfiles}/StateDisagg2014"

gen DataLevel=0
replace GradeLevel="G38" if GradeLevel=="Grand Total"

save "/${yrfiles}/State2014", replace


//// Create district level data

//math and ela
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_dist.xlsx", sheet("Spring 2014") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C ProficientOrAbove_count13
rename D ProficientOrAbove_percent13

rename E ProficientOrAbove_count23
rename F ProficientOrAbove_percent23

drop G

rename H ProficientOrAbove_count14
rename I ProficientOrAbove_percent14

rename J ProficientOrAbove_count24
rename K ProficientOrAbove_percent24

drop L

rename M ProficientOrAbove_count15
rename N ProficientOrAbove_percent15

rename O ProficientOrAbove_count25
rename P ProficientOrAbove_percent25

drop Q

rename R ProficientOrAbove_count16
rename S ProficientOrAbove_percent16

rename T ProficientOrAbove_count26
rename U ProficientOrAbove_percent26

drop V

rename W ProficientOrAbove_count17
rename X ProficientOrAbove_percent17

rename Y ProficientOrAbove_count27
rename Z ProficientOrAbove_percent27

drop AA

rename AB ProficientOrAbove_count18
rename AC ProficientOrAbove_percent18

rename AD ProficientOrAbove_count28
rename AE ProficientOrAbove_percent28

drop AF

rename AG ProficientOrAbove_count19
rename AH ProficientOrAbove_percent19

rename AI ProficientOrAbove_count29
rename AJ ProficientOrAbove_percent29

drop AK

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 ProficientOrAbove_percent1 ProficientOrAbove_count2 ProficientOrAbove_percent2, i(id) j(GradeLevel)

drop id
gen id=_n

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring Subject GradeLevel, replace
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/DistMathELA2014", replace



// dist disaggregate math and ela (race/ethnicity)
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_dist_disagg.xlsx", sheet("Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to tranform to long (first digit: subject, second digit: racial group)

rename C ProficientOrAbove_count11
rename D ProficientOrAbove_percent11

rename E ProficientOrAbove_count21
rename F ProficientOrAbove_percent21

drop G

rename H ProficientOrAbove_count12
rename I ProficientOrAbove_percent12

rename J ProficientOrAbove_count22
rename K ProficientOrAbove_percent22

drop L

rename M ProficientOrAbove_count13
rename N ProficientOrAbove_percent13

rename O ProficientOrAbove_count23
rename P ProficientOrAbove_percent23

drop Q

rename R ProficientOrAbove_count14
rename S ProficientOrAbove_percent14

rename T ProficientOrAbove_count24
rename U ProficientOrAbove_percent24

drop V

rename W ProficientOrAbove_count15
rename X ProficientOrAbove_percent15

rename Y ProficientOrAbove_count25
rename Z ProficientOrAbove_percent25

drop AA

rename AB ProficientOrAbove_count16
rename AC ProficientOrAbove_percent16

rename AD ProficientOrAbove_count26
rename AE ProficientOrAbove_percent26

drop AF

rename AG ProficientOrAbove_count17
rename AH ProficientOrAbove_percent17

rename AI ProficientOrAbove_count27
rename AJ ProficientOrAbove_percent27

drop AK

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 StudentGroup_TotalTested1 ProficientOrAbove_percent1 ProficientOrAbove_count2 StudentGroup_TotalTested2 ProficientOrAbove_percent2, i(id) j(StudentSubGroup)

drop id
gen id=_n

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring StudentSubGroup, replace
tostring Subject, replace
gen StudentSubGroup_TotalTested="*"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="1"
replace StudentSubGroup="Asian" if StudentSubGroup=="2"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="3"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="4"
replace StudentSubGroup="Two or More" if StudentSubGroup=="5"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="6"
replace StudentSubGroup="White" if StudentSubGroup=="7"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="Race/Eth"

save "/${yrfiles}/DistDisaggRaceEth2014", replace

// gen student group totals

tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace force
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggRaceEthTotals2014", replace

use "/${yrfiles}/DistDisaggRaceEth2014", clear

tostring StudentSubGroup_TotalTested, replace force
merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggRaceEthTotals2014.dta", force
drop _merge

save "/${yrfiles}/DistDisaggRaceEth2014", replace



// dist disaggregate math and ela (EL status)

import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_dist_disagg.xlsx", sheet("ELL") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to tranform to long (first digit: subject, second digit: el status)

rename C ProficientOrAbove_count11
rename D ProficientOrAbove_percent11

rename E ProficientOrAbove_count21
rename F ProficientOrAbove_percent21

drop G

rename H ProficientOrAbove_count12
rename I ProficientOrAbove_percent12

rename J ProficientOrAbove_count22
rename K ProficientOrAbove_percent22

drop L


gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 StudentGroup_TotalTested1 ProficientOrAbove_percent1 ProficientOrAbove_count2 StudentGroup_TotalTested2 ProficientOrAbove_percent2, i(id) j(StudentSubGroup)

drop id
gen id=_n

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring StudentSubGroup, replace
tostring Subject, replace
gen StudentSubGroup_TotalTested="*"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="1"
replace StudentSubGroup="English Learner" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="EL Status"

save "/${yrfiles}/DistDisaggELStatus2014", replace

// gen student group totals

tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace force
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggELStatusTotals2014", replace

use "/${yrfiles}/DistDisaggELStatus2014", clear

tostring StudentSubGroup_TotalTested, replace force
merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggELStatusTotals2014.dta", force
drop _merge

save "/${yrfiles}/DistDisaggELStatus2014", replace



// economic status (math ela)

import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_dist_disagg.xlsx", sheet("Free_Reduced") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to tranform to long (first digit: subject, second digit: el status)

rename C ProficientOrAbove_count11
rename D ProficientOrAbove_percent11

rename E ProficientOrAbove_count21
rename F ProficientOrAbove_percent21

drop G

rename H ProficientOrAbove_count12
rename I ProficientOrAbove_percent12

rename J ProficientOrAbove_count22
rename K ProficientOrAbove_percent22

drop L

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 StudentGroup_TotalTested1 ProficientOrAbove_percent1 ProficientOrAbove_count2 StudentGroup_TotalTested2 ProficientOrAbove_percent2, i(id) j(StudentSubGroup)

drop id
gen id=_n

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(Subject)

drop id


tostring StudentSubGroup, replace
tostring Subject, replace
gen StudentSubGroup_TotalTested="*"
replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="1"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="Economic Status"

save "/${yrfiles}/DistDisaggEconStatus2014", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace force
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggEconStatusTotals2014", replace

use "/${yrfiles}/DistDisaggEconStatus2014", clear

tostring StudentSubGroup_TotalTested, replace force
merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggEconStatusTotals2014.dta", force
drop _merge

save "/${yrfiles}/DistDisaggEconStatus2014", replace

// append at district level data

use "/${yrfiles}/DistMathELA2014.dta"
append using "/${yrfiles}/DistDisaggEconStatus2014", force
append using "/${yrfiles}/DistDisaggELStatus2014", force
append using "/${yrfiles}/DistDisaggRaceEth2014", force

gen DataLevel=1

save "/${yrfiles}/Dist2014", replace


//// School level data files
import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_sch.xlsx", sheet("Spring 2014") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E ProficientOrAbove_count13
rename F ProficientOrAbove_percent13

rename G ProficientOrAbove_count23
rename H ProficientOrAbove_percent23

drop I

rename J ProficientOrAbove_count14
rename K ProficientOrAbove_percent14

rename L ProficientOrAbove_count24
rename M ProficientOrAbove_percent24

drop N

rename O ProficientOrAbove_count15
rename P ProficientOrAbove_percent15

rename Q ProficientOrAbove_count25
rename R ProficientOrAbove_percent25

drop S

rename T ProficientOrAbove_count16
rename U ProficientOrAbove_percent16

rename V ProficientOrAbove_count26
rename W ProficientOrAbove_percent26

drop X

rename Y ProficientOrAbove_count17
rename Z ProficientOrAbove_percent17

rename AA ProficientOrAbove_count27
rename AB ProficientOrAbove_percent27

drop AC

rename AD ProficientOrAbove_count18
rename AE ProficientOrAbove_percent18

rename AF ProficientOrAbove_count28
rename AG ProficientOrAbove_percent28

drop AH

rename AI ProficientOrAbove_count19
rename AJ ProficientOrAbove_percent19

rename AK ProficientOrAbove_count29
rename AL ProficientOrAbove_percent29

drop AM

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 ProficientOrAbove_percent1 ProficientOrAbove_count2 ProficientOrAbove_percent2, i(id) j(GradeLevel)

drop id
gen id=_n

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring Subject GradeLevel, replace
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup_TotalTested="*"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/SchMathELA2014", replace


// disaggregate school math and ela (race/ethnicity)

import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_sch_disagg.xlsx", sheet("Ethnicity") clear

rename A StateAssignedSchID
rename B SchoolName
rename C StateAssignedDistID
rename D CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, 2nd digit for race)

rename E ProficientOrAbove_count13
rename F ProficientOrAbove_percent13

rename G ProficientOrAbove_count23
rename H ProficientOrAbove_percent23

drop I

rename J ProficientOrAbove_count14
rename K ProficientOrAbove_percent14

rename L ProficientOrAbove_count24
rename M ProficientOrAbove_percent24

drop N

rename O ProficientOrAbove_count15
rename P ProficientOrAbove_percent15

rename Q ProficientOrAbove_count25
rename R ProficientOrAbove_percent25

drop S

rename T ProficientOrAbove_count16
rename U ProficientOrAbove_percent16

rename V ProficientOrAbove_count26
rename W ProficientOrAbove_percent26

drop X

rename Y ProficientOrAbove_count17
rename Z ProficientOrAbove_percent17

rename AA ProficientOrAbove_count27
rename AB ProficientOrAbove_percent27

drop AC

rename AD ProficientOrAbove_count18
rename AE ProficientOrAbove_percent18

rename AF ProficientOrAbove_count28
rename AG ProficientOrAbove_percent28

drop AH

rename AI ProficientOrAbove_count19
rename AJ ProficientOrAbove_percent19

rename AK ProficientOrAbove_count29
rename AL ProficientOrAbove_percent29

drop AM

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 ProficientOrAbove_percent1 ProficientOrAbove_count2 ProficientOrAbove_percent2, i(id) j(StudentSubGroup)

drop id
gen id=_n

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring StudentSubGroup, replace
tostring Subject, replace
gen StudentSubGroup_TotalTested="*"
replace StudentSubGroup="American Indian or Alaska Native" if StudentSubGroup=="3"
replace StudentSubGroup="Asian" if StudentSubGroup=="4"
replace StudentSubGroup="Black or African American" if StudentSubGroup=="5"
replace StudentSubGroup="Hispanic or Latino" if StudentSubGroup=="6"
replace StudentSubGroup="Two or More" if StudentSubGroup=="7"
replace StudentSubGroup="Native Hawaiian or Pacific Islander" if StudentSubGroup=="8"
replace StudentSubGroup="White" if StudentSubGroup=="9"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="Race/Eth"

save "/${yrfiles}/SchDisaggRaceEth2014", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace force
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID StateAssignedSchID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggRaceEthTotals2014", replace

use "/${yrfiles}/SchDisaggRaceEth2014", clear

tostring StudentSubGroup_TotalTested, replace force
merge m:1 StateAssignedDistID Subject StateAssignedSchID using "/${yrfiles}/SchDisaggRaceEthTotals2014.dta", force
drop _merge

save "/${yrfiles}/SchDisaggRaceEth2014", replace



// school disaggregate math and ela (EL status)

import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_sch_disagg.xlsx", sheet("ELL") clear

rename A StateAssignedSchID
rename B SchoolName
rename C StateAssignedDistID
rename D CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E ProficientOrAbove_count11
rename F ProficientOrAbove_percent11

rename G ProficientOrAbove_count21
rename H ProficientOrAbove_percent21

drop I

rename J ProficientOrAbove_count12
rename K ProficientOrAbove_percent12

rename L ProficientOrAbove_count22
rename M ProficientOrAbove_percent22

drop N

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 ProficientOrAbove_percent1 ProficientOrAbove_count2 ProficientOrAbove_percent2, i(id) j(StudentSubGroup)

drop id
gen id=_n

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring StudentSubGroup, replace
tostring Subject, replace
gen StudentSubGroup_TotalTested="*"
replace StudentSubGroup="English Proficient" if StudentSubGroup=="1"
replace StudentSubGroup="English Learner" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="EL Status"

save "/${yrfiles}/SchDisaggELStatus2014", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace force
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID StateAssignedSchID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggELStatusTotals2014", replace

use "/${yrfiles}/SchDisaggELStatus2014", clear

tostring StudentSubGroup_TotalTested, replace force
merge m:1 StateAssignedDistID Subject StateAssignedSchID using "/${yrfiles}/SchDisaggELStatusTotals2014.dta", force
drop _merge

save "/${yrfiles}/SchDisaggELStatus2014", replace



// school disaggregate math and ela (Econ status)

import excel "/${yrfiles}/IN_OriginalData_2014_mat&ela_sch_disagg.xlsx", sheet("Free_Reduced") clear

rename A StateAssignedSchID
rename B SchoolName
rename C StateAssignedDistID
rename D CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E ProficientOrAbove_count11
rename F ProficientOrAbove_percent11

rename G ProficientOrAbove_count21
rename H ProficientOrAbove_percent21

drop I

rename J ProficientOrAbove_count12
rename K ProficientOrAbove_percent12

rename L ProficientOrAbove_count22
rename M ProficientOrAbove_percent22

drop N

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 ProficientOrAbove_percent1 ProficientOrAbove_count2 ProficientOrAbove_percent2, i(id) j(StudentSubGroup)

drop id
gen id=_n

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring StudentSubGroup, replace
tostring Subject, replace
gen StudentSubGroup_TotalTested="*"
replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="1"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="Economic Status"

save "/${yrfiles}/SchDisaggEconStatus2014", replace

// gen student group totals
tostring StudentSubGroup_TotalTested, replace force
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="."
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace force
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID StateAssignedSchID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggEconStatusTotals2014", replace

use "/${yrfiles}/SchDisaggEconStatus2014", clear

tostring StudentSubGroup_TotalTested, replace force
merge m:1 StateAssignedDistID Subject StateAssignedSchID using "/${yrfiles}/SchDisaggEconStatusTotals2014.dta", force
drop _merge

save "/${yrfiles}/SchDisaggEconStatus2014", replace


//append state level data
use "/${yrfiles}/SchMathELA2014.dta", clear
append using "/${yrfiles}/SchDisaggEconStatus2014"
append using "/${yrfiles}/SchDisaggELStatus2014"
append using "/${yrfiles}/SchDisaggRaceEth2014"

gen DataLevel=2

save "/${yrfiles}/School2014", replace






//
//
//
//




// PREPARE SCIENCE AND SOCIAL STUDIES DATA OF ALL LEVELS
import excel "/${source}/IN_OriginalData_2013-2014_sci&soc.xlsx", sheet("2014_SCIENCE_CORP") clear

rename A StateAssignedDistID
rename B CorpName

rename C ProficientOrAbove_count4
rename D ProficientOrAbove_percent4

rename E ProficientOrAbove_count6
rename F ProficientOrAbove_percent6

rename G ProficientOrAbove_count38
rename H ProficientOrAbove_percent38

gen id=_n
drop if id==1
drop if id==2
drop if id>=358

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(GradeLevel)

gen Subject="sci"
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen DataLevel=1
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
tostring GradeLevel, replace
drop id

save "/${yrfiles}/IN_2014_sci_dist.dta", replace


import excel "/${source}/IN_OriginalData_2013-2014_sci&soc.xlsx", sheet("2014_SCIENCE_SCH") clear

rename A StateAssignedSchID
rename B SchoolName
rename C StateAssignedDistID
rename D CorpName

rename E ProficientOrAbove_count4
rename F ProficientOrAbove_percent4

rename G ProficientOrAbove_count6
rename H ProficientOrAbove_percent6

rename I ProficientOrAbove_count38
rename J ProficientOrAbove_percent38

gen id=_n
drop if id==1
drop if id==2
drop if id>=1773

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(GradeLevel)

gen Subject="sci"
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen DataLevel=2
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
tostring GradeLevel, replace
drop id


save "/${yrfiles}/IN_2014_sci_sch.dta", replace


// social studies
import excel "/${source}/IN_OriginalData_2013-2014_sci&soc.xlsx", sheet("2014_SS_CORP") clear

rename A StateAssignedDistID
rename B CorpName

rename C ProficientOrAbove_count5
rename D ProficientOrAbove_percent5

rename E ProficientOrAbove_count7
rename F ProficientOrAbove_percent7

rename G ProficientOrAbove_count38
rename H ProficientOrAbove_percent38

gen id=_n
drop if id==1
drop if id==2
drop if id>=356

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(GradeLevel)

gen Subject="soc"
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen DataLevel=1
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
tostring GradeLevel, replace
drop id

save "/${yrfiles}/IN_2014_soc_dist.dta", replace


import excel "/${source}/IN_OriginalData_2013-2014_sci&soc.xlsx", sheet("2014_SS_SCH") clear

rename A StateAssignedSchID
rename B SchoolName
rename C StateAssignedDistID
rename D CorpName

rename E ProficientOrAbove_count4
rename F ProficientOrAbove_percent4

rename G ProficientOrAbove_count6
rename H ProficientOrAbove_percent6

rename I ProficientOrAbove_count38
rename J ProficientOrAbove_percent38

gen id=_n
drop if id==1
drop if id==2
drop if id>=1755

reshape long ProficientOrAbove_count ProficientOrAbove_percent, i(id) j(GradeLevel)

gen Subject="soc"
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentGroup_TotalTested="*"
gen DataLevel=2
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
tostring GradeLevel, replace
drop id

save "/${yrfiles}/IN_2014_soc_sch.dta", replace


//append all data

use "/${yrfiles}/School2014.dta", clear

append using "/${yrfiles}/Dist2014.dta"
append using "/${yrfiles}/State2014.dta"
append using "/${yrfiles}/IN_2014_soc_sch.dta"
append using "/${yrfiles}/IN_2014_soc_dist.dta"
append using "/${yrfiles}/IN_2014_sci_sch.dta"
append using "/${yrfiles}/IN_2014_sci_dist.dta"

save "/${yrfiles}/IN_2014_appended.dta", replace


////	MERGE NCES

use "/${nces}/NCES_2013_District.dta", clear
drop if state_fips!=18
save "/${yrfiles}/IN_2013_District.dta", replace


use "/${yrfiles}/IN_2014_appended.dta", replace

gen state_leaid=StateAssignedDistID
drop if CorpName=="Independent Non-Public Schools"
drop if StateAssignedDistID=="9200"
drop if StateAssignedDistID=="9205"
drop if StateAssignedDistID=="9210"
drop if StateAssignedDistID=="9215"
drop if StateAssignedDistID=="9220"
drop if StateAssignedDistID=="9230"
drop if StateAssignedDistID=="9240"

merge m:1 state_leaid using "/${yrfiles}/IN_2013_District.dta"
drop if _merge==2
drop _merge

gen seasch=StateAssignedSchID

save "/${yrfiles}/IN_2014.dta", replace

use "/${nces}/NCES_2013_School.dta", clear
drop if state_fips!=18
drop if (seasch=="6637"| seasch=="6645" | seasch=="6647" | seasch=="6649") & SchLevel==-2
save "/${yrfiles}/IN_2013_School.dta", replace


use "/${yrfiles}/IN_2014.dta", replace

merge m:1 seasch using "/${yrfiles}/IN_2013_School.dta"
drop if _merge==2
drop _merge



/////	FINISH CLEANING

rename state_name State
replace State=18
rename state_location StateAbbrev
replace StateAbbrev="IN"
rename state_fips StateFips
replace StateFips=18
gen SchYear="2013-14"
rename lea_name DistName
rename district_agency_type DistType
rename school_name SchName
rename school_type SchType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
gen AssmtName="ISTEP+"
gen AssmtType="Regular"
gen Lev1_count="*"
gen Lev1_percent="*"
gen Lev2_count="*"
gen Lev2_percent="*"
gen Lev3_count="*"
gen Lev3_percent="*"
gen Lev4_count="*"
gen Lev4_percent="*"
gen Lev5_count="*"
gen Lev5_percent="*"
gen AvgScaleScore="*"
gen ProficiencyCriteria="Pass or Pass Plus"
gen ParticipationRate="*"
gen Flag_AssmtNameChange="N"
gen Flag_CutScoreChange_ELA="N"
gen Flag_CutScoreChange_math="N"
gen Flag_CutScoreChange_read=""
gen Flag_CutScoreChange_oth="N"

label define LevelIndicator 0 "State" 1 "District" 2 "School"
label values DataLevel LevelIndicator

replace StudentGroup_TotalTested="*" if StudentGroup_TotalTested=="0"

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


save "/${yrfiles}/IN_2014.dta", replace

export delimited using "/${output}/IN_AssmtData_2014.csv", replace



