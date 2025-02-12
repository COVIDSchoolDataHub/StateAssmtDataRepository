*******************************************************
* CONNECTICUT

* File name: 01_CT_Cleaning
* Last update: 2/11/2025

*******************************************************
* Notes

	* This do file cleans CT's yearly data and merges with NCES
	* This file does NOT include 2021, which was formatted differently from other years.
	* As of 2/5/25, the most recent NCES file available is NCES_2022. This will be used for 2023 and 2024 data files.
	* This file will need to be updated when NCES_2023 becomes available
	
*******************************************************

/////////////////////////////////////////
*** Setup ***
/////////////////////////////////////////

clear

/////////////////////////////////////////
*** Cleaning ***
/////////////////////////////////////////
log using variablescheck.log, replace
//Standardizing Varnames (and variables if necessary) before appending
forvalues year = 2015/2024 {
	local prevyear =`=`year'-1'
	if `year' == 2020 | `year' == 2021 continue
	tempfile temp_`year'
	save "`temp_`year''", emptyok
	foreach dl in State Dist Sch {
		foreach sg in All EL FC FRM2 Gen Home MC RE SWD {
			if ("`sg'" == "FC" | "`sg'" == "Home" | "`sg'" == "MC") & (`year' == 2015 | `year' == 2016 | `year' == 2017) continue
			foreach subject in ela_mat sci {
				if (`year' == 2015 | `year' == 2016 | `year' == 2017 | `year' == 2018) & "`subject'" == "sci" continue
				di "~~~~~~~~"
				di "`year'"
				di "`dl'"
				di "`sg'"
				di "`subject'"
				import delimited "${Original}/`dl'_`sg'_CT_OriginalData_`year'_`subject'.csv", clear

*Replaces missing values by duplicating the value above it only for 2024 because the col values are not repeated in 2024. Repeats in other files. 
if "`dl'" == "State" & "`year'" == "2024" {
replace v1 = v1[_n-1] if missing(v1)
replace v2 = v2[_n-1] if missing(v2)
replace v3 = v3[_n-1] if missing(v3)
}

if "`dl'" == "Dist" & "`year'" == "2024" {
replace v1 = v1[_n-1] if missing(v1)
replace v2 = v2[_n-1] if missing(v2)
replace v3 = v3[_n-1] if missing(v3)
replace v4 = v4[_n-1] if missing(v4)
} 

if "`dl'" == "Sch" & "`year'" == "2024" {
replace v1 = v1[_n-1] if missing(v1)
replace v2 = v2[_n-1] if missing(v2)
replace v3 = v3[_n-1] if missing(v3)
replace v4 = v4[_n-1] if missing(v4)
replace v5 = v5[_n-1] if missing(v5)
replace v6 = v6[_n-1] if missing(v6)
}




				//import delimited "${Original}/Sch_All_CT_OriginalData_2017_ela_mat.csv", clear
				*Generates DataLevels*
				if "`dl'" == "State" gen DataLevel = "State" 
				if "`dl'" == "Dist" gen DataLevel = "District" 
				if "`dl'" == "Sch" gen DataLevel = "School" 
				
				*Generates the subject variable and renames the variables following the new subject variable.*
				if "`subject'" == "sci" & "`dl'" != "Sch" {
					forvalues n = 22(-1)3 {
					local new = `n'+1
					capture rename v`n' v`new'
					}
					gen v3 = "sci"
				}
				
				*Generates the subject variable and renames the variables following the new subject variable.*
				if "`subject'" == "sci" & "`dl'" == "Sch" {
					forvalues n = 22(-1)5 {
					local new = `n'+1
					capture rename v`n' v`new'
					}
					gen v5 = "sci"
					
				}
				
				if "`dl'" == "State" & "`sg'" == "All" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					drop v4
					gen StudentSubGroup = "All Students"
					rename v5 StudentSubGroup_TotalTested
					rename v6 ParticipationRate
					drop v7
					rename v8 Lev1_count
					rename v9 Lev1_percent
					rename v10 Lev2_count
					rename v11 Lev2_percent
					rename v12 Lev3_count
					rename v13 Lev3_percent
					rename v14 Lev4_count
					rename v15 Lev4_percent
					rename v16 ProficientOrAbove_count
					rename v17 ProficientOrAbove_percent
					rename v18 AvgScaleScore
					
				}
				
				if "`dl'" == "State" & "`sg'" == "EL" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "English Learner" if strpos(v4, "Y") !=0
					replace v4 = "English Proficient" if strpos(v4, "N") !=0
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
					
				}
				if "`dl'" == "State" & "`sg'" == "FRM2"  {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "Economically Disadvantaged" if strpos(v4, "Y") !=0
					replace v4 = "Not Economically Disadvantaged" if strpos(v4, "N") !=0
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" & "`sg'" == "Gen" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" & "`sg'" == "RE" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" {
					gen SchName = "All Schools"
					gen StateAssignedSchID = ""
					gen StateAssignedDistID = ""
				}
				if "`dl'" == "Dist" & "`sg'" == "All" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					gen StudentSubGroup = "All Students"
					rename v4 Subject
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "EL" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "English Learner" if strpos(v5, "Y") !=0
					replace v5 = "English Proficient" if strpos(v5, "N") !=0
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
					
					
				}
				
				if "`dl'" == "Dist" & "`sg'" == "FRM2" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "Economically Disadvantaged" if strpos(v5, "Y") !=0
					replace v5 = "Not Economically Disadvantaged" if strpos(v5, "N") !=0
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "Gen" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "RE" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" {
					gen SchName = "All Schools"
					gen StateAssignedSchID = ""
				}
				if "`dl'" == "Sch" & "`sg'" == "All" {
					gen StudentSubGroup = "All Students"
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					drop v7 
					rename v8 StudentSubGroup_TotalTested
					rename v9 ParticipationRate
					drop v10
					rename v11 Lev1_count
					rename v12 Lev1_percent
					rename v13 Lev2_count
					rename v14 Lev2_percent
					rename v15 Lev3_count
					rename v16 Lev3_percent
					rename v17 Lev4_count
					rename v18 Lev4_percent
					rename v19 ProficientOrAbove_count
					rename v20 ProficientOrAbove_percent
					rename v21 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "EL" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "English Learner" if strpos(v7, "Y") !=0
					replace v7 = "English Proficient" if strpos(v7, "N") !=0
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "FRM2" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "Economically Disadvantaged" if strpos(v7, "Y") !=0
					replace v7 = "Not Economically Disadvantaged" if strpos(v7, "N") !=0
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "Gen" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "RE" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "State" & "`sg'" == "FC" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "Foster Care" if strpos(v4, "Y") !=0
					replace v4 = "Non-Foster Care" if strpos(v4, "N") !=0
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
					
				}
				if "`dl'" == "State" & "`sg'" == "Home" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "Homeless" if strpos(v4, "Y") !=0
					replace v4 = "Non-Homeless" if strpos(v4, "N") !=0
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" & "`sg'" == "MC" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "Military" if strpos(v4, "Y") !=0
					replace v4 = "Non-Military" if strpos(v4, "N") !=0
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "State" & "`sg'" == "SWD" {
					rename v1 DistName
					rename v2 GradeLevel
					rename v3 Subject
					replace v4 = "SWD" if strpos(v4, "Y") !=0
					replace v4 = "Non-SWD" if strpos(v4, "N") !=0
					rename v4 StudentSubGroup
					drop v5
					rename v6 StudentSubGroup_TotalTested
					rename v7 ParticipationRate
					drop v8
					rename v9 Lev1_count
					rename v10 Lev1_percent
					rename v11 Lev2_count
					rename v12 Lev2_percent
					rename v13 Lev3_count
					rename v14 Lev3_percent
					rename v15 Lev4_count
					rename v16 Lev4_percent
					rename v17 ProficientOrAbove_count
					rename v18 ProficientOrAbove_percent
					rename v19 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "FC" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "Foster Care" if strpos(v5, "Y") !=0
					replace v5 = "Non-Foster Care" if strpos(v5, "N") !=0
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "Home" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "Homeless" if strpos(v5, "Y") !=0
					replace v5 = "Non-Homeless" if strpos(v5, "N") !=0
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "MC" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "Military" if strpos(v5, "Y") !=0
					replace v5 = "Non-Military" if strpos(v5, "N") !=0
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Dist" & "`sg'" == "SWD" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 GradeLevel
					rename v4 Subject
					replace v5 = "SWD" if strpos(v5, "Y") !=0
					replace v5 = "Non-SWD" if strpos(v5, "N") !=0
					rename v5 StudentSubGroup
					drop v6
					rename v7 StudentSubGroup_TotalTested
					rename v8 ParticipationRate
					drop v9
					rename v10 Lev1_count
					rename v11 Lev1_percent
					rename v12 Lev2_count
					rename v13 Lev2_percent
					rename v14 Lev3_count
					rename v15 Lev3_percent
					rename v16 Lev4_count
					rename v17 Lev4_percent
					rename v18 ProficientOrAbove_count
					rename v19 ProficientOrAbove_percent
					rename v20 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "FC" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "Foster Care" if strpos(v7, "Y") !=0
					replace v7 = "Non-Foster Care" if strpos(v7, "N") !=0
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "Home" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "Homeless" if strpos(v7, "Y") !=0
					replace v7 = "Non-Homeless" if strpos(v7, "N") !=0
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "MC" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "Military" if strpos(v7, "Y") !=0
					replace v7 = "Non-Military" if strpos(v7, "N") !=0
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`dl'" == "Sch" & "`sg'" == "SWD" {
					rename v1 DistName
					rename v2 StateAssignedDistID
					rename v3 SchName
					rename v4 StateAssignedSchID
					rename v5 GradeLevel
					rename v6 Subject
					replace v7 = "SWD" if strpos(v7, "Y") !=0
					replace v7 = "Non-SWD" if strpos(v7, "N") !=0
					rename v7 StudentSubGroup
					drop v8
					rename v9 StudentSubGroup_TotalTested
					rename v10 ParticipationRate
					drop v11
					rename v12 Lev1_count
					rename v13 Lev1_percent
					rename v14 Lev2_count
					rename v15 Lev2_percent
					rename v16 Lev3_count
					rename v17 Lev3_percent
					rename v18 Lev4_count
					rename v19 Lev4_percent
					rename v20 ProficientOrAbove_count
					rename v21 ProficientOrAbove_percent
					rename v22 AvgScaleScore
				}
				if "`subject'" == "sci" & "`dl'" != "State" {
					replace GradeLevel = Subject
					drop Subject
					gen Subject = "sci"
					
				}
				drop in 1/4
				save "${Original}/`dl'_`sg'_CT_OriginalData_`year'_`subject'.dta", replace
				append using "`temp_`year''"
				save "`temp_`year''", replace
				clear
			}
		}
	}
