clear
set more off
cd "/Volumes/T7/State Test Project/West Virginia"
global data "/Volumes/T7/State Test Project/West Virginia/Original Data Files"
global NCES "/Volumes/T7/State Test Project/NCES/NCES_Feb_2024"
global NCES_clean "/Volumes/T7/State Test Project/West Virginia/NCES_Clean"
global counts "/Volumes/T7/State Test Project/West Virginia/Counts"

import delimited "$counts/WV_2022_counts", case(preserve)

//Rename and Drop Variables
drop SchoolYear State
rename NCESLEAID NCESDistrictID
rename LEA DistName
rename School SchName
rename NCESSCHID NCESSchoolID
drop DataGroup
drop DataDescription
rename Value ParticipationRate
rename Subgroup StudentSubGroup
drop Denominator
rename Numerator StudentSubGroup_TotalTested
drop Population
rename AgeGrade GradeLevel
rename AcademicSubject Subject
drop ProgramType Outcome

//Variable Types
tostring NCESDistrictID, replace
replace NCESDistrictID = "" if NCESDistrictID == "."
tostring NCESSchoolID, replace force format("%15.6g")
replace NCESSchoolID = "" if NCESSchoolID == "."

//StudentSubGroup
replace StudentSubGroup = Characteristics if missing(StudentSubGroup) & !missing(Characteristics)
drop Characteristics
replace StudentSubGroup = "All Students" if strpos(StudentSubGroup, "All Students") !=0
replace StudentSubGroup = "American Indian or Alaska Native" if StudentSubGroup == "American Indian/Alaska Native/Native American"
drop if StudentSubGroup == "Asian"
replace StudentSubGroup = "Asian" if StudentSubGroup == "Asian/Pacific Islander"
replace StudentSubGroup = "Native Hawaiian or Pacific Islander" if StudentSubGroup == "Native Hawaiian or Other Pacific Islander"
replace StudentSubGroup = "Black or African American" if StudentSubGroup == "Black (not Hispanic) African American"
replace StudentSubGroup = "Hispanic or Latino" if StudentSubGroup == "Hispanic/Latino"
replace StudentSubGroup = "Two or More" if StudentSubGroup == "Multicultural/Multiethnic/Multiracial/other"
replace StudentSubGroup = "White" if StudentSubGroup == "White or Caucasian (not Hispanic)"
replace StudentSubGroup = "SWD" if StudentSubGroup == "Children with disabilities"
**Economically Disadvantaged Correct
**English Learner Correct
replace StudentSubGroup = "Foster Care" if StudentSubGroup == "Foster care students"
**Homeless Correct
replace StudentSubGroup = "Military" if StudentSubGroup == "Military connected"
**Male Correct
**Female Correct

//StudentGroup
gen StudentGroup = ""
replace StudentGroup = "All Students" if StudentSubGroup == "All Students"
replace StudentGroup = "RaceEth" if StudentSubGroup == "American Indian or Alaska Native" | StudentSubGroup == "Asian" | StudentSubGroup == "Black or African American" | StudentSubGroup == "Hispanic or Latino" | StudentSubGroup == "White" | StudentSubGroup == "Two or More" | StudentSubGroup == "Native Hawaiian or Pacific Islander"
replace StudentGroup = "Economic Status" if StudentSubGroup == "Economically Disadvantaged" | StudentSubGroup == "Not Economically Disadvantaged"
replace StudentGroup = "Gender" if StudentSubGroup == "Male" | StudentSubGroup == "Female" | StudentSubGroup == "Gender X"
replace StudentGroup = "EL Status" if StudentSubGroup == "English Proficient" | StudentSubGroup == "English Learner"
replace StudentGroup = "Disability Status" if StudentSubGroup == "SWD" | StudentSubGroup == "Non-SWD"
replace StudentGroup = "Migrant Status" if StudentSubGroup == "Migrant" | StudentSubGroup == "Non-Migrant"
replace StudentGroup = "Homeless Enrolled Status" if StudentSubGroup == "Homeless" | StudentSubGroup == "Non-Homeless"
replace StudentGroup = "Foster Care Status" if StudentSubGroup == "Foster Care" | StudentSubGroup == "Non-Foster Care"
replace StudentGroup = "Military Connected Status" if StudentSubGroup == "Military" | StudentSubGroup == "Non-Military"

//StudentGroup_TotalTested
egen StudentGroup_TotalTested = total(StudentSubGroup_TotalTested), by(StudentGroup NCESDistrictID NCESSchoolID GradeLevel Subject)

//GradeLevel
replace GradeLevel = subinstr(GradeLevel, "Grade ", "G0",.)

//Subject
replace Subject = "math" if Subject == "Mathematics"
replace Subject = "ela" if Subject == "Reading/Language Arts"
replace Subject = "sci" if Subject == "Science"

//ParticipationRate
replace ParticipationRate = "*" if regexm(ParticipationRate, "[0-9]") ==0
gen lowpart = "0-" if strpos(ParticipationRate, "<") !=0
gen highpart = "-1" if strpos(ParticipationRate, ">") !=0
replace ParticipationRate = subinstr(ParticipationRate,">=", "",.)
replace ParticipationRate = subinstr(ParticipationRate, "%","",.)
replace ParticipationRate = subinstr(ParticipationRate, "<", "",.)
replace ParticipationRate = string(real(ParticipationRate)/100, "%9.3g") if regexm(ParticipationRate, "[0-9]") !=0
replace ParticipationRate = lowpart+ParticipationRate if !missing(lowpart)
replace ParticipationRate = ParticipationRate + highpart if !missing(highpart)
drop *part
rename ParticipationRate ParticipationRate1

//DataLevel
gen DataLevel = "State" if missing(NCESDistrictID) & missing(NCESSchoolID)
replace DataLevel = "District" if !missing(NCESDistrictID) & missing(NCESSchoolID)
replace DataLevel = "School" if !missing(NCESDistrictID) & !missing(NCESSchoolID)
label def DataLevel  1 "State" 2 "District" 3 "School"
encode DataLevel, gen(nDataLevel) label(DataLevel)
drop DataLevel
rename nDataLevel DataLevel
sort DataLevel
replace DistName = "All Districts" if DataLevel == 1
replace SchName = "All Schools" if DataLevel !=3

//Sorting, Saving
order DataLevel DistName NCESDistrictID SchName NCESSchoolID Subject GradeLevel StudentGroup StudentGroup_TotalTested StudentSubGroup StudentSubGroup_TotalTested ParticipationRate
sort DataLevel DistName SchName Subject GradeLevel StudentGroup StudentSubGroup
save "$counts/WV_2022_counts", replace
clear




