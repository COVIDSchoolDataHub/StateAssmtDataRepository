
global yrfiles "/Users/hayden/Desktop/Research/IN/2018"
global nces "/Users/hayden/Desktop/Research/NCES"
global output "/Users/hayden/Desktop/Research/IN/Output"


//////	ORGANIZING AND APPENDING DATA


//// Create state level data

//ela
import excel "/${yrfiles}/IN_OriginalData_2018_all_state.xlsx", sheet("ELA") clear

drop E F G H I

gen count=_n
drop if count==1
drop if count==2
drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="ela"

save "/${yrfiles}/StateELA2018", replace

//math
import excel "/${yrfiles}/IN_OriginalData_2018_all_state.xlsx", sheet("Math") clear

drop E F G

gen count=_n
drop if count==1
drop if count==2
drop if count==10
drop if count==11
drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="math"

save "/${yrfiles}/StateMath2018", replace

//sci
import excel "/${yrfiles}/IN_OriginalData_2018_all_state.xlsx", sheet("Science") clear

drop E F G

gen count=_n
drop if count==1
drop if count==2
drop if count==6
drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="sci"

save "/${yrfiles}/StateSci2018", replace

//soc
import excel "/${yrfiles}/IN_OriginalData_2018_all_state.xlsx", sheet("Social Studies") clear

drop E F G

gen count=_n
drop if count==1
drop if count==2

drop count

rename A GradeLevel
rename B ProficientOrAbove_count
rename C StudentGroup_TotalTested
rename D ProficientOrAbove_percent

gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen Subject="soc"

save "/${yrfiles}/StateSoc2018", replace

// state disaggregate data (math and ela)
import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_state_disagg.xlsx", sheet("Grades 03-08") firstrow clear

drop BothELAandMathPassN BothELAandMathTestN BothELAandMathPass K

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

destring StudentSubGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2018", replace

// generate subgroup totals
collapse (sum) StudentSubGroup_TotalTested, by(Subject StudentGroup)

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/StateDisaggTotals2018", replace

use "/${yrfiles}/StateDisagg2018", clear

merge m:1 StudentGroup Subject using "/${yrfiles}/StateDisaggTotals2018.dta"

drop _merge
gen GradeLevel="G38"
tostring StudentSubGroup_TotalTested StudentGroup_TotalTested, replace

save "/${yrfiles}/StateDisagg2018", replace

//append all state-level files
use "/${yrfiles}/StateELA2018", replace
append using "/${yrfiles}/StateMath2018"
append using "/${yrfiles}/StateSci2018"
append using "/${yrfiles}/StateSoc2018"
append using "/${yrfiles}/StateDisagg2018"

gen DataLevel=0

save "/${yrfiles}/State2018", replace


//// Create district level data

//math and ela
import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_dist.xlsx", sheet("Spring 2018") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename C ProficientOrAbove_count13
rename D StudentGroup_TotalTested13
rename E ProficientOrAbove_percent13

rename F ProficientOrAbove_count23
rename G StudentGroup_TotalTested23
rename H ProficientOrAbove_percent23

drop I J K

rename L ProficientOrAbove_count14
rename M StudentGroup_TotalTested14
rename N ProficientOrAbove_percent14

rename O ProficientOrAbove_count24
rename P StudentGroup_TotalTested24
rename Q ProficientOrAbove_percent24

drop R S T

rename U ProficientOrAbove_count15
rename V StudentGroup_TotalTested15
rename W ProficientOrAbove_percent15

rename X ProficientOrAbove_count25
rename Y StudentGroup_TotalTested25
rename Z ProficientOrAbove_percent25

drop AA AB AC

rename AD ProficientOrAbove_count16
rename AE StudentGroup_TotalTested16
rename AF ProficientOrAbove_percent16

rename AG ProficientOrAbove_count26
rename AH StudentGroup_TotalTested26
rename AI ProficientOrAbove_percent26

drop AJ AK AL

rename AM ProficientOrAbove_count17
rename AN StudentGroup_TotalTested17
rename AO ProficientOrAbove_percent17

