*******************************************************
* NEW YORK		

* File name: Combining 2018-onwards
* Last update: 04/03/2025

*******************************************************
* Notes

	* This do file imports and combines NY data from 2018 onwards.
	* The combined files are saved in the Combined subfolder.
	* This file should be updated when newer data are released.
	* Note the naming convention of the temp files - tempfile#_xx
	* where xx refers to the last two digits of the year being imported. 
	
*******************************************************
clear

*******************************************************
//Importing 2018 Data
*******************************************************

import delimited "${Original_1}/NY_OriginalData_ela_2018.txt", clear stringcols(1)

gen subject = "ELA"

tempfile temp1_18
save "`temp1_18'"

import delimited "${Original_1}/NY_OriginalData_mat_2018.txt", clear stringcols(1)

gen subject = "MATH"

tempfile temp2_18
save "`temp2_18'"

import delimited "${Original_1}/NY_OriginalData_sci_2018.txt", clear stringcols(1)

gen subject = "SCIENCE"

tempfile temp3_18
save "`temp3_18'"
clear

//Appending

foreach n in 1 2 3 {
	append using "`temp`n'_18'", force
}

save "${Combined}/Combined_2018.dta", replace

*******************************************************
//Importing 2019 Data
*******************************************************
clear

//Standardizing varnames and combining
//ELA *CROSSWALK IN README IS WRONG*
import delimited "${Original_2}/NY_OriginalData_ela_2019.txt", clear stringcols(1)
rename v2 ENTITY_NAME
rename v3 YEAR
rename v4 ASSESSMENT
rename v5 StudentSubGroup
rename v6 StudentSubGroup_TotalTested
rename v7 NOT_TESTED
rename v8 Lev1_count
rename v9 Lev1_percent
rename v10 Lev2_count
rename v11 Lev2_percent
rename v12 Lev3_count
rename v13 Lev3_percent
rename v14 Lev4_count
rename v15 Lev4_percent
rename v16 NUM_PROF
rename v17 PER_PROF
rename v18 TOTAL_SCALE_SCORES
rename v19 AvgScaleScore
gen subject= "ELA"

tempfile temp1_19
save "`temp1_19'"

//MATH
import delimited "${Original_2}/NY_OriginalData_mat_2019.txt", clear stringcols(1)
rename v2 ENTITY_NAME
rename v3 YEAR
rename v4 ASSESSMENT
rename v5 StudentSubGroup
rename v6 StudentSubGroup_TotalTested
rename v7 NOT_TESTED
rename v8 Lev1_count
rename v9 Lev1_percent
rename v10 Lev2_count
rename v11 Lev2_percent
rename v12 Lev3_count
rename v13 Lev3_percent
rename v14 Lev4_count
rename v15 Lev4_percent
rename v16 Lev5_count
rename v17 Lev5_percent
rename v18 NUM_PROF
rename v19 PER_PROF
rename v20 TOTAL_SCALE_SCORES
rename v21 AvgScaleScore
gen subject = "MATH"

tempfile temp2_19
save "`temp2_19'"

//SCI *CROSSWALK IN README IS WRONG*
import delimited "${Original_2}/NY_OriginalData_sci_2019.txt", clear stringcols(1)

rename v2 ENTITY_NAME
rename v3 YEAR
rename v4 ASSESSMENT
rename v5 StudentSubGroup
rename v6 StudentSubGroup_TotalTested
rename v7 NOT_TESTED
rename v8 Lev1_count
rename v9 Lev1_percent
rename v10 Lev2_count
rename v11 Lev2_percent
rename v12 Lev3_count
rename v13 Lev3_percent
rename v14 Lev4_count
rename v15 Lev4_percent
rename v16 NUM_PROF
rename v17 PER_PROF
rename v18 TOTAL_SCALE_SCORES
rename v19 AvgScaleScore
gen subject = "SCIENCE"

tempfile temp3_19
save "`temp3_19'"
clear

//Appending
foreach n in 1 2 3 {
	append using "`temp`n'_19'", force
}

save "${Combined}/Combined_2019.dta", replace

*******************************************************
//Importing 2021 Data
*******************************************************
clear

//ELA
import delimited "${Original_2}/NY_OriginalData_ela_2021.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
gen subject = "ELA"

tempfile temp1_21
save "`temp1_21'"