*Temporarily stores data by year which would include subgroups. 	
use "`temp_`year''"

*Strips unnecessary characters and leaves only numeric values*
//StateAssignedDistID and StateAssignedSchID
replace StateAssignedDistID = subinstr(StateAssignedDistID, "=","",.)
replace StateAssignedSchID = subinstr(StateAssignedSchID,"=","",.)
replace StateAssignedDistID = subinstr(StateAssignedDistID,`"""',"",.)
replace StateAssignedSchID = subinstr(StateAssignedSchID,`"""',"",.)


//StudentSubGroup
replace StudentSubGroup = "Hispanic or Latino" if strpos(StudentSubGroup, "Hispanic") !=0
replace StudentSubGroup = "Two or More" if strpos(StudentSubGroup, "Two or More") !=0
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if strpos(StudentSubGroup, "Hawaiian") !=0
replace StudentSubGroup = "Female" if StudentSubGroup == "F"
replace StudentSubGroup = "Male" if StudentSubGroup == "M"


//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X" 
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "RaceEth" if StudentSubGroup == "Hispanic or Latino"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"


keep if StudentGroup == "All Students" | StudentGroup == "RaceEth" | StudentGroup == "Economic Status" | StudentGroup == "Gender" | StudentGroup == "EL Status" | StudentGroup == "RaceEth" | StudentGroup == "Disability Status" | StudentGroup == "Homeless Enrolled Status" | StudentGroup == "Foster Care Status" | StudentGroup == "Military Connected Status"

//StudentGroup_TotalTested
replace StudentSubGroup_TotalTested = string(real(Lev1_count) + real(Lev2_count) + real(Lev3_count) + real(Lev4_count)) if StudentSubGroup_TotalTested == "*" & !missing(real(Lev1_count)) & !missing(real(Lev2_count)) & !missing(real(Lev3_count)) & !missing(real(Lev4_count))

*Generating IDs and StudentGroup_TotalTested
gen StateAssignedDistID1 = StateAssignedDistID
replace StateAssignedDistID1 = "000000" if DataLevel == "State" //Remove quotations if DistIDs are numeric
gen StateAssignedSchID1 = StateAssignedSchID
replace StateAssignedSchID1 = "000000" if DataLevel != "School" //Remove quotations if SchIDs are numeric
egen group_id = group(DataLevel StateAssignedDistID1 StateAssignedSchID1 Subject GradeLevel)
sort group_id StudentGroup StudentSubGroup
by group_id: gen StudentGroup_TotalTested = StudentSubGroup_TotalTested if StudentSubGroup == "All Students"
by group_id: replace StudentGroup_TotalTested = StudentGroup_TotalTested[_n-1] if missing(StudentGroup_TotalTested)
drop group_id StateAssignedDistID1 StateAssignedSchID1

//DataLevel
label def DataLevel 1 "State" 2 "District" 3 "School"
encode DataLevel, gen(DataLevel_n) label(DataLevel)
sort DataLevel_n 
drop DataLevel 
rename DataLevel_n DataLevel
replace SchName = "All Schools" if DataLevel !=3
replace DistName = "All Districts" if DataLevel ==1

//Subject
replace Subject = lower(Subject)

//GradeLevel
replace GradeLevel = "G" + GradeLevel
keep if inlist(GradeLevel,"G03","G04","G05","G06","G07","G08")

//Year
gen SchYear = "`prevyear'" + "-" + substr("`year'",-2,2)

//Merging with NCES Data//
gen StateAssignedDistID1 = substr(StateAssignedDistID,1,3)
gen StateAssignedDistID2 = StateAssignedDistID
gen StateAssignedSchID1 = StateAssignedDistID1 + "-" + substr(StateAssignedSchID,4,2)
gen StateAssignedSchID2 = StateAssignedDistID + "-" + StateAssignedSchID
tempfile temp1
save "`temp1'", replace

//District
keep if DataLevel ==2
tempfile tempdist
save "`tempdist'", replace
//clear



if `year' < 2023 {
use "${NCES_District}/NCES_`prevyear'_District"
keep if state_name == "Connecticut" | state_location == "CT"
save "${NCES_State}/NCES_`prevyear'_District_CT", replace
}

else if `year'>=2023{
use "${NCES_District}/NCES_2022_District"
keep if state_name == "Connecticut" | state_location == "CT"
save "${NCES_State}/NCES_2022_District_CT", replace
}
if `year' <2019 {
gen StateAssignedDistID1 = subinstr(state_leaid,"CT-","",.)
merge 1:m StateAssignedDistID1 using "`tempdist'"
}

if `year' >= 2019 {
	gen StateAssignedDistID2 = subinstr(state_leaid,"CT-","",.)
	merge 1:m StateAssignedDistID2 using "`tempdist'"
}
drop if _merge ==1
save "`tempdist'", replace
clear

//School
use "`temp1'"
keep if DataLevel==3
tempfile tempschool
save "`tempschool'", replace
if `year' <2023 {
use "${NCES_School}/NCES_`prevyear'_School"
keep if state_name == "Connecticut" | state_location == "CT"
save "${NCES_State}/NCES_`prevyear'_School_CT", replace
}
else if `year' >= 2023 {
use "${NCES_School}/NCES_2022_School"
keep if state_name == "Connecticut" | state_location == "CT"
save "${NCES_State}/NCES_2022_School_CT", replace
}
gen StateAssignedDistID1 = subinstr(state_leaid,"CT-","",.)
if `year' <2019 {
gen StateAssignedSchID1 = StateAssignedDistID1 + "-" + seasch if strpos(seasch,"-") ==0
replace StateAssignedSchID1 = seasch if strpos(seasch,"-") !=0
drop if StateAssignedSchID1=="-"


merge 1:m StateAssignedSchID1 using "`tempschool'"
drop if _merge ==1
}




if `year' >= 2019 {
	gen StateAssignedSchID2 = seasch 
	merge 1:m StateAssignedSchID2 using "`tempschool'"
	drop if _merge ==1
}

if "`year'" == "2024" | "`year'" == "2023" {
decode district_agency_type, gen(district_agency_type1)
drop district_agency_type
rename district_agency_type1 district_agency_type
}

save "`tempschool'", replace
clear



//Appending
use "`temp1'"

keep if DataLevel==1
append using "`tempdist'" 
if "`year'" == "2024" | "`year'" == "2023" {
destring year, replace 
drop boundary_change_indicator
drop number_of_schools
drop fips
}
append using "`tempschool'"

//Fixing NCES Variables
rename district_agency_type DistTypeLabels
rename state_location StateAbbrev
rename state_fips StateFips
rename district_agency_type_num DistType
rename ncesdistrictid NCESDistrictID
rename state_leaid State_leaid
rename ncesschoolid NCESSchoolID
rename county_name CountyName
rename county_code CountyCode
replace StateFips = 9
replace StateAbbrev = "CT"
if "`year'" == "2024" | "`year'" == "2023" {
rename school_type SchType 
}

// Make county proper case in 2015
replace CountyName = proper(CountyName) if SchYear == "2014-15"

//Fixing Unmerged with Data where possible
replace SchVirtual = 3 if NCESSchoolID == "090051001945" & SchYear == "2022-23"
replace SchLevel = 2 if NCESSchoolID == "090051001945" & SchYear == "2022-23"

replace NCESSchoolID = "090012010010" if NCESSchoolID == "090012000010" & SchYear == "2014-15"
replace NCESSchoolID = "090006010008" if NCESSchoolID == "090006000008" & SchYear == "2014-15"
replace NCESSchoolID = "090003010001" if NCESSchoolID == "090003000001" & SchYear == "2014-15"

replace DistTypeLabels = "Regular local school district" if SchName == "Geraldine Claytor Magnet Academy"
replace State_leaid = "0150011" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace SchType = 1 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace NCESDistrictID = "0900450" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace NCESSchoolID = "090045001918" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace seasch = "31" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace DistCharter = "No" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace DistType = 1 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace SchLevel = 2 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace SchVirtual = 0 if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace CountyName = "Fairfield County" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace CountyCode = "9001" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017

replace DistTypeLabels = "Regional education service agency" if SchName == "Mill Academy"
replace State_leaid = "CT-244" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchType = 4 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace seasch = "244-94" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace DistType = 4 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchLevel = -1 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace SchVirtual = -1 if SchName == "Mill Academy" & missing(NCESSchoolID)
replace CountyName = "New Haven County" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace CountyCode = "9009" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace NCESDistrictID = "0900070" if SchName == "Mill Academy" & missing(NCESSchoolID)
replace NCESSchoolID = "090007001505" if SchName == "Mill Academy" & missing(NCESSchoolID)

replace DistTypeLabels = "Regular local school district" if SchName == "Enlightenment School"
replace State_leaid = "CT-1510011" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace SchType = 1 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace seasch = "1510011-1519111" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace DistType = 1 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace SchLevel = 4 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace SchVirtual = 0 if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace CountyName = "New Haven County" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace CountyCode = "9009" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace DistLocale = "Suburb, midsize" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace NCESDistrictID = "0904830" if SchName == "Enlightenment School" & missing(NCESSchoolID)
replace NCESSchoolID = "090483001418" if SchName == "Enlightenment School" & missing(NCESSchoolID)

replace DistTypeLabels = "Local school district that is a component of a supervisory union" if SchName == "Woodland School" & missing(NCESSchoolID)
replace State_leaid = "CT-0430011" if SchName == "Woodland School" & missing(NCESSchoolID)
replace SchType = 2 if SchName == "Woodland School" & missing(NCESSchoolID)
replace seasch = "0430011-0439011" if SchName == "Woodland School" & missing(NCESSchoolID)
replace DistCharter = "No" if SchName == "Woodland School" & missing(NCESSchoolID)
replace DistType = 2 if SchName == "Woodland School" & missing(NCESSchoolID)
replace SchLevel = 4 if SchName == "Woodland School" & missing(NCESSchoolID)
replace SchVirtual = -1 if SchName == "Woodland School" & missing(NCESSchoolID)
replace CountyName = "Hartford County" if SchName == "Woodland School" & missing(NCESSchoolID)
replace CountyCode = "9003" if SchName == "Woodland School" & missing(NCESSchoolID)
replace DistLocale = "City, small" if SchName == "Woodland School" & missing(NCESSchoolID)
replace NCESDistrictID = "0901260" if SchName == "Woodland School" & missing(NCESSchoolID)
replace NCESSchoolID = "090126000205" if SchName == "Woodland School" & missing(NCESSchoolID)

replace DistTypeLabels = "Specialized public school district" if DistName == "Area Cooperative Educational Services"
replace State_leaid = "CT-2440014" if DistName == "Area Cooperative Educational Services"
replace NCESDistrictID = "0900070" if DistName == "Area Cooperative Educational Services"
replace DistCharter = "No" if DistName == "Area Cooperative Educational Services"
replace DistType = 9 if DistName == "Area Cooperative Educational Services"
replace CountyName = "New Haven County" if DistName == "Area Cooperative Educational Services"
replace CountyCode = "9009" if DistName == "Area Cooperative Educational Services"
replace seasch = StateAssignedDistID + "-" + StateAssignedSchID if _merge == 2

replace DistTypeLabels = "Regular local school district" if DistName == "Bridgeport School District"


//Dropping Unmerged with no data available and unmerged bilingual schools

drop if [_merge==2] & [(Lev1_percent == "*" | Lev1_percent == "--" | Lev1_percent == "0")  & (Lev2_percent == "*" | Lev2_percent == "--" | Lev2_percent == "0") & (Lev3_percent == "*" | Lev3_percent == "--" | Lev3_percent == "0" ) & (Lev4_percent == "*" | Lev4_percent == "--" | Lev4_percent == "0") & (ProficientOrAbove_percent == "*" | ProficientOrAbove_percent == "--" | ProficientOrAbove_percent == "0") & (ProficientOrAbove_count == "*" | ProficientOrAbove_count == "--" | ProficientOrAbove_count == "0")]

drop if (_merge==2) & strpos(SchName, "Bilingual") !=0

// Dropping if StudentSubGroup_TotalTested == 0 and StudentSubGroup != "All Students"
drop if (StudentSubGroup_TotalTested == "0" | (StudentSubGroup_TotalTested == "*" & Lev1_count == "--")) & StudentSubGroup != "All Students"

//Replacing NCES vars with Missing/not reported when applicable
label def agency_typedf -1 "Missing/not reported", add
replace DistType = -1 if missing(DistType) & DataLevel !=1
replace DistCharter = "Missing/not reported" if missing(DistCharter) & DataLevel !=1
replace SchType =-1 if missing(SchType) & DataLevel ==3
replace SchLevel = -1 if missing(SchLevel) & DataLevel ==3
replace CountyName = "Missing/not reported" if missing(CountyName) & DataLevel !=1
replace CountyCode = "Missing/not reported" if missing(CountyCode) & DataLevel !=1
replace SchVirtual = -1 if missing(SchVirtual) & DataLevel ==3
replace NCESDistrictID = "Missing/not reported" if missing(NCESDistrictID) & DataLevel !=1
replace NCESSchoolID = "Missing/not reported" if missing(NCESSchoolID) & DataLevel ==3
replace State_leaid = "Missing/not reported" if missing(State_leaid) & DataLevel !=1
replace seasch = "Missing/not reported" if missing(seasch) & DataLevel ==3


//Proficiency Criteria
gen ProficiencyCriteria = "Levels 3-4"

//AssmtName
gen AssmtName = "Smarter Balanced Assessment"
replace AssmtName = "NGSS Assessment" if Subject == "sci"

//State 
gen State = "Connecticut"

//AssmtType
gen AssmtType = "Regular"

//Flags
gen Flag_AssmtNameChange = "N"
gen Flag_CutScoreChange_ELA = "N"
gen Flag_CutScoreChange_math = "N"
gen Flag_CutScoreChange_sci = "Not applicable"
gen Flag_CutScoreChange_soc = "Not applicable"

foreach var of varlist Flag* {
	replace `var' = "Y" if `year' == 2015 & "`var'" != "Flag_CutScoreChange_soc" & "`var'" != "Flag_CutScoreChange_sci"
	replace `var' = "N" if "`var'" == "Flag_CutScoreChange_sci" & `year' >= 2019
	replace `var' = "Y" if `year' == 2022 & "`var'" != "Flag_AssmtNameChange" & "`var'" != "Flag_CutScoreChange_soc"
	replace `var' = "Y" if `year' == 2019 & "`var'" == "Flag_AssmtNameChange" & Subject == "sci"
	replace `var' = "Y" if `year' == 2019 & "`var'" == "Flag_CutScoreChange_sci"
}
replace Flag_CutScoreChange_soc = "Not applicable"

//Missing/empty Variables
gen Lev5_count = ""
gen Lev5_percent= ""

//AvgScaleScore
replace AvgScaleScore = "--" if AvgScaleScore == "N/A"

//Dropping specific schools in response to R1
drop if StateAssignedSchID == "2449414" | StateAssignedSchID == "2440214"

// Apply DistType labels

replace DistTypeLabels = "Missing/not reported" if DistTypeLabels == ""
replace DistType = -1 if  DistTypeLabels == "Missing/not reported"
replace DistType = 1 if DistTypeLabels == "Regular local school district"
labmask DistType, values(DistTypeLabels)

// Missing School 
replace NCESSchoolID = "090234011301" if SchName == "Mansfield Elementary School"
replace NCESDistrictID = "0902340" if SchName == "Mansfield Elementary School"
replace DistCharter = "No" if SchName == "Mansfield Elementary School"
replace SchType = 1 if SchName == "Mansfield Elementary School"
replace DistType = 1 if SchName == "Mansfield Elementary School"
replace StateAssignedDistID = "0780011" if SchName == "Mansfield Elementary School"
replace StateAssignedSchID = "0780111" if SchName == "Mansfield Elementary School"
replace SchLevel = 1 if SchName == "Mansfield Elementary School"
replace SchVirtual = 0 if SchName == "Mansfield Elementary School"
replace CountyName = "Capitol Planning Region" if SchName == "Mansfield Elementary School"
replace CountyCode = "9110" if SchName == "Mansfield Elementary School"


//Final Cleaning
recast str80 SchName


**** r1 updates 

// fixing distype 
decode DistType, gen(DistType1)
replace DistType1 = "" if DistType1 == "Missing/not reported"
drop DistType
rename DistType1 DistType


// fixing dist and sch names 
foreach var of varlist DistName SchName {
replace `var' = strtrim(`var')
replace `var' = stritrim(`var')
}

// fixing county names 
replace CountyName = "South Central Connecticut Planning Region" if NCESDistrictID == "0900070" & (SchYear=="2022-23" | SchYear=="2023-24")
replace CountyCode= "9170" if NCESDistrictID == "0900070" & (SchYear=="2022-23" | SchYear=="2023-24")

// fixing flags
replace Flag_CutScoreChange_ELA = "N" if `year' == 2021 | `year' == 2022
replace Flag_CutScoreChange_math = "N" if `year' == 2021 | `year' == 2022
replace Flag_CutScoreChange_sci = "N" if `year' == 2021 | `year' == 2022


// missing NCES data 
replace DistLocale = "City, midsize" if SchName == "Geraldine Claytor Magnet Academy" & `year' == 2017
replace DistLocale = "Rural, fringe" if SchName == "Mansfield Elementary School" & `year' == 2024

replace SchLevel = 1 if SchName == "Candlewood Lake Elementary School"  & `year' == 2024
replace SchVirtual = 3 if SchName == "Candlewood Lake Elementary School" &  `year' == 2024 // updated to "Supplemental Virtual" for homogeneity with other entries

replace SchVirtual = 3 if SchName == "Woodland School" & `year' == 2023 // updated to "Supplemental Virtual" for homogeneity with other entries

***Calculations***

//Converting ParticipationRate, ProficientOrAbove_percent, and Level percents to decimal and general cleaning
*destring in new var, ignore certain char, then replace org var with % upto 3 decimal places. 
destring ParticipationRate, gen(nParticipationRate) i(*N/A)
replace ParticipationRate = string(nParticipationRate/100, "%9.3g") if ParticipationRate != "*"
destring ProficientOrAbove_percent, gen(nProficientOrAbove_percent) i(*N/A)
replace ProficientOrAbove_percent = string(nProficientOrAbove_percent/100, "%9.3g") if ProficientOrAbove_percent != "*" & ProficientOrAbove_percent != "N/A"
replace ProficientOrAbove_percent = "--" if ProficientOrAbove_percent == "N/A"
replace ProficientOrAbove_count = "--" if ProficientOrAbove_count == "N/A"

foreach n in 1 2 3 4 {
	replace Lev`n'_percent = "--" if Lev`n'_percent == "N/A"
	replace Lev`n'_count = "--" if Lev`n'_count == "N/A"
	destring Lev`n'_count, gen(nLev`n'_count) i(*-)
	destring Lev`n'_percent, gen(nLev`n'_percent) i(*-)
	replace Lev`n'_percent = string(nLev`n'_percent/100, "%9.3g") if Lev`n'_percent != "*" & Lev`n'_percent != "--"
}

//Sometimes, ProficientOrAbove_count and ProficientOrAbove_percent can be calculated even if they're listed as suppressed for some reason. Correcting below. 
replace ProficientOrAbove_count = string(nLev3_count + nLev4_count, "%9.3g") if ProficientOrAbove_count == "*" & Lev3_count != "*" & Lev4_count != "*" & Lev3_count != "--" & Lev4_count != "--"

destring StudentSubGroup_TotalTested, gen(nStudentSubGroup_TotalTested) i("*" "-")

replace ProficientOrAbove_count = string(nStudentSubGroup_TotalTested - nLev3_count - nLev4_count, "%9.3g") if ProficientOrAbove_count == "*" & Lev3_count != "*" & Lev4_count != "*" & Lev3_count != "--" & Lev4_count != "--" & StudentSubGroup_TotalTested != "*" & StudentSubGroup_TotalTested != "--"
replace ProficientOrAbove_percent = string((nLev3_percent/100) + (nLev4_percent/100), "%9.3g") if ProficientOrAbove_percent == "*" & Lev3_percent != "*" & Lev4_percent != "*" & Lev3_percent != "--" & Lev4_percent != "--"
replace ProficientOrAbove_percent = string(1-(nLev1_percent/100) -(nLev2_percent/100), "%9.3g") if ProficientOrAbove_percent == "*" & Lev1_percent != "*" & Lev2_percent != "*" & Lev1_percent != "--" & Lev2_percent != "--"

// deriving Lev4_count 
destring StudentSubGroup_TotalTested, gen(total_count) ignore("*" "--")

global a 1 2 3 4
	foreach a in $a {
		destring Lev`a'_count, gen(n`a'_count) ignore("*" "--")
		destring Lev`a'_percent, gen(n`a'_percent) ignore("*" "--")
	}
	
destring ProficientOrAbove_count, gen(nprof_count) ignore("*" "--")
destring ProficientOrAbove_percent, gen(nprof_percent) ignore("*" "--")

*Deriving Lev4_count and Lev4_percent if total and other values are not suppressed    
replace n4_count = total_count - n1_count - n2_count - n3_count if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace n4_percent = 1 - n1_percent - n2_percent - n3_percent if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace n4_percent = 0 if n4_percent <= 0
replace n4_percent = 0 if n4_percent == 0.001

*Deriving Lev3_count and Lev3_percent if total and other values are not suppressed
replace n3_count = total_count - n1_count - n2_count - n4_count if Lev1_count != "*" & Lev2_count != "*" & Lev4_count != "*" & Lev3_count == "*" & StudentSubGroup_TotalTested != "*"
replace n3_percent = 1 - n1_percent - n2_percent - n4_percent if Lev1_count != "*" & Lev2_count != "*" & Lev4_count != "*" & Lev3_count == "*" & StudentSubGroup_TotalTested != "*"
replace n3_percent = 0 if n3_percent <= 0
replace n3_percent = 0 if n3_percent == 0.001

*Deriving Lev2_count and Lev2_percent if total and other values are not suppressed
replace n2_count = total_count - n1_count - n3_count - n4_count if Lev1_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev2_count == "*" & StudentSubGroup_TotalTested != "*"
replace n2_percent = 1 - n1_percent - n3_percent - n4_percent if Lev1_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev2_count == "*" & StudentSubGroup_TotalTested != "*"
replace n2_percent = 0 if n2_percent <= 0
replace n2_percent = 0 if n2_percent == 0.001

*Deriving Lev1_count and Lev1_percent if total and other values are not suppressed
replace n1_count = total_count - n2_count - n3_count - n4_count if Lev2_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev1_count == "*" & StudentSubGroup_TotalTested != "*"
replace n1_percent = 1 - n2_percent - n3_percent - n4_percent if Lev2_count != "*" & Lev3_count != "*" & Lev4_count != "*" & Lev1_count == "*" & StudentSubGroup_TotalTested != "*"
replace n1_percent = 0 if n1_percent <= 0
replace n1_percent = 0 if n1_percent == 0.001

*Deriving Proficient Or Above count from Level 3 and 4 values and Proficiency is defined as Level 3 + Level 4.
replace nprof_count = n3_count + n4_count if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace nprof_percent = n3_percent + n4_percent if Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & Lev4_percent == "*" & StudentSubGroup_TotalTested != "*"

*Replacing Level count and percent values calculated above. 
replace Lev4_count = string(n4_count) if Lev1_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev4_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev4_percent = string(n4_percent) if Lev1_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & Lev4_percent == "*" & StudentSubGroup_TotalTested != "*"

replace Lev3_count = string(n3_count) if Lev1_count != "*" & Lev2_count != "*" & Lev4_count != "*" & Lev3_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev3_percent = string(n3_percent) if Lev1_percent != "*" & Lev2_percent != "*" & Lev4_percent != "*" & Lev3_percent == "*" & StudentSubGroup_TotalTested != "*"

replace Lev2_count = string(n2_count) if Lev1_count != "*" & Lev4_count != "*" & Lev3_count != "*" & Lev2_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev2_percent = string(n2_percent) if Lev1_percent != "*" & Lev4_percent != "*" & Lev3_percent != "*" & Lev2_percent == "*" & StudentSubGroup_TotalTested != "*"

replace Lev1_count = string(n1_count) if Lev4_count != "*" & Lev2_count != "*" & Lev3_count != "*" & Lev1_count == "*" & StudentSubGroup_TotalTested != "*"
replace Lev1_percent = string(n1_percent) if Lev4_percent != "*" & Lev2_percent != "*" & Lev3_percent != "*" & Lev1_percent == "*" & StudentSubGroup_TotalTested != "*"

replace ProficientOrAbove_count = string(nprof_count) if ProficientOrAbove_count == "*" & nprof_count != .
replace ProficientOrAbove_percent = string(nprof_percent) if ProficientOrAbove_percent == "*" & nprof_percent != .

// Reordering variables and sorting data
local vars State StateAbbrev StateFips SchYear DataLevel DistName DistType 	///
    SchName SchType NCESDistrictID StateAssignedDistID NCESSchoolID 		///
    StateAssignedSchID DistCharter DistLocale SchLevel SchVirtual 			///
    CountyName CountyCode AssmtName AssmtType Subject GradeLevel 			///
    StudentGroup StudentGroup_TotalTested StudentSubGroup 					///
    StudentSubGroup_TotalTested Lev1_count Lev1_percent Lev2_count 			///
    Lev2_percent Lev3_count Lev3_percent Lev4_count Lev4_percent 			///
    Lev5_count Lev5_percent AvgScaleScore ProficiencyCriteria 				///
    ProficientOrAbove_count ProficientOrAbove_percent ParticipationRate 	///
    Flag_AssmtNameChange Flag_CutScoreChange_ELA Flag_CutScoreChange_math 	///
    Flag_CutScoreChange_sci Flag_CutScoreChange_soc
	keep `vars'
	order `vars'
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup

*Exporting into a separate folder Output for Stanford - without derivations*
*save "${Output_ND}/CT_AssmtData`year'_NoDev", replace //If .dta format needed. 
export delimited "${Output_ND}/CT_AssmtData`year'_NoDev", replace

***Derivations***
// deriving ProficientOrAbove_count using ProficientOrAbove_percent and StudentSubGroup_TotalTested, r2
replace ProficientOrAbove_count = string(round(real(ProficientOrAbove_percent) * real(StudentSubGroup_TotalTested),1)) if ProficientOrAbove_count == "*" & !missing(real(ProficientOrAbove_percent)) & !missing(real(StudentSubGroup_TotalTested))

*Exporting Output with derivations*
*save "${Output}/CT_AssmtData_`year'", replace //If .dta format needed. 
export delimited "${Output}/CT_AssmtData_`year'", replace
clear
}
* END of 01_CT_Cleaning.do 