rename AP ProficientOrAbove_count27
rename AQ StudentGroup_TotalTested27
rename AR ProficientOrAbove_percent27

drop AS AT AU

rename AV ProficientOrAbove_count18
rename AW StudentGroup_TotalTested18
rename AX ProficientOrAbove_percent18

rename AY ProficientOrAbove_count28
rename AZ StudentGroup_TotalTested28
rename BA ProficientOrAbove_percent28

drop BB BC BD

rename BE ProficientOrAbove_count19
rename BF StudentGroup_TotalTested19
rename BG ProficientOrAbove_percent19

rename BH ProficientOrAbove_count29
rename BI StudentGroup_TotalTested29
rename BJ ProficientOrAbove_percent29

drop BK BL BM BN

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 StudentGroup_TotalTested1 ProficientOrAbove_percent1 ProficientOrAbove_count2 StudentGroup_TotalTested2 ProficientOrAbove_percent2, i(id) j(GradeLevel)

drop id
gen id=_n

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring Subject GradeLevel, replace
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/DistMathELA2018", replace


//science
import excel "/${yrfiles}/IN_OriginalData_2018_sci&soc.xlsx", sheet("2018_Science_Corp") clear

rename A StateAssignedDistID
rename B CorpName

rename C ProficientOrAbove_count4
rename D StudentGroup_TotalTested4
rename E ProficientOrAbove_percent4

rename F ProficientOrAbove_count6
rename G StudentGroup_TotalTested6
rename H ProficientOrAbove_percent6

rename I ProficientOrAbove_count38
rename J StudentGroup_TotalTested38
rename K ProficientOrAbove_percent38

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(GradeLevel)

gen Subject="sci"
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
tostring GradeLevel, replace
drop id

save "/${yrfiles}/DistSci2018", replace


// district social studies
import excel "/${yrfiles}/IN_OriginalData_2018_sci&soc.xlsx", sheet("2018 Social_Studies_Corp") clear

rename A StateAssignedDistID
rename B CorpName

rename C ProficientOrAbove_count5
rename D StudentGroup_TotalTested5
rename E ProficientOrAbove_percent5

rename F ProficientOrAbove_count7
rename G StudentGroup_TotalTested7
rename H ProficientOrAbove_percent7

rename I ProficientOrAbove_count38
rename J StudentGroup_TotalTested38
rename K ProficientOrAbove_percent38

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(GradeLevel)

gen Subject="soc"
gen StudentGroup="All Students"
gen StudentSubGroup="All Students"
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
tostring GradeLevel, replace
drop id

save "/${yrfiles}/DistSoc2018", replace


// dist disaggregate math and ela (race/ethnicity)
import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_dist_disagg.xlsx", sheet("Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to tranform to long (first digit: subject, second digit: racial group)

rename C ProficientOrAbove_count11
rename D StudentGroup_TotalTested11
rename E ProficientOrAbove_percent11

rename F ProficientOrAbove_count21
rename G StudentGroup_TotalTested21
rename H ProficientOrAbove_percent21

drop I J K

rename L ProficientOrAbove_count12
rename M StudentGroup_TotalTested12
rename N ProficientOrAbove_percent12

rename O ProficientOrAbove_count22
rename P StudentGroup_TotalTested22
rename Q ProficientOrAbove_percent22

drop R S T

rename U ProficientOrAbove_count13
rename V StudentGroup_TotalTested13
rename W ProficientOrAbove_percent13

rename X ProficientOrAbove_count23
rename Y StudentGroup_TotalTested23
rename Z ProficientOrAbove_percent23

drop AA AB AC

rename AD ProficientOrAbove_count14
rename AE StudentGroup_TotalTested14
rename AF ProficientOrAbove_percent14

rename AG ProficientOrAbove_count24
rename AH StudentGroup_TotalTested24
rename AI ProficientOrAbove_percent24

drop AJ AK AL

rename AM ProficientOrAbove_count15
rename AN StudentGroup_TotalTested15
rename AO ProficientOrAbove_percent15

rename AP ProficientOrAbove_count25
rename AQ StudentGroup_TotalTested25
rename AR ProficientOrAbove_percent25

