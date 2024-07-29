clear
set more off

global raw "/Volumes/T7/State Test Project/New Mexico/Original Data Files"
global output "/Volumes/T7/State Test Project/New Mexico/Output"
global NCES "/Volumes/T7/State Test Project/New Mexico/NCES"

cd "/Volumes/T7/State Test Project/New Mexico"

** Converting to dta **

import excel "${raw}/NM_OriginalData_2017_elamath.xlsx", sheet(PARCC 2017) cellrange(A4) firstrow clear
drop J-N
drop if Code == .
save "${raw}/NM_AssmtData_2017_PARCC.dta", replace
import excel "${raw}/NM_OriginalData_2017_sci.xlsx", sheet(Webfiles SBASCI 2016) cellrange(A3) firstrow clear
drop I-M
save "${raw}/NM_AssmtData_2017_SBA.dta", replace

import excel "${raw}/NM_OriginalData_2017_all_RegularAlt.xlsx", firstrow cellrange(B3) clear
save  "${raw}/NM_AssmtData_2017_all_RegularAlt", replace

import excel "${raw}/NM_OriginalData_2018_elamath.xlsx", sheet(PARCC 2018) cellrange(A4) firstrow clear
save "${raw}/NM_AssmtData_2018_PARCC.dta", replace
import excel "${raw}/NM_OriginalData_2018_sci.xlsx", sheet(SBA Science by Grade 2018 MASKE) cellrange(A3) firstrow clear
drop I-K
save "${raw}/NM_AssmtData_2018_SBA.dta", replace

import excel "${raw}/NM_OriginalData_2018_all_RegularAlt.xlsx", firstrow cellrange(B3) clear
save  "${raw}/NM_AssmtData_2018_all_RegularAlt", replace
	

import excel "${raw}/NM_OriginalData_2019_elamath.xlsx", sheet(TAMELA Proficiencies 2019 MASKE) cellrange(A4) firstrow clear
save "${raw}/NM_AssmtData_2019_TAMELA.dta", replace
import excel "${raw}/NM_OriginalData_2019_sci.xlsx", sheet(SBA_Science_by_Grade_2019) cellrange(A3) firstrow clear
drop I-K
drop if Code == ""
save "${raw}/NM_AssmtData_2019_SBA.dta", replace

import excel "${raw}/NM_OriginalData_2019_all_RegularAlt.xlsx", firstrow cellrange(B3) clear
save  "${raw}/NM_AssmtData_2019_all_RegularAlt", replace 

import excel "${raw}/NM_OriginalData_2021_elamath.xlsx", sheet(MSSA ESSA 2021) cellrange(A3) firstrow clear
drop J-N
drop if StateorDistrict == ""
save "${raw}/NM_AssmtData_2021_MSSA.dta", replace

import excel "${raw}/NM_OriginalData_2015_2023_all_DataRequest.xlsx", sheet("2021 optional testing (10%)") cellrange(A2) firstrow clear
save "${raw}/NM_AssmtData_2021_ASR.dta", replace

import excel "${raw}/NM_OriginalData_2015_2023_all_DataRequest.xlsx", sheet("2022 Part Prof All grades") firstrow clear
save "${raw}/NM_AssmtData_2022_all.dta", replace


foreach s in ELA MATH SCIENCE {
import excel "${raw}/NM_OriginalData_2015_2023_all_DataRequest.xlsx", sheet("2023 `s' By Grade") firstrow clear
save "${raw}/NM_AssmtData_2023_`s'", replace
}

