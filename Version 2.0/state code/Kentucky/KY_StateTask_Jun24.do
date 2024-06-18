clear
cd "/Volumes/T7/State Test Project/Kentucky/Output"

import delimited "KY_AssmtData_2022.csv", clear case(preserve)
replace Flag_CutScoreChange_sci = "Y"
export delimited "KY_AssmtData_2022.csv", replace