drop AS AT AU

rename AV ProficientOrAbove_count16
rename AW StudentGroup_TotalTested16
rename AX ProficientOrAbove_percent16

rename AY ProficientOrAbove_count26
rename AZ StudentGroup_TotalTested26
rename BA ProficientOrAbove_percent26

drop BB BC BD

rename BE ProficientOrAbove_count17
rename BF StudentGroup_TotalTested17
rename BG ProficientOrAbove_percent17

rename BH ProficientOrAbove_count27
rename BI StudentGroup_TotalTested27
rename BJ ProficientOrAbove_percent27

drop BK BL BM BN BO BP BQ BR

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
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

save "/${yrfiles}/DistDisaggRaceEth2018", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggRaceEthTotals2018", replace

use "/${yrfiles}/DistDisaggRaceEth2018", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggRaceEthTotals2018.dta"
drop _merge

save "/${yrfiles}/DistDisaggRaceEth2018", replace



// dist disaggregate math and ela (EL status)

import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_dist_disagg.xlsx", sheet("ELL") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to tranform to long (first digit: subject, second digit: el status)

rename C ProficientOrAbove_count11
rename D StudentGroup_TotalTested11
rename E ProficientOrAbove_percent11

rename F ProficientOrAbove_count21
rename G StudentGroup_TotalTested21
rename H ProficientOrAbove_percent21

drop I J K

rename L ProficientOrAbove_count12
rename M StudentGroup_TotalTested12
rename N ProficientOrAbove_percent12

rename O ProficientOrAbove_count22
rename P StudentGroup_TotalTested22
rename Q ProficientOrAbove_percent22

drop R S T

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
replace StudentSubGroup="English Proficient" if StudentSubGroup=="1"
replace StudentSubGroup="English Learner" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="EL Status"
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

save "/${yrfiles}/DistDisaggELStatus2018", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggELStatusTotals2018", replace

use "/${yrfiles}/DistDisaggELStatus2018", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggELStatusTotals2018.dta"
drop _merge

save "/${yrfiles}/DistDisaggELStatus2018", replace



// economic status (math ela)

import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_dist_disagg.xlsx", sheet("SES") clear

rename A StateAssignedDistID
rename B CorpName

//prepare to tranform to long (first digit: subject, second digit: el status)

rename C ProficientOrAbove_count11
rename D StudentGroup_TotalTested11
rename E ProficientOrAbove_percent11

rename F ProficientOrAbove_count21
rename G StudentGroup_TotalTested21
rename H ProficientOrAbove_percent21

drop I J K

rename L ProficientOrAbove_count12
rename M StudentGroup_TotalTested12
rename N ProficientOrAbove_percent12

rename O ProficientOrAbove_count22
rename P StudentGroup_TotalTested22
rename Q ProficientOrAbove_percent22

drop R S T

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
replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="1"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="Economic Status"
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

save "/${yrfiles}/DistDisaggEconStatus2018", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/DistDisaggEconStatusTotals2018", replace

use "/${yrfiles}/DistDisaggEconStatus2018", clear

merge m:1 StateAssignedDistID Subject using "/${yrfiles}/DistDisaggEconStatusTotals2018.dta"
drop _merge

save "/${yrfiles}/DistDisaggEconStatus2018", replace

// append at district level data

use "/${yrfiles}/DistMathELA2018.dta"
append using "/${yrfiles}/DistSci2018.dta"
append using "/${yrfiles}/DistSoc2018.dta"
append using "/${yrfiles}/DistDisaggEconStatus2018"
append using "/${yrfiles}/DistDisaggELStatus2018"
append using "/${yrfiles}/DistDisaggRaceEth2018"

gen DataLevel=1

save "/${yrfiles}/Dist2018", replace


//// School level data files
import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_sch.xlsx", sheet("Spring 2018") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E ProficientOrAbove_count13
rename F StudentGroup_TotalTested13
rename G ProficientOrAbove_percent13

rename H ProficientOrAbove_count23
rename I StudentGroup_TotalTested23
rename J ProficientOrAbove_percent23

