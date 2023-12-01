clear
set more off
local Original "/Volumes/T7/State Test Project/Alabama/Original Data"
local Output "/Volumes/T7/State Test Project/Alabama/Output"

//Importing
import excel "`Original'/AL_Enrollment_2023", firstrow allstring

//Renaming
rename A SystemName
rename B StudentSubGroup
drop C
drop D E F
rename G G03
rename H G04
rename I G05
rename J G06
rename K G07
rename L G08
drop M N O P Q R S

//Getting StateAssignedID'

gen StateID = substr(SystemName,1, strpos(SystemName, " ")-1)
replace StateID = StateID[_n-1] if missing(StateID)
replace SystemName = subinstr(SystemName, StateID,"",.)
replace SystemName = SystemName[_n-1] if missing(SystemName)

//Reshaping
replace StudentSubGroup = "All Students" if missing(StudentSubGroup)
reshape long G0, i(SystemName StateID StudentSubGroup) j(GradeLevel)

