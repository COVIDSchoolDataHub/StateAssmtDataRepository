import excel "$data/WV_SY18to24_Subgroup_Participation-Enroll_19Feb2025.xlsx", sheet ("Participation Rate") cellrange(A2) firstrow clear

//Rename Variables
rename Dist StateAssignedDistID
rename Schl StateAssignedSchID
rename PopulationGroup StudentGroup
rename Subgroup StudentSubGroup

rename Grade03 Grade03math
rename Grade04 Grade04math
rename Grade05 Grade05math
rename Grade06 Grade06math
rename Grade07 Grade07math
rename Grade08 Grade08math
rename Grade11 Grade11math

rename O Grade03ela
rename P Grade04ela
rename Q Grade05ela
rename R Grade06ela
rename S Grade07ela
rename T Grade08ela
rename U Grade11ela

rename V Grade05sci
rename W Grade08sci
rename X Grade11sci

rename Grade* ParticipationRateGrade*

//Reshape Data
reshape long ParticipationRate, i(Year StateAssignedDistID StateAssignedSchID StudentGroup StudentSubGroup) j(GradeLevel) string

//IDs
replace StateAssignedDistID = "" if StateAssignedDistID == "999"
replace StateAssignedSchID = "" if StateAssignedSchID == "999"

//Subject & GradeLevel
gen Subject = substr(GradeLevel, 8, 4)
replace GradeLevel = subinstr(GradeLevel, Subject, "", 1)
replace GradeLevel = subinstr(GradeLevel, "rade", "", 1)
drop if GradeLevel == "G11"

//StudentGroup & StudentSubGroup
replace StudentSubGroup = "All Students" if StudentSubGroup == "Total"
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "Native American"
replace StudentSubGroup = "Economically Disadvantaged" if StudentSubGroup == "Direct Cert"
replace StudentSubGroup = "English Learner" if StudentSubGroup == "English Language Learner"
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Pacific Islander"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Special Education"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multi-racial"

replace StudentGroup = "All Students" if StudentGroup == "Total Population"
replace StudentGroup = "RaceEth" if StudentGroup == "Race/Ethnicity"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Learner"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military"

//Separate By Year
forvalues year = 2018/2024{
	if `year' == 2020 continue
	local prevyear =`=`year'-1'
	local schyear "`prevyear'-`year'"
	preserve
	keep if Year == "`schyear'"
	drop Year
	save "$data/WV_Participation_`year'", replace
	restore
}