drop K L M

rename N ProficientOrAbove_count14
rename O StudentGroup_TotalTested14
rename P ProficientOrAbove_percent14

rename Q ProficientOrAbove_count24
rename R StudentGroup_TotalTested24
rename S ProficientOrAbove_percent24

drop T U V

rename W ProficientOrAbove_count15
rename X StudentGroup_TotalTested15
rename Y ProficientOrAbove_percent15

rename Z ProficientOrAbove_count25
rename AA StudentGroup_TotalTested25
rename AB ProficientOrAbove_percent25

drop AC AD AE

rename AF ProficientOrAbove_count16
rename AG StudentGroup_TotalTested16
rename AH ProficientOrAbove_percent16

rename AI ProficientOrAbove_count26
rename AJ StudentGroup_TotalTested26
rename AK ProficientOrAbove_percent26

drop AL AM AN

rename AO ProficientOrAbove_count17
rename AP StudentGroup_TotalTested17
rename AQ ProficientOrAbove_percent17

rename AR ProficientOrAbove_count27
rename AS StudentGroup_TotalTested27
rename AT ProficientOrAbove_percent27

drop AU AV AW

rename AX ProficientOrAbove_count18
rename AY StudentGroup_TotalTested18
rename AZ ProficientOrAbove_percent18

rename BA ProficientOrAbove_count28
rename BB StudentGroup_TotalTested28
rename BC ProficientOrAbove_percent28

drop BD BE BF

rename BG ProficientOrAbove_count19
rename BH StudentGroup_TotalTested19
rename BI ProficientOrAbove_percent19

rename BJ ProficientOrAbove_count29
rename BK StudentGroup_TotalTested29
rename BL ProficientOrAbove_percent29

drop BM BN BO BP

gen id=_n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count1 StudentGroup_TotalTested1 ProficientOrAbove_percent1 ProficientOrAbove_count2 StudentGroup_TotalTested2 ProficientOrAbove_percent2, i(id) j(GradeLevel)

drop id
gen id=_n

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(Subject)

drop id

tostring Subject GradeLevel, replace
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

save "/${yrfiles}/SchMathELA2018", replace


// science

import excel "/${yrfiles}/IN_OriginalData_2018_sci&soc.xlsx", sheet("2018_Science_School") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long by grade

rename E ProficientOrAbove_count4
rename F StudentGroup_TotalTested4
rename G ProficientOrAbove_percent4

rename H ProficientOrAbove_count6
rename I StudentGroup_TotalTested6
rename J ProficientOrAbove_percent6

rename K ProficientOrAbove_count38
rename L StudentGroup_TotalTested38
rename M ProficientOrAbove_percent38

gen id = _n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(GradeLevel)

drop id
tostring GradeLevel, replace
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

gen Subject="sci"

save "/${yrfiles}/SchSci2018", replace


// social studies

import excel "/${yrfiles}/IN_OriginalData_2018_sci&soc.xlsx", sheet("2018_Social_Studies_School") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long by grade

rename E ProficientOrAbove_count5
rename F StudentGroup_TotalTested5
rename G ProficientOrAbove_percent5

rename H ProficientOrAbove_count7
rename I StudentGroup_TotalTested7
rename J ProficientOrAbove_percent7

rename K ProficientOrAbove_count38
rename L StudentGroup_TotalTested38
rename M ProficientOrAbove_percent38

gen id = _n
drop if id==1
drop if id==2

reshape long ProficientOrAbove_count StudentGroup_TotalTested ProficientOrAbove_percent, i(id) j(GradeLevel)

drop id
tostring GradeLevel, replace
gen StudentSubGroup_TotalTested=StudentGroup_TotalTested
gen StudentSubGroup="All Students"
gen StudentGroup="All Students"

gen Subject="soc"

save "/${yrfiles}/SchSoc2018", replace


// disaggregate school math and ela (race/ethnicity)

import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_sch_disagg.xlsx", sheet("Ethnicity") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E ProficientOrAbove_count11
rename F StudentGroup_TotalTested11
rename G ProficientOrAbove_percent11