//MATH
import delimited "${Original_2}/NY_OriginalData_mat_2021.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 Lev5_count
rename v21 Lev5_percent
rename v22 NUM_PROF
rename v23 PER_PROF
drop v24
drop v25
drop v26
drop v27
drop v28
gen subject = "MATH"

tempfile temp2_21
save "`temp2_21'"

//SCIENCE
import delimited "${Original_2}/NY_OriginalData_sci_2021.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
drop v22
drop v23
drop v24
drop v25
drop v26
gen subject = "SCIENCE"

tempfile temp3_21
save "`temp3_21'"
clear
//Appending

foreach n in 1 2 3 {
	append using "`temp`n'_21'", force
}

save "${Combined}/Combined_2021.dta", replace

*******************************************************
//Importing 2022 Data
*******************************************************
clear

//ELA
import delimited "${Original_2}/NY_OriginalData_ela_2022.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
gen subject = "ELA"

tempfile temp1_22
save "`temp1_22'"

//MATH
import delimited "${Original_2}/NY_OriginalData_mat_2022.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 Lev5_count
rename v21 Lev5_percent
rename v22 NUM_PROF
rename v23 PER_PROF
rename v24 TOTAL_SCALE_SCORES
rename v25 AvgScaleScore
drop v26
drop v27
drop v28
drop v29
drop v30
gen subject = "MATH"

tempfile temp2_22
save "`temp2_22'"

//SCIENCE
import delimited "${Original_2}/NY_OriginalData_sci_2022.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
drop v24
drop v25
drop v26
drop v27
drop v28
gen subject = "SCIENCE"

tempfile temp3_22
save "`temp3_22'"
clear

//Appending
foreach n in 1 2 3 {
	append using "`temp`n'_22'", force
}

save "${Combined}/Combined_2022.dta", replace

*******************************************************
//Importing 2023 Data
*******************************************************
clear

//ELA
import delimited "${Original_2}/NY_OriginalData_ela_2023.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
gen subject = "ELA"

tempfile temp1_23
save "`temp1_23'"

//MATH
import delimited "${Original_2}/NY_OriginalData_mat_2023.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 Lev5_count
rename v21 Lev5_percent
rename v22 NUM_PROF
rename v23 PER_PROF
rename v24 TOTAL_SCALE_SCORES
rename v25 AvgScaleScore
gen subject = "MATH"

tempfile temp2_23
save "`temp2_23'"

//SCIENCE
import delimited "${Original_2}/NY_OriginalData_sci_2023.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
gen subject = "SCIENCE"

tempfile temp3_23
save "`temp3_23'"
clear

//Appending
foreach n in 1 2 3 {
	append using "`temp`n'_23'", force
}

save "${Combined}/Combined_2023.dta", replace

*******************************************************
//Importing 2024 Data
*******************************************************
//ELA
import delimited "${Original_2}/NY_OriginalData_ela_2024.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
gen subject = "ELA"

tempfile temp1_24
save "`temp1_24'"

//MATH

import delimited "${Original_2}/NY_OriginalData_mat_2024.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 Lev5_count
rename v21 Lev5_percent
rename v22 NUM_PROF
rename v23 PER_PROF
rename v24 TOTAL_SCALE_SCORES
rename v25 AvgScaleScore
gen subject = "MATH"

tempfile temp2_24
save "`temp2_24'"

//SCIENCE
import delimited "${Original_2}/NY_OriginalData_sci_2024.txt", clear stringcols(2)
drop v1
rename v2 v1
rename v3 ENTITY_NAME
rename v4 YEAR
rename v5 ASSESSMENT
rename v6 StudentSubGroup
rename v7 TOTAL_COUNT
rename v8 NOT_TESTED
rename v9 PCT_NOT_TESTED
rename v10 StudentSubGroup_TotalTested
rename v11 ParticipationRate
rename v12 Lev1_count
rename v13 Lev1_percent
rename v14 Lev2_count
rename v15 Lev2_percent
rename v16 Lev3_count
rename v17 Lev3_percent
rename v18 Lev4_count
rename v19 Lev4_percent
rename v20 NUM_PROF
rename v21 PER_PROF
rename v22 TOTAL_SCALE_SCORES
rename v23 AvgScaleScore
gen subject = "SCIENCE"

tempfile temp3_24
save "`temp3_24'"
clear

//Appending

foreach n in 1 2 3 {
	append using "`temp`n'_24'", force
}

save "${Combined}/Combined_2024.dta", replace
*End of Combining 2018-onwards
****************************************************
