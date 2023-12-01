clear
set more off

global raw "/Users/maggie/Desktop/New Mexico/Original Data Files"
global output "/Users/maggie/Desktop/New Mexico/Output"
global NCES "/Users/maggie/Desktop/New Mexico/NCES/Cleaned"

cd "/Users/maggie/Desktop/New Mexico"

** Converting to dta **

import excel "${raw}/NM_OriginalData_2017_elamath.xlsx", sheet(PARCC 2017) cellrange(A4) firstrow clear
drop J-N
drop if Code == .
save "${raw}/NM_AssmtData_2017_PARCC.dta", replace
import excel "${raw}/NM_OriginalData_2017_sci.xlsx", sheet(Webfiles SBASCI 2016) cellrange(A3) firstrow clear
drop I-M
save "${raw}/NM_AssmtData_2017_SBA.dta", replace

import excel "${raw}/NM_OriginalData_2018_elamath.xlsx", sheet(PARCC 2018) cellrange(A4) firstrow clear
save "${raw}/NM_AssmtData_2018_PARCC.dta", replace
import excel "${raw}/NM_OriginalData_2018_sci.xlsx", sheet(SBA Science by Grade 2018 MASKE) cellrange(A3) firstrow clear
drop I-K
save "${raw}/NM_AssmtData_2018_SBA.dta", replace	

import excel "${raw}/NM_OriginalData_2019_elamath.xlsx", sheet(TAMELA Proficiencies 2019 MASKE) cellrange(A4) firstrow clear
save "${raw}/NM_AssmtData_2019_TAMELA.dta", replace
import excel "${raw}/NM_OriginalData_2019_sci.xlsx", sheet(SBA_Science_by_Grade_2019) cellrange(A3) firstrow clear
drop I-K
drop if Code == ""
save "${raw}/NM_AssmtData_2019_SBA.dta", replace

import excel "${raw}/NM_OriginalData_2021_elamath.xlsx", sheet(MSSA ESSA 2021) cellrange(A3) firstrow clear
drop J-N
drop if StateorDistrict == ""
save "${raw}/NM_AssmtData_2021_MSSA.dta", replace

import excel "${raw}/NM_OriginalData_2022_all.xlsx", sheet(AVT by Entity & Group 2022) cellrange(A3) firstrow clear
drop H I N
drop if StateorDistrict == ""
save "${raw}/NM_AssmtData_2022_all.dta", replace

import excel "${raw}/NM_OriginalData_2023_ela.xlsx", sheet(DSRC SY 2022-23, Proficiency, E) firstrow clear
drop if District == ""
save "${raw}/NM_AssmtData_2023_ela.dta", replace
import excel "${raw}/NM_OriginalData_2023_math.xlsx", sheet(DSRC SY 2022-23, Proficiency, M) firstrow clear
drop if District == ""
save "${raw}/NM_AssmtData_2023_math.dta", replace
import excel "${raw}/NM_OriginalData_2023_sci.xlsx", sheet(DSRC SY 2022-23, Proficiency, S) firstrow clear
drop if District == ""
save "${raw}/NM_AssmtData_2023_sci.dta", replace