rename H ProficientOrAbove_count21
rename I StudentGroup_TotalTested21
rename J ProficientOrAbove_percent21

drop K L M

rename N ProficientOrAbove_count12
rename O StudentGroup_TotalTested12
rename P ProficientOrAbove_percent12

rename Q ProficientOrAbove_count22
rename R StudentGroup_TotalTested22
rename S ProficientOrAbove_percent22

drop T U V

rename W ProficientOrAbove_count13
rename X StudentGroup_TotalTested13
rename Y ProficientOrAbove_percent13

rename Z ProficientOrAbove_count23
rename AA StudentGroup_TotalTested23
rename AB ProficientOrAbove_percent23

drop AC AD AE

rename AF ProficientOrAbove_count14
rename AG StudentGroup_TotalTested14
rename AH ProficientOrAbove_percent14

rename AI ProficientOrAbove_count24
rename AJ StudentGroup_TotalTested24
rename AK ProficientOrAbove_percent24

drop AL AM AN

rename AO ProficientOrAbove_count15
rename AP StudentGroup_TotalTested15
rename AQ ProficientOrAbove_percent15

rename AR ProficientOrAbove_count25
rename AS StudentGroup_TotalTested25
rename AT ProficientOrAbove_percent25

drop AU AV AW

rename AX ProficientOrAbove_count16
rename AY StudentGroup_TotalTested16
rename AZ ProficientOrAbove_percent16

rename BA ProficientOrAbove_count26
rename BB StudentGroup_TotalTested26
rename BC ProficientOrAbove_percent26

drop BD BE BF

rename BG ProficientOrAbove_count17
rename BH StudentGroup_TotalTested17
rename BI ProficientOrAbove_percent17

rename BJ ProficientOrAbove_count27
rename BK StudentGroup_TotalTested27
rename BL ProficientOrAbove_percent27

drop BM BN BO

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
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

save "/${yrfiles}/SchDisaggRaceEth2018", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID StateAssignedSchID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggRaceEthTotals2018", replace

use "/${yrfiles}/SchDisaggRaceEth2018", clear

merge m:1 StateAssignedDistID Subject StateAssignedSchID using "/${yrfiles}/SchDisaggRaceEthTotals2018.dta"
drop _merge

save "/${yrfiles}/SchDisaggRaceEth2018", replace



// school disaggregate math and ela (EL status)

import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_sch_disagg.xlsx", sheet("ELL") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E ProficientOrAbove_count11
rename F StudentGroup_TotalTested11
rename G ProficientOrAbove_percent11

rename H ProficientOrAbove_count21
rename I StudentGroup_TotalTested21
rename J ProficientOrAbove_percent21

drop K L M

rename N ProficientOrAbove_count12
rename O StudentGroup_TotalTested12
rename P ProficientOrAbove_percent12

rename Q ProficientOrAbove_count22
rename R StudentGroup_TotalTested22
rename S ProficientOrAbove_percent22

drop T U V

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
replace StudentSubGroup="English Proficient" if StudentSubGroup=="1"
replace StudentSubGroup="English Learner" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="EL Status"
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

save "/${yrfiles}/SchDisaggELStatus2018", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID StateAssignedSchID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggELStatusTotals2018", replace

use "/${yrfiles}/SchDisaggELStatus2018", clear

merge m:1 StateAssignedDistID Subject StateAssignedSchID using "/${yrfiles}/SchDisaggELStatusTotals2018.dta"
drop _merge

save "/${yrfiles}/SchDisaggELStatus2018", replace



// school disaggregate math and ela (Econ status)

import excel "/${yrfiles}/IN_OriginalData_2018_mat&ela_sch_disagg.xlsx", sheet("SES") clear

rename A StateAssignedDistID
rename B CorpName
rename C StateAssignedSchID
rename D SchoolNameOriginalData

//prepare to transform from wide to long (first digit: 1=ela, 2=math, second digit: grade)

rename E ProficientOrAbove_count11
rename F StudentGroup_TotalTested11
rename G ProficientOrAbove_percent11

rename H ProficientOrAbove_count21
rename I StudentGroup_TotalTested21
rename J ProficientOrAbove_percent21

drop K L M

rename N ProficientOrAbove_count12
rename O StudentGroup_TotalTested12
rename P ProficientOrAbove_percent12

rename Q ProficientOrAbove_count22
rename R StudentGroup_TotalTested22
rename S ProficientOrAbove_percent22

drop T U V

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
replace StudentSubGroup="Not Economically Disadvantaged" if StudentSubGroup=="1"
replace StudentSubGroup="Economically Disadvantaged" if StudentSubGroup=="2"
replace Subject="ela" if Subject=="1"
replace Subject="math" if Subject=="2"

gen StudentGroup="Economic Status"
rename StudentGroup_TotalTested StudentSubGroup_TotalTested

save "/${yrfiles}/SchDisaggEconStatus2018", replace

// gen student group totals

replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested==""
replace StudentSubGroup_TotalTested="100000000000" if StudentSubGroup_TotalTested=="***"

destring StudentSubGroup_TotalTested, replace
collapse (sum) StudentSubGroup_TotalTested, by(Subject StateAssignedDistID StateAssignedSchID)

replace StudentSubGroup_TotalTested=100000000000 if StudentSubGroup_TotalTested>=100000000000

tostring StudentSubGroup_TotalTested, replace
replace StudentSubGroup_TotalTested="*" if StudentSubGroup_TotalTested=="1.00000e+11"

rename StudentSubGroup_TotalTested StudentGroup_TotalTested

save "/${yrfiles}/SchDisaggEconStatusTotals2018", replace

use "/${yrfiles}/SchDisaggEconStatus2018", clear

merge m:1 StateAssignedDistID Subject StateAssignedSchID using "/${yrfiles}/SchDisaggEconStatusTotals2018.dta"
drop _merge

save "/${yrfiles}/SchDisaggEconStatus2018", replace


//append state level data
use "/${yrfiles}/SchMathELA2018.dta", clear
append using "/${yrfiles}/SchSci2018.dta"
append using "/${yrfiles}/SchSoc2018.dta"
append using "/${yrfiles}/SchDisaggEconStatus2018"
append using "/${yrfiles}/SchDisaggELStatus2018"
append using "/${yrfiles}/SchDisaggRaceEth2018"

gen DataLevel=2

save "/${yrfiles}/School2018", replace

//append all data
append using "/${yrfiles}/Dist2018.dta"
append using "/${yrfiles}/State2018.dta"

save "/${yrfiles}/IN_2018_appended.dta", replace


////	MERGE NCES

use "/${nces}/NCES_2017_District.dta", clear
drop if state_fips!=18
save "/${yrfiles}/IN_2017_District.dta", replace


use "/${yrfiles}/IN_2018_appended.dta", replace

gen state_leaid="IN-"+StateAssignedDistID
drop if CorpName=="Independent Non-Public Schools"
drop if StateAssignedDistID=="9200"
drop if StateAssignedDistID=="9205"
drop if StateAssignedDistID=="9210"
drop if StateAssignedDistID=="9215"
drop if StateAssignedDistID=="9220"
drop if StateAssignedDistID=="9230"
drop if StateAssignedDistID=="9240"

merge m:1 state_leaid using "/${yrfiles}/IN_2017_District.dta"
drop if _merge==2
drop _merge

gen seasch=StateAssignedDistID+"-"+StateAssignedSchID

save "/${yrfiles}/IN_2018.dta", replace

use "/${nces}/NCES_2017_School.dta", clear
drop if state_fips!=18
save "/${yrfiles}/IN_2017_School.dta", replace


use "/${yrfiles}/IN_2018.dta", replace

merge m:1 seasch using "/${yrfiles}/IN_2017_School.dta"
drop if _merge==2
drop _merge



/////	FINISH CLEANING

rename state_name State
replace State=18
rename state_location StateAbbrev
replace StateAbbrev="IN"
rename state_fips StateFips
replace StateFips=18
gen SchYear="2017-18"
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


save "/${yrfiles}/IN_2018.dta", replace

export delimited using "/${output}/IN_AssmtData_2018.csv", replace



